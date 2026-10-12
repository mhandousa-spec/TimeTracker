/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: custom_confirm_dialog.dart
/// Purpose: Declares `_DialogShell`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

/// ******************* FILE INFO *******************
/// File Name: custom_dialogs.dart
/// Description: Reusable dialog widgets:
///   - showConfirmDialog   → Request To Cancellation / any confirm
///   - showSuccessDialog   → Success feedback (Lottie animation)
///   - showCommentDialog   → Justifications / any text-area comment
///   - showUploadDialog    → Adding Attachment (drag & drop / browse)
/// Created by: Amr Mesbah
/// Last Update: 08/3/2026

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';

// ─────────────────────────────────────────────
//  SHARED HELPERS
// ─────────────────────────────────────────────

/// Rounded dialog shell used by every dialog.
class _DialogShell extends StatelessWidget {
  final Widget child;
  final double? width;

  //
  const _DialogShell({required this.child, this.width});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Container(
        width: width ?? 420.w,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light
              ? AppColors.card
              : AppColors.background,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.totalBlack.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(-3, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(16.r),
        child: child,
      ),
    );
  }
}

/// Yellow primary button (matches your customButton style).
Widget _primaryBtn({
  required String label,
  required VoidCallback onTap,
  double? width,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: width,
      height: 36.sp,
      decoration: BoxDecoration(
        color: AppColors.primary, // #FFDE59
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Center(
        child: Text(
          label,
          style: StyleText.fontSize14Weight500.copyWith(color: AppColors.textButton),
        ),
      ),
    ),
  );
}

/// Grey/neutral secondary button.
Widget _secondaryBtn({
  required String label,
  required VoidCallback onTap,
  double? width,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: width,
      height: 36.sp,
      decoration: BoxDecoration(
        color: AppColors.secondaryAction,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Center(
        child: Text(
          label,
          style: StyleText.fontSize14Weight500.copyWith(color: AppColors.onSecondaryAction),
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────
//  1.  CONFIRM DIALOG
// ─────────────────────────────────────────────
///
/// Usage:
/// ```dart
/// showConfirmDialog(
///   context: context,
///   title: 'Request To Cancellation',
///   subtitle: 'Are You Sure You Want to Cancel This Request?',
///   onConfirm: () { /* your action */ },
/// );
/// ```
Future<void> showConfirmDialog({
  required BuildContext context,
  String title = 'Confirm',
  String subtitle = 'Are you sure you want to proceed?',
  String confirmLabel = 'Yes',
  String cancelLabel = 'No',
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
  /// Optional custom Lottie animation path.
  /// Defaults to assets/lottie_assets/main_lottie_assets/lottie_attention.json
  String? lottieAsset,
  /// Whether the Lottie animation should loop. Defaults to true.
  bool repeat = true,
  /// Fallback icon widget if you want to bypass Lottie entirely
  Widget? iconWidget,
}) {
  return showDialog(
    context: context,
    barrierColor: AppColors.totalBlack.withOpacity(0.4),
    builder: (_) => _ConfirmDialog(
      title: title,
      subtitle: subtitle,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      onConfirm: onConfirm,
      onCancel: onCancel,
      lottieAsset: lottieAsset,
      repeat: repeat,
      iconWidget: iconWidget,
    ),
  );
}

class _ConfirmDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final String? lottieAsset;
  final bool repeat;
  final Widget? iconWidget;

  const _ConfirmDialog({
    required this.title,
    required this.subtitle,
    required this.confirmLabel,
    required this.cancelLabel,
    this.onConfirm,
    this.onCancel,
    this.lottieAsset,
    this.repeat = true,
    this.iconWidget,
  });

  @override
  Widget build(BuildContext context) {
    return _DialogShell(
      width: 411.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 8.h),
          // Icon
          _buildIcon(),

          SizedBox(height: 16.h),
          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: StyleText.fontSize16Weight600.copyWith(color: AppColors.text),
          ),
          SizedBox(height: 8.h),
          // Subtitle
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.text.withOpacity(0.6),
            ),
          ),

          SizedBox(height: 16.h),

          // Buttons row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _secondaryBtn(
                width: context.isPhone ? 135.sp : 135.sp,
                label: cancelLabel,
                onTap: () {
                  HapticController.low(); // cancel in dialog
                  Navigator.of(context).pop();
                  onCancel?.call();
                },
              ),

              _primaryBtn(
                width: context.isPhone ? 135.sp : 135.sp,
                label: confirmLabel,
                onTap: () {
                  HapticController.high(); // confirm "are you sure"
                  Navigator.of(context).pop();
                  onConfirm?.call();
                },
              ),
            ],
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    if (iconWidget != null) return iconWidget!;
    return Lottie.asset(
      lottieAsset ?? 'assets/lottie_assets/main_lottie_assets/lottie_confirmation.json',
      width: 90.r,
      height: 90.r,
      repeat: repeat,
    );
  }
}

// ─────────────────────────────────────────────
//  2.  SUCCESS DIALOG
// ─────────────────────────────────────────────
///
/// Usage:
/// ```dart
/// showSuccessDialog(
///   context: context,
///   title: 'Request Cancelation',
///   subtitle: 'You Successfully Requested Cancelation For This Request',
/// );
/// ```
Future<void> showSuccessDialog({
  required BuildContext context,
  String title = 'Success',
  String subtitle = 'Operation completed successfully.',
  String closeLabel = 'Close',
  VoidCallback? onClose,
  /// Optional custom Lottie animation path.
  /// Defaults to assets/lottie_assets/main_lottie_assets/lottie_approved.json
  String? lottieAsset,
  /// Whether the Lottie animation should loop. Defaults to false (plays once).
  bool repeat = false,
}) {
  return showDialog(
    context: context,
    barrierColor: AppColors.totalBlack.withOpacity(0.4),
    builder: (_) => _SuccessDialog(
      title: title,
      subtitle: subtitle,
      closeLabel: closeLabel,
      onClose: onClose,
      lottieAsset: lottieAsset,
      repeat: repeat,
    ),
  );
}

class _SuccessDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final String closeLabel;
  final VoidCallback? onClose;
  final String? lottieAsset;
  final bool repeat;

  const _SuccessDialog({
    required this.title,
    required this.subtitle,
    required this.closeLabel,
    this.onClose,
    this.lottieAsset,
    this.repeat = false,
  });

  @override
  Widget build(BuildContext context) {
    return _DialogShell(
      width: 410.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 16.h),
          // Lottie success animation
          _buildIcon(),
          SizedBox(height: 16.h),
          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: StyleText.fontSize16Weight600.copyWith(color: AppColors.text),
          ),
          SizedBox(height: 8.h),
          // Subtitle
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.text.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Lottie.asset(
      lottieAsset ?? 'assets/lottie_assets/main_lottie_assets/lottie_approved.json',
      width: 90.r,
      height: 90.r,
      repeat: repeat,
    );
  }
}

// ─────────────────────────────────────────────
//  2b. ERROR / WARNING DIALOG
// ─────────────────────────────────────────────
///
/// The failure-side counterpart to [showSuccessDialog].
///
/// WHY THIS EXISTS
/// ---------------
/// Failures and validation guards used to be surfaced with
/// `ScaffoldMessenger.showSnackBar`. A snackbar is the wrong instrument for
/// them: it auto-dismisses after a few seconds, it can be covered by the
/// keyboard or a bottom sheet, and on tablet — the primary form factor here —
/// it lands in a corner far from the control the user just pressed. A message
/// the user has to act on (fix the title, pick a member, complete the dates)
/// has to persist until it is acknowledged.
///
/// [showSuccessDialog] dismisses on a barrier tap because nothing is required
/// of the user. This one renders an explicit Close button for the same reason
/// in reverse: acknowledging the failure should be a deliberate act.
///
/// Usage:
/// ```dart
/// showErrorDialog(
///   context: context,
///   title: 'Something Went Wrong',
///   subtitle: state.errorMessage!,
///   closeLabel: 'Close',
/// );
/// ```
Future<void> showErrorDialog({
  required BuildContext context,
  String title = 'Something Went Wrong',
  String subtitle = 'The action could not be completed.',
  String closeLabel = 'Close',
  VoidCallback? onClose,

  /// Defaults to assets/lottie_assets/main_lottie_assets/error.json.
  String? lottieAsset,
  bool repeat = false,
}) {
  return showDialog(
    context: context,
    barrierColor: AppColors.totalBlack.withOpacity(0.4),
    builder: (_) => _MessageDialog(
      title: title,
      subtitle: subtitle,
      closeLabel: closeLabel,
      onClose: onClose,
      lottieAsset:
          lottieAsset ?? 'assets/lottie_assets/main_lottie_assets/error.json',
      repeat: repeat,
    ),
  );
}

/// Same shell as [showErrorDialog] with the attention animation, for the
/// "you cannot continue yet" guards that are not errors — nothing broke, the
/// form is simply incomplete.
Future<void> showWarningDialog({
  required BuildContext context,
  String title = 'Missing Information',
  String subtitle = 'Complete the highlighted fields to continue.',
  String closeLabel = 'Close',
  VoidCallback? onClose,
  String? lottieAsset,
  bool repeat = false,
}) {
  return showErrorDialog(
    context: context,
    title: title,
    subtitle: subtitle,
    closeLabel: closeLabel,
    onClose: onClose,
    lottieAsset: lottieAsset ??
        'assets/lottie_assets/main_lottie_assets/lottie_attention.json',
    repeat: repeat,
  );
}

class _MessageDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final String closeLabel;
  final VoidCallback? onClose;
  final String lottieAsset;
  final bool repeat;

  const _MessageDialog({
    required this.title,
    required this.subtitle,
    required this.closeLabel,
    required this.lottieAsset,
    this.onClose,
    this.repeat = false,
  });

  @override
  Widget build(BuildContext context) {
    return _DialogShell(
      width: 410.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 16.h),
          Lottie.asset(
            lottieAsset,
            width: 90.r,
            height: 90.r,
            repeat: repeat,
          ),
          SizedBox(height: 16.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style:
                StyleText.fontSize16Weight600.copyWith(color: AppColors.text),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.text.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 16.h),
          _primaryBtn(
            label: closeLabel,
            width: 140.w,
            onTap: () {
              HapticController.high();
              Navigator.of(context).pop();
              onClose?.call();
            },
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  3.  COMMENT / JUSTIFICATION DIALOG
// ─────────────────────────────────────────────
///
/// Usage:
/// ```dart
/// showCommentDialog(
///   context: context,
///   title: 'Reason Of Cancellation',
///   fieldLabel: 'Justifications',
///   onSubmit: (text) { /* use text */ },
/// );
/// ```
Future<void> showCommentDialog({
  required BuildContext context,
  String title = 'Comment',
  String fieldLabel = 'Justifications',
  String hint = 'Text here',
  String submitLabel = 'Submit',
  int maxLength = 500,
  TextDirection textDirection = TextDirection.ltr,
  /// Pass SVG asset for the title icon, or leave null for default X icon
  String? titleIconAsset,
  void Function(String comment)? onSubmit,
}) {
  return showDialog(
    context: context,
    barrierColor: AppColors.totalBlack.withOpacity(0.4),
    builder: (_) => _CommentDialog(
      title: title,
      fieldLabel: fieldLabel,
      hint: hint,
      submitLabel: submitLabel,
      maxLength: maxLength,
      textDirection: textDirection,
      titleIconAsset: titleIconAsset,
      onSubmit: onSubmit,
    ),
  );
}

class _CommentDialog extends StatefulWidget {
  final String title;
  final String fieldLabel;
  final String hint;
  final String submitLabel;
  final int maxLength;
  final TextDirection textDirection;
  final String? titleIconAsset;
  final void Function(String)? onSubmit;

  const _CommentDialog({
    required this.title,
    required this.fieldLabel,
    required this.hint,
    required this.submitLabel,
    required this.maxLength,
    required this.textDirection,
    this.titleIconAsset,
    this.onSubmit,
  });

  @override
  State<_CommentDialog> createState() => _CommentDialogState();
}

class _CommentDialogState extends State<_CommentDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    setState(() => _submitted = true);
    if (_controller.text.trim().isEmpty) return;
    HapticController.medium(); // submit
    Navigator.of(context).pop();
    widget.onSubmit?.call(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return _DialogShell(
      width: 539.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──
          Row(
            children: [
              _TitleIcon(assetPath: widget.titleIconAsset),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  widget.title,
                  style: StyleText.fontSize14Weight600
                      .copyWith(color: AppColors.text),
                ),
              ),
              // GestureDetector(
              //   onTap: () => Navigator.of(context).pop(),
              //   child: Icon(Icons.close, size: 18.r, color: AppColors.text),
              // ),
            ],
          ),
          SizedBox(height: 16.h),

          // ── Text field ──
          CustomTextField(
            label: widget.fieldLabel,
            hint: widget.hint,
            controller: _controller,
            maxLines: 5,
            fillColor:AppColors.card,
            maxLength: widget.maxLength,
            required: _submitted,
            textDirection: widget.textDirection,
            onChanged: (_) => setState(() {}),
          ),

          SizedBox(height: 16.h),

          // ── Submit button ──
          Align(
            alignment: Alignment.centerRight,
            child: _primaryBtn(
              label: widget.submitLabel,
              onTap: _handleSubmit,
              width: 120.w,
            ),
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  4.  UPLOAD / ATTACHMENT DIALOG
// ─────────────────────────────────────────────
///
/// Usage:
/// ```dart
/// showUploadDialog(
///   context: context,
///   onSubmit: (file, title) { /* handle upload */ },
/// );
/// ```
Future<void> showUploadDialog({
  required BuildContext context,
  String dialogTitle = 'Adding Attachment',
  String titleFieldLabel = 'Title Name',
  String titleFieldHint = 'Text here',
  String submitLabel = 'Submit',
  String discardLabel = 'Discard',
  TextDirection textDirection = TextDirection.ltr,
  String? headerIconAsset,
  List<String>? allowedExtensions,
  /// Custom success title/subtitle, or null to skip success dialog
  String successTitle = 'Attachment Added',
  String successSubtitle = 'Your attachment has been added successfully.',
  bool showSuccessOnSubmit = true,
  /// Optional custom Lottie animation path for the success dialog shown after submit.
  String? successLottieAsset,
  void Function(PlatformFile file, String titleName)? onSubmit,
}) {
  return showDialog(
    context: context,
    barrierColor: AppColors.totalBlack.withOpacity(0.4),
    builder: (_) => _UploadDialog(
      parentContext: context, // ← pass the parent context
      dialogTitle: dialogTitle,
      titleFieldLabel: titleFieldLabel,
      titleFieldHint: titleFieldHint,
      submitLabel: submitLabel,
      discardLabel: discardLabel,
      textDirection: textDirection,
      headerIconAsset: headerIconAsset,
      allowedExtensions: allowedExtensions,
      showSuccessOnSubmit: showSuccessOnSubmit,
      successTitle: successTitle,
      successSubtitle: successSubtitle,
      successLottieAsset: successLottieAsset,
      onSubmit: onSubmit,
    ),
  );
}

class _UploadDialog extends StatefulWidget {
  final BuildContext parentContext; // ← added
  final String dialogTitle;
  final String titleFieldLabel;
  final String titleFieldHint;
  final String submitLabel;
  final String discardLabel;
  final TextDirection textDirection;
  final String? headerIconAsset;
  final List<String>? allowedExtensions;
  final bool showSuccessOnSubmit;
  final String successTitle;
  final String successSubtitle;
  final String? successLottieAsset;
  final void Function(PlatformFile, String)? onSubmit;

  const _UploadDialog({
    required this.parentContext,
    required this.dialogTitle,
    required this.titleFieldLabel,
    required this.titleFieldHint,
    required this.submitLabel,
    required this.discardLabel,
    required this.textDirection,
    required this.showSuccessOnSubmit,
    required this.successTitle,
    required this.successSubtitle,
    this.headerIconAsset,
    this.allowedExtensions,
    this.successLottieAsset,
    this.onSubmit,
  });

  @override
  State<_UploadDialog> createState() => _UploadDialogState();
}

class _UploadDialogState extends State<_UploadDialog> {
  PlatformFile? _pickedFile;
  final TextEditingController _titleCtrl = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: widget.allowedExtensions != null
          ? FileType.custom
          : FileType.any,
      allowedExtensions: widget.allowedExtensions,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _pickedFile = result.files.first);
    }
  }

  void _handleSubmit() {
    setState(() => _submitted = true);
    if (_pickedFile == null) return;
    if (_titleCtrl.text.trim().isEmpty) return;

    HapticController.medium(); // submit
    // Close upload dialog
    Navigator.of(context).pop();

    // Fire callback
    widget.onSubmit?.call(_pickedFile!, _titleCtrl.text.trim());

    // Show success dialog using the parent context (still mounted)
    if (widget.showSuccessOnSubmit) {
      showSuccessDialog(
        context: widget.parentContext,
        title: widget.successTitle,
        subtitle: widget.successSubtitle,
        lottieAsset: widget.successLottieAsset,
        onClose: () {},
      );
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return _DialogShell(
      width: 430.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Row(
            children: [
              _TitleIcon(
                assetPath: "assets/icons_assets/main_icons_assets/cloud_upload.svg",
                fallback: Icon(Icons.attach_file,
                    size: 18.r, color: AppColors.primary),
              ),
              SizedBox(width: 8.w),
              Text(
                widget.dialogTitle,
                style: StyleText.fontSize14Weight600
                    .copyWith(color: AppColors.text),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // ── STEP 1: Drop zone (shown when no file picked) ──
          if (_pickedFile == null) ...[
            _buildDropZone(lightMode),
            SizedBox(height: 16.h),
            // Only a Discard button in step 1
            Align(
              alignment: Alignment.centerRight,
              child: _secondaryBtn(
                label: widget.discardLabel,
                onTap: () {
                  HapticController.medium(); // discard
                  Navigator.of(context).pop();
                },
                width: 120.w,
              ),
            ),
          ],

          // ── STEP 2: File picked → show file card + title field ──
          if (_pickedFile != null) ...[
            _buildFileCard(),
            SizedBox(height: 16.h),

            // Title field (only after file is selected)
            Text(
              widget.titleFieldLabel,
              style: StyleText.fontSize14Weight400
                  .copyWith(color: AppColors.text),
            ),
            SizedBox(height: 6.h),
            CustomTextField(
              hint: widget.titleFieldHint,
              controller: _titleCtrl,
              fillColor: AppColors.card,
              required: _submitted,
              textDirection: widget.textDirection,
              onChanged: (_) => setState(() {}),
            ),


            // Action buttons
            Row(
              children: [
                Expanded(
                  child: _secondaryBtn(
                    label: widget.discardLabel,
                    onTap: () {
                      HapticController.medium(); // discard
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _primaryBtn(
                    label: widget.submitLabel,
                    onTap: _handleSubmit,
                  ),
                ),
              ],
            ),
          ],

          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildDropZone(bool lightMode) {
    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        width: double.infinity,
        height: 150.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomSvgImage(
              assetPath: 'assets/icons_assets/form_builder_assets/upload_arrow_rounded.svg',
              width: 60.w,
              height: 60.h,
              fit: BoxFit.fill,
            ),
            SizedBox(height: 8.h),
            Text(
              'Drag & Drop files here',
              style: StyleText.fontSize14Weight400
                  .copyWith(color: AppColors.text),
            ),
            SizedBox(height: 4.h),
            Text(
              'Or',
              style: StyleText.fontSize12Weight400
                  .copyWith(color: AppColors.text),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileCard() {
    final file = _pickedFile!;
    final extension = file.extension ?? '';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.secondaryText.withOpacity(.5), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomSvgImage(
            assetPath: _getFileIcon(extension),
            width: 28.r,
            height: 28.r,
            fit: BoxFit.scaleDown,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: StyleText.fontSize12Weight400
                      .copyWith(color: AppColors.text),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                Text(
                  _formatBytes(file.size),
                  style: StyleText.fontSize10Weight400
                      .copyWith(color: AppColors.secondaryText),
                ),
              ],
            ),
          ),
          GestureDetector(
              onTap: () => setState(() => _pickedFile = null),
              child:  CustomSvgImage(assetPath: "assets/icons_assets/main_icons_assets/document_remove_badge_red.svg",width: 15.w,height: 15.h,fit: BoxFit.scaleDown,)

          ),
        ],
      ),
    );
  }

  String _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'assets/icons_assets/main_icons_assets/pdf_file_red.svg';
      case 'ppt':
      case 'pptx':
        return 'assets/icons_assets/main_icons_assets/powerpoint_logo.svg';
      case 'doc':
      case 'docx':
        return 'assets/icons_assets/main_icons_assets/doc_file_blue.svg';
      case 'png':
        return 'assets/icons_assets/main_icons_assets/image_photo_rounded.svg';
      default:
        return 'assets/icons_assets/main_icons_assets/image_photo_rounded.svg';
    }
  }
}

// ─────────────────────────────────────────────
//  SHARED: Title row icon widget
// ─────────────────────────────────────────────
class _TitleIcon extends StatelessWidget {
  final String? assetPath;
  final Widget? fallback;

  const _TitleIcon({this.assetPath, this.fallback});

  @override
  Widget build(BuildContext context) {
    if (assetPath != null) {
      return Container(
          width: 30.r,
          height: 30.r,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary
          ),
          child: Center(child: CustomSvgImage(
   assetPath: assetPath!,
   width: 20.r,
   height: 20.r,
   fit: BoxFit.scaleDown,
 )));
    }
    return fallback ??
        Container(
          width: 20.r,
          height: 20.r,
          decoration: BoxDecoration(
            color: AppColors.red,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.close, size: 12.r, color: AppColors.white),
        );
  }
}




//showConfirmDialog(
//   context: context,
//   title: 'Request To Cancellation',
//   subtitle: 'Are You Sure You Want to Cancel This Request?',
//   // lottieAsset: 'assets/lottie_assets/main_lottie_assets/lottie_attention.json', // default
//   onConfirm: () { /* your action */ },
// );


// showSuccessDialog(
// context: context,
// title: 'Request Cancelation',
// subtitle: 'You Successfully Requested Cancelation For This Request',
// // lottieAsset: 'assets/lottie_assets/main_lottie_assets/lottie_approved.json', // default
// onClose: () { /* optional */ },
// );


//showCommentDialog(
//   context: context,
//   title: 'Reason Of Cancellation',
//   fieldLabel: 'Justifications',
//   titleIconAsset: 'assets/icons_assets/main_icons_assets/cancel_minus_circle.svg',
//   textDirection: TextDirection.ltr, // or rtl for Arabic
//   onSubmit: (text) { /* use comment text */ },
// );


//showUploadDialog(
//   context: context,
//   allowedExtensions: ['pdf', 'png', 'jpg'],
//   headerIconAsset: 'assets/icons_assets/form_builder_assets/attachment_paperclip.svg',
//   onSubmit: (file, titleName) { /* handle upload */ },
// );