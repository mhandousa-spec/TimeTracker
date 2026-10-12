/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: arabic_number_format.dart
/// Purpose: Declares `ArabicNumberFormatter`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:flutter/services.dart';

class ArabicNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = newValue.text.replaceAllMapped(RegExp(r'[0-9]'), (match) {
      switch (match.group(0)) {
        case '0': return '٠';
        case '1': return '١';
        case '2': return '٢';
        case '3': return '٣';
        case '4': return '٤';
        case '5': return '٥';
        case '6': return '٦';
        case '7': return '٧';
        case '8': return '٨';
        case '9': return '٩';
        default:  return match.group(0)!;
      }
    });
    return newValue.copyWith(text: newText);
  }
}

/// Converts Western (ASCII) digits in a string to Arabic-Indic digits.
/// Moved here from core/extension/context_extensions.dart so all Arabic-number
/// conversion lives in one place.
extension ArabicDigits on String {
  String toArabicNumbers() {
    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String result = this;
    for (int i = 0; i < englishDigits.length; i++) {
      result = result.replaceAll(englishDigits[i], arabicDigits[i]);
    }
    return result;
  }
}
