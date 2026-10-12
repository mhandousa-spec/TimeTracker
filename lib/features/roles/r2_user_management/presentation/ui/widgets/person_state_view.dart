/// Module: roles / r2_user_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: person_state_view.dart
/// Purpose: Declares `PersonStateView`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 25/8/2026 - Avatar falls back to the gender SVG (AssetImage could
///                      never render it).

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/23-custom_check_box.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/core/helper/data_grc_module/core/extensions/extensions.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_app_module/core/widgets/custom_check_box.dart';

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/custom/75-custom_title_value_widget.dart';
// REMOVED_MODULE: import '../../../../../../external/services_app_module/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/domain/entities/user_permission_entity.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';

class PersonStateView extends StatelessWidget {
  PersonStateView(
      {required this.person,
      required this.onTap,
      this.isEdit = false,
      this.isSelected = false,
      this.showAccessDates = false,
      super.key,
      this.color});
  UserPermissionEntity person;
  var onTap;
  Color? color;
  bool isEdit;
  bool isSelected;
  bool showAccessDates;

  /// The person's photo, or the gender avatar when they have none.
  ///
  /// FIXED 25/8/2026 — this was one `CircleAvatar` doing
  /// `backgroundImage: imagePath.contains('http') ? NetworkImage(...) :
  /// AssetImage(imagePath)`, and the else branch could never work.
  /// `EmployeeHelper.getEmployeeImage` (which fills `imagePath`) returns the
  /// photo URL when there is one and otherwise
  /// `male_avatar.svg` / `female_avatar.svg` — and `AssetImage` cannot decode
  /// an SVG. So every employee without a photo got a blank circle.
  ///
  /// The fallback now renders through `SvgPicture.asset`, matching the avatar
  /// used elsewhere in the app. It picks the file off `person.gender` rather
  /// than trusting `imagePath`, so the choice is made from the data instead of
  /// from a string the helper happened to build.
  ///
  /// Sizes: `radius: 20.sp` keeps this card's existing avatar footprint, and
  /// the 40.sp SVG box is exactly that circle's diameter, so the artwork fills
  /// it without being cropped.
  Widget _buildAvatar() {
    if (person.imagePath.contains('http')) {
      return CircleAvatar(
        radius: 20.sp,
        backgroundColor: AppColors.primary,
        backgroundImage: NetworkImage(person.imagePath),
      );
    }

    return CircleAvatar(
      radius: 20.sp,
      backgroundColor: Colors.transparent,
      child: ClipOval(
        child: SvgPicture.asset(
          person.gender == 'male'
              ? 'assets/icons_assets/main_icons_assets/male_avatar.svg'
              : 'assets/icons_assets/main_icons_assets/female_avatar.svg',
          fit: BoxFit.cover,
          width: 40.sp,
          height: 40.sp,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        decoration: BoxDecoration(
          color: color ?? AppColors.card,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsetsDirectional.all(10),
        child: Column(
          spacing: 10.sp,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildAvatar(),
                  SizedBox(width: 10.w),
                  Expanded(
                    // FIXED 28/8/2026: the department and the job title were
                    // each wrapped in an `Expanded`, so instead of taking the
                    // height their text needs they were squeezed into whatever
                    // was left of the tile after the name — and the tile is a
                    // fixed `mainAxisExtent`. At three lines there was not
                    // enough room, so both lines were cut off mid-glyph (the
                    // Arabic descenders in "مدقق داخلي" lost their tails).
                    //
                    // Each line now takes its own natural height
                    // (MainAxisSize.min, no Expanded) and the grid tile was
                    // grown to fit all three — see the `mainAxisExtent` in
                    // add_new_users_access.dart. `maxLines: 1` + ellipsis keeps
                    // a long department name on one line, so the block can
                    // never grow past the height the tile now allows.
                    child: Column(
                      spacing: 2.sp,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          FormatHelper.capitalize(context.isArabic
                              ? person.arabicName
                              : person.englishName),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: StyleText.fontSize14Weight500.copyWith(
                            color: AppColors.text
                          ),
                        ),
                        Text(
                          FormatHelper.capitalize(
                              person.departmentName(
                                  context.isArabic,
                                  context.read<MainCoreDepartmentCubit>())),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: StyleText.fontSize12Weight500.copyWith(color: AppColors.spanText).copyWith(
                              color: AppColors.secondaryText
                          ),
                        ),
                        Text(
                          FormatHelper.capitalize(
                              person.jobTitle(context.isArabic)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: StyleText.fontSize12Weight500.copyWith(color: AppColors.spanText).copyWith(
                              color: AppColors.secondaryText
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onTap != null)
                    Align(
                        alignment: AlignmentDirectional.topEnd,
                        child: (isEdit)
                            ? CustomSvgImage(assetPath: AppAssets.minusCircle)
                            : CustomCheckBox(isSelected: isSelected))
                ],
              ),
            ),
            if (showAccessDates)
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FittedBox(
                    child: CustomTitleValueWidget(
                        title: S.of(context).access_granted,
                        titleStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack)
                            .copyWith(fontSize: 10.sp),
                        valueStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack)
                            .copyWith(fontSize: 10.sp, color: AppColors.text),
                        value: person.startDate ?? '-'),
                  ),
                  Spacer(),
                  FittedBox(
                    child: CustomTitleValueWidget(
                        title: S.of(context).access_revoked,
                        titleStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack)
                            .copyWith(fontSize: 10.sp),
                        valueStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack)
                            .copyWith(fontSize: 10.sp, color: AppColors.text),
                        value: person.endDate ?? '-'),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}

// REMOVED 12/8/2026: a large commented-out Row block. It was the last
// user of GetX's `.tr` string extension in this feature, and dead code
// besides — the live layout below replaced it.
