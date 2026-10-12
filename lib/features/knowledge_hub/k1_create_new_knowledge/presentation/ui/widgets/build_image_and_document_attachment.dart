/// Module: knowledge_hub / presentation / s1_create_new_knowledge / widgets/build_image_and_document_attachment.dart
/// ************************* FILE INFO *************************** ///
/// File Name: build_image_and_document_attachment.dart
/// Purpose: Image & document attachment display/formatting helpers for the create-knowledge form.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import '../../../../main_controller/data/models/create_knowledge_new_model.dart';
import './knowledge_hub_file_utils.dart';
import '../../../../main_controller/presentation/ui/widgets/attach_document_button.dart';
import '../../../../main_controller/presentation/ui/widgets/document_desc_en_ar.dart';
import '../../../../main_controller/presentation/ui/widgets/enter_document_name_en_ar.dart';
import '../../../../main_controller/presentation/ui/widgets/selected_document_widget.dart';
import '../../../../main_controller/presentation/ui/widgets/upload_image_widget.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

Widget buildImageAndDocumentSection(
    BuildContext context, {
      required bool isMobile,
      required VoidCallback pickImage,
      required File? selectedImage,
      required CreateKnowledgeModel? submittedDocument,
      required File? selectedDocument,
      required VoidCallback functionToPickDocument,
      required VoidCallback functionToRemoveDocument,
      required String fileName,
      required String fileExtension,
      required int fileSize,
      required DateTime uploadedDate,
      required TextEditingController englishController,
      required TextEditingController arabicController,
      required GlobalKey<FormState> documentNameKey,
      required void Function(String)? onNameChanged,
      required void Function(String)? onArabicNameChanged,
      required TextEditingController englishDescController,
      required TextEditingController arabicDescController,
      required GlobalKey<FormState> documentDescriptionFormKey,
      required void Function(String)? onDescChanged,
      required void Function(String)? onArabicDescChanged,
    }) {
  return Container(
    width: ScreenUtil().screenWidth,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8.r),
      color: AppColors.colorWhite,
    ),
    padding: EdgeInsets.all(15),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        uploadImageWidget(
          pickImage: pickImage,
          selectedImage: selectedImage,
          imageUrl: submittedDocument?.currentImageUrl,
          context: context,
        ),
        SizedBox(height: 15),
        _buildDocumentAttachSection(
          context,
          isMobile: isMobile,
          submittedDocument: submittedDocument,
          selectedDocument: selectedDocument,
          functionToPickDocument: functionToPickDocument,
          functionToRemoveDocument: functionToRemoveDocument,
          fileName: fileName,
          fileExtension: fileExtension,
          fileSize: fileSize,
          uploadedDate: uploadedDate,
        ),
        SizedBox(height: 20),
        _buildDocumentNameSection(
          context,
          englishController: englishController,
          arabicController: arabicController,
          documentNameKey: documentNameKey,
          onNameChanged: onNameChanged,
          onArabicNameChanged: onArabicNameChanged,
        ),
        SizedBox(height: 15),
        _buildDescriptionSection(
          context,
          englishDescController: englishDescController,
          arabicDescController: arabicDescController,
          documentDescriptionFormKey: documentDescriptionFormKey,
          onDescChanged: onDescChanged,
          onArabicDescChanged: onArabicDescChanged,
        ),
      ],
    ),
  );
}

Widget _buildDocumentAttachSection(
    BuildContext context, {
      required bool isMobile,
      required CreateKnowledgeModel? submittedDocument,
      required File? selectedDocument,
      required VoidCallback functionToPickDocument,
      required VoidCallback functionToRemoveDocument,
      required String fileName,
      required String fileExtension,
      required int fileSize,
      required DateTime uploadedDate,
    }) {
  final lightMode = Theme.of(context).brightness == Brightness.light;

  if (isMobile) {
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
        SizedBox(height: 15),
        _buildDocumentAttachButton(
          context,
          submittedDocument: submittedDocument,
          selectedDocument: selectedDocument,
          functionToPickDocument: functionToPickDocument,
          functionToRemoveDocument: functionToRemoveDocument,
          fileName: fileName,
          fileExtension: fileExtension,
          fileSize: fileSize,
          uploadedDate: uploadedDate,
        ),
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
      SizedBox(width: 15),
      Expanded(
        child: _buildDocumentAttachButton(
          context,
          submittedDocument: submittedDocument,
          selectedDocument: selectedDocument,
          functionToPickDocument: functionToPickDocument,
          functionToRemoveDocument: functionToRemoveDocument,
          fileName: fileName,
          fileExtension: fileExtension,
          fileSize: fileSize,
          uploadedDate: uploadedDate,
        ),
      ),
    ],
  );
}

Widget _buildDocumentAttachButton(
    BuildContext context, {
      double? buttonWidth,
      required CreateKnowledgeModel? submittedDocument,
      required File? selectedDocument,
      required VoidCallback functionToPickDocument,
      required VoidCallback functionToRemoveDocument,
      required String fileName,
      required String fileExtension,
      required int fileSize,
      required DateTime uploadedDate,
    }) {
  final hasExistingDocument =
      submittedDocument != null && selectedDocument == null;
  final hasSelectedDocument = selectedDocument != null;

  if (!hasExistingDocument && !hasSelectedDocument) {
    return attachDocumentButton(
      context,
      onPressed: functionToPickDocument,
      text: S.of(context).attach_document,
      icon: CustomSvgImage(
          assetPath: 'assets/knowldge_image_module/KnowledgeUpload Minimalistic.svg',
          height: 16.sp,
          width: 16.sp
      ),
      buttonWidth: buttonWidth,
    );
  }

  // ✅ FIXED: Extract upload date from model using helper function
  if (hasExistingDocument) {
    return selectedDocumentWidget(
      context,
      fileName: submittedDocument.currentDocumentFileName,
      fileSize: submittedDocument.currentDocumentSize,
      uploadedDate: KnowledgeHubFileUtils.getUploadDateFromModel(
        submittedDocument,
      ),
      onRemove: functionToRemoveDocument,
      fileExtension: submittedDocument.currentDocumentExtension,
    );
  }

  return selectedDocumentWidget(
    context,
    fileName: fileName,
    fileSize: fileSize,
    uploadedDate: uploadedDate,
    onRemove: functionToRemoveDocument,
    fileExtension: fileExtension,
  );
}

Widget _buildDocumentNameSection(
    BuildContext context, {
      required TextEditingController englishController,
      required TextEditingController arabicController,
      required GlobalKey<FormState> documentNameKey,
      required void Function(String)? onNameChanged,
      required void Function(String)? onArabicNameChanged,
    }) {
  return enterDocumentNameEnAr(
    context,
    englishController: englishController,
    arabicController: arabicController,
    documentNameKey: documentNameKey,
    onChanged: onNameChanged,
    onArabicChanged: onArabicNameChanged,
  );
}

Widget _buildDescriptionSection(
    BuildContext context, {
      required TextEditingController englishDescController,
      required TextEditingController arabicDescController,
      required GlobalKey<FormState> documentDescriptionFormKey,
      required void Function(String)? onDescChanged,
      required void Function(String)? onArabicDescChanged,
    }) {
  return documentDescNameEnAr(
    context,
    englishDescController: englishDescController,
    arabicDescController: arabicDescController,
    documentDescriptionFormKey: documentDescriptionFormKey,
    onChanged: onDescChanged,
    onArabicChanged: onArabicDescChanged,
  );
}