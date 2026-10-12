/// Module: roles / r2_user_management / presentation / ui / pages / bulk_access_upload
///
///*************************** FILE INFO ****************************///
/// File Name: access_bulk_upload_preview_page.dart
/// Purpose: "Bulk Upload" step 2 — review, fix and activate the imported rows
///          (Figma 4717:36048).
/// Author: Knowticed Plus team
/// Created At: 21/9/2026 — bug report p.1. Toolbar, grid and pinned button
///          row follow the GRC assignee preview
///          (`assignee_bulk_upload_preview_page.dart`).
///
/// Cells:
///  * Employee ID / Email — text; either identifies the employee.
///  * Current Role Type — read-only, from the live access roster.
///  * Desired Role Type — the role dropdown, active roles only.
///  * Access Granted / Access Revoked — the shared calendar field.
///  * Status — read-only: Scheduled when access starts after today, else Active.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/23-custom_check_box.dart';
import 'package:knowticed_plus/core/custom/3-custom_dropdown_calander.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/models/role_model.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/domain/enums/user_access_status.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/ui/pages/bulk_access_upload/access_bulk_upload_cubit.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/ui/pages/bulk_access_upload/access_bulk_upload_rows.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/ui/pages/user_management_home.dart'
    show UserAccessStatusColor;
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/ui/widgets/user_access_status_label.dart';
import 'package:knowticed_plus/features/settings/se1_profile/data/utils/localized_digits.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Unscaled cell height, shared by every cell so the row reads as one line.
const double _kCellHeight = 36;

class AccessBulkUploadPreviewPage extends StatefulWidget {
  const AccessBulkUploadPreviewPage({super.key});

  @override
  State<AccessBulkUploadPreviewPage> createState() =>
      _AccessBulkUploadPreviewPageState();
}

class _AccessBulkUploadPreviewPageState
    extends State<AccessBulkUploadPreviewPage> {
  int _currentErrorIndex = -1;

  bool get _ar => context.isArabic;
  String _tr(String en, String ar) => _ar ? ar : en;

  // ── Column set (Figma order) ────────────────────────────────────────────
  List<(String, double)> get _columns => <(String, double)>[
        (S.of(context).employeeId, 170),
        (S.of(context).email, 230),
        (_tr('Current Role Type', 'نوع الدور الحالي'), 190),
        (_tr('Desired Role Type', 'نوع الدور المطلوب'), 210),
        (S.of(context).access_granted, 170),
        (S.of(context).access_revoked, 170),
        (S.of(context).status, 120),
      ];

  String _errorText(AccessBulkError error) => switch (error) {
        AccessBulkError.identityRequired =>
          _tr('Employee ID or Email is required', 'رقم الموظف أو البريد مطلوب'),
        AccessBulkError.employeeNotFound =>
          _tr('No employee with this ID', 'لا يوجد موظف بهذا الرقم'),
        AccessBulkError.emailNotFound =>
          _tr('No employee with this email', 'لا يوجد موظف بهذا البريد'),
        AccessBulkError.emailDoesNotMatchId =>
          _tr('Email belongs to another employee', 'البريد يخص موظفًا آخر'),
        AccessBulkError.ownAccess =>
          _tr('You cannot change your own access', 'لا يمكنك تعديل صلاحيتك'),
        AccessBulkError.duplicateEmployee =>
          _tr('Employee appears in more than one row', 'الموظف مكرر في أكثر من صف'),
        AccessBulkError.roleRequired =>
          _tr('Role is required', 'الدور مطلوب'),
        AccessBulkError.roleNotFound =>
          _tr('Role not found or not active', 'الدور غير موجود أو غير نشط'),
        AccessBulkError.dateRequired =>
          _tr('Date is required', 'التاريخ مطلوب'),
        AccessBulkError.dateInvalid =>
          _tr('Unreadable date', 'تاريخ غير صالح'),
        AccessBulkError.datePast =>
          _tr('Cannot start in the past', 'لا يمكن أن يبدأ في الماضي'),
        AccessBulkError.revokedBeforeGranted =>
          _tr('Must be after Access Granted', 'يجب أن يكون بعد تاريخ المنح'),
      };

  /// Figma's "23-04-2024". Formatted in 'en' (no locale data needed) and then
  /// given Arabic-Indic digits in Arabic, as the rest of the roles screens do.
  String _formatDate(DateTime date) => LocalizedDigits.apply(
      DateFormat('dd-MM-yyyy', 'en').format(date), _ar ? 'ar' : 'en');

  // ── Error navigation ─────────────────────────────────────────────────────
  void _jumpToError(bool next, AccessBulkUploadRows rowsData) {
    final List<(int, AccessBulkField)> locations = rowsData.errorLocations;
    if (locations.isEmpty) return;

    setState(() {
      _currentErrorIndex = next
          ? (_currentErrorIndex + 1) % locations.length
          : (_currentErrorIndex - 1 + locations.length) % locations.length;
    });

    final (int rowIndex, AccessBulkField field) = locations[_currentErrorIndex];
    final AccessBulkRowForm row = rowsData.rows[rowIndex];
    final BuildContext? rowContext = row.key.currentContext;
    if (rowContext != null) {
      Scrollable.ensureVisible(rowContext,
          alignment: 0.5, duration: const Duration(milliseconds: 300));
    }
    row.focusNodes[field]?.requestFocus();
  }

  // ── Activate ─────────────────────────────────────────────────────────────
  Future<void> _onActivate(AccessBulkUploadCubit cubit) async {
    final AccessBulkUploadRows rowsData = cubit.rowsData;
    if (!rowsData.isValid) {
      if (rowsData.errorLocations.isNotEmpty) {
        await CustomDialogManager.showSuccess(
          context: context,
          lottiePath: 'assets/lottie_assets/main_lottie_assets/lottie_rejected.json',
          title: S.of(context).mustCorrectErrors,
        );
        if (mounted) _jumpToError(true, rowsData);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).addAtLeastOneRow)));
      }
      return;
    }

    final NavigatorState navigator = Navigator.of(context);
    List<String> failures = const <String>[];

    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie: 'assets/lottie_assets/roles_lottie_assets/Edit Document.json',
      confirmTitle: _tr('Activating Access', 'تفعيل الصلاحيات'),
      confirmSubtitle: _tr('Are You Sure You Want To Activate These Access?',
          'هل أنت متأكد أنك تريد تفعيل هذه الصلاحيات؟'),
      confirmNoText: S.of(context).no,
      confirmYesText: S.of(context).yes,
      onConfirm: () async {
        await cubit.activate();
        final AccessBulkUploadState state = cubit.state;
        if (state is AccessBulkUploadResult) failures = state.failures;
        // Only an all-rows success earns the success dialog; partial results
        // are reported below with the rows that failed still in the table.
        return failures.isEmpty;
      },
      successLottie: 'assets/lottie_assets/main_lottie_assets/check.json',
      successTitle: S.of(context).activated,
      successSubtitle: _tr('You Successfully Activated These Access',
          'تم تفعيل هذه الصلاحيات بنجاح'),
      onSuccessComplete: () {
        if (navigator.mounted) navigator.pop(true);
      },
    );

    if (!mounted || failures.isEmpty) return;
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(
          _tr('Some rows were not saved', 'لم يتم حفظ بعض الصفوف'),
          style: StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
        ),
        content: SingleChildScrollView(
          child: Text(
            failures.join('\n'),
            style: StyleText.fontSize14Weight400.copyWith(color: AppColors.red),
          ),
        ),
        actions: <Widget>[
          customButton(
            title: S.of(context).ok,
            function: () => Navigator.pop(dialogContext),
            color: AppColors.primary,
            textStyle: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.textButton),
          ),
        ],
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final AccessBulkUploadCubit cubit = context.read<AccessBulkUploadCubit>();

    return BlocBuilder<AccessBulkUploadCubit, AccessBulkUploadState>(
      builder: (BuildContext context, AccessBulkUploadState state) {
        final bool submitting = state is AccessBulkUploadSubmitting;
        final AccessBulkUploadRows rowsData = cubit.rowsData;

        return SideFrameMasterServices(
          titleText: S.of(context).platformControlsAndManagement,
          onFirstTap: () => popFrameRoutes(context, 2),
          secondTitle: S.of(context).bulkUpload,
          onSecondTap: () => popFrameRoutes(context, 1),
          child: SideFrameBoundedBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildToolbar(cubit, rowsData),
                SizedBox(height: 15.sp),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10.sp),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: submitting
                        ? const Center(child: CircleProgressMaster())
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _totalChip(rowsData),
                                  SizedBox(height: 10.sp),
                                  _buildHeaderRow(),
                                  for (int i = 0; i < rowsData.rows.length; i++)
                                    _buildRow(cubit, rowsData, i),
                                ],
                              ),
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 15.sp),
                Row(
                  children: [
                    customButton(
                      title: S.of(context).discard,
                      function: () => Navigator.pop(context),
                      color: AppColors.secondaryButton,
                      textStyle: StyleText.fontSize16Weight600
                          .copyWith(color: AppColors.blackButton),
                    ),
                    const Spacer(),
                    customButton(
                      title: S.of(context).activate,
                      function: submitting ? () {} : () => _onActivate(cubit),
                      color: rowsData.isValid && !submitting
                          ? AppColors.primary
                          : AppColors.secondaryText,
                      textStyle: StyleText.fontSize16Weight600
                          .copyWith(color: AppColors.textButton),
                    ),
                  ],
                ),
                SizedBox(height: 16.sp),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _totalChip(AccessBulkUploadRows rowsData) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 4.sp),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        '${_tr('Total Access', 'إجمالي الصلاحيات')}: ${rowsData.rows.length}',
        style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
      ),
    );
  }

  Widget _buildToolbar(AccessBulkUploadCubit cubit, AccessBulkUploadRows rowsData) {
    final int errorCount = rowsData.errorCount;
    final TextStyle darkButtonText =
        StyleText.fontSize14Weight500.copyWith(color: AppColors.white);

    return Row(
      children: [
        Container(
          height: 30.sp,
          padding: EdgeInsets.symmetric(horizontal: 4.sp),
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
                icon: Icon(_ar ? Icons.chevron_right : Icons.chevron_left,
                    color: AppColors.text),
              ),
              Text('${S.of(context).error}: ',
                  style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
              Text(
                errorCount > 0 && _currentErrorIndex >= 0
                    ? '${_currentErrorIndex + 1}/$errorCount'
                    : '$errorCount',
                style: StyleText.fontSize14Weight500.copyWith(
                    color: errorCount > 0 ? AppColors.red : AppColors.text),
              ),
              IconButton(
                iconSize: 16.sp,
                onPressed: () => _jumpToError(true, rowsData),
                icon: Icon(_ar ? Icons.chevron_left : Icons.chevron_right,
                    color: AppColors.text),
              ),
            ],
          ),
        ),
        const Spacer(),
        customButton(
          title: S.of(context).removeSelection,
          wrapContent: true,
          contentHorizontalPadding: 12.sp,
          function: () {
            if (rowsData.selectedRows.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(S.of(context).selectAtLeastOneRow)));
              return;
            }
            cubit.removeSelectedRows();
          },
          color: AppColors.black,
          textStyle: darkButtonText,
        ),
        SizedBox(width: 10.sp),
        customButton(
          title: S.of(context).duplication,
          wrapContent: true,
          contentHorizontalPadding: 12.sp,
          function: () {
            if (rowsData.selectedRows.length != 1) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(S.of(context).selectExactlyOneRowToDuplicate)));
              return;
            }
            cubit.duplicateSelectedRow();
          },
          color: AppColors.black,
          textStyle: darkButtonText,
        ),
        SizedBox(width: 10.sp),
        customButton(
          title: '+ ${S.of(context).row}',
          wrapContent: true,
          contentHorizontalPadding: 12.sp,
          function: cubit.addRow,
          color: AppColors.black,
          textStyle: darkButtonText,
        ),
      ],
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      children: [
        SizedBox(width: 40.sp),
        for (final (String label, double width) in _columns)
          SizedBox(
            width: width.sp,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.sp),
              child: Container(
                height: 30.sp,
                alignment: AlignmentDirectional.centerStart,
                padding: EdgeInsets.symmetric(horizontal: 8.sp),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRow(AccessBulkUploadCubit cubit, AccessBulkUploadRows rowsData, int index) {
    final AccessBulkRowForm row = rowsData.rows[index];
    final List<(String, double)> columns = _columns;
    double w(int column) => columns[column].$2.sp;

    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final UserAccessStatus? status = row.accessGranted == null
        ? null
        : (row.accessGranted!.isAfter(today)
            ? UserAccessStatus.scheduled
            : UserAccessStatus.active);

    return Container(
      key: row.key,
      padding: EdgeInsets.symmetric(vertical: 5.sp),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CustomCheckBox is display-only; `opaque` keeps the whole slot
          // tappable (same note as the GRC preview).
          SizedBox(
            width: 40.sp,
            height: _kCellHeight.sp,
            child: Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => cubit.toggleRowSelected(index),
                child: CustomCheckBox(isSelected: rowsData.selectedRows.contains(index)),
              ),
            ),
          ),
          _textCell(
            width: w(0),
            controller: row.employeeIdController,
            focusNode: row.focusNodes[AccessBulkField.employeeId]!,
            error: row.errors[AccessBulkField.employeeId],
            onChanged: cubit.revalidate,
          ),
          _textCell(
            width: w(1),
            controller: row.emailController,
            focusNode: row.focusNodes[AccessBulkField.email]!,
            error: row.errors[AccessBulkField.email],
            onChanged: cubit.revalidate,
          ),
          _readOnlyCell(
            width: w(2),
            text: row.currentAccess?.getLocalizedRoleName(_ar) ?? '-',
          ),
          _cell(
            width: w(3),
            child: Focus(
              focusNode: row.focusNodes[AccessBulkField.desiredRole],
              child: CustomDropdown<String>(
                items: <DropdownItem<String>>[
                  for (final RoleHistoryModel role in rowsData.roles)
                    DropdownItem<String>(
                      value: role.currentRoleName,
                      label: _ar && role.currentRoleNameAr.trim().isNotEmpty
                          ? role.currentRoleNameAr
                          : role.currentRoleName,
                    ),
                ],
                value: row.desiredRole,
                // An unmatched file value is shown back as the hint, so the
                // user sees what the sheet said while picking the fix.
                hint: row.rawRole.isNotEmpty ? row.rawRole : S.of(context).select,
                onChanged: (String? value) => cubit.setRole(index, value),
                errorText: _maybeError(row.errors[AccessBulkField.desiredRole]),
                fillColor: AppColors.background,
                height: _kCellHeight,
              ),
            ),
          ),
          _cell(
            width: w(4),
            child: Focus(
              focusNode: row.focusNodes[AccessBulkField.accessGranted],
              child: CustomDropdownCalendar(
                value: row.accessGranted,
                hint: row.rawGranted.isNotEmpty ? row.rawGranted : 'dd-mm-yyyy',
                firstDate: today,
                dateFormatter: _formatDate,
                onChanged: (DateTime? date) => cubit.setAccessGranted(index, date),
                errorText: _maybeError(row.errors[AccessBulkField.accessGranted]),
                fillColor: AppColors.background,
                height: _kCellHeight,
              ),
            ),
          ),
          _cell(
            width: w(5),
            child: Focus(
              focusNode: row.focusNodes[AccessBulkField.accessRevoked],
              child: CustomDropdownCalendar(
                value: row.accessRevoked,
                hint: row.rawRevoked.isNotEmpty ? row.rawRevoked : 'dd-mm-yyyy',
                firstDate: row.accessGranted ?? today,
                dateFormatter: _formatDate,
                onChanged: (DateTime? date) => cubit.setAccessRevoked(index, date),
                errorText: _maybeError(row.errors[AccessBulkField.accessRevoked]),
                fillColor: AppColors.background,
                height: _kCellHeight,
              ),
            ),
          ),
          _readOnlyCell(
            width: w(6),
            text: status?.label(context) ?? '-',
            color: status?.color,
          ),
        ],
      ),
    );
  }

  String? _maybeError(AccessBulkError? error) =>
      error == null ? null : _errorText(error);

  Widget _cell({required double width, required Widget child}) => SizedBox(
        width: width,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.sp),
          child: child,
        ),
      );

  Widget _readOnlyCell({required double width, required String text, Color? color}) {
    return _cell(
      width: width,
      child: Container(
        height: _kCellHeight.sp,
        alignment: AlignmentDirectional.centerStart,
        padding: EdgeInsets.symmetric(horizontal: 12.sp),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: StyleText.fontSize12Weight400
              .copyWith(color: color ?? AppColors.secondaryText),
        ),
      ),
    );
  }

  Widget _textCell({
    required double width,
    required TextEditingController controller,
    required FocusNode focusNode,
    required AccessBulkError? error,
    required VoidCallback onChanged,
  }) {
    final Color borderColor = error != null ? AppColors.red : Colors.transparent;
    OutlineInputBorder border(Color color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
          borderSide: BorderSide(color: color),
        );

    return _cell(
      width: width,
      child: SizedBox(
        height: _kCellHeight.sp,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: (_) => onChanged(),
          textAlignVertical: TextAlignVertical.center,
          style: StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: AppColors.background,
            contentPadding: EdgeInsets.symmetric(horizontal: 12.sp),
            suffixIcon: error != null
                ? Tooltip(
                    message: _errorText(error),
                    child: Icon(Icons.error, color: AppColors.red, size: 16.sp),
                  )
                : null,
            border: border(borderColor),
            enabledBorder: border(borderColor),
            focusedBorder: border(error != null ? AppColors.red : AppColors.primary),
          ),
        ),
      ),
    );
  }
}
