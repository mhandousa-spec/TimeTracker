// ***************************** FILE INFO ***************************** //
// File Name: employee_bulk_upload_view.dart
// Purpose: Renders employee bulk-upload states and result dialogs.
// Author: Mohamed Elrashidy
// Created At: 2026-08-16
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import '../../../../../../../core/custom/57-custom_dialog_manager.dart';
import '../../../../../../../core/custom/66-circle_progress.dart';
import '../../../../../../../core/theme/app_colors.dart';

import '../../../../../../../generated/l10n.dart';
import '../../../../../../core/helper/main_helper/pagination_app_bar.dart';
import '../../controller/employee_bulk_upload_cubit.dart';
import '../../controller/employee_bulk_upload_state.dart';
import '../../../data/models/employee_bulk_upload_commit_result.dart';
import '../../../utils/employee_bulk_upload_failure.dart';
import '../widgets/employee_bulk_upload_drop_zone.dart';
import '../widgets/employee_bulk_upload_dialog_action.dart';
import 'employee_bulk_upload_editable_workbook.dart';
import 'employee_bulk_upload_processing_overlay.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

/// Main state-driven content for the employee bulk-upload flow.
class EmployeeBulkUploadView extends StatelessWidget {
  const EmployeeBulkUploadView({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = S.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PaginationAppBar(screensTitles: [
                localization.humanResources,
                localization.employees,
                localization.employeeBulkUploadTitle,
              ]),
              SizedBox(height: 16.h),
              Expanded(
                child: BlocConsumer<EmployeeBulkUploadCubit,
                    EmployeeBulkUploadState>(
                  listenWhen: (previous, current) =>
                      previous.status.runtimeType !=
                          current.status.runtimeType ||
                      previous.failure != current.failure ||
                      previous.failureMessage != current.failureMessage,
                  listener: _listen,
                  builder: (context, state) {
                    final cubit = context.read<EmployeeBulkUploadCubit>();
                    final file = state.file;
                    final inputIsBusy =
                        state.status is EmployeeBulkUploadPicking ||
                            state.status is EmployeeBulkUploadParsing;
                    final content = file == null
                        ? Center(
                            child: EmployeeBulkUploadDropZone(
                              isProcessing: inputIsBusy,
                              onBrowse: () => cubit.pickAndParse(localization),
                              onDiscard: cubit.discard,
                              onNoFilesDropped: () =>
                                  cubit.reportDroppedFileFailure(
                                EmployeeBulkNoDroppedFileFailure(
                                  localization.employeeBulkNoDroppedFiles,
                                ),
                                localization,
                              ),
                              onUnsupportedFile: () =>
                                  cubit.reportDroppedFileFailure(
                                EmployeeBulkUnsupportedFileFailure(
                                  localization.employeeBulkUnsupportedFile,
                                ),
                                localization,
                              ),
                              onFileReadFailure: () =>
                                  cubit.reportDroppedFileFailure(
                                EmployeeBulkFileReadFailure(
                                  localization.employeeBulkFileReadFailure,
                                ),
                                localization,
                              ),
                              onDropped: (name, bytes) => cubit.parseBytes(
                                name,
                                bytes,
                                localization,
                              ),
                            ),
                          )
                        : EmployeeBulkUploadEditableWorkbook(
                            fileName: file.fileName,
                            errorCount: file.errors.length,
                            focusedErrorIndex: state.focusedError == null
                                ? -1
                                : file.errors.indexOf(state.focusedError!),
                            hasSelection: state.selectedRows.isNotEmpty,
                            canDuplicate: state.selectedRows.length == 1,
                            selectedRows: state.selectedRows,
                            focusedError: state.focusedError,
                            rows: file.rows,
                            errors: file.errors,
                            canSubmit: state.canSubmit,
                            submitting:
                                state.status is EmployeeBulkUploadSubmitting,
                            employeeCount: file.employeeCount,
                            newDepartmentCount: state.newDepartments.length,
                            onPreviousError: cubit.focusPreviousError,
                            onNextError: cubit.focusNextError,
                            onAdd: () => cubit.addRow(localization),
                            onDuplicate: () =>
                                cubit.duplicateSelected(localization),
                            onRemove: () => cubit.removeSelected(localization),
                            onToggleRow: cubit.toggleRow,
                            onChanged: (row, header, value) => cubit.updateCell(
                              row,
                              header,
                              value,
                              localization,
                            ),
                            onDiscard: cubit.discard,
                            onSubmit: () => cubit.submit(localization),
                          );
                    return Stack(
                      children: [
                        content,
                        if (state.status is EmployeeBulkUploadParsing)
                          EmployeeBulkUploadProcessingOverlay(
                            message: localization.processingFile,
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _listen(BuildContext context, EmployeeBulkUploadState state) {
    final localization = S.of(context);
    if (state.status is EmployeeBulkUploadSubmitting) {
      showLoadingIndicator();
      return;
    }
    if (state.status is EmployeeBulkUploadFailureStatus ||
        state.status is EmployeeBulkUploadCompletedWithFailures ||
        state.status is EmployeeBulkUploadSuccess) {
      hideLoadingIndicator();
    }
    if (state.status is EmployeeBulkUploadFailureStatus &&
        state.failureMessage != null) {
      if (state.failure != null) {
        _showFileFailureDialog(
          context,
          failure: state.failure!,
          message: state.failureMessage!,
        );
      } else {
        _showFailureMessageDialog(context, state.failureMessage!);
      }
    } else if (state.status is EmployeeBulkUploadCompletedWithFailures) {
      _showFailedEmployeesDialog(context, state.failedEmployees);
    } else if (state.status is EmployeeBulkUploadSuccess) {
      _showSuccessDialog(context, state, localization);
    }
  }

  void _showSuccessDialog(
    BuildContext context,
    EmployeeBulkUploadState state,
    S localization,
  ) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        contentPadding: EdgeInsets.all(20.sp),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/lottie_assets/main_lottie_assets/lottie_approved.json',
              width: 90.sp,
              height: 90.sp,
            ),
            SizedBox(height: 15.sp),
            Text(
              localization.employeeBulkUploadSuccess,
              style: StyleText.fontSize20Weight500.copyWith(
                color: AppColors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15.sp),
            Text(
              '${localization.employeeBulkTotalEmployees}: '
              '${state.createdEmployeeCount}',
              style: StyleText.fontSize18Weight500.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
            SizedBox(height: 15.sp),
            EmployeeBulkUploadDialogAction(
              title: localization.ok,
              onTap: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFailedEmployeesDialog(
    BuildContext context,
    List<EmployeeBulkUploadFailedEmployee> failedEmployees,
  ) {
    final localization = S.of(context);
    final cubit = context.read<EmployeeBulkUploadCubit>();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        contentPadding: EdgeInsets.all(20.sp),
        content: SizedBox(
          width: 520.sp,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/lottie_assets/main_lottie_assets/lottie_rejected.json',
                width: 90.sp,
                height: 90.sp,
              ),
              SizedBox(height: 15.sp),
              Text(
                localization.employeeBulkUploadFailure,
                style: StyleText.fontSize20Weight500.copyWith(
                  color: AppColors.secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15.sp),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 280.sp),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final failedEmployee in failedEmployees)
                        Padding(
                          padding: EdgeInsets.only(bottom: 10.sp),
                          child: Text(
                            '${failedEmployee.excelRowNumber} · '
                            '${failedEmployee.employeeId}\n'
                            '${cubit.failureMessageFor(
                              failedEmployee.failure,
                              localization,
                            )}',
                            style:
                                StyleText.fontSize14Weight400.copyWith(
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 15.sp),
              EmployeeBulkUploadDialogAction(
                title: localization.ok,
                onTap: () => Navigator.pop(dialogContext),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFileFailureDialog(
    BuildContext context, {
    required EmployeeBulkUploadFailure failure,
    required String message,
  }) {
    final localization = S.of(context);
    CustomDialogManager.showMessage(
      context: context,
      lottiePath:
          'assets/lottie_assets/main_lottie_assets/lottie_rejected.json',
      title: failure is EmployeeBulkHeaderFailure
          ? localization.warning
          : localization.error,
      subtitle: _fileFailureSubtitle(failure, message, localization),
    );
  }

  /// Method Name: [_showFailureMessageDialog]
  ///
  /// Purpose: Shows a dialog when a failure has no typed failure object.
  ///
  /// Parameters:
  /// - [context]: Page context used to show the dialog.
  /// - [message]: Localized failure message to display.
  ///
  /// Returns: Starts the failure acknowledgement dialog.
  void _showFailureMessageDialog(BuildContext context, String message) {
    final localization = S.of(context);
    CustomDialogManager.showMessage(
      context: context,
      lottiePath:
          'assets/lottie_assets/main_lottie_assets/lottie_rejected.json',
      title: localization.error,
      subtitle: message,
    );
  }

  String _fileFailureSubtitle(
    EmployeeBulkUploadFailure failure,
    String message,
    S localization,
  ) {
    if (failure is! EmployeeBulkHeaderFailure) return message;
    final details = <String>[message];
    if (failure.missingHeaders.isNotEmpty) {
      details.add(
        '${localization.missingColumns}: ${failure.missingHeaders.join(', ')}',
      );
    }
    if (failure.unexpectedHeaders.isNotEmpty) {
      details.add(
        '${localization.unknownColumns}: '
        '${failure.unexpectedHeaders.join(', ')}',
      );
    }
    return details.join('\n\n');
  }
}
