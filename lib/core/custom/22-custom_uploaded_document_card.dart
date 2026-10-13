/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: product_warranty_card.dart
/// Purpose: Declares `ProductWarrantyCard`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

// Figma node 6550:9945 — product warranty / attachment card with
// removable file row and expiry date.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';

import 'package:knowticed_plus/core/custom/52-custom_upload_document.dart';

/// Attachment card: title + file row (thumbnail, name, size, remove badge)
/// + trailing date.
///
/// ```dart
/// ProductWarrantyCard(
///   title: 'Product Warranty',
///   fileName: 'Watermark.png',
///   fileSize: '2.5 MB',
///   date: '29 Dec 2023',
///   onRemove: () {},
///   onTapFile: () {},
/// )
/// ```
class ProductWarrantyCard extends StatelessWidget {
  /// Shown in place of a real size when the caller passes none.
  ///
  /// WARNING — THIS IS NOT THE FILE'S SIZE. It is a fixed placeholder, so a
  /// 5 MB attachment still reads "22 kB". It exists because the GRC detail
  /// pages hold only a download URL, which carries no byte count, and the
  /// design calls for two lines under the icon.
  ///
  /// The real fix is upstream: record the size at upload time (the picked
  /// `PlatformFile` knows it — `PolicyDocumentInfo.fromPlatformFile`
  /// already formats one into `sizeLabel`) and persist it alongside the
  /// document URL, then pass it in as [fileSize]. Until that lands, treat
  /// anything this prints as decoration, not as data.
  static const String placeholderFileSize = '22 kB';

  final String title;
  final String fileName;
  /// The file's size, already formatted ('2.5 MB').
  ///
  /// Null falls back to [placeholderFileSize] so the name/size pair always
  /// renders as two lines, which is how Figma draws the card — see the
  /// warning on that constant before relying on what it shows.
  final String? fileSize;
  final String? date;
  final Widget? fileIcon;

  /// Overrides the extension read out of [fileName]. Pass it when the real
  /// type is known but the displayed name does not carry it (a storage key,
  /// a renamed download).
  final String? fileExtension;

  final VoidCallback? onRemove;
  final VoidCallback? onTapFile;
  final double? width;

  /// Opt-in layout (Time Tracker owner review G3, 13/10/2026): the remove
  /// icon in the card's top-end CORNER, and size + date on one line under
  /// the name (date at the end), so name and date line up.
  final bool removeOnCorner;

  const ProductWarrantyCard({
    super.key,
    required this.title,
    required this.fileName,
    this.fileSize,
    this.date,
    this.fileIcon,
    this.fileExtension,
    this.onRemove,
    this.onTapFile,
    this.width,
    this.removeOnCorner = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 283.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // An empty title adds no gap (the card lines up with its label).
          if (title.isNotEmpty) ...[
            Text(title, style: CardStyles.label(12)),
            SizedBox(height: 6.h),
          ],
          if (removeOnCorner) _cornerCard() else InkWell(
            onTap: onTapFile,
            borderRadius: CardStyles.radius(),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: CardStyles.radius(),
                boxShadow: CardStyles.shadow,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // File thumbnail box.
                  Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 30.r,
                        height: 30.r,
                        child: FittedBox(
                          child: fileIcon ?? _defaultFileIcon(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // File name + size
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          fileName,
                          style: CardStyles.value(12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          fileSize ?? placeholderFileSize,
                          style: CardStyles.label(10),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // Date + Remove stacked vertically
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      if (onRemove != null) ...[
                        SizedBox(height: 2.h),
                        InkWell(
                          onTap: onRemove,
                          customBorder: const CircleBorder(),
                          child: SizedBox(
                            width: 15.r,
                            height: 15.r,
                            child: CustomSvgImage(assetPath: CardSvg.remove),
                          ),
                        ),
                      ],

                      SizedBox(height: 2.h),

                      if (date != null)
                        Text(date!, style: CardStyles.label(10)),

                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// [removeOnCorner] layout: icon · name over "size … date", remove (–)
  /// pinned to the top-end corner.
  Widget _cornerCard() {
    return InkWell(
      onTap: onTapFile,
      borderRadius: CardStyles.radius(),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: CardStyles.radius(),
          boxShadow: CardStyles.shadow,
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(8.r, 8.r, onRemove != null ? 26.r : 8.r, 8.r),
              child: Row(
                children: [
                  SizedBox(
                    width: 40.r,
                    height: 40.r,
                    child: Center(
                      child: SizedBox(
                        width: 30.r,
                        height: 30.r,
                        child: FittedBox(child: fileIcon ?? _defaultFileIcon()),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(fileName, style: CardStyles.value(12), maxLines: 1, overflow: TextOverflow.ellipsis),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Text(fileSize ?? placeholderFileSize, style: CardStyles.label(10)),
                            const Spacer(),
                            if (date != null) Text(date!, style: CardStyles.label(10)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (onRemove != null)
              PositionedDirectional(
                top: 6.r,
                end: 6.r,
                child: InkWell(
                  onTap: onRemove,
                  customBorder: const CircleBorder(),
                  child: SizedBox(
                    width: 15.r,
                    height: 15.r,
                    child: CustomSvgImage(assetPath: CardSvg.remove),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Picks the SVG by file extension (pdf, doc, xlsx, image, video...).
  ///
  /// Uses [fileTypeIconAsset], not the upload dialog's [getFileIcon]: the
  /// latter knows only pdf / ppt / doc / png, so a spreadsheet or a video
  /// attachment came back as a photo icon.
  ///
  /// And [fileExtensionOf], not `fileName.split('.').last`: callers derive
  /// [fileName] from a storage URL (`policyDocumentEn.split('/').last`), so
  /// the naive split returned `pdf?alt=media&token=…` and every PDF fell
  /// through to the default icon.
  Widget _defaultFileIcon() {
    final String ext = (fileExtension == null || fileExtension!.trim().isEmpty)
        ? fileExtensionOf(fileName)
        : fileExtension!.trim().toLowerCase();
    return CardSvg.icon(fileTypeIconAsset(ext));
  }
}
