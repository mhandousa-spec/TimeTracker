/// Module: settings/se1_profile
///
///*************************** FILE INFO ****************************///
/// File Name: build_personal_profile.dart
/// Purpose: Turn the raw employee history model into the page's read model.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Added for CR-SKEL-SE1-N03 / N17. Every widget in the sub-feature used to do
/// this flattening inline against a mutable global — `employee!.email!.last`,
/// `employee!.mobilePhone` … — which meant three copies of the same
/// force-unwrapping and a crash whenever a history list was empty. The
/// flattening happens once, here, and `lastOrNull` replaces every `!`.

import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/mobile_phone_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:knowticed_plus/features/settings/se1_profile/domain/entities/personal_profile.dart';

class BuildPersonalProfile {
  const BuildPersonalProfile();

  /// Function Name: [call]
  ///
  /// Purpose: Map an employee onto a [PersonalProfile].
  ///
  /// Parameters:
  /// - [employee]: the loaded employee, or `null` before it has loaded.
  ///
  /// Returns: [PersonalProfile] — [PersonalProfile.empty] for a null employee,
  ///          so callers never have to null-check the result.
  PersonalProfile call(NewEmployeeModelHistory? employee) {
    if (employee == null) return PersonalProfile.empty;

    final MobilePhone? mobilePhone = _first(employee.mobilePhone);

    return PersonalProfile(
      firstName: _last(employee.firstName) ?? '',
      middleName: _last(employee.middleName) ?? '',
      lastName: _last(employee.lastName) ?? '',
      firstNameInArabic: _last(employee.firstNameInArabic),
      middleNameInArabic: _last(employee.middleNameInArabic),
      lastNameInArabic: _last(employee.lastNameInArabic),
      photoUrl: _last(employee.photo),
      gender: _last(employee.gender),
      maritalStatus: _last(employee.maritalStatus),
      rawBirthDate: _last(employee.birthDay),
      email: _last(employee.email) ?? '',
      phoneNumber: _last(mobilePhone?.phones) ?? '',
      phoneCountryCode:
          _last(mobilePhone?.countryCode) ?? PersonalProfile.defaultCountryCode,
      country: _last(employee.country) ?? '',
      province: _last(employee.province) ?? '',
      city: _last(employee.city) ?? '',
      street: _last(employee.street) ?? '',
    );
  }

  /// The employee model stores every field as a history list, newest last.
  /// Written out rather than using `lastOrNull` so this layer needs neither
  /// `package:collection` nor `package:get` — a domain use case should not
  /// import a service locator for a list helper.
  static T? _last<T>(List<T>? values) =>
      (values == null || values.isEmpty) ? null : values.last;

  static T? _first<T>(List<T>? values) =>
      (values == null || values.isEmpty) ? null : values.first;
}
