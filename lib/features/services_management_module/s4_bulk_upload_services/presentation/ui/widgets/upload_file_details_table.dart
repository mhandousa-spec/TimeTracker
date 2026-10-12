/// Module: services_management_module
/// Description: Editable row/column table for the bulk "upload file
///              details" (master step 1) screen — header row + per-row
///              checkbox/editable-cell rendering. Pure presentation; all
///              callbacks are passed in by the parent page, which owns the
///              row/validation state. Extracted from
///              UploadFileDetailsTabletMaster to bring that file under the
///              800-LOC budget (audit fix #1).
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: flutter_screenutil, CustomExcelTextField, CustomCheckBox
/// Revision History:
///   - Initial version.
///   - Reverted an AR-mode column-swap workaround that was added here by
///     mistake. The real bug was the header order in
///     MasterUploadHeaders.step1ExpectedHeaders (English listed before
///     Arabic in each name/description pair) — fixed at that source
///     instead. This widget just renders expectedHeaders as given, with no
///     reordering logic.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/23-custom_check_box.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/services_management_module/s4_bulk_upload_services/presentation/ui/widgets/custom_excel_text_field.dart';

class UploadFileDetailsTable extends StatelessWidget {
  const UploadFileDetailsTable({
    super.key,
    required this.expectedHeaders,
    required this.formData,
    required this.validationErrors,
    required this.selectedRows,
    required this.focusNodes,
    required this.fieldKeys,
    required this.scrollController,
    required this.isDepartmentDisabled,
    required this.isApproversDisabled,
    required this.onToggleRowSelected,
    required this.onCellValidate,
  });

  final List<String> expectedHeaders;
  final List<Map<String, TextEditingController>> formData;
  final List<Map<String, String>> validationErrors;
  final Set<int> selectedRows;
  final List<Map<String, FocusNode>> focusNodes;
  final List<Map<String, GlobalKey>> fieldKeys;
  final ScrollController scrollController;
  final bool Function(int rowIndex) isDepartmentDisabled;
  final bool Function(int rowIndex) isApproversDisabled;
  final void Function(int rowIndex) onToggleRowSelected;
  final void Function(String key, int rowIndex) onCellValidate;

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;

    return Container(
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(8.r)),
      child: Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: (expectedHeaders.length * 265) + 90,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10.sp, top: 10.sp, right: 10),
                  child: Container(
                    width: 124.sp,
                    height: 25.sp,
                    decoration:
                    BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(4.r)),
                    child: Center(
                      child: Text(
                        "${S.of(context).totalServices}: ${formData.length}",
                        style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.sp),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: SizedBox(
                    height: 400.sp,
                    child: ListView.builder(
                      controller: scrollController,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: formData.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _HeaderRow(headers: expectedHeaders);
                        }

                        final rowIndex = index - 1;
                        final row = formData[rowIndex];
                        final isSelected = selectedRows.contains(rowIndex);

                        return Padding(
                          padding: EdgeInsets.only(top: 10.sp, bottom: 10.sp, right: 12.sp, left: 0.sp),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => onToggleRowSelected(rowIndex),
                                child: _RowCheckbox(isSelected: isSelected, lightMode: lightMode),
                              ),
                              SizedBox(width: 10.sp),
                              ...expectedHeaders.map((header) {
                                bool isDisabled = false;
                                if (header == 'Departments') {
                                  isDisabled = isDepartmentDisabled(rowIndex);
                                } else if (header == 'Approvers') {
                                  isDisabled = isApproversDisabled(rowIndex);
                                }

                                return Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: KeyedSubtree(
                                    key: fieldKeys[rowIndex][header],
                                    child: CustomExcelTextField(
                                      controller: row[header]!,
                                      focusNode: focusNodes[rowIndex][header],
                                      placeholder: isDisabled ? S.of(context).disabled : header,
                                      width: 250,
                                      // height: 36,
                                      showHeader: false,
                                      headerLabel: '',
                                      errorText: validationErrors.length > rowIndex
                                          ? validationErrors[rowIndex][header]
                                          : null,
                                      rowIndex: rowIndex,
                                      isDisabled: isDisabled,
                                      validator: (key, idx) => onCellValidate(key, idx),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.headers});

  final List<String> headers;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 33.sp),
      child: Row(
        children: headers.map((header) {
          final isMixedLang =
              RegExp(r'[a-zA-Z]').hasMatch(header) && RegExp(r'[؀-ۿ]').hasMatch(header);
          final isArabicHeader = RegExp(r'[؀-ۿ]').hasMatch(header);

          String arabicPart = '';
          String englishPart = '';

          if (isMixedLang) {
            arabicPart = header.replaceAll(RegExp(r'[a-zA-Z0-9]'), '').trim();
            englishPart = header.replaceAll(RegExp(r'[^\x00-\x7F]'), '').trim();
          }

          return Container(
            width: 250,
            margin: const EdgeInsets.only(right: 12),
            alignment: isArabicHeader ? Alignment.centerRight : Alignment.centerLeft,
            child: isMixedLang
                ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(arabicPart,
                    textAlign: TextAlign.right,
                    style: StyleText.fontSize16Weight500.copyWith(color: AppColors.text)),
                const SizedBox(width: 6),
                Text(englishPart,
                    textAlign: TextAlign.left,
                    style: StyleText.fontSize16Weight500.copyWith(color: AppColors.text)),
              ],
            )
                : Text(
              header,
              textAlign: isArabicHeader ? TextAlign.right : TextAlign.left,
              style: StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Row selection checkbox.
///
/// ✅ FIX (bug report p14 "use same check box in figma"): this was a local
/// re-implementation that had drifted from the shared component — 24.sp instead
/// of 22.sp, radius 6.r instead of 4.r, an AppColors.grey border instead of
/// secondaryText@50%, and Icons.check instead of Icons.check_rounded. It now
/// delegates to core/custom/23-custom_check_box.dart so the table matches every
/// other checkbox in the app.
class _RowCheckbox extends StatelessWidget {
  const _RowCheckbox({required this.isSelected, required this.lightMode});

  final bool isSelected;
  final bool lightMode;

  @override
  Widget build(BuildContext context) {
    return CustomCheckBox(isSelected: isSelected);
  }
}