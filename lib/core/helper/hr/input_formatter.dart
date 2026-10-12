// ***************************** FILE INFO ***************************** //
// File Name: input_formatter.dart
// Purpose: Provides reusable input formatters for HR text fields.
// Author: Mohamed Elrashidy
// Created At: 2026-08-27
// ********************************************************************* //

import 'package:flutter/services.dart';

/// Provides input formatters shared by HR forms.
abstract final class HrInputFormatter {
  /// Allows English letters and spaces for English name fields.
  static final TextInputFormatter englishName =
      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z ]'));

  /// Allows Arabic letters and spaces for Arabic name fields.
  static final TextInputFormatter arabicName =
      FilteringTextInputFormatter.allow(
    RegExp(r'[\u0621-\u063A\u0641-\u064A ]'),
  );
}
