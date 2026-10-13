/// Module: test / time_tracker / data
///
///*************************** FILE INFO ****************************///
/// File Name: readable_ids_test.dart
/// Purpose: Owner decision 48 — new records get readable ids: REQ-2026-0001,
///          TRX-…, LOC-0001, GRP-…, RQT-…, CMT-0001 per request; numbers keep
///          counting and skip ids that already exist.
/// Author: Knowticed Plus team
/// Created at: 13/10/2026

import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/time_tracker/data/data_source/remote_data_source/time_tracker_remote_data_source.dart';

void main() {
  test('NewDocId formats and counter keys', () {
    const NewDocId req = NewDocId('REQ-2026');
    expect(req.idFor(1), 'REQ-2026-0001');
    expect(req.idFor(42), 'REQ-2026-0042');
    expect(req.counterKey, 'REQ-2026');
    const NewDocId cmt = NewDocId('CMT', counterKey: 'CMT__REQ-2026-0001');
    expect(cmt.idFor(3), 'CMT-0003');
    expect(cmt.counterKey, 'CMT__REQ-2026-0001');
    expect(const NewDocId('LOC').idFor(12345), 'LOC-12345');
  });
}
