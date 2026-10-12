/// Module: test / notification
///
///*************************** FILE INFO ****************************///
/// File Name: notification_edit_layout_test.dart
/// Purpose: Time Tracker QA KP-TT-018 (9/10/2026): the Notification Control
///          edit panel's Preview · Discard · Save row and its "Notification
///          Status" + "Reset Default Messages" row always fit — iPad
///          portrait (the 191 px overflow), iPad landscape and iPhone,
///          English and Arabic. Any overflow fails the test.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_edit_layout.dart';

const ValueKey<String> _preview = ValueKey<String>('preview');
const ValueKey<String> _discard = ValueKey<String>('discard');
const ValueKey<String> _save = ValueKey<String>('save');

/// Screen, ScreenUtil design size (main.dart ladder) and the panel width.
typedef _Case = ({String name, Size screen, Size design, double panel, bool arabic});

const List<_Case> _cases = <_Case>[
  // iPad Air 11" portrait: the right panel QA measured (row 493 px − 191 px).
  (name: 'iPad portrait EN', screen: Size(820, 1180), design: Size(768, 1024), panel: 302, arabic: false),
  (name: 'iPad portrait AR', screen: Size(820, 1180), design: Size(768, 1024), panel: 302, arabic: true),
  (name: 'iPad landscape EN', screen: Size(1180, 820), design: Size(1024, 768), panel: 700, arabic: false),
  (name: 'iPhone EN', screen: Size(390, 844), design: Size(375, 812), panel: 330, arabic: false),
  (name: 'iPhone AR narrow', screen: Size(390, 844), design: Size(375, 812), panel: 200, arabic: true),
];

/// [child] is built INSIDE ScreenUtilInit (the app's `.sp` text styles).
Widget _app(_Case c, Widget Function() child) => ScreenUtilInit(
      designSize: c.design,
      builder: (_, __) => MaterialApp(
        home: Directionality(
          textDirection: c.arabic ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            body: Align(
              alignment: AlignmentDirectional.topStart,
              child: SizedBox(width: c.panel, child: child()),
            ),
          ),
        ),
      ),
    );

NotificationEditActions _actions(_Case c, VoidCallback onSave) {
  final TextStyle style = StyleText.fontSize18Weight500;
  return NotificationEditActions(
    start: <NotificationEditAction>[
      NotificationEditAction(key: _preview, title: c.arabic ? 'معاينة' : 'Preview', onTap: () {}, color: AppColors.grey, textStyle: style),
      NotificationEditAction(key: _discard, title: c.arabic ? 'تجاهل' : 'Discard', onTap: () {}, color: AppColors.darkGrey, textStyle: style),
    ],
    end: NotificationEditAction(key: _save, title: c.arabic ? 'حفظ' : 'Save', onTap: onSave, color: AppColors.primary, textStyle: style),
  );
}

void main() {
  test('layout choice: spread when 3 × 150.w fit, shared when the labels fit, else stacked', () {
    NotificationEditActionsLayout at(double w) => NotificationEditActions.layoutFor(
          maxWidth: w,
          count: 3,
          hasEnd: true,
          ideal: 160,
          gap: 12.8,
          longestLabel: 90,
        );
    expect(at(800), NotificationEditActionsLayout.spread);
    expect(at(302), NotificationEditActionsLayout.shared, reason: 'iPad portrait panel — was a 191 px overflow');
    expect(at(200), NotificationEditActionsLayout.stacked);
  });

  for (final _Case c in _cases) {
    testWidgets('Preview · Discard · Save fit and Save is reachable (${c.name})', (WidgetTester tester) async {
      tester.view.physicalSize = c.screen;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      int taps = 0;
      await tester.pumpWidget(_app(c, () => _actions(c, () => taps++)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'no RenderFlex overflow');

      final Rect panel = tester.getRect(find.byType(NotificationEditActions));
      for (final ValueKey<String> k in <ValueKey<String>>[_preview, _discard, _save]) {
        final Rect r = tester.getRect(find.byKey(k));
        expect(r.left >= panel.left - 0.5 && r.right <= panel.right + 0.5, isTrue, reason: '$k inside the panel ${c.name}');
        expect(r.width, greaterThan(40));
      }
      await tester.tap(find.byKey(_save));
      await tester.pump(const Duration(milliseconds: 50));
      expect(taps, 1, reason: 'Save works');
      // Landscape keeps the Figma layout: Save at the far end, 150.w wide.
      if (c.panel >= 700) {
        expect(tester.getRect(find.byKey(_save)).right, closeTo(panel.right, 0.5));
        expect(tester.getRect(find.byKey(_preview)).width, closeTo(tester.getRect(find.byKey(_save)).width, 0.5));
      }
      // Very narrow: one button per line, Save last.
      if (c.panel <= 200) {
        expect(tester.getRect(find.byKey(_save)).top, greaterThan(tester.getRect(find.byKey(_discard)).bottom - 0.5));
      }
    });

    testWidgets('"Notification Status" + switch + Reset Default Messages never overflow (${c.name})',
        (WidgetTester tester) async {
      tester.view.physicalSize = c.screen;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_app(
        c,
        () => Builder(
          builder: (BuildContext context) => NotificationStatusHeader(
            icon: const SizedBox(width: 16, height: 16, key: ValueKey<String>('icon')),
            title: Text(c.arabic ? 'حالة الإشعار' : 'Notification Status', style: StyleText.fontSize18Weight500),
            toggle: const SizedBox(width: 38, height: 22, key: ValueKey<String>('toggle')),
            trailing: SizedBox(
              key: const ValueKey<String>('reset'),
              width: 220.w,
              height: 30.h,
              child: const ColoredBox(color: Colors.amber),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'no overflow (was 13 px on iPad portrait)');
      final Rect panel = tester.getRect(find.byType(NotificationStatusHeader));
      final Rect reset = tester.getRect(find.byKey(const ValueKey<String>('reset')));
      expect(reset.right <= panel.right + 0.5 && reset.left >= panel.left - 0.5, isTrue);
      final Rect toggle = tester.getRect(find.byKey(const ValueKey<String>('toggle')));
      if (c.panel < 400) {
        expect(reset.top, greaterThanOrEqualTo(toggle.bottom - 0.5), reason: 'moves to its own line');
      }
    });
  }
}
