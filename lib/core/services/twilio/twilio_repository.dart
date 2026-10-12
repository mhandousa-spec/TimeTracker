/// Module: core/services/twilio
///
///*************************** FILE INFO ****************************///
/// File Name: twilio_repository.dart
/// Purpose: Send and verify one-time passcodes through Twilio Verify.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Removed 11 print() calls, five of which logged the
///          Account SID, the SID/token lengths, the OTP destination and the
///          base64-encoded `SID:token` credential to the device console.
///
/// SECURITY: the auth token still reaches the client because the request is
/// made from the app. That is inherent to calling Twilio directly and cannot
/// be fixed here — move OTP sending behind a Cloud Function.

import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:knowticed_plus/core/services/twilio/twilio_constants.dart';

class TwilioRepository {
  static const String _verifyBase = 'https://verify.twilio.com/v2/Services';

  /// Basic auth header value. Never log this.
  String get _authHeader {
    final String credentials =
        '${TwilioConstants.twilioAccountSid}:${TwilioConstants.twilioAuthToken}';
    return 'Basic ${base64Encode(utf8.encode(credentials))}';
  }

  /// Function Name: [sendOTP]
  ///
  /// Purpose: Start a Twilio Verify challenge.
  ///
  /// Parameters:
  /// - [to]: Destination phone number in E.164 form.
  /// - [channel]: `sms` or `call`.
  /// - [locale]: Message locale.
  ///
  /// Returns: [Future<bool>] `true` when Twilio accepted the request.
  ///
  /// Throws: [StateError] when the Twilio dart-defines were not supplied.
  Future<bool> sendOTP(String to, String channel, String locale) async {
    TwilioConstants.assertConfigured();

    final Uri url = Uri.parse(
      '$_verifyBase/${TwilioConstants.twilioVerifyServiceSid}/Verifications',
    );

    final http.Response response = await http.post(
      url,
      headers: <String, String>{
        'Authorization': _authHeader,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: <String, String>{
        'To': to,
        'Channel': channel,
        'Locale': locale,
      },
    );

    // Previously this only logged on failure, so the caller could not tell a
    // sent OTP from a rejected one. The status is returned instead.
    return response.statusCode == 201;
  }

  /// Function Name: [verifyOTP]
  ///
  /// Purpose: Check a code the user entered against the Twilio challenge.
  ///
  /// Parameters:
  /// - [to]: Destination phone number in E.164 form.
  /// - [code]: The code the user entered.
  ///
  /// Returns: [Future<bool>] `true` only when Twilio reports `approved`.
  ///
  /// Throws: [StateError] when the Twilio dart-defines were not supplied.
  Future<bool> verifyOTP(String to, String code) async {
    TwilioConstants.assertConfigured();

    final Uri url = Uri.parse(
      '$_verifyBase/${TwilioConstants.twilioVerifyServiceSid}/VerificationCheck',
    );

    final http.Response response = await http.post(
      url,
      headers: <String, String>{
        'Authorization': _authHeader,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: <String, String>{'To': to, 'Code': code},
    );

    if (response.statusCode != 200) return false;

    final dynamic data = jsonDecode(response.body);
    return data is Map && data['status'] == 'approved';
  }
}
