/// Module: knowledge_hub / presentation / s5_submission_details / widgets/submitted_document_header.dart
/// ************************* FILE INFO *************************** ///
/// File Name: submitted_document_header.dart
/// Purpose: Submitted document header — Submission Details (S5) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/knowledge_hub/k5_submission_details/presentation/ui/widgets/submitted_document_info.dart';

import 'package:knowticed_plus/core/custom/32-custom_svg.dart';

Widget buildSubmittedDocumentHeader(
  BuildContext context, {
  required String documentName,
  required String documentDescription,
  required String documentExtension,
  required bool isMobile,
  required bool lightMode,
}) {
  String getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'assets/icons_assets/main_icons_assets/svg_pdf_icon.svg';
      case 'ppt':
      case 'pptx':
        return 'assets/icons_assets/main_icons_assets/ppt_attachment_icon.svg';
      case 'doc':
      case 'docx':
        return 'assets/icons_assets/main_icons_assets/doc_icon.svg';
      case 'png':
      case 'jpg':
      case 'jpeg':
        return 'assets/icons_assets/main_icons_assets/svg_image_icon.svg';
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'wmv':
      case 'flv':
      case 'mkv':
      case 'webm':
        return 'assets/icons_assets/main_icons_assets/knowledgeVideo.svg';
      case 'xlsx':
      case 'xls':
      case 'xlsm':
      case 'csv':
        return 'assets/icons_assets/main_icons_assets/excell.svg';
      default:
        return 'assets/icons_assets/main_icons_assets/svg_image_icon.svg';
    }
  }


  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      CustomSvgImage(
        assetPath: getFileIcon(documentExtension),
        height: 50.sp,
        width: 45.sp,
        fit: BoxFit.fill,
      ),
      SizedBox(width: 6.w),
      submittedDocumentInfo(
        context,
        documentName: documentName,
        documentDescription: documentDescription,
        isMobile: isMobile,
        lightMode: lightMode,
      ),
    ],
  );
}
