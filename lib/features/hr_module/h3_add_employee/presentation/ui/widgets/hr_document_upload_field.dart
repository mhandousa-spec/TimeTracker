// ***************************** FILE INFO ***************************** //
// File Name: hr_document_upload_field.dart
// Purpose: Provides the HrDocumentUploadField widget for responsive HR documents.
// Author: Mohamed Elrashidy
// Created At: 2026-08-10
// ********************************************************************* //

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../../../core/constants/app_assets.dart';
import '../../../../../../core/custom/52-custom_upload_document.dart';
import '../../../../../../core/custom/55-custom_responsive_fields.dart';
import '../../../../../../core/custom/6-custom_button_with_svg.dart';
import '../../../../../../core/custom/32-custom_svg.dart';
import '../../../../../../core/theme/app_colors.dart';

import '../../../../../../generated/l10n.dart';
import 'add_employee_read_only_scope.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

/// A responsive HR document adapter backed by the shared upload dialog.
class HrDocumentUploadField extends StatelessWidget {
  const HrDocumentUploadField({
    super.key,
    required this.label,
    required this.file,
    required this.onChanged,
    this.isRequired = true,
  });

  final String label;
  final PlatformFile? file;
  final ValueChanged<PlatformFile?> onChanged;
  final bool isRequired;

  /// Method Name: [_openUploadDialog]
  ///
  /// Purpose: Opens the shared attachment dialog and stores its local result.
  ///
  /// Parameters:
  /// - [context]: Build context used to show the dialog and read localization.
  /// - [onChanged]: Receives the selected in-memory platform file.
  ///
  /// Returns: A future completed after the dialog closes.
  Future<void> _openUploadDialog(
    BuildContext context,
    ValueChanged<PlatformFile?> onChanged,
  ) {
    final localization = S.of(context);
    return showUploadDialog(
      context: context,
      dialogTitle: label,
      titleFieldLabel: localization.titleName,
      titleFieldHint: localization.textHere,
      submitLabel: localization.submit,
      discardLabel: localization.discard,
      browseLabel: localization.browseFiles,
      onSubmit: (selectedFile, _) => onChanged(selectedFile),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = S.of(context);
    if (!AddEmployeeReadOnlyScope.isEnabled(context)) {
      return _ReadOnlyDocumentField(label: label, file: file);
    }
    return FormField<PlatformFile>(
      initialValue: file,
      validator: isRequired
          ? (value) => value == null ? localization.fieldRequired : null
          : null,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildResponsiveFields(
            context: context,
            mobileSpacing: 6,
            left: Text(
              label,
              style: StyleText.fontSize14Weight500,
            ),
            right: (file == null)
                ? SizedBox(
                    child: Center(
                      child: SizedBox(
                        width: 300.sp,
                        child: customButtonWithSvg(
                          title: localization.upload,
                          function: () async {
                            await _openUploadDialog(context, (selected) {
                              field.didChange(selected);
                              onChanged(selected);
                            });
                          },
                          textStyle:
                              StyleText.fontSize14Weight500.copyWith(
                            color: AppColors.textButton,
                          ),
                          color: AppColors.primary,
                          image: AppAssets.upload,
                          widthImage: 18.sp,
                          heightImage: 18.sp,
                          colorBorder: AppColors.transparent,
                          svgColor: AppColors.textButton,
                          fixedRadius: 4.r,
                        ),
                      ),
                    ),
                  )
                : SizedBox(
                    width: 300.sp,
                    child:
                        _buildSelectedFileCard(context, localization, field)),
          ),
          if (field.errorText != null) ...[
            SizedBox(height: 4.h),
            Text(
              field.errorText!,
              style: StyleText.fontSize12Weight400
                  .copyWith(color: AppColors.red),
            ),
          ],
        ],
      ),
    );
  }

  /// Method Name: [_buildSelectedFileCard]
  ///
  /// Purpose: Renders uploaded-file metadata in the same style as the shared dialog.
  ///
  /// Parameters:
  /// - [context]: Build context used for locale and dialog actions.
  /// - [localization]: Localized labels used by the upload field.
  /// - [field]: Form field state used to clear or replace the file.
  ///
  /// Returns: A file card with icon, metadata, edit, and remove behavior.
  Widget _buildSelectedFileCard(
    BuildContext context,
    S localization,
    FormFieldState<PlatformFile> field,
  ) {
    final selectedFile = file!;
    final extension = selectedFile.name.contains('.')
        ? selectedFile.name.split('.').last
        : '';
    final locale = Localizations.localeOf(context).toLanguageTag();
    final uploadDate = DateFormat('dd MMM yyyy', locale).format(DateTime.now());

    return GestureDetector(
      onTap: () async {
        await _openUploadDialog(context, (selected) {
          field.didChange(selected);
          onChanged(selected);
        });
      },
      child: Container(
        width: 300,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            CustomSvgImage(
              assetPath: getFileIcon(extension),
              width: 40.r,
              height: 40.r,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedFile.name,
                    style: StyleText.fontSize12Weight400,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        _formatBytes(selectedFile.size),
                        style: StyleText.fontSize10Weight400.copyWith(color: AppColors.lightGrey),
                      ),
                      SizedBox(width: 16.w),
                      Text(
                        '${localization.date}: $uploadDate',
                        style: StyleText.fontSize10Weight400.copyWith(color: AppColors.lightGrey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: () {
                field.didChange(null);
                onChanged(null);
              },
              child: Container(
                width: 22.r,
                height: 22.r,
                decoration: BoxDecoration(
                  color: AppColors.red,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.remove,
                  size: 14.r,
                  color: AppColors.card,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Method Name: [_formatBytes]
  ///
  /// Purpose: Converts a file size into the dialog's readable size format.
  ///
  /// Parameters:
  /// - [bytes]: File size in bytes.
  ///
  /// Returns: A formatted byte, kilobyte, or megabyte string.
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Displays a selected document without edit, upload, or remove actions.
class _ReadOnlyDocumentField extends StatelessWidget {
  const _ReadOnlyDocumentField({required this.label, required this.file});

  final String label;
  final PlatformFile? file;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: StyleText.fontSize14Weight500),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Row(
            children: [
              const Icon(Icons.insert_drive_file_outlined),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  file?.name ?? '',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
