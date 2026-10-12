/// Module: roles / r2_user_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: user_management_table_widget.dart
/// Purpose: Declares `UserManagementTableWidget`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 29/8/2026 - Title and Supervisor swapped (Title now reads first,
///                      beside the department it belongs to), and the two
///                      access-date columns added at the end.
/// Updated: 30/8/2026 - Role Type moved out of the identity block to sit after
///                      Supervisor, and Access Grantor added before the two
///                      access-date columns.

import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/core/helper/data_grc_module/core/extensions/extensions.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/knowledge_hub_module/core/theming/new_theme.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'dart:ui' as ui;

import 'package:knowticed_plus/core/helper/main_helper/employee_helper.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_date.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/domain/entities/user_permission_entity.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:collection/collection.dart';

class UserManagementTableWidget extends StatelessWidget {
  final List<UserPermissionEntity> userPermissions;
  final String locale;

  const UserManagementTableWidget({
    Key? key,
    required this.userPermissions,
    required this.locale,
  }) : super(key: key);

  bool get _isArabic => locale.toLowerCase().startsWith('ar');

  TextStyle get _headerStyle => StyleText.fontSize14Weight500.copyWith(
    color: AppColors.white,
  );

  TextStyle _cellStyle(BuildContext context) {
    return StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack).copyWith(
      color: AppColors.text,
    );
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

  // ✅ Role name supports AR / EN (item value, not the header).
  // Reads RoleCubit via context.read (flutter_bloc) — same as the
  // UserPermissionOverview card, which is the access path that actually works.
  String _getRoleName(UserPermissionEntity user, BuildContext context) {
    final access = user.accessName;
    if (access == null || access.trim().isEmpty) return '-';

    try {
      final roleCubit = context.read<RoleCubit>();
      final role = roleCubit.roles.firstWhereOrNull(
            (r) =>
        r.roleId == access ||
            r.currentRoleName == access,
      );

      if (role != null) {
        return _isArabic ? role.currentRoleNameAr : role.currentRoleName;
      }
    } catch (e) {
      // RoleCubit not found in this widget's tree -> fall back to raw name.
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

  // ✅ Phone now includes the country code (e.g. +20 1012345678).
  String _getMobilePhone(EmployeeEntityPro? employee) {
    final mobile = employee?.mobilePhone;
    if (mobile?.phone == null) return '-';

    // Clean phone (remove square brackets if present)
    final phone = (mobile!.phone ?? '').replaceAll(RegExp(r'[\[\]]'), '').trim();
    if (phone.isEmpty) return '-';

    // Clean country code and normalize the leading '+'
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
    if (employee == null) return '-';

    // Check if supervisor field is empty
    if (employee.supervisor == null || employee.supervisor!.isEmpty) {
      return '-';
    }

    try {
      // Get all employees
      final allEmployees = AppControllers.employee.allEmployeesEntities;

      if (allEmployees == null || allEmployees.isEmpty) {
        return '-';
      }

      // Find supervisor by email (since supervisor field contains email)
      EmployeeEntityPro? supervisor = allEmployees.firstWhereOrNull(
            (element) => element.email?.toLowerCase().trim() == employee.supervisor?.toLowerCase().trim(),
      );

      // If not found by email, try by ID as fallback
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

  /// The person who granted this access.
  ///
  /// ADDED 30/8/2026. Unlike every other column here, this one does NOT come
  /// from the employee record — it is a property of the grant, resolved by the
  /// repository from `currentEditBy` and stored on the entity in both
  /// languages, so it is read straight off [UserPermissionEntity] rather than
  /// looked up again. An unresolvable grantor already arrives as
  /// "Unknown" / "غير معروف"; a grant with no grantor recorded at all renders
  /// as "-" like every other empty cell.
  String _getAccessGrantor(UserPermissionEntity user) {
    final String grantor = user.grantorName(_isArabic).trim();
    return grantor.isEmpty ? '-' : grantor;
  }

  String _getTitle(EmployeeEntityPro? employee, BuildContext context) {
    if (employee == null) return '-';
    return EmployeeHelper.getEmployeeLocalizedTitle(
      employee: employee,
      context: context,
    ) ?? '-';
  }

  // Width calculation methods
  double _calculateNoWidth(BuildContext context) {
    return context.isPortrait ? 60.w : 70.w;
  }

  double _calculateRoleTypeWidth(BuildContext context) {
    double maxLength = 0;
    for (var user in userPermissions) {
      // ✅ Use the localized role name so AR widths are correct too
      final roleName = _getRoleName(user, context);
      if (roleName.isNotEmpty && roleName != '-') {
        maxLength = maxLength > roleName.length ? maxLength : roleName.length.toDouble();
      }
    }
    if (maxLength == 0) return context.isPortrait ? 120.w : 140.w;
    double calculatedWidth = ((maxLength * 8.sp) + 40.w) > 200.w ? 200.w : (maxLength * 8.sp) + 40.w;
    double minWidth = context.isPortrait ? 120.w : 120.w;
    return calculatedWidth > minWidth ? calculatedWidth : minWidth;
  }

  double _calculateEmployeeIdWidth(BuildContext context) {
    return context.isPortrait ? 100.w : 120.w;
  }

  double _calculateFirstNameWidth(BuildContext context) {
    double maxLength = 0;
    for (var user in userPermissions) {
      EmployeeEntityPro? employee = _getEmployee(user.employeeId);
      String name = _getFirstName(employee, context);
      if (name.isNotEmpty && name != '-') {
        maxLength = maxLength > name.length ? maxLength : name.length.toDouble();
      }
    }
    if (maxLength == 0) return context.isPortrait ? 120.w : 140.w;
    double calculatedWidth = ((maxLength * 8.sp) + 40.w) > 200.w ? 200.w : (maxLength * 8.sp) + 40.w;
    double minWidth = context.isPortrait ? 120.w : 120.w;
    return calculatedWidth > minWidth ? calculatedWidth : minWidth;
  }

  double _calculateLastNameWidth(BuildContext context) {
    double maxLength = 0;
    for (var user in userPermissions) {
      EmployeeEntityPro? employee = _getEmployee(user.employeeId);
      String name = _getLastName(employee, context);
      if (name.isNotEmpty && name != '-') {
        maxLength = maxLength > name.length ? maxLength : name.length.toDouble();
      }
    }
    if (maxLength == 0) return context.isPortrait ? 120.w : 140.w;
    double calculatedWidth = ((maxLength * 8.sp) + 40.w) > 200.w ? 200.w : (maxLength * 8.sp) + 40.w;
    double minWidth = context.isPortrait ? 120.w : 120.w;
    return calculatedWidth > minWidth ? calculatedWidth : minWidth;
  }

  double _calculateEmailWidth(BuildContext context) {
    return context.isPortrait ? 300.w : 300.w;
  }

  double _calculateMobilePhoneWidth(BuildContext context) {
    // ✅ A bit wider now that the country code is shown
    return context.isPortrait ? 150.w : 170.w;
  }

  double _calculateDepartmentWidth(BuildContext context) {
    double maxLength = 0;
    for (var user in userPermissions) {
      EmployeeEntityPro? employee = _getEmployee(user.employeeId);
      String dept = _getDepartment(employee, context);
      if (dept.isNotEmpty && dept != '-') {
        maxLength = maxLength > dept.length ? maxLength : dept.length.toDouble();
      }
    }
    if (maxLength == 0) return context.isPortrait ? 140.w : 160.w;
    double calculatedWidth = ((maxLength * 8.sp) + 40.w) > 220.w ? 220.w : (maxLength * 8.sp) + 40.w;
    double minWidth = context.isPortrait ? 140.w : 140.w;
    return calculatedWidth > minWidth ? calculatedWidth : minWidth;
  }

  double _calculateSupervisorWidth(BuildContext context) {
    double maxLength = 0;
    for (var user in userPermissions) {
      EmployeeEntityPro? employee = _getEmployee(user.employeeId);
      String supervisor = _getSupervisor(employee, context);
      if (supervisor.isNotEmpty && supervisor != '-') {
        maxLength = maxLength > supervisor.length ? maxLength : supervisor.length.toDouble();
      }
    }
    if (maxLength == 0) return context.isPortrait ? 140.w : 160.w;
    double calculatedWidth = ((maxLength * 8.sp) + 40.w) > 200.w ? 200.w : (maxLength * 8.sp) + 40.w;
    double minWidth = context.isPortrait ? 140.w : 140.w;
    return calculatedWidth > minWidth ? calculatedWidth : minWidth;
  }

  double _calculateTitleWidth(BuildContext context) {
    double maxLength = 0;
    for (var user in userPermissions) {
      EmployeeEntityPro? employee = _getEmployee(user.employeeId);
      String title = _getTitle(employee, context);
      if (title.isNotEmpty && title != '-') {
        maxLength = maxLength > title.length ? maxLength : title.length.toDouble();
      }
    }
    if (maxLength == 0) return context.isPortrait ? 140.w : 160.w;
    double calculatedWidth = ((maxLength * 8.sp) + 40.w) > 200.w ? 200.w : (maxLength * 8.sp) + 40.w;
    double minWidth = context.isPortrait ? 140.w : 140.w;
    return calculatedWidth > minWidth ? calculatedWidth : minWidth;
  }

  /// ADDED 30/8/2026: the grantor is a person's full name, same shape as the
  /// supervisor column, so it sizes the same way.
  double _calculateAccessGrantorWidth(BuildContext context) {
    double maxLength = 0;
    for (var user in userPermissions) {
      String grantor = _getAccessGrantor(user);
      if (grantor.isNotEmpty && grantor != '-') {
        maxLength = maxLength > grantor.length ? maxLength : grantor.length.toDouble();
      }
    }
    if (maxLength == 0) return context.isPortrait ? 140.w : 160.w;
    double calculatedWidth = ((maxLength * 8.sp) + 40.w) > 200.w ? 200.w : (maxLength * 8.sp) + 40.w;
    double minWidth = context.isPortrait ? 140.w : 140.w;
    return calculatedWidth > minWidth ? calculatedWidth : minWidth;
  }

  /// Both access-date columns render the same "dd MMM yyyy" shape, so they
  /// share one width — Arabic month names are the longer of the two languages.
  double _calculateAccessDateWidth(BuildContext context) {
    return context.isPortrait ? 140.w : 150.w;
  }

  Widget _cell(BuildContext context, Widget child) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
      child: DefaultTextStyle.merge(
        style: _cellStyle(context),
        child: child,
      ),
    );
  }

  Widget _textCell(BuildContext context, String text, {int maxLines = 2}) {
    return _cell(
      context,
      Text(
        text.isEmpty ? '-' : text,
        style: StyleText.fontSize14Weight600.copyWith(
            color: AppColors.text
        ),
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // Phone numbers must always read left-to-right so the leading '+' and the
  // country code stay in front — otherwise RTL/Arabic mode renders them as
  // "962 6637654149+". The value keeps the "+<code> <number>" form.
  Widget _phoneCell(BuildContext context, String text) {
    return _cell(
      context,
      Align(
        alignment:
            _isArabic ? Alignment.centerRight : Alignment.centerLeft,
        child: Directionality(
          textDirection: ui.TextDirection.ltr,
          child: Text(
            text.isEmpty ? '-' : text,
            // The Directionality above already sets the paragraph direction;
            // this states it on the Text itself too, so the number cannot be
            // re-ordered into "6637654149 962+" by an RTL ancestor that a
            // future refactor drops in between.
            textDirection: ui.TextDirection.ltr,
            textAlign: TextAlign.left,
            style: StyleText.fontSize14Weight600
                .copyWith(color: AppColors.text),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  /// One of the stored access dates, in the reader's locale.
  ///
  /// [UserPermissionEntity.startDate] / `endDate` are TEXT in Firestore, in
  /// whatever shape the build that wrote them used — see
  /// [LocalizedDate.parseStored]. An access that has not been revoked has no
  /// end date at all, which is why an unset value renders as "-" rather than
  /// as an error.
  Widget _accessDateCell(BuildContext context, String? storedDate) =>
      _textCell(context, LocalizedDate.ofStored(context, storedDate),
          maxLines: 1);

  Widget _numberCell(BuildContext context, int number) {
    return _cell(
      context,
      Text(
        // `toString()` is always ASCII, so the row numbers stayed Latin in a
        // table whose dates are Arabic-Indic.
        LocalizedNumber.of(context, number),
        maxLines: 1,
        style: _cellStyle(context).copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;

    final headers = <String>[
      _isArabic ? 'رقم' : 'NO',
      _isArabic ? 'رقم الموظف' : 'Employee ID',
      _isArabic ? 'الاسم الأول' : 'First Name',
      _isArabic ? 'اسم العائلة' : 'Last Name',
      _isArabic ? 'البريد الإلكتروني' : 'Email',
      _isArabic ? 'رقم الهاتف المحمول' : 'Mobile Phone',
      _isArabic ? 'اسم القسم' : 'Department Name',
      // SWAPPED 29/8/2026: Title now precedes Supervisor. The job title
      // belongs beside the department it sits in; the supervisor is a
      // different person's name and reads better after both.
      _isArabic ? 'المسمى الوظيفي' : 'Title',
      _isArabic ? 'المشرف' : 'Supervisor',
      // MOVED 30/8/2026: Role Type used to sit second, inside the identity
      // block. It describes the ACCESS, not the person, so it now opens the
      // access block that runs to the end of the row: role, who granted it,
      // and the two dates it runs between.
      _isArabic ? 'نوع الدور' : 'Role Type',
      // ADDED 30/8/2026: the person who granted this access.
      S.of(context).access_grantor,
      // ADDED 29/8/2026: when the access starts and when it ends. Localized
      // through the ARB rather than hardcoded like the columns above, which
      // predate this file's l10n import.
      S.of(context).access_granted,
      S.of(context).access_revoked,
    ];

    final columnWidths = <int, TableColumnWidth>{
      0: FixedColumnWidth(_calculateNoWidth(context)),
      1: FixedColumnWidth(_calculateEmployeeIdWidth(context)),
      2: FixedColumnWidth(_calculateFirstNameWidth(context)),
      3: FixedColumnWidth(_calculateLastNameWidth(context)),
      4: FixedColumnWidth(_calculateEmailWidth(context)),
      5: FixedColumnWidth(_calculateMobilePhoneWidth(context)),
      6: FixedColumnWidth(_calculateDepartmentWidth(context)),
      7: FixedColumnWidth(_calculateTitleWidth(context)),
      8: FixedColumnWidth(_calculateSupervisorWidth(context)),
      9: FixedColumnWidth(_calculateRoleTypeWidth(context)),
      10: FixedColumnWidth(_calculateAccessGrantorWidth(context)),
      11: FixedColumnWidth(_calculateAccessDateWidth(context)),
      12: FixedColumnWidth(_calculateAccessDateWidth(context)),
    };

    return Directionality(
      textDirection: _isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.sp),
          child: Table(
            border: TableBorder.all(
              color: AppColors.transparent,
              borderRadius: BorderRadius.circular(10.sp),
            ),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: columnWidths,
            children: [
              // Header Row
              TableRow(
                decoration: BoxDecoration(
                  color: AppColors.blackShadow
                ),
                children: headers.map((name) =>
                    Padding(
                      padding: EdgeInsets.all(10.sp),
                      child: Text(
                        name,
                        style: _headerStyle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                      ),
                    ),
                ).toList(),
              ),

              // Data Rows
              ...List.generate(userPermissions.length, (index) {
                final user = userPermissions[index];
                final isEven = index.isEven;
                final rowColor = lightMode
                    ? (isEven ? AppColors.evenRowColor : AppColors.white)
                    : (isEven ? AppColors.oddRowColor : AppColors.black);

                final employee = _getEmployee(user.employeeId);
                final roleName = _getRoleName(user, context);
                final firstName = _getFirstName(employee, context);
                final lastName = _getLastName(employee, context);
                final email = _getEmail(employee);
                final mobilePhone = _getMobilePhone(employee);
                final departmentName = _getDepartment(employee, context);
                final supervisor = _getSupervisor(employee, context);
                final title = _getTitle(employee, context);
                final accessGrantor = _getAccessGrantor(user);

                return TableRow(
                  decoration: BoxDecoration(color: rowColor),
                  children: [
                    _numberCell(context, index + 1),
                    _textCell(context, user.employeeId, maxLines: 1),
                    _textCell(context, FormatHelper.capitalize(firstName)),
                    _textCell(context, FormatHelper.capitalize(lastName)),
                    _textCell(context, email, maxLines: 1),
                    _phoneCell(context, mobilePhone),
                    _textCell(context, FormatHelper.capitalize(departmentName)),
                    _textCell(context, FormatHelper.capitalize(title)),
                    _textCell(context, FormatHelper.capitalize(supervisor)),
                    _textCell(context, FormatHelper.capitalize(roleName)),
                    _textCell(context, FormatHelper.capitalize(accessGrantor)),
                    _accessDateCell(context, user.startDate),
                    _accessDateCell(context, user.endDate),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}