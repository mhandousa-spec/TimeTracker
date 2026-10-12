/// Module: onboarding/o1_splash
///
///*************************** FILE INFO ****************************///
/// File Name: splash_screen.dart
/// Purpose: The launch screen — fades the brand mark in, then hands off to the
///          intro carousel or the sign-in page.
/// Author: Knowticed Plus team
/// Created at: 13/11/2024
/// Updated: 12/8/2026 - CR-SKEL-O1-N01..N09: moved from the feature root into
///          `presentation/ui/pages/`; the routing decision and the six direct
///          `storage.read(...)` calls moved into `SplashController`;
///          `Get.find<LoginController>()` is injected as a callback instead;
///          `themeController.currentTheme` replaced with `Theme.of(context)`;
///          the inline `MaterialPageRoute` replaced with a named route; asset
///          paths and storage keys moved to `AppAssets` / `AppConstants`; the
///          dead `isUsebiometrics` field removed; `const` constructor with a
///          `Key` added.

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/network/message_module/routes/app_routes.dart';
import 'package:knowticed_plus/core/network/message_module/routes/get_pages.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/features/onboarding/o1_splash/presentation/controller/splash_controller.dart';
import 'package:knowticed_plus/features/onboarding/o1_splash/presentation/controller/splash_destination.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/presentation/controller/login_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _fadeDuration = Duration(seconds: 4);

  late final AnimationController _controller;
  late final Animation<double> _animation;

  /// The `Get.find` is passed in as a callback so the controller itself has no
  /// dependency on the auth feature (CR-SKEL-O1-N04).
  late final SplashController _splashController = SplashController(
    isBiometricLoginEnabled: () =>
        Get.find<LoginController>().isUseBiometrics,
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _fadeDuration);
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _animation.addStatusListener(_onAnimationStatus);
    _controller.forward();
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) return;

    switch (_splashController.resolveDestination()) {
      case SplashDestination.waitForBiometrics:
        // signWithBiometrics() was started in LoginController.onInit() and
        // navigates itself; replacing the route here would race it.
        break;
      case SplashDestination.signIn:
        _replaceWith(Routes.onboardingSignIn);
        break;
      case SplashDestination.intro:
        _replaceWith(Routes.onboardingIntro);
        break;
    }
  }

  /// `AppPages.route(...)`, not `pushReplacementNamed`: the app does not pass
  /// `getPages` to `GetMaterialApp`, so a bare named push has no generator to
  /// resolve against. Same approach as the settings menu (round 4, §17).
  void _replaceWith(String routeName) {
    Navigator.of(context).pushReplacement(AppPages.route(routeName));
  }

  @override
  void dispose() {
    _animation.removeStatusListener(_onAnimationStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final String? companyLogo = _splashController.companyLogoUrl;

    return Scaffold(
      // Live palette rather than the frozen `scaffoldBackgroundColor` baked
      // into the `static final` ThemeData — see sign_in_screen.dart.
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _animation,
        child: Center(
          child: SizedBox(
            width: isPortrait ? 0.15.h : 0.25.h,
            // The tenant logo is always shown at the portrait size; only the
            // app mark grows in landscape. Preserved from the original.
            height: companyLogo == null || isPortrait ? 0.15.h : 0.25.h,
            child: companyLogo == null
                ? SvgPicture.asset(_appMarkFor(context))
                : SvgPicture.network(companyLogo),
          ),
        ),
      ),
    );
  }

  /// Reads the brightness from the tree rather than from `themeController`,
  /// so the mark follows a theme change without a restart.
  String _appMarkFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppAssets.logoDark
          : AppAssets.logo;
}
