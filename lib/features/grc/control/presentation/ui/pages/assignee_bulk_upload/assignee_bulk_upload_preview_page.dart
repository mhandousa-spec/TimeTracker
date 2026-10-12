/// Module: GRC Assignee Bulk Upload (shared by Control Owner + Control Champion)
/// Description: Editable preview table for the bulk upload flow. One row per
///              parsed assignment (Email / Policy Name / Control Name(s)),
///              each field backed by a TextEditingController so the user can
///              fix flagged data before creating anything; row selection
///              drives Remove Selection / Duplication. Activate is disabled
///              only while a per-cell validation error exists or the table
///              is empty. Mirrors policy_bulk_upload_preview_page.dart minus
///              the Total Weight footer (not applicable here).
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-26
/// Dependencies: flutter_bloc, AssigneeBulkUploadCubit, AssigneeBulkRowForm

import 'package:knowticed_plus/core/custom/11-custom_confirm_diaolog.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/23-custom_check_box.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/control/presentation/ui/pages/assignee_bulk_upload/assignee_bulk_upload_cubit.dart';
import 'package:knowticed_plus/features/grc/control/presentation/ui/pages/assignee_bulk_upload/assignee_bulk_upload_rows.dart';
import 'package:knowticed_plus/features/grc/control/presentation/ui/pages/assignee_bulk_upload/assignee_excel_parser.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_l10n.dart';

class _ColumnSpec {
  final String fieldKey;
  final String label;
  final double width;
  const _ColumnSpec(this.fieldKey, this.label, this.width);
}

/// `email`/`policyName` labels reuse [assigneeBulkUploadExpectedHeaders]
/// (declared once in assignee_excel_parser.dart) by index instead of
/// restating those header strings here; `controlNames` appends a UI hint
/// to that same shared header rather than duplicating it outright.
final List<_ColumnSpec> _columns = [
  _ColumnSpec('email', assigneeBulkUploadExpectedHeaders[0], 220),
  _ColumnSpec('policyName', assigneeBulkUploadExpectedHeaders[1], 220),
  _ColumnSpec(
    'controlNames',
    '${assigneeBulkUploadExpectedHeaders[2]} (comma-separated)',
    320,
  ),
];

/// class name: [AssigneeBulkUploadPreviewPage]
///
/// purpose: render the bulk upload's editable table for an
///          [AssigneeBulkUploadCubit] already provided above it in the
///          widget tree.
class AssigneeBulkUploadPreviewPage extends StatefulWidget {
  final String moduleId;
  final String assigneeLabel;

  const AssigneeBulkUploadPreviewPage({
    super.key,
    required this.moduleId,
    required this.assigneeLabel,
  });

  @override
  State<AssigneeBulkUploadPreviewPage> createState() =>
      _AssigneeBulkUploadPreviewPageState();
}

class _AssigneeBulkUploadPreviewPageState
    extends State<AssigneeBulkUploadPreviewPage> {
  int _currentErrorIndex = -1;

  void _jumpToError(bool next, AssigneeBulkUploadRows rowsData) {
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

  Future<void> _onActivate(AssigneeBulkUploadCubit cubit) async {
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
    await showConfirmDialog(
      context: context,
      title: '${S.of(context).activate} ${widget.assigneeLabel}s',
      subtitle:
          S.of(context).areYouSureYouWantToActivateTheseAssignments,
      confirmLabel: S.of(context).activate,
      cancelLabel: S.of(context).Cancel,
      onConfirm: () => cubit.submit(moduleId: widget.moduleId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AssigneeBulkUploadCubit>();

    return BlocConsumer<AssigneeBulkUploadCubit, AssigneeBulkUploadState>(
      listener: (context, state) {
        if (state is AssigneeBulkUploadSubmitResult) {
          if (state.succeededCount > 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  S.of(context).assigneesCreated,
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
        final submitting = state is AssigneeBulkUploadSubmitting;
        final rowsData = cubit.rowsData;
        final activateEnabled = !submitting && rowsData.isValid;

        // The frame owns the Scaffold, SafeArea, breadcrumb and side
        // padding. Two crumbs: the first pops one route, the last gets none.
        return SideFrameMasterServices(
          titleText: S.of(context).grc,
          onFirstTap: () => popFrameRoutes(context, 1),
          secondTitle:
              '${widget.assigneeLabel} ${S.of(context).bulkUploadPreview}',
          // Toolbar over an Expanded grid over a pinned button row.
          child: SideFrameBoundedBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildToolbar(context, cubit, rowsData),
                SizedBox(height: 15.h),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeaderRow(),
                          for (var i = 0; i < rowsData.rows.length; i++)
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
                      color: activateEnabled
                          ? AppColors.primary
                          : AppColors.secondaryText,
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
    AssigneeBulkUploadCubit cubit,
    AssigneeBulkUploadRows rowsData,
  ) {
    final errorCount = rowsData.errorCount;
    return Row(
      children: [
        Container(
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
        ),
        const Spacer(),
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
      ],
    );
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
              child: Text(grcTr(context, column.label),
                style: StyleText.fontSize14Weight600.copyWith(color: AppColors.text),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRow(
    AssigneeBulkUploadCubit cubit,
    AssigneeBulkUploadRows rowsData,
    int index,
  ) {
    final row = rowsData.rows[index];
    final controllers = <String, TextEditingController>{
      'email': row.emailController,
      'policyName': row.policyNameController,
      'controlNames': row.controlNamesController,
    };

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
            ),
        ],
      ),
    );
  }

  Widget _buildCell({
    required double width,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String? error,
    required VoidCallback onChanged,
  }) {
    final borderColor = error != null ? AppColors.red : Colors.transparent;
    return SizedBox(
      width: width,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: (_) => onChanged(),
          style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: AppColors.card,
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
}
