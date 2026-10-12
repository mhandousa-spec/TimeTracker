// ******************* FILE INFO *******************
// File Name: state_model
// Description: DTO holding aggregated request-state statistics counters.
// Module: services_management_module / data / models
// *************************************************

class StateStatisticsModel {
  // ---- Firestore field keys ----


  // Firestore / JSON keys
  static const String kApproved = 'approved';
  static const String kCanceled = 'canceled';
  static const String kPending = 'pending';
  static const String kRejected = 'rejected';
  static const String kInProgress = 'inProgress';
  static const String kBreachedSla = 'breachedSLA';
  static const String kDone = 'done';

  final int approvedCount;
  final int cancelCount;
  final int pendingCount;
  final int rejectedCount;
  final int inProgressCount;
  final int branchSlaCount;
  final int doneCount;

  StateStatisticsModel({
    required this.approvedCount,
    required this.cancelCount,
    required this.pendingCount,
    required this.rejectedCount,
    required this.inProgressCount,
    required this.branchSlaCount,
    required this.doneCount,
  });

  factory StateStatisticsModel.fromJson(Map<String, dynamic> json) {
    return StateStatisticsModel(
      approvedCount: (json[kApproved] as num?)?.toInt() ?? 0,
      cancelCount: (json[kCanceled] as num?)?.toInt() ?? 0,
      pendingCount: (json[kPending] as num?)?.toInt() ?? 0,
      rejectedCount: (json[kRejected] as num?)?.toInt() ?? 0,
      inProgressCount: (json[kInProgress] as num?)?.toInt() ?? 0,
      branchSlaCount: (json[kBreachedSla] as num?)?.toInt() ?? 0,
      doneCount: (json[kDone] as num?)?.toInt() ?? 0,
    );
  }

  // Canonical map serialization (§10) — delegates to toJson()/fromJson().
  Map<String, dynamic> toMap() => toJson();

  factory StateStatisticsModel.fromMap(Map<String, dynamic> map) =>
      StateStatisticsModel.fromJson(map);

  Map<String, dynamic> toJson() {
    return {
      kApproved: approvedCount,
      kCanceled: cancelCount,
      kPending: pendingCount,
      kRejected: rejectedCount,
      kInProgress: inProgressCount,
      kBreachedSla: branchSlaCount,
      kDone: doneCount,
    };
  }

  StateStatisticsModel copyWith({
    int? approvedCount,
    int? cancelCount,
    int? pendingCount,
    int? rejectedCount,
    int? inProgressCount,
    int? branchSlaCount,
    int? doneCount,
  }) {
    return StateStatisticsModel(
      approvedCount: approvedCount ?? this.approvedCount,
      cancelCount: cancelCount ?? this.cancelCount,
      pendingCount: pendingCount ?? this.pendingCount,
      rejectedCount: rejectedCount ?? this.rejectedCount,
      inProgressCount: inProgressCount ?? this.inProgressCount,
      branchSlaCount: branchSlaCount ?? this.branchSlaCount,
      doneCount: doneCount ?? this.doneCount,
    );
  }

  String formatCount(int count) => count.toString().padLeft(2, '0');
}
