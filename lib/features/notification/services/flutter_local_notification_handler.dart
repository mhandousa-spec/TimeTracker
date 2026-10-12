/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: flutter_local_notification_handler.dart
/// Purpose: Shows a local (foreground) notification.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - Added the standard header (Docs). See the placement note in
///          `firebase_notification_handler.dart`.

import 'dart:convert';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class FlutterLocalNotificationHandler {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// A single, STABLE Android channel for every app notification.
  ///
  /// The id and name used to be `Random().nextInt(99999).toString()`, so every
  /// notification created a brand-new channel. On Android 8+ a channel is a
  /// permanent, user-visible setting: the app accumulated thousands of them,
  /// the importance/priority set at creation only applied to the first, and the
  /// user could not meaningfully mute or manage the app's notifications. One
  /// fixed channel fixes all three.
  static const String _channelId = 'knowticed_plus_default';
  static const String _channelName = 'General Notifications';
  static const String _channelDescription =
      'General notifications from Knowticed Plus';

  /// ✨Initialize the local notification plugin.⭐
  /// Called once when the app starts to initialize the local notification
  /// plugin. This sets up the plugin to work on both Android and iOS and
  /// sets up the callbacks for when the user taps on a notification.
  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      /*onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {}*/
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        /* selectNotificationStream.add(notificationResponse.payload);*/
      },
      /* onDidReceiveBackgroundNotificationResponse: notificationTapBackground,*/
    );
  }

  static Future<void> showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: "default",
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: darwinNotificationDetails,
    );

    // Prefer the message's own `notification` block — every push the app sends
    // (see NotificationServiceApp.sendNotification) carries title/body there,
    // and `data` holds only routing info like `route`. The old code read
    // `data['English_Title'] / ['English_Body']`, keys that are never present,
    // so foreground notifications showed a blank title and body. The localized
    // `*_Title` / `*_Body` data keys are kept as a fallback for any sender that
    // does populate them.
    //
    // `Get.deviceLocale` was force-unwrapped (`!`); it is null before GetX is
    // initialized (e.g. in the background isolate), which threw and was
    // swallowed by the catch — the notification simply never appeared. Read it
    // null-safely instead.
    final bool isArabic = Get.deviceLocale?.languageCode == 'ar';
    final Map<String, dynamic> data = message.data;

    final String? title = message.notification?.title ??
        (isArabic ? data['Arabic_Title'] : data['English_Title'])
            as String?;
    final String? body = message.notification?.body ??
        (isArabic ? data['Arabic_Body'] : data['English_Body']) as String?;

    try {
      await flutterLocalNotificationsPlugin.show(
        // 31-bit id: Android notification ids must fit in a signed 32-bit int,
        // and a wider range risks a duplicate id replacing a live notification.
        id: Random().nextInt(1 << 30),
        title: title,
        body: body,
        notificationDetails: platformChannelSpecifics,
        payload: jsonEncode(message.data),
      );
    } catch (e) {
    }
  }
}
