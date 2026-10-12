// ****************** FILE INFO ******************
// File Name: crm_client_record_model.dart
// Purpose: Data model representing a saved CRM client record keyed by field ids
// Author: Mohand Adel
// Created At: 08/08/2026

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_audit_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/utils/crm_client_blacklist_details_parser.dart';

/// A single saved client record produced by the dynamic form engine.
///
/// The [values] map is ALWAYS keyed by `field.id` (or the deterministic
/// `systemKey` for default fields) — never by localized display labels. This
/// keeps existing client data intact when field names change inside
/// `crm2_controls`.
class CrmClientRecordModel {
  final String id;
  final String clientTypeId;
  final String templateId;
  final int templateVersion;
  final String status; // active, archived, deleted
  final String? mergedIntoId;
  final Map<String, dynamic> values;
  final Map<String, dynamic> blacklistDetails;
  final CrmAuditModel audit;

  static const String blacklistDetailsKey = 'Blacklist_Details';
  static const String blacklistReasonKey = 'Reason';
  static const String blacklistRequestedAtKey = 'Requested_At';
  static const String blacklistRequestedByKey = 'Requested_By';
  static const String blacklistRemovalReasonKey = 'Removal_Reason';
  static const String blacklistRemovalRequestedAtKey = 'Removal_Requested_At';
  static const String blacklistRemovalRequestedByKey = 'Removal_Requested_By';
  static const String blacklistRemovalStatusKey = 'Removal_Status';

  const CrmClientRecordModel({
    required this.id,
    required this.clientTypeId,
    required this.templateId,
    required this.templateVersion,
    this.status = 'active',
    this.mergedIntoId,
    required this.values,
    this.blacklistDetails = const {},
    required this.audit,
  });

  Map<String, dynamic> toMap() => {
        CrmFirestoreKeys.ID_KEY: id,
        CrmFirestoreKeys.CLIENT_TYPE_ID_KEY: clientTypeId,
        CrmFirestoreKeys.TEMPLATE_ID_KEY: templateId,
        CrmFirestoreKeys.TEMPLATE_VERSION_KEY: templateVersion,
        CrmFirestoreKeys.STATUS_KEY: status,
        if (mergedIntoId != null)
          CrmFirestoreKeys.MERGED_INTO_ID_KEY: mergedIntoId,
        CrmFirestoreKeys.VALUES_KEY: values,
        if (blacklistDetails.isNotEmpty) blacklistDetailsKey: blacklistDetails,
        CrmFirestoreKeys.AUDIT_KEY: audit.toMap(),
      };

  factory CrmClientRecordModel.fromMap(Map<String, dynamic> map) {
    final Map<String, dynamic> resolvedBlacklistDetails =
        CrmClientBlacklistDetailsParser.fromMap(map);
    return CrmClientRecordModel(
      id: (CrmFirestoreKeys.read(map, CrmFirestoreKeys.ID_KEY, 'id') ?? '')
          .toString(),
      clientTypeId: (CrmFirestoreKeys.read(
                map,
                CrmFirestoreKeys.CLIENT_TYPE_ID_KEY,
                'clientTypeId',
              ) ??
              '')
          .toString(),
      templateId: (CrmFirestoreKeys.read(
                map,
                CrmFirestoreKeys.TEMPLATE_ID_KEY,
                'templateId',
              ) ??
              '')
          .toString(),
      templateVersion: (CrmFirestoreKeys.read(
            map,
            CrmFirestoreKeys.TEMPLATE_VERSION_KEY,
            'templateVersion',
          ) as num?)
              ?.toInt() ??
          1,
      status:
          (CrmFirestoreKeys.read(map, CrmFirestoreKeys.STATUS_KEY, 'status') ??
                  'active')
              .toString(),
      mergedIntoId: CrmFirestoreKeys.read(
        map,
        CrmFirestoreKeys.MERGED_INTO_ID_KEY,
        'mergedIntoId',
      )?.toString(),
      values: Map<String, dynamic>.from(
        CrmFirestoreKeys.read(map, CrmFirestoreKeys.VALUES_KEY, 'values')
                as Map? ??
            const {},
      ),
      blacklistDetails: resolvedBlacklistDetails,
      audit: CrmAuditModel.fromMap(
        Map<String, dynamic>.from(
          CrmFirestoreKeys.read(map, CrmFirestoreKeys.AUDIT_KEY, 'audit')
                  as Map? ??
              const {},
        ),
      ),
    );
  }

  CrmClientRecordModel copyWith({
    String? id,
    String? clientTypeId,
    String? templateId,
    int? templateVersion,
    String? status,
    String? mergedIntoId,
    bool clearMergedIntoId = false,
    Map<String, dynamic>? values,
    Map<String, dynamic>? blacklistDetails,
    CrmAuditModel? audit,
  }) {
    return CrmClientRecordModel(
      id: id ?? this.id,
      clientTypeId: clientTypeId ?? this.clientTypeId,
      templateId: templateId ?? this.templateId,
      templateVersion: templateVersion ?? this.templateVersion,
      status: status ?? this.status,
      mergedIntoId:
          clearMergedIntoId ? null : (mergedIntoId ?? this.mergedIntoId),
      values: values ?? this.values,
      blacklistDetails: blacklistDetails ?? this.blacklistDetails,
      audit: audit ?? this.audit,
    );
  }

  /// Looks up a value by `field.id` first, then falls back to a deterministic
  /// `systemKey` suffix match (default field ids end with `_<systemKey>`).
  dynamic valueFor(dynamic fieldId, [String? systemKey]) {
    final String? key = fieldId?.toString();
    if (key != null && values.containsKey(key)) return values[key];
    if (systemKey == null || systemKey.isEmpty) return null;
    if (values.containsKey(systemKey)) return values[systemKey];
    for (final MapEntry<String, dynamic> entry in values.entries) {
      if (entry.key.endsWith('_$systemKey')) return entry.value;
    }
    return null;
  }

  /// Primary display value used as the card title in the clients list. Prefers
  /// the standard name system keys, then falls back to the first non-empty
  /// scalar value.
  String? get primaryDisplayValue {
    for (final String systemKey in const [
      'first_name',
      'last_name',
      'company_name',
      'entity_name'
    ]) {
      final dynamic value = valueFor(null, systemKey);
      final String text = _stringify(value);
      if (text.isNotEmpty) return text;
    }
    for (final dynamic value in values.values) {
      final String text = _stringify(value);
      if (text.isNotEmpty) return text;
    }
    return null;
  }

  /// Secondary display value (email or phone) shown under the card title.
  String? get secondaryDisplayValue {
    for (final String systemKey in const ['email', 'phone_number', 'phone']) {
      final String text = _stringify(valueFor(null, systemKey));
      if (text.isNotEmpty) return text;
    }
    return null;
  }

  bool get isBlacklisted => status.toLowerCase() == 'blacklist';

  String get blacklistReason =>
      (blacklistDetails[blacklistReasonKey] ?? '').toString();

  String get blacklistRequestedBy =>
      (blacklistDetails[blacklistRequestedByKey] ?? '').toString();

  DateTime? get blacklistRequestedAt =>
      _dateValue(blacklistDetails[blacklistRequestedAtKey]);

  static DateTime? _dateValue(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return value is String ? DateTime.tryParse(value) : null;
  }

  static String _stringify(dynamic value) {
    if (value == null) return '';
    if (value is Map) {
      final String english = (value['en'] ?? value['EN'] ?? '').toString();
      if (english.trim().isNotEmpty) return english.trim();
      final String arabic = (value['ar'] ?? value['AR'] ?? '').toString();
      return arabic.trim();
    }
    if (value is List) return '';
    return value.toString().trim();
  }
}
