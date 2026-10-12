/// Module: onboarding/o2_intro
///
///*************************** FILE INFO ****************************///
/// File Name: onboarding.dart
/// Purpose: The swipeable intro carousel shown on first run.
/// Author: Mazen Shabaan
/// Created at: 16/July/2023
/// Updated: 12/8/2026 - CR-SKEL-O2-N04..N14: the three file-scope
///          `Get.find()` / `Get.put(ThemeController())` globals are gone —
///          they ran on *import*, and twenty files imported this page just to
///          reach `themeController`, which now lives in
///          `core/theme/theme_controller.dart`; the mutable top-level
///          `screenWidth`, computed from the physical display at import, is
///          replaced by `MediaQuery` inside `initState`; the eight hardcoded
///          English paragraphs moved to the .arb bundle; `S.current` became
///          `S.of(context)` so the carousel follows a locale change;
///          `PersistentNavBarNavigator.pushNewScreen` became a named route;
///          the ~117-line `build` is split; the model's swapped
///          `description` / `titlestr` fields are renamed and made final;
///          the blanket `ignore_for_file` and the commented-out imports are
///          deleted; `_OnboardScreenState` is `_WelcomeViewState`.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:knowticed_plus/core/constants/app_constants.dart';
import 'package:knowticed_plus/core/network/message_module/routes/app_routes.dart';
import 'package:knowticed_plus/core/network/message_module/routes/get_pages.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/custom/33-custom_haptic.dart';
import 'package:knowticed_plus/features/onboarding/o2_intro/presentation/ui/widgets/page_on_boarding.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// One slide's content.
///
/// The fields were previously named so that `build` passed `description` as
/// the title and `titlestr` as the body — functional but backwards
/// (CR-SKEL-O2-N14).
class AllinOnboardModel {
  const AllinOnboardModel({
    required this.imageAsset,
    required this.title,
    required this.body,
  });

  final String imageAsset;
  final String title;
  final String body;
}

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  static const String _assetRoot = 'assets/icons_assets/onboarding_assets';

  /// Illustration per slide, in order. Kept separate from the localized text
  /// so the list below can be built with a `BuildContext`.
  static const List<String> _slideAssets = <String>[
    '$_assetRoot/onboarding_checklist.svg',
    '$_assetRoot/onboarding_calendar_planning.svg',
    '$_assetRoot/onboarding_chat_conversation.svg',
    '$_assetRoot/onboarding_analytics_presentation.svg',
    '$_assetRoot/onboarding_profile_accept.svg',
    '$_assetRoot/onboarding_customer_loyalty_handshake.svg',
    '$_assetRoot/onboarding_secure_login.svg',
    '$_assetRoot/onboarding_checklist.svg',
  ];

  int currentIndex = 0;
  late final PageController pageController =
      PageController(initialPage: 0, keepPage: true);

  @override
  void initState() {
    super.initState();
    // Was read from a mutable top-level `screenWidth` computed from
    // `platformDispatcher.views.first.physicalSize` at import time — which is
    // evaluated before the app has a window on some launches, and never
    // updates (CR-SKEL-O2-N05).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _applyPreferredOrientations();
    });
  }

  void _applyPreferredOrientations() {
    final bool isTablet = MediaQuery.of(context).size.shortestSide >
        AppConstants.tabletShortestSideBreakpoint;

    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
      if (isTablet) DeviceOrientation.landscapeLeft,
      if (isTablet) DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  /// Built per frame from `S.of(context)`, so the carousel follows a locale
  /// change. Was a field initializer using `S.current`, which resolves once and
  /// runs outside a BuildContext (CR-SKEL-O2-N10).
  List<AllinOnboardModel> _slides(BuildContext context) {
    final S text = S.of(context);
    final List<String> titles = <String>[
      text.effortlessTaskManagement,
      text.streamlinedRequests,
      text.comprehensiveServiceManagement,
      text.efficientEventManagement,
      text.flexibleRoleManagement,
      text.personalizedToDoLists,
      text.realTimeTeamChat,
      text.clearOrganizationChart,
    ];
    final List<String> bodies = <String>[
      text.effortlessTaskManagementBody,
      text.streamlinedRequestsBody,
      text.comprehensiveServiceManagementBody,
      text.efficientEventManagementBody,
      text.flexibleRoleManagementBody,
      text.personalizedToDoListsBody,
      text.realTimeTeamChatBody,
      text.clearOrganizationChartBody,
    ];

    return <AllinOnboardModel>[
      for (int i = 0; i < _slideAssets.length; i++)
        AllinOnboardModel(
          imageAsset: _slideAssets[i],
          title: titles[i],
          body: bodies[i],
        ),
    ];
  }

  /// Marks the carousel as seen, so the splash screen goes straight to sign-in
  /// next launch.
  void _markOnboardingComplete() {
    storage.write(
      AppConstants.onboardingStorageKey,
      AppConstants.onboardingCompletedValue,
    );
  }

  /// `AppPages.route(...)` rather than `pushReplacementNamed`: the app does not
  /// pass `getPages` to `GetMaterialApp`, so a bare named push has no generator
  /// to resolve against.
  void _goToSignIn() {
    Navigator.of(context)
        .pushReplacement(AppPages.route(Routes.onboardingSignIn));
  }

  void _onPrimaryPressed(int slideCount) {
    hapticController.triggerHapticFeedback(
      vibration: VibrateType.heavyImpact,
      hapticFeedback: HapticFeedback.heavyImpact,
    );

    if (currentIndex < slideCount - 1) {
      setState(() => currentIndex++);
      pageController.animateToPage(
        currentIndex,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeIn,
      );
      return;
    }

    _markOnboardingComplete();
    _goToSignIn();
  }

  void _onSkipPressed() {
    _markOnboardingComplete();
    hapticController.triggerHapticFeedback(
      vibration: VibrateType.lightImpact,
      hapticFeedback: HapticFeedback.lightImpact,
    );
    _goToSignIn();
  }

  @override
  Widget build(BuildContext context) {
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final bool isTablet = MediaQuery.of(context).size.shortestSide >
        AppConstants.tabletShortestSideBreakpoint;
    final List<AllinOnboardModel> slides = _slides(context);

    return Scaffold(
      // Explicit rather than inherited from `scaffoldBackgroundColor`:
      // AppTheme.lightTheme / darkTheme are `static final`, so each one's
      // background colour is frozen at whatever AppColors resolved to the first
      // time that ThemeData was constructed. That is why switching to dark in
      // the app and logging out left this page rendering light. AppColors.*
      // are live getters over `currentThemeColors`, so they always match.
      backgroundColor: AppColors.background,
      body: Padding(
        padding: EdgeInsets.only(left: 0.028.w, right: 0.028.w),
        child: ListView(
          children: <Widget>[
            _buildCarousel(slides, isPortrait: isPortrait, isTablet: isTablet),
            _buildDots(slides.length),
            SizedBox(height: 0.028.h),
            _buildPrimaryButton(slides.length,
                isPortrait: isPortrait, isTablet: isTablet),
            SizedBox(height: 0.016.h),
            _buildSkipButton(isPortrait: isPortrait, isTablet: isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildCarousel(
    List<AllinOnboardModel> slides, {
    required bool isPortrait,
    required bool isTablet,
  }) {
    return SizedBox(
      height: isTablet && isPortrait ? 0.78.h : 0.75.h,
      child: Padding(
        padding: EdgeInsets.only(top: isPortrait ? 0.06.h : 0.07.h),
        child: PageView.builder(
          controller: pageController,
          onPageChanged: (int value) => setState(() => currentIndex = value),
          itemCount: slides.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? (isPortrait ? 0.05.w : 0.3.h) : 0,
              ),
              child: CustomPageView(
                title: slides[index].title,
                description: slides[index].body,
                imgurl: slides[index].imageAsset,
              ),
            );
          },
        ),
      ),
    );
  }

  /// Jump straight to [index] when its indicator is tapped.
  ///
  /// The dots were previously decorative only — they showed which slide was
  /// active but swallowed taps, so the only way through the carousel was the
  /// Next button.
  void _onDotPressed(int index) {
    if (index == currentIndex) return;

    hapticController.triggerHapticFeedback(
      vibration: VibrateType.lightImpact,
      hapticFeedback: HapticFeedback.lightImpact,
    );

    setState(() => currentIndex = index);
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildDots(int slideCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(
        slideCount,
        (int index) => Semantics(
          button: true,
          selected: currentIndex == index,
          label: '${index + 1}',
          child: InkWell(
            onTap: () => _onDotPressed(index),
            customBorder: const CircleBorder(),
            // A bare dot is well under the 48dp minimum tap target, so the
            // padding — not the dot — is what the finger actually hits.
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 0.006.w,
                vertical: 0.012.h,
              ),
              child: buildDot(index: index),
            ),
          ),
        ),
      ),
    );
  }

  /// Full-bleed primary action, matching Knowticed. The shared `customButton`
  /// was deliberately not used: ButtonSizing clamps it to a 38.sp/135.sp pill,
  /// which reads as a small chip here instead of a wide CTA.
  Widget _buildPrimaryButton(
    int slideCount, {
    required bool isPortrait,
    required bool isTablet,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? (isPortrait ? 0.2.w : 0.45.h) : 0.04.w,
      ),
      child: ElevatedButton(
        onPressed: () => _onPrimaryPressed(slideCount),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: Size(0.035.w, 0.057.h),
          backgroundColor: AppColors.signOut,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
        ),
        child: Text(
          currentIndex != slideCount - 1
              ? S.of(context).next
              : S.of(context).getStart,
          style: StyleText.fontSize16Weight400
              .copyWith(color: AppColors.textButton),
        ),
      ),
    );
  }

  Widget _buildSkipButton({
    required bool isPortrait,
    required bool isTablet,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? (isPortrait ? 0.2.w : 0.45.h) : 0.04.w,
      ),
      child: TextButton(
        onPressed: _onSkipPressed,
        style: TextButton.styleFrom(
          minimumSize: Size(0.035.w, 0.057.h),
          foregroundColor: AppColors.darkGrey,
          backgroundColor: AppColors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
        ),
        onLongPress: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Text(
          S.of(context).skip,
          style: StyleText.fontSize20Weight500.copyWith(
            fontSize: isTablet
                ? FontConstants.fontSize022.h
                : FontConstants.fontSize020.h,
            // Secondary action → the palette's grey, per the design rule that
            // grey buttons use AppColors.darkGrey. `textdeactivecolor` is an
            // alias for the same key; naming it directly makes the intent
            // readable at the call site.
            color: AppColors.darkGrey,
          ),
        ),
      ),
    );
  }

  /// One page indicator. Widens for the current slide.
  AnimatedContainer buildDot({int? index}) {
    final bool isTablet = MediaQuery.of(context).size.shortestSide >
        AppConstants.tabletShortestSideBreakpoint;
    final bool isCurrent = currentIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      // Spacing now comes from the tap-target padding in _buildDots. The old
      // `EdgeInsets.only(right:)` also mirrored under RTL, which left the row
      // visually off-centre in Arabic.
      margin: EdgeInsets.zero,
      height: isTablet ? 0.015.h : 0.01.h,
      width: isCurrent
          ? (isTablet ? 0.035.w : 0.06.w)
          : (isTablet ? 0.015.h : 0.02.w),
      decoration: BoxDecoration(
        // Theme-aware: AppColors.onboardingDotInactive resolves per palette,
        // replacing the manual currentTheme == lightTheme comparison.
        color: isCurrent ? AppColors.signOut : AppColors.onboardingDotInactive,
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }
}

/// Alias so that `Onboarding` can be used wherever `WelcomeView` is needed.
typedef Onboarding = WelcomeView;
