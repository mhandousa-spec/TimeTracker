/// Module: GRC Policy Management
/// Description: Editable "edit mode" body of the Policy Details page — the
///              "Create Arabic Version" toggle plus the shared
///              [PolicyInfoFormWidget] fields. The Active/Inactive status
///              toggle lives on [PolicyEditPage] itself, outside this form.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-18
/// Dependencies: Flutter SDK, AppColors, AppTheme, PolicyInfoFormWidget,
///               flutter_switch
/// Revision History: 2026-07-18 - Initial creation
///                   2026-07-22 - Replaced the hardcoded isArabicEnabled:
///                                true with a real toggle, and moved the
///                                status toggle out to PolicyEditPage
library;

import 'dart:io';

import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_document_info.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/widgets/grc_policy_widget/policy_info_form_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import '../../../../../../../core/extensions/context_extensions.dart';

/// class name: [PolicyEditModeWidget]
///
/// purpose: renders the editable form for a Policy — the "Create Arabic
///          Version" toggle followed by [PolicyInfoFormWidget]. Kept as a
///          thin, stateless composition: all field state lives in the
///          parent page, this widget only lays it out.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 18/7/2026
class PolicyEditModeWidget extends StatelessWidget {
  final bool isArabicEnabled;
  final ValueChanged<bool> onArabicToggle;
  final File? imageFile;
  final String? imageUrl;
  final ValueChanged<File> onImagePicked;

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

  const PolicyEditModeWidget({
    super.key,
    required this.isArabicEnabled,
    required this.onArabicToggle,
    required this.onImagePicked,
    this.imageFile,
    this.imageUrl,
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
    required this.onUploadDocumentEn,
    required this.onUploadDocumentAr,
    required this.onRemoveDocumentEn,
    required this.onRemoveDocumentAr,
    this.documentEn,
    this.documentAr,
  });

  @override
  Widget build(BuildContext context) {
    // 768 / 1024 put the avatar and the "Create Arabic Version" toggle on one
    // line. 375 has no room for both, so the design stacks them: the toggle
    // trailing-aligned on its own line, the avatar under it.
    final bool isMobile = screenSizeOf(context) == ScreenSize.mobile;

    final Widget avatar = CustomImagePicker(
      radius: 30.r,
      badgeRadius: 11.r,
      imageFile: imageFile,
      imageUrl: imageUrl,
      onImagePicked: onImagePicked,
    );

    final Widget arabicToggle = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            S.of(context).createArabicVersion,
            style:context.isPhone ? StyleText.fontSize12Weight500.copyWith(
                color: AppColors.secondaryText
            ):
                StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
          ),
        ),
        SizedBox(width: 10.w),
        FlutterSwitch(
          width: context.isPhone ? 30.sp : 38.sp,
          height: context.isPhone ? 18.sp : 22.sp,
          padding: context.isPhone ? 2.sp : 3.sp,
          borderRadius: 20.sp,
          toggleSize: 16.sp,
          activeColor: AppColors.secondaryPrimary,
          inactiveColor: Colors.grey.withOpacity(.16),
          value: isArabicEnabled,
          onToggle: onArabicToggle,
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isMobile) ...[
          Align(alignment: AlignmentDirectional.centerEnd, child: arabicToggle),
          SizedBox(height: 10.h),
          Align(alignment: AlignmentDirectional.centerStart, child: avatar),
        ] else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [avatar, arabicToggle],
          ),
        SizedBox(height: 12.h),
        PolicyInfoFormWidget(
          isArabicEnabled: isArabicEnabled,
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
    );
  }
}
