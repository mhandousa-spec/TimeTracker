// ****************** FILE INFO ******************
// File Name: crm_blacklist_item_model.dart
// Purpose: Normalized model for CRM Blacklisted clients and blacklist requests.
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_record_model.dart';

class CrmBlacklistItemModel {
  final String recordId;
  final String clientNameEn;
  final String clientNameAr;
  final String? photoUrl;
  final String clientType;
  final String clientTypeId;
  final String reason;
  final String requestedBy;
  final String requestedByName;
  final String date;
  final String time;
  final DateTime rawDate;
  final String status; // 'blocked', 'pending', 'approved', 'rejected'
  final CrmClientRecordModel clientRecord;

  const CrmBlacklistItemModel({
    required this.recordId,
    required this.clientNameEn,
    required this.clientNameAr,
    this.photoUrl,
    required this.clientType,
    required this.clientTypeId,
    required this.reason,
    required this.requestedBy,
    required this.requestedByName,
    required this.date,
    required this.time,
    required this.rawDate,
    required this.status,
    required this.clientRecord,
  });

  bool get isBlocked => status == 'blocked';
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  String get displayName =>
      clientNameEn.isNotEmpty ? clientNameEn : clientNameAr;

  /// Constructs a BlacklistItem from a CrmClientRecordModel
  factory CrmBlacklistItemModel.fromClientRecord(
    CrmClientRecordModel record, {
    String? clientTypeName,
    String? employeeDisplayName,
  }) {
    final DateTime eventDate =
        record.blacklistRequestedAt ?? record.audit.updatedAt;

    final String formattedDate =
        '${eventDate.day}/${eventDate.month}/${eventDate.year}';
    final int hour = eventDate.hour > 12
        ? eventDate.hour - 12
        : (eventDate.hour == 0 ? 12 : eventDate.hour);
    final String period = eventDate.hour >= 12 ? 'pm' : 'am';
    final String formattedTime =
        '$hour:${eventDate.minute.toString().padLeft(2, '0')} $period';

    final String enName = record.primaryDisplayValue ?? '';
    final String arName = record.secondaryDisplayValue ?? '';

    final String type = clientTypeName ??
        (record.clientTypeId.isNotEmpty ? record.clientTypeId : 'Person');

    final String reqBy = record.blacklistRequestedBy;
    final String reqByName = employeeDisplayName ??
        (reqBy.isNotEmpty ? reqBy.split('@').first : 'Staff');

    final dynamic photoVal = record.valueFor(null, 'photo') ??
        record.valueFor(null, 'logo') ??
        record.valueFor(null, 'avatar') ??
        record.valueFor(null, 'image');
    final String? photoUrl =
        photoVal is String && photoVal.isNotEmpty ? photoVal : null;

    final String removalStatus = (record.blacklistDetails[
                CrmClientRecordModel.blacklistRemovalStatusKey] ??
            '')
        .toString()
        .toLowerCase();

    String itemStatus = 'blocked';
    if (removalStatus == 'pending') {
      itemStatus = 'pending';
    } else if (removalStatus == 'approved') {
      itemStatus = 'approved';
    } else if (removalStatus == 'rejected') {
      itemStatus = 'rejected';
    } else if (record.isBlacklisted) {
      itemStatus = 'blocked';
    }

    return CrmBlacklistItemModel(
      recordId: record.id,
      clientNameEn: enName,
      clientNameAr: arName,
      photoUrl: photoUrl,
      clientType: type,
      clientTypeId: record.clientTypeId,
      reason: record.blacklistReason.isNotEmpty
          ? record.blacklistReason
          : 'Restricted account',
      requestedBy: reqBy,
      requestedByName: reqByName,
      date: formattedDate,
      time: formattedTime,
      rawDate: eventDate,
      status: itemStatus,
      clientRecord: record,
    );
  }
}
