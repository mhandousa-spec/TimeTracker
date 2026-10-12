/// Module: roles / r2_user_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: user_management_export_dialog.dart
/// Purpose: Declares `UserManagementExportDialog`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/core/helper/data_grc_module/core/extensions/extensions.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
import 'package:dartz/dartz.dart' show Either;
import 'package:knowticed_plus/core/helper/main_helper/csv_helper.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/helper/main_helper/employee_helper.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_date.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/domain/entities/user_permission_entity.dart';

import 'package:knowticed_plus/core/custom/5-custom_button.dart';
// ADDED 8/9/2026: the in-row export spinner — same as the roles export dialog.
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:collection/collection.dart';
class UserManagementExportDialog extends StatefulWidget {
  final List<UserPermissionEntity> userPermissions;

  const UserManagementExportDialog({
    Key? key,
    required this.userPermissions,
  }) : super(key: key);

  @override
  State<UserManagementExportDialog> createState() => _UserManagementExportDialogState();
}

class _UserManagementExportDialogState extends State<UserManagementExportDialog> {
  final TextEditingController controller = TextEditingController();
  // REMOVED 8/9/2026: `_overlayEntry` — the full-screen loading overlay it held
  // is gone; the wait is drawn in the button row instead, matching the roles
  // export dialog.
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // FIXED 29/8/2026: the default file name was hardcoded English
    // ("User_Management_export_29 Aug 2026") even in Arabic mode. It is now
    // built from localized strings, so AR mode yields an Arabic name.
    // Resolved in didChangeDependencies because it needs Localizations, which
    // are not ready in initState.
    if (controller.text.isEmpty) {
      controller.text = _getDefaultFileName(context);
    }
  }

  /// The name the File Name box opens with.
  ///
  /// Every part of it follows the locale: the label from the ARB, the month
  /// name and the digits from [LocalizedDate] — so Arabic mode offers
  /// "تصدير إدارة المستخدمين_٢٩ أغسطس ٢٠٢٦" rather than an Arabic label with a
  /// Latin date stuck on the end.
  ///
  /// It is only a DEFAULT: the box is editable, and the user can replace it
  /// with anything before exporting.
  String _getDefaultFileName(BuildContext context) {
    final String dateStr = LocalizedDate.of(
      context,
      DateTime.now(),
      pattern: 'dd MMM yyyy',
    );

    return "${S.of(context).exportUserManagement}_$dateStr";
  }

  /// How long the in-row spinner stays up at minimum.
  ///
  /// ADDED 8/9/2026. A small export finishes in a few milliseconds, so the
  /// spinner would appear and vanish inside one frame and the dialog would look
  /// like it did nothing. Same floor the roles export dialog uses.
  static const Duration _minimumProgressDuration = Duration(milliseconds: 700);

  /// Holds the spinner for the rest of its minimum, then clears it.
  Future<void> _finishProgress(DateTime shownAt) async {
    final Duration elapsed = DateTime.now().difference(shownAt);
    if (elapsed < _minimumProgressDuration) {
      await Future<void>.delayed(_minimumProgressDuration - elapsed);
    }
    if (!mounted) return;
    setState(() {
      _isExporting = false;
    });
  }


  EmployeeEntityPro? _getEmployee(String employeeId) {
    try {
      return AppControllers.employee
          .allEmployeesEntities!
          .firstWhere((element) => element.id == employeeId);
    } catch (e) {
      return null;
    }
  }

  // ✅ Localized role name (matches the table). Drop this and use
  // `user.accessName` in the CSV if you want the export to stay raw English.
  String _getRoleName(UserPermissionEntity user, BuildContext context) {
    final access = user.accessName;
    if (access == null || access.trim().isEmpty) return '';

    try {
      // Was `final roleCubit = Get.find<RoleCubit>();`. The GetX sweep replaced
      // the right-hand side with the shared `roleCubit` singleton, which made
      // the local shadow itself. The singleton is used directly instead.
      final target = access.trim().toLowerCase();

      final role = roleCubit.roles.firstWhereOrNull(
            (r) =>
        (r.roleId?.toString().trim().toLowerCase() == target) ||
            (r.currentRoleName?.trim().toLowerCase() == target),
      );

      if (role != null) {
        if (context.isArabic) {
          final ar = role.currentRoleNameAr;
          if (ar != null && ar.trim().isNotEmpty) return ar;
        }
        final en = role.currentRoleName;
        if (en != null && en.trim().isNotEmpty) return en;
      }
    } catch (e) {
      // RoleCubit not available -> fall back to raw access name.
    }

    return access;
  }

  String _getFirstName(EmployeeEntityPro? employee, BuildContext context) {
    if (employee == null) return '-';
    if (context.isArabic) {
      return employee.firstNameInArabic ?? employee.firstName ?? '-';
    } else {
      return employee.firstName ?? '-';
    }
  }

  String _getLastName(EmployeeEntityPro? employee, BuildContext context) {
    if (employee == null) return '-';
    if (context.isArabic) {
      return employee.lastNameInArabic ?? employee.lastName ?? '-';
    } else {
      return employee.lastName ?? '-';
    }
  }

  String _getEmail(EmployeeEntityPro? employee) {
    return employee?.email ?? '-';
  }

  // ✅ Phone now includes the country code (matches the table).
  String _getMobilePhone(EmployeeEntityPro? employee) {
    final mobile = employee?.mobilePhone;
    if (mobile?.phone == null) return '-';

    final phone = (mobile!.phone ?? '').replaceAll(RegExp(r'[\[\]]'), '').trim();
    if (phone.isEmpty) return '-';

    final rawCode = (mobile.countryCode ?? '').replaceAll(RegExp(r'[\[\]]'), '').trim();
    if (rawCode.isEmpty) return phone;

    final code = rawCode.startsWith('+') ? rawCode : '+$rawCode';
    return '$code $phone';
  }

  String _getDepartment(EmployeeEntityPro? employee, BuildContext context) {
    if (employee == null) return '-';
    return EmployeeHelper.getEmployeeLocalizeDepartment(
      employee: employee,
      context: context,
    );
  }

  String _getSupervisor(EmployeeEntityPro? employee, BuildContext context) {
    if (employee == null || employee.supervisor == null || employee.supervisor!.isEmpty) {
      return '-';
    }

    try {
      final allEmployees = AppControllers.employee.allEmployeesEntities;

      if (allEmployees == null || allEmployees.isEmpty) {
        return '-';
      }

      EmployeeEntityPro? supervisor = allEmployees.firstWhereOrNull(
            (element) => element.email?.toLowerCase().trim() == employee.supervisor?.toLowerCase().trim(),
      );

      if (supervisor == null) {
        supervisor = allEmployees.firstWhereOrNull(
              (element) => element.id?.toLowerCase().trim() == employee.supervisor?.toLowerCase().trim(),
        );
      }

      if (supervisor == null) {
        return '-';
      }

      return EmployeeHelper.getEmployeeLocalizedName(
        employee: supervisor,
        context: context,
      );
    } catch (e) {
      return '-';
    }
  }

  String _getTitle(EmployeeEntityPro? employee, BuildContext context) {
    if (employee == null) return '-';
    return EmployeeHelper.getEmployeeLocalizedTitle(
      employee: employee,
      context: context,
    ) ?? '-';
  }

  Future<void> _exportData(BuildContext context) async {
    if (_isExporting) return;

    final fileName = controller.text.trim();
    if (fileName.isEmpty) {
      _showMessage(
        context,
        title: S.of(context).error,
        message: S.of(context).pleaseEnterAFileName,
        background: AppColors.orange,
      );
      return;
    }

    // The spinner replaces the buttons from here until the write returns.
    setState(() {
      _isExporting = true;
    });
    final DateTime progressShownAt = DateTime.now();

    try {

      if (widget.userPermissions.isEmpty) {
        await _finishProgress(progressShownAt);
        _showMessage(
          context,
          title: S.of(context).noData,
          message: S.of(context).noUserPermissionsToExport,
          background: AppColors.orange,
        );
        return;
      }

      // FIXED 21/9/2026 — "Export CSV not work" (bug report p.8). This wrote
      // to `getApplicationDocumentsDirectory()`, which on a sandboxed macOS
      // build is the app container and on phones is unreachable, so the file
      // "exported" somewhere nobody could find it. It now goes through the
      // shared save path every other export uses: real Downloads (revealed)
      // on desktop, the system save sheet on phones.
      final Either<String, String> saved = await CSVHelper().exportForUser(
        fileName: fileName,
        csvContent: _generateCSVContent(),
      );

      await _finishProgress(progressShownAt);

      final String? saveError = saved.fold((l) => l, (_) => null);
      if (saveError != null) throw Exception(saveError);

      // The user dismissed the phone save sheet: nothing to report.
      if (saved.getOrElse(() => '') == CSVHelper.exportCancelled) return;

      // Capture the branded success strings and a stable navigator BEFORE
      // popping this dialog — once the export dialog is popped, this widget's
      // `context` is deactivated and can't be used to show another dialog or
      // resolve `S.of(context)`.
      final successTitle = S.of(context).exportSuccessful;
      final successSubtitle = S.of(context).exportSuccess;
      final navigator = Navigator.of(context, rootNavigator: true);

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (navigator.mounted) {
        await CustomDialogManager.showSuccess(
          context: navigator.context,
          lottiePath: 'assets/lottie_assets/main_lottie_assets/approved.json',
          title: successTitle,
          subtitle: successSubtitle,
        );
      }

    } catch (e) {
      await _finishProgress(progressShownAt);

      _showMessage(
        context,
        title: S.of(context).exportFailed,
        message: '${S.of(context).error}: ${e.toString()}',
        background: AppColors.red,
        duration: const Duration(seconds: 5),
      );
    }
  }

  /// Shows a transient message via the framework's Scaffold messenger.
  ///
  /// Replaces `Get.snackbar` (GetX is banned): the snack bar is now scoped to
  /// this route instead of a global overlay.
  void _showMessage(
    BuildContext context, {
    required String title,
    required String message,
    required Color background,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: duration,
          backgroundColor: background,
          behavior: SnackBarBehavior.floating,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(message, style: TextStyle(color: AppColors.white)),
            ],
          ),
        ),
      );
  }


  String _generateCSVContent() {
    List<List<dynamic>> rows = [
      [
        'NO',
        'Role Type',
        'Employee ID',
        'First Name',
        'Last Name',
        'Email',
        'Mobile Phone',
        'Department Name',
        'Supervisor',
        'Title',
      ],
    ];

    for (int i = 0; i < widget.userPermissions.length; i++) {
      final user = widget.userPermissions[i];
      final employee = _getEmployee(user.employeeId);

      rows.add([
        i + 1,
        _safeString(_getRoleName(user, context)),
        _safeString(user.employeeId),
        _safeString(_getFirstName(employee, context)),
        _safeString(_getLastName(employee, context)),
        _safeString(_getEmail(employee)),
        _safeString(_getMobilePhone(employee)),
        _safeString(_getDepartment(employee, context)),
        _safeString(_getSupervisor(employee, context)),
        _safeString(_getTitle(employee, context)),
      ]);
    }

    return _convertToCSV(rows);
  }

  String _safeString(dynamic value) {
    if (value == null) return '';
    String str = value.toString();
    if (str.contains(',') || str.contains('"') || str.contains('\n')) {
      str = '"${str.replaceAll('"', '""')}"';
    }
    return str;
  }

  String _convertToCSV(List<List<dynamic>> rows) {
    StringBuffer csvBuffer = StringBuffer();
    for (List<dynamic> row in rows) {
      csvBuffer.writeln(row.join(','));
    }
    return csvBuffer.toString();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  bool isTabletLandscape(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return size.width >= 900 && isLandscape;
  }

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    var isMobile = ContextExtension(context).isPhone;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
        ),
        width: 411.sp,
        child: Padding(
          padding: EdgeInsets.all(20.sp), // ✅ Equal padding on all sides
          child: Column(
            mainAxisSize: MainAxisSize.min, // ✅ Dialog now fits its content height
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 30.sp,
                    height: 30.sp,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                    child: Center(
                      // CHANGED 29/8/2026: was export_arrow.svg tinted
                      // AppColors.text — a light glyph on the light primary
                      // disc, so the circle read as empty. It is now the
                      // export mark, tinted AppColors.textButton, which is the
                      // colour every other icon on a primary background uses.
                      child: CustomSvgImage(
                        assetPath:
                            "assets/icons_assets/main_icons_assets/assets_export.svg",
                        width: 16.sp,
                        height: 16.sp,
                        color: AppColors.textButton,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.sp),
                  Text(
                    S.of(context).exportUserManagement,
                    style: StyleText.fontSize16Weight500.copyWith(
                     color: AppColors.text
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              CustomTextField(
                label: S.of(context).fileName,
                hint: S.of(context).textHere,
                controller: controller,
                height: 36,
                onChanged: (_) => setState(() {}),
              ),
              SizedBox(height: 20),
              // PROGRESS 8/9/2026: while the CSV is being written, Discard and
              // Export CSV are replaced IN PLACE by CircleProgressMaster —
              // identical to the roles export dialog. The SizedBox pins the row
              // to the button height so the dialog does not resize mid-export,
              // and the FittedBox lets the spinner (which sizes itself off the
              // screen height) settle into that row on any device.
              //
              // The two buttons take the roles dialog's width, passed through
              // `width:` — the parameter customButton actually honours.
              SizedBox(
                height: 38,
                child: _isExporting
                    ? const Center(
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: CircleProgressMaster(),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          customButton(
                            title: S.of(context).discard,
                            width: context.isPhone ? 120.sp : 150.sp,
                            color: AppColors.secondaryButton,
                            height: 38,
                            textStyle:
                                StyleText.fontSize16Weight500.copyWith(
                              color: AppColors.blackButton,
                            ),
                            radius: 8.r,
                            function: () => Navigator.pop(context),
                          ),
                          customButton(
                            title: S.of(context).exportCsv,
                            width: context.isPhone ? 120.sp : 150.sp,
                            color: AppColors.primary,
                            height: 38.sp,
                            textStyle:
                                StyleText.fontSize16Weight500.copyWith(
                              color: AppColors.textButton,
                            ),
                            radius: 8.r,
                            function: () => _exportData(context),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}