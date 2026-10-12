// ****************** FILE INFO ******************
// File Name: crm_deal_stage_model.dart
// Purpose: Data model for CRM Deal Stages with Firestore serialization and checklist items
// Author: Mohand Adel
// Created At: 22/08/2026

// ignore_for_file: constant_identifier_names

import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_audit_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_stage_checklist_item_model.dart';

class CrmDealStageModel {
  final String id;
  final String nameEn;
  final String nameAr;
  final String status;
  final int probability;
  final String color;
  final int order;
  final bool isDeleted;
  final List<CrmStageChecklistItemModel> checklistItems;
  final CrmAuditModel? audit;

  static const String ID = 'Id';
  static const String NAME_EN = 'Name_En';
  static const String NAME_AR = 'Name_Ar';
  static const String STATUS = 'Status';
  static const String PROBABILITY = 'Probability';
  static const String COLOR = 'Color';
  static const String ORDER = 'Order';
  static const String IS_DELETED = 'Is_Deleted';
  static const String CHECKLIST_ITEMS = 'Checklist_Items';
  static const String AUDIT = 'Audit';

  const CrmDealStageModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    this.status = 'active',
    this.probability = 0,
    this.color = '',
    this.order = 0,
    this.isDeleted = false,
    this.checklistItems = const <CrmStageChecklistItemModel>[],
    this.audit,
  });

  bool get isActive => status.toLowerCase() == 'active';
  bool get isInactive => !isActive;

  /// Function Name: getEmptyModel
  ///
  /// Purpose: Factory constructor returning a default empty stage model.
  ///
  /// Returns: CrmDealStageModel
  factory CrmDealStageModel.getEmptyModel() {
    return const CrmDealStageModel(
      id: '',
      nameEn: '',
      nameAr: '',
      status: 'active',
      probability: 0,
      color: '',
      order: 0,
      isDeleted: false,
      checklistItems: <CrmStageChecklistItemModel>[],
    );
  }

  /// Function Name: toMap
  ///
  /// Purpose: Serializes the stage model to a Firestore map.
  ///
  /// Returns: `Map<String, dynamic>`
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic>{
      CrmFirestoreKeys.ID_KEY: id,
      CrmFirestoreKeys.NAME_EN_KEY: nameEn,
      CrmFirestoreKeys.NAME_AR_KEY: nameAr,
      CrmFirestoreKeys.STATUS_KEY: status,
      CrmFirestoreKeys.PROBABILITY_KEY: probability,
      CrmFirestoreKeys.COLOR_KEY: color,
      CrmFirestoreKeys.ORDER_KEY: order,
      CrmFirestoreKeys.IS_DELETED_KEY: isDeleted,
      CrmFirestoreKeys.CHECKLIST_ITEMS_KEY:
          checklistItems.map((item) => item.toMap()).toList(),
    };
    if (audit != null) {
      map[CrmFirestoreKeys.AUDIT_KEY] = audit!.toMap();
    }
    return map;
  }

  /// Function Name: fromMap
  ///
  /// Purpose: Deserializes Firestore map data into a CrmDealStageModel instance.
  ///
  /// Parameters:
  /// - map: Firestore document map.
  ///
  /// Returns: CrmDealStageModel
  factory CrmDealStageModel.fromMap(Map<String, dynamic> map) {
    CrmAuditModel? auditModel;
    final dynamic rawAudit = CrmFirestoreKeys.read(
      map,
      CrmFirestoreKeys.AUDIT_KEY,
      'audit',
    );
    if (rawAudit is Map<String, dynamic>) {
      auditModel = CrmAuditModel.fromMap(rawAudit);
    }

    final dynamic rawChecklist = CrmFirestoreKeys.read(
      map,
      CrmFirestoreKeys.CHECKLIST_ITEMS_KEY,
      'checklistItems',
    );
    List<CrmStageChecklistItemModel> items = <CrmStageChecklistItemModel>[];
    if (rawChecklist is List) {
      items = rawChecklist
          .whereType<Map<String, dynamic>>()
          .map((m) => CrmStageChecklistItemModel.fromMap(m))
          .toList();
    }

    return CrmDealStageModel(
      id: (CrmFirestoreKeys.read(map, CrmFirestoreKeys.ID_KEY, 'id') ?? '')
          .toString(),
      nameEn: (CrmFirestoreKeys.read(
                map,
                CrmFirestoreKeys.NAME_EN_KEY,
                'nameEn',
              ) ??
              '')
          .toString(),
      nameAr: (CrmFirestoreKeys.read(
                map,
                CrmFirestoreKeys.NAME_AR_KEY,
                'nameAr',
              ) ??
              '')
          .toString(),
      status: (CrmFirestoreKeys.read(
                map,
                CrmFirestoreKeys.STATUS_KEY,
                'status',
              ) ??
              'active')
          .toString(),
      probability: _asInt(
        CrmFirestoreKeys.read(
          map,
          CrmFirestoreKeys.PROBABILITY_KEY,
          'probability',
        ),
      ),
      color: (CrmFirestoreKeys.read(map, CrmFirestoreKeys.COLOR_KEY, 'color') ??
              '')
          .toString(),
      order: _asInt(
        CrmFirestoreKeys.read(map, CrmFirestoreKeys.ORDER_KEY, 'order'),
      ),
      isDeleted: CrmFirestoreKeys.read(
            map,
            CrmFirestoreKeys.IS_DELETED_KEY,
            'isDeleted',
          ) ==
          true,
      checklistItems: items,
      audit: auditModel,
    );
  }

  /// Function Name: copyWith
  ///
  /// Purpose: Creates an immutable copy of the stage with updated fields.
  ///
  /// Parameters:
  /// - id: Optional stage ID.
  /// - nameEn: Optional English name.
  /// - nameAr: Optional Arabic name.
  /// - status: Optional active/inactive status.
  /// - probability: Optional deal probability percentage.
  /// - color: Optional theme color code.
  /// - order: Optional display sequence number.
  /// - isDeleted: Optional soft-deletion flag.
  /// - checklistItems: Optional list of checklist items.
  /// - audit: Optional audit timestamps.
  ///
  /// Returns: CrmDealStageModel
  CrmDealStageModel copyWith({
    String? id,
    String? nameEn,
    String? nameAr,
    String? status,
    int? probability,
    String? color,
    int? order,
    bool? isDeleted,
    List<CrmStageChecklistItemModel>? checklistItems,
    CrmAuditModel? audit,
  }) {
    return CrmDealStageModel(
      id: id ?? this.id,
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
      status: status ?? this.status,
      probability: probability ?? this.probability,
      color: color ?? this.color,
      order: order ?? this.order,
      isDeleted: isDeleted ?? this.isDeleted,
      checklistItems: checklistItems ?? this.checklistItems,
      audit: audit ?? this.audit,
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
