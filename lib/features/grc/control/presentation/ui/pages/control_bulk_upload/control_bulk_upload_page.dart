// lib/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_page.dart
/// Module: GRC Control Bulk Upload
/// Description: The "Control Bulk Upload" drag & drop / browse screen,
///              scoped to a single Policy. Parses the selected workbook
///              via parseControlExcel() and, on success, provides
///              ChampionCubit/OwnerCubit (loading their module-scoped
///              lists) plus a fresh ControlBulkUploadCubit, then opens the
///              editable preview table. Mirrors
///              policy_bulk_upload_page.dart.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: desktop_drop, file_picker, ControlBulkUploadCubit,
///               ChampionCubit, OwnerCubit, control_excel_parser.dart

import 'dart:io';

import 'package:knowticed_plus/core/custom/37-custom_navigate.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/control/domain/use_cases/create_control_usecase.dart';
import 'package:knowticed_plus/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_cubit.dart';
import 'package:knowticed_plus/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_preview_page.dart';
import 'package:knowticed_plus/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_weight_dialog.dart';
import 'package:knowticed_plus/features/grc/control/presentation/ui/pages/control_bulk_upload/control_excel_parser.dart';
import 'package:knowticed_plus/features/grc/control_champion/presentation/controller/champion_cubit.dart';
import 'package:knowticed_plus/features/grc/control_owner/presentation/controller/owner_cubit.dart';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' hide Border, BorderStyle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class ControlBulkUploadPage extends StatefulWidget {
  final String moduleId;
  final String policyId;
  final DateTime policyStartDate;
  final DateTime policyEndDate;

  /// Middle breadcrumb segment. Figma draws this screen as
  /// "GRC > Module Name > Control Bulk Upload" at 768 and 1024; null/empty
  /// falls back to the old two-segment crumb so existing call sites that do
  /// not pass a name keep working.
  final String? moduleNameEn;
  final String? moduleNameAr;

  const ControlBulkUploadPage({
    super.key,
    required this.moduleId,
    required this.policyId,
    required this.policyStartDate,
    required this.policyEndDate,
    this.moduleNameEn,
    this.moduleNameAr,
  });

  @override
  State<ControlBulkUploadPage> createState() => _ControlBulkUploadPageState();
}

class _ControlBulkUploadPageState extends State<ControlBulkUploadPage> {
  bool _isDragging = false;
  bool _isProcessing = false;
  String? _errorMessage;
  bool? _equalWeights;

  /// function name: [_ensureEqualWeightsAnswered]
  ///
  /// purpose: show the Equal/Distinct weight dialog the first time the user
  ///          initiates an upload (Browse Files tap or a file drop), and
  ///          only then — subsequent uploads in this same page instance
  ///          reuse the already-answered value.
  ///
  /// return type: [Future<bool>] - true once `_equalWeights` is set and safe to use; false if the widget was unmounted while the dialog was open
  Future<bool> _ensureEqualWeightsAnswered() async {
    if (_equalWeights != null) return true;
    final answer = await showControlBulkWeightDialog(context);
    if (!mounted) return false;
    setState(() => _equalWeights = answer);
    return true;
  }

  Future<void> _pickAndParseExcel() async {
    if (!await _ensureEqualWeightsAnswered()) return;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
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
    if (!await _ensureEqualWeightsAnswered()) return;
    if (details.files.isEmpty) return;

    final file = details.files.first;
    final lowerName = file.name.toLowerCase();
    if (!lowerName.endsWith('.xlsx') && !lowerName.endsWith('.xls')) {
      setState(() => _errorMessage = S.of(context).pleaseDropAnExcelFileXlsxOrXls);
      return;
    }
    await _processBytes(await file.readAsBytes());
  }

  Future<void> _processBytes(List<int> bytes) async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    final result = parseControlExcel(bytes);

    if (!mounted) return;
    setState(() => _isProcessing = false);

    switch (result) {
      case ControlExcelParseSuccess(:final rows):
        navigateTo(
          context,
          MultiBlocProvider(
            providers: [
              BlocProvider<ChampionCubit>(
                create: (_) => GetIt.instance<ChampionCubit>()
                  ..getAllChampions(moduleId: widget.moduleId),
              ),
              BlocProvider<OwnerCubit>(
                create: (_) => GetIt.instance<OwnerCubit>()
                  ..getAllOwners(moduleId: widget.moduleId),
              ),
            ],
            child: Builder(
              builder: (innerContext) => BlocProvider<ControlBulkUploadCubit>(
                create: (_) => ControlBulkUploadCubit(
                  createControlUseCase: GetIt.instance<CreateControlUseCase>(),
                  championCubit: innerContext.read<ChampionCubit>(),
                  ownerCubit: innerContext.read<OwnerCubit>(),
                  parsedRows: rows,
                  equalWeights: _equalWeights!,
                  policyStartDate: widget.policyStartDate,
                  policyEndDate: widget.policyEndDate,
                ),
                child: ControlBulkUploadPreviewPage(
                  moduleId: widget.moduleId,
                  policyId: widget.policyId,
                  moduleNameEn: widget.moduleNameEn,
                  moduleNameAr: widget.moduleNameAr,
                ),
              ),
            ),
          ),
        );
      case ControlExcelParseHeaderMismatch(:final message):
        setState(() => _errorMessage = message);
      case ControlExcelParseEmpty():
        setState(() => _errorMessage = S.of(context).noDataRowsFoundInTheExcelFile);
    }
  }

  /// The module name for the middle crumb, or null when none was passed.
  String? _moduleName(BuildContext context) {
    final name = ContextExtension(context).isArabic
        ? widget.moduleNameAr
        : widget.moduleNameEn;
    return (name == null || name.trim().isEmpty) ? null : name;
  }

  @override
  Widget build(BuildContext context) {
    final String? moduleName = _moduleName(context);
    // The frame owns the Scaffold, SafeArea, breadcrumb and side padding.
    // The middle crumb is optional here, so the first crumb's pop count
    // follows it: 2 routes back when the module name is present, 1 when it
    // isn't.
    return SideFrameMasterServices(
      titleText: S.of(context).grc,
      onFirstTap: () => popFrameRoutes(context, moduleName != null ? 2 : 1),
      secondTitle: moduleName ?? S.of(context).controlBulkUpload,
      onSecondTap: moduleName != null ? () => popFrameRoutes(context, 1) : null,
      thirdTitle: moduleName != null ? S.of(context).controlBulkUpload : null,
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
