// ****************** FILE INFO ******************
// File Name: crm_template_layout_model.dart
// Purpose: Data models representing saved CRM template UI layout
// Author: Mohand Adel
// Created At: 04/08/2026

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';

class CrmTemplateLayoutModel {
  final String id;
  final String templateId;
  final List<CrmTemplatePageModel> pages;
  final DateTime updatedAt;
  final String updatedBy;

  const CrmTemplateLayoutModel({
    required this.id,
    required this.templateId,
    required this.pages,
    required this.updatedAt,
    required this.updatedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      CrmFirestoreKeys.ID_KEY: id,
      CrmFirestoreKeys.TEMPLATE_ID_KEY: templateId,
      CrmFirestoreKeys.PAGES_KEY: pages.map((page) => page.toMap()).toList(),
      CrmFirestoreKeys.UPDATED_AT_KEY: Timestamp.fromDate(updatedAt),
      CrmFirestoreKeys.UPDATED_BY_KEY: updatedBy,
    };
  }

  factory CrmTemplateLayoutModel.fromMap(Map<String, dynamic> map) {
    return CrmTemplateLayoutModel(
      id: (CrmFirestoreKeys.read(map, CrmFirestoreKeys.ID_KEY, 'id') ?? '')
          .toString(),
      templateId: (CrmFirestoreKeys.read(
                map,
                CrmFirestoreKeys.TEMPLATE_ID_KEY,
                'templateId',
              ) ??
              '')
          .toString(),
      pages: (CrmFirestoreKeys.read(map, CrmFirestoreKeys.PAGES_KEY, 'pages')
                  as List? ??
              const [])
          .map(
            (page) => CrmTemplatePageModel.fromMap(
              Map<String, dynamic>.from(page as Map),
            ),
          )
          .toList(),
      updatedAt: _readDateTime(
        CrmFirestoreKeys.read(
          map,
          CrmFirestoreKeys.UPDATED_AT_KEY,
          'updatedAt',
        ),
      ),
      updatedBy: (CrmFirestoreKeys.read(
                map,
                CrmFirestoreKeys.UPDATED_BY_KEY,
                'updatedBy',
              ) ??
              '')
          .toString(),
    );
  }

  static DateTime _readDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}

class CrmTemplatePageModel {
  final String id;
  final String titleEn;
  final String titleAr;
  final int order;
  final List<CrmTemplateRowModel> rows;

  const CrmTemplatePageModel({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.order,
    required this.rows,
  });

  Map<String, dynamic> toMap() {
    return {
      CrmFirestoreKeys.ID_KEY: id,
      CrmFirestoreKeys.TITLE_EN_KEY: titleEn,
      CrmFirestoreKeys.TITLE_AR_KEY: titleAr,
      CrmFirestoreKeys.ORDER_KEY: order,
      CrmFirestoreKeys.ROWS_KEY: rows.map((row) => row.toMap()).toList(),
    };
  }

  factory CrmTemplatePageModel.fromMap(Map<String, dynamic> map) {
    return CrmTemplatePageModel(
      id: (CrmFirestoreKeys.read(map, CrmFirestoreKeys.ID_KEY, 'id') ?? '')
          .toString(),
      titleEn: (CrmFirestoreKeys.read(
                  map, CrmFirestoreKeys.TITLE_EN_KEY, 'titleEn') ??
              '')
          .toString(),
      titleAr: (CrmFirestoreKeys.read(
                  map, CrmFirestoreKeys.TITLE_AR_KEY, 'titleAr') ??
              '')
          .toString(),
      order: (CrmFirestoreKeys.read(map, CrmFirestoreKeys.ORDER_KEY, 'order')
                  as num?)
              ?.toInt() ??
          0,
      rows: (CrmFirestoreKeys.read(map, CrmFirestoreKeys.ROWS_KEY, 'rows')
                  as List? ??
              const [])
          .map(
            (row) => CrmTemplateRowModel.fromMap(
              Map<String, dynamic>.from(row as Map),
            ),
          )
          .toList(),
    );
  }
}

class CrmTemplateRowModel {
  final String id;
  final int columnsCount;
  final List<CrmTemplateColumnModel> columns;

  const CrmTemplateRowModel({
    required this.id,
    required this.columnsCount,
    required this.columns,
  });

  Map<String, dynamic> toMap() {
    return {
      CrmFirestoreKeys.ID_KEY: id,
      CrmFirestoreKeys.COLUMNS_COUNT_KEY: columnsCount,
      CrmFirestoreKeys.COLUMNS_KEY:
          columns.map((column) => column.toMap()).toList(),
    };
  }

  factory CrmTemplateRowModel.fromMap(Map<String, dynamic> map) {
    return CrmTemplateRowModel(
      id: (CrmFirestoreKeys.read(map, CrmFirestoreKeys.ID_KEY, 'id') ?? '')
          .toString(),
      columnsCount: (CrmFirestoreKeys.read(
            map,
            CrmFirestoreKeys.COLUMNS_COUNT_KEY,
            'columnsCount',
          ) as num?)
              ?.toInt() ??
          1,
      columns: (CrmFirestoreKeys.read(
                map,
                CrmFirestoreKeys.COLUMNS_KEY,
                'columns',
              ) as List? ??
              const [])
          .map(
            (column) => CrmTemplateColumnModel.fromMap(
              Map<String, dynamic>.from(column as Map),
            ),
          )
          .toList(),
    );
  }
}

class CrmTemplateColumnModel {
  final String type;
  final String refId;

  const CrmTemplateColumnModel({
    required this.type,
    required this.refId,
  });

  Map<String, dynamic> toMap() {
    return {
      CrmFirestoreKeys.TYPE_KEY: type,
      CrmFirestoreKeys.REF_ID_KEY: refId,
    };
  }

  factory CrmTemplateColumnModel.fromMap(Map<String, dynamic> map) {
    return CrmTemplateColumnModel(
      type:
          (CrmFirestoreKeys.read(map, CrmFirestoreKeys.TYPE_KEY, 'type') ?? '')
              .toString(),
      refId:
          (CrmFirestoreKeys.read(map, CrmFirestoreKeys.REF_ID_KEY, 'refId') ??
                  '')
              .toString(),
    );
  }
}
