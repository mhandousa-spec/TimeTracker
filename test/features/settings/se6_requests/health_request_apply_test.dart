/// Module: test / settings / se6_requests
///
///*************************** FILE INFO ****************************///
/// File Name: health_request_apply_test.dart
/// Purpose: Approving a Health Insurance / Emergency Contact change request
///          APPENDS to the Employees_Info history lists and to `timestamps`
///          (`RequestsRemoteDataSource.applyChangesToHistory`), and an
///          approval no longer wipes a field whose list was shorter than
///          `timestamps` (the 9/10/2026 carry-forward fix in
///          `NewEmployeeModelHistory`).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026

import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:knowticed_plus/features/settings/se6_requests/data/data_source/remote_data_source/requests_remote_data_source.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/entities/field_change.dart';

void main() {
  test('approved health + emergency changes append, current value = last', () {
    final NewEmployeeModelHistory history =
        NewEmployeeModelHistory.fromMap(<String, dynamic>{
      'Id': 'emp-1',
      'timestamps': <int>[1000, 2000],
      'First_Name': <String>['amr', 'amr'],
      'Insurance_Name': <String>['Allianz', 'Allianz'],
      'Insurance_Policy_Number': <String>['P-1', 'P-1'],
      'First_Contact_Phone': <String>['100', '100'],
      'Second_Contact_First_Name': <String>['Mona', 'Mona'],
    });

    final ({NewEmployeeModelHistory history, List<String> skipped}) result =
        RequestsRemoteDataSource.applyChangesToHistory(history, const <FieldChange>[
      FieldChange(
          fieldName: 'insuranceName', oldValue: 'Allianz', newValue: 'AXA'),
      FieldChange(
          fieldName: 'firstContact_phone', oldValue: '100', newValue: '200'),
    ]);

    final NewEmployeeModelHistory applied = result.history;
    expect(result.skipped, isEmpty);

    // One revision per approved field (existing behaviour): 2 + 2.
    expect(applied.timestamps, hasLength(4));

    expect(applied.insuranceName, <String>['Allianz', 'Allianz', 'AXA', 'AXA']);
    expect(applied.firstContactPhone, <String>['100', '100', '100', '200']);
    // Untouched fields repeat their last value and stay aligned.
    expect(applied.insurancePolicyNumber, <String>['P-1', 'P-1', 'P-1', 'P-1']);
    expect(applied.secondContactFirstName.last, 'Mona');
    expect(applied.firstName, <String>['amr', 'amr', 'amr', 'amr']);

    // The write map carries the appended lists.
    final Map<String, dynamic> written = applied.toMap();
    expect((written['Insurance_Name'] as List<dynamic>).last, 'AXA');
    expect((written['timestamps'] as List<dynamic>).length, 4);
  });

  test('a SHORT history list keeps its current value through an approval', () {
    // Insurance_Policy_Number has one entry for three revisions — e.g. an HR
    // bulk upload appended `timestamps` without it. Before 9/10/2026 the gap
    // was filled with '' and the unchanged policy number became ''.
    final NewEmployeeModelHistory history =
        NewEmployeeModelHistory.fromMap(<String, dynamic>{
      'timestamps': <int>[1000, 2000, 3000],
      'Insurance_Name': <String>['Allianz', 'Allianz', 'Allianz'],
      'Insurance_Policy_Number': <String>['P-1'],
      'Mobile_Phone': <Map<String, dynamic>>[
        <String, dynamic>{
          'Phone': <String>['5551234'],
          'Country_Code': <String>['+20'],
          'Country_App': <String>['EG'],
        },
      ],
    });

    final NewEmployeeModelHistory applied =
        RequestsRemoteDataSource.applyChangesToHistory(history, const <FieldChange>[
      FieldChange(
          fieldName: 'insuranceName', oldValue: 'Allianz', newValue: 'AXA'),
    ]).history;

    expect(applied.timestamps, hasLength(4));
    expect(applied.insuranceName.last, 'AXA');
    expect(applied.insurancePolicyNumber, <String>['P-1', 'P-1', 'P-1', 'P-1']);
    // Same fix for the employee's own mobile phone.
    expect(applied.mobilePhone, hasLength(4));
    expect(applied.mobilePhone.last.phones, <String>['5551234']);
  });

  test('unknown field names are skipped, the rest still applied', () {
    final NewEmployeeModelHistory history =
        NewEmployeeModelHistory.fromMap(<String, dynamic>{
      'timestamps': <int>[1000],
      'Insurance_Name': <String>['Allianz'],
    });

    final ({NewEmployeeModelHistory history, List<String> skipped}) result =
        RequestsRemoteDataSource.applyChangesToHistory(history, const <FieldChange>[
      FieldChange(fieldName: 'not_a_field', oldValue: '', newValue: 'x'),
      FieldChange(
          fieldName: 'insuranceName', oldValue: 'Allianz', newValue: 'AXA'),
    ]);

    expect(result.skipped, <String>['not_a_field']);
    expect(result.history.insuranceName.last, 'AXA');
  });
}
