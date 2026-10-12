/// Module: onboarding/o3_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: sign_in_screen.dart
/// Purpose: The sign-in screen — email/password, biometrics and the language toggle.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - CR-SKEL-O3-N20/N21/N22: the `try/catch` moved to `AppVersionReader`; the two
///          hardcoded English hints and the AR/EN toggle are localized; the locale
///          comes from the tree; the two raw `Colors.*` route through AppColors.
/// Updated: 9/10/2026 - DEBUG-ONLY "🧪 Test employee" button under Sign In
///          (compile-time `kDebugTestEmployeeSwitchBuild`, absent in release).

/// Date Created :12/November/2023
/// Developer Name : Bassem Mohamed
/// App Version : Version 2
/// Objectives: the sign-in page for every form factor.
///
/// Layout matches Knowticed's start_sign_in.dart one-for-one:
///   • portrait  (phone AND tablet) → hero image 0.3.h, headings, form,
///     centred copyright / version block.
///   • landscape (tablet + desktop) → split panel: hero image on the left,
///     headings + form centred on the right, language toggle top-right.
///
/// There is deliberately no separate phone layout — Knowticed drives both
/// phones and tablets from the same portrait branch, so a single
/// [_portraitLayout] is used here too.
///
/// Fields use the shared core CustomTextField (2-custom_textfield.dart), tuned
/// with Knowticed's field styling (8px radius, tinted prefix icon, 0.01.h
/// content padding) so the two apps render identically.

import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/constants/app_constants.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/data/utils/app_version_reader.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/data/utils/login_access_probe.dart';

import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/76-date_time_in_arabic.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/custom/64-custom_response_dialog.dart';
import 'package:knowticed_plus/core/helper/main_helper/functions.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/presentation/controller/biometrics_controller.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/presentation/controller/login_controller.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/presentation/ui/widgets/forgot_password_dialog.dart';
// ADDED 9/10/2026 — DEBUG-ONLY "Switch to test employee" entry point.
import 'package:knowticed_plus/features/onboarding/o3_authentication/data/utils/debug_test_employee_switch.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/presentation/ui/widgets/debug_test_employee_widgets.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/main.dart';

/// Hero artwork shared by the portrait header and the landscape side panel —
/// the same file Knowticed uses.
const String kSignInHeroImage = 'assets/png_assets/loginPhoto.jpeg';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool canBiometrics = false;
  String appVersion = '';
  String buildNumber = '';

  late final LoginController loginController = Get.put(LoginController());
  final HapticController hapticController = Get.put(HapticController());

  @override
  void initState() {
    super.initState();
    _checkCanBiometrics();
    _getAppVersion();
  }

  Future<bool> _checkCanBiometrics() async {
    canBiometrics = await checkBiometrics();
    if (mounted) setState(() {});
    return canBiometrics;
  }

  /// The `try/catch` this held moved to `AppVersionReader` — try is forbidden
  /// in presentation/ui/ (§11.2, CR-SKEL-O3-N20).
  Future<void> _getAppVersion() async {
    final AppVersionInfo info = await AppVersionReader.read();
    if (!mounted) return;
    setState(() {
      appVersion = info.version;
      buildNumber = info.buildNumber;
    });
  }

  /// Reads the locale from the tree rather than the GetX registry (§13).
  bool get _isArabic =>
      Localizations.localeOf(context).languageCode ==
      AppConstants.arabicLanguageCode;

  @override
  Widget build(BuildContext context) {
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    // Knowticed branches on orientation only: phones and tablets held upright
    // get the identical stacked layout, everything else the split panel.
    return Scaffold(
      // Explicit rather than inherited from `scaffoldBackgroundColor`:
      // AppTheme.lightTheme / darkTheme are `static final`, so each one's
      // background is frozen at whatever AppColors resolved to the first time
      // that ThemeData was built. AppColors.* are live getters over
      // `currentThemeColors`, so they always match the active palette — which
      // is what makes this screen follow dark mode after a logout.
      backgroundColor: AppColors.background,
      body: isPortrait ? _portraitLayout() : _landscapeLayout(),
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // Shared credential form
  // ───────────────────────────────────────────────────────────────────────

  /// Email + password + forgot-password + Sign In button.
  ///
  /// Mirrors Knowticed's `content` column: the children are centre-aligned so
  /// the 80%-width Sign In button sits in the middle of the form column.
  Widget _signInForm({required bool isPortrait}) {
    return GetBuilder<LoginController>(
      builder: (controller) => Column(
        children: [
          SizedBox(height: 10.sp),
          // Both hints were hardcoded English. The missing `enterYourPassword`
          // key the old comment referred to has been added to both .arb files,
          // so they are localized now (CR-SKEL-O3-N21).
          _field(
            controller: controller.emailcontroller,
            hint: S.of(context).enterYourEmail,
            asset: 'assets/icons_assets/main_icons_assets/mail-inbox-app.svg',
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 10.sp),
          SizedBox(

            child: _field(
              controller: controller.passcontroller,
              hint: S.of(context).enterYourPassword,
              asset:
                  'assets/icons_assets/main_icons_assets/password-protection.svg',

              obscureText: true, // renders the built-in eye toggle
              // CHANGED 21/9/2026 — '*' (U+002A) is a superscript-height glyph,
              // so the mask sat at the top of the field (bug report p.15).
              // '∗' (U+2217, ASTERISK OPERATOR) is still a star but is drawn on
              // the math axis, i.e. vertically centred in the line.
              // CHANGED 30/9/2026 (Role QA p.1) — '∗' is not in the app
              // font, so it came from a fallback font and still sat below the
              // icon/eye centre line. '•' is in the font and is the platform
              // default mask; it lines up with the icons.
              obscuringCharacter: '\u2022',
              onTap: () => hapticController.triggerHapticFeedback(
                  vibration: VibrateType.lightImpact,
                  hapticFeedback: HapticFeedback.lightImpact),
            ),
          ),
          SizedBox(height: 10.sp),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: _onForgotPasswordPressed,
                child: Text(
                  S.of(context).forgotPassword,
                  style: StyleText.fontSize14Weight400.copyWith(
                    fontSize: FontConstants.fontSize018.h,
                    color: AppColors.text,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 30.sp),

          // Services mobile QA p.33: on a phone the 300pt button sat inset
          // from the fields above it. It now spans the form column, so its
          // edges line up with the email / password fields and "Forgot
          // Password?". Tablet / desktop keep the 300pt centred button.
          customButton(
            color: AppColors.primary,
            width: MediaQuery.sizeOf(context).shortestSide < 600
                ? double.infinity
                : 300.sp,
            height: 38.sp,
            title: S.of(context).signIn,
            function: _onSignInPressed,
            textStyle: StyleText.fontSize16Weight600.copyWith(
              color: AppColors.textButton,
            ),
          ),
          // ADDED 9/10/2026 — DEBUG-ONLY "🧪 Test employee" (owner option B).
          // `kDebugTestEmployeeSwitchBuild` is a compile-time constant, false
          // in release/profile, so this button and the picker are tree-shaken.
          if (kDebugTestEmployeeSwitchBuild) ...<Widget>[
            SizedBox(height: 12.sp),
            const DebugTestEmployeeSignInButton(),
          ],
        ],
      ),
    );
  }

  /// Core CustomTextField tuned to Knowticed's CustomField appearance:
  /// 8px radius, 0.01.h vertical padding, prefix icon tinted with
  /// [AppColors.lightPrimary] at 0.025.h, card fill.
  Widget _field({
    required TextEditingController controller,
    required String hint,
    required String asset,
    TextInputType? keyboardType,
    bool obscureText = false,
    String obscuringCharacter = '•',
    VoidCallback? onTap,
  }) {
    return CustomTextField(
      height: 36,
      controller: controller,
      hint: hint,
      keyboardType: keyboardType,
      obscureText: obscureText,
      obscuringCharacter: obscuringCharacter,
      onTap: onTap,
      fillColor: AppColors.card,
      valueStyle: StyleText.fontSize14Weight400
          .copyWith(color: AppColors.secondaryText),
      hintStyle: StyleText.fontSize14Weight500
          .copyWith(color: AppColors.secondaryText),
      prefixIcon: CustomSvgImage(
        assetPath: asset,
        width: 0.020.h,
        height: 0.020.h,
        fit: BoxFit.scaleDown,
        color: AppColors.primary,
      ),
    );
  }

  void _onForgotPasswordPressed() {
    hapticController.triggerHapticFeedback(
        vibration: VibrateType.mediumImpact,
        hapticFeedback: HapticFeedback.mediumImpact);
    showDialog(
      context: context,
      builder: (_) => const ForgotPasswordDialog(),
    );
  }

  Future<void> _onSignInPressed() async {
    hapticController.triggerHapticFeedback(
        vibration: VibrateType.mediumImpact,
        hapticFeedback: HapticFeedback.mediumImpact);

    // Email is normalised to lower case so sign-in is case-insensitive.
    final String email =
        loginController.emailcontroller.text.trim().toLowerCase();
    final String password = loginController.passcontroller.text;

    if (email.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => ResponseDialog(
          title: S.of(context).missingInformation,
          subtitle: S.of(context).pleaseEnterBothEmailAndPasswordToSignIn,
          lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
        ),
      );
      return;
    }

    if (await checkInternet()) {
      // DIAGNOSTIC 7/9/2026 — the "Authentication Error /
      // [cloud_firestore/permission-denied]" dialog.
      //
      // That dialog is the generic fallback in
      // `DemoLoginController.handleAuthenticationErrorMessage`: a raw
      // `FirebaseException` reached it as a `Failure` message and matched no
      // `FailureAuthenticationType`, so it was printed verbatim. It does not
      // say WHICH of the seven Firestore reads a sign-in makes was refused.
      //
      // `LoginAccessProbe.run` walks those seven reads in order and logs each
      // one's verdict under the `[login-probe]` tag. It is debug-only, it
      // never throws, and its result is deliberately ignored — awaited only so
      // its lines land before the login's own `[login]` lines. Delete this
      // call (and the probe file) once the offending rule is fixed.
      //
      // No try/catch here: §11.2 forbids it in presentation/ui/, which is why
      // the handling lives inside the probe.
      await LoginAccessProbe.run(email);

      loginController.login(context, email, password);
    } else {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => ResponseDialog(
          title: S.of(context).error,
          subtitle: S.of(context).pleaseCheckYourInternetConnection,
          lottieAsset: "assets/lottie_assets/main_lottie_assets/internet.json",
        ),
      );
    }
  }

  // ───────────────────────────────────────────────────────────────────────
  // Shared chrome
  // ───────────────────────────────────────────────────────────────────────

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

  /// Title + tagline. The tagline steps down from semi-bold 22 (landscape) to
  /// regular 23 (portrait), exactly as Knowticed does.
  Widget _headings({required bool isPortrait}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).demoAppPlus,
            style: StyleText.fontSize28Weight500
                .copyWith(color: AppColors.text, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: isPortrait ? 8 : 10.h),
          Text(
            S.of(context).navigateTheDigitalFrontierWithEase,
            style: StyleText.fontSize20Weight500
                .copyWith(color: AppColors.text, fontWeight: FontWeight.w500),
          ),
        ],
      );

  Widget _copyright() => Text(
        '${S.of(context).copyright}© ${DateTime.now().year} Knowticed. ${S.of(context).allRIGHTSRESERVED}',
        style: StyleText.fontSize14Weight400.copyWith(
          fontSize: FontConstants.fontSize018.h,
          color: AppColors.text,
        ),
        textAlign: TextAlign.center,
      );

  Widget _versionLabel() => Text(
        appVersion.isEmpty
            ? '${S.of(context).version} ...'
            : '${S.of(context).version} ${localizeNumber(appVersion)}',
        style: StyleText.fontSize14Weight400.copyWith(
          fontSize: FontConstants.fontSize018.h,
          color: AppColors.text,
        ),
        textAlign: TextAlign.center,
      );

  /// Landscape-only locale toggle.
  Widget _languageToggle() => GestureDetector(
        onTap: () {
          final box = GetStorage();
          final String? localeData = box.read<String>('LocaleData');
          final Locale locale = localeData.toString().contains('ar')
              ? const Locale('en', 'US')
              : const Locale('ar', 'EG');
          Get.updateLocale(locale);
          box.write('LocaleData', locale.toString());
          hapticController.triggerHapticFeedback(
              vibration: VibrateType.heavyImpact,
              hapticFeedback: HapticFeedback.heavyImpact);
        },
        child: Text(
          // The label names the language you would switch *to*, so it is the
          // opposite of the active one. Was a hardcoded AR/EN literal pair
          // selected with `Get.locale` (CR-SKEL-O3-N22).
          Localizations.localeOf(context).languageCode ==
                  AppConstants.englishLanguageCode
              ? S.of(context).arabic
              : S.of(context).english,
          style: StyleText.fontSize20Weight500.copyWith(
            fontSize: FontConstants.fontSize020.h,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
      );

  // ───────────────────────────────────────────────────────────────────────
  // Portrait — phone and tablet
  // ───────────────────────────────────────────────────────────────────────

  Widget _portraitLayout() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              Image.asset(
                kSignInHeroImage,
                width: double.infinity,
                fit: BoxFit.cover,
                height: 0.45.h,
              ),
              Positioned(
                top: 0.07.h,
                left: _isArabic ? 0.89.w : 0.045.w,
                child: _logo(
                  width: .06.h,
                  height: storage.read('logo') == null ? .05.h : .06.h,
                ),
              ),
            ],
          ),

          SizedBox(height: 20.sp),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.04.w),
            child: _headings(isPortrait: true),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.04.w),
            child: _signInForm(isPortrait: true),
          ),
          Padding(
            padding: EdgeInsets.only(top: 0.11.h),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _copyright(),
                  SizedBox(height: 0.02.h),
                  _versionLabel(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // Landscape — tablet and desktop
  // ───────────────────────────────────────────────────────────────────────

  Widget _landscapeLayout() {
    final bool isKeyboardVisible =
        MediaQuery.of(context).viewInsets.bottom != 0;
    final bool isMobilePlatform = Platform.isAndroid || Platform.isIOS;

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
                          _headings(isPortrait: false),
                          _signInForm(isPortrait: false),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: 0.070.h,
          left: _isArabic ? 0.9.w : 0.030.w,
          child: _logo(
            width: .095.h,
            height: storage.read('logo') == null ? .07.h : .095.h,
          ),
        ),
        if (!isKeyboardVisible)
          Positioned(
            bottom: 0.070.h,
            right: isMobilePlatform
                ? (_isArabic ? 0.55.w : 0.19.w)
                : (_isArabic ? 0.55.w : 0.185.w),
            child: _copyright(),
          ),
        if (!isKeyboardVisible)
          Positioned(
            bottom: 0.030.h,
            right: _isArabic ? 0.65.w : 0.28.w,
            child: _versionLabel(),
          ),
        Positioned(
          top: 0.070.h,
          right: _isArabic ? null : 0.050.w,
          left: _isArabic ? 0.050.w : null,
          child: _languageToggle(),
        ),
      ],
    );
  }
}
