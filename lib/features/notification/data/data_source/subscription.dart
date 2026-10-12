/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: subscription.dart
/// Purpose: Topic subscription for push notifications.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - CR-SKEL-NOTIF-N20: renamed from `subsecration.dart`.

import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/controller/settings_controller.dart';

class FCMSubscriptionService {

  /// Subscribe current logged-in user to their personal notification channel
  /// ✅ UPDATED: Handle platform-specific token requirements
  static Future<void> subscribeToPersonalChannel({String? userEmail}) async {
    try {

      String? email;

      // ✅ Option 1: Use provided email
      if (userEmail != null && userEmail.isNotEmpty) {
        email = userEmail;
      }
      // ✅ Option 2: Try to get from SettingsController
      else {
        try {
          SettingsController settingsController = Get.find<SettingsController>();

          if (settingsController.employee == null) {
            return;
          }

          if (settingsController.employee!.email == null ||
              settingsController.employee!.email!.isEmpty ||
              settingsController.employee!.email!.last == null) {
            return;
          }

          email = settingsController.employee!.email!.last!;
        } catch (e) {
          return;
        }
      }

      if (email == null || email.isEmpty) {
        return;
      }

      // ✅ PLATFORM-SPECIFIC: Wait for APNS token on iOS/macOS
      // ✅ PLATFORM-SPECIFIC: Wait for APNS token on iOS/macOS with retries
      if (Platform.isIOS || Platform.isMacOS) {
        // print('🍎 Apple platform detected - waiting for APNS token...');
        //
        // String? apnsToken;
        // int retries = 0;
        // const maxRetries = 5;
        //
        // while (apnsToken == null && retries < maxRetries) {
        //   try {
        //     apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        //
        //     if (apnsToken == null) {
        //       retries++;
        //       if (retries < maxRetries) {
        //         final delay = Duration(seconds: retries * 2); // Exponential backoff
        //         print('⏳ Retry $retries/$maxRetries - waiting ${delay.inSeconds}s for APNS token...');
        //         await Future.delayed(delay);
        //       }
        //     } else {
        //       print('✅ APNS token acquired after $retries retries: ${apnsToken.substring(0, 10)}...');
        //     }
        //   } catch (e) {
        //     retries++;
        //     if (retries < maxRetries) {
        //       print('⚠️ Error getting APNS token (attempt $retries/$maxRetries): $e');
        //       await Future.delayed(Duration(seconds: retries * 2));
        //     }
        //   }
        // }
        //
        // if (apnsToken == null) {
        //   print('⚠️ APNS token not available after $maxRetries retries');
        //   print('💡 Subscription will be attempted anyway, but may fail on macOS');
        // }
      }

      // Generate topic name (same format as in CSV upload)
      String topicName = email
          .trim()
          .toLowerCase()
          .replaceAll('@', '_at_')
          .replaceAll('.', '_dot_')
          .replaceAll('+', '_plus_')
          .replaceAll(' ', '_');


      // Subscribe to personal notification channel
      await FirebaseMessaging.instance.subscribeToTopic(topicName);


    } catch (e, stackTrace) {
      // Don't throw - subscription failure shouldn't crash the app
    }
  }

  /// Subscribe to the general "App" broadcast channel
  static Future<void> subscribeToAppChannel() async {
    try {

      // ✅ PLATFORM-SPECIFIC: Wait for APNS token on iOS/macOS
      if (Platform.isIOS || Platform.isMacOS) {
        await Future.delayed(const Duration(seconds: 1));
      }

      await FirebaseMessaging.instance.subscribeToTopic('App');
    } catch (e) {
    }
  }

  /// Unsubscribe from personal channel (call this on logout)
  static Future<void> unsubscribeFromPersonalChannel({String? userEmail}) async {
    try {
      String? email;

      if (userEmail != null && userEmail.isNotEmpty) {
        email = userEmail;
      } else {
        try {
          SettingsController settingsController = Get.find<SettingsController>();

          if (settingsController.employee == null ||
              settingsController.employee!.email == null ||
              settingsController.employee!.email!.isEmpty) {
            return;
          }

          email = settingsController.employee!.email!.last!;
        } catch (e) {
          return;
        }
      }

      if (email == null || email.isEmpty) {
        return;
      }

      String topicName = email
          .trim()
          .toLowerCase()
          .replaceAll('@', '_at_')
          .replaceAll('.', '_dot_')
          .replaceAll('+', '_plus_')
          .replaceAll(' ', '_');

      await FirebaseMessaging.instance.unsubscribeFromTopic(topicName);


    } catch (e) {
    }
  }

  /// Unsubscribe from App channel
  static Future<void> unsubscribeFromAppChannel() async {
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic('App');
    } catch (e) {
    }
  }
}
