import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'dart:ui' as ui;

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/knowledge_hub/main_controller/helper/format_helper.dart';

Widget enterDocumentNameEnAr(
    BuildContext context, {
      required TextEditingController englishController,
      required TextEditingController arabicController,
      required GlobalKey<FormState> documentNameKey,
      required void Function(String)? onChanged,
      required void Function(String)? onArabicChanged,
    }) {
  final isMobile = ContextExtension(context).isPhone;
  final lightMode = Theme.of(context).brightness == Brightness.light;
  final isArabic = Get.locale?.languageCode == 'ar';

  final englishField = Directionality(
    textDirection: ui.TextDirection.ltr,
    child: CustomTextField(
      label: 'Name of Document',
      hint: 'Text Here',
      controller: englishController,
      height: 36,
      // ADDED 28/8/2026 — English field takes English only. CustomTextField's
      // built-in script guard refuses any edit that ADDS an Arabic character
      // (typed or pasted) and shows "Please use English characters only." when a
      // value loaded from Firestore already contains one. Digits, punctuation
      // and symbols are untouched: the rule is about SCRIPT, not about marks.
      restrictByDirection: true,
      onChanged: (value) {
        // ✅ Apply capitalization before calling the original callback
        final capitalizedValue = FormatHelper.capitalize(value);
        if (capitalizedValue != value) {
          englishController.value = TextEditingValue(
            text: capitalizedValue,
            selection: TextSelection.collapsed(offset: capitalizedValue.length),
          );
        }
        onChanged?.call(capitalizedValue);
      },
      textDirection: ui.TextDirection.ltr,
      textAlign: TextAlign.left,
      fillColor: lightMode
          ? AppColors.background
          : AppColors.background,
    ),
  );

  final arabicField = Directionality(
    textDirection: ui.TextDirection.rtl,
    child: CustomTextField(
      label: 'إسم الوثيقة',
      hint: 'اكتب هنا',
      controller: arabicController,
      textDirection: ui.TextDirection.rtl,
      textAlign: TextAlign.right,
      height: 36,
      // ADDED 28/8/2026 — mirror of the English field: Arabic only, enforced by
      // the same guard reading textDirection: rtl blocks `[a-zA-Z]`.
      restrictByDirection: true,
      onChanged: (value) {
        // ✅ Apply capitalization for Arabic text too
        final capitalizedValue = FormatHelper.capitalize(value);
        if (capitalizedValue != value) {
          arabicController.value = TextEditingValue(
            text: capitalizedValue,
            selection: TextSelection.collapsed(offset: capitalizedValue.length),
          );
        }
        onArabicChanged?.call(capitalizedValue);
      },
      fillColor: lightMode
          ? AppColors.background
          : AppColors.background,
    ),
  );

  return Form(
    key: documentNameKey,
    child: isMobile
        ? Column(
      children: [
        if (isArabic) ...[
          arabicField,
          SizedBox(height: 10.h),
          englishField,
        ] else ...[
          englishField,
          SizedBox(height: 10.h),
          arabicField,
        ],
      ],
    )
        : Row(
      children: [
        if (isArabic) ...[
          Expanded(child: arabicField),
          SizedBox(width: 15.w),
          Expanded(child: englishField),
        ] else ...[
          Expanded(child: englishField),
          SizedBox(width: 15.w),
          Expanded(child: arabicField),
        ],
      ],
    ),
  );
}