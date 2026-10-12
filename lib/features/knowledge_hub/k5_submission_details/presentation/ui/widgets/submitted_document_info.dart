/// Module: knowledge_hub / presentation / s5_submission_details / widgets/submitted_document_info.dart
/// ************************* FILE INFO *************************** ///
/// File Name: submitted_document_info.dart
/// Purpose: Submitted document info — Submission Details (S5) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import '../../../../main_controller/helper/responsive_helper.dart';
import './build_submitted_document_data_row.dart';

Widget submittedDocumentInfo(
  BuildContext context, {
  required String documentName,
  required String documentDescription,
  required bool isMobile,
  required bool lightMode,
}) {
  final isMobile = ResponsivePage.isMobile(context);
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      buildInfoRow(
        iconPath: 'assets/icons_assets/knowledge_hub_assets/document_name_icon.svg',
        label: '${S.of(context).document_name}: ',
        value: documentName,
        lightMode: lightMode,
      ),
      SizedBox(height: 6.sp),
      if (!isMobile) ...[
        buildSubmittedDocumentDescription(
          context,
          documentDescription: documentDescription,
          isMobile: isMobile,
          lightMode: lightMode,
        ),
      ],
    ],
  );
}
