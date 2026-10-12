// ****************** FILE INFO ******************
// File Name: crm_export_documents_dialog.dart
// Purpose: Custom Export dialog for documents matching the design specifications.
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> showExportDocumentsDialog({
  required BuildContext context,
  String defaultFileName = '',
  required void Function(String fileName) onSubmit,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext ctx) => _CrmExportDocumentsDialog(
      defaultFileName: defaultFileName,
      onSubmit: onSubmit,
    ),
  );
}

class _CrmExportDocumentsDialog extends StatefulWidget {
  final String defaultFileName;
  final void Function(String fileName) onSubmit;

  const _CrmExportDocumentsDialog({
    required this.defaultFileName,
    required this.onSubmit,
  });

  @override
  State<_CrmExportDocumentsDialog> createState() =>
      _CrmExportDocumentsDialogState();
}

class _CrmExportDocumentsDialogState extends State<_CrmExportDocumentsDialog> {
  late final TextEditingController _fileNameController;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _fileNameController = TextEditingController(text: widget.defaultFileName);
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    setState(() => _submitted = true);
    final String fileName = _fileNameController.text.trim();
    if (fileName.isEmpty) return;
    Navigator.of(context).pop();
    widget.onSubmit(fileName);
  }

  @override
  Widget build(BuildContext context) {
    final String exportTitle = FormatHelper.localizedString(
      englishName: 'Export',
      arabicName: 'تصدير',
    );
    final String fileNameLabel = FormatHelper.localizedString(
      englishName: 'File Name',
      arabicName: 'اسم الملف',
    );
    final String hintText = FormatHelper.localizedString(
      englishName: 'Text here',
      arabicName: 'اكتب هنا',
    );
    final String discardLabel = FormatHelper.localizedString(
      englishName: 'Discard',
      arabicName: 'إلغاء',
    );
    final String submitLabel = FormatHelper.localizedString(
      englishName: 'Submit',
      arabicName: 'حفظ',
    );

    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Container(
        width: 430.w,
        padding: EdgeInsets.all(20.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 1. Header: Yellow Circle with Export Icon + Title
            Row(
              children: <Widget>[
                Container(
                  width: 36.sp,
                  height: 36.sp,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: CustomSvgImage(
                      assetPath: AppAssets.export,
                      width: 18.sp,
                      height: 18.sp,
                      color: AppColors.black,
                    ),
                  ),
                ),
                SizedBox(width: 10.sp),
                Text(
                  exportTitle,
                  style: StyleText.fontSize16Weight600.copyWith(
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
            SizedBox(height: 18.sp),

            // 2. Field Label
            Text(
              fileNameLabel,
              style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 6.sp),

            // 3. File Name Input
            CustomTextField(
              hint: hintText,
              controller: _fileNameController,
              required: _submitted,
              onChanged: (_) => setState(() {}),
            ),
            SizedBox(height: 24.sp),

            // 4. Bottom Action Buttons: Discard | Submit
            Row(
              children: <Widget>[
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      height: 38.sp,
                      decoration: BoxDecoration(
                        color: AppColors.greyDark,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        discardLabel,
                        style: StyleText.fontSize14Weight500.copyWith(
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.sp),
                Expanded(
                  child: InkWell(
                    onTap: _handleSubmit,
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      height: 38.sp,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        submitLabel,
                        style: StyleText.fontSize14Weight600.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
