/// Module: knowledge_hub / presentation / s1_create_new_knowledge / widgets/image_and_document_section.dart
/// ************************* FILE INFO *************************** ///
/// File Name: image_document_section.dart
/// Purpose: Widget for image and document attachment section
/// Author: Youssef Khaled
/// Created At: 22/10/2025

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import '../../../../main_controller/data/models/create_knowledge_new_model.dart';
import '../../../../main_controller/presentation/ui/widgets/attach_document_button.dart';
import '../../../../main_controller/presentation/ui/widgets/document_desc_en_ar.dart';
import '../../../../main_controller/presentation/ui/widgets/enter_document_name_en_ar.dart';
import '../../../../main_controller/presentation/ui/widgets/selected_document_widget.dart';
import '../../../../main_controller/presentation/ui/widgets/upload_image_widget.dart';
import 'package:knowticed_plus/core/custom/33-custom_haptic.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class ImageDocumentSection extends StatefulWidget {
  final bool isMobile;
  final File? selectedImage;
  final File? selectedDocument;
  final String? documentFileName;
  final int documentSize;
  final DateTime? documentUploadedDate;
  final String? documentExtension;
  final CreateKnowledgeModel? submittedDocument;
  final VoidCallback pickImage;
  final VoidCallback pickDocument;
  final VoidCallback removeDocument;
  final TextEditingController englishController;
  final TextEditingController arabicController;
  final TextEditingController englishDescController;
  final TextEditingController arabicDescController;
  final GlobalKey<FormState> documentNameFormKey;
  final GlobalKey<FormState> documentDescriptionKey;
  final VoidCallback onChanged;

  const ImageDocumentSection({
    super.key,
    required this.isMobile,
    required this.selectedImage,
    required this.selectedDocument,
    required this.documentFileName,
    required this.documentSize,
    required this.documentUploadedDate,
    required this.documentExtension,
    required this.submittedDocument,
    required this.pickImage,
    required this.pickDocument,
    required this.removeDocument,
    required this.englishController,
    required this.arabicController,
    required this.englishDescController,
    required this.arabicDescController,
    required this.documentNameFormKey,
    required this.documentDescriptionKey,
    required this.onChanged,
  });

  @override
  State<ImageDocumentSection> createState() => _ImageDocumentSectionState();
}

class _ImageDocumentSectionState extends State<ImageDocumentSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _triggerHapticAndAnimation(VoidCallback callback) {
    hapticController.triggerHapticFeedback(
      vibration: VibrateType.mediumImpact,
      hapticFeedback: HapticFeedback.mediumImpact,
    );

    _animationController.forward().then((_) {
      _animationController.reverse();
      callback();
    });
  }

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    return Container(
      width: ScreenUtil().screenWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: lightMode
            ? AppColors.white
            : AppColors.chatBackground,
      ),
      padding: EdgeInsets.all(15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          uploadImageWidget(
            context: context,
            pickImage: () => _triggerHapticAndAnimation(widget.pickImage),
            selectedImage: widget.selectedImage,
            imageUrl: widget.submittedDocument?.currentImageUrl,
          ),
          SizedBox(height: 15),
          _buildDocumentAttachSection(context),
          SizedBox(height: 20),
          enterDocumentNameEnAr(
            context,
            englishController: widget.englishController,
            arabicController: widget.arabicController,
            documentNameKey: widget.documentNameFormKey,
            onChanged: (_) => widget.onChanged(),
            onArabicChanged: (_) => widget.onChanged(),
          ),
          SizedBox(height: 15),
          documentDescNameEnAr(
            context,
            englishDescController: widget.englishDescController,
            arabicDescController: widget.arabicDescController,
            documentDescriptionFormKey: widget.documentDescriptionKey,
            onChanged: (_) => widget.onChanged(),
            onArabicChanged: (_) => widget.onChanged(),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentAttachSection(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    if (widget.isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).attach_document,
            style: StyleText.fontSize14Weight500.copyWith(
              color: lightMode
                  ? AppColors.blackButton
                  : AppColors.white,
            ),
          ),
          SizedBox(height: 8.h),
          _buildDocumentAttachButton(context),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            S.of(context).attach_document,
            style: StyleText.fontSize14Weight500.copyWith(
              color: lightMode
                  ? AppColors.blackButton
                  : AppColors.white,
            ),
          ),
        ),
        SizedBox(width: 15.w),
        Expanded(child: _buildDocumentAttachButton(context)),
      ],
    );
  }

  Widget _buildDocumentAttachButton(BuildContext context) {
    if (widget.selectedDocument == null && widget.submittedDocument == null) {
      return ScaleTransition(
        scale: _scaleAnimation,
        child: attachDocumentButton(
          buttonWidth: 410.w,
          context,
          onPressed: () => _triggerHapticAndAnimation(widget.pickDocument),
          text: S.of(context).attach_document,
          icon: CustomSvgImage(
            color: AppColors.textButton,
            assetPath: 'assets/icons_assets/main_icons_assets/bulk_upload_qiyas.svg',
            height: 16.sp,
            width: 16.sp,
          ),
        ),
      );
    }

    if (widget.submittedDocument != null && widget.selectedDocument == null) {
      return ScaleTransition(
        scale: _scaleAnimation,
        child: selectedDocumentWidget(
          context,
          fileName: widget.submittedDocument!.currentDocumentFileName,
          fileSize: widget.submittedDocument!.currentDocumentSize,
          uploadedDate: DateTime.now(),
          onRemove: () => _triggerHapticAndAnimation(widget.removeDocument),
          fileExtension: widget.submittedDocument!.currentDocumentExtension,
        ),
      );
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: selectedDocumentWidget(
        context,
        fileName: widget.documentFileName ?? '',
        fileSize: widget.documentSize,
        uploadedDate: widget.documentUploadedDate ?? DateTime.now(),
        onRemove: () => _triggerHapticAndAnimation(widget.removeDocument),
        fileExtension: widget.documentExtension ?? '',
      ),
    );
  }
}