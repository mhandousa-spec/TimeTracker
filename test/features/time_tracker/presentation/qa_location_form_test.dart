/// Module: test / time_tracker / presentation
///
///*************************** FILE INFO ****************************///
/// File Name: qa_location_form_test.dart
/// Purpose: QA bugs on the New Location form (9/10/2026): KP-TT-004 (State /
///          City name THEMSELVES in their hints before a country is
///          chosen), KP-TT-005 (Working Days are a row of small chips on iPad
///          portrait, not full-width bars) and KP-TT-006 (the country list is
///          searchable). English + Arabic.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/10-custom_tabs.dart';
import 'package:knowticed_plus/core/helper/main_helper/location_data_service.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/pages/time_tracker_home_page.dart';
import 'package:knowticed_plus/features/time_tracker/tt5_locations/presentation/ui/widgets/location_form_fields.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import '../_support/time_tracker_widget_harness.dart';

Finder _key(String k) => find.byKey(ValueKey<String>(k));
Finder _tab(String label) => find.descendant(of: find.byType(CustomTabs), matching: find.text(label));

Future<void> _tapIn(WidgetTester tester, TimeTrackerHarness h, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.tap(f);
  await h.settle(tester);
}

Future<void> _openNewLocation(WidgetTester tester, TimeTrackerHarness h) async {
  await tester.ensureVisible(_tab(S.current.timeTrackerTabLocations));
  await tester.pump();
  await tester.tap(_tab(S.current.timeTrackerTabLocations));
  await h.settle(tester);
  await _tapIn(tester, h, _key('locationsAddButton'));
}

/// The real Cairo fonts, so widths are the device's.
Future<void> _cairo() async {
  const String dir = 'assets/fonts/fonts_english/Cairo';
  for (final String family in <String>['Cairo', 'CairoArabic']) {
    final FontLoader loader = FontLoader(family);
    for (final String f in <String>['Cairo-Regular.ttf', 'Cairo-Medium.ttf', 'Cairo-SemiBold.ttf']) {
      final Uint8List bytes = File('$dir/$f').readAsBytesSync();
      loader.addFont(Future<ByteData>.value(ByteData.view(bytes.buffer)));
    }
    await loader.load();
  }
}

void main() {
  setUpAll(() async {
    await initTimeTrackerTestStorage();
    await _cairo();
  });

  for (final (String name, Locale locale) in <(String, Locale)>[
    ('EN', const Locale('en')),
    ('AR', const Locale('ar')),
  ]) {
    testWidgets('KP-TT-004: State / City hints name their own field before a country ($name)',
        (WidgetTester tester) async {
      final TimeTrackerHarness h = TimeTrackerHarness();
      await h.pump(tester, const TimeTrackerHomePage(), locale: locale);
      await _openNewLocation(tester, h);
      final BuildContext ctx = tester.element(_key('locationSubmitButton'));
      expect(tester.widget<CustomDropdown<String>>(_key('locationField_state')).hint,
          S.of(ctx).timeTrackerSelectState);
      expect(tester.widget<CustomDropdown<String>>(_key('locationField_city')).hint, S.of(ctx).selectCity);
      expect(tester.widget<CustomDropdown<String>>(_key('locationField_state')).hint,
          isNot(S.of(ctx).selectCountry), reason: 'it read "Select Country" before the fix');
      await h.dispose(tester);
    });

    testWidgets('KP-TT-005: Working Days are a row of chips on iPad portrait ($name)',
        (WidgetTester tester) async {
      final TimeTrackerHarness h = TimeTrackerHarness();
      await h.pump(tester, const TimeTrackerHomePage(), size: const Size(820, 1180), locale: locale);
      await _openNewLocation(tester, h);
      await tester.ensureVisible(_key('workingDay_1'));
      await tester.pump();
      final double formWidth = tester.getSize(_key('locationSubmitButton')).width;
      for (int day = 1; day <= 7; day++) {
        final Size chip = tester.getSize(_key('workingDay_$day'));
        expect(chip.width, lessThan(140), reason: 'day $day chip is ${chip.width} wide (was the full row)');
      }
      expect(formWidth, greaterThan(0));
      // Several chips share one line.
      expect(tester.getTopLeft(_key('workingDay_1')).dy, closeTo(tester.getTopLeft(_key('workingDay_2')).dy, 1));
      expect(tester.takeException(), isNull);
      await h.dispose(tester);
    });

    testWidgets('KP-TT-006: the country list is searchable ($name)', (WidgetTester tester) async {
      await tester.runAsync(LocationDataService.instance.load);
      final TimeTrackerHarness h = TimeTrackerHarness();
      await h.pump(tester, const TimeTrackerHomePage(), locale: locale);
      await _openNewLocation(tester, h);
      await _tapIn(tester, h, _key('locationCountryPicker'));
      expect(find.byType(TtSearchPickerDialog), findsOneWidget);
      final int all = find.byWidgetPredicate((Widget w) =>
          w.key is ValueKey<String> && (w.key! as ValueKey<String>).value.startsWith('searchPickerItem_')).evaluate().length;
      expect(all, greaterThan(0));
      // The label the list shows for Egypt in this language.
      final BuildContext ctx = tester.element(find.byType(TtSearchPickerDialog));
      final String query = LocationDataService.instance
          .countries(ctx)
          .firstWhere((LocationOption o) => o.code == 'EG')
          .label(locale.languageCode == 'ar');
      await tester.enterText(find.descendant(of: _key('searchPickerField'), matching: find.byType(TextField)), query);
      await h.settle(tester);
      final Finder items = find.byWidgetPredicate((Widget w) =>
          w.key is ValueKey<String> && (w.key! as ValueKey<String>).value.startsWith('searchPickerItem_'));
      expect(items.evaluate().length, inInclusiveRange(1, 3), reason: 'filtered from $all');
      expect(find.descendant(of: items.first, matching: find.textContaining(query)), findsWidgets);
      await _tapIn(tester, h, items.first);
      expect(find.byType(TtSearchPickerDialog), findsNothing);
      expect(tester.widget<CustomDropdown<String>>(_key('locationField_country')).value, isNotNull);
      expect(tester.takeException(), isNull);
      await h.dispose(tester);
    });
  }
}
