/// Module: GRC Policy Management
/// Description: Read-only card widget for a single Control, shown in the
///              Controls list on the Policy Details page.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-15
/// Dependencies: Flutter SDK, AppColors, AppTheme, ControlEntity, ControlStatus
/// Revision History: 2026-07-15 - Initial creation
library;

/// ************************* FILE INFO *************************** ///
/// File Name: control_card_widget.dart
/// Purpose: Contains ControlCardWidget, a read-only list-item card that
///          displays a single ControlEntity's status, score, weight,
///          frequency dates, and last edit. Tapping opens it for editing.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 15/7/2026

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_status.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/entities/owner_entity.dart';
import 'package:knowticed_plus/features/grc/control_owner/presentation/controller/owner_cubit.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_l10n.dart';

/// class name: [ControlCardWidget]
///
/// purpose: read-only list-item card for a single [ControlEntity]. Used by
///          the Controls section of the Policy Details page.
///
/// REQUIRES an [OwnerCubit] ancestor -- PolicyDetailsPage provides one for
/// the whole list. The card needs it because a control's owner is not a
/// field on [ControlEntity]: the assignment is recorded on the other side,
/// in `OwnerEntity.assigningControls`.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 15/7/2026
class ControlCardWidget extends StatelessWidget {
  final ControlEntity control;
  final VoidCallback onTap;

  const ControlCardWidget({
    super.key,
    required this.control,
    required this.onTap,
  });

  Color _statusColor(ControlStatus status) {
    switch (status) {
      case ControlStatus.active:
        return AppColors.green;
      case ControlStatus.inactive:
        return AppColors.orange;
      case ControlStatus.scheduled:
        return AppColors.primary;
      case ControlStatus.expired:
        return AppColors.red;

      // GRC bug report p17 "branding": the same blue the Unassigned filter
      // tab uses above the list (policy_view_mode_widget), not grey.
      case ControlStatus.unassigned:
        return AppColors.blue;
      case ControlStatus.draft:
        return AppColors.colorGrey;
    }
  }

  /// "Control Owner: (avatar) Name" -- the row Figma draws between the
  /// control name and the dates, and the one piece of the card that was
  /// never built.
  ///
  /// Resolves out of the module-wide owner list the page already holds
  /// rather than fetching per card, and falls back to "Not Assigned" for a
  /// control nobody owns yet (an Unassigned or Draft control, which Figma's
  /// always-populated mock never shows).
  Widget _buildOwnerRow(BuildContext context) {
    return BlocBuilder<OwnerCubit, OwnerState>(
      builder: (context, state) {
        final List<OwnerEntity> owners =
            state is OwnerListLoaded ? state.owners : const <OwnerEntity>[];

        // The cubit's own predicate, not a re-written copy of it -- the same
        // call ControlDescriptionSectionWidget and AddEditControlPage make.
        final List<String> emails = context.read<OwnerCubit>().alreadyAssignedEmails(
              owners,
              policyId: control.policyId,
              controlId: control.id,
            );
        final String email = emails.isEmpty ? '' : emails.first;

        return Row(
          children: [
            Text(
              '${FormatHelper.capitalize(S.of(context).controlOwner)}: ',
              style: StyleText.fontSize12Weight400
                  .copyWith(color: AppColors.secondaryText),
            ),
            if (email.isEmpty)
              Flexible(
                child: Text(
                  FormatHelper.capitalize(S.of(context).notAssigned),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  // GRC bug report p17: branding blue, matching Unassigned.
                  style: StyleText.fontSize12Weight500
                      .copyWith(color: AppColors.blue),
                ),
              )
            else ...[
              _ownerAvatar(email),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  FormatHelper.capitalize(employeeDisplayName(context, email)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: StyleText.fontSize12Weight500
                      .copyWith(color: AppColors.text),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  /// `foregroundImage` over an SVG child, not `backgroundImage` -- the
  /// default silhouette is an SVG that AssetImage cannot decode, so a
  /// background image would paint nothing. Same arrangement GrcOwnerBadge
  /// and the previous-owners cards use.
  Widget _ownerAvatar(String email) {
    final String photo = findEmployeeByEmail(email).displayPhoto;
    final bool hasPhoto =
        photo.isNotEmpty && photo != AppAssets.defaultEmployeeAvatar;

    return CircleAvatar(
      radius: 11.r,
      backgroundColor: AppColors.moreLightGrey,
      foregroundImage: hasPhoto ? appImageProvider(photo) : null,
      child: ClipOval(
        child: CustomSvgImage(
          assetPath: AppAssets.defaultEmployeeAvatar,
          width: 22.r,
          height: 22.r,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;
    final dateFormat = DateFormat('d MMM yyyy', isArabic ? 'ar' : 'en');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(4.r),
          boxShadow: CardStyles.shadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text.rich(
                  TextSpan(
                    text:
                        '${FormatHelper.capitalize(S.of(context).controlStatus)}: ',
                    style: StyleText.fontSize12Weight400
                        .copyWith(color: AppColors.secondaryText),
                    children: [
                      TextSpan(
                        text: FormatHelper.capitalize(
                            grcTr(context, control.status.value)),
                        style: StyleText.fontSize12Weight500
                            .copyWith(color: _statusColor(control.status)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.field,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${FormatHelper.capitalize(S.of(context).score)}: ',
                        style: StyleText.fontSize12Weight500
                            .copyWith(color: AppColors.secondaryText),
                      ),

                      Text(
                        '${control.score}',
                        style: StyleText.fontSize12Weight500
                            .copyWith(color: AppColors.text),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              FormatHelper.capitalize(
                  isArabic ? control.controlsNameAr : control.controlsNameEn),
              style:
                  StyleText.fontSize16Weight600.copyWith(color: AppColors.text),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.h),
            _buildOwnerRow(context),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    text:
                        '${FormatHelper.capitalize(S.of(context).startDate)}: ',
                    style: StyleText.fontSize12Weight400
                        .copyWith(color: AppColors.secondaryText),
                    children: [
                      TextSpan(
                        text: FormatHelper.capitalize(dateFormat.format(control.startDate)),
                        style: StyleText.fontSize12Weight500
                            .copyWith(color: AppColors.text),
                      ),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    text:
                        '${FormatHelper.capitalize(S.of(context).endDate)}: ',
                    style: StyleText.fontSize12Weight400
                        .copyWith(color: AppColors.secondaryText),
                    children: [
                      TextSpan(
                        text: FormatHelper.capitalize(dateFormat.format(control.endDate)),
                        style: StyleText.fontSize12Weight500
                            .copyWith(color: AppColors.text),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    text:
                        '${FormatHelper.capitalize(S.of(context).controlWeight)}: ',
                    style: StyleText.fontSize12Weight400
                        .copyWith(color: AppColors.secondaryText),
                    children: [
                      TextSpan(
                        text: FormatHelper.capitalize(control.controlsWeight.toStringAsFixed(0)),
                        style: StyleText.fontSize12Weight500
                            .copyWith(color: AppColors.text),
                      ),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    text:
                        '${FormatHelper.capitalize(S.of(context).last_edit)}: ',
                    style: StyleText.fontSize12Weight400
                        .copyWith(color: AppColors.secondaryText),
                    children: [
                      TextSpan(
                        text: FormatHelper.capitalize(dateFormat.format(control.lastModifiedDate)),
                        style: StyleText.fontSize12Weight500
                            .copyWith(color: AppColors.text),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
