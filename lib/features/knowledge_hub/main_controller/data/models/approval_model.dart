/// Module: knowledge_hub / core/data/models/approval_model.dart
import 'dart:developer';
/// ************************* FILE INFO *************************** ///
/// File Name: approval_model.dart
/// Purpose: Contains the model class for approval tracking.
/// Author: Youssef Khaled
/// Created At: 26/10/2025

class ApprovalModel {
  // ✅ SHARED timestamps for ALL fields
  final List<int> timestamps;

  // Core fields - Direct lists!
  final List<String> knowledgeId;
  final List<String> status;
  final List<String> rejectionReason;
  final List<String> approvalJustification;

  ApprovalModel({
    required this.timestamps,
    required this.knowledgeId,
    required this.status,
    required this.rejectionReason,
    required this.approvalJustification,
  });

  // ✅ Helper getters for current (latest) values
  String get currentKnowledgeId => knowledgeId.isNotEmpty ? knowledgeId.last : '';
  String get currentStatus => status.isNotEmpty ? status.last : '';
  String get currentRejectionReason => rejectionReason.isNotEmpty ? rejectionReason.last : '';
  String get currentApprovalJustification => approvalJustification.isNotEmpty ? approvalJustification.last : '';

  // ✅ Get timestamp at specific index
  int? getTimestampAt(int index) => index < timestamps.length ? timestamps[index] : null;

  // ✅ Get current (latest) timestamp
  int? get currentTimestamp => timestamps.isNotEmpty ? timestamps.last : null;

  // Factory: Create from JSON
  factory ApprovalModel.fromJson(Map<String, dynamic> json, [String? docId]) {
      // ✅ Parse shared timestamps first
      final List<int> sharedTimestamps = (json['timestamps'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList() ?? [DateTime.now().millisecondsSinceEpoch];

      return ApprovalModel(
        timestamps: sharedTimestamps,
        knowledgeId: _parseList<String>(json['knowledgeId'], (v) => v as String? ?? ''),
        status: _parseList<String>(json['status'], (v) => v as String? ?? ''),
        rejectionReason: _parseList<String>(json['rejectionReason'], (v) => v as String? ?? ''),
        approvalJustification: _parseList<String>(json['approvalJustification'], (v) => v as String? ?? ''),
      );
  }

  // Helper: Parse list (handles multiple legacy formats)
  static List<T> _parseList<T>(dynamic value, T Function(dynamic) deserializer) {
    // If it's already a list
    if (value is List) {
      return value.map((e) => deserializer(e)).toList();
    }

    // Legacy format with FieldHistory: {timestamps: [...], values: [...]}
    if (value is Map<String, dynamic> && value.containsKey('values')) {
      final values = value['values'];
      if (values is List) {
        return values.map((e) => deserializer(e)).toList();
      }
    }

    // Legacy format: {value: ..., timestamp: ...}
    if (value is Map<String, dynamic> && value.containsKey('value')) {
      return [deserializer(value['value'])];
    }

    // Simple value
    return [deserializer(value)];
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'timestamps': timestamps,
      'knowledgeId': knowledgeId,
      'status': status,
      'rejectionReason': rejectionReason,
      'approvalJustification': approvalJustification,
    };
  }

  // Factory: Create with initial values
  factory ApprovalModel.createNew({
    required String knowledgeId,
    required String status,
    String? rejectionReason,
    String? approvalJustification,
  }) {
    return ApprovalModel(
      timestamps: [DateTime.now().millisecondsSinceEpoch],
      knowledgeId: [knowledgeId],
      status: [status],
      rejectionReason: [rejectionReason ?? ''],
      approvalJustification: [approvalJustification ?? ''],
    );
  }

  // copyWith method - adds new timestamp and new values
  ApprovalModel copyWith({
    String? knowledgeId,
    String? status,
    String? rejectionReason,
    String? approvalJustification,
  }) {
    // ✅ Add new timestamp
    final newTimestamps = List<int>.from(timestamps)..add(DateTime.now().millisecondsSinceEpoch);

    return ApprovalModel(
      timestamps: newTimestamps,
      knowledgeId: knowledgeId != null ? (List<String>.from(this.knowledgeId)..add(knowledgeId)) : this.knowledgeId,
      status: status != null ? (List<String>.from(this.status)..add(status)) : this.status,
      rejectionReason: rejectionReason != null ? (List<String>.from(this.rejectionReason)..add(rejectionReason)) : this.rejectionReason,
      approvalJustification: approvalJustification != null ? (List<String>.from(this.approvalJustification)..add(approvalJustification)) : this.approvalJustification,
    );
  }

  // Update methods - add new values to lists
  void updateStatus(String newStatus) {
    timestamps.add(DateTime.now().millisecondsSinceEpoch);
    status.add(newStatus);
  }

  void updateRejectionReason(String reason) {
    timestamps.add(DateTime.now().millisecondsSinceEpoch);
    rejectionReason.add(reason);
  }

  void updateApprovalJustification(String justification) {
    timestamps.add(DateTime.now().millisecondsSinceEpoch);
    approvalJustification.add(justification);
  }

  void updateApproval({
    String? newStatus,
    String? reason,
    String? justification,
  }) {
    timestamps.add(DateTime.now().millisecondsSinceEpoch);
    if (newStatus != null) status.add(newStatus);
    if (reason != null) rejectionReason.add(reason);
    if (justification != null) approvalJustification.add(justification);
  }
}