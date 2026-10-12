/// Module: core / services / restricted_location
///
///*************************** FILE INFO ****************************///
/// File Name: restricted_location_guard.dart
/// Purpose: Declares `RestrictedLocationGuard` (decides whether the signed-in
///          employee may use the app from where they are) and
///          `RestrictedLocationOverlay` (the full-screen block shown when not).
/// Author: Knowticed Plus team
/// Created at: 28/9/2026
///
/// THE RULE
/// --------
/// Restricted Location is a ROLE policy, set on the role editor's third page
/// (Edit Role Settings Permissions): the `Restricted_Location` switch plus the
/// list of allowed countries under it (`RoleRepository.ROLE_RESTRICTED_LOCATIONS`).
/// For an employee whose role has the switch ON and at least one country
/// ticked, the app is blocked unless the device is in one of those countries.
/// Switch off, or no countries ticked, means no restriction.
///
/// WHERE THE COUNTRY COMES FROM
/// ----------------------------
///   1. Phones (Android / iOS): the GPS fix, reverse-geocoded to an ISO code.
///   2. Everywhere else, and on a phone whose GPS is off or denied: the
///      country of the device's public IP address (api.country.is). Desktop
///      has no reverse geocoder, so this is the desktop path.
/// If neither answers, the country is UNKNOWN and the app stays blocked with a
/// Try Again button — an unverifiable location must not open a restricted app.
///
/// WHEN IT RUNS
/// ------------
/// `MainCoreEmployeeController._loadModulePermissions` calls [evaluate] every
/// time the signed-in employee's role and permissions (re)load, so editing the
/// role takes effect without a restart.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/core/services/geolocator/geolocator_repository.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/repository/role_repository.dart';

enum RestrictedLocationStatus {
  /// No restriction applies, or the device is in an allowed country.
  allowed,

  /// A restriction applies and the check is running.
  checking,

  /// The device is outside every allowed country.
  blocked,

  /// A restriction applies but the country could not be determined.
  unknown,
}

class RestrictedLocationGuard {
  RestrictedLocationGuard._();

  static final RestrictedLocationGuard instance = RestrictedLocationGuard._();

  /// What the overlay draws from.
  final ValueNotifier<RestrictedLocationStatus> status =
      ValueNotifier<RestrictedLocationStatus>(RestrictedLocationStatus.allowed);

  /// The country last detected, for the message on the block screen.
  String? detectedCountryCode;

  String? _roleId;
  bool _enabled = false;
  int _run = 0;

  /// Re-check the policy for [roleId]. [enabled] is the role's
  /// `Restricted_Location` switch.
  Future<void> evaluate({
    required String roleId,
    required bool enabled,
  }) async {
    _roleId = roleId;
    _enabled = enabled;
    final int run = ++_run;

    if (!enabled) {
      status.value = RestrictedLocationStatus.allowed;
      return;
    }

    final List<String> allowed =
        await RoleRepository().getRestrictedCountryCodes(roleId);
    if (run != _run) return; // a newer evaluation superseded this one

    if (allowed.isEmpty) {
      status.value = RestrictedLocationStatus.allowed;
      return;
    }

    // Only show the "checking" state if nothing is decided yet, so a routine
    // re-check does not flash the block screen over a working session.
    if (status.value != RestrictedLocationStatus.allowed) {
      status.value = RestrictedLocationStatus.checking;
    }

    final String? country = await _detectCountryCode();
    if (run != _run) return;

    detectedCountryCode = country;
    if (country == null) {
      status.value = RestrictedLocationStatus.unknown;
      return;
    }

    final Set<String> allowedUpper =
        allowed.map((String c) => c.toUpperCase()).toSet();
    status.value = allowedUpper.contains(country.toUpperCase())
        ? RestrictedLocationStatus.allowed
        : RestrictedLocationStatus.blocked;
  }

  /// Run the last evaluation again (the block screen's Try Again).
  Future<void> retry() async {
    final String? roleId = _roleId;
    if (roleId == null) return;
    status.value = RestrictedLocationStatus.checking;
    await evaluate(roleId: roleId, enabled: _enabled);
  }

  /// Drop any restriction — call when nobody is signed in.
  void reset() {
    _run++;
    _roleId = null;
    _enabled = false;
    detectedCountryCode = null;
    status.value = RestrictedLocationStatus.allowed;
  }

  Future<String?> _detectCountryCode() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      final String? fromGps = await _countryFromGps();
      if (fromGps != null) return fromGps;
    }
    return _countryFromIp();
  }

  Future<String?> _countryFromGps() async {
    try {
      final Position? position = await GelocatorRepository.getCurrentLocation();
      if (position == null) return null;
      final List<Placemark> marks =
          await Geocoding()
              .placemarkFromCoordinates(position.latitude, position.longitude);
      final String? code =
          marks.isEmpty ? null : marks.first.isoCountryCode?.trim();
      return (code == null || code.isEmpty) ? null : code;
    } catch (e) {
      debugPrint('RestrictedLocationGuard GPS lookup failed: $e');
      return null;
    }
  }

  Future<String?> _countryFromIp() async {
    try {
      final http.Response response = await http
          .get(Uri.parse('https://api.country.is/'))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;
      final Object? body = jsonDecode(response.body);
      if (body is Map && body['country'] is String) {
        final String code = (body['country'] as String).trim();
        return code.isEmpty ? null : code;
      }
      return null;
    } catch (e) {
      debugPrint('RestrictedLocationGuard IP lookup failed: $e');
      return null;
    }
  }
}

/// Covers the whole app while [RestrictedLocationGuard] says the employee may
/// not use it here. Mounted once, in the `GetMaterialApp.builder` (main.dart).
class RestrictedLocationOverlay extends StatelessWidget {
  const RestrictedLocationOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<RestrictedLocationStatus>(
      valueListenable: RestrictedLocationGuard.instance.status,
      child: child,
      builder: (BuildContext context, RestrictedLocationStatus value,
          Widget? child) {
        final bool block = value != RestrictedLocationStatus.allowed;
        return Stack(
          children: <Widget>[
            child!,
            if (block)
              Positioned.fill(child: _BlockScreen(status: value)),
          ],
        );
      },
    );
  }
}

class _BlockScreen extends StatelessWidget {
  const _BlockScreen({required this.status});

  final RestrictedLocationStatus status;

  @override
  Widget build(BuildContext context) {
    final bool isArabic =
        Localizations.maybeLocaleOf(context)?.languageCode == 'ar';
    String t(String en, String ar) => isArabic ? ar : en;

    final bool checking = status == RestrictedLocationStatus.checking;
    final String title = checking
        ? t('Checking your location…', 'جارٍ التحقق من موقعك…')
        : t('Restricted Location', 'موقع مقيد');
    final String message = switch (status) {
      RestrictedLocationStatus.blocked => t(
          'Your role does not allow the app to be opened from your current '
              'country${_suffix()}.',
          'لا يسمح دورك بفتح التطبيق من دولتك الحالية${_suffix()}.'),
      RestrictedLocationStatus.unknown => t(
          'Your location could not be verified. Turn on location services '
              'and your internet connection, then try again.',
          'تعذر التحقق من موقعك. فعّل خدمات الموقع والاتصال بالإنترنت ثم حاول مرة أخرى.'),
      _ => '',
    };

    return Material(
      color: AppColors.background,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (checking)
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.lightPrimary),
                        strokeWidth: 2,
                      ),
                    )
                  else
                    Lottie.asset(
                      'assets/lottie_assets/main_lottie_assets/lottie_warning.json',
                      width: 90,
                      height: 90,
                    ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize20Weight500
                        .copyWith(color: AppColors.text),
                  ),
                  if (message.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 12),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: StyleText.fontSize14Weight400
                          .copyWith(color: AppColors.secondaryText),
                    ),
                  ],
                  if (!checking) ...<Widget>[
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: RestrictedLocationGuard.instance.retry,
                      child: Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          t('Try Again', 'حاول مرة أخرى'),
                          style: StyleText.fontSize16Weight500
                              .copyWith(color: AppColors.textButton),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _suffix() {
    final String? code = RestrictedLocationGuard.instance.detectedCountryCode;
    return code == null ? '' : ' ($code)';
  }
}
