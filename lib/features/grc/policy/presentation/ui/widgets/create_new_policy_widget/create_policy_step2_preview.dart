/// Module: GRC Policy Management
/// Description: Step 2 (Preview) content of the Create Policy page —
///              read-only policy summary plus the controls table.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-16
/// Dependencies: Flutter SDK, AppColors, PolicyInfoFormWidget,
///               PolicyControlsTableWidget, AddControllerButton
/// Revision History: 2026-07-16 - Extracted from create_new_policy.dart
library;

/// ************************* FILE INFO *************************** ///
/// File Name: create_policy_step2_preview.dart
/// Purpose: Contains CreatePolicyStep2Preview, the full preview step of
///          CreateNewPolicyPage — policy summary + controls table.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 16/7/2026

import 'dart:io';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/widgets/create_new_policy_widget/add_controller_button.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/widgets/grc_policy_widget/policy_control_model.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/widgets/grc_policy_widget/policy_controls_table_widget.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_document_info.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/widgets/grc_policy_widget/policy_info_form_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// class name: [CreatePolicyStep2Preview]
///
/// purpose: step 2 of [CreateNewPolicyPage] — shows the policy info
///          read-only, then either the controls table (if any control was
///          touched) or an [AddControllerButton] that sends the user back
///          to step 1.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 16/7/2026
class CreatePolicyStep2Preview extends StatelessWidget {
  final bool isArabicEnabled;
  final TextEditingController nameController;
  final TextEditingController nameArController;
  final TextEditingController numberController;
  final TextEditingController numberArController;
  final TextEditingController descriptionController;
  final TextEditingController descriptionArController;
  final TextEditingController weightController;
  final DateTime? startDate;
  final DateTime? endDate;
  final File? imageFile;
  final String? imageUrl;
  final PolicyDocumentInfo? documentEn;
  final PolicyDocumentInfo? documentAr;
  final List<PolicyControlModel> touchedControls;
  final VoidCallback onControlsChanged;

  /// Upload / remove for the policy documents. A document that was not
  /// uploaded in step 1 can still be added from the preview.
  final VoidCallback onUploadDocumentEn;
  final VoidCallback onUploadDocumentAr;
  final VoidCallback onRemoveDocumentEn;
  final VoidCallback onRemoveDocumentAr;

  const CreatePolicyStep2Preview({
    super.key,
    required this.isArabicEnabled,
    required this.nameController,
    required this.nameArController,
    required this.numberController,
    required this.numberArController,
    required this.descriptionController,
    required this.descriptionArController,
    required this.weightController,
    required this.startDate,
    required this.endDate,
    required this.documentEn,
    required this.documentAr,
    required this.touchedControls,
    required this.onControlsChanged,
    required this.onUploadDocumentEn,
    required this.onUploadDocumentAr,
    required this.onRemoveDocumentEn,
    required this.onRemoveDocumentAr,
    this.imageFile,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).preview,
              style: StyleText.fontSize16Weight400.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(15.sp),
              decoration: BoxDecoration(
                color: AppColors.field,
                borderRadius: BorderRadius.circular(8.sp),
              ),
              child: PolicyInfoFormWidget(
                isArabicEnabled: isArabicEnabled,
                readOnly: true,
                imageFile: imageFile,
                imageUrl: imageUrl,
                nameController: nameController,
                nameArController: nameArController,
                numberController: numberController,
                numberArController: numberArController,
                descriptionController: descriptionController,
                descriptionArController: descriptionArController,
                weightController: weightController,
                startDate: startDate,
                endDate: endDate,
                onStartDateChanged: (_) {},
                onEndDateChanged: (_) {},
                documentEn: documentEn,
                documentAr: documentAr,
                onUploadDocumentEn: onUploadDocumentEn,
                onUploadDocumentAr: onUploadDocumentAr,
                onRemoveDocumentEn: onRemoveDocumentEn,
                onRemoveDocumentAr: onRemoveDocumentAr,
              ),
            ),
            SizedBox(height: 15.h),
            // -- Controls table / Add Controller button --

            touchedControls.isEmpty
                ? SizedBox.shrink()
                : PolicyControlsTableWidget(
                    controls: touchedControls,
                    isArabicEnabled: isArabicEnabled,
                    onSave: onControlsChanged,
                  ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
