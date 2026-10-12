// ****************** FILE INFO ******************
// File Name: crm_template_layout_data.dart
// Purpose: In-memory data holders for the CRM template layout editor (items,
//          columns, rows and pages) shared by the layout page and its widgets
// Author: Mohand Adel
// Created At: 12/08/2026

import 'package:flutter/widgets.dart';

/// A selectable section or field shown in the layout column dropdowns.
class CrmLayoutItem {
  const CrmLayoutItem({
    required this.id,
    required this.name,
    this.isSection = false,
  });

  final String id;
  final String name;
  final bool isSection;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CrmLayoutItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Mutable selection state of a single layout column.
class CrmLayoutColumnData {
  CrmLayoutColumnData({
    this.selectedItemId,
    this.selectedItemName,
    this.isSection = false,
  });

  String? selectedItemId;
  String? selectedItemName;
  bool isSection;
}

/// Mutable state of a single layout row (column count, mode, selections).
class CrmLayoutRowData {
  CrmLayoutRowData({
    required this.id,
    required this.title,
    this.numberOfColumns = 1,
    this.isSectionMode = false,
  }) : columnsController = TextEditingController(text: '$numberOfColumns');

  final String id;
  final String title;
  int numberOfColumns;
  bool isSectionMode;
  CrmLayoutColumnData? column1;
  CrmLayoutColumnData? column2;
  bool isExpanded = true;
  final TextEditingController columnsController;

  void dispose() {
    columnsController.dispose();
  }
}

/// Mutable state of a single layout page holding its rows.
class CrmLayoutPageData {
  CrmLayoutPageData({
    required this.id,
    required this.title,
    required this.rows,
  });

  final String id;
  final String title;
  final List<CrmLayoutRowData> rows;
  bool isExpanded = true;
}
