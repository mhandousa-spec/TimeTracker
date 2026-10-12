import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/features/knowledge_hub/main_controller/helper/format_helper.dart';

Widget documentDescNameEnAr(
    BuildContext context, {
      required TextEditingController englishDescController,
      required TextEditingController arabicDescController,
      required GlobalKey<FormState> documentDescriptionFormKey,
      required void Function(String)? onChanged,
      required void Function(String)? onArabicChanged,
      bool submitted = false,
    }) {
  final isArabic = Localizations.localeOf(context).languageCode == 'ar';
  final lightMode = Theme.of(context).brightness == Brightness.light;

  final englishField = Directionality(
    textDirection: ui.TextDirection.ltr,
    child: CustomTextField(
      label: 'Document Description',
      hint: 'Text Here',
      hintStyle: TextStyle(color: AppColors.secondaryText.withOpacity(.5)),
      controller: englishDescController,
      height: 72,
      textDirection: ui.TextDirection.ltr,
      showCharCount: true,
      maxLines: 3,
      // ADDED 28/8/2026 — English description takes English only. The built-in
      // script guard refuses any edit that ADDS an Arabic character (typed or
      // pasted); digits, punctuation and symbols still pass, so a normal
      // sentence's full stops and brackets are never flagged.
      restrictByDirection: true,
      onChanged: (value) {
        // ✅ Apply capitalization
        final capitalizedValue = FormatHelper.capitalize(value);
        if (capitalizedValue != value) {
          englishDescController.value = TextEditingValue(
            text: capitalizedValue,
            selection: TextSelection.collapsed(offset: capitalizedValue.length),
          );
        }
        onChanged?.call(capitalizedValue);
      },
      submitted: submitted,
      fillColor: lightMode
          ? AppColors.background
          : AppColors.background,
    ),
  );

  final arabicField = Directionality(
    textDirection: ui.TextDirection.rtl,
    child: CustomTextField(
      label: 'وصف الوثيقة',
      hint: 'اكتب هنا',
      hintStyle: TextStyle(color: AppColors.secondaryText.withOpacity(.5)),
      controller: arabicDescController,
      textDirection: ui.TextDirection.rtl,
      textAlign: TextAlign.right,
      height: 72,
      showCharCount: true,
      maxLines: 3,
      // ADDED 28/8/2026 — mirror of the English description: Arabic only,
      // `[a-zA-Z]` blocked, punctuation and numbers left alone.
      restrictByDirection: true,
      onChanged: (value) {
        // ✅ Apply capitalization
        final capitalizedValue = FormatHelper.capitalize(value);
        if (capitalizedValue != value) {
          arabicDescController.value = TextEditingValue(
            text: capitalizedValue,
            selection: TextSelection.collapsed(offset: capitalizedValue.length),
          );
        }
        onArabicChanged?.call(capitalizedValue);
      },
      submitted: submitted,
      fillColor: lightMode
          ? AppColors.background
          : AppColors.background,
    ),
  );

  return Form(
    key: documentDescriptionFormKey,
    child: Column(
      children: [
        if (isArabic) ...[
          arabicField,
          SizedBox(height: 15),
          englishField,
        ] else ...[
          englishField,
          SizedBox(height: 15),
          arabicField,
        ],
      ],
    ),
  );
}