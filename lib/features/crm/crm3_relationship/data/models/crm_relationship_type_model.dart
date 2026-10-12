// ****************** FILE INFO ******************
// File Name: crm_relationship_type_model.dart
// Purpose: Data model representing a sub-type under a relationship category
// Author: Mohand Adel
// Created At: 12/08/2026
// ignore_for_file: constant_identifier_names

import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';

class CrmRelationshipTypeModel {
  final String id;
  final String nameEn;
  final String nameAr;

  static const String ID = 'Id';
  static const String NAME_EN = 'Name_En';
  static const String NAME_AR = 'Name_Ar';

  const CrmRelationshipTypeModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
  });

  Map<String, dynamic> toMap() {
    return {
      CrmFirestoreKeys.ID_KEY: id,
      CrmFirestoreKeys.NAME_EN_KEY: nameEn,
      CrmFirestoreKeys.NAME_AR_KEY: nameAr,
    };
  }

  factory CrmRelationshipTypeModel.fromMap(Map<String, dynamic> map) {
    return CrmRelationshipTypeModel(
      id: (CrmFirestoreKeys.read(map, CrmFirestoreKeys.ID_KEY, 'id') ?? '')
          .toString(),
      nameEn:
          (CrmFirestoreKeys.read(map, CrmFirestoreKeys.NAME_EN_KEY, 'nameEn') ??
                  '')
              .toString(),
      nameAr:
          (CrmFirestoreKeys.read(map, CrmFirestoreKeys.NAME_AR_KEY, 'nameAr') ??
                  '')
              .toString(),
    );
  }

  CrmRelationshipTypeModel copyWith({
    String? id,
    String? nameEn,
    String? nameAr,
  }) {
    return CrmRelationshipTypeModel(
      id: id ?? this.id,
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
    );
  }
}
