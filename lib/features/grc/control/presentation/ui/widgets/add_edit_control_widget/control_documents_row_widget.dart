/// Module: GRC Policy Management
/// Description: Control Document (English/Arabic) upload/preview row for
///              the Add/Edit Control form, extracted from
///              AddEditControlPage.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-15
/// Dependencies: flutter, PolicyDocumentPreviewWidget, PolicyDocumentInfo
/// Revision History: 2026-07-15 - Initial creation (inline in
///                                add_edit_control_page.dart)
///                   2026-07-27 - Split out into its own widget file
library;

/// ************************* FILE INFO *************************** ///
/// File Name: control_documents_row_widget.dart
/// Purpose: Contains ControlDocumentsRowWidget, the Control Document ENG/AR
///          upload-or-preview row.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 27/7/2026

import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_document_info.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/widgets/grc_policy_widget/policy_document_preview_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// class name: [ControlDocumentsRowWidget]
///
/// purpose: renders the Control Document ENG/AR upload-or-preview columns.
///          Two Expanded columns split the row 50/50 when Arabic is on;
///          with only the ENG column left, an Expanded there would stretch
///          it across the whole row instead of keeping that same
///          half-width look, so a `FractionallySizedBox` is used instead.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 27/7/2026
class ControlDocumentsRowWidget extends StatelessWidget {
  final bool isArabicEnabled;
  final PolicyDocumentInfo? documentEn;
  final PolicyDocumentInfo? documentAr;
  final VoidCallback onUploadDocumentEn;
  final VoidCallback onUploadDocumentAr;
  final VoidCallback onRemoveDocumentEn;
  final VoidCallback onRemoveDocumentAr;

  const ControlDocumentsRowWidget({
    super.key,
    required this.isArabicEnabled,
    required this.documentEn,
    required this.documentAr,
    required this.onUploadDocumentEn,
    required this.onUploadDocumentAr,
    required this.onRemoveDocumentEn,
    required this.onRemoveDocumentAr,
  });

  Widget _documentButton({required VoidCallback onTap, required String title}) {
    return customButtonWithSvg(
      colorBorder: AppColors.primary,
      space: 10.w,
      radius: 8.r,
      widthImage: 16.w,
      heightImage: 16.h,
      function: onTap,
      title: title,
      textStyle:
          StyleText.fontSize14Weight500.copyWith(color: AppColors.textButton),
      image: 'assets/hrAsset/Upload.svg',
      color: AppColors.primary,
      width: 220.w,
      height: 36.h,
      svgColor: AppColors.textButton,
    );
  }

  /// function name: [_documentColumn]
  ///
  /// purpose: one document upload/preview column — shared by the ENG and AR
  ///          Control Document sections so their layout stays identical
  ///          whether they're shown side by side or (Arabic disabled) alone.
  Widget _documentColumn({
    required String label,
    required PolicyDocumentInfo? document,
    required VoidCallback onRemove,
    required VoidCallback onUpload,
  }) {
    return Column(
      spacing: 8.h,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
        document != null
            ? PolicyDocumentPreviewWidget(
                document: document, onRemove: onRemove)
            : SizedBox(
                width: double.infinity,
                child:
                    _documentButton(onTap: onUpload, title: 'Control Document'),
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // iPhone (375): the document slots run full width, stacked. A
    // half-width upload button (or two side by side) is the iPad/desktop
    // layout and leaves the label clipped on a phone.
    if (screenSizeOf(context) == ScreenSize.mobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: _documentColumn(
              label: 'Control Document ENG',
              document: documentEn,
              onRemove: onRemoveDocumentEn,
              onUpload: onUploadDocumentEn,
            ),
          ),
          if (isArabicEnabled) ...[
            SizedBox(height: 15.h),
            SizedBox(
              width: double.infinity,
              child: _documentColumn(
                label: 'Control Document AR',
                document: documentAr,
                onRemove: onRemoveDocumentAr,
                onUpload: onUploadDocumentAr,
              ),
            ),
          ],
        ],
      );
    }

    return isArabicEnabled
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _documentColumn(
                  label: 'Control Document ENG',
                  document: documentEn,
                  onRemove: onRemoveDocumentEn,
                  onUpload: onUploadDocumentEn,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _documentColumn(
                  label: 'Control Document AR',
                  document: documentAr,
                  onRemove: onRemoveDocumentAr,
                  onUpload: onUploadDocumentAr,
                ),
              ),
            ],
          )
        : FractionallySizedBox(
            widthFactor: 0.5,
            alignment: AlignmentDirectional.centerStart,
            child: _documentColumn(
              label: 'Control Document ENG',
              document: documentEn,
              onRemove: onRemoveDocumentEn,
              onUpload: onUploadDocumentEn,
            ),
          );
  }
}
