/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: toggle_control.dart
/// Purpose: Declares `ThemeAndLocalizationsState`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

// ******************* FILE INFO *******************
// File Name: toogle_control.dart
// Description: Theme & localization toggle cubit (app-wide toggle control).
// Module: core / theme
// Note: relocated here from services_management_module/main_controller/
//       controller so main.dart and other modules can use it without
//       depending on the services module.
// *************************************************

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:knowticed_plus/core/helper/main_helper/app_locale.dart';

class ThemeAndLocalizationsState {
  final ThemeMode themeMode;
  final Locale locale;

  ThemeAndLocalizationsState({
    required this.themeMode,
    required this.locale,
  });

  ThemeAndLocalizationsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
  }) {
    return ThemeAndLocalizationsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }
}

class ThemeAndLocalizationsCubit extends Cubit<ThemeAndLocalizationsState> {
  // B5 FIX: guard against emit-after-close (StateError) when the user
  // navigates away mid-await. Applies to every emit in this cubit.
  @override
  void emit(state) {
    if (isClosed) return;
    super.emit(state);
  }

  // FIXED: the initial locale was a hardcoded `const Locale('en')`, and
  // _loadSettings then read SharedPreferences['appLocale'] — a key NOTHING in
  // the app ever wrote. The real language picker writes
  // GetStorage['LocaleData'], which is also what main() and GetMaterialApp
  // read. So this cubit's locale was pinned to English on every run no matter
  // what language was chosen, and any widget rendering from it disagreed with
  // the rest of the tree.
  //
  // It now seeds from AppLocale, which reads the same store as everyone else,
  // and does so SYNCHRONOUSLY: the old value arrived one async frame late, so
  // even a correct value would have been English for the first frames.
  ThemeAndLocalizationsCubit()
      : super(
    ThemeAndLocalizationsState(
      themeMode: ThemeMode.dark,
      locale: AppLocale.current,
    ),
  ) {
    _loadSettings();
  }

  /// Load theme from SharedPreferences.
  ///
  /// The locale is NOT loaded here — it is already correct from the
  /// constructor, and re-reading it from a second store is what caused the
  /// disagreement this class used to introduce.
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final themeString = prefs.getString('themeMode');
    ThemeMode themeMode = ThemeMode.dark;
    if (themeString == ThemeMode.light.toString()) {
      themeMode = ThemeMode.light;
    }

    emit(state.copyWith(themeMode: themeMode));
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    final newTheme =
    state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', newTheme.toString());

    emit(state.copyWith(themeMode: newTheme));
  }

  /// Toggle between English and Arabic
  ///
  /// FIXED: this wrote SharedPreferences['appLocale'] and emitted a new state,
  /// which changed nothing the user could see — GetMaterialApp's locale comes
  /// from GetStorage['LocaleData'], and no `Get.updateLocale`, `S.load` or
  /// `Intl.defaultLocale` call was made. It now goes through AppLocale, the
  /// same path the language picker uses.
  Future<void> toggleLanguage() async {
    final Locale newLocale =
        state.locale.languageCode == 'en' ? AppLocale.arabic : AppLocale.english;

    await AppLocale.apply(newLocale);

    emit(state.copyWith(locale: newLocale));
  }
}
