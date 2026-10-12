/// Module: settings/se5_emergency_contact
///
///*************************** FILE INFO ****************************///
/// File Name: emergency_contact_mapper.dart
/// Purpose: Map [EmergencyContactsModel] onto the domain entity.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Added for CR-SKEL-SE5-N09. `EmergencyContactEntity.fromModel` lived on the
/// entity, so `domain/entities/` imported `data/models/`. The body is the
/// original one, with the `countryCode!` / `countryApp!` force-unwraps replaced
/// by `?.` — the phone sub-model's lists are nullable, and a contact saved
/// without a country code would have thrown here.

import 'package:knowticed_plus/features/settings/se5_emergency_contact/data/models/emergency_contacts_model.dart';
import 'package:knowticed_plus/features/settings/se5_emergency_contact/domain/entities/emergency_contact_entity.dart';

abstract class EmergencyContactMapper {
  /// Function Name: [toEntity]
  ///
  /// Purpose: Flatten the stored history lists into the latest values.
  static EmergencyContactEntity toEntity(
      EmergencyContactsModel emergencyContactsModel) {

    return EmergencyContactEntity(
      employeeId: emergencyContactsModel.employeeId,
      firstContactFirstName: emergencyContactsModel
          .firstEmergencyContact?.firstName.values.lastOrNull,
      firstContactMiddleName: emergencyContactsModel
          .firstEmergencyContact?.middleName.values.lastOrNull,
      firstContactLastName: emergencyContactsModel
          .firstEmergencyContact?.lastName.values.lastOrNull,
      firstContactRelationShip: emergencyContactsModel
          .firstEmergencyContact?.relationShip.values.lastOrNull,
      firstContactPhone: emergencyContactsModel
          .firstEmergencyContact?.phone.phones?.lastOrNull,
      firstContactCountryCode: emergencyContactsModel
          .firstEmergencyContact?.phone.countryCode?.lastOrNull,
      firstContactCountryApp: emergencyContactsModel
          .firstEmergencyContact?.phone.countryApp?.lastOrNull,
      firstContactEmail:
      emergencyContactsModel.firstEmergencyContact?.email.values.lastOrNull,
      firstContactCountry: emergencyContactsModel
          .firstEmergencyContact?.country.values.lastOrNull,
      firstContactProvince: emergencyContactsModel
          .firstEmergencyContact?.province.values.lastOrNull,
      firstContactCity:
      emergencyContactsModel.firstEmergencyContact?.city?.values.lastOrNull,
      firstContactStreet: emergencyContactsModel
          .firstEmergencyContact?.street.values.lastOrNull,
      firstContactLanguage: emergencyContactsModel
          .firstEmergencyContact?.language?.values.lastOrNull,
      secondContactFirstName: emergencyContactsModel
          .secondEmergencyContact?.firstName.values.lastOrNull,
      secondContactMiddleName: emergencyContactsModel
          .secondEmergencyContact?.middleName.values.lastOrNull,
      secondContactLastName: emergencyContactsModel
          .secondEmergencyContact?.lastName.values.lastOrNull,
      secondContactRelationShip: emergencyContactsModel
          .secondEmergencyContact?.relationShip.values.lastOrNull,
      secondContactPhone: emergencyContactsModel
          .secondEmergencyContact?.phone.phones?.lastOrNull,
      secondContactCountryCode: emergencyContactsModel
          .secondEmergencyContact?.phone.countryCode?.lastOrNull,
      secondContactCountryApp: emergencyContactsModel
          .secondEmergencyContact?.phone.countryApp?.lastOrNull,
      secondContactEmail: emergencyContactsModel
          .secondEmergencyContact?.email.values.lastOrNull,
      secondContactCountry: emergencyContactsModel
          .secondEmergencyContact?.country.values.lastOrNull,
      secondContactProvince: emergencyContactsModel
          .secondEmergencyContact?.province.values.lastOrNull,
      secondContactCity:
      emergencyContactsModel.secondEmergencyContact?.city.values.lastOrNull,
      secondContactStreet: emergencyContactsModel
          .secondEmergencyContact?.street.values.lastOrNull,
      secondContactLanguage: emergencyContactsModel
          .secondEmergencyContact?.language?.values.lastOrNull,
    );
  }
}
