/// Module: settings/se6_requests
///
///*************************** FILE INFO ****************************///
/// File Name: request_field_mapping.dart
/// Purpose: Translate a request's `fieldName` into the employee-model field it
///          writes to.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
/// Updated: 13/8/2026 - The table only listed a handful of the field names the
///          edit screens actually emit. `edit_page_request_health.dart` writes
///          `firstContact_firstName`, `firstContact_city`, `secondContact_street`
///          and eleven more; none were listed, so `toModelField` handed the raw
///          snake_case key to `NewEmployeeModelHistory.updateFieldSynchronized`,
///          which threw `Unknown field` and aborted the entire approval — the
///          profile kept its old values while the request still read as
///          approved. Completed the table, folded the snake_case spellings into
///          one camelCase normaliser (the same approach
///          `UserManagementController.mapFieldName` already took), and split
///          the phone fields out because they live inside a `MobilePhone`
///          object rather than a plain string field.
///
/// Added for CR-SKEL-SE6-N01. This table lived as a local `_mapFieldName`
/// inside `details_request.dart` — a widget — right next to the Firestore
/// update that used it. Two near-identical copies existed (the preview pages
/// carry their own display-name table), and only this one drives writes, so
/// this is the one that had to leave the UI.

abstract final class RequestFieldMapping {
  const RequestFieldMapping._();

  /// Prefix marking a field that lives inside the employee's `MobilePhone`
  /// object instead of being a top-level model field. `updateFieldSynchronized`
  /// cannot take these as strings — it demands a `MobilePhone` instance and
  /// throws an `ArgumentError` on anything else.
  static const String mobilePhonePrefix = 'mobilePhone.';

  /// Request `fieldName` → `NewEmployeeModelHistory` field name.
  ///
  /// Keys are the names the settings edit screens emit. Values are the exact
  /// `case` labels in `updateFieldSynchronized`, apart from the `mobilePhone.*`
  /// values, which [isMobilePhoneField] routes elsewhere.
  ///
  /// Several keys map to themselves; they are listed so the table doubles as
  /// the set of fields an approval is allowed to write.
  static const Map<String, String> _toModelField = <String, String>{
    // Basic fields
    'first_name': 'firstName',
    'middle_name': 'middleName',
    'last_name': 'lastName',
    'first_name_arabic': 'firstNameInArabic',
    'middle_name_arabic': 'middleNameInArabic',
    'last_name_arabic': 'lastNameInArabic',
    'email': 'email',
    'gender': 'gender',
    'date_of_birth': 'birthDay',
    'marital_status': 'maritalStatus',
    'photo': 'photo',
    'nationality': 'nationality',

    // Phone. These are not top-level fields — see [isMobilePhoneField].
    'phone': '${mobilePhonePrefix}phones',
    'Phone': '${mobilePhonePrefix}phones',
    'country_code': '${mobilePhonePrefix}countryCode',
    'Country_Code': '${mobilePhonePrefix}countryCode',
    'country_app': '${mobilePhonePrefix}countryApp',
    'Country_App': '${mobilePhonePrefix}countryApp',

    // Address fields
    'street': 'street',
    'city': 'city',
    'province': 'province',
    'country': 'country',
    'postal_code': 'postalCode',
    'postalCode': 'postalCode',

    // Health insurance
    'insurance_name': 'insuranceName',
    'insuranceName': 'insuranceName',
    'Insurance_Name': 'insuranceName',
    'insurance_policy_number': 'insurancePolicyNumber',
    'insurancePolicyNumber': 'insurancePolicyNumber',
    'Insurance_Policy_Number': 'insurancePolicyNumber',

    // 1st emergency contact. `edit_page_request_health.dart` emits the
    // snake_case spellings; the camelCase ones are what the model uses.
    'firstContact_firstName': 'firstContactFirstName',
    'firstContact_lastName': 'firstContactLastName',
    'firstContact_relationship': 'firstContactRelationship',
    'firstContact_email': 'firstContactEmail',
    'firstContact_phone': 'firstContactPhone',
    'firstContact_language': 'firstContactLanguage',
    'firstContact_country': 'firstContactCountry',
    'firstContact_province': 'firstContactProvince',
    'firstContact_city': 'firstContactCity',
    'firstContact_street': 'firstContactStreet',

    // 2nd emergency contact
    'secondContact_firstName': 'secondContactFirstName',
    'secondContact_lastName': 'secondContactLastName',
    // Older requests wrote a single combined name field.
    'secondContact_name': 'secondContactFirstName',
    'secondContact_relationship': 'secondContactRelationship',
    'secondContact_email': 'secondContactEmail',
    'secondContact_phone': 'secondContactPhone',
    'secondContact_language': 'secondContactLanguage',
    'secondContact_country': 'secondContactCountry',
    'secondContact_province': 'secondContactProvince',
    'secondContact_city': 'secondContactCity',
    'secondContact_street': 'secondContactStreet',
  };

  /// Function Name: [toModelField]
  ///
  /// Purpose: Resolve the employee-model field for a request field name.
  ///
  /// Falls back to a snake_case → camelCase fold before giving up, so a new
  /// `somethingContact_postalCode` on an edit screen resolves without this
  /// table having to list it. Returns the input unchanged when nothing matches
  /// — the previous behaviour, which lets a request name a model field
  /// directly. [isKnown] is what callers should use to decide whether a field
  /// is safe to write.
  static String toModelField(String requestFieldName) {
    final String? direct = _toModelField[requestFieldName];
    if (direct != null) return direct;

    final String camel = _snakeToCamel(requestFieldName);
    return _toModelField[camel] ?? camel;
  }

  /// Function Name: [isMobilePhoneField]
  ///
  /// Purpose: Whether [modelField] (the output of [toModelField]) addresses a
  ///          member of the employee's `MobilePhone` rather than a top-level
  ///          model field.
  static bool isMobilePhoneField(String modelField) =>
      modelField.startsWith(mobilePhonePrefix);

  /// Function Name: [mobilePhoneMember]
  ///
  /// Purpose: `mobilePhone.countryCode` → `countryCode`.
  static String mobilePhoneMember(String modelField) =>
      modelField.substring(mobilePhonePrefix.length);

  /// Function Name: [isKnown]
  ///
  /// Purpose: Whether a request field resolves to something the employee model
  ///          can actually store. Lets the caller skip a field it cannot write
  ///          instead of letting one bad name throw away every other change in
  ///          the same approval.
  static bool isKnown(String requestFieldName) {
    if (_toModelField.containsKey(requestFieldName)) return true;
    final String camel = _snakeToCamel(requestFieldName);
    return _toModelField.containsKey(camel) ||
        _toModelField.containsValue(camel);
  }

  /// `secondContact_province` → `secondContactProvince`.
  /// Leaves an already-camelCase key untouched.
  static String _snakeToCamel(String value) {
    if (!value.contains('_')) return value;

    final List<String> parts =
        value.split('_').where((String p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return value;

    return parts.first +
        parts
            .skip(1)
            .map((String p) => p[0].toUpperCase() + p.substring(1))
            .join();
  }
}
