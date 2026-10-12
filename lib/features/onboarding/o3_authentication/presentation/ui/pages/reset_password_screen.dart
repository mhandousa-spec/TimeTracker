/// Module: onboarding/o3_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: reset_password_screen.dart
/// Purpose: The reset-password screen.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - Added the standard header (Docs).
///
/// REMAINING (CR-SKEL-O3-N06/N23): this is still a stub on a security-relevant
/// path — it navigates back to sign-in and never resets anything.

/// Date Created :12/May/2023
/// Developer Name : Bassem Mohamed
/// App Version : Version 2
/// Objectives: first-login ResetPassword screen — reached from LoginController
/// when the account is still inactive: the user signed in with the company's
/// temporary password and must now choose a real one.
///
/// The chrome is a port of Knowticed's reset_password_layout_vertical /
/// _horizontal pair, so phones, tablets and desktop render the same as
/// Knowticed:
///   • portrait  → hero image 0.3.h + logo, "Reset Your Password" title, form.
///   • landscape → hero image side panel, title + form centred on the right.
///
/// Submitting writes the new password to Firestore and activates the account.

// `hide State` is required: dartz exports its own State class, which collides
// with Flutter's State and makes _ResetPasswordState fail to resolve.
import 'dart:ui';

import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/64-custom_response_dialog.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/data/repository/demo_login_repository.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/presentation/ui/pages/sign_in_screen.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/presentation/ui/widgets/check_row.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/main.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({
    super.key,
    required this.savedPassword,
    required this.employee,
    required this.isDemoActivation,
    this.requireOldPassword = true,
  });

  final String savedPassword;
  final NewEmployeeModelHistory? employee;
  final bool isDemoActivation;

  /// Whether the "Enter Old Password" step is shown and validated.
  ///
  /// False for the unlock flow: an account that was locked and then unlocked
  /// signs in with the default password held in User Access — the same value
  /// this screen would ask for again — so re-typing the old password is
  /// redundant there and is skipped.
  final bool requireOldPassword;

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController _oldPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  final DemoLoginRepository _repository = DemoLoginRepository();
  final HapticController _hapticController = Get.put(HapticController());

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // The checklist below reacts to every keystroke, so all three controllers
    // drive a rebuild.
    for (final c in [
      _oldPassController,
      _newPassController,
      _confirmPassController,
    ]) {
      c.addListener(_onChanged);
    }
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (final c in [
      _oldPassController,
      _newPassController,
      _confirmPassController,
    ]) {
      c.removeListener(_onChanged);
      c.dispose();
    }
    super.dispose();
  }

  // ───────────────────────────────────────────────────────────────────────
  // Password rules
  // ───────────────────────────────────────────────────────────────────────

  bool get _oldPasswordMatches =>
      _oldPassController.text == widget.savedPassword;

  bool get _hasMinimumLength => _newPassController.text.length >= 8;

  bool get _hasUppercase => _newPassController.text.contains(RegExp(r'[A-Z]'));

  bool get _hasNumber => _newPassController.text.contains(RegExp(r'[0-9]'));

  bool get _hasSymbol =>
      _newPassController.text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  bool get _hasNoSpaces => !_newPassController.text.contains(' ');

  bool get _passwordsMatch {
    final String next = _newPassController.text;
    final String confirm = _confirmPassController.text;
    if (next.isEmpty && confirm.isEmpty) return false;
    return next == confirm;
  }

  bool get _isAllChecked =>
      (!widget.requireOldPassword || _oldPasswordMatches) &&
      _hasNoSpaces &&
      _hasMinimumLength &&
      _hasUppercase &&
      _hasNumber &&
      _hasSymbol &&
      _passwordsMatch;

  // ───────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisible =
        MediaQuery.of(context).viewInsets.bottom != 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: OrientationBuilder(
        builder: (context, orientation) => orientation == Orientation.portrait
            ? _verticalLayout(isKeyboardVisible)
            : _horizontalLayout(),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // Form content — shared by both layouts
  // ───────────────────────────────────────────────────────────────────────

  Widget _content({required bool isPortrait}) {
    final bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    return Column(
      children: [
        if (!isPortrait) SizedBox(height: 0.03.h),
        if (widget.requireOldPassword) ...[
          _passwordField(
            controller: _oldPassController,
            hint: S.of(context).enterOldPassword,
          ),
          SizedBox(height: 0.018.h),
        ],
        _passwordField(
          controller: _newPassController,
          hint: S.of(context).enterNewPassword,
        ),
        SizedBox(height: 0.018.h),
        _passwordField(
          controller: _confirmPassController,
          hint: S.of(context).confirmNewPassword,
        ),
        SizedBox(height: 0.02.h),
        if (widget.requireOldPassword)
          CheckRow(
            isChecked: _oldPasswordMatches,
            text: S.of(context).oldPasswordMatchesSavedPassword,
          ),
        CheckRow(
          isChecked: _hasMinimumLength,
          text: S.of(context).passwordMustBeAtLeast8Characters,
        ),
        CheckRow(
          isChecked: _hasUppercase,
          text: S.of(context).passwordMustContainUppercase,
        ),
        CheckRow(
          isChecked: _hasNumber,
          text: S.of(context).passwordMustContainNumber,
        ),
        CheckRow(
          isChecked: _hasSymbol,
          text: S.of(context).passwordMustContainSymbol,
        ),
        CheckRow(
          isChecked: _passwordsMatch,
          text: S.of(context).newPasswordMatchesConfirmField,
        ),
        SizedBox(height: 0.021.h),
        Row(
          children: [
            _actionButton(

              label: S.of(context).discard,
              color: AppColors.darkGrey,
              textColor: AppColors.text,
              onTap: _isSaving ? null : _onDiscard,
            ),
            Spacer(),
            _actionButton(
              label: S.of(context).Save,
              color: _isAllChecked
                  ? AppColors.primary
                  : AppColors.darkGrey,
              textColor:
                  _isAllChecked ? AppColors.textButton : AppColors.text,
              onTap: (_isAllChecked && !_isSaving) ? _submit : null,
              isBusy: _isSaving,
            ),
          ],
        ),
        SizedBox(height: isTablet ? 0.01.h : 0.02.h),
      ],
    );
  }

  /// Core CustomTextField tuned to Knowticed's CustomField appearance.
  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
  }) {
    return CustomTextField(
      controller: controller,
      hint: hint,
      obscureText: true,
      enabled: !_isSaving,
      fillColor: AppColors.card,
      borderRadius: BorderRadius.circular(8.0),
      contentPadding: EdgeInsets.symmetric(vertical: 0.01.h),
      valueStyle: StyleText.fontSize14Weight400
          .copyWith(color: AppColors.secondaryText),
      hintStyle: StyleText.fontSize14Weight500
          .copyWith(color: AppColors.secondaryText),
      prefixIcon: CustomSvgImage(
        color: AppColors.text,
        assetPath:
            'assets/icons_assets/watermark/password.svg',
        height: 0.025.h,
      ),
      onTap: () => _hapticController.triggerHapticFeedback(
        vibration: VibrateType.lightImpact,
        hapticFeedback: HapticFeedback.lightImpact,
      ),
    );
  }

  /// Discard / Save pill — same geometry as Knowticed's CustomButton
  /// (38.sp tall, 6px radius, centred FittedBox label).
  Widget _actionButton({
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback? onTap,
    bool isBusy = false,
  }) {
    return InkWell(
      onTap: onTap,
      splashColor: AppColors.transparent,
      child: Container(
        alignment: Alignment.center,
        height: 38.sp,
        width: 200.sp,
        padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 8.sp),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: FittedBox(
          child: isBusy
              ? SizedBox(
                  width: 18.sp,
                  height: 18.sp,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: textColor,
                  ),
                )
              : Text(
                  label,
                  maxLines: 1,
                  style: StyleText.fontSize18Weight500
                      .copyWith(color: textColor),
                ),
        ),
      ),
    );
  }

  Widget _logo({required double width, required double height}) => SizedBox(
        width: width,
        height: height,
        child: storage.read('logo') == null
            ? SvgPicture.asset(
                'assets/icons_assets/main_icons_assets/knowticed_logo.svg',
                fit: BoxFit.fill,
              )
            : SvgPicture.network(storage.read('logo'), fit: BoxFit.fill),
      );

  Widget _title({required bool isPortrait}) => Text(
        S.of(context).resetYourPassword,
        style: isPortrait
            ? StyleText.fontSize24Weight600.copyWith(
                fontSize: FontConstants.fontSize032.h,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              )
            : StyleText.fontSize36Weight500
                .copyWith(color: AppColors.text),
      );

  // ───────────────────────────────────────────────────────────────────────
  // Portrait — phone and tablet
  // ───────────────────────────────────────────────────────────────────────

  Widget _verticalLayout(bool isKeyboardVisible) {
    final bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Stack(
            children: [
              // The hero collapses on phones once the keyboard is up so the
              // fields stay reachable; tablets keep it.
              Visibility(
                visible: isTablet ? true : !isKeyboardVisible,
                child: Image.asset(
                  kSignInHeroImage,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  height: 0.3.h,
                ),
              ),
              if (!isTablet && isKeyboardVisible) SizedBox(height: 0.05.h),
              // PositionedDirectional: the logo sits 0.030.w from the
              // leading edge — left in English, right in Arabic — instead of
              // being pushed across with a hardcoded locale offset.
              PositionedDirectional(
                top: isTablet ? 0.04.h : 0.070.h,
                start: 0.030.w,
                child: _logo(
                  width: isTablet ? .06.h : .08.h,
                  height: isTablet
                      ? (storage.read('logo') == null ? .045.h : .06.h)
                      : (storage.read('logo') == null ? .06.h : 0.08.h),
                ),
              ),
            ],
          ),
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 0.06.w, vertical: 0.02.h),
            child: _title(isPortrait: true),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.06.w),
            child: _content(isPortrait: true),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // Landscape — tablet and desktop
  // ───────────────────────────────────────────────────────────────────────

  Widget _horizontalLayout() {
    return Stack(
      children: [
        Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width / 2.6,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(kSignInHeroImage),
                  fit: BoxFit.fill,
                ),
              ),
              child: Stack(
                children: [
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
                    child: Container(color: AppColors.transparent),
                  ),
                  Container(color: AppColors.white.withOpacity(0.19)),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: AppColors.background,
                height: double.infinity,
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0.07.h),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _title(isPortrait: false),
                          _content(isPortrait: false),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        PositionedDirectional(
          top: 0.070.h,
          start: 0.030.w,
          child: _logo(
            width: .095.h,
            height: storage.read('logo') == null ? .07.h : .095.h,
          ),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // Actions
  // ───────────────────────────────────────────────────────────────────────

  void _onDiscard() {
    _hapticController.triggerHapticFeedback(
      vibration: VibrateType.mediumImpact,
      hapticFeedback: HapticFeedback.mediumImpact,
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
      (route) => false,
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.card,
        content: Text(
          message,
          style: StyleText.fontSize14Weight400
              .copyWith(color: AppColors.text),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    _hapticController.triggerHapticFeedback(
      vibration: VibrateType.mediumImpact,
      hapticFeedback: HapticFeedback.mediumImpact,
    );

    final NewEmployeeModelHistory? employee = widget.employee;
    if (employee == null) {
      _showMessage(S.of(context).error);
      return;
    }

    setState(() => _isSaving = true);
    showLoadingIndicator();

    final Either<Failure, void> result =
        await _repository.updateEmployeePassword(
      employee: employee,
      newPassword: _newPassController.text,
    );

    hideLoadingIndicator();
    if (!mounted) return;
    setState(() => _isSaving = false);

    // Only leave the screen when the write actually succeeded, otherwise the
    // user is bounced to sign-in believing the password changed when it did not.
    result.fold(
      (failure) => _showMessage(failure.errMessage),
      (_) {
        showDialog(
          context: context,
          builder: (_) => ResponseDialog(
            title: S.of(context).successful,
            subtitle: S.of(context).passwordResetSuccessMessage,
            lottieAsset:
                'assets/lottie_assets/main_lottie_assets/successful.json',
          ),
        );
        Future.delayed(const Duration(seconds: 5), () {
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const SignInScreen()),
            (route) => false,
          );
        });
      },
    );
  }
}
