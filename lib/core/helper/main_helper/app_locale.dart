/// Module: core · main_helper
///
///*************************** FILE INFO ****************************///
/// File Name: app_locale.dart
/// Purpose: The single place that decides, stores and applies the app language.
/// Author: Knowticed Plus team
/// Created: 01/09/2026
///
/// WHY THIS EXISTS
///
/// The language used to be decided in three places that could disagree:
///
///   1. `main()` read GetStorage['LocaleData'] and called `S.load(Locale('ar'))`
///      — language only, no country.
///   2. `MyApp.build` read the SAME key and built `Locale('ar', 'EG')`.
///   3. `LanguageScreen.toggleLangSwitch` wrote that key and called
///      `Get.updateLocale(Locale('ar', 'SA'))` — a THIRD country code.
///
/// plus `ThemeAndLocalizationsCubit`, which read a completely different store
/// (SharedPreferences['appLocale']) that nothing ever wrote.
///
/// `S` resolves on languageCode alone, so the messages survived that. Anything
/// keyed on the FULL tag did not: `S.load` sets `Intl.defaultLocale` to
/// `locale.toString()`, so booting into Arabic left `Intl.defaultLocale` as
/// `ar_EG` while switching to Arabic at runtime left it as `ar_SA`. Every
/// DateFormat and NumberFormat that relies on the ambient locale therefore
/// formatted differently depending on HOW the app arrived in Arabic.
///
/// Everything that sets or reads the language now goes through here.
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

import 'package:knowticed_plus/generated/l10n.dart';

class AppLocale {
  const AppLocale._();

  /// GetStorage key. Keep this value — it is what the language picker has
  /// always written, so existing installs keep their choice.
  static const String storageKey = 'LocaleData';

  /// The ONE Locale used for each language, everywhere: what is handed to
  /// `S.load`, to `GetMaterialApp.locale`, and to `Get.updateLocale`.
  static const Locale arabic = Locale('ar', 'SA');
  static const Locale english = Locale('en', 'US');

  /// The stored choice, falling back to the device language on a fresh install.
  static String get languageCode {
    final String? stored = GetStorage().read<String>(storageKey);
    final String raw = stored ?? Get.deviceLocale?.toString() ?? 'en';
    return raw.toLowerCase().contains('ar') ? 'ar' : 'en';
  }

  static bool get isArabic => languageCode == 'ar';

  /// The Locale the app should be in right now.
  static Locale get current => isArabic ? arabic : english;

  /// Applies [locale] to every mechanism that resolves a localized value, and
  /// persists it so the next cold start comes up the same way.
  ///
  /// Call this from anywhere the user changes language. Calling
  /// `Get.updateLocale` on its own is not enough — it moves the widget tree but
  /// leaves `Intl.defaultLocale` and `S.current` behind.
  static Future<void> apply(Locale locale) async {
    final Locale target = locale.languageCode == 'ar' ? arabic : english;

    await GetStorage().write(storageKey, target.languageCode);
    await _load(target);
    Get.updateLocale(target);
  }

  /// Boot-time restore. Same as [apply] minus the write (nothing changed) and
  /// minus `Get.updateLocale` — at this point `runApp` has not been called and
  /// there is no tree to update; `GetMaterialApp.locale` picks [current] up.
  static Future<void> restore() => _load(current);

  static Future<void> _load(Locale target) async {
    await S.load(target);
    // `S.load` already assigns this, but only as a side effect of its own
    // canonicalisation. Setting it here as well makes the contract explicit:
    // after this call the ambient Intl locale IS the app locale.
    Intl.defaultLocale = target.toString();
  }
}
