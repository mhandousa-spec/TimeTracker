// ****************** FILE INFO ******************
// File Name: crm_template_details_content.dart
// Purpose: Editable/read-only bilingual template name fields for CRM template builder
// Author: Mohand Adel
// Created At: 25/08/2026

import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmTemplateDetailsContent extends StatefulWidget {
  const CrmTemplateDetailsContent({
    required this.nameEn,
    required this.nameAr,
    this.isReadOnly = true,
    super.key,
  });

  final String nameEn;
  final String nameAr;
  final bool isReadOnly;

  @override
  State<CrmTemplateDetailsContent> createState() =>
      _CrmTemplateDetailsContentState();
}

class _CrmTemplateDetailsContentState extends State<CrmTemplateDetailsContent> {
  late final TextEditingController _nameEnController;
  late final TextEditingController _nameArController;

  @override
  void initState() {
    super.initState();
    _nameEnController = TextEditingController(text: widget.nameEn);
    _nameArController = TextEditingController(text: widget.nameAr);
  }

  @override
  void didUpdateWidget(covariant CrmTemplateDetailsContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.nameEn != widget.nameEn) {
      _nameEnController.text = widget.nameEn;
    }
    if (oldWidget.nameAr != widget.nameAr) {
      _nameArController.text = widget.nameAr;
    }
  }

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameArController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildResponsiveFields(
      context: context,
      left: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Template Name',
            style: StyleText.fontSize14Weight500.copyWith(
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 8.h),
          CustomTextField(
            controller: _nameEnController,
            hint: S.current.crmTextHere,
            readOnly: widget.isReadOnly,
          ),
        ],
      ),
      right: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'اسم القالب',
              style: StyleText.fontSize14Weight500.copyWith(
                color: AppColors.black,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Directionality(
            textDirection: TextDirection.rtl,
            child: CustomTextField(
              controller: _nameArController,
              hint: S.current.crmWriteHere,
              textAlign: TextAlign.right,
              readOnly: widget.isReadOnly,
            ),
          ),
        ],
      ),
    );
  }
}
