// ******************* FILE INFO *******************
// File Name: service_stats_model
// Description: Service stats model.
// Module: services_management_module / presentation/s5_service_details/data
// *************************************************

class ServiceStatsModel {
  // ---- Map keys (§10) ----
  static const String kDone = 'done';
  static const String kApproved = 'approved';
  static const String kInProgress = 'inprogress';
  static const String kPending = 'pending';
  static const String kRejected = 'rejected';
  static const String kCancel = 'cancel';
  static const String kBranchSla = 'branchsla';

  final int done;
  final int approved;
  final int inprogress;
  final int pending;
  final int rejected;
  final int cancel;
  final int branchsla;

  ServiceStatsModel({
    required this.done,
    required this.approved,
    required this.inprogress,
    required this.pending,
    required this.rejected,
    required this.cancel,
    required this.branchsla,
  });

  factory ServiceStatsModel.empty() {
    return ServiceStatsModel(
      done: 0,
      approved: 0,
      inprogress: 0,
      pending: 0,
      rejected: 0,
      cancel: 0,
      branchsla: 0,
    );
  }

  factory ServiceStatsModel.fromMap(Map<String, int> map) {
    return ServiceStatsModel(
      done: map[kDone] ?? 0,
      approved: map[kApproved] ?? 0,
      inprogress: map[kInProgress] ?? 0,
      pending: map[kPending] ?? 0,
      rejected: map[kRejected] ?? 0,
      cancel: map[kCancel] ?? 0,
      branchsla: map[kBranchSla] ?? 0,
    );
  }

  Map<String, int> toMap() {
    return {
      kDone: done,
      kApproved: approved,
      kInProgress: inprogress,
      kPending: pending,
      kRejected: rejected,
      kCancel: cancel,
      kBranchSla: branchsla,
    };
  }

  ServiceStatsModel copyWith({
    int? done,
    int? approved,
    int? inprogress,
    int? pending,
    int? rejected,
    int? cancel,
    int? branchsla,
  }) {
    return ServiceStatsModel(
      done: done ?? this.done,
      approved: approved ?? this.approved,
      inprogress: inprogress ?? this.inprogress,
      pending: pending ?? this.pending,
      rejected: rejected ?? this.rejected,
      cancel: cancel ?? this.cancel,
      branchsla: branchsla ?? this.branchsla,
    );
  }
}