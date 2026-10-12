// lib/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_preview_page.dart
/// Module: GRC Control Bulk Upload
/// Description: Editable preview table for the Control bulk upload flow.
///              Mirrors policy_bulk_upload_preview_page.dart's toolbar/
///              error-nav/per-cell structure; adds a per-row (not
///              page-footer) Applied Departments Total Weight box, shown
///              only once that row's Applied Departments cell itself has
///              no error (a bad sum still shows the box, in red, per the
///              'departmentWeight' error key — see ControlBulkRowForm).
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: flutter_bloc, ControlBulkUploadCubit, ControlBulkRowForm

import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/23-custom_check_box.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_row_form.dart';
import 'package:knowticed_plus/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_cubit.dart';
import 'package:knowticed_plus/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_rows.dart';
import 'package:knowticed_plus/features/grc/control/presentation/ui/pages/control_bulk_upload/control_excel_parser.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Column labels reuse [controlBulkUploadExpectedHeaders] (declared once in
/// control_excel_parser.dart) by index — same order as that list — instead
/// of restating the 14 bilingual header strings here.
final List<_ColumnSpec> _columns = [
  _ColumnSpec('controlNameEn', controlBulkUploadExpectedHeaders[0], 150),
  _ColumnSpec('controlNameAr', controlBulkUploadExpectedHeaders[1], 150),
  _ColumnSpec('controlNumberEn', controlBulkUploadExpectedHeaders[2], 110),
  _ColumnSpec('controlNumberAr', controlBulkUploadExpectedHeaders[3], 110),
  _ColumnSpec('controlDescriptionEn', controlBulkUploadExpectedHeaders[4], 180),
  _ColumnSpec('controlDescriptionAr', controlBulkUploadExpectedHeaders[5], 180),
  _ColumnSpec('startDate', controlBulkUploadExpectedHeaders[6], 110),
  _ColumnSpec('endDate', controlBulkUploadExpectedHeaders[7], 110),
  _ColumnSpec('controlWeight', controlBulkUploadExpectedHeaders[8], 100),
  _ColumnSpec('frequency', controlBulkUploadExpectedHeaders[9], 110),
  _ColumnSpec('controlChampion', controlBulkUploadExpectedHeaders[10], 180),
  _ColumnSpec('controlOwner', controlBulkUploadExpectedHeaders[11], 180),
  _ColumnSpec('appliedDepartments', controlBulkUploadExpectedHeaders[12], 200),
  _ColumnSpec('departmentWeight', controlBulkUploadExpectedHeaders[13], 150),
];

class _ColumnSpec {
  final String fieldKey;
  final String label;
  final double width;
  const _ColumnSpec(this.fieldKey, this.label, this.width);
}

class ControlBulkUploadPreviewPage extends StatefulWidget {
  final String moduleId;
  final String policyId;

  /// Middle breadcrumb segment, forwarded from ControlBulkUploadPage so the
  /// crumb here reads "GRC > Module Name > Control Bulk Upload Preview",
  /// matching Figma. Null/empty falls back to the two-segment crumb.
  final String? moduleNameEn;
  final String? moduleNameAr;

  const ControlBulkUploadPreviewPage({
    super.key,
    required this.moduleId,
    required this.policyId,
    this.moduleNameEn,
    this.moduleNameAr,
  });

  @override
  State<ControlBulkUploadPreviewPage> createState() =>
      _ControlBulkUploadPreviewPageState();
}

class _ControlBulkUploadPreviewPageState
    extends State<ControlBulkUploadPreviewPage> {
  int _currentErrorIndex = -1;

  void _jumpToError(bool next, ControlBulkUploadRows rowsData) {
    final locations = rowsData.errorLocations;
    if (locations.isEmpty) return;

    setState(() {
      _currentErrorIndex = next
          ? (_currentErrorIndex + 1) % locations.length
          : (_currentErrorIndex - 1 + locations.length) % locations.length;
    });

    final (rowIndex, fieldKey) = locations[_currentErrorIndex];
    final row = rowsData.rows[rowIndex];
    final rowContext = row.key.currentContext;
    if (rowContext != null) {
      Scrollable.ensureVisible(
        rowContext,
        alignment: 0.5,
        duration: const Duration(milliseconds: 300),
      );
    }
    row.focusNodes[fieldKey]?.requestFocus();
  }

  Future<void> _onActivate(ControlBulkUploadCubit cubit) async {
    final rowsData = cubit.rowsData;
    if (!rowsData.isValid) {
      if (rowsData.errorLocations.isNotEmpty) {
        _jumpToError(true, rowsData);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).addAtLeastOneRow)),
        );
      }
      return;
    }
    await cubit.submit(moduleId: widget.moduleId, policyId: widget.policyId);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ControlBulkUploadCubit>();

    return BlocConsumer<ControlBulkUploadCubit, ControlBulkUploadState>(
      listener: (context, state) {
        if (state is ControlBulkUploadSubmitResult) {
          if (state.succeededCount > 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${state.succeededCount} ${S.of(context).controlSCreated}',
                ),
              ),
            );
          }
          if (state.failed.isEmpty) {
            Navigator.pop(context, true);
          }
        }
      },
      builder: (context, state) {
        final submitting = state is ControlBulkUploadSubmitting;
        final rowsData = cubit.rowsData;
        final activateEnabled = !submitting && rowsData.isValid;

        final String? moduleName = _moduleName(context);
        // The frame owns the Scaffold, SafeArea, breadcrumb and side
        // padding. The middle crumb is optional, so the first crumb's pop
        // count follows it.
        return SideFrameMasterServices(
          titleText: S.of(context).grc,
          onFirstTap: () =>
              popFrameRoutes(context, moduleName != null ? 2 : 1),
          secondTitle: moduleName ?? S.of(context).controlBulkUploadPreview,
          onSecondTap:
              moduleName != null ? () => popFrameRoutes(context, 1) : null,
          thirdTitle:
              moduleName != null ? S.of(context).controlBulkUploadPreview : null,
          // Toolbar over an Expanded grid/card list over a pinned button row.
          child: SideFrameBoundedBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildToolbar(context, cubit, rowsData),
                SizedBox(height: 15.h),
                Expanded(
                  // Figma has no 375 frame for bulk upload, and a
                  // fourteen-column editable grid is unusable at that
                  // width -- so the phone gets one stacked card per row
                  // (label above field, same TextFields, same error
                  // borders and same per-row Total Weight box). iPad (768)
                  // and desktop (1024) keep the grid the design draws and
                  // scroll it sideways.
                  child: screenSizeOf(context) == ScreenSize.mobile
                      ? SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (var i = 0;
                                  i < rowsData.rows.length;
                                  i++) ...[
                                if (i != 0) SizedBox(height: 12.h),
                                _buildRowCard(cubit, rowsData, i),
                              ],
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHeaderRow(),
                                for (var i = 0;
                                    i < rowsData.rows.length;
                                    i++)
                                  _buildRow(cubit, rowsData, i),
                              ],
                            ),
                          ),
                        ),
                ),
                SizedBox(height: 15.h),
                Row(
                  children: [
                    customButton(
                      title: S.of(context).discard,
                      function: () => Navigator.pop(context),
                      width: 150.w,
                      height: 38.h,
                      color: AppColors.secondaryText,
                      textStyle: StyleText.fontSize16Weight600
                          .copyWith(color: AppColors.text),
                    ),
                    const Spacer(),
                    customButton(
                      title: S.of(context).activate,
                      function: submitting ? () {} : () => _onActivate(cubit),
                      width: 150.w,
                      height: 38.h,
                      color: activateEnabled ? AppColors.primary : AppColors.secondaryText,
                      textStyle: StyleText.fontSize16Weight600
                          .copyWith(color: AppColors.textButton),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildToolbar(
    BuildContext context,
    ControlBulkUploadCubit cubit,
    ControlBulkUploadRows rowsData,
  ) {
    final errorCount = rowsData.errorCount;
    final bool isMobile = screenSizeOf(context) == ScreenSize.mobile;

    final Widget errorNav = Container(
          height: 30.h,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                iconSize: 16.sp,
                onPressed: () => _jumpToError(false, rowsData),
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                '${S.of(context).error}: '
                '${errorCount > 0 ? '${_currentErrorIndex + 1}/$errorCount' : '0'}',
                style: StyleText.fontSize14Weight500.copyWith(
                  color: errorCount > 0 ? AppColors.red : AppColors.text,
                ),
              ),
              IconButton(
                iconSize: 16.sp,
                onPressed: () => _jumpToError(true, rowsData),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        );

    final List<Widget> actions = [
        customButton(
          title: S.of(context).removeSelection,
          function: () {
            if (rowsData.selectedRows.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(S.of(context).selectAtLeastOneRow)),
              );
              return;
            }
            cubit.removeSelectedRows();
          },
          width: 150.w,
          height: 30.h,
          color: AppColors.black,
          textStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.white),
        ),
        SizedBox(width: 10.w),
        customButton(
          title: S.of(context).duplication,
          function: () {
            if (rowsData.selectedRows.length != 1) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(S.of(context).selectExactlyOneRowToDuplicate)),
              );
              return;
            }
            cubit.duplicateSelectedRow();
          },
          width: 100.w,
          height: 30.h,
          color: AppColors.black,
          textStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.white),
        ),
        SizedBox(width: 10.w),
        customButton(
          title: '+ ${S.of(context).row}',
          function: cubit.addRow,
          width: 90.w,
          height: 30.h,
          color: AppColors.black,
          textStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.white),
        ),
    ];

    // 375 cannot fit the error stepper plus three action buttons on one
    // line, so the phone stacks them and lets the buttons wrap. Same shape
    // PolicyBulkUploadPreviewPage uses.
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          errorNav,
          SizedBox(height: 8.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 8.h,
            children:
                actions.where((w) => w is! SizedBox).toList(growable: false),
          ),
        ],
      );
    }

    return Row(children: [errorNav, const Spacer(), ...actions]);
  }

  /// The module name for the middle crumb, or null when none was passed.
  String? _moduleName(BuildContext context) {
    final name = ContextExtension(context).isArabic
        ? widget.moduleNameAr
        : widget.moduleNameEn;
    return (name == null || name.trim().isEmpty) ? null : name;
  }

  Widget _buildHeaderRow() {
    return Row(
      children: [
        SizedBox(width: 40.w),
        for (final column in _columns)
          SizedBox(
            width: column.width.w,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                column.label,
                style: StyleText.fontSize14Weight600.copyWith(color: AppColors.text),
              ),
            ),
          ),
        SizedBox(width: 140.w),
      ],
    );
  }

  Widget _buildRow(
    ControlBulkUploadCubit cubit,
    ControlBulkUploadRows rowsData,
    int index,
  ) {
    final row = rowsData.rows[index];
    final controllers = _controllersFor(row);

    return Container(
      key: row.key,
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The app's checkbox, not Material's -- see the policy bulk upload
          // preview page. CustomCheckBox is display-only, so the tap lives on
          // the GestureDetector, and `opaque` keeps the whole 40-wide slot
          // tappable rather than just the 22 box.
          SizedBox(
            width: 40.w,
            child: Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => cubit.toggleRowSelected(index),
                child: CustomCheckBox(
                  isSelected: rowsData.selectedRows.contains(index),
                ),
              ),
            ),
          ),
          for (final column in _columns)
            _buildCell(
              width: column.width.w,
              controller: controllers[column.fieldKey]!,
              focusNode: row.focusNodes[column.fieldKey]!,
              error: row.errors[column.fieldKey],
              onChanged: () => cubit.revalidateRow(index),
              // Equal-weights mode auto-computes this column (100 / department
              // count, recomputed on every Applied Departments edit — see
              // ControlBulkRowForm._validateDepartments) — it isn't user input.
              readOnly: column.fieldKey == 'departmentWeight' && cubit.equalWeights,
            ),
          _buildRowTotalWeight(row),
        ],
      ),
    );
  }

  /// [width] null means "fill the parent" -- the phone card stacks these
  /// full width instead of pinning each to its grid column width.
  /// One field key -> controller map per row, shared by the 768 / 1024 grid
  /// row and the 375 card so the two layouts can never drift apart.
  Map<String, TextEditingController> _controllersFor(ControlBulkRowForm row) {
    return <String, TextEditingController>{
      'controlNameEn': row.controlNameEnController,
      'controlNameAr': row.controlNameArController,
      'controlNumberEn': row.controlNumberEnController,
      'controlNumberAr': row.controlNumberArController,
      'controlDescriptionEn': row.controlDescriptionEnController,
      'controlDescriptionAr': row.controlDescriptionArController,
      'startDate': row.startDateController,
      'endDate': row.endDateController,
      'controlWeight': row.controlWeightController,
      'frequency': row.frequencyController,
      'controlChampion': row.controlChampionController,
      'controlOwner': row.controlOwnerController,
      'appliedDepartments': row.appliedDepartmentsController,
      'departmentWeight': row.departmentWeightController,
    };
  }

  // ------------------------------------------------------------------
  // PHONE (375): one stacked card per row instead of a grid row
  // ------------------------------------------------------------------

  /// Same row, same controllers, same focus nodes and the same `row.key` the
  /// error stepper scrolls to -- only the arrangement differs, so
  /// `_jumpToError` keeps working unchanged on a phone.
  Widget _buildRowCard(
    ControlBulkUploadCubit cubit,
    ControlBulkUploadRows rowsData,
    int index,
  ) {
    final row = rowsData.rows[index];
    final controllers = _controllersFor(row);
    final bool selected = rowsData.selectedRows.contains(index);

    return Container(
      key: row.key,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: selected
              ? AppColors.primary
              : AppColors.secondaryText.withOpacity(.15),
        ),
      ),
      // stretch: the stacked TextFields and the Total Weight box fill the
      // card width; a start-aligned Column would let them shrink-wrap.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => cubit.toggleRowSelected(index),
            child: Row(
              children: [
                CustomCheckBox(isSelected: selected),
                SizedBox(width: 8.w),
                Text(
                  '${S.of(context).row} ${index + 1}',
                  style: StyleText.fontSize14Weight600
                      .copyWith(color: AppColors.text),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          for (final column in _columns) ...[
            Text(
              column.label,
              style: StyleText.fontSize12Weight400
                  .copyWith(color: AppColors.secondaryText),
            ),
            SizedBox(height: 4.h),
            _buildCell(
              width: null,
              controller: controllers[column.fieldKey]!,
              focusNode: row.focusNodes[column.fieldKey]!,
              error: row.errors[column.fieldKey],
              onChanged: () => cubit.revalidateRow(index),
              readOnly:
                  column.fieldKey == 'departmentWeight' && cubit.equalWeights,
            ),
            SizedBox(height: 10.h),
          ],
          _buildRowTotalWeight(row, fullWidth: true),
        ],
      ),
    );
  }

  Widget _buildCell({
    required double? width,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String? error,
    required VoidCallback onChanged,
    bool readOnly = false,
  }) {
    final borderColor = error != null ? AppColors.red : Colors.transparent;
    return SizedBox(
      width: width,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          readOnly: readOnly,
          onChanged: (_) => onChanged(),
          style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: readOnly ? AppColors.background : AppColors.card,
            contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            suffixIcon: error != null
                ? Tooltip(
                    message: error,
                    child: Icon(Icons.error, color: AppColors.red, size: 16.sp),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ),
    );
  }

  /// Renders the per-row Applied-Departments Total Weight box: hidden when
  /// the row has no departments at all ([ControlBulkRowForm.departmentNames]
  /// empty — either genuinely empty or the names/count themselves errored,
  /// in which case the red-bordered Applied Departments cell above already
  /// communicates the problem); green when the pair is fully valid; red
  /// (with a "should be 100" message) when the names/count are fine but the
  /// weights don't sum to 100 (['departmentWeight'] error present).
  Widget _buildRowTotalWeight(ControlBulkRowForm row,
      {bool fullWidth = false}) {
    if (row.departmentNames.isEmpty) {
      return fullWidth ? const SizedBox.shrink() : SizedBox(width: 140.w);
    }

    final total = row.departmentWeights.fold<double>(0, (sum, w) => sum + w);
    final valid = !row.errors.containsKey('departmentWeight');

    return SizedBox(
      width: fullWidth ? double.infinity : 140.w,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                border: Border.all(color: valid ? AppColors.green : AppColors.red),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                '${S.of(context).totalWeight} : ${total.toStringAsFixed(0)}',
                style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text),
              ),
            ),
            if (!valid)
              Padding(
                padding: EdgeInsets.only(top: 2.h),
                child: Text(
                  S.of(context).totalWeightShouldBe100,
                  style: StyleText.fontSize10Weight500.copyWith(color: AppColors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
