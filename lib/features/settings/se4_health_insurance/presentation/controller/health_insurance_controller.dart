/// Module: settings/se4_health_insurance
///
///*************************** FILE INFO ****************************///
/// File Name: health_insurance_controller.dart
/// Purpose: Holds the loaded insurance and emergency-contact entities for the
///          settings health-insurance section.
/// Author: Amr Mesbah
/// Created at: 12/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SE4-N08/N10: `updateAllInformation` is deleted.
///          It held the feature's only direct Firestore write, three
///          `Get.snackbar` calls with raw Colors.green/orange/red, and the
///          global loading overlay — and it had **no callers**: the live edit
///          path goes through the request flow (edit_page_request_health ->
///          preview -> RequestsCubit), so nothing could reach it. The six
///          TextEditingControllers went with it; none were read outside this
///          file. The two empty catches now record [loadErrorMessage].
///
/// Updated: 9/10/2026 - Reads Employees_Info ONLY. The two extra loads from
///          `Demo/{cid}/Insurance/{email}` and `Demo/{cid}/Emergency
///          Contacts/{email}` are gone (Settings schema 9 Oct: those
///          collections are duplicates being dropped — approval never updated
///          them, so they could only go stale). The entities they filled,
///          `healthInsuranceEntity` / `emergencyContactEntity`, had no reader
///          left (the preview page stopped using them on 24/8/2026) and went
///          with them, as did `loadErrorMessage`, which only those loads set.
///
/// REMAINING (CR-SKEL-SE4-N01): this is still a plain class rather than a
/// Cubit. Folding it into EmployeesHealthInsuranceCubit means changing what
/// SettingsController hands to the section widgets; staged, not done.

import 'package:knowticed_plus/core/helper/main_helper/phone_number.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/controller/settings_controller.dart';

class SettingsHealthInsuranceController {
  SettingsController settingsController;

  // REMOVED 9/10/2026 — `EmergencyContactEntity? emergencyContactEntity` and
  // `HealthInsuranceEntity? healthInsuranceEntity`. They were filled from the
  // duplicate `Emergency Contacts` / `Insurance` collections and nothing read
  // them. Insurance and emergency contacts now come from Employees_Info alone
  // (`Insurance_Name`, `Insurance_Policy_Number`, `First_Contact_*`,
  // `Second_Contact_*`; current value = last element of each history list).

  // Phone Numbers
  PhoneNumber? insurancePhone2;
  PhoneNumber? connecntionPhone2;

  // Additional Fields
  String? insuranceName2;
  String? insurancePolice2;
  String? connectionName2;
  String? connectionMiddleName2;
  String? connectionLastName2;
  String? connecntionRelation2;
  String? connecntionEmail2;
  String? connecntionCountry2;
  String? connecntionProvince2;
  String? connecntionCity2;
  String? connecntionAddress2;
  String? connecntionPostalCode2;

  // The `change*` flags that used to live here went with the controllers.
  // They were only ever set — true by the listeners below, false at the end of
  // each load — and the sole reader was `updateAllInformation`, which was
  // deleted in the same change. With the listeners gone they could never be
  // anything but `false`, so keeping them would have been a trap for the
  // staged Cubit migration.

  SettingsHealthInsuranceController(this.settingsController);

  /// Get all data from employee model
  getData() {
    // print('🏥 Loading Health Insurance & Emergency Contact data...');

    if (settingsController.employee == null) {
      // print('⚠️ No employee data available');
      return;
    }

    _loadHealthInsuranceFromEmployee();
    _loadEmergencyContactFromEmployee();
    // REMOVED 9/10/2026 — `_getHealthInsuranceData()` and
    // `_getEmergencyContactData()`: the reads of `Insurance/{email}` and
    // `Emergency Contacts/{email}`. Employees_Info (above) is the only source.
  }

  /// Load health insurance data from employee model
  void _loadHealthInsuranceFromEmployee() {
    if (settingsController.employee == null) return;

    // Load Insurance Name
    if (settingsController.employee!.insuranceName.isNotEmpty) {
      insuranceName2 = settingsController.employee!.insuranceName.last;
    }

    // Load Insurance Policy Number
    if (settingsController.employee!.insurancePolicyNumber.isNotEmpty) {
      insurancePolice2 = settingsController.employee!.insurancePolicyNumber.last;
    }
  }

  /// Load emergency contact data from employee model
  void _loadEmergencyContactFromEmployee() {
    if (settingsController.employee == null) return;

    // Load First Contact First Name
    if (settingsController.employee!.firstContactFirstName.isNotEmpty) {
      connectionName2 = settingsController.employee!.firstContactFirstName.last;
    }

    // Load First Contact Last Name
    if (settingsController.employee!.firstContactLastName.isNotEmpty) {
      connectionLastName2 = settingsController.employee!.firstContactLastName.last;
      // print('   Contact Last Name: $connectionLastName2');
    }

    // Load First Contact Relationship
    if (settingsController.employee!.firstContactRelationship.isNotEmpty) {
      connecntionRelation2 = settingsController.employee!.firstContactRelationship.last;
    }

    // Load First Contact Email
    if (settingsController.employee!.firstContactEmail.isNotEmpty) {
      connecntionEmail2 = settingsController.employee!.firstContactEmail.last;
      // print('   Contact Email: $connecntionEmail2');
    }

    // First Contact Phone is deliberately not loaded here. The old line only
    // pushed the raw string into the deleted `connecntionPhone` controller;
    // the surviving snapshot field is a [PhoneNumber], and parsing into it via
    // `PhoneNumber.fromCompleteNumber` rethrows InvalidCharactersException,
    // which would turn one malformed stored number into a failed load for the
    // whole section. Nothing reads `connecntionPhone2` today.

    // Load First Contact Country
    if (settingsController.employee!.firstContactCountry.isNotEmpty) {
      connecntionCountry2 = settingsController.employee!.firstContactCountry.last;
      // print('   Contact Country: $connecntionCountry2');
    }

    // Load First Contact Province
    if (settingsController.employee!.firstContactProvince.isNotEmpty) {
      connecntionProvince2 = settingsController.employee!.firstContactProvince.last;
      // print('   Contact Province: $connecntionProvince2');
    }

    // Load First Contact City
    if (settingsController.employee!.firstContactCity.isNotEmpty) {
      connecntionCity2 = settingsController.employee!.firstContactCity.last;
      // print('   Contact City: $connecntionCity2');
    }

    // Load First Contact Street
    if (settingsController.employee!.firstContactStreet.isNotEmpty) {
      connecntionAddress2 = settingsController.employee!.firstContactStreet.last;
      // print('   Contact Address: $connecntionAddress2');
    }

  }

  // REMOVED 9/10/2026 — `loadErrorMessage`, `_getHealthInsuranceData()` and
  // `_getEmergencyContactData()`. They read `Demo/{cid}/Insurance/{email}`
  // and `Demo/{cid}/Emergency Contacts/{email}` through
  // EmployeesHealthInsuranceCubit / EmergencyContactController — duplicate
  // copies the Settings schema (9 Oct) drops. The page renders straight from
  // the Employees_Info history lists (HealthInsuranceSection,
  // EmergencyContactInformationSection, EditPageRequestHealth).
}
