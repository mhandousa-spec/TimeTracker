/// Module: settings/se1_profile
///
///*************************** FILE INFO ****************************///
/// File Name: personal_profile.dart
/// Purpose: The read model behind the personal-information page.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Added for CR-SKEL-SE1-N03 / N17. The section widgets used to reach into the
/// mutable top-level `employee` global from settings_screen.dart and
/// force-unwrap it (`employee!.email!.last`), so the page crashed whenever the
/// employee had not loaded yet, or any of the history lists was empty. They now
/// receive this entity: every field is a plain, already-resolved `String`, and
/// an unloaded employee is a well-defined empty profile rather than a null
/// dereference.

import 'package:flutter/foundation.dart';

@immutable
class PersonalProfile {
  const PersonalProfile({
    this.firstName = '',
    this.middleName = '',
    this.lastName = '',
    this.firstNameInArabic,
    this.middleNameInArabic,
    this.lastNameInArabic,
    this.photoUrl,
    this.gender,
    this.maritalStatus,
    this.rawBirthDate,
    this.email = '',
    this.phoneNumber = '',
    this.phoneCountryCode = defaultCountryCode,
    this.country = '',
    this.province = '',
    this.city = '',
    this.street = '',
  });

  /// Used when the employee record carries no country code. Was inlined as
  /// `"EG"` / `'🇪🇬'` / `'+20'` in three places in contact_information.dart.
  static const String defaultCountryCode = 'EG';

  /// The empty profile — what the page shows before the employee has loaded.
  static const PersonalProfile empty = PersonalProfile();

  final String firstName;
  final String middleName;
  final String lastName;
  final String? firstNameInArabic;
  final String? middleNameInArabic;
  final String? lastNameInArabic;

  final String? photoUrl;
  final String? gender;
  final String? maritalStatus;

  /// The birthday exactly as stored. Parsing lives in the data layer
  /// ([EmployeeDateFormatter]) — never in a widget.
  final String? rawBirthDate;

  final String email;
  final String phoneNumber;

  /// ISO country code (e.g. `EG`) — not the dial code.
  final String phoneCountryCode;

  final String country;
  final String province;
  final String city;
  final String street;

  bool get hasPhoto => photoUrl != null && photoUrl!.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonalProfile &&
          other.firstName == firstName &&
          other.middleName == middleName &&
          other.lastName == lastName &&
          other.firstNameInArabic == firstNameInArabic &&
          other.middleNameInArabic == middleNameInArabic &&
          other.lastNameInArabic == lastNameInArabic &&
          other.photoUrl == photoUrl &&
          other.gender == gender &&
          other.maritalStatus == maritalStatus &&
          other.rawBirthDate == rawBirthDate &&
          other.email == email &&
          other.phoneNumber == phoneNumber &&
          other.phoneCountryCode == phoneCountryCode &&
          other.country == country &&
          other.province == province &&
          other.city == city &&
          other.street == street;

  @override
  int get hashCode => Object.hashAll(<Object?>[
        firstName,
        middleName,
        lastName,
        firstNameInArabic,
        middleNameInArabic,
        lastNameInArabic,
        photoUrl,
        gender,
        maritalStatus,
        rawBirthDate,
        email,
        phoneNumber,
        phoneCountryCode,
        country,
        province,
        city,
        street,
      ]);
}
