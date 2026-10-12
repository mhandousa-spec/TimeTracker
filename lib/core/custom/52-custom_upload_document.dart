/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: custom_upload_document_dialog.dart
/// Purpose: Declares `_DialogShell`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

// ─────────────────────────────────────────────
//  UPLOAD / ATTACHMENT DIALOG  (Figma-matched)
// ─────────────────────────────────────────────
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/44-custom_validated_textfield.dart';

///
/// Usage:
/// ```dart
/// showUploadDialog(
///   context: context,
///   onSubmit: (file, title) { /* handle upload */ },
/// );
/// ```
Future<void> showUploadDialog({
  required BuildContext context,
  String dialogTitle = 'Adding Attachment',
  String titleFieldLabel = 'Title Name',
  String titleFieldHint = 'Text here',
  String submitLabel = 'Submit',
  String discardLabel = 'Discard',
  String browseLabel = 'Browse Files',
  TextDirection textDirection = TextDirection.ltr,
  String? headerIconAsset,
  List<String>? allowedExtensions,
  void Function(PlatformFile file, String titleName)? onSubmit,
}) {
  return showDialog(
    context: context,
    barrierColor: AppColors.totalBlack.withOpacity(0.4),
    builder: (_) => _UploadDialog(
      dialogTitle: dialogTitle,
      titleFieldLabel: titleFieldLabel,
      titleFieldHint: titleFieldHint,
      submitLabel: submitLabel,
      discardLabel: discardLabel,
      browseLabel: browseLabel,
      textDirection: textDirection,
      headerIconAsset: headerIconAsset,
      allowedExtensions: allowedExtensions,
      onSubmit: onSubmit,
    ),
  );
}

// ─────────────────────────────────────────────
//  Helper — file-type icon path
// ─────────────────────────────────────────────
String getFileIcon(String extension) {
  switch (extension.toLowerCase()) {
    case 'pdf':
      return 'assets/icons_assets/main_icons_assets/pdf_file_red.svg';
    case 'ppt':
    case 'pptx':
      return 'assets/icons_assets/main_icons_assets/powerpoint_logo.svg';
    case 'doc':
    case 'docx':
      return 'assets/icons_assets/main_icons_assets/doc_file_blue.svg';
    case 'png':
      return 'assets/icons_assets/main_icons_assets/image_photo_rounded.svg';
    default:
      return 'assets/icons_assets/main_icons_assets/image_photo_rounded.svg';
  }
}

// ─────────────────────────────────────────────
//  Helper — file-type icon path (full coverage)
// ─────────────────────────────────────────────

/// The icon asset for a file type, covering every type the app actually
/// accepts: Office documents, images, video and spreadsheets.
///
/// This is deliberately SEPARATE from [getFileIcon] above, which the upload
/// dialog uses and which only knows pdf / ppt / doc / png — everything else,
/// an .xlsx and an .mp4 included, comes back as a photo icon there. Rather
/// than change the icons under every existing upload-dialog call site, the
/// fuller mapping lives here and cards opt into it.
///
/// Accepts either a bare extension ('pdf') or a whole file name or URL
/// ('Watermark.PDF', '.../doc.pdf?alt=media&token=…') — anything containing
/// a '.', '/' or '?' is run through [fileExtensionOf] first.
String fileTypeIconAsset(String extensionOrName) {
  final String extension = extensionOrName.contains(RegExp(r'[./\\?#]'))
      ? fileExtensionOf(extensionOrName)
      : extensionOrName.toLowerCase();

  switch (extension) {
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

/// The lower-cased extension of [nameOrUrl], without the dot, or '' when
/// there isn't a plausible one.
///
/// WHY THIS IS NOT `name.split('.').last`: most callers hand over a name
/// derived from a storage URL, not a clean file name. A Firebase download
/// URL ends `…%2Fdoc.pdf?alt=media&token=1a2b-3c4d`, so splitting on '.'
/// yields `pdf?alt=media&token=1a2b-3c4d`, which matches no case in
/// [fileTypeIconAsset] and quietly falls through to the generic image icon —
/// which is why PDFs were showing a photo glyph. So: drop the query and
/// fragment, percent-decode, take the last path segment, and only then read
/// the extension.
String fileExtensionOf(String nameOrUrl) {
  final String name = fileNameOf(nameOrUrl);
  if (name.isEmpty) return '';

  final int dot = name.lastIndexOf('.');
  if (dot < 0 || dot == name.length - 1) return '';

  final String extension = name.substring(dot + 1).toLowerCase();
  // Guards against a dotted folder or version segment ('v1.2/report') being
  // read as an extension.
  return RegExp(r'^[a-z0-9]{1,5}$').hasMatch(extension) ? extension : '';
}

/// The human-readable file name inside [nameOrUrl] — what a card should
/// actually print.
///
/// A download URL is not a file name. Callers that write
/// `url.split('/').last` end up printing the whole encoded storage key:
///
///     Policies_Files%2F5839e033-…%2FDocuments%2FEn%2F1789419500602_report.pdf?alt=media&token=…
///
/// which is what the Control Details page was showing where Figma shows
/// "report.pdf". So: drop the query and fragment, percent-decode, take the
/// last path segment, and drop the upload timestamp the storage layer
/// prefixes (see PolicyStorageDataSource._buildFileName, which names every
/// upload '<epochMillis>_<originalName>').
String fileNameOf(String nameOrUrl) {
  String name = nameOrUrl.trim();
  if (name.isEmpty) return '';

  final int queryAt = name.indexOf(RegExp(r'[?#]'));
  if (queryAt >= 0) name = name.substring(0, queryAt);

  // Storage paths arrive percent-encoded ('policies%2Fabc%2Fdoc.pdf').
  // decodeComponent throws on a malformed '%' run, which is not worth
  // failing a file name over — fall back to the raw string.
  try {
    name = Uri.decodeComponent(name);
  } on FormatException {
    // keep `name` as-is
  } on ArgumentError {
    // 9/10/2026 (Time Tracker UI pass): a plain non-ASCII name ("Medical
    // Report — …", an Arabic file name) throws ArgumentError, not
    // FormatException — it crashed every file card showing such a name.
    // Keep `name` as-is.
  }

  final int slash = name.lastIndexOf(RegExp(r'[/\\]'));
  if (slash >= 0) name = name.substring(slash + 1);

  // '1789419500602_report.pdf' -> 'report.pdf'. Guarded to 10+ digits so a
  // genuine name that merely starts with a number ('2024_budget.xlsx') is
  // left alone.
  final Match? stamped = RegExp(r'^\d{10,}_(.+)$').firstMatch(name);
  if (stamped != null) name = stamped.group(1)!;

  return name;
}

// ─────────────────────────────────────────────
//  _DialogShell — rounded dialog wrapper (no border)
// ─────────────────────────────────────────────
class _DialogShell extends StatelessWidget {
  final Widget child;
  final double width;

  const _DialogShell({required this.child, required this.width});

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    return Dialog(
      backgroundColor: lightMode ? AppColors.card : AppColors.background,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Container(
        width: width,
        padding: EdgeInsets.all(20.r),
        child: child,
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Dialog states
// ─────────────────────────────────────────────
enum _UploadState {
  empty,   // State 1: no file — drop zone + Discard/Browse buttons (NO title field)
  picked,  // State 2: file picked — file card + Title + Discard/Submit
  removed, // State 3: file removed — Upload button + Title + Discard/Submit
}

// ─────────────────────────────────────────────
//  _UploadDialog — StatefulWidget
// ─────────────────────────────────────────────
class _UploadDialog extends StatefulWidget {
  final String dialogTitle;
  final String titleFieldLabel;
  final String titleFieldHint;
  final String submitLabel;
  final String discardLabel;
  final String browseLabel;
  final TextDirection textDirection;
  final String? headerIconAsset;
  final List<String>? allowedExtensions;
  final void Function(PlatformFile, String)? onSubmit;

  const _UploadDialog({
    required this.dialogTitle,
    required this.titleFieldLabel,
    required this.titleFieldHint,
    required this.submitLabel,
    required this.discardLabel,
    required this.browseLabel,
    required this.textDirection,
    this.headerIconAsset,
    this.allowedExtensions,
    this.onSubmit,
  });

  @override
  State<_UploadDialog> createState() => _UploadDialogState();
}

// ─────────────────────────────────────────────
//  _UploadDialogState
// ─────────────────────────────────────────────
class _UploadDialogState extends State<_UploadDialog> {
  PlatformFile? _pickedFile;
  _UploadState _uploadState = _UploadState.empty;
  final TextEditingController _titleCtrl = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  // ── File picker ──
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: widget.allowedExtensions != null ? FileType.custom : FileType.any,
      allowedExtensions: widget.allowedExtensions,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _pickedFile = result.files.first;
        _uploadState = _UploadState.picked;
      });
    }
  }

  // ── Remove file ──
  void _removeFile() {
    setState(() {
      _pickedFile = null;
      _uploadState = _UploadState.removed;
    });
  }

  // ── Submit handler ──
  void _handleSubmit() {
    setState(() => _submitted = true);
    if (_pickedFile == null) return;
    if (_titleCtrl.text.trim().isEmpty) return;
    Navigator.of(context).pop();
    widget.onSubmit?.call(_pickedFile!, _titleCtrl.text.trim());
  }

  // ── Helpers ──
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Extract extension from file name
  String _getExtension(String fileName) {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last : '';
  }

  // ── Build ──
  @override
  Widget build(BuildContext context) {
    return _DialogShell(
      width: 430.w, // ✅ Fixed width = 430.w
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          _buildHeader(),
          SizedBox(height: 20.h),

          // ── State 1: Drop zone ONLY — NO title field ──
          if (_uploadState == _UploadState.empty) ...[
            _buildDropZone(),
            SizedBox(height: 20.h),
            _buildState1Buttons(),

            // ── State 2 & 3: File section + title + submit buttons ──
          ] else ...[
            Text(
              'File',
              style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.text.withOpacity(0.6),
              ),
            ),
            SizedBox(height: 8.h),

            // State 2 → file card | State 3 → upload button
            if (_uploadState == _UploadState.picked)
              _buildFileCard()
            else
              _buildUploadButton(),

            SizedBox(height: 16.h),

            // Title Name field
            Text(
              widget.titleFieldLabel,
              style: StyleText.fontSize12Weight400
                  .copyWith(color: AppColors.text),
            ),
            SizedBox(height: 6.h),
            CustomTextField(
              hint: widget.titleFieldHint,
              controller: _titleCtrl,
              required: _submitted,
              fillColor: AppColors.card,
              textDirection: widget.textDirection,
              onChanged: (_) => setState(() {}),
            ),

            SizedBox(height: 20.h),
            _buildState2And3Buttons(),
          ],

          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Header
  // ─────────────────────────────────────────────
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 36.r,
          height: 36.r,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child:
                 CustomSvgImage(
                   assetPath: "assets/icons_assets/main_icons_assets/cloud_upload.svg",
                   width: 18.r,
                   color: AppColors.textButton,
                   height: 18.r,
                   fit: BoxFit.contain,
                 )
          ),
        ),
        SizedBox(width: 10.w),
        Text(
          widget.dialogTitle,
          style: context.isPhone ? StyleText.fontSize14Weight600.copyWith(color: AppColors.text) : StyleText.fontSize16Weight600.copyWith(color: AppColors.text),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  State 1 — Drop zone (no border, light grey bg)
  // ─────────────────────────────────────────────
  Widget _buildDropZone() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomSvgImage(assetPath: "assets/icons_assets/main_icons_assets/cloud_upload.svg",width: 100.sp,height: 100.sp,fit: BoxFit.fill,color: AppColors.secondaryText,),
          SizedBox(height: 12.h),
          Text(
            'Drag & Drop files here',
            style: StyleText.fontSize16Weight500
                .copyWith(color: AppColors.secondaryText),
          ),
          SizedBox(height: 6.h),
          Text(
            'Or',
            style: StyleText.fontSize13Weight400
                .copyWith(color: AppColors.secondaryText),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  State 1 buttons — Discard (left) | Browse Files (right)
  // ─────────────────────────────────────────────
  Widget _buildState1Buttons() {
    return Row(
      children: [
        Expanded(
          child: _secondaryBtn(
            label: widget.discardLabel,
            onTap: () => Navigator.of(context).pop(),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _primaryBtn(
            label: widget.browseLabel,
            onTap: _pickFile,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  State 2 — File card with SVG icon (NO background box)
  // ─────────────────────────────────────────────
  Widget _buildFileCard() {
    final file = _pickedFile!;
    final now = DateTime.now();
    final ext = _getExtension(file.name);
    final iconPath = getFileIcon(ext);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          // ✅ SVG icon directly — NO white background box
          CustomSvgImage(
            assetPath: iconPath,
            width: 40.r,
            height: 40.r,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 12.w),
          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: StyleText.fontSize13Weight400
                      .copyWith(color: AppColors.text),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      _formatBytes(file.size),
                      style: StyleText.fontSize10Weight400
                          .copyWith(color: AppColors.secondaryText),
                    ),

                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          // Red circle minus button
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: _removeFile,
                child: Container(
                  width: 18.r,
                  height: 18.r,
                  decoration: BoxDecoration(
                    color: AppColors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.remove, size: 12.r, color: AppColors.white),
                ),
              ),
              SizedBox(height: 9.w),
              Text(
                'Date: ${_formatDate(now)}',
                style: StyleText.fontSize10Weight400
                    .copyWith(color: AppColors.secondaryText),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  State 3 — Full-width Upload button (no border)
  // ─────────────────────────────────────────────
  Widget _buildUploadButton() {
    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        width: double.infinity,
        height: 46.h,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.upload_rounded, size: 18.r, color: AppColors.textButton),
            SizedBox(width: 8.w),
            Text(
              'Upload',
              style: StyleText.fontSize14Weight600
                  .copyWith(color: AppColors.textButton),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  States 2 & 3 buttons — Discard | Submit
  // ─────────────────────────────────────────────
  Widget _buildState2And3Buttons() {
    return Row(
      children: [
        Expanded(
          child: _secondaryBtn(
            label: widget.discardLabel,
            onTap: () => Navigator.of(context).pop(),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _primaryBtn(
            label: widget.submitLabel,
            onTap: _handleSubmit,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  Button helpers (no border anywhere)
  // ─────────────────────────────────────────────

  Widget _secondaryBtn({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(

        height: 36.sp,
        decoration: BoxDecoration(
          color: AppColors.greyDark,
          borderRadius: BorderRadius.circular(8.r),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.text),
        ),
      ),
    );
  }

  Widget _primaryBtn({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36.sp,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8.r),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: StyleText.fontSize14Weight600
              .copyWith(color: AppColors.textButton),
        ),
      ),
    );
  }
}
