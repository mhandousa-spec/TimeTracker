// ****************** FILE INFO ******************
// File Name: crm_term_clause_model.dart
// Purpose: Data model representing an individual bilingual term clause
// Author: Mohand Adel
// Created At: 16/08/2026
// ignore_for_file: constant_identifier_names

import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';

class CrmTermClauseModel {
  final String id;
  final String textEn;
  final String textAr;
  final int order;

  static const String ID = 'Id';
  static const String TEXT_EN = 'Text_En';
  static const String TEXT_AR = 'Text_Ar';
  static const String ORDER = 'Order';

  const CrmTermClauseModel({
    required this.id,
    required this.textEn,
    required this.textAr,
    this.order = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      CrmFirestoreKeys.ID_KEY: id,
      'Text_En': textEn,
      'Text_Ar': textAr,
      CrmFirestoreKeys.ORDER_KEY: order,
    };
  }

  factory CrmTermClauseModel.fromMap(Map<String, dynamic> map) {
    return CrmTermClauseModel(
      id: (CrmFirestoreKeys.read(map, CrmFirestoreKeys.ID_KEY, 'id') ?? '')
          .toString(),
      textEn: (CrmFirestoreKeys.read(map, 'Text_En', 'textEn') ??
              CrmFirestoreKeys.read(map, 'text_en', 'text') ??
              '')
          .toString(),
      textAr: (CrmFirestoreKeys.read(map, 'Text_Ar', 'textAr') ??
              CrmFirestoreKeys.read(map, 'text_ar', 'text_ar') ??
              '')
          .toString(),
      order: (CrmFirestoreKeys.read(map, CrmFirestoreKeys.ORDER_KEY, 'order') ??
          0) as int,
    );
  }

  factory CrmTermClauseModel.getEmptyModel() {
    return const CrmTermClauseModel(
      id: '',
      textEn: '',
      textAr: '',
      order: 0,
    );
  }

  CrmTermClauseModel copyWith({
    String? id,
    String? textEn,
    String? textAr,
    int? order,
  }) {
    return CrmTermClauseModel(
      id: id ?? this.id,
      textEn: textEn ?? this.textEn,
      textAr: textAr ?? this.textAr,
      order: order ?? this.order,
    );
  }

  String localizedText(bool isArabic) {
    if (isArabic) {
      return textAr.isNotEmpty ? textAr : textEn;
    }
    return textEn.isNotEmpty ? textEn : textAr;
  }
}
