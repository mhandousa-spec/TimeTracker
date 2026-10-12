/// Module: GRC Policy Management
/// Description: Read-only Control Document (English/Arabic) preview row for
///              the Control Details page, extracted from
///              ControlDetailsPage.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-21
/// Dependencies: flutter, ProductWarrantyCard
/// Revision History: 2026-07-21 - Initial creation (inline in
///                                control_details_page.dart)
///                   2026-07-28 - Split out into its own widget file
library;

/// ************************* FILE INFO *************************** ///
/// File Name: control_documents_preview_row_widget.dart
/// Purpose: Contains ControlDocumentsPreviewRowWidget, the read-only
///          document card(s) for a Control's English/Arabic documents.
///          Renders nothing when neither document is set.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 28/7/2026

import 'package:knowticed_plus/core/custom/22-custom_uploaded_document_card.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/custom/52-custom_upload_document.dart'
    show fileNameOf;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:knowticed_plus/generated/l10n.dart';

/// class name: [ControlDocumentsPreviewRowWidget]
///
/// purpose: renders one or two read-only document preview cards for a
///          Control's English/Arabic documents, side by side.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 28/7/2026
class ControlDocumentsPreviewRowWidget extends StatelessWidget {
  final String? documentEnUrl;
  final String? documentArUrl;
  final DateTime lastModifiedDate;
  final DateFormat dateFormat;

  const ControlDocumentsPreviewRowWidget({
    super.key,
    required this.documentEnUrl,
    required this.documentArUrl,
    required this.lastModifiedDate,
    required this.dateFormat,
  });

  /// One document card. [expand] is false on 375, where the cards are
  /// stacked in a Column and an Expanded would claim the leftover height.
  Widget _documentCard(
    BuildContext context,
    String url,
    String title, {
    required bool expand,
  }) {
    // No outer Container here. ProductWarrantyCard ALREADY draws the card
    // (AppColors.card + CardStyles.shadow) around the file row, with its
    // title sitting above it; wrapping the pair in a second filled, bordered
    // box put a border around the title too and double-framed the row --
    // Figma has one card, not two.
    final Widget card = ProductWarrantyCard(
      title: title,
      // fileNameOf, not url.split('/').last: the stored value is a download
      // URL, so the naive split printed the whole encoded storage key
      // across the card where Figma prints 'Watermark.png'.
      fileName: fileNameOf(url),
      // Figma labels the date 'Uploaded On: 28 Dec 2024'; the bare date
      // read as an unexplained number in the corner.
      date: '${S.of(context).uploadedOn}: '
          '${dateFormat.format(lastModifiedDate)}',
    );
    return expand
        ? Expanded(child: card)
        : SizedBox(width: double.infinity, child: card);
  }

  @override
  Widget build(BuildContext context) {
    final hasEn = documentEnUrl != null;
    final hasAr = documentArUrl != null;
    if (!hasEn && !hasAr) return const SizedBox.shrink();

    // Side by side at 768 / 1024; stacked full width at 375.
    final bool isMobile = screenSizeOf(context) == ScreenSize.mobile;
    final bool expand = !isMobile;

    // Figma draws the two documents as a fixed two-up grid. At 768 / 1024
    // each card therefore keeps its half-width slot even when only one
    // document exists — a lone card stretched across the full row reads as
    // a different component. On 375 they simply stack.
    final List<Widget> cards = isMobile
        ? [
            if (hasEn)
              _documentCard(context, documentEnUrl!,
                  S.of(context).controlDocumentEng,
                  expand: false),
            if (hasEn && hasAr) SizedBox(height: 10.h),
            if (hasAr)
              _documentCard(context, documentArUrl!,
                  S.of(context).controlDocumentAr,
                  expand: false),
          ]
        : [
            hasEn
                ? _documentCard(context, documentEnUrl!,
                    S.of(context).controlDocumentEng,
                    expand: true)
                : const Expanded(child: SizedBox.shrink()),
            SizedBox(width: 12.w),
            hasAr
                ? _documentCard(context, documentArUrl!,
                    S.of(context).controlDocumentAr,
                    expand: true)
                : const Expanded(child: SizedBox.shrink()),
          ];

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: isMobile
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: cards)
          : Row(crossAxisAlignment: CrossAxisAlignment.start, children: cards),
    );
  }
}
