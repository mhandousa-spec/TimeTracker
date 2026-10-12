/// Module: core/constants
///
///*************************** FILE INFO ****************************///
/// File Name: app_constants.dart
/// Purpose: App-wide non-secret constants.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// One of the three files §5 of the review requires under core/constants/
/// (alongside firebase_collections.dart and app_keys.dart). Values here were
/// collected from literals that appeared at more than one call site.
abstract final class AppConstants {
  const AppConstants._();

  // ── Locales ────────────────────────────────────────────────────────────
  static const String englishLanguageCode = 'en';
  static const String arabicLanguageCode = 'ar';

  /// Locales the app ships. Keep in sync with `MaterialApp.supportedLocales`
  /// and with `AppBarDate.supportedDateLocales`.
  static const List<String> supportedLanguageCodes = <String>[
    englishLanguageCode,
    arabicLanguageCode,
  ];

  // ── Layout breakpoints ─────────────────────────────────────────────────
  /// Shortest-side breakpoint separating phone from tablet.
  ///
  /// Note this is deliberately distinct from [tabletWidthBreakpoint]: a phone
  /// in landscape can exceed the width breakpoint while still having a
  /// shortest side under 600. `ContextExtension` documents the difference.
  static const double tabletShortestSideBreakpoint = 600;

  /// Width breakpoint used by the responsive home/nav shells.
  static const double tabletWidthBreakpoint = 768;

  /// Shortest-side breakpoint for large tablets.
  static const double largeTabletShortestSideBreakpoint = 1024;

  // ── Storage keys ───────────────────────────────────────────────────────
  static const String localeStorageKey = 'LocaleData';
  static const String emailStorageKey = 'email';
  static const String companyIdStorageKey = 'company_id';
  static const String logoStorageKey = 'logo';
  static const String drawerOrderStorageKey = 'drawer_custom_order';

  /// `'true'` once the user has been through the intro carousel. Written by
  /// o2_intro and read by the splash screen, both of which used the literal
  /// (§15, CR-SKEL-O1-N07 / CR-SKEL-O2-N11).
  static const String onboardingStorageKey = 'onboarding';

  /// The value [onboardingStorageKey] is set to. It is a String, not a bool —
  /// the splash screen compares `== 'true'`.
  static const String onboardingCompletedValue = 'true';

  // ── Date formats ───────────────────────────────────────────────────────
  /// Format used for the permission From_Date / To_Date fields.
  ///
  /// Note: the review flags `getExpiringPermissions` for calling
  /// `DateTime.parse` on values in this format, which always throws — parse
  /// with `DateFormat(permissionDateFormat).parse(...)` instead.
  static const String permissionDateFormat = 'MMM dd, yyyy';

  static const String displayDateFormat = 'dd MMMM yyyy';
  static const String timestampFormat = 'yyyy-MM-dd HH:mm:ss';

  // ── Defaults ───────────────────────────────────────────────────────────
  /// Default validity window applied to a newly imported employee's access.
  static const Duration defaultAccessDuration = Duration(days: 180);
}
