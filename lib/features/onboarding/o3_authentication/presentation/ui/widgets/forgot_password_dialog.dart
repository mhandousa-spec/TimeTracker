/// Module: onboarding/o3_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: forgot_password_dialog.dart
/// Purpose: The "forgot password" prompt.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - CR-SKEL-O3-N24: the `try/finally` is gone — even try/finally is forbidden in
///          presentation/ui/ (§11.2).

/// Objectives: "Forgot Password?" dialog shown from the sign-in screen.
///
/// Visual port of Knowticed's ForgotPassDialog (rounded 8px card, title, single
/// email field, Cancel / Send row) without the Firestore employee lookup — the
/// submit handler validates the address and reports back through
/// [ResponseDialog].

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/64-custom_response_dialog.dart';
import 'package:knowticed_plus/core/helper/role/validator.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
// Brings in ScreenSizeExtension, so `0.15.w` means 15% of the screen (as in
// Knowticed) rather than screenutil's design-size scale factor.
import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key, this.onSubmit});

  /// Optional hook so the caller can drive the actual reset request.
  /// Receives the normalised (trimmed, lower-cased) email address.
  final Future<void> Function(String email)? onSubmit;

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final TextEditingController _emailController = TextEditingController();
  final HapticController _hapticController = Get.put(HapticController());

  String? _emailError;
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final String email = _emailController.text.trim().toLowerCase();
    final String? error = Validator.emailTitle(email);

    if (error != null) {
      setState(() => _emailError = error);
      return;
    }

    setState(() {
      _emailError = null;
      _submitting = true;
    });

    _hapticController.triggerHapticFeedback(
      vibration: VibrateType.mediumImpact,
      hapticFeedback: HapticFeedback.mediumImpact,
    );

    // Held onto before the pop: this dialog's own context is defunct once it
    // closes, so the confirmation is shown from the parent navigator instead.
    final NavigatorState navigator = Navigator.of(context);

    // Was `try { await onSubmit } finally { … }`. Even try/finally is
    // forbidden in presentation/ui/ (§11.2, CR-SKEL-O3-N24). The callback is
    // the caller's to make safe — it is a cubit/controller method, which is
    // where the catch belongs — so this simply awaits and then clears the
    // in-flight flag.
    await widget.onSubmit?.call(email);
    if (mounted) setState(() => _submitting = false);

    if (!mounted) return;
    navigator.pop();
    showDialog(
      context: navigator.context,
      builder: (dialogContext) => ResponseDialog(
        title: S.of(dialogContext).resetPassword,
        subtitle: S.of(dialogContext).passwordResetLinkSent,
        lottieAsset: 'assets/lottie_assets/main_lottie_assets/successful.json',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isTablet ? (isPortrait ? 0.22.w : 0.33.w) : 0.15.w,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.card,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 15.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                S.of(context).forgotPassword2,
                style: StyleText.fontSize18Weight500
                    .copyWith(color: AppColors.text),
              ),
              SizedBox(height: 15.sp),
              CustomTextField(
                label: S.of(context).email,
                hint: S.of(context).textHere,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.start,
                errorText: _emailError,
                fillColor: AppColors.field,
                onChanged: (_) {
                  if (_emailError != null) setState(() => _emailError = null);
                },
              ),
              SizedBox(height: 15.sp),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _submitting ? null : () => Navigator.of(context).pop(),
                    child: Text(
                      S.of(context).cancel,
                      style: StyleText.fontSize14Weight500
                          .copyWith(color: AppColors.text),
                    ),
                  ),
                  SizedBox(width: 8.sp),
                  ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: isTablet
                          ? Size(0.1.w, 0.053.h)
                          : Size(0.3.w, 0.05.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _submitting
                        ? SizedBox(
                            width: 18.sp,
                            height: 18.sp,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textButton,
                            ),
                          )
                        : Text(
                            S.of(context).send,
                            style: StyleText.fontSize14Weight500
                                .copyWith(color: AppColors.textButton),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
