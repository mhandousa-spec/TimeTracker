/// Module: GRC Policy Management
/// Description: Step 0 (Policy Info) content of the Create Policy page —
///              header/avatar row plus the policy info form.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-16
/// Dependencies: Flutter SDK, AppColors, PolicyHeaderWidget,
///               PolicyInfoFormWidget
/// Revision History: 2026-07-16 - Extracted from create_new_policy.dart
library;

/// ************************* FILE INFO *************************** ///
/// File Name: create_policy_step0.dart
/// Purpose: Contains CreatePolicyStep0, the policy-info form step of
///          CreateNewPolicyPage.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 16/7/2026

import 'dart:io';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_document_info.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/widgets/grc_policy_widget/policy_header_widget.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/widgets/grc_policy_widget/policy_info_form_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// class name: [CreatePolicyStep0]
///
/// purpose: step 0 of [CreateNewPolicyPage] — collects the policy image,
///          Arabic-version toggle, and the policy info form fields. All
///          state is owned by the parent page and passed in via controllers
///          and callbacks.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 16/7/2026
class CreatePolicyStep0 extends StatelessWidget {
  final bool isArabicEnabled;
  final ValueChanged<bool> onArabicToggle;
  final File? imageFile;
  final ValueChanged<File?> onImagePicked;
  final bool submitted;
  final TextEditingController nameController;
  final TextEditingController nameArController;
  final TextEditingController numberController;
  final TextEditingController numberArController;
  final TextEditingController descriptionController;
  final TextEditingController descriptionArController;
  final TextEditingController weightController;
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<DateTime?> onStartDateChanged;
  final ValueChanged<DateTime?> onEndDateChanged;
  final PolicyDocumentInfo? documentEn;
  final PolicyDocumentInfo? documentAr;
  final VoidCallback onUploadDocumentEn;
  final VoidCallback onUploadDocumentAr;
  final VoidCallback onRemoveDocumentEn;
  final VoidCallback onRemoveDocumentAr;

  const CreatePolicyStep0({
    super.key,
    required this.isArabicEnabled,
    required this.onArabicToggle,
    required this.imageFile,
    required this.onImagePicked,
    required this.submitted,
    required this.nameController,
    required this.nameArController,
    required this.numberController,
    required this.numberArController,
    required this.descriptionController,
    required this.descriptionArController,
    required this.weightController,
    required this.startDate,
    required this.endDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.documentEn,
    required this.documentAr,
    required this.onUploadDocumentEn,
    required this.onUploadDocumentAr,
    required this.onRemoveDocumentEn,
    required this.onRemoveDocumentAr,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(8.sp),
      ),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PolicyHeaderWidget(
                isArabicEnabled: isArabicEnabled,
                onArabicToggle: onArabicToggle,
                imageFile: imageFile,
                onImagePicked: onImagePicked,
              ),
              SizedBox(height: 15.h),
              PolicyInfoFormWidget(
                isArabicEnabled: isArabicEnabled,
                allFieldsRequired: true,
                submitted: submitted,
                nameController: nameController,
                nameArController: nameArController,
                numberController: numberController,
                numberArController: numberArController,
                descriptionController: descriptionController,
                descriptionArController: descriptionArController,
                weightController: weightController,
                startDate: startDate,
                endDate: endDate,
                onStartDateChanged: onStartDateChanged,
                onEndDateChanged: onEndDateChanged,
                documentEn: documentEn,
                documentAr: documentAr,
                onUploadDocumentEn: onUploadDocumentEn,
                onUploadDocumentAr: onUploadDocumentAr,
                onRemoveDocumentEn: onRemoveDocumentEn,
                onRemoveDocumentAr: onRemoveDocumentAr,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
