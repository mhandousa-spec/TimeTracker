/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: demo_accounts_seeder.dart
/// Purpose: "Apply all modules" — fire every notification and every calendar
///          event of every module at the demo accounts.
/// Author: Knowticed Plus team
/// Created at: 27/9/2026
///
/// Driven by the button on Home (`ApplyAllModulesButton`). One call to
/// [DemoAccountsSeeder.applyAll]:
///
///   1. NOTIFICATIONS — walks `NotificationCatalog.allEvents` (every module:
///      Knowledge Hub, To-Do, Services, Roles, User Access, User Management,
///      Time Tracker, Database, Qiyas, GRC, Settings, Notification Control,
///      Messages) and sends each one to each account through
///      `AppNotificationSender.sendEvent`, so the real template (admin text
///      from Notification Control if it exists, the enum default otherwise)
///      is used and the in-app document lands in the normal Notifications
///      collection.
///
///   2. CALENDAR — walks `CalendarCatalog.allEvents` and writes one document
///      per (account, event type) to [CalendarDataService.seededEventsPath].
///      `CalendarCubit` reads that collection as its own source, so every
///      calendar event type shows on the account's calendar, spread over the
///      next two weeks.
///
/// Re-running is safe for the calendar: document ids are
/// `<email>_<typeId>`, so a second run overwrites instead of duplicating.
/// Notifications are new documents on every run (that is what a real event
/// does too).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:knowticed_plus/core/enums/app_module.dart';
import 'package:knowticed_plus/core/enums/template_variable_samples.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/data/data_source/calendar_data_service.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/domain/enums/calendar_catalog.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/domain/enums/calendar_event_type.dart';
import 'package:knowticed_plus/features/notification/domain/enums/database_module/database_notification_pages.dart';
import 'package:knowticed_plus/features/notification/domain/enums/grc_module/grc_notification_pages.dart';
import 'package:knowticed_plus/features/notification/domain/enums/knowledge_hub_module/knowledge_hub_notification_pages.dart';
import 'package:knowticed_plus/features/notification/domain/enums/messages_module/messages_notification_pages.dart';
import 'package:knowticed_plus/features/notification/domain/enums/notification_catalog.dart';
import 'package:knowticed_plus/features/notification/domain/enums/notification_event.dart';
import 'package:knowticed_plus/features/notification/domain/enums/role_module/role_management_module/role_management_notification_pages.dart';
import 'package:knowticed_plus/features/notification/domain/enums/role_module/user_access_module/user_access_notification_pages.dart';
import 'package:knowticed_plus/features/notification/domain/enums/role_module/user_management_module/user_management_notification_pages.dart';
import 'package:knowticed_plus/features/notification/domain/enums/services_module/services_notification_pages.dart';
import 'package:knowticed_plus/features/notification/domain/enums/settings_module/settings_notification_pages.dart';
import 'package:knowticed_plus/features/notification/services/app_notification_sender.dart';

/// What one [DemoAccountsSeeder.applyAll] run did.
class DemoSeedResult {
  const DemoSeedResult({
    required this.notificationsSent,
    required this.notificationsAttempted,
    required this.calendarEventsWritten,
    required this.calendarEventsAttempted,
  });

  final int notificationsSent;
  final int notificationsAttempted;
  final int calendarEventsWritten;
  final int calendarEventsAttempted;

  bool get isFullSuccess =>
      notificationsSent == notificationsAttempted &&
      calendarEventsWritten == calendarEventsAttempted;

  bool get isTotalFailure => notificationsSent == 0 && calendarEventsWritten == 0;

  @override
  String toString() =>
      'notifications $notificationsSent/$notificationsAttempted, '
      'calendar $calendarEventsWritten/$calendarEventsAttempted';
}

abstract final class DemoAccountsSeeder {
  /// The accounts that receive everything. Stored lower-case, because the
  /// notification queries compare `Reciver_Email` against
  /// `receiverEmail.toLowerCase()`.
  static const List<String> accounts = <String>[
    'ibrahim_mansour_1211@knowticedplus.com',
    'nasser_rashid_0808@knowticedplus.com',
    'yousef_jamal_2508@knowticedplus.com',
    'demo@knowticedplus.com',
  ];

  /// Whether [email] is one of [accounts].
  static bool isDemoAccount(String? email) =>
      email != null && accounts.contains(email.trim().toLowerCase());

  /// Also send an FCM push for each notification. Off by default: a full run
  /// is ~every event × 4 accounts, and that many pushes at once only floods
  /// the devices. The in-app notification is written either way.
  static const bool sendPush = false;

  /// How many notification sends run at once.
  static const int _notificationChunk = 20;

  /// Firestore allows 500 writes per batch.
  static const int _batchLimit = 450;

  /// Default notification page per module, so tapping a seeded notification
  /// opens somewhere sensible. Modules without a page enum get '' (the deep
  /// link then falls back to the module itself).
  static String pageKeyFor(AppModule module) {
    switch (module) {
      case AppModule.knowledgeHub:
        return KnowledgeHubNotificationPage.viewKnowledgeHub.key;
      case AppModule.services:
        return ServicesNotificationPage.requestServicesToggle.key;
      case AppModule.roleManagement:
        return RoleManagementNotificationPage.roleScreen.key;
      case AppModule.userAccess:
        return UserAccessNotificationPage.userAccessHomePage.key;
      case AppModule.userManagement:
        return UserManagementNotificationPage.roleEmployeeDetailsPage.key;
      case AppModule.database:
        return DatabaseNotificationPage.databaseBuilderPage.key;
      case AppModule.grc:
        return GrcNotificationPage.grcModules.key;
      case AppModule.settings:
        return SettingsNotificationPage.personalInfoScreen.key;
      case AppModule.messages:
        return MessagesNotificationPage.messagingHome.key;
      default:
        return '';
    }
  }

  /// Function Name: [applyAll]
  ///
  /// Purpose: send every notification and write every calendar event of every
  /// module to every account in [accounts].
  ///
  /// Parameters:
  /// - [senderEmail]: the signed-in user, recorded as the sender.
  /// - [isArabic]: passed through to the sender (both languages are stored).
  static Future<DemoSeedResult> applyAll({
    required String senderEmail,
    required bool isArabic,
  }) async {
    final List<(int, int)> results = await Future.wait(<Future<(int, int)>>[
      _applyNotifications(senderEmail: senderEmail, isArabic: isArabic),
      _applyCalendar(),
    ]);
    final (int sent, int attempted) = results[0];
    final (int written, int total) = results[1];

    final DemoSeedResult result = DemoSeedResult(
      notificationsSent: sent,
      notificationsAttempted: attempted,
      calendarEventsWritten: written,
      calendarEventsAttempted: total,
    );
    debugPrint('[demo-seed] done — $result');
    return result;
  }

  // ───────────────────────────── notifications ─────────────────────────────

  static Future<(int, int)> _applyNotifications({
    required String senderEmail,
    required bool isArabic,
  }) async {
    final DateTime now = DateTime.now();
    final List<Future<bool> Function()> jobs = <Future<bool> Function()>[];

    for (final NotificationEvent event in NotificationCatalog.allEvents) {
      final values = event.variables.toSampleValues(now: now);
      for (final String account in accounts) {
        jobs.add(() => AppNotificationSender.sendEvent(
              event: event,
              pageKey: pageKeyFor(event.module),
              senderEmail: senderEmail,
              receiverEmail: account,
              isArabic: isArabic,
              variables: values,
              sendPush: sendPush,
            ));
      }
    }

    int sent = 0;
    for (int i = 0; i < jobs.length; i += _notificationChunk) {
      final int end =
          (i + _notificationChunk) > jobs.length ? jobs.length : i + _notificationChunk;
      final List<bool> chunk =
          await Future.wait(jobs.sublist(i, end).map((job) => job()));
      sent += chunk.where((bool ok) => ok).length;
    }
    debugPrint('[demo-seed] notifications $sent/${jobs.length}');
    return (sent, jobs.length);
  }

  // ─────────────────────────────── calendar ────────────────────────────────

  static Future<(int, int)> _applyCalendar() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference<Map<String, dynamic>> collection = firestore
        .collection(getBaseUrl(CalendarDataService.seededEventsPath));

    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final List<CalendarEventType> types = CalendarCatalog.allEvents;

    final List<MapEntry<String, Map<String, dynamic>>> docs =
        <MapEntry<String, Map<String, dynamic>>>[];

    for (int i = 0; i < types.length; i++) {
      final CalendarEventType type = types[i];
      // Spread the entries over today .. today+13 so the month is readable,
      // and back the reminder offset out so the card lands on that day.
      final DateTime shownOn = today.add(Duration(days: i % 14, hours: 9 + i % 8));
      final DateTime sourceDate =
          shownOn.subtract(Duration(days: type.reminderOffsetDays));

      for (final String account in accounts) {
        docs.add(MapEntry<String, Map<String, dynamic>>(
          '${account}_${type.id}',
          <String, dynamic>{
            'receiverEmail': account,
            'typeId': type.id,
            'module': type.module.key,
            'sourceDate': Timestamp.fromDate(sourceDate),
            'createdAt': FieldValue.serverTimestamp(),
          },
        ));
      }
    }

    int written = 0;
    for (int i = 0; i < docs.length; i += _batchLimit) {
      final int end =
          (i + _batchLimit) > docs.length ? docs.length : i + _batchLimit;
      final WriteBatch batch = firestore.batch();
      for (final MapEntry<String, Map<String, dynamic>> doc
          in docs.sublist(i, end)) {
        batch.set(collection.doc(doc.key), doc.value);
      }
      try {
        await batch.commit();
        written += end - i;
      } catch (e, stackTrace) {
        debugPrint('[demo-seed] calendar batch $i-$end FAILED — $e\n$stackTrace');
      }
    }
    debugPrint('[demo-seed] calendar $written/${docs.length}');
    return (written, docs.length);
  }
}
