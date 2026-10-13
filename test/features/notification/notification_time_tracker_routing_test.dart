/// Module: notification / test
///
///*************************** FILE INFO ****************************///
/// File Name: notification_time_tracker_routing_test.dart
/// Purpose: Pins the Time Tracker notification wiring (phase 4): stored
///          `time_tracker` (and the legacy `tracking`) open the real
///          `Modules.timeTracker`; View on a notification with a
///          `Request_Id` opens that request — as the approver when its page
///          is `TimeTrackerApprovalDetails`, else as the requester — and the
///          catalogue (Notification Control tab) carries the events.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026

import 'package:flutter_test/flutter_test.dart';
import 'package:knowticed_plus/core/enums/app_module.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/notification/data/models/notification_data_model.dart';
import 'package:knowticed_plus/features/notification/domain/enums/notification_catalog.dart';
import 'package:knowticed_plus/features/notification/domain/enums/time_tracker_module/time_tracker_events.dart';
import 'package:knowticed_plus/features/notification/domain/enums/time_tracker_module/time_tracker_notification_pages.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_card.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_routing.dart';

NotificationModelSystem _doc({String page = 'TimeTrackerRequestDetails', String? id = 'req-7'}) =>
    NotificationModelSystem.fromMap(<String, dynamic>{
      'title': 'Request Approved',
      'body': 'Your Sick Leave request has been reviewed and formally approved.',
      'Name_of_module': 'time_tracker',
      'name_of_page': page,
      'Sender_Email': 'hr@co.com',
      'Reciver_Email': 'me@co.com',
      'timestamp': 1791386013886,
      if (id != null) 'Request_Id': id,
    });

void main() {
  group('module resolution', () {
    test('time_tracker and the legacy tracking open Modules.timeTracker (with its icon)', () {
      expect(NotificationRouting.moduleForStoredKey('time_tracker'), Modules.timeTracker);
      expect(NotificationRouting.moduleForStoredKey('tracking'), Modules.timeTracker);
      expect(NotificationCard.moduleIconPath('time_tracker'), Modules.timeTracker.iconPath);
    });
  });

  group('timeTrackerLinkFor', () {
    test('requester page → the requester details of that request', () {
      final TimeTrackerNotificationLink? link =
          NotificationRouting.timeTrackerLinkFor(_doc(), Modules.timeTracker);
      expect(link?.requestId, 'req-7');
      expect(link?.asApproval, isFalse);
    });

    test('approval page → the approver details', () {
      final TimeTrackerNotificationLink? link = NotificationRouting.timeTrackerLinkFor(
        _doc(page: TimeTrackerNotificationPage.approvalDetails.key),
        Modules.timeTracker,
      );
      expect(link?.asApproval, isTrue);
    });

    test('no id, or another module → null (the module main page / not ours)', () {
      expect(NotificationRouting.timeTrackerLinkFor(_doc(id: null), Modules.timeTracker), isNull);
      expect(NotificationRouting.timeTrackerLinkFor(_doc(), Modules.todo), isNull);
      expect(NotificationRouting.todoIdFor(_doc(), Modules.timeTracker), isNull);
    });
  });

  group('catalogue', () {
    // Updated 9/10/2026 (phase 6): + missed_check_out → 17.
    test('the Time Tracker tab carries the 15 events + request_canceled + missed_check_out + the 5 server keys', () {
      expect(NotificationCatalog.modules, contains(AppModule.timeTracker));
      expect(NotificationCatalog.eventsOf(AppModule.timeTracker), TimeTrackerNotificationEvent.values);
      // 13/10/2026: + pending_approvals, break_policy_violation_manager,
      // pause_duration_exceeded, shift_start_reminder, shift_end_reminder.
      expect(TimeTrackerNotificationEvent.values, hasLength(22));
      for (final String key in <String>[
        'pending_approvals',
        'break_policy_violation_manager',
        'pause_duration_exceeded',
        'shift_start_reminder',
        'shift_end_reminder',
      ]) {
        expect(TimeTrackerNotificationEvent.fromKey(key), isNotNull, reason: key);
      }
      expect(
        NotificationCatalog.find(module: AppModule.timeTracker, key: 'request_canceled'),
        TimeTrackerNotificationEvent.requestCanceled,
      );
      for (final TimeTrackerNotificationEvent e in TimeTrackerNotificationEvent.values) {
        expect('${e.titleEn} ${e.bodyEn}', isNot(contains('Name Of Service')), reason: e.key);
      }
    });

    test('page keys round-trip', () {
      for (final TimeTrackerNotificationPage p in TimeTrackerNotificationPage.values) {
        expect(TimeTrackerNotificationPage.fromKey(p.key), p);
      }
      expect(TimeTrackerNotificationPage.fromKey('nope'), isNull);
    });
  });
}
