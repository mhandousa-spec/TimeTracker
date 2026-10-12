/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: location_data_service.dart
/// Purpose: Country -> state/governorate -> city data for the location dropdowns.
/// Author: Knowticed Plus team
/// Created at: 24/8/2026
///
/// WHY THIS EXISTS INSTEAD OF A PACKAGE
///
/// `country_state_city` is data-only and would have been the obvious pick, but
/// its pubspec pins `sdk: ">=2.17.6 <3.0.0"` and this project is on Dart 3.5.4,
/// so `flutter pub get` refuses it. `csc_picker_plus` IS Dart 3 ready, but it
/// only ships a widget — it exposes no way to read the underlying lists — and
/// the requirement here is to render through `CustomDropdown`, the app's own
/// control. So the data lives in `assets/data/location_data.json` and this
/// service reads it.
///
/// The COUNTRY list is not in that file. It comes from `country_picker`, which
/// is already a dependency, so every country in the world is offered and the
/// Arabic names are the package's own translations rather than hand-typed ones.
/// The JSON only fills in what `country_picker` has no answer for: the states
/// and cities under a country.

import 'dart:convert';

import 'package:country_picker/country_picker.dart'
    show CountryService, CountryLocalizations;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

/// One selectable place. [code] is the ISO-2 for a country, the state code for
/// a state, and empty for a city (cities have no stable code in the data).
class LocationOption {
  const LocationOption({
    required this.code,
    required this.name,
    this.nameAr,
  });

  final String code;
  final String name;
  final String? nameAr;

  /// The label to show, by app locale. Falls back to English when a place has
  /// no Arabic name yet, which is better than showing an empty row.
  String label(bool isArabic) =>
      isArabic ? (nameAr?.isNotEmpty == true ? nameAr! : name) : name;

  /// Looser match, for values typed in before these dropdowns existed. A record
  /// holding "Mubarak Al-kabeer Governorate" should still resolve to the
  /// canonical "Mubarak Al-Kabeer" rather than silently starting empty.
  ///
  /// The 3-character floor stops a stray one- or two-letter value from matching
  /// half the list.
  bool matchesLoose(String? text) {
    if (matches(text)) return true;
    final t = text?.trim().toLowerCase() ?? '';
    if (t.length < 3) return false;
    final en = name.trim().toLowerCase();
    final ar = (nameAr ?? '').trim().toLowerCase();
    return (en.isNotEmpty && (t.contains(en) || en.contains(t))) ||
        (ar.isNotEmpty && (t.contains(ar) || ar.contains(t)));
  }

  /// True when [text] is this place under either language. Used to turn a value
  /// already saved on the employee record back into a dropdown selection.
  bool matches(String? text) {
    if (text == null) return false;
    final t = text.trim().toLowerCase();
    if (t.isEmpty) return false;
    return t == name.trim().toLowerCase() ||
        t == (nameAr ?? '').trim().toLowerCase() ||
        (code.isNotEmpty && t == code.toLowerCase());
  }
}

class LocationDataService {
  LocationDataService._();

  static final LocationDataService instance = LocationDataService._();

  static const String _assetPath = 'assets/data/location_data.json';

  /// countryIso2 -> { states: [...] }, parsed once and kept.
  Map<String, dynamic>? _countries;

  /// In flight while the first caller is waiting, so two widgets building at
  /// the same time do not each decode the file.
  Future<void>? _loading;

  bool get isLoaded => _countries != null;

  /// Reads and decodes the asset. Safe to call repeatedly — after the first
  /// success it returns immediately.
  Future<void> load() {
    if (_countries != null) return Future<void>.value();
    return _loading ??= _read();
  }

  Future<void> _read() async {
    try {
      final raw = await rootBundle.loadString(_assetPath);
      final decoded = json.decode(raw);
      _countries = Map<String, dynamic>.from(
        (decoded as Map<String, dynamic>)['countries'] as Map,
      );
    } catch (_) {
      // A missing or malformed asset must not take the settings screen down.
      // The country dropdown still works (it comes from country_picker); the
      // state and city dropdowns are simply empty.
      _countries = <String, dynamic>{};
    } finally {
      _loading = null;
    }
  }

  // ── Countries ─────────────────────────────────────────────────────────────

  /// Every country in the world, sorted by the label the user will read.
  ///
  /// [context] is used for the Arabic names. It needs
  /// `CountryLocalizations.delegate` in the app's `localizationsDelegates`;
  /// without it the English name is returned, never an empty string.
  List<LocationOption> countries(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final localizations = CountryLocalizations.of(context);

    // No filtering: `CountryService.getAll()` returns the real countries only —
    // the special "world wide" entry is opt-in on the picker, not in this list.
    final list = CountryService()
        .getAll()
        .map((c) {
          final translated = localizations?.countryName(
            countryCode: c.countryCode,
          );
          return LocationOption(
            code: c.countryCode,
            name: c.name,
            nameAr: translated,
          );
        })
        .toList();

    list.sort((a, b) => a.label(isArabic).compareTo(b.label(isArabic)));
    return list;
  }

  // ── States / governorates ─────────────────────────────────────────────────

  /// The states of [countryIso2], or an empty list when the JSON has no entry
  /// for that country yet. Order is the order in the file, which is the
  /// official order for the countries currently filled in.
  List<LocationOption> statesOf(String? countryIso2) {
    final country = _country(countryIso2);
    if (country == null) return const <LocationOption>[];

    return (country['states'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .map((s) => LocationOption(
              code: (s['code'] ?? '') as String,
              name: (s['name'] ?? '') as String,
              nameAr: s['name_ar'] as String?,
            ))
        .toList();
  }

  // ── Cities ────────────────────────────────────────────────────────────────

  /// The cities of one state. [stateCode] is the `code` of a [statesOf] entry.
  List<LocationOption> citiesOf(String? countryIso2, String? stateCode) {
    final country = _country(countryIso2);
    if (country == null || stateCode == null || stateCode.isEmpty) {
      return const <LocationOption>[];
    }

    final state = (country['states'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .firstWhere(
          (s) => s['code'] == stateCode,
          orElse: () => <String, dynamic>{},
        );

    return (state['cities'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .map((c) => LocationOption(
              code: '',
              name: (c['name'] ?? '') as String,
              nameAr: c['name_ar'] as String?,
            ))
        .toList();
  }

  /// True when this country has any state data at all. The caller uses it to
  /// explain an empty dropdown instead of leaving the user staring at nothing.
  bool hasStateData(String? countryIso2) => statesOf(countryIso2).isNotEmpty;

  Map<String, dynamic>? _country(String? iso2) {
    if (_countries == null || iso2 == null || iso2.isEmpty) return null;
    final entry = _countries![iso2.toUpperCase()];
    return entry is Map ? Map<String, dynamic>.from(entry) : null;
  }
}
