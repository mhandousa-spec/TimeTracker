// ****************** FILE INFO ******************
// File Name: crm_category_type_model.dart
// Purpose: Data model for individual types under an Activity Category
// Author: Mohand Adel
// Created At: 17/08/2026

import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';

class CrmCategoryTypeModel {
  final String id;
  final String nameEn;
  final String nameAr;

  const CrmCategoryTypeModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
  });

  String localizedName(bool isArabic) {
    if (isArabic) {
      return nameAr.isNotEmpty ? nameAr : nameEn;
    }
    return nameEn.isNotEmpty ? nameEn : nameAr;
  }

  factory CrmCategoryTypeModel.getEmptyModel() {
    return const CrmCategoryTypeModel(
      id: '',
      nameEn: '',
      nameAr: '',
    );
  }

  factory CrmCategoryTypeModel.fromMap(Map<String, dynamic> map) {
    return CrmCategoryTypeModel(
      id: (map[CrmFirestoreKeys.ID_KEY] ?? '').toString(),
      nameEn: (map[CrmFirestoreKeys.NAME_EN_KEY] ?? '').toString(),
      nameAr: (map[CrmFirestoreKeys.NAME_AR_KEY] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      CrmFirestoreKeys.ID_KEY: id,
      CrmFirestoreKeys.NAME_EN_KEY: nameEn,
      CrmFirestoreKeys.NAME_AR_KEY: nameAr,
    };
  }

  CrmCategoryTypeModel copyWith({
    String? id,
    String? nameEn,
    String? nameAr,
  }) {
    return CrmCategoryTypeModel(
      id: id ?? this.id,
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
    );
  }
}
