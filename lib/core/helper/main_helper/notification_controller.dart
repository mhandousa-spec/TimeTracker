/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: notification_controller.dart
/// Purpose: Declares `NotificationController` — the Settings > Notification
///          switch's stored state.
/// Author: Knowticed Plus team
/// Created at: 31/8/2026
///
/// ADDED 31/8/2026 to back the "Notification" row the Figma settings design
/// shows under Animation. Deliberately a straight copy of
/// [BiometricController]'s shape: one GetStorage-backed RxBool, default ON for
/// an employee who has never touched it, so the switch reads the same on a
/// fresh install as it does after a restart.
///
/// SCOPE: this stores the employee's PREFERENCE and nothing else. No FCM
/// topic is subscribed or unsubscribed here and no notification is suppressed
/// by it — when the delivery side lands, read [isNotificationEnabled] there
/// rather than adding a second flag.
///
/// The storage handle is private on purpose. `biometric_controller.dart`
/// declares a top-level `storage`, and both files are imported into
/// `settings_layout.dart`; a second public `storage` would make the name
/// ambiguous across those imports.

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

final GetStorage _storage = GetStorage();

class NotificationController extends GetxController {
  /// The GetStorage key. Kept as a constant so a future migration can find
  /// every reader instead of grepping for the string.
  static const String notificationKey = 'Notification';

  RxBool isNotificationEnabled = _storage.read(notificationKey) == null
      ? true.obs
      : _storage.read(notificationKey) == true
          ? true.obs
          : false.obs;

  void toggleNotification(bool value) {
    isNotificationEnabled.value = value;
    _storage.write(notificationKey, value);
    update();
  }
}
