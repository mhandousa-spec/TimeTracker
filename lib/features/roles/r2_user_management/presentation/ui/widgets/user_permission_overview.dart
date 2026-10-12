/// Module: roles / r2_user_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: user_permission_overview.dart
/// Purpose: Declares `UserPermissionOverview`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 25/8/2026 - The card's status line now renders a localized name.
/// Updated: 29/8/2026 - Access dates render through LocalizedDate, so every
///          card shows the same "23 Aug 2023" / "٢٣ أغسطس ٢٠٢٣" shape.

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/core/new_theme.dart';

import 'package:knowticed_plus/core/helper/main_helper/employee_helper.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_date.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/75-custom_title_value_widget.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/domain/entities/user_permission_entity.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/ui/pages/employee_details.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/ui/widgets/user_access_status_label.dart';

import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:collection/collection.dart';
class UserPermissionOverview extends StatelessWidget {
  UserPermissionOverview({super.key, required this.userPermissionEntity});

  final UserPermissionEntity userPermissionEntity;

  /// ✅ Get localized role name
  String _getLocalizedRoleName(BuildContext context) {
    if (userPermissionEntity.accessName == null ||
        userPermissionEntity.accessName!.isEmpty) {
      return '-';
    }

    try {
      final roleCubit = context.read<RoleCubit>();
      final role = roleCubit.roles.firstWhereOrNull(
              (r) => r.roleId == userPermissionEntity.accessName ||
              r.currentRoleName == userPermissionEntity.accessName
      );

      if (role != null) {
        // Return localized name based on current locale
        return !context.isArabic
            ? role.currentRoleName
            : role.currentRoleNameAr;
      }

      // Fallback to accessName if role not found
      return userPermissionEntity.accessName!;
    } catch (e) {
      return userPermissionEntity.accessName!;
    }
  }

  /// ✅ Get status color based on status name
  Color _getStatusColor(String statusName) {
    final normalizedStatus = statusName.toLowerCase().replaceAll(' ', '');

    Color resultColor;
    switch (normalizedStatus) {
      case 'active':
        resultColor = AppColors.lightGreen; // Green
        break;
      case 'inactive':
        resultColor = AppColors.red; // Red
        break;
      case 'scheduled':
        resultColor = AppColors.orange; // Orange
        break;
      case 'expiringsoon':
        resultColor = AppColors.expiringSoon; // Dark Red
        break;
      default:
        resultColor = AppColors.card;
        break;
    }

    return resultColor;
  }

  /// One of the card's access dates, in the reader's locale.
  ///
  /// REPLACED 29/8/2026 — this was ~110 lines: a four-stage parser, a hardcoded
  /// Arabic month table and a digit-conversion loop. Two faults it had:
  ///
  ///  * It parsed the named-month shapes with `'en'` only, so a row stored with
  ///    an Arabic month came back unparsed and the card painted the RAW string
  ///    — which is why one card read "فبراير 25, 2027" (storage vocabulary,
  ///    Latin digits, comma and all) while the card beside it read
  ///    "٢٧ أغسطس ٢٠٢٦".
  ///  * The English branch used `DateFormat('dd MMM yyyy')` with no locale, so
  ///    its month names followed whatever `Intl.defaultLocale` happened to be
  ///    rather than the screen's.
  ///
  /// [LocalizedDate] now owns both the parsing and the output for every screen:
  /// "23 Aug 2023" in English, "٢٣ أغسطس ٢٠٢٣" in Arabic, from any of the
  /// shapes this app has ever written.
  String _getLocalizedDate(BuildContext context, String? dateString) =>
      LocalizedDate.ofStored(context, dateString);

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;

    var isMobile = ContextExtension(context).isPhone;

    return GestureDetector(
      // CHANGED 21/9/2026 — a card ALWAYS opens the employee's details.
      // It used to open the role editor instead whenever the employee's role
      // was still a DRAFT, so tapping a person landed on "Adding New Role"
      // (reported with the "Compliance Policy Review" cards). Drafts are
      // edited from Role Management, where they are listed as roles.
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RoleEmployeeDetailsPage(
              userPermission: userPermissionEntity,
            ),
          ),
        );
      },
      child: Container(
          padding: EdgeInsets.all(10.sp),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: AppColors.card
          ),
          child: Column(
              spacing: 10.sp,
              mainAxisSize: MainAxisSize.min,
              children: [
            // No fixed height here: the name/role/status stack is taller than
            // the 52.sp this used to hard-code, which clipped it. The grid's
            // mainAxisExtent sizes the card instead.
            Container(
              child: Row(
                spacing: 5.sp,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  userImage(),
                  SizedBox(width: 3.sp),
                  // Expanded so long employee names ellipsize instead of
                  // overflowing the card horizontally.
                  Expanded(
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      Text(  FormatHelper.capitalize(EmployeeHelper.getEmployeeLocalizedNameWithId(
                          employeeId: userPermissionEntity.employeeId,
                          context: context)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: StyleText.fontSize14Weight500.copyWith(
                            color: AppColors.text
                        ),

                      ),


                      isMobile ? SizedBox() : SizedBox(height: 3.h),

                      // ✅ UPDATED: Use localized role name
                      CustomTitleValueWidget(
                          title: "${S.of(context).roleType}: ",
                          value: FormatHelper.capitalize(_getLocalizedRoleName(context))
                      ),

                      isMobile ? SizedBox() :   SizedBox(height: 2.h),

                      Builder(
                          builder: (context) {
                            // LOCALIZED 25/8/2026: the card printed
                            // `FormatHelper.capitalize(accessStatus.name)` — the
                            // raw enum identifier — so an Arabic user read
                            // "Active" / "Scheduled" on a translated card.
                            //
                            // `_getStatusColor` still keys off the enum NAME,
                            // and must: it matches identifiers, not display
                            // text, so it has to stay locale-independent.
                            final statusName =
                                userPermissionEntity.accessStatus.name;
                            final statusLabel =
                                userPermissionEntity.accessStatus.label(context);
                            final statusColor = _getStatusColor(statusName);



                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("${S.of(context).status}: ",style: StyleText.fontSize12Weight400.copyWith(
                                  color: AppColors.secondaryText
                                ),),

                                Flexible(
                                  child: Text(statusLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: StyleText.fontSize12Weight400.copyWith(
                                    color: statusColor
                                ),),
                                ),
                              ],
                            );
                          }
                      )
                    ],
                  ),
                  ),
                ],
              ),
            ),
            // Flexible (not Spacer) so the two date pairs share the row and
            // ellipsize when the card is narrow, instead of overflowing right.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: CustomTitleValueWidget(
                      title: "${S.of(context).access_granted}: ",
                      titleStyle: StyleText.fontSize10Weight400.copyWith(
                        color: AppColors.secondaryText
                      ),
                      valueStyle: StyleText.fontSize10Weight400.copyWith(
                          color: AppColors.text
                      ),
                      value: _getLocalizedDate(context, userPermissionEntity.startDate)),
                ),
                SizedBox(width: 4.sp),
                Flexible(
                  child: CustomTitleValueWidget(
                      title: "${S.of(context).access_revoked}: ",
                      titleStyle: StyleText.fontSize10Weight400.copyWith(
                          color: AppColors.secondaryText
                      ),
                      valueStyle:  StyleText.fontSize10Weight400.copyWith(
                          color: AppColors.text
                      ),
                      value: _getLocalizedDate(context, userPermissionEntity.endDate)),
                ),
              ],
            )
          ])),
    );
  }

  Widget userImage() {
    String imageUrl = EmployeeHelper.getEmployeeImageWithId(
        employeeId: userPermissionEntity.employeeId);

    // ✅ Handle empty, null, or invalid image paths
    bool isValidUrl = imageUrl.isNotEmpty &&
        imageUrl != "[]" &&
        imageUrl.contains('http');

    bool isValidAsset = imageUrl.isNotEmpty &&
        imageUrl != "[]" &&
        !imageUrl.contains('http');

    return ClipRRect(
      borderRadius: BorderRadius.circular(50.r),
      child: isValidUrl
          ? Image.network(
        imageUrl,
        width: 50.sp,
        height: 50.sp,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackImage();
        },
      )
          : isValidAsset
          ? Image.asset(
        imageUrl,
        width: 50.sp,
        height: 50.sp,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackImage();
        },
      )
          : _buildFallbackImage(),
    );
  }

  // ✅ Add fallback image widget
  Widget _buildFallbackImage() {
    return Container(
        width: 50.sp,
        height: 50.sp,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(50.r),
        ),
        child: CustomSvgImage(assetPath: "assets/icons_assets/main_icons_assets/male_avatar.svg")
    );
  }
}