// ****************** FILE INFO ******************
// File Name: crm_stage_checklist_item_model.dart
// Purpose: Data model for CRM Deal Stage checklist progress items
// Author: Mohand Adel
// Created At: 22/08/2026

// ignore_for_file: constant_identifier_names

import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';

class CrmStageChecklistItemModel {
  final String nameEn;
  final String nameAr;

  static const String NAME_EN = 'Name_En';
  static const String NAME_AR = 'Name_Ar';

  const CrmStageChecklistItemModel({
    required this.nameEn,
    required this.nameAr,
  });

  /// Function Name: getEmptyModel
  ///
  /// Purpose: Factory constructor returning a default empty checklist item.
  ///
  /// Returns: CrmStageChecklistItemModel
  factory CrmStageChecklistItemModel.getEmptyModel() {
    return const CrmStageChecklistItemModel(
      nameEn: '',
      nameAr: '',
    );
  }

  /// Function Name: toMap
  ///
  /// Purpose: Serializes the checklist item model into a Firestore map.
  ///
  /// Returns: `Map<String, dynamic>`
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      CrmFirestoreKeys.NAME_EN_KEY: nameEn,
      CrmFirestoreKeys.NAME_AR_KEY: nameAr,
    };
  }

  /// Function Name: fromMap
  ///
  /// Purpose: Deserializes Firestore map data into a CrmStageChecklistItemModel instance.
  ///
  /// Parameters:
  /// - map: Firestore map representation of a checklist item.
  ///
  /// Returns: CrmStageChecklistItemModel
  factory CrmStageChecklistItemModel.fromMap(Map<String, dynamic> map) {
    return CrmStageChecklistItemModel(
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
    );
  }

  /// Function Name: copyWith
  ///
  /// Purpose: Creates an immutable copy of the checklist item with optional field replacements.
  ///
  /// Parameters:
  /// - nameEn: Optional updated English name.
  /// - nameAr: Optional updated Arabic name.
  ///
  /// Returns: CrmStageChecklistItemModel
  CrmStageChecklistItemModel copyWith({
    String? nameEn,
    String? nameAr,
  }) {
    return CrmStageChecklistItemModel(
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
    );
  }
}
