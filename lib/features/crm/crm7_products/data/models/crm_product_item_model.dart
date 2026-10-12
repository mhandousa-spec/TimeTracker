// ****************** FILE INFO ******************
// File Name: crm_product_item_model.dart
// Purpose: Data model for CRM Product Items with full serialization and pricing details.
// Author: Mohand Adel
// Created At: 23/08/2026
// ignore_for_file: constant_identifier_names

import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_audit_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';
import 'package:knowticed_plus/features/crm/crm7_products/domain/enums/crm_currency_enum.dart';

class CrmProductItemModel {
  static const String CODE_KEY = 'Code';
  static const String CATEGORY_ID_KEY = 'Category_Id';
  static const String CATEGORY_NAME_EN_KEY = 'Category_Name_En';
  static const String CATEGORY_NAME_AR_KEY = 'Category_Name_Ar';
  static const String UNIT_PRICE_KEY = 'Unit_Price';
  static const String CURRENCY_KEY = 'Currency';
  static const String TAX_KEY = 'Tax';
  static const String DISCOUNT_RULE_KEY = 'Discount_Rule';

  final String id;
  final String code;
  final String categoryId;
  final String categoryNameEn;
  final String categoryNameAr;
  final String nameEn;
  final String nameAr;
  final String noteEn;
  final String noteAr;
  final double unitPrice;
  final String currency;
  final double tax;
  final String discountRule;
  final String status;
  final bool isActive;
  final bool isDeleted;
  final int order;
  final CrmAuditModel? audit;

  const CrmProductItemModel({
    required this.id,
    this.code = '',
    required this.categoryId,
    this.categoryNameEn = '',
    this.categoryNameAr = '',
    required this.nameEn,
    required this.nameAr,
    this.noteEn = '',
    this.noteAr = '',
    this.unitPrice = 0.0,
    this.currency = 'EGP',
    this.tax = 0.0,
    this.discountRule = '',
    this.status = 'Active',
    this.isActive = true,
    this.isDeleted = false,
    this.order = 0,
    this.audit,
  });

  CrmCurrencyEnum get currencyEnum => CrmCurrencyEnum.fromCode(currency);

  /// Generates a standardized product code in format `CP-XXXXX`.
  static String generateCode([List<CrmProductItemModel>? existingProducts]) {
    if (existingProducts != null && existingProducts.isNotEmpty) {
      int maxNum = 0;
      for (final CrmProductItemModel p in existingProducts) {
        final String upper = p.code.toUpperCase().trim();
        if (upper.startsWith('CP-')) {
          final String digits = upper.substring(3).trim();
          final int? num = int.tryParse(digits);
          if (num != null && num > maxNum) {
            maxNum = num;
          }
        }
      }
      if (maxNum > 0) {
        return 'CP-${(maxNum + 1).toString().padLeft(5, '0')}';
      }
    }
    final int randomSuffix =
        10000 + (DateTime.now().millisecondsSinceEpoch % 90000);
    return 'CP-$randomSuffix';
  }

  factory CrmProductItemModel.empty() => const CrmProductItemModel(
        id: '',
        code: '',
        categoryId: '',
        categoryNameEn: '',
        categoryNameAr: '',
        nameEn: '',
        nameAr: '',
        noteEn: '',
        noteAr: '',
        unitPrice: 0.0,
        currency: 'EGP',
        tax: 0.0,
        discountRule: '',
        status: 'Active',
        isActive: true,
        isDeleted: false,
        order: 0,
      );

  factory CrmProductItemModel.fromMap(Map<String, dynamic> map) {
    return CrmProductItemModel(
      id: (map[CrmFirestoreKeys.ID_KEY] ?? '').toString(),
      code: (map[CODE_KEY] ?? '').toString(),
      categoryId: (map[CATEGORY_ID_KEY] ?? '').toString(),
      categoryNameEn: (map[CATEGORY_NAME_EN_KEY] ?? '').toString(),
      categoryNameAr: (map[CATEGORY_NAME_AR_KEY] ?? '').toString(),
      nameEn: (map[CrmFirestoreKeys.NAME_EN_KEY] ?? '').toString(),
      nameAr: (map[CrmFirestoreKeys.NAME_AR_KEY] ?? '').toString(),
      noteEn: (map[CrmFirestoreKeys.NOTE_EN_KEY] ?? '').toString(),
      noteAr: (map[CrmFirestoreKeys.NOTE_AR_KEY] ?? '').toString(),
      unitPrice: (map[UNIT_PRICE_KEY] as num?)?.toDouble() ?? 0.0,
      currency: (map[CURRENCY_KEY] ?? 'EGP').toString(),
      tax: (map[TAX_KEY] as num?)?.toDouble() ?? 0.0,
      discountRule: (map[DISCOUNT_RULE_KEY] ?? '').toString(),
      status: (map[CrmFirestoreKeys.STATUS_KEY] ?? 'Active').toString(),
      isActive: map[CrmFirestoreKeys.IS_ACTIVE_KEY] == true,
      isDeleted: map[CrmFirestoreKeys.IS_DELETED_KEY] == true,
      order: (map[CrmFirestoreKeys.ORDER_KEY] as num?)?.toInt() ?? 0,
      audit: map[CrmFirestoreKeys.AUDIT_KEY] is Map<String, dynamic>
          ? CrmAuditModel.fromMap(
              map[CrmFirestoreKeys.AUDIT_KEY] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        CrmFirestoreKeys.ID_KEY: id,
        CODE_KEY: code,
        CATEGORY_ID_KEY: categoryId,
        CATEGORY_NAME_EN_KEY: categoryNameEn,
        CATEGORY_NAME_AR_KEY: categoryNameAr,
        CrmFirestoreKeys.NAME_EN_KEY: nameEn,
        CrmFirestoreKeys.NAME_AR_KEY: nameAr,
        CrmFirestoreKeys.NOTE_EN_KEY: noteEn,
        CrmFirestoreKeys.NOTE_AR_KEY: noteAr,
        UNIT_PRICE_KEY: unitPrice,
        CURRENCY_KEY: currency,
        TAX_KEY: tax,
        DISCOUNT_RULE_KEY: discountRule,
        CrmFirestoreKeys.STATUS_KEY: status,
        CrmFirestoreKeys.IS_ACTIVE_KEY: isActive,
        CrmFirestoreKeys.IS_DELETED_KEY: isDeleted,
        CrmFirestoreKeys.ORDER_KEY: order,
        if (audit != null) CrmFirestoreKeys.AUDIT_KEY: audit!.toMap(),
      };

  CrmProductItemModel copyWith({
    String? id,
    String? code,
    String? categoryId,
    String? categoryNameEn,
    String? categoryNameAr,
    String? nameEn,
    String? nameAr,
    String? noteEn,
    String? noteAr,
    double? unitPrice,
    String? currency,
    double? tax,
    String? discountRule,
    String? status,
    bool? isActive,
    bool? isDeleted,
    int? order,
    CrmAuditModel? audit,
  }) =>
      CrmProductItemModel(
        id: id ?? this.id,
        code: code ?? this.code,
        categoryId: categoryId ?? this.categoryId,
        categoryNameEn: categoryNameEn ?? this.categoryNameEn,
        categoryNameAr: categoryNameAr ?? this.categoryNameAr,
        nameEn: nameEn ?? this.nameEn,
        nameAr: nameAr ?? this.nameAr,
        noteEn: noteEn ?? this.noteEn,
        noteAr: noteAr ?? this.noteAr,
        unitPrice: unitPrice ?? this.unitPrice,
        currency: currency ?? this.currency,
        tax: tax ?? this.tax,
        discountRule: discountRule ?? this.discountRule,
        status: status ?? this.status,
        isActive: isActive ?? this.isActive,
        isDeleted: isDeleted ?? this.isDeleted,
        order: order ?? this.order,
        audit: audit ?? this.audit,
      );

  String localizedName(bool isArabic) =>
      isArabic && nameAr.isNotEmpty ? nameAr : nameEn;

  String localizedCategoryName(bool isArabic) =>
      isArabic && categoryNameAr.isNotEmpty ? categoryNameAr : categoryNameEn;
}
