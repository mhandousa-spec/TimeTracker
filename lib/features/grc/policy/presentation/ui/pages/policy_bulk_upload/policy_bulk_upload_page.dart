/// Module: GRC Policy Bulk Upload
/// Description: The "Policy Bulk Upload" drag & drop / browse screen.
///              Parses the selected workbook via parsePolicyExcel() and, on
///              success, opens the editable preview table under a fresh
///              PolicyBulkUploadCubit; on a header mismatch or empty file
///              it shows an inline error instead of navigating.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-11
/// Dependencies: desktop_drop, file_picker, PolicyBulkUploadCubit, policy_excel_parser.dart

import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'dart:io';

import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/policy/domain/use_cases/create_policy_usecase.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/pages/policy_bulk_upload/policy_bulk_upload_cubit.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/pages/policy_bulk_upload/policy_bulk_upload_preview_page.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/pages/policy_bulk_upload/policy_excel_parser.dart';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' hide Border, BorderStyle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: policy_bulk_upload_page.dart
/// Purpose: Contains PolicyBulkUploadPage, the drag & drop / browse entry
///          screen for the Policy Bulk Upload flow.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 11/7/2026

/// class name: [PolicyBulkUploadPage]
///
/// purpose: let the user pick or drop an Excel workbook of policies, parse
///          it, and open the editable preview table on success.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 11/7/2026
class PolicyBulkUploadPage extends StatefulWidget {
  final String moduleId;

  /// Module name shown as the middle breadcrumb, as the design draws it
  /// (GRC > Module Name > Policy Bulk Upload). Optional so existing call
  /// sites keep working; the breadcrumb simply drops that segment when
  /// nothing is passed.
  final String? moduleNameEn;
  final String? moduleNameAr;

  /// Owners of the module — forwarded to the preview page, which is where the
  /// upload is actually confirmed and the notification sent.
  final List<String> moduleOwners;

  const PolicyBulkUploadPage({
    super.key,
    required this.moduleId,
    this.moduleNameEn,
    this.moduleNameAr,
    this.moduleOwners = const <String>[],
  });

  @override
  State<PolicyBulkUploadPage> createState() => _PolicyBulkUploadPageState();
}

class _PolicyBulkUploadPageState extends State<PolicyBulkUploadPage> {
  bool _isDragging = false;
  bool _isProcessing = false;
  String? _errorMessage;

  /// Name of the workbook the user picked, shown on the preview screen.
  String? _selectedFileName;

  Future<void> _pickAndParseExcel() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      // xlsx only. 'xls' was offered here, but the excel package reads
      // OOXML and cannot open a real legacy .xls at all -- picking one only
      // ever produced a parse failure, so it is no longer offered.
      allowedExtensions: ['xlsx'],
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    _selectedFileName = file.name;
    var bytes = file.bytes;
    if (bytes == null && file.path != null) {
      bytes = await File(file.path!).readAsBytes();
    }
    if (bytes == null) {
      setState(() => _errorMessage = S.of(context).unableToReadTheSelectedFile);
      return;
    }
    await _processBytes(bytes);
  }

  Future<void> _onDragDone(DropDoneDetails details) async {
    setState(() => _isDragging = false);
    if (details.files.isEmpty) return;

    final file = details.files.first;
    final lowerName = file.name.toLowerCase();
    if (!lowerName.endsWith('.xlsx') && !lowerName.endsWith('.xls')) {
      setState(() => _errorMessage = S.of(context).pleaseDropAnExcelFileXlsxOrXls);
      return;
    }
    _selectedFileName = file.name;
    await _processBytes(await file.readAsBytes());
  }

  Future<void> _processBytes(List<int> bytes) async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    final result = parsePolicyExcel(bytes);

    if (!mounted) return;
    setState(() => _isProcessing = false);

    switch (result) {
      case PolicyExcelParseSuccess(:final rows):
        final activated = await Navigator.push<bool>(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => BlocProvider<PolicyBulkUploadCubit>(
              create: (_) => PolicyBulkUploadCubit(
                createPolicyUseCase: GetIt.instance<CreatePolicyUseCase>(),
                parsedRows: rows,
              ),
              child: PolicyBulkUploadPreviewPage(
                moduleId: widget.moduleId,
                fileName: _selectedFileName,
                moduleNameEn: widget.moduleNameEn,
                moduleNameAr: widget.moduleNameAr,
                moduleOwners: widget.moduleOwners,
              ),
            ),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
        // The preview page only pops with `true` once every row activated
        // successfully — chain that pop through this page too, so the
        // module list (which reloads unconditionally on return) is reached
        // directly instead of leaving the user on this now-stale picker.
        if (activated == true && mounted) {
          Navigator.pop(context, true);
        }
      case PolicyExcelParseHeaderMismatch(:final message):
        setState(() => _errorMessage = message);
      case PolicyExcelParseUnreadable(:final message):
        setState(() => _errorMessage = message);
      case PolicyExcelParseEmpty():
        setState(() => _errorMessage = S.of(context).noDataRowsFoundInTheExcelFile);
    }
  }

  /// The module segment of the breadcrumb in the active language, or null
  /// when the caller did not supply one.
  String? _moduleName(BuildContext context) {
    final name = ContextExtension(context).isArabic
        ? widget.moduleNameAr
        : widget.moduleNameEn;
    return (name == null || name.trim().isEmpty) ? null : name;
  }

  @override
  Widget build(BuildContext context) {
    // The frame owns the Scaffold, SafeArea, breadcrumb and side padding.
    final String? moduleName = _moduleName(context);
    return SideFrameMasterServices(
      titleText: S.of(context).grc,
      onFirstTap: () => popFrameRoutes(context, moduleName != null ? 2 : 1),
      secondTitle: moduleName ?? S.of(context).policyBulkUpload,
      onSecondTap:
          moduleName != null ? () => popFrameRoutes(context, 1) : null,
      thirdTitle: moduleName != null ? S.of(context).policyBulkUpload : null,
      // The drop zone is an Expanded over a pinned button row.
      child: SideFrameBoundedBody(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: DropTarget(
                  onDragEntered: (_) => setState(() => _isDragging = true),
                  onDragExited: (_) => setState(() => _isDragging = false),
                  onDragDone: _onDragDone,
                  child: GestureDetector(
                    onTap: _pickAndParseExcel,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _isDragging
                            ? AppColors.primary.withOpacity(0.1)
                            : AppColors.card,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: _isProcessing
                            ? CircularProgressIndicator(color: AppColors.primary)
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons_assets/main_icons_assets/uploadfile.svg',
                                    width: 100.sp,
                                    height: 100.sp,
                                  ),
                                  SizedBox(height: 27.sp),
                                  Text(
                                    S.of(context).dragDropHere,
                                    style: StyleText.fontSize20Weight500
                                        .copyWith(color: AppColors.text),
                                  ),
                                  SizedBox(height: 8.sp),
                                  Text(
                                    S.of(context).or,
                                    style: StyleText.fontSize16Weight500
                                        .copyWith(color: AppColors.secondaryText),
                                  ),
                                  if (_errorMessage != null) ...[
                                    SizedBox(height: 16.sp),
                                    Text(
                                      _errorMessage!,
                                      style: StyleText.fontSize14Weight500
                                          .copyWith(color: AppColors.red),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 26.h),
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
                    title: S.of(context).browseFiles,
                    function: _pickAndParseExcel,
                    width: 150.w,
                    height: 38.h,
                    color: AppColors.primary,
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
  }
}
