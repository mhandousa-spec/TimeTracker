// ****************** FILE INFO ******************
// File Name: crm_activity_notes_section.dart
// Purpose: Bilingual notes section (English & Arabic) for activities
// Author: Mohand Adel
// Created At: 26/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class CrmActivityNotesSection extends StatelessWidget {
  final TextEditingController noteEnController;
  final TextEditingController noteArController;
  final bool isReadOnly;

  const CrmActivityNotesSection({
    super.key,
    required this.noteEnController,
    required this.noteArController,
    required this.isReadOnly,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Note',
          style: StyleText.fontSize14Weight400.copyWith(
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 6.sp),
        CustomTextField(
          controller: noteEnController,
          hint: 'Description',
          maxLines: 3,
          maxLength: 500,
          readOnly: isReadOnly,
        ),
        SizedBox(height: 16.sp),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'ملاحظة',
            style: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.text,
            ),
          ),
        ),
        SizedBox(height: 6.sp),
        CustomTextField(
          controller: noteArController,
          hint: 'اكتب هنا',
          textAlign: TextAlign.right,
          maxLines: 3,
          maxLength: 500,
          readOnly: isReadOnly,
        ),
      ],
    );
  }
}
