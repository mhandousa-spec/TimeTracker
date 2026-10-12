/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: notification_page_config.dart
/// Purpose: FCM service configuration for the notification sender.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - CR-SKEL-NOTIF-N20: renamed from `notification_page_confg.dart`. The Admin
///          private key it used to hold was removed in round 3 — it reads a
///          dart-define now.

import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:knowticed_plus/core/constants/app_keys.dart';

class NotificationServiceApp {

  // ═══════════════════════════════════════════════════════════
  // METHOD 1: Get Access Token
  // ═══════════════════════════════════════════════════════════

  /// The last token obtained, and when it stops being valid.
  ///
  /// ADDED 25/8/2026. [getAccessToken] is called by [sendNotification], which
  /// is called once per recipient. A service-account handshake is two network
  /// round trips, so a fan-out to nineteen reviewers performed thirty-eight of
  /// them to send nineteen notifications — and the settings submit dialog waits
  /// on the whole thing.
  ///
  /// Google issues these tokens with an hour of life. They are cached until a
  /// minute before expiry (clock skew and in-flight requests), then re-minted.
  static auth.AccessCredentials? _cachedCredentials;

  /// One handshake at a time. Without this, a parallel fan-out would start N
  /// handshakes before any of them populated the cache — exactly the cost the
  /// cache exists to avoid.
  static Future<String>? _inFlightToken;

  static bool get _cacheIsUsable {
    final auth.AccessCredentials? credentials = _cachedCredentials;
    if (credentials == null) return false;
    return credentials.accessToken.expiry
        .isAfter(DateTime.now().toUtc().add(const Duration(minutes: 1)));
  }

  static Future<String> getAccessToken() async {
    if (_cacheIsUsable) return _cachedCredentials!.accessToken.data;

    // Someone else is already minting one — wait for theirs.
    final Future<String>? pending = _inFlightToken;
    if (pending != null) return pending;

    final Future<String> request = _mintAccessToken();
    _inFlightToken = request;
    try {
      return await request;
    } finally {
      _inFlightToken = null;
    }
  }

  static Future<String> _mintAccessToken() async {
    // Step 1: Define Service Account Credentials
    // This is like a "robot account" that has permission to send notifications
    // Credentials come from --dart-define via AppKeys; the service-account
    // private key used to be a literal in this file. See app_keys.dart.
    final Map<String, String> serviceAccountJson =
        AppKeys.fcmServiceAccountJson();

    // Step 2: Define required permissions (scopes)
    final List<String> scopes = AppKeys.fcmScopes;

    // Step 3: Create authenticated HTTP client
    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    try {
      // Step 4: Get access credentials (token)
      auth.AccessCredentials credentials =
          await auth.obtainAccessCredentialsViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
        client,
      );

      _cachedCredentials = credentials;
      return credentials.accessToken.data; // Return the access token
    } finally {
      // Step 5: Close the client whatever happened — it leaked on every throw.
      client.close();
    }
  }

  // ═══════════════════════════════════════════════════════════
  // ✅ NEW HELPER METHOD: Sanitize Email for Topic
  // ═══════════════════════════════════════════════════════════

  static String sanitizeEmailForTopic(String email) {
    return email
        .trim()
        .toLowerCase()
        .replaceAll('@', '_at_')
        .replaceAll('.', '_dot_')
        .replaceAll('+', '_plus_')
        .replaceAll(' ', '_');
  }

  // ═══════════════════════════════════════════════════════════
  // METHOD 2: Send Notification (FIXED)
  // ═══════════════════════════════════════════════════════════

  /// [moduleKey] / [pageKey] (ADDED 16/9/2026) travel in the push `data`
  /// block as `module` / `name_of_page` — the same values the in-app record
  /// stores — so a tapped push can be routed to the module that sent it
  /// instead of always to the Services screen. Both are optional; older
  /// callers keep working unchanged.
  static Future<void> sendNotification(
      String title,
      String body,
      String? channel, {  // Can be email or topic name
      String moduleKey = '',
      String pageKey = '',
      }) async
  {

    // Step 1: Get authentication token
    final String accessToken = await getAccessToken();

    if (accessToken.isEmpty) {
      return;
    }


    // ✅ Step 2: Sanitize the channel (convert email to valid topic name)
    String topicName = "news";  // Default topic

    if (channel != null && channel.isNotEmpty) {
      // Check if channel looks like an email (contains @)
      if (channel.contains('@')) {
        topicName = sanitizeEmailForTopic(channel);
      } else {
        // Already a topic name
        topicName = channel;
      }
    } else {
    }

    // Step 3: Define FCM endpoint URL
    String endpointFCM = 'https://fcm.googleapis.com/v1/projects/knowticed-v2-scheme/messages:send';

    // Step 4: Create notification message
    final Map<String, dynamic> message = {
      "message": {
        "topic": topicName,  // ✅ Use sanitized topic name
        "notification": {
          "title": title,  // Notification title
          "body": body     // Notification content
        },
        "data": {
          // Kept for existing handlers; module/page below are the real hint.
          "route": moduleKey.isEmpty ? "serviceScreen" : moduleKey,
          if (moduleKey.isNotEmpty) "module": moduleKey,
          if (pageKey.isNotEmpty) "name_of_page": pageKey,
        }
      }
    };


    try {
      // Step 5: Send HTTP POST request to Firebase
      final http.Response response = await http.post(
        Uri.parse(endpointFCM),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'  // Authenticate with token
        },
        body: jsonEncode(message),  // Convert message to JSON
      );

      // Step 6: Handle response

      // FIXED 16/9/2026 — both outcomes were swallowed silently, so a
      // rejected push (bad topic, expired key, wrong project) looked exactly
      // like a delivered one. Failures are now logged; the in-app record is
      // unaffected either way.
      if (response.statusCode == 200) {
        debugPrint('[fcm] push sent to topic "$topicName"'
            '${moduleKey.isEmpty ? '' : ' (module=$moduleKey)'}');
      } else {
        debugPrint('[fcm] push REJECTED for topic "$topicName" — '
            'HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e, stackTrace) {
      debugPrint('[fcm] push FAILED for topic "$topicName" — $e\n$stackTrace');
    }

  }
}