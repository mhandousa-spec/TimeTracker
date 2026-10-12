/// Module: GRC Module Management
/// Description: Provides the bottom action buttons (Discard / Publish / Save /
///              Restore) displayed at the foot of the GRC Module details page.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-06-29
/// Dependencies: AppColors, customButton, showConfirmDialog, GrcPageMode
/// Revision History: 2026-06-29 - Initial creation
///                    2026-06-30 - Added onAction callback (Mohamed Magdy Abdelkhalek)
library;

/// ************************* FILE INFO *************************** ///
/// File Name: grc_bottom_buttons.dart
/// Purpose: Contains GrcBottomButtons, the bottom row of action buttons for
///          create, edit, and restore modes of the GRC Module details page.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 29/6/2026

import 'package:knowticed_plus/core/custom/11-custom_confirm_diaolog.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/grc/module/presentation/ui/pages/grc_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// class name: [GrcBottomButtons]
///
/// purpose: renders the bottom action row for the GRC Module details page.
///          Hidden in view mode; shows Discard + Publish/Save/Restore otherwise.
///          Tapping the primary action opens a confirmation dialog before
///          invoking [onAction].
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 29/6/2026
class GrcBottomButtons extends StatelessWidget {
  final GrcPageMode mode;
  final VoidCallback onDiscard;
  final VoidCallback onAction;

  /// Called before the confirm dialog. Return false to abort.
  final bool Function()? validate;

  /// Whether the primary action (Publish / Save / Restore) can be used.
  ///
  /// ADDED 13/9/2026. The button was always live and always primary-coloured,
  /// so an incomplete form was only refused AFTER the tap, by [validate]. It
  /// now reads as unavailable until the form is complete: [AppColors.darkGrey]
  /// with secondary text, and the tap does nothing.
  ///
  /// [validate] is still called on tap and still guards the real submit — this
  /// is the visual half of the same rule, not a replacement for it.
  final bool isActionEnabled;

  const GrcBottomButtons({
    super.key,
    required this.mode,
    required this.onDiscard,
    required this.onAction,
    this.validate,
    this.isActionEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (mode == GrcPageMode.view) return const SizedBox.shrink();

    final bool isCompact = screenSizeOf(context) == ScreenSize.mobile;

    // Figma: 150x38 at 768 and 1024, 135x38 at 375. Height is the app-wide
    // ButtonSizing.height (38), which already matches every frame.
    final double buttonWidth = isCompact ? 135.w : 150.w;

    // The 375 frames label the secondary action "Discard" even in edit mode,
    // where the wider frames spell out "Discard Changes" — the long label
    // does not fit 135.
    final String discardLabel = (mode == GrcPageMode.create || isCompact)
        ? S.of(context).discard
        : S.of(context).discardChange;

    return Row(
      mainAxisAlignment: mode == GrcPageMode.restore
          ? MainAxisAlignment.end
          : MainAxisAlignment.spaceBetween,
      children: [
        if (mode != GrcPageMode.restore)
          customButton(
            title: discardLabel,
            function: onDiscard,
            height: 38.h,
            width: buttonWidth,
            color: AppColors.darkGrey,
            textColor: AppColors.text,
            borderColor: AppColors.border,
          ),
        customButton(
          title: mode == GrcPageMode.create
              ? S.of(context).publish
              : mode == GrcPageMode.restore
                  ? S.of(context).restore
                  : S.of(context).Save,
          // `customButton` takes a non-nullable VoidCallback, so "disabled"
          // is an empty callback rather than null. The colour is what tells
          // the user; the no-op is what enforces it.
          function: isActionEnabled ? () => _onActionTap(context) : () {},
          height: 38.h,
          width: buttonWidth,
          color: isActionEnabled ? AppColors.primary : AppColors.darkGrey,
          textColor:
              isActionEnabled ? AppColors.textButton : AppColors.secondaryText,
        ),
      ],
    );
  }

  void _onActionTap(BuildContext context) {
    if (validate != null && !validate!()) return;
    final isCreate = mode == GrcPageMode.create;
    final isRestore = mode == GrcPageMode.restore;
    showConfirmDialog(
      context: context,
      title: isCreate
          ? S.of(context).creatingModules
          : isRestore
              ? S.of(context).restoringModule
              : S.of(context).editingModules,
      cancelLabel: S.of(context).no,
      confirmLabel: S.of(context).yes,
      // One animation per mode, matching the title and subtitle above and
      // below it. _ConfirmDialog builds the icon as the FIRST child of its
      // column, so this needs no layout work here.
      //
      // All three used to be `iconWidget:` (a flat doc.svg / des.svg), and
      // _buildIcon() returns early on that — `if (iconWidget != null) return
      // iconWidget!` — so the dialog's own Lottie never ran at all.
      lottieAsset: isCreate
          ? AppAssets.lottieConfirmation
          : isRestore
              ? AppAssets.restore
              : AppAssets.lottieEditDocument,
      subtitle: isCreate
          ? S.of(context).areYouSureYouWantToCreateThisModule
          : isRestore
              ? S.of(context).areYouSureYouWantToRestoreThisModule
              : S.of(context).areYouSureYouWantToEditThisModule,
      onConfirm: onAction,
    );
  }
}
