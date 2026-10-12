/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: firebase_notification_handler.dart
/// Purpose: FCM token handling and message routing.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - Added the standard header. The Admin private key this held was removed in
///          round 3.
///
/// REMAINING (CR-SKEL-NOTIF-N18): this folder is a non-canonical `services/` at
/// the feature root, and this file is consumed cross-feature by
/// `login_controller.dart` — it is shared infrastructure and belongs in
/// `core/services/`. This pass may not add files under `lib/core`.

import 'dart:convert';

import 'package:crypto/crypto.dart'; // for sha256
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:knowticed_plus/core/constants/app_keys.dart';

class FirebaseNotificationHandler {
  static Future<String> getAccessToken() async {
    // Credentials come from --dart-define via AppKeys; the service-account
    // private key used to be a literal in this file. See app_keys.dart.
    final Map<String, String> serviceAccountJson =
        AppKeys.fcmServiceAccountJson();

    final List<String> scopes = AppKeys.fcmScopes;

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
      client,
    );

    client.close();
    return credentials.accessToken.data;
  }

  static Future<void> sendNotification(String title, String body,
      List<String> usersIds, Map<String, dynamic> notificationData) async {
    final String accessToken = await getAccessToken();
    List<String> hashedIds = _idsHashing(usersIds);
    if (accessToken.isEmpty) {
      return;
    }


    String endpointFCM =
        'https://fcm.googleapis.com/v1/projects/knowticed-v2-scheme/messages:send';
    for (String id in hashedIds) {
      final Map<String, dynamic> message = {
        "message": {
          "topic": id,
          "notification": {"title": title, "body": body},
          "data": notificationData
        }
      };

      try {
        final http.Response response = await http.post(
          Uri.parse(endpointFCM),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken'
          },
          body: jsonEncode(message),
        );


        if (response.statusCode == 200) {
        } else {
        }
      } catch (e) {
      }
    }
  }

  static List<String> _idsHashing(List<String> ids) {
    List<String> hashedIds = [];
    for (String id in ids) {
      String hashedId = sha256.convert(utf8.encode(id)).toString();
      hashedIds.add(hashedId);
    }
    return hashedIds;
  }

  static Future<void> subscribeToTopic(String email) async {
    String topic = _idsHashing([email])[0];
    await FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  /// ✨Unsubscribe from a topic.⭐
  /// This will remove the user from a topic, and they will stop receiving notifications
  /// for that topic.
  static Future<void> unsubscribeFromTopic(String email) async {
    String topic = _idsHashing([email])[0];
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }
}
