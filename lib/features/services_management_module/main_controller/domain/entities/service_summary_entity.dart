// ******************* FILE INFO *******************
// File Name: service_summary_entity
// Description: Immutable domain entity summarising a single service record.
// Module: services_management_module / domain / entities
// *************************************************

import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/domain/enums/service_state.dart';

/// Immutable business object describing the *current* snapshot of a service.
///
/// The data layer stores every field as a time-stamped history list
/// ([ServicesHistoryModel]). The domain only ever cares about the latest value,
/// so this entity flattens that history into plain, final fields and a typed
/// [ServiceState]. UI and use cases should prefer this entity over the raw DTO.
class ServiceSummaryEntity {
  final String id;
  final String parentServiceId;
  final ServiceState state;
  final String serviceNameEnglish;
  final String serviceNameArabic;
  final String emailRequester;
  final String assignedProviderEmail;
  final bool requireApproval;

  const ServiceSummaryEntity({
    required this.id,
    required this.parentServiceId,
    required this.state,
    required this.serviceNameEnglish,
    required this.serviceNameArabic,
    required this.emailRequester,
    required this.assignedProviderEmail,
    required this.requireApproval,
  });

  /// Builds an entity from the data-layer DTO, reading only current values.
  factory ServiceSummaryEntity.fromModel(ServicesHistoryModel model) {
    return ServiceSummaryEntity(
      id: model.currentId,
      parentServiceId: model.currentParentServiceId,
      state: ServiceState.fromValue(model.currentState),
      serviceNameEnglish: model.currentServiceNameEnglish,
      serviceNameArabic: model.currentServiceNameArabic,
      emailRequester: model.currentEmailRequester,
      assignedProviderEmail: model.currentAssignedProviderEmail,
      requireApproval: model.currentRequireApproval,
    );
  }
}
