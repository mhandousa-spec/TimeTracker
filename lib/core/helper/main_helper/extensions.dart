/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: extensions.dart
/// Purpose: Declares `ContextExtension`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

// Moved out of core/helper/messaging (removed). The date_time_helper import
// was dropped: nothing here used it, and that file is itself broken (it
// imports messaging/data/models/chat_enums.dart, which does not exist).

// Date: 4/8/2024
// By: Youssef Ashraf, Nada Mohammed
// Last update: 8/8/2024
// Objectives: This file is responsible for providing extensions to several classes in the project.

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import './date_time_helper.dart';

/// Screen-info helpers that are *not* already provided by
/// [core/extension/context_extensions.dart].
///
/// `isTablett` and `isArabic` used to be declared here too, with implementations
/// identical to the ones in context_extensions.dart. Two extensions declaring
/// the same member on BuildContext makes every call ambiguous in any library
/// that imports both, so the duplicates were removed and context_extensions.dart
/// is now the single source for them.
extension ContextExtension on BuildContext {
  // ScreenInfo
  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;

  bool get isTabletRange500To600 =>
      MediaQuery.of(this).size.width >= 500 &&
      MediaQuery.of(this).size.width <= 600;
  bool get isTabletVer =>
      MediaQuery.of(this).size.width >= 600 &&
      MediaQuery.of(this).size.width < 800;

  // NOTE: this reads `>= 600`, i.e. it is true on *wide* screens — the opposite
  // of context_extensions.dart's `isPhone` (`shortestSide < 600`). Left as-is so
  // its three call sites keep their current behaviour; see the migration notes.
  bool get isPhone => MediaQuery.of(this).size.width >= 600;
}

extension AudioWavesSample on PlayerController {
  int getNumOfSamples(audioWavesSpacing) {
    // 328 is the width of the audio waves container in tablet, 146 is the width of the audio waves container in mobile
    return Get.context!.isTablett
        ? (328.w ~/ audioWavesSpacing)
        : (146.w ~/ audioWavesSpacing);
  }
}

/// Extension to add additional functionalities for string manipulation, specifically for number conversions.
extension NumberToArabic on String {
  /// Converts English digits in the string to equivalent Arabic digits.
  String toArabicNumbers() {
    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    String result = this;
    for (int i = 0; i < englishDigits.length; i++) {
      result = result.replaceAll(englishDigits[i], arabicDigits[i]);
    }
    return result;
  }

  int toEnglishNumber() {
    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    String result = this;
    for (int i = 0; i < arabicDigits.length; i++) {
      result = result.replaceAll(arabicDigits[i], englishDigits[i]);
    }
    return result.toInt();
  }

  double toEnglishNumberAsDouble() {
    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    String result = this;
    for (int i = 0; i < arabicDigits.length; i++) {
      result = result.replaceAll(arabicDigits[i], englishDigits[i]);
    }
    return result.toDouble();
  }

  bool isLink() {
    return this.startsWith('http://') ||
        this.startsWith('https://') ||
        this.startsWith('www.');
  }

  /// Returns the string padded with leading zeros to ensure it has at least two digits.
  String get doubleDigit {
    try {
      return padLeft(2, DateTimeHelper.formatInt(0));
    } catch (e) {
      return this;
    }
  }

  /// Converts the string to an integer, returning 0 if the conversion fails.
  int toInt() => int.tryParse(this) ?? 0;

  /// Converts the string to an integer, returning a default value if the conversion fails or the value is 0.
  int toIntDefualt(int number) =>
      int.tryParse(this) == 0 ? number : int.tryParse(this) ?? number;

  /// Converts the string to a double, returning 0 if the conversion fails.
  double toDouble() => double.tryParse(this) ?? 0;

  /// Converts all digits in the string to '0'.
  String replaceAllDigitsWithZero() {
    const digits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    String result = this;
    for (var digit in digits) {
      result = result.replaceAll(digit, DateTimeHelper.formatInt(0));
    }
    return result;
  }

  Color? toColor() {
    try {
      var hexColor = replaceAll("Color(", "").replaceAll(")", "");

      return Color(int.parse(hexColor));
    } catch (e) {
      // Form bug report #16: since Flutter 3.27 `Color.toString()` is
      // "Color(alpha: 1.0000, red: 1.0000, green: …, colorSpace: …)", which
      // the hex parse above cannot read — so every saved title colour came
      // back as the black fallback (a white title showed black). Read that
      // format too before giving up.
      final match = RegExp(
              r'alpha:\s*([\d.]+),\s*red:\s*([\d.]+),\s*green:\s*([\d.]+),\s*blue:\s*([\d.]+)')
          .firstMatch(this);
      if (match != null) {
        double c(int i) => double.parse(match.group(i)!);
        return Color.from(alpha: c(1), red: c(2), green: c(3), blue: c(4));
      }
      return Colors.black; // Fallback color
    }
  }

  toImage() {
    if (this != null && isNotEmpty) {
      if (contains('http') || contains('https')) {
        return Image.network(this);
      } else {
        return appImageWidget(this);
      }
    }

    return null;
  }
}

extension IntToOrdinal on int {
  /// Converts integers up to 9 to their ordinal form, otherwise appends "th".
  String toOrdinal() {
    switch (this) {
      case 0:
        return S.current.k1st;
      case 1:
        return S.current.k2nd;
      case 2:
        return S.current.k3rd;

      default:
        return (Get.locale!.languageCode == 'en')
            ? (this + 1).toString() + S.current.th
            : (this + 1).toString().toArabicNumbers() +
                S.current.th; // or '${this + 1}th'.tr if you want to maintain the +1 logic from original
    }
  }

  /// Zero-based index as a SPELLED-OUT ordinal — 0 → "First", 1 → "Second".
  ///
  /// ADDED 19/8/2026. Figma names these headers "First Row" / "Second Row" /
  /// "First Column" (MESBAH / node 7444-41775 and siblings), while
  /// [toOrdinal] produces the numeric "1st" / "2nd" form the bug report
  /// flagged. [toOrdinal] is left exactly as it is — it is a general-purpose
  /// core extension and the numeric form is right in other contexts.
  ///
  /// NOT routed through `S.current`: the generated l10n class has no key for
  /// these, and adding one means editing the .arb files and re-running the
  /// intl codegen. The strings are inlined here the same way the Form Builder
  /// call sites already inline "Row", "Column" and "Choose Field of".
  ///
  /// Past the word list it falls back to [toOrdinal], so a 12-column row reads
  /// "12th Column" rather than breaking. That is deliberate — Figma only ever
  /// shows five, and the columns cap at 15.
  String toWordOrdinal() {
    const english = [
      'First', 'Second', 'Third', 'Fourth', 'Fifth',
      'Sixth', 'Seventh', 'Eighth', 'Ninth', 'Tenth',
    ];
    // Definite forms: they qualify a definite noun ("الصف الأول").
    const arabic = [
      'الأول', 'الثاني', 'الثالث', 'الرابع', 'الخامس',
      'السادس', 'السابع', 'الثامن', 'التاسع', 'العاشر',
    ];

    if (this < 0 || this >= english.length) return toOrdinal();

    return Get.locale?.languageCode == 'ar' ? arabic[this] : english[this];
  }

  String formatNumber() {
    String formattedNumber;

    if (this >= 1000000) {
      formattedNumber = '${(this / 1000000).truncate()}M';
    } else if (this >= 1000) {
      formattedNumber = '${(this / 1000).truncate()}K';
    } else {
      formattedNumber = this.toString();
    }

    // التحقق من اللغة الحالية وإرجاع الرقم بالتنسيق المناسب
    if (Get.context!.isArabic) {
      return DateTimeHelper.formatInt(int.parse(
          formattedNumber.replaceAll('K', '000').replaceAll('M', '000000')));
    } else {
      return formattedNumber;
    }
  }
}

/// Extension to provide additional functionality to the bool type.
extension BoolExtension on bool {
  /// Toggles the boolean value and returns the opposite.
  bool toggle() {
    return !this;
  }
}
