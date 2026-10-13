/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: custom_dialog_manager.dart
/// Purpose: Declares `CustomDialogManager`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

/// ******************* FILE INFO *******************
/// File Name: custom_dialog.dart
/// Description: this is custom success or comment or select dialog for reuse
/// Created by: Amr Mesbah
/// Last Update: 30/8/2025
/// Relocated to core/custom (57); imports repointed to core/custom equivalents.
import 'package:get/get.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/44-custom_validated_textfield.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class CustomDialogManager {
  /// Shows a blocking loading indicator while [task] runs, then closes it.
  ///
  /// ADDED 30/9/2026 (Role QA p.9, p.19, p.20, p.40): after "Yes" / "Continue"
  /// the confirm dialog closed and nothing happened on screen until the
  /// request came back, so the user could not tell anything was going on.
  static Future<T> runWithLoading<T>(
    BuildContext context,
    Future<T> Function() task,
  ) async {
    // An OverlayEntry, not a dialog route: callers' onConfirm bodies pop their
    // own routes (loaders, pages) and a route on top would swallow that pop.
    final OverlayState? overlay = context.mounted
        ? Overlay.maybeOf(context, rootOverlay: true)
        : null;
    OverlayEntry? entry;
    if (overlay != null) {
      entry = OverlayEntry(
        builder: (_) => Stack(
          children: [
            ModalBarrier(
              dismissible: false,
              color: AppColors.totalBlack.withOpacity(0.5),
            ),
            Center(
              child: SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.lightPrimary),
                  backgroundColor: AppColors.white.withOpacity(0.6),
                  strokeWidth: 2.0,
                ),
              ),
            ),
          ],
        ),
      );
      overlay.insert(entry);
    }
    try {
      return await task();
    } finally {
      entry?.remove();
    }
  }

  static Future<void> showDialogFlow({
    required BuildContext context,
    required String confirmLottie,
    required String confirmTitle,
    required String confirmSubtitle,
    required String confirmYesText,
    required String confirmNoText,
    // B2 FIX: must return whether the confirm action actually succeeded so the
    // success dialog is only shown on a real success (was VoidCallback, called
    // fire-and-forget with success shown unconditionally).
    required Future<bool> Function() onConfirm,
    VoidCallback? onNoPressed,
    bool commentRequired = false,
    required String successLottie,
    required String successTitle,
    required String successSubtitle,
    bool comment = false,
    TextEditingController? commentController,
    String commentSubmitText = '',
    String commentDiscardText = '',
    String customReasonTitle = '',
    /// SVG for the reason dialog's header icon. Null keeps the title-based
    /// default; see [_showCommentDialog].
    String? customReasonIconAsset,
    // B2 FIX: returns whether the submit action succeeded (was Future<void>).
    Future<bool> Function()? onCommentSubmit,
    VoidCallback? onCommentDiscard,
    VoidCallback? onSuccessDismissed,
    VoidCallback? onSuccessComplete, // ✅ ADD THIS PARAMETER
    /// Skip the success step entirely. The confirm dialog closes and
    /// [onSuccessComplete] runs straight away — no second dialog, no
    /// [onSuccessDismissed]. For flows where the outcome is self-evident
    /// (logout lands the user on the sign-in screen), an extra "it worked"
    /// dialog is one more tap between the user and where they asked to go.
    /// Defaults to true so every existing caller is unchanged.
    bool showSuccessDialog = true,
    /// Width of the CONFIRM dialog, unscaled (`.sp` is applied here). ADDED
    /// 21/9/2026 — defaults to the 500 every existing caller had; the User
    /// Access confirmations pass Figma's 411.
    double confirmWidth = 500,
    /// ADDED 1/10/2026 (Services mobile QA p.13): the success step's title
    /// (20) and message (18) read bigger than the confirm step they follow
    /// (20 / 14). When true the success step uses 18 / 14 instead. Defaults
    /// to false so every existing caller is unchanged.
    bool compactSuccess = false,
    /// ADDED 7/10/2026 (animation + haptic standard). Opt-in; defaults keep
    /// every existing caller unchanged.
    ///  * [destructive]: delete / remove / log-out confirmations — the confirm
    ///    content shakes ONCE (`ShakeOnce`), "Yes" fires a HIGH haptic and "No"
    ///    a LOW one.
    ///  * [scaleIn]: every other confirmation — the dialog scales in
    ///    (`ScaleInContent`), "No" fires LOW, "Yes" keeps MEDIUM.
    bool destructive = false,
    bool scaleIn = false,
  }) async {
    final outerContext = context;
    final bool standardHaptics = destructive || scaleIn;

    // ✅ CREATE A COMPLETER TO TRACK WHEN EVERYTHING IS DONE
    final completer = Completer<void>();

    await showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (dlgCtx) {
        final isMobile = ContextExtension(dlgCtx).isPhone;
        final Widget dialog = Dialog(
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? AppColors.white
              : AppColors.chatBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: SizedBox(
              width: confirmWidth.sp,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    confirmLottie,
                    width: 70.sp,
                    height: 70.sp,
                    fit: BoxFit.scaleDown,
                    repeat: true,
                    animate: true,
                  ),
                  SizedBox(height: 15.sp),
                  Text(
                    confirmTitle,
                    style: StyleText.fontSize20Weight500.copyWith(
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppColors.blackButton
                          : AppColors.white,
                    ),
                  ),
                  SizedBox(height: 15.sp),
                  Text(
                    confirmSubtitle,
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize14Weight500.copyWith(
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppColors.secondaryText
                          : AppColors.grey,
                    ),
                  ),
                  SizedBox(height: 15.sp),
                  // Bug report (Settings mobile p.16/p.18): on a phone-width
                  // window the two fixed-width buttons were wider than the
                  // dialog, so "Confirm" / "Yes" ran past its right edge.
                  // Each button keeps its 135 on a wide window but shrinks to
                  // share the dialog's width on a narrow one.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: 135.sp), child: customButton(
                        fullWidth: true,
                        title: confirmNoText,
                        haptic: standardHaptics
                            ? HapticController.low
                            : HapticController.medium,
                        function: () {
                          Navigator.of(context, rootNavigator: true).pop();
                          onNoPressed?.call();
                          // ✅ COMPLETE THE FLOW WHEN USER SAYS NO
                          if (!completer.isCompleted) {
                            completer.complete();
                          }
                        },
                        textStyle: StyleText.fontSize15Weight400.copyWith(
                          color: AppColors.onSecondaryAction,
                        ),
                        width: isMobile ? 115.sp : 135.sp,
                        height: 38.sp,
                        radius: 4.r,
                        color: AppColors.secondaryAction,
                      ))),
                      SizedBox(height: 0, width: 15.sp),
                      Flexible(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: 135.sp), child: customButton(
                        fullWidth: true,
                        title: confirmYesText,
                        haptic: destructive
                            ? HapticController.high
                            : HapticController.medium,
                        function: () async {

                          // 1) Close the confirm dialog FIRST
                          final nav = Navigator.of(dlgCtx, rootNavigator: true);
                          if (nav.canPop()) {
                            nav.pop();
                          }

                          // 2) Brief delay
                          await Future.delayed(const Duration(milliseconds: 120));

                          // 3) If comment required, show comment dialog
                          bool proceed = true;
                          if (comment && commentController != null) {
                            proceed = await _showCommentDialog(
                              context: outerContext,
                              controller: commentController,
                              submitText: commentSubmitText,
                              discardText: commentDiscardText,
                              reasonTitle: customReasonTitle,
                              reasonIconAsset: customReasonIconAsset,
                              onSubmit: onCommentSubmit,
                              onDiscard: onCommentDiscard,
                              isRequired: commentRequired,
                            );

                            if (!proceed) {
                              // ✅ COMPLETE THE FLOW WHEN COMMENT IS DISCARDED
                              if (!completer.isCompleted) {
                                completer.complete();
                              }
                              return;
                            }
                          }

                          // 4) Run the confirm logic. B2 FIX: only proceed to
                          // the success dialog if it actually succeeded.
                          bool confirmOk;
                          try {
                            confirmOk = await runWithLoading(outerContext, onConfirm);
                          } catch (e, st) {
                            confirmOk = false;
                          }

                          if (!confirmOk) {
                            // The action failed — do NOT show a false success.
                            if (!completer.isCompleted) completer.complete();
                            return;
                          }

                          // 5) Show success dialog (unless the caller opted out)
                          if (showSuccessDialog) {
                            await _showSuccessDialog(
                              context: outerContext,
                              lottiePath: successLottie,
                              title: successTitle,
                              subtitle: successSubtitle,
                              compact: compactSuccess,
                            );

                            onSuccessDismissed?.call();
                          }

                          // ✅ COMPLETE THE FLOW AFTER SUCCESS DIALOG
                          if (!completer.isCompleted) {
                            completer.complete();
                          }

                          // ✅ CALL onSuccessComplete AFTER EVERYTHING IS DONE
                          onSuccessComplete?.call();
                        },
                        textStyle: StyleText.fontSize15Weight400.copyWith(
                          color: AppColors.textButton,
                        ),
                        width: isMobile ? 115.sp : 135.sp,
                        height: 38.sp,
                        radius: 4.r,
                        color: AppColors.primary,
                      )))
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
        if (destructive) return ShakeOnce(child: dialog);
        if (scaleIn) return ScaleInContent(child: dialog);
        return dialog;
      },
    );

    // ✅ WAIT FOR THE ENTIRE FLOW TO COMPLETE
    await completer.future;

  }

  /// Standalone success/acknowledgement dialog, for screens that just need to
  /// confirm something worked without the confirm -> comment -> success flow.
  /// Auto-closes after a short delay, same as the flow's final step.
  /// Persistent message dialog — same look as [showSuccess] but it stays until
  /// the user dismisses it.
  ///
  /// Use this for errors and warnings. [showSuccess] auto-closes after ~1.5s,
  /// which is fine for a confirmation but loses the message on a failure the
  /// user needs to read (e.g. a CSV upload listing the missing columns).
  static Future<void> showMessage({
    required BuildContext context,
    required String lottiePath,
    required String title,
    String subtitle = '',
    // ADDED 21/9/2026 — when set, the dialog has no OK button and closes
    // itself after this long (it can still be dismissed by tapping outside).
    Duration? closeAfter,
  }) {
    BuildContext? dialogContext;
    if (closeAfter != null) {
      Future<void>.delayed(closeAfter, () {
        final BuildContext? ctx = dialogContext;
        // `mounted` first: if the user already tapped the barrier, the
        // element is gone and Navigator.of would throw.
        if (ctx != null && ctx.mounted &&
            (ModalRoute.of(ctx)?.isCurrent ?? false)) {
          Navigator.of(ctx, rootNavigator: true).maybePop();
        }
      });
    }
    return showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (ctx) {
       dialogContext = ctx;
       return Dialog(
        backgroundColor: Theme.of(ctx).brightness == Brightness.light
            ? AppColors.white
            : AppColors.chatBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: SizedBox(
            width: 500.sp,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  lottiePath,
                  width: 70.w,
                  height: 70.h,
                  fit: BoxFit.scaleDown,
                ),
                SizedBox(height: 20.h),
                // Role QA p.4 / p.38: long titles wrapped to two big lines on a phone.
                // Kept on one line, scaled down only when it doesn't fit.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize20Weight500.copyWith(
                      color: Theme.of(ctx).brightness == Brightness.light
                          ? AppColors.blackButton
                          : AppColors.white,
                    ),
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  SizedBox(height: 18.h),
                  // Flexible + scroll: this dialog carries error text of
                  // unbounded length (a failed role save lists every restricted
                  // permission — one such message ran 1029px past the bottom of
                  // a min-height Column, which has nowhere to put the excess).
                  // The Lottie, title and OK button keep their intrinsic size;
                  // only the message scrolls, so the button stays reachable.
                  Flexible(
                    child: SingleChildScrollView(
                      child: Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: StyleText.fontSize18Weight500.copyWith(
                          color: Theme.of(ctx).brightness == Brightness.light
                              ? AppColors.secondaryText
                              : AppColors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
                if (closeAfter == null) ...[
                SizedBox(height: 20.h),
                customButton(
                  title: S.of(ctx).ok2,
                  function: () =>
                      Navigator.of(ctx, rootNavigator: true).maybePop(),
                  textStyle: StyleText.fontSize15Weight400
                      .copyWith(color: AppColors.textButton),
                  width: 135.sp,
                  height: 38.sp,
                  radius: 4.r,
                  color: AppColors.primary,
                ),
                ],
              ],
            ),
          ),
        ),
      );
      },
    );
  }

  /// Persistent dialog hosting a single text field and one confirm action.
  ///
  /// Added for the form-builder "download as PDF/Excel" flow, which needs a
  /// filename field plus a Download button. [showMessage] and [showSuccess] are
  /// message-only, and [showDialogFlow]'s comment step is bound to a
  /// confirm→success sequence, so neither fits an input-then-act dialog.
  ///
  /// Built from the core widgets (CustomTextField, customButton) so it matches
  /// the rest of core/custom. [onConfirm] runs *after* the dialog is dismissed,
  /// so callers are free to push further dialogs from it.
  static Future<void> showInput({
    required BuildContext context,
    required TextEditingController controller,
    required String title,
    required String confirmText,
    required VoidCallback onConfirm,
    String? fieldLabel,
    Widget? leadingIcon,

    /// Dialog width, or null for the 500 default. ADDED.
    ///
    /// INTERPRETED IN `.sp` — pass the raw design number (`360`), not `360.sp`,
    /// the same contract `CustomTextField.height` and `CustomDropdown.height`
    /// carry. A pre-scaled value would be scaled twice.
    ///
    /// 500 is a lot of box for one short field: this dialog is a title, one
    /// input and a button, so at 500 the input stretches most of the way
    /// across the screen for a value that is usually a few words. Defaults to
    /// 500, so every existing call site is unchanged.
    double? width,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (ctx) => Dialog(
        backgroundColor: Theme.of(ctx).brightness == Brightness.light
            ? AppColors.white
            : AppColors.chatBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        child: Padding(
          // CHANGED: was 24.r. showInput's box is a title, one field and a
          // button, so 24 all round was most of what made the dialog feel
          // oversized even after the width came down. The other dialogs in
          // this file keep 24.r — they carry a 70.sp Lottie and two lines of
          // centred copy, which need the air.
          padding: EdgeInsets.all(12.sp),
          child: SizedBox(
            width: (width ?? 500).sp,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (leadingIcon != null) ...[
                      leadingIcon,
                      SizedBox(width: 8.w),
                    ],
                    Expanded(
                      child: Text(
                        title,
                        style: StyleText.fontSize18Weight500.copyWith(
                          color: Theme.of(ctx).brightness == Brightness.light
                              ? AppColors.blackButton
                              : AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                CustomTextField(
                  controller: controller,
                  label: fieldLabel,
                ),
                SizedBox(height: 20.h),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: customButton(
                    title: confirmText,
                    function: () {
                      Navigator.of(ctx, rootNavigator: true).maybePop();
                      onConfirm();
                    },
                    textStyle: StyleText.fontSize15Weight400
                        .copyWith(color: AppColors.textButton),
                    width: 135.sp,
                    height: 38.sp,
                    radius: 4.r,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Auto-closing success dialog (no button).
  ///
  /// [closeAfter] ADDED 21/9/2026 — how long it stays up; defaults to the
  /// 1.5 s every existing caller had.
  static Future<void> showSuccess({
    required BuildContext context,
    required String lottiePath,
    required String title,
    String subtitle = '',
    Duration closeAfter = const Duration(milliseconds: 1500),
  }) =>
      _showSuccessDialog(
        context: context,
        lottiePath: lottiePath,
        title: title,
        subtitle: subtitle,
        closeAfter: closeAfter,
      );

  /// Upload dialog — shown BEFORE the file picker.
  ///
  /// ADDED 29/8/2026. The Upload toolbar action used to jump straight into the
  /// OS file picker; this shows the drag-and-drop card first (per the design),
  /// and only runs [onBrowse] — the caller's real upload flow — when the user
  /// taps "Browse Files". [onDiscard] (optional) runs on Discard / dismiss.
  ///
  /// The drop area is visual: real OS drag-and-drop needs a desktop-drop
  /// package and platform channel wiring, which this card does not add — the
  /// working path is the Browse Files button.
  static Future<void> showUpload({
    required BuildContext context,
    required Future<void> Function() onBrowse,
    VoidCallback? onDiscard,
  }) async {
    final bool isArabic =
        Localizations.localeOf(context).languageCode == 'ar';
    final bool isMobile = ContextExtension(context).isPhone;
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    await showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (dlgCtx) {
        return Dialog(
          backgroundColor: isLight ? AppColors.white : AppColors.chatBackground,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          child: Padding(
            padding: EdgeInsets.all(12.sp),
            child: SizedBox(
              width: 560.sp,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: badge + title
                  Row(
                    children: [
                      Container(
                        width: 30.sp,
                        height: 30.sp,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: CustomSvgImage(
                            assetPath:
                                'assets/icons_assets/watermark/upload.svg',
                            width: 20.w,
                            height: 20.h,
                            fit: BoxFit.contain,
                            color: AppColors.textButton,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        isArabic ? 'رفع' : 'Upload',
                        style: StyleText.fontSize20Weight500.copyWith(
                          color: isLight ? AppColors.blackButton : AppColors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  // Drop zone (visual)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    decoration: BoxDecoration(
                      color: isLight ? AppColors.field : AppColors.chatBackground,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomSvgImage(assetPath: "assets/icons_assets/main_icons_assets/cloud_upload.svg",width: 100.sp,height: 100.sp,fit: BoxFit.fill,),
                        SizedBox(height: 16.h),
                        Text(
                          isArabic
                              ? 'اسحب وأفلت الملفات هنا'
                              : 'Drag & Drop files here',
                          textAlign: TextAlign.center,
                          style: StyleText.fontSize16Weight500.copyWith(
                            color: AppColors.text,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          isArabic ? 'أو' : 'Or',
                          style: StyleText.fontSize14Weight500.copyWith(
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  // Actions
                  Row(
                    children: [
                      customButton(
                        title: isArabic ? 'إلغاء' : 'Discard',
                        function: () {
                          Navigator.of(dlgCtx, rootNavigator: true).maybePop();
                          onDiscard?.call();
                        },
                        textStyle: StyleText.fontSize15Weight400
                            .copyWith(color: AppColors.onSecondaryAction),
                        width: isMobile ? 120.sp : 150.sp,
                        height: 44.sp,
                        radius: 8.r,
                        color: AppColors.secondaryAction,
                      ),
                      const Spacer(),
                      customButton(
                        title: isArabic ? 'تصفح الملفات' : 'Browse Files',
                        function: () async {
                          // Close the card first, then run the real upload flow.
                          Navigator.of(dlgCtx, rootNavigator: true).maybePop();
                          await Future.delayed(
                              const Duration(milliseconds: 120));
                          await onBrowse();
                        },
                        textStyle: StyleText.fontSize15Weight400
                            .copyWith(color: AppColors.textButton),
                        width: isMobile ? 120.sp : 150.sp,
                        height: 44.sp,
                        radius: 8.r,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Generic content dialog — the manager's chrome around ANY child widget.
  ///
  /// ADDED 2/9/2026. [showMessage], [showInput], [showUpload] and [showExport]
  /// each hard-code their own body, so a caller with an existing widget to show
  /// (the chat attachment menu, for one) had no way in and fell back to
  /// `Get.defaultDialog`, which is styled nowhere and ignores this file's
  /// radius/background rules. This is that way in: same [Dialog] shell as
  /// [showUpload], no body of its own.
  ///
  /// Pass [backgroundColor] `Colors.transparent` together with
  /// [padding] `EdgeInsets.zero` when the [child] already paints its own card,
  /// otherwise you get two stacked backgrounds.
  ///
  /// Returns whatever the child pops with, so it can also be used for pickers:
  /// `Navigator.of(ctx, rootNavigator: true).pop(value)`.
  static Future<T?> showContent<T>({
    required BuildContext context,
    required Widget child,
    double? width,
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
    bool barrierDismissible = true,
    // ADDED 13/10/2026 (Time Tracker owner V2): the content scrolls when the
    // phone keyboard leaves too little room (it overflowed). Opt-in — a child
    // that sizes itself with Expanded / Flexible must keep the default.
    bool scrollable = false,
  }) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      useRootNavigator: true,
      builder: (dlgCtx) {
        return Dialog(
          backgroundColor: backgroundColor ??
              (isLight ? AppColors.white : AppColors.chatBackground),
          // `Colors.transparent` above would still show the default elevation
          // shadow, so drop it whenever the caller supplies its own surface.
          elevation: backgroundColor == Colors.transparent ? 0 : null,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(8.r),
          ),
          child: Padding(
            padding: padding ?? EdgeInsets.all(12.sp),
            child: scrollable
                ? SingleChildScrollView(
                    child: width == null ? child : SizedBox(width: width, child: child),
                  )
                : (width == null ? child : SizedBox(width: width, child: child)),
          ),
        );
      },
    );
  }

  /// Export dialog — a file-name field then Discard / Download.
  ///
  /// ADDED 29/8/2026. Replaces the old filter+preview export dialog for the
  /// simple "name it and download" flow: [onDownload] receives the raw file
  /// name the user typed (the caller adds the extension and runs the export).
  static Future<void> showExport({
    required BuildContext context,
    required Future<void> Function(String fileName) onDownload,
    String? initialFileName,
  }) async {
    final bool isArabic =
        Localizations.localeOf(context).languageCode == 'ar';
    final bool isMobile = ContextExtension(context).isPhone;
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final TextEditingController fileNameController =
        TextEditingController(text: initialFileName ?? '');

    await showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (dlgCtx) {
        return Dialog(
          backgroundColor: isLight ? AppColors.white : AppColors.chatBackground,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          child: Padding(
            padding: EdgeInsets.all(12.r),
            child: SizedBox(
              // EDIT 29/8/2026: 300 was a phone width used on every form factor.
              // On desktop it left the File Name field a narrow slot in the
              // middle of a wide window while Discard and Download — 150 each —
              // nearly filled the row beneath it. 500 is what every other dialog
              // in this file uses (confirm, success, error, restore); the phone
              // keeps 300, where 500 would overflow the screen.
              width: isMobile ? 300.sp : 500.sp,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: circular badge + title
                  Row(
                    children: [
                      Container(
                        width: 30.sp,
                        height: 30.sp,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: CustomSvgImage(
                            assetPath:
                                'assets/icons_assets/watermark/export.svg',
                            width: 15.w,
                            height: 15.h,
                            fit: BoxFit.contain,
                            color: AppColors.textButton,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        isArabic ? 'تصدير' : 'Export',
                        style: StyleText.fontSize20Weight500.copyWith(
                          color: isLight ? AppColors.blackButton : AppColors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  // File name field (label above + placeholder inside)
                  CustomTextField(
                    controller: fileNameController,
                    label: isArabic ? 'اسم الملف' : 'File Name',
                    hint: isArabic ? 'اكتب هنا' : 'Text here',
                    fillColor: AppColors.background,
                  ),
                  SizedBox(height: 12.h),
                  // Actions
                  Row(
                    children: [
                      customButton(
                        title: isArabic ? 'إلغاء' : 'Discard',
                        function: () =>
                            Navigator.of(dlgCtx, rootNavigator: true).maybePop(),
                        textStyle: StyleText.fontSize15Weight400
                            .copyWith(color: AppColors.onSecondaryAction),
                        width: isMobile ? 100.sp : 120.sp,
                        height: 38.sp,
                        radius: 8.r,
                        color: AppColors.secondaryAction,
                      ),
                      const Spacer(),
                      customButton(
                        title: isArabic ? 'تحميل' : 'Download',
                        function: () async {
                          final String name = fileNameController.text.trim();
                          Navigator.of(dlgCtx, rootNavigator: true).maybePop();
                          await Future.delayed(
                              const Duration(milliseconds: 120));
                          await onDownload(name);
                        },
                        textStyle: StyleText.fontSize15Weight400
                            .copyWith(color: AppColors.textButton),
                        width: isMobile ? 100.sp : 120.sp,                        height: 38.sp,
                        radius: 8.r,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<bool> _showCommentDialog({
    required BuildContext context,
    required TextEditingController controller,
    required String submitText,
    required String discardText,
    required String reasonTitle,
    /// SVG for the reason dialog's header icon. Null keeps the historical
    /// title-based guess — see the note at the icon itself.
    String? reasonIconAsset,
    // B2 FIX: returns whether the submit action succeeded.
    Future<bool> Function()? onSubmit,
    VoidCallback? onDiscard,
    bool isRequired = false,
  }) async {
    final isArabic = Localizations
        .localeOf(context)
        .languageCode == 'ar';
    // 1) add this helper near the top of the file (outside the widget/class)
    String _toWesternDigits(String s) {
      const east = ['٠','١','٢','٣','٤','٥','٦','٧','٨','٩'];
      const west = ['0','1','2','3','4','5','6','7','8','9'];
      for (var i = 0; i < east.length; i++) {
        s = s.replaceAll(east[i], west[i]);
      }
      return s;
    }

    String _toEasternDigits(String s) {
      const east = ['٠','١','٢','٣','٤','٥','٦','٧','٨','٩'];
      const west = ['0','1','2','3','4','5','6','7','8','9'];
      for (var i = 0; i < west.length; i++) {
        s = s.replaceAll(west[i], east[i]);
      }
      return s;
    }



    final isMobile = ContextExtension(context).isPhone;
    String? errorText;
    // FIX 25/9/2026 (services bug report p8 — duplicated "requires your
    // approval" notifications): Submit had no in-flight guard, so a second
    // tap while `onSubmit` was still awaiting ran the whole action again —
    // approving twice and notifying the next approver twice.
    bool isSubmitting = false;

    final result = await showDialog<bool>(

      context: context,
      barrierDismissible: !isRequired,
      useRootNavigator: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? AppColors.white
              : AppColors.chatBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          child: Padding(
            padding: EdgeInsets.all(15.sp),
            child: SizedBox(
              width: 500.sp,
              child: StatefulBuilder(
                builder: (context, setState) {
                  void validate() {
                    if (isRequired && controller.text.trim().isEmpty) {
                      setState(() => errorText = S.of(context).pleaseEnterCancelReason);
                    } else {
                      setState(() => errorText = null);
                    }
                  }
                  const int kMaxChars = 500;
                  final int len = controller.text.characters.length;
                  final String counterText = isArabic
                      ? '${_toEasternDigits(kMaxChars.toString())}/${_toEasternDigits(len.toString())}' // AR: ٥٠٠/٠
                      : '${_toWesternDigits(len.toString())}/${_toWesternDigits(kMaxChars.toString())}'; // EN: 0/500

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          // ADDED 22/9/2026 — [reasonIconAsset]. The icon used
                          // to be a two-way guess off the TITLE: "Reason Of
                          // Approval" got a tick, and anything else got the red
                          // rejection cross. That was fine while the only two
                          // callers were approve and reject, but a third reason
                          // (Knowledge Hub's "Reason Of Editing") then showed a
                          // rejection icon on an edit. A caller that knows its
                          // own icon now passes it; the title guess stays as the
                          // default so every existing caller is untouched.
                          if (reasonIconAsset != null)
                            SizedBox(
                              child: CustomSvgImage(assetPath: reasonIconAsset, width: 30.w, height: 30.h, fit: BoxFit.fill),
                            )
                          else if (reasonTitle == S.of(context).reasonOfApproval)
                            Container(
                              width: 30.sp, height: 30.sp,
                              decoration:  BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                              child: SizedBox(
                                child: Icon(Icons.check,color: AppColors.textButton,)
                              )
                            )
                          else
                            SizedBox(
                              child: CustomSvgImage(assetPath: "assets/icons_assets/form_builder_assets/close_circle_red.svg",width: 30.w,height: 30.h,fit: BoxFit.fill,),
                            ),
                          SizedBox(width: 5.sp),
                          Text(
                            reasonTitle,
                            style: StyleText.fontSize16Weight500.copyWith(
                              color: AppColors.text
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15.sp),

                      CustomValidatedTextFieldMaster(
                        label: S.of(context).Justifications,
                        hint: S.of(context).Texthere,

                        controller: controller,
                        height: 72.sp,
                        maxLines: 3,
                        showCharCount: true,
                        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                        onChanged: (value) {
                          setState(() {});
                        },
                        textStyle: StyleText.fontSize14Weight500.copyWith(
                          color: Theme.of(context).brightness == Brightness.light
                              ? AppColors.blackButton
                              : AppColors.white,
                        ),
                      ),


                      SizedBox(height: 15.sp),
                      Row(
                        children: [
                          customButton(
                            title: discardText,
                            function: () {
                              Navigator.of(context, rootNavigator: true).pop(false);
                              onDiscard?.call();
                            },
                            textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.onSecondaryAction),
                            width: isMobile ? 120.sp : 150.sp,
                            height: 38.sp,
                            radius: 8.r,
                            color: AppColors.secondaryAction
                          ),
                          const Spacer(),
                          // ✅ DISABLE BUTTON when field is empty and required
                          Builder(
                            builder: (btnContext) {
                              final textValue = controller.text;
                              final trimmedValue = textValue.trim();
                              final isEmpty = trimmedValue.isEmpty;
                              final shouldDisable = isRequired && isEmpty;


                              return Opacity(
                                opacity: shouldDisable ? 0.5 : 1.0,
                                child: IgnorePointer(
                                  ignoring: shouldDisable,
                                  child: customButton(
                                    title: submitText,
                                    function: () async {
                                      if (isSubmitting) return;
                                      isSubmitting = true;
                                      // B2 FIX: pop with the real success result so
                                      // the caller aborts (no success dialog) when
                                      // the submit action failed.
                                      bool submitOk;
                                      try {
                                        submitOk = onSubmit == null
                                            ? true
                                            : await runWithLoading(btnContext, onSubmit);
                                      } catch (e, st) {
                                        submitOk = false;
                                      }
                                      if (Navigator.of(btnContext, rootNavigator: true).canPop()) {
                                        Navigator.of(btnContext, rootNavigator: true).pop(submitOk);
                                      }
                                      isSubmitting = false;
                                    },
                                    textStyle: StyleText.fontSize16Weight500.copyWith(
                                      color: AppColors.textButton,
                                    ),
                                    width: isMobile ? 120.sp : 150.sp,
                                    height: 38.sp,
                                    radius: 8.r,
                                    color: AppColors.primary,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );

    return result ?? false;
  }

  // REPLACE the whole method with this:
  static Future<void> _showSuccessDialog({
    required BuildContext context,
    required String lottiePath,
    required String title,
    required String subtitle,
    Duration closeAfter = const Duration(milliseconds: 1500),
    bool compact = false,
  }) async {

    BuildContext? dialogCtx; // capture the dialog's own context

    // IMPORTANT: barrierDismissible=false so users can't dismiss before auto-close
    await showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (ctx) {
        dialogCtx = ctx; // <-- capture
        return Dialog(
          backgroundColor: Theme.of(ctx).brightness == Brightness.light
              ? AppColors.white
              : AppColors.chatBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: SizedBox(
              width: 500.sp,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    lottiePath,
                    width: 70.w,
                    height: 70.h,
                    fit: BoxFit.scaleDown,
                  ),
                  SizedBox(height: 20.h),
                  // Role QA p.4 / p.38: long titles wrapped to two big lines on a phone.
                  // Kept on one line, scaled down only when it doesn't fit.
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: (compact
                              ? StyleText.fontSize18Weight500
                              : StyleText.fontSize20Weight500)
                          .copyWith(
                        color: Theme.of(ctx).brightness == Brightness.light
                            ? AppColors.blackButton
                            : AppColors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  // Same reason as showMessage(): the subtitle can be long
                  // enough to overflow a min-height Column, so it scrolls.
                  Flexible(
                    child: SingleChildScrollView(
                      child: Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: (compact ? StyleText.fontSize14Weight500 : StyleText.fontSize18Weight500).copyWith(
                          color: Theme.of(ctx).brightness == Brightness.light
                              ? AppColors.secondaryText
                              : AppColors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).timeout(const Duration(milliseconds: 1), onTimeout: () {});

    // Schedule the auto-close tied to the captured dialog context
    await Future.delayed(closeAfter);

    // FIXED 25/8/2026: this threw "Looking up a deactivated widget's ancestor
    // is unsafe" whenever the success dialog was already gone by the time the
    // 1500ms above elapsed — the user tapped the barrier (this dialog is
    // `barrierDismissible: true`), or the route beneath it was popped.
    //
    // `canPop()` could not prevent it: the ancestor lookup happens INSIDE
    // `Navigator.of`, so it throws before there is a NavigatorState to ask.
    // `Element.mounted` is the check that has to come first — and when it is
    // false there is nothing to do anyway, because the dialog this would have
    // closed is already closed.
    //
    // FIXED 1/10/2026 (Services mobile QA p.18, black screen): `mounted` is
    // still true while a barrier-dismissed dialog plays its exit animation,
    // and `canPop()` only says the navigator has SOME route to pop — so a tap
    // just before the timer fired made this pop the page underneath instead.
    // Pop only when this dialog's own route is still the top one.
    if (dialogCtx != null && dialogCtx!.mounted) {
      final ModalRoute<dynamic>? route = ModalRoute.of(dialogCtx!);
      if (route != null && route.isCurrent) {
        Navigator.of(dialogCtx!, rootNavigator: true).pop();
      }
    }
  }

}
