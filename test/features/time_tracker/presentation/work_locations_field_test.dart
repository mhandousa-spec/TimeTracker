/// Module: test / time_tracker / presentation
///
///*************************** FILE INFO ****************************///
/// File Name: work_locations_field_test.dart
/// Purpose: `TtWorkLocationsField` (owner review T5 / T6, 12/10/2026): the
///          main location is tagged "Main", extra locations are listed, and
///          removing the main one promotes the next.
/// Author: Knowticed Plus team
/// Created at: 12/10/2026

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/features/time_tracker/tt6_employees/presentation/ui/widgets/grant_access_dialog.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import '../_support/time_tracker_widget_harness.dart';

const List<WorkLocation> _places = <WorkLocation>[
  WorkLocation(id: 'hq', nameEn: 'Headquarters'),
  WorkLocation(id: 'br', nameEn: 'Branch'),
];

void main() {
  setUpAll(initTimeTrackerTestStorage);

  testWidgets('main tagged, extras listed, removing the main promotes the next', (WidgetTester tester) async {
    String main = 'hq';
    List<String> extras = <String>['br'];
    final TimeTrackerHarness h = TimeTrackerHarness();
    await h.pump(
      tester,
      Scaffold(
        body: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) => TtWorkLocationsField(
            mainId: main,
            extraIds: extras,
            locations: _places,
            isArabic: false,
            onChanged: (String m, List<String> e) => setState(() {
              main = m;
              extras = e;
            }),
          ),
        ),
      ),
    );
    expect(find.text('Headquarters · ${S.current.timeTrackerMainLocation}'), findsOneWidget);
    expect(find.text('Branch'), findsOneWidget);
    expect(find.text(S.current.timeTrackerWorkLocationsHint), findsOneWidget);

    final TtRemovableChip chip =
        tester.widget<TtRemovableChip>(find.byKey(const ValueKey<String>('workLocationChip_hq')));
    chip.onRemove!();
    await tester.pump();
    expect(main, 'br');
    expect(extras, isEmpty);
    expect(find.text('Branch · ${S.current.timeTrackerMainLocation}'), findsOneWidget);
    await h.dispose(tester);
  });
}
