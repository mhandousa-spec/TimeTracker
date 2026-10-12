/// Module: settings/se4_health_insurance
///
///*************************** FILE INFO ****************************///
/// File Name: health_insurance_mapper.dart
/// Purpose: Map [HealthInsuranceModel] onto the domain entity.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Added for CR-SKEL-SE4-N18. `HealthInsuranceEntity.fromModel` lived on the
/// entity itself, so `domain/entities/` imported `data/models/`. It also did
/// `healthInsuranceModel.employeeId!` — the exact non-null dereference that the
/// repository's fabricated-success bug detonated. The `!` is gone: a model with
/// no employee id now yields an empty string rather than throwing during a
/// mapping step.

import 'package:knowticed_plus/features/settings/se4_health_insurance/data/models/health_insurance_model.dart';
import 'package:knowticed_plus/features/settings/se4_health_insurance/domain/entities/request_health_insurance_entity.dart';

abstract class HealthInsuranceMapper {
  /// Function Name: [toEntity]
  ///
  /// Purpose: Flatten the stored history lists into the latest values.
  static HealthInsuranceEntity toEntity(HealthInsuranceModel model) {
    return HealthInsuranceEntity(
      employeeId: model.employeeId ?? '',
      providerName: model.insuranceProviderName.values.lastOrNull,
      policyNumber: model.insurancePolicyNumber.values.lastOrNull,
      providerNumber: model.insuranceProviderContact.phones?.lastOrNull,
      providerCountryCode:
          model.insuranceProviderContact.countryCode?.lastOrNull,
      providerCountryApp: model.insuranceProviderContact.countryApp?.lastOrNull,
      postalCode: model.postalCode.values.lastOrNull,
    );
  }
}
