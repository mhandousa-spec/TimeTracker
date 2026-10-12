/// Module: services_management_module
/// Description: Scrollable preview table (header row + editable data rows)
///              for the bulk-upload request-preview screen.
/// Author: Knowticed Team
/// Date: 02/07/2026
/// Dependencies: RequestEditableCell, AppColors, StyleText
/// Revision History:
///   - 02/07/2026 (Knowticed Team): Extracted from upload_details.dart
///     (fix item 5 — page LOC reduction).
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/23-custom_check_box.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/services_management_module/s3_create_master_services/presentation/ui/widgets/request_editable_cell.dart';

class UploadDetailsPreviewTable extends StatelessWidget {
  final List<String> expectedHeaders;
  final List<Map<String, TextEditingController>> formData;
  final List<Map<String, String>> validationErrors;
  final List<Map<String, GlobalKey>> fieldKeys;
  final List<Map<String, FocusNode>> focusNodes;
  final Set<int> selectedRows;
  final ScrollController scrollController;
  final ScrollController horizontalScrollController;
  final bool lightMode;
  final ValueChanged<int> onToggleRowSelected;
  final void Function(int rowIndex, String header) onCellChanged;

  const UploadDetailsPreviewTable({
    super.key,
    required this.expectedHeaders,
    required this.formData,
    required this.validationErrors,
    required this.fieldKeys,
    required this.focusNodes,
    required this.selectedRows,
    required this.scrollController,
    required this.horizontalScrollController,
    required this.lightMode,
    required this.onToggleRowSelected,
    required this.onCellChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (formData.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: horizontalScrollController,
          child: SizedBox(
            // ✅ FIX (bug report p14): the width was hardcoded to 1400.w, which
            // caps the horizontal scroll extent. Once the columns needed more
            // than that the right-hand ones were clipped and unreachable —
            // "it must be scrollable right and left".
            //
            // Derive it from the column count instead, matching the row layout
            // below (220 cell + 40 + 12 spacing) plus the leading checkbox
            // column, exactly as the bulk-upload table already does.
            width: (expectedHeaders.length * (220 + 40 + 12)) + 90,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10.sp, top: 10.sp, right: 10),
                  child: Container(
                    width: 160.sp,
                    height: 25.sp,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Center(
                      child: Text(
                        'Total Requests: ${formData.length}',
                        style: StyleText.fontSize14Weight500
                            .copyWith(color: AppColors.text),
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
                          return _buildHeaderRow();
                        }
                        final rowIndex = index - 1;
                        return _buildDataRow(context, rowIndex);
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

  Widget _buildHeaderRow() {
    return Padding(
      padding: EdgeInsets.only(left: 34.sp, top: 8.sp, bottom: 8.sp),
      child: Row(
        children: expectedHeaders.map((header) {
          return SizedBox(
            width: 220 + 40 + 12,
            child: Text(
              header,
              style: StyleText.fontSize16Weight500
                  .copyWith(color: AppColors.text),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDataRow(BuildContext context, int rowIndex) {
    final row = formData[rowIndex];
    final isSelected = selectedRows.contains(rowIndex);

    return Padding(
      padding:
          EdgeInsets.only(top: 10.sp, bottom: 10.sp, right: 12.sp, left: 0.sp),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => onToggleRowSelected(rowIndex),
            // ✅ FIX (bug report p14 "use same check box in figma"): was an
            // inline copy that had drifted from the shared component — 24.sp
            // instead of 22.sp, radius 6.r instead of 4.r, AppColors.grey
            // border instead of secondaryText@50%, and a 16.sp Icons.check
            // instead of Icons.check_rounded.
            child: CustomCheckBox(isSelected: isSelected),
          ),
          SizedBox(width: 10.sp),
          ...expectedHeaders.map((header) {
            final hasError = (validationErrors.length > rowIndex) &&
                validationErrors[rowIndex].containsKey(header);
            final errorText = hasError ? validationErrors[rowIndex][header] : null;

            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: KeyedSubtree(
                key: fieldKeys[rowIndex][header],
                child: RequestEditableCell(
                  controller: row[header]!,
                  focusNode: focusNodes[rowIndex][header]!,
                  placeholder: header,
                  errorText: errorText,
                  width: 220,
                  height: 36,
                  onChanged: () => onCellChanged(rowIndex, header),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
