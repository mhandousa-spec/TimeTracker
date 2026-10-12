// ***************************** FILE INFO ***************************** //
// File Name: enum_bulk_value.dart
// Purpose: Provides the stable workbook value for generic enum selectors.
// Author: Mohamed Elrashidy
// Created At: 2026-08-19
// ********************************************************************* //

/// Exposes the persisted enum name as the value used by bulk workbooks.
extension EnumBulkValue on Enum {
  String get value => name;
}
