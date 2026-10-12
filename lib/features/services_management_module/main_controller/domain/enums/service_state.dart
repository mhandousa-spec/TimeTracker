// ******************* FILE INFO *******************
// File Name: service_state
// Description: Business enum for the lifecycle state of a service / request.
// Module: services_management_module / domain / enums
// *************************************************

/// The lifecycle state of a service or service request.
///
/// Domain-level representation of the free-form `state` / `status` strings that
/// are persisted by the data layer. Keeping the canonical values here (instead
/// of scattering string literals across cubits and widgets) removes a whole
/// class of typo bugs and gives the UI a single source of truth.
enum ServiceState {
  draft('draft'),
  pending('pending'),
  inProgress('in_progress'),
  approved('approved'),
  rejected('rejected'),
  branchSla('branch_sla'),
  done('done'),
  unknown('unknown');

  const ServiceState(this.value);

  /// The persisted string value as stored by the data layer.
  final String value;

  /// Maps a persisted string to its [ServiceState], case-insensitively.
  /// Falls back to [ServiceState.unknown] for unrecognised values.
  static ServiceState fromValue(String? raw) {
    if (raw == null || raw.isEmpty) return ServiceState.unknown;
    final normalized = raw.trim().toLowerCase().replaceAll(' ', '_');
    for (final state in ServiceState.values) {
      if (state.value == normalized) return state;
    }
    return ServiceState.unknown;
  }

  bool get isTerminal =>
      this == ServiceState.approved ||
      this == ServiceState.rejected ||
      this == ServiceState.done;
}
