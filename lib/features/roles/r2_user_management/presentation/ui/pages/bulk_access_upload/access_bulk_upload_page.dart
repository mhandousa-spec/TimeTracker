/// Module: roles / r2_user_management / presentation / ui / pages / bulk_access_upload
///
///*************************** FILE INFO ****************************///
/// File Name: access_bulk_upload_page.dart
/// Purpose: "Bulk Upload" step 1 — drop or browse for the import workbook
///          (Figma 4717:35944). Opened by the Import button on the User
///          Management home.
/// Author: Knowticed Plus team
/// Created At: 21/9/2026 — bug report p.1. Same layout as the GRC assignee
///          and services bulk uploads: an Expanded drop zone over a pinned
///          Discard / Browse Files row.
library;

import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' hide Border, BorderStyle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/domain/entities/user_permission_entity.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/controller/user_management_cubit.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/ui/pages/bulk_access_upload/access_bulk_upload_cubit.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/ui/pages/bulk_access_upload/access_bulk_upload_parser.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/ui/pages/bulk_access_upload/access_bulk_upload_preview_page.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class AccessBulkUploadPage extends StatefulWidget {
  /// The User Management cubit: supplies the repository and the current
  /// access roster, and is refreshed after a successful import.
  final UserManagementAccessCubit userManagement;

  const AccessBulkUploadPage({super.key, required this.userManagement});

  @override
  State<AccessBulkUploadPage> createState() => _AccessBulkUploadPageState();
}

class _AccessBulkUploadPageState extends State<AccessBulkUploadPage> {
  bool _isDragging = false;
  bool _isProcessing = false;
  String? _errorMessage;

  String _tr(String en, String ar) => context.isArabic ? ar : en;

  Future<void> _browse() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>['xlsx', 'xls', 'csv'],
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;

    final PlatformFile file = result.files.single;
    List<int>? bytes = file.bytes;
    if (bytes == null && file.path != null) {
      bytes = await File(file.path!).readAsBytes();
    }
    if (!mounted) return;
    if (bytes == null) {
      setState(() => _errorMessage = S.of(context).unableToReadTheSelectedFile);
      return;
    }
    await _process(bytes, file.name);
  }

  Future<void> _onDragDone(DropDoneDetails details) async {
    setState(() => _isDragging = false);
    if (details.files.isEmpty) return;

    final file = details.files.first;
    final String name = file.name.toLowerCase();
    if (!name.endsWith('.xlsx') &&
        !name.endsWith('.xls') &&
        !name.endsWith('.csv')) {
      setState(() => _errorMessage = S.of(context).pleaseDropAnExcelFileXlsxOrXls);
      return;
    }
    await _process(await file.readAsBytes(), file.name);
  }

  Future<void> _process(List<int> bytes, String fileName) async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    // Roles may not be loaded yet if Role Management was never opened this
    // session; the review screen needs them to match "Desired Role Type".
    if (roleCubit.roles.isEmpty) await roleCubit.getUnDeletedRoles();

    final AccessBulkParseResult result = parseAccessBulkFile(bytes, fileName);
    if (!mounted) return;
    setState(() => _isProcessing = false);

    switch (result) {
      case AccessBulkParseSuccess(:final rows):
        await _openPreview(rows);
      case AccessBulkParseInvalid(:final missingHeaders):
        setState(() => _errorMessage = missingHeaders.isEmpty
            ? _tr(
                'This file could not be read. Open it in Excel and save it again as .xlsx or .csv, then retry.',
                'تعذرت قراءة هذا الملف. افتحه في إكسل واحفظه مرة أخرى بصيغة ‎.xlsx أو ‎.csv ثم أعد المحاولة.')
            : '${_tr('Missing columns', 'أعمدة مفقودة')}: ${missingHeaders.join(', ')}\n'
                '${_tr('Expected columns', 'الأعمدة المتوقعة')}: ${accessBulkUploadHeaders.join(', ')}');
      case AccessBulkParseEmpty():
        setState(() => _errorMessage = S.of(context).noDataRowsFoundInTheExcelFile);
    }
  }

  Future<void> _openPreview(List<AccessBulkRawRow> rows) async {
    final UserManagementAccessCubit userManagement = widget.userManagement;

    final Map<String, UserPermissionEntity> currentAccess =
        <String, UserPermissionEntity>{
      for (final List<UserPermissionEntity> users
          in userManagement.roleFilteredUsersPermissions.values)
        for (final UserPermissionEntity user in users) user.employeeId: user,
    };

    final bool? activated = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => BlocProvider<AccessBulkUploadCubit>(
          create: (_) => AccessBulkUploadCubit(
            repository: userManagement.repository,
            rawRows: rows,
            employees: AppControllers.employee.allEmployeesEntities ?? const [],
            roles: roleCubit.roles,
            currentAccessByEmployeeId: currentAccess,
            currentUserEmail:
                AppControllers.employee.employeeEntity?.email ?? '',
          ),
          child: const AccessBulkUploadPreviewPage(),
        ),
      ),
    );

    // Refresh whatever happened: a partial import still saved some rows.
    userManagement.getUserAccess();
    if (activated == true && mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return SideFrameMasterServices(
      titleText: S.of(context).platformControlsAndManagement,
      onFirstTap: () => popFrameRoutes(context, 1),
      secondTitle: S.of(context).bulkUpload,
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
                  onTap: _isProcessing ? null : _browse,
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
                          ? const CircleProgressMaster()
                          : Padding(
                              padding: EdgeInsets.all(20.sp),
                              child: Column(
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
                                      textAlign: TextAlign.center,
                                      style: StyleText.fontSize14Weight500
                                          .copyWith(color: AppColors.red),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 26.sp),
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
                  title: S.of(context).browseFiles,
                  function: _isProcessing ? () {} : _browse,
                  color: AppColors.primary,
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
  }
}
