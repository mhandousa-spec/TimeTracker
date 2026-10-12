part of 'approved_evidence_cubit.dart';

enum ApprovedEvidenceStatus { initial, loading, loaded, failure }

/// class name: [ApprovedEvidenceState]
///
/// purpose: the loaded data and the four filter selections. An empty set
///          means "All".
class ApprovedEvidenceState {
  final ApprovedEvidenceStatus status;
  final ApprovedEvidenceData? data;
  final String? message;

  final Set<int> years;
  final Set<String> departments;
  final Set<String> policyIds;

  /// "policyId/controlId" keys — see [ApprovedEvidenceData.controlKey].
  final Set<String> controlIds;

  const ApprovedEvidenceState({
    this.status = ApprovedEvidenceStatus.initial,
    this.data,
    this.message,
    this.years = const <int>{},
    this.departments = const <String>{},
    this.policyIds = const <String>{},
    this.controlIds = const <String>{},
  });

  bool get hasFilters =>
      years.isNotEmpty ||
      departments.isNotEmpty ||
      policyIds.isNotEmpty ||
      controlIds.isNotEmpty;

  /// The evidence the current filters select.
  List<ApprovedEvidenceItem> get selected =>
      data?.filter(
        years: years,
        departments: departments,
        policyIds: policyIds,
        controlIds: controlIds,
      ) ??
      const <ApprovedEvidenceItem>[];

  ApprovedEvidenceState copyWith({
    ApprovedEvidenceStatus? status,
    ApprovedEvidenceData? data,
    String? message,
    Set<int>? years,
    Set<String>? departments,
    Set<String>? policyIds,
    Set<String>? controlIds,
  }) {
    return ApprovedEvidenceState(
      status: status ?? this.status,
      data: data ?? this.data,
      message: message ?? this.message,
      years: years ?? this.years,
      departments: departments ?? this.departments,
      policyIds: policyIds ?? this.policyIds,
      controlIds: controlIds ?? this.controlIds,
    );
  }
}
