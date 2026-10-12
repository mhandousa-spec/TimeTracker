/// Module: test / settings / se4_health_insurance
///
///*************************** FILE INFO ****************************///
/// File Name: health_request_form_rules_test.dart
/// Purpose: The 2nd emergency contact is OPTIONAL (owner decision
///          9/10/2026): insurance + 1st contact required; the 2nd contact
///          empty, or complete once any of its fields is filled.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026

import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/settings/se4_health_insurance/domain/rules/health_request_form_rules.dart';

List<String> _contact({String Function(int i)? value}) =>
    List<String>.generate(10, (int i) => value?.call(i) ?? 'v$i');

final List<String> _insurance = <String>['Allianz', 'P-1'];
final List<String> _emptyContact = List<String>.filled(10, '');

void main() {
  test('submits with the 2nd contact completely empty', () {
    expect(
      HealthRequestFormRules.canPreview(
        insurance: _insurance,
        firstContact: _contact(),
        secondContact: _emptyContact,
      ),
      isTrue,
    );
  });

  test('whitespace-only 2nd contact counts as empty', () {
    expect(
      HealthRequestFormRules.canPreview(
        insurance: _insurance,
        firstContact: _contact(),
        secondContact: List<String>.filled(10, '   '),
      ),
      isTrue,
    );
  });

  test('submits with a complete 2nd contact', () {
    expect(
      HealthRequestFormRules.canPreview(
        insurance: _insurance,
        firstContact: _contact(),
        secondContact: _contact(),
      ),
      isTrue,
    );
  });

  test('ONE filled 2nd-contact field makes every 2nd-contact field required',
      () {
    final List<String> started =
        List<String>.from(_emptyContact)..[4] = '+20 1012345678'; // phone
    expect(
      HealthRequestFormRules.canPreview(
        insurance: _insurance,
        firstContact: _contact(),
        secondContact: started,
      ),
      isFalse,
    );
    expect(HealthRequestFormRules.isSecondContactIncomplete(started), isTrue);
  });

  test('2nd contact missing one field is refused', () {
    expect(
      HealthRequestFormRules.canPreview(
        insurance: _insurance,
        firstContact: _contact(),
        secondContact: _contact(value: (int i) => i == 9 ? '' : 'v$i'),
      ),
      isFalse,
    );
  });

  test('1st contact and insurance stay required', () {
    expect(
      HealthRequestFormRules.canPreview(
        insurance: _insurance,
        firstContact: _contact(value: (int i) => i == 0 ? '' : 'v$i'),
        secondContact: _emptyContact,
      ),
      isFalse,
    );
    expect(
      HealthRequestFormRules.canPreview(
        insurance: <String>['Allianz', ''],
        firstContact: _contact(),
        secondContact: _emptyContact,
      ),
      isFalse,
    );
    // An empty 1st contact is NOT "optional" like the 2nd.
    expect(
      HealthRequestFormRules.canPreview(
        insurance: _insurance,
        firstContact: _emptyContact,
        secondContact: _contact(),
      ),
      isFalse,
    );
  });

  test('2nd-contact "required" errors only after submit AND once started', () {
    expect(
      HealthRequestFormRules.showSecondContactErrors(
          submitted: true, secondContact: _emptyContact),
      isFalse,
    );
    final List<String> started = List<String>.from(_emptyContact)..[0] = 'Ali';
    expect(
      HealthRequestFormRules.showSecondContactErrors(
          submitted: false, secondContact: started),
      isFalse,
    );
    expect(
      HealthRequestFormRules.showSecondContactErrors(
          submitted: true, secondContact: started),
      isTrue,
    );
  });
}
