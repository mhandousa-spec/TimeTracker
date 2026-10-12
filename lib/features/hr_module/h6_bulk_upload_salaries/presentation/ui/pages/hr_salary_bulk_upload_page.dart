// ***************************** FILE INFO ***************************** //
// File Name: hr_salary_bulk_upload_page.dart
// Purpose: Hosts the Employee-style salary workbook flow.
// Author: Mohamed Elrashidy
// Created At: 2026-08-23
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/custom/57-custom_dialog_manager.dart';
import '../../../../../../../generated/l10n.dart';
import '../../../../../../core/helper/main_helper/pagination_app_bar.dart';
import '../../../../shared/bulk_upload/hr_bulk_upload_drop_zone.dart';
import '../../../../shared/bulk_upload/hr_bulk_upload_processing_overlay.dart';
import '../../../../shared/bulk_upload/hr_bulk_upload_workbook.dart';
import '../../controller/salary_bulk_upload_cubit.dart';
import '../../../utils/salary_bulk_upload_headers.dart';

/// Route entry for salary workbook uploads.
class HrSalaryBulkUploadPage extends StatelessWidget {
  const HrSalaryBulkUploadPage({super.key, this.refreshProvider});

  final Future<void> Function()? refreshProvider;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => SalaryBulkUploadCubit(refreshProvider: refreshProvider),
        child: const _SalaryBulkUploadView(),
      );
}

class _SalaryBulkUploadView extends StatelessWidget {
  const _SalaryBulkUploadView();

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PaginationAppBar(screensTitles: [
                l10n.humanResources,
                l10n.salary,
                l10n.salary,
              ]),
              SizedBox(height: 16.h),
              Expanded(
                child: BlocConsumer<SalaryBulkUploadCubit, SalaryBulkState>(
                  listener: (context, state) {
                    if (state.status is SalaryBulkCompleted ||
                        state.status is SalaryBulkPartial) {
                      Navigator.of(context).pop(true);
                    }
                    if (state.status is SalaryBulkFailed &&
                        state.message != null) {
                      CustomDialogManager.showMessage(
                        context: context,
                        lottiePath:
                            'assets/lottie_assets/main_lottie_assets/error.json',
                        title: l10n.errorOccurred,
                        subtitle: state.message!,
                      );
                    }
                  },
                  builder: (context, state) {
                    final cubit = context.read<SalaryBulkUploadCubit>();
                    final isProcessing = state.status is SalaryBulkWorking;
                    final content = state.file == null
                        ? Center(
                            child: HrBulkUploadDropZone(
                              isProcessing: isProcessing,
                              onBrowse: () => cubit.pick(l10n),
                              onDiscard: cubit.discard,
                              onDropped: (name, bytes) =>
                                  cubit.parse(name, bytes, l10n),
                              onNoFilesDropped: () {},
                              onUnsupportedFile: () {},
                              onFileReadFailure: () {},
                            ),
                          )
                        : HrBulkUploadWorkbook(
                            file: state.file!,
                            template: SalaryBulkUploadHeaders.template,
                            focusedErrorIndex: state.focusedError == null
                                ? -1
                                : state.file!.errors
                                    .indexOf(state.focusedError!),
                            selectedRows: state.selectedRows,
                            canSubmit: state.canSubmit,
                            submitting: state.status is SalaryBulkSubmitting,
                            onPreviousError: cubit.previousError,
                            onNextError: cubit.nextError,
                            onAdd: () => cubit.addRow(l10n),
                            onDuplicate: () => cubit.duplicateSelected(l10n),
                            onRemove: () => cubit.removeSelected(l10n),
                            onToggleRow: cubit.toggleRow,
                            onChanged: (row, header, value) =>
                                cubit.update(row, header, value, l10n),
                            onDiscard: cubit.discard,
                            onSubmit: () => cubit.submit(l10n),
                          );
                    return Stack(
                      children: [
                        content,
                        if (isProcessing)
                          HrBulkUploadProcessingOverlay(
                            message: l10n.processingFile,
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
}
