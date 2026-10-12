// ****************** FILE INFO ******************
// File Name: crm_discount_model.dart
// Purpose: Data model representing a CRM Discount Rule
// Author: Mohand Adel
// Created At: 23/08/2026
// ignore_for_file: constant_identifier_names

import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_audit_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';

class CrmDiscountModel {
  final String id;
  final String nameEn;
  final String nameAr;
  final String type; // 'Service', 'Product', 'Both'
  final String categoryId;
  final String categoryNameEn;
  final String categoryNameAr;
  final String productId;
  final String productNameEn;
  final String productNameAr;
  final int minQuantity;
  final int maxQuantity;
  final double discountValue;
  final String discountType; // 'percentage', 'fixed'
  final String applyOnTeam;
  final String clientTypeId;
  final String clientTypeName;
  final List<String> tags;
  final String status; // 'active', 'inactive', 'deleted'
  final bool isActive;
  final bool isDeleted;
  final int order;
  final CrmAuditModel? audit;

  static const String ID = 'Id';
  static const String NAME_EN = 'Name_En';
  static const String NAME_AR = 'Name_Ar';
  static const String TYPE = 'Type';
  static const String CATEGORY_ID = 'Category_Id';
  static const String CATEGORY_NAME_EN = 'Category_Name_En';
  static const String CATEGORY_NAME_AR = 'Category_Name_Ar';
  static const String PRODUCT_ID = 'Product_Id';
  static const String PRODUCT_NAME_EN = 'Product_Name_En';
  static const String PRODUCT_NAME_AR = 'Product_Name_Ar';
  static const String MIN_QUANTITY = 'Min_Quantity';
  static const String MAX_QUANTITY = 'Max_Quantity';
  static const String DISCOUNT_VALUE = 'Discount_Value';
  static const String DISCOUNT_TYPE = 'Discount_Type';
  static const String APPLY_ON_TEAM = 'Apply_On_Team';
  static const String CLIENT_TYPE_ID = 'Client_Type_Id';
  static const String CLIENT_TYPE_NAME = 'Client_Type_Name';
  static const String TAGS = 'Tags';
  static const String STATUS = 'Status';
  static const String IS_ACTIVE = 'Is_Active';
  static const String IS_DELETED = 'Is_Deleted';
  static const String ORDER = 'Order';
  static const String AUDIT = 'Audit';

  const CrmDiscountModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    this.type = 'Service',
    this.categoryId = '',
    this.categoryNameEn = '',
    this.categoryNameAr = '',
    this.productId = '',
    this.productNameEn = '',
    this.productNameAr = '',
    this.minQuantity = 0,
    this.maxQuantity = 0,
    this.discountValue = 0.0,
    this.discountType = 'percentage',
    this.applyOnTeam = '',
    this.clientTypeId = '',
    this.clientTypeName = '',
    this.tags = const <String>[],
    this.status = 'active',
    this.isActive = true,
    this.isDeleted = false,
    this.order = 0,
    this.audit,
  });

  String localizedName(bool isArabic) {
    if (isArabic) {
      return nameAr.isNotEmpty ? nameAr : nameEn;
    }
    return nameEn.isNotEmpty ? nameEn : nameAr;
  }

  String localizedCategoryName(bool isArabic) {
    if (isArabic) {
      return categoryNameAr.isNotEmpty ? categoryNameAr : categoryNameEn;
    }
    return categoryNameEn.isNotEmpty ? categoryNameEn : categoryNameAr;
  }

  String localizedProductName(bool isArabic) {
    if (isArabic) {
      return productNameAr.isNotEmpty ? productNameAr : productNameEn;
    }
    return productNameEn.isNotEmpty ? productNameEn : productNameAr;
  }

  String get formattedDiscountValue {
    if (discountType == 'percentage' || discountType == '%') {
      return '${discountValue.toStringAsFixed(discountValue.truncateToDouble() == discountValue ? 0 : 2)}%';
    }
    return discountValue.toStringAsFixed(
        discountValue.truncateToDouble() == discountValue ? 0 : 2);
  }

  String get displayType => type.isNotEmpty ? type : 'Service';

  String get displayTeam => applyOnTeam.isNotEmpty ? applyOnTeam : 'All Teams';

  String get editorName {
    if (audit == null) return 'Admin';
    final String by =
        audit!.updatedBy.isNotEmpty ? audit!.updatedBy : audit!.createdBy;
    if (by.contains('@')) {
      final String username = by.split('@').first;
      return username
          .split('.')
          .map((String part) => part.isNotEmpty
              ? '${part[0].toUpperCase()}${part.substring(1)}'
              : '')
          .join(' ');
    }
    return by.isNotEmpty ? by : 'Admin';
  }

  String get lastUpdateFormatted {
    if (audit == null) return '';
    final DateTime dt = audit!.updatedAt;
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      CrmFirestoreKeys.ID_KEY: id,
      CrmFirestoreKeys.NAME_EN_KEY: nameEn,
      CrmFirestoreKeys.NAME_AR_KEY: nameAr,
      TYPE: type,
      CATEGORY_ID: categoryId,
      CATEGORY_NAME_EN: categoryNameEn,
      CATEGORY_NAME_AR: categoryNameAr,
      PRODUCT_ID: productId,
      PRODUCT_NAME_EN: productNameEn,
      PRODUCT_NAME_AR: productNameAr,
      MIN_QUANTITY: minQuantity,
      MAX_QUANTITY: maxQuantity,
      DISCOUNT_VALUE: discountValue,
      DISCOUNT_TYPE: discountType,
      APPLY_ON_TEAM: applyOnTeam,
      CLIENT_TYPE_ID: clientTypeId,
      CLIENT_TYPE_NAME: clientTypeName,
      TAGS: tags,
      CrmFirestoreKeys.STATUS_KEY: status,
      CrmFirestoreKeys.IS_ACTIVE_KEY: isActive,
      CrmFirestoreKeys.IS_DELETED_KEY: isDeleted,
      CrmFirestoreKeys.ORDER_KEY: order,
      if (audit != null) CrmFirestoreKeys.AUDIT_KEY: audit!.toMap(),
    };
  }

  factory CrmDiscountModel.fromMap(Map<String, dynamic> map) {
    final dynamic auditData =
        CrmFirestoreKeys.read(map, CrmFirestoreKeys.AUDIT_KEY, 'audit');
    final String resolvedStatus =
        (CrmFirestoreKeys.read(map, CrmFirestoreKeys.STATUS_KEY, 'status') ??
                'active')
            .toString();
    final bool resolvedDeleted = (CrmFirestoreKeys.read(
              map,
              CrmFirestoreKeys.IS_DELETED_KEY,
              'isDeleted',
            ) ??
            resolvedStatus == 'deleted') ==
        true;
    final bool resolvedActive = (CrmFirestoreKeys.read(
              map,
              CrmFirestoreKeys.IS_ACTIVE_KEY,
              'isActive',
            ) ??
            resolvedStatus == 'active') ==
        true;

    final dynamic tagsRaw = CrmFirestoreKeys.read(map, TAGS, 'tags');
    List<String> resolvedTags = const <String>[];
    if (tagsRaw is List) {
      resolvedTags = tagsRaw.map((dynamic item) => item.toString()).toList();
    }

    final dynamic minQtyRaw =
        CrmFirestoreKeys.read(map, MIN_QUANTITY, 'minQuantity');
    final dynamic maxQtyRaw =
        CrmFirestoreKeys.read(map, MAX_QUANTITY, 'maxQuantity');
    final dynamic discountValRaw =
        CrmFirestoreKeys.read(map, DISCOUNT_VALUE, 'discountValue');

    return CrmDiscountModel(
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
      type: (CrmFirestoreKeys.read(map, TYPE, 'type') ?? 'Service').toString(),
      categoryId: (CrmFirestoreKeys.read(map, CATEGORY_ID, 'categoryId') ?? '')
          .toString(),
      categoryNameEn:
          (CrmFirestoreKeys.read(map, CATEGORY_NAME_EN, 'categoryNameEn') ?? '')
              .toString(),
      categoryNameAr:
          (CrmFirestoreKeys.read(map, CATEGORY_NAME_AR, 'categoryNameAr') ?? '')
              .toString(),
      productId: (CrmFirestoreKeys.read(map, PRODUCT_ID, 'productId') ?? '')
          .toString(),
      productNameEn:
          (CrmFirestoreKeys.read(map, PRODUCT_NAME_EN, 'productNameEn') ?? '')
              .toString(),
      productNameAr:
          (CrmFirestoreKeys.read(map, PRODUCT_NAME_AR, 'productNameAr') ?? '')
              .toString(),
      minQuantity: minQtyRaw is num
          ? minQtyRaw.toInt()
          : (int.tryParse(minQtyRaw?.toString() ?? '') ?? 0),
      maxQuantity: maxQtyRaw is num
          ? maxQtyRaw.toInt()
          : (int.tryParse(maxQtyRaw?.toString() ?? '') ?? 0),
      discountValue: discountValRaw is num
          ? discountValRaw.toDouble()
          : (double.tryParse(discountValRaw?.toString() ?? '') ?? 0.0),
      discountType:
          (CrmFirestoreKeys.read(map, DISCOUNT_TYPE, 'discountType') ??
                  'percentage')
              .toString(),
      applyOnTeam:
          (CrmFirestoreKeys.read(map, APPLY_ON_TEAM, 'applyOnTeam') ?? '')
              .toString(),
      clientTypeId:
          (CrmFirestoreKeys.read(map, CLIENT_TYPE_ID, 'clientTypeId') ?? '')
              .toString(),
      clientTypeName:
          (CrmFirestoreKeys.read(map, CLIENT_TYPE_NAME, 'clientTypeName') ?? '')
              .toString(),
      tags: resolvedTags,
      status: resolvedStatus,
      isActive: resolvedActive,
      isDeleted: resolvedDeleted,
      order: (CrmFirestoreKeys.read(map, CrmFirestoreKeys.ORDER_KEY, 'order') ??
          0) as int,
      audit: auditData is Map
          ? CrmAuditModel.fromMap(Map<String, dynamic>.from(auditData))
          : null,
    );
  }

  factory CrmDiscountModel.getEmptyModel() {
    return const CrmDiscountModel(
      id: '',
      nameEn: '',
      nameAr: '',
      type: 'Service',
      categoryId: '',
      categoryNameEn: '',
      categoryNameAr: '',
      productId: '',
      productNameEn: '',
      productNameAr: '',
      minQuantity: 0,
      maxQuantity: 0,
      discountValue: 0.0,
      discountType: 'percentage',
      applyOnTeam: '',
      clientTypeId: '',
      clientTypeName: '',
      tags: <String>[],
      status: 'active',
      isActive: true,
      isDeleted: false,
      order: 0,
    );
  }

  CrmDiscountModel copyWith({
    String? id,
    String? nameEn,
    String? nameAr,
    String? type,
    String? categoryId,
    String? categoryNameEn,
    String? categoryNameAr,
    String? productId,
    String? productNameEn,
    String? productNameAr,
    int? minQuantity,
    int? maxQuantity,
    double? discountValue,
    String? discountType,
    String? applyOnTeam,
    String? clientTypeId,
    String? clientTypeName,
    List<String>? tags,
    String? status,
    bool? isActive,
    bool? isDeleted,
    int? order,
    CrmAuditModel? audit,
  }) {
    return CrmDiscountModel(
      id: id ?? this.id,
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      categoryNameEn: categoryNameEn ?? this.categoryNameEn,
      categoryNameAr: categoryNameAr ?? this.categoryNameAr,
      productId: productId ?? this.productId,
      productNameEn: productNameEn ?? this.productNameEn,
      productNameAr: productNameAr ?? this.productNameAr,
      minQuantity: minQuantity ?? this.minQuantity,
      maxQuantity: maxQuantity ?? this.maxQuantity,
      discountValue: discountValue ?? this.discountValue,
      discountType: discountType ?? this.discountType,
      applyOnTeam: applyOnTeam ?? this.applyOnTeam,
      clientTypeId: clientTypeId ?? this.clientTypeId,
      clientTypeName: clientTypeName ?? this.clientTypeName,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      order: order ?? this.order,
      audit: audit ?? this.audit,
    );
  }
}
