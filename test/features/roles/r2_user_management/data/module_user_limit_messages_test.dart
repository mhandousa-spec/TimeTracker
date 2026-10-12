/// Module: test / roles / r2_user_management / data
///
///*************************** FILE INFO ****************************///
/// File Name: module_user_limit_messages_test.dart
/// Purpose: The EN/AR user-limit messages name the module and the limit,
///          e.g. "Time Tracker allows 10 users. 10 are already assigned."
/// Author: Knowticed Plus team
/// Created at: 9/10/2026

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/data/services/module_user_limit_messages.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/domain/services/module_user_limit_rule.dart';
import 'package:knowticed_plus/generated/l10n.dart';

const LimitViolation fullTimeTracker = LimitViolation(
  kind: LimitViolationKind.module,
  module: 'tracking', // Admin's licence key — must still read "Time Tracker"
  limit: 10,
  assigned: 10,
  requested: 11,
);

const LimitViolation overshoot = LimitViolation(
  kind: LimitViolationKind.module,
  module: 'time_tracker',
  limit: 10,
  assigned: 8,
  requested: 11,
);

const LimitViolation fullCompany = LimitViolation(
  kind: LimitViolationKind.totalUsers,
  limit: 20,
  assigned: 20,
  requested: 21,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('English', () {
    setUpAll(() => S.load(const Locale('en')));

    test("the owner's example, word for word", () {
      expect(ModuleUserLimitMessages.violation(fullTimeTracker),
          'Time Tracker allows 10 users. 10 are already assigned.');
    });

    test('a selection that overshoots says how many seats are left', () {
      expect(ModuleUserLimitMessages.violation(overshoot),
          'Time Tracker allows 10 users. 8 are already assigned. Only 2 more can be added.');
    });

    test('company total', () {
      expect(ModuleUserLimitMessages.violation(fullCompany),
          'Your plan allows 20 users. 20 are already assigned.');
    });

    test('several violations, one per line', () {
      expect(
          ModuleUserLimitMessages.verdict(
              const LimitVerdict(<LimitViolation>[fullTimeTracker, fullCompany])),
          'Time Tracker allows 10 users. 10 are already assigned.\n'
          'Your plan allows 20 users. 20 are already assigned.');
    });

    test('usage lines', () {
      expect(
          ModuleUserLimitMessages.usage(const ModuleUsage(
              module: 'time_tracker', assigned: 8, limit: 10)),
          'Time Tracker: 8 of 10 users');
      expect(
          ModuleUserLimitMessages.usage(
              const ModuleUsage(assigned: 18, limit: 20)),
          'Users: 18 of 20');
    });

    test('module names come from the app labels, any spelling', () {
      expect(ModuleUserLimitMessages.moduleName('database'), 'Database Builder');
      expect(ModuleUserLimitMessages.moduleName('form_builder'), 'Form Builder');
      expect(ModuleUserLimitMessages.moduleName('knowledge_hub'), 'Knowledge Hub');
      expect(ModuleUserLimitMessages.moduleName('services'), 'Services');
    });

    test('the failure carries the message and the verdict', () {
      final ModuleUserLimitFailure failure = ModuleUserLimitFailure(
          const LimitVerdict(<LimitViolation>[fullTimeTracker]));
      expect(failure.errMessage,
          'Time Tracker allows 10 users. 10 are already assigned.');
      expect(failure.verdict.allowed, isFalse);
    });
  });

  group('Arabic', () {
    setUpAll(() => S.load(const Locale('ar')));
    tearDownAll(() => S.load(const Locale('en')));

    test('module, limit and count — Arabic-Indic digits, no tanween', () {
      final String text = ModuleUserLimitMessages.violation(fullTimeTracker);
      expect(text, 'الحد الأقصى لمستخدمي تتبع الوقت هو ١٠، وتم تعيين ١٠ بالفعل.');
      expect(RegExp('[ً-ٍ]').hasMatch(text), isFalse);
    });

    test('usage line', () {
      expect(
          ModuleUserLimitMessages.usage(const ModuleUsage(
              module: 'time_tracker', assigned: 8, limit: 10)),
          'تتبع الوقت: ٨ من أصل ١٠');
    });
  });
}
