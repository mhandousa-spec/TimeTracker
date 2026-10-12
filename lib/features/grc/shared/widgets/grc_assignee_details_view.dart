/// Module: GRC shared widgets
/// Description: Body of the Control Champion and Control Owner details
///              screens -- profile card, action row, Policies, Controls and
///              Tasks -- laid out for the 375 / 768 / 1024 MAGDY frames.
/// Author: Knowticed Plus team
/// Date: 2026-09-15
/// Dependencies: GrcPersonProfileCard, GrcAssigneeTasksSection,
///               customButton (5), customButtonWithSvg (6)
library;

import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_assignee_tasks_section.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_assignment_chip.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_button_loading_placeholder.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_person_profile_card.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Which assignee the details screen is for. Picks the Tasks source.
enum GrcAssigneeKind { champion, owner }

const String _editSvg = 'assets/icons_assets/data_grc_assets/editButton.svg';
const String _removeSvg =
    'assets/icons_assets/main_icons_assets/minus_circle.svg';

/// Fixed width MAGDY gives every action button on this row (135 at 768
/// and 1024). ButtonSizing still owns the 38 height.
const double _actionWidth = 135;

/// class name: [GrcAssigneeDetailsView]
///
/// purpose: the scrollable content of a champion / owner details screen.
///          The page keeps its own state (loading flags, cubit listeners,
///          navigation) and hands this widget the resolved names and the
///          callbacks.
class GrcAssigneeDetailsView extends StatelessWidget {
  final GrcAssigneeKind kind;
  final String moduleId;
  final String email;
  final bool isLoadingNames;
  final List<String> policyNames;
  final List<String> controlNames;

  /// Null hides "Contact Manager" (the owner frames do not draw it).
  final VoidCallback? onContactManager;
  final VoidCallback onReassign;
  final bool isReassignLoading;
  final VoidCallback onEdit;
  final bool isEditLoading;
  final VoidCallback onRemove;

  const GrcAssigneeDetailsView({
    super.key,
    required this.kind,
    required this.moduleId,
    required this.email,
    required this.isLoadingNames,
    required this.policyNames,
    required this.controlNames,
    required this.onReassign,
    required this.isReassignLoading,
    required this.onEdit,
    required this.isEditLoading,
    required this.onRemove,
    this.onContactManager,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = screenSizeOf(context) == ScreenSize.mobile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GrcPersonProfileCard(email: email),
        SizedBox(height: 15.h),
        _actions(context, isMobile),
        SizedBox(height: 15.h),
        _chipsSection(context, S.of(context).policies, policyNames),
        SizedBox(height: 15.h),
        _chipsSection(context, S.of(context).controls, controlNames),
        SizedBox(height: 20.h),
        switch (kind) {
          GrcAssigneeKind.champion =>
            GrcChampionTasksSection(moduleId: moduleId, championEmail: email),
          GrcAssigneeKind.owner =>
            GrcOwnerTasksSection(moduleId: moduleId, ownerEmail: email),
        },
        SizedBox(height: 24.h),
      ],
    );
  }

  // ── action row ──────────────────────────────────────────────────────

  TextStyle get _buttonText =>
      StyleText.fontSize14Weight400.copyWith(color: AppColors.textButton);

  Widget _actions(BuildContext context, bool isMobile) {
    final List<Widget> leading = [
      if (onContactManager != null)
        customButtonWithSvg(
          // Message-type button: icon-only on mobile.
          title: isMobile ? '' : S.of(context).contactManager,
          function: onContactManager!,
          textStyle: _buttonText,
          color: AppColors.primary,
          image: AppAssets.chat,
          widthImage: 20.sp,
          heightImage: 20.sp,
          space: 8.w,
          colorBorder: AppColors.transparent,
          svgColor: AppColors.textButton,
          fixedWidth: isMobile ? null : _actionWidth.w,
        ),
      isReassignLoading
          ? GrcButtonLoadingPlaceholder(
              width: isMobile ? 90.w : _actionWidth.w,
              height: 38.sp,
            )
          : customButton(
              title: S.of(context).reassign,
              function: onReassign,
              width: isMobile ? null : _actionWidth.w,
              wrapContent: isMobile,
              color: AppColors.primary,
              textStyle: _buttonText,
            ),
    ];

    final List<Widget> trailing = [
      isEditLoading
          ? GrcButtonLoadingPlaceholder(
              width: isMobile ? 38.sp : _actionWidth.w,
              height: 38.sp,
            )
          : customButtonWithSvg(
              // Icon-only on the phone, as the 375 frame draws it.
              title: isMobile ? '' : S.of(context).Edit,
              function: onEdit,
              textStyle: _buttonText,
              color: AppColors.primary,
              image: _editSvg,
              widthImage: 18.sp,
              heightImage: 18.sp,
              space: 8.w,
              colorBorder: AppColors.transparent,
              svgColor: AppColors.textButton,
              fixedWidth: isMobile ? null : _actionWidth.w,
            ),
      customButtonWithSvg(
        title: isMobile ? '' : S.of(context).remove,
        function: onRemove,
        textStyle:
            StyleText.fontSize14Weight400.copyWith(color: AppColors.white),
        color: AppColors.red,
        image: _removeSvg,
        widthImage: 20.sp,
        heightImage: 20.sp,
        space: 8.w,
        colorBorder: AppColors.transparent,
        svgColor: AppColors.white,
        fixedWidth: isMobile ? null : _actionWidth.w,
      ),
    ];

    return Row(
      children: [
        ...[
          for (var i = 0; i < leading.length; i++) ...[
            if (i > 0) SizedBox(width: isMobile ? 8.w : 15.w),
            leading[i],
          ],
        ],
        const Spacer(),
        ...[
          for (var i = 0; i < trailing.length; i++) ...[
            if (i > 0) SizedBox(width: isMobile ? 8.w : 15.w),
            trailing[i],
          ],
        ],
      ],
    );
  }

  // ── Policies / Controls ─────────────────────────────────────────────

  Widget _chipsSection(
      BuildContext context, String title, List<String> names) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: StyleText.fontSize20Weight500.copyWith(color: AppColors.text),
        ),
        SizedBox(height: 8.h),
        if (isLoadingNames)
          Center(child: const CircleProgressMaster())
        else if (names.isEmpty)
          Text(
            S.of(context).noControlsAssigned,
            style: StyleText.fontSize12Weight400
                .copyWith(color: AppColors.secondaryText),
          )
        else
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: [
              for (final String n in names) GrcAssignmentChip(label: n),
            ],
          ),
      ],
    );
  }
}
