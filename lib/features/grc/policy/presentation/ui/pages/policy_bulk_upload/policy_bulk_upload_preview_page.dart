/// Module: GRC Policy Bulk Upload
/// Description: Editable preview table for the bulk upload flow. One row
///              per parsed policy, each field backed by a TextEditingController
///              so the user can fix flagged data before creating anything;
///              row selection drives Remove Selection / Duplication; the
///              footer shows the Total Weight sum for information only —
///              Activate is disabled only while a per-cell validation error
///              exists or the table is empty.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-11
/// Dependencies: flutter_bloc, PolicyBulkUploadCubit, PolicyBulkRowForm

import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/11-custom_confirm_diaolog.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_l10n.dart';
import 'package:knowticed_plus/core/custom/23-custom_check_box.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/pages/policy_bulk_upload/policy_bulk_upload_cubit.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/pages/policy_bulk_upload/policy_bulk_upload_rows.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: policy_bulk_upload_preview_page.dart
/// Purpose: Contains PolicyBulkUploadPreviewPage, the editable table screen
///          the user reviews/fixes/activates from.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 11/7/2026

const List<_ColumnSpec> _columns = [
  _ColumnSpec('policyNumberEn', 'Policy Number', 110),
  _ColumnSpec('policyNumberAr', 'Policy Number Ar', 110),
  _ColumnSpec('policyNameEn', 'Policy Name', 150),
  _ColumnSpec('policyNameAr', 'اسم السياسة', 150),
  _ColumnSpec('policyDescriptionEn', 'Policy Description', 180),
  _ColumnSpec('policyDescriptionAr', 'وصف السياسة', 180),
  _ColumnSpec('startDate', 'Start Date', 110),
  _ColumnSpec('endDate', 'End Date', 110),
  _ColumnSpec('policyWeight', 'Policy Weight', 100),
  _ColumnSpec('policyDocument', 'Policy Document', 160),
];

class _ColumnSpec {
  final String fieldKey;
  final String label;
  final double width;
  const _ColumnSpec(this.fieldKey, this.label, this.width);
}

/// class name: [PolicyBulkUploadPreviewPage]
///
/// purpose: render the bulk upload's editable table (mockup: "Policy Bulk
///          Upload Preview") for a [PolicyBulkUploadCubit] already provided
///          above it in the widget tree.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 11/7/2026
class PolicyBulkUploadPreviewPage extends StatefulWidget {
  final String moduleId;

  /// Name of the uploaded workbook, printed under the breadcrumb the way
  /// the design shows it. Null renders the "no file selected" placeholder.
  final String? fileName;

  /// Middle breadcrumb segment (GRC > Module Name > Policy Bulk Upload
  /// Preview). Optional, so older call sites keep compiling.
  final String? moduleNameEn;
  final String? moduleNameAr;

  /// Owners of the module — the audience for the bulk-upload notification.
  final List<String> moduleOwners;

  const PolicyBulkUploadPreviewPage({
    super.key,
    required this.moduleId,
    this.fileName,
    this.moduleNameEn,
    this.moduleNameAr,
    this.moduleOwners = const <String>[],
  });

  @override
  State<PolicyBulkUploadPreviewPage> createState() =>
      _PolicyBulkUploadPreviewPageState();
}

class _PolicyBulkUploadPreviewPageState
    extends State<PolicyBulkUploadPreviewPage> {
  int _currentErrorIndex = -1;

  void _jumpToError(bool next, PolicyBulkUploadRows rowsData) {
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

  Future<void> _onActivate(PolicyBulkUploadCubit cubit) async {
    final rowsData = cubit.rowsData;
    if (!rowsData.isValid) {
      if (rowsData.errorLocations.isNotEmpty) {
        _jumpToError(true, rowsData);
      } else {
        CustomDialogManager.showMessage(
          context: context,
          lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
          title: S.of(context).unsuccessful,
          subtitle: S.of(context).addAtLeastOneRow,
        );
      }
      return;
    }
    await showConfirmDialog(
      context: context,
      title: S.of(context).activatePolicies,
      subtitle: S.of(context).areYouSureYouWantToActivateThesePolicies,
      confirmLabel: S.of(context).activate,
      cancelLabel: S.of(context).Cancel,
      onConfirm: () => cubit.submit(
        moduleId: widget.moduleId,
        moduleName: widget.moduleNameEn ?? '',
        moduleOwners: widget.moduleOwners,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PolicyBulkUploadCubit>();

    return BlocConsumer<PolicyBulkUploadCubit, PolicyBulkUploadState>(
      listener: (context, state) {
        if (state is PolicyBulkUploadSubmitResult) {
          if (state.succeededCount > 0) {
            showSuccessDialog(
              context: context,
              subtitle:
                  '${state.succeededCount} ${S.of(context).policYIesCreated}',
            );
          }
          if (state.failed.isEmpty) {
            Navigator.pop(context, true);
          }
        }
      },
      builder: (context, state) {
        final submitting = state is PolicyBulkUploadSubmitting;
        final rowsData = cubit.rowsData;
        final activateEnabled = !submitting && rowsData.isValid;

        // The frame owns the Scaffold, SafeArea, breadcrumb and padding.
        final String? moduleName = _moduleName(context);
        return SideFrameMasterServices(
          titleText: S.of(context).grc,
          onFirstTap: () => popFrameRoutes(context, moduleName != null ? 2 : 1),
          secondTitle: moduleName ?? S.of(context).policyBulkUploadPreview,
          onSecondTap:
              moduleName != null ? () => popFrameRoutes(context, 1) : null,
          thirdTitle:
              moduleName != null ? S.of(context).policyBulkUploadPreview : null,
          // The row table is an Expanded over a pinned button row.
          child: SideFrameBoundedBody(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${S.of(context).fileName}: '
                    '${widget.fileName ?? S.of(context).noFileSelected}',
                    style: StyleText.fontSize16Weight500
                        .copyWith(color: AppColors.text),
                  ),
                  SizedBox(height: 15.h),
                  _buildToolbar(context, cubit, rowsData),
                  SizedBox(height: 15.h),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.field,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        '${S.of(context).totalPolicies}: '
                        '${rowsData.rows.length}',
                        style: StyleText.fontSize12Weight500
                            .copyWith(color: AppColors.text),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: _buildTotalWeight(rowsData),
                  ),
                  SizedBox(height: 15.h),
                  Row(
                    children: [
                      customButton(
                        title: S.of(context).discard,
                        function: () => Navigator.pop(context),
                        width: 150.w,
                        height: 38.h,
                        color: AppColors.darkGrey,
                        textStyle: StyleText.fontSize16Weight600
                            .copyWith(color: AppColors.white),
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

  /// The module segment of the breadcrumb in the active language, or null
  /// when the caller did not supply one.
  String? _moduleName(BuildContext context) {
    final name = ContextExtension(context).isArabic
        ? widget.moduleNameAr
        : widget.moduleNameEn;
    return (name == null || name.trim().isEmpty) ? null : name;
  }

  Widget _buildToolbar(
    BuildContext context,
    PolicyBulkUploadCubit cubit,
    PolicyBulkUploadRows rowsData,
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
              CustomDialogManager.showMessage(
                context: context,
                lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
                title: S.of(context).unsuccessful,
                subtitle: S.of(context).selectAtLeastOneRow,
              );
              return;
            }
            cubit.removeSelectedRows();
          },
          width: 150.w,
          height: 30.h,
          color: Colors.black,
          textStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.white),
        ),
        SizedBox(width: 10.w),
        customButton(
          title: S.of(context).duplication,
          function: () {
            if (rowsData.selectedRows.length != 1) {
              CustomDialogManager.showMessage(
                context: context,
                lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
                title: S.of(context).unsuccessful,
                subtitle: S.of(context).selectExactlyOneRowToDuplicate,
              );
              return;
            }
            cubit.duplicateSelectedRow();
          },
          width: 100.w,
          height: 30.h,
          color: Colors.black,
          textStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.white),
        ),
        SizedBox(width: 10.w),
        customButton(
          title: '+ ${S.of(context).row}',
          function: cubit.addRow,
          width: 90.w,
          height: 30.h,
          color: Colors.black,
          textStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.white),
        ),
    ];

    // 375 cannot fit the error stepper and three action buttons on one
    // line, so the phone stacks them; iPad (768) and desktop keep the
    // single row the design draws.
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          errorNav,
          SizedBox(height: 8.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 8.h,
            children: actions
                .where((w) => w is! SizedBox)
                .toList(growable: false),
          ),
        ],
      );
    }

    return Row(children: [errorNav, const Spacer(), ...actions]);
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
                grcTr(context, column.label),
                style: StyleText.fontSize14Weight600.copyWith(color: AppColors.text),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRow(
    PolicyBulkUploadCubit cubit,
    PolicyBulkUploadRows rowsData,
    int index,
  ) {
    final row = rowsData.rows[index];
    final controllers = <String, TextEditingController>{
      'policyNumberEn': row.policyNumberEnController,
      'policyNumberAr': row.policyNumberArController,
      'policyNameEn': row.policyNameEnController,
      'policyNameAr': row.policyNameArController,
      'policyDescriptionEn': row.policyDescriptionEnController,
      'policyDescriptionAr': row.policyDescriptionArController,
      'startDate': row.startDateController,
      'endDate': row.endDateController,
      'policyWeight': row.policyWeightController,
      'policyDocument': row.policyDocumentController,
    };

    return Container(
      key: row.key,
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Material's Checkbox paints its own splash, its own 48x48 tap
          // padding and its own colours, none of which match the rest of the
          // app. CustomCheckBox is the app's box; it is display-only, so the
          // tap lives on the GestureDetector around it. `opaque` keeps the
          // whole 40-wide slot tappable rather than just the 22 box.
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

  Widget _buildTotalWeight(PolicyBulkUploadRows rowsData) {
    final valid = rowsData.totalWeightValid;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            border: Border.all(color: valid ? AppColors.green : AppColors.red),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            '${S.of(context).totalWeight} : ${rowsData.totalWeight.toStringAsFixed(0)}',
            style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
          ),
        ),
        if (!valid) ...[
          SizedBox(height: 4.h),
          Text(
            S.of(context).totalWeightShouldBe100,
            style: StyleText.fontSize12Weight500.copyWith(color: AppColors.red),
          ),
        ],
      ],
    );
  }
}
