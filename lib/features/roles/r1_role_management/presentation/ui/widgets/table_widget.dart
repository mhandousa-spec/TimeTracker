/// Module: roles / r1_role_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: table_widget.dart
/// Purpose: Declares `RoleTableView`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/knowledge_hub_module/core/theming/new_theme.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:knowticed_plus/features/roles/r1_role_management/data/models/role_model.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/modules_cubit.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/ui/widgets/permission_label.dart';
import 'package:knowticed_plus/generated/l10n.dart';
class RoleTableView extends StatelessWidget {
  final List<RoleHistoryModel> roles;
  final String locale;

  const RoleTableView({
    Key? key,
    required this.roles,
    required this.locale,
  }) : super(key: key);

  bool get _isArabic => locale.toLowerCase().startsWith('ar');

  TextStyle get _headerStyle =>
      StyleText.fontSize14Weight500.copyWith(color: AppColors.white);

  TextStyle _cellStyle(BuildContext context) {
    return StyleText.fontSize12Weight500;
  }

  // ── Column widths ──────────────────────────────────────────────────────────

  double _calculateNoWidth(BuildContext context) => 60.w;

  double _calculateRoleNameWidth(BuildContext context) {
    double maxLength = 0;
    for (var role in roles) {
      final roleName = role.currentRoleName;
      if (roleName.isNotEmpty) {
        maxLength = math.max(maxLength, roleName.length.toDouble());
      }
    }
    if (maxLength == 0) return 150.w;
    double calculatedWidth = math.min((maxLength * 10.sp) + 40.w, 200.w);
    return math.max(calculatedWidth, 150.w);
  }

  double _calculateRoleDescriptionWidth(BuildContext context) => 250.w;

  double _calculateModulesWidth(BuildContext context) => 150.w;

  double _calculateSwitchesWidth(BuildContext context) => 300.w;

  double _calculateStatusWidth(BuildContext context) => 100.w;

  double _calculateCreatedByWidth(BuildContext context) => 260.w;

  // ── Module name (AR/EN) ────────────────────────────────────────────────────

  String _getModuleName(BuildContext context, Modules module) {
    switch (module) {
      case Modules.employees:    return S.of(context).employees;
      case Modules.services:     return S.of(context).services;
      case Modules.tasks:        return S.of(context).tasks;
      case Modules.todo:         return S.of(context).todo;
      case Modules.events:       return S.of(context).events;
      case Modules.notes:        return S.of(context).notes;
      case Modules.requests:     return S.of(context).requests;
      case Modules.knowledgeHub: return S.of(context).knowledge_hub;
      case Modules.qiyas:        return S.of(context).qiyas;
      case Modules.grc:          return S.of(context).grc;
      case Modules.tracking:     return S.of(context).tracking;
      case Modules.inventory:    return S.of(context).inventory;
      case Modules.messages:     return S.of(context).messages;
      case Modules.database:     return S.of(context).database_builder;
      case Modules.formBuilder:  return S.of(context).services_app;
      case Modules.roles:        return S.of(context).roles;
      case Modules.settings:     return S.of(context).settings;
      case Modules.home:         return S.of(context).home;
      case Modules.timeTracker:  return S.of(context).timeTracker; // ADDED 8/10/2026
      case Modules.notification: return S.of(context).notifications;
      default:                   return module.name;
    }
  }

  // ── Module enum from string ────────────────────────────────────────────────

  Modules? _getModuleEnum(String moduleName) {
    switch (moduleName.toLowerCase().trim()) {
      case 'employees':                  return Modules.employees;
      case 'services':                   return Modules.services;
      case 'tasks':                      return Modules.tasks;
      case 'todo':                       return Modules.todo;
      case 'events':                     return Modules.events;
      case 'notes':                      return Modules.notes;
      case 'requests':                   return Modules.requests;
      case 'knowledge_hub':
      case 'knowledgehub':               return Modules.knowledgeHub;
      case 'qiyas':                      return Modules.qiyas;
      case 'grc':                        return Modules.grc;
      case 'tracking':                   return Modules.tracking;
      case 'inventory':                  return Modules.inventory;
      case 'messages':                   return Modules.messages;
      case 'database_builder':
      case 'database':                   return Modules.database;
      case 'services_app':
      case 'formbuilder':                return Modules.formBuilder;
      case 'roles':                      return Modules.roles;
      case 'settings':                   return Modules.settings;
      case 'home':                       return Modules.home;
      case 'notification':
      case 'notifications':              return Modules.notification;
      case 'crm':                        return Modules.crm;
      case 'time_tracker':               return Modules.timeTracker; // ADDED 8/10/2026
      default:
        return null;
    }
  }

  // ── Expand roles by modules ────────────────────────────────────────────────

  List<Map<String, dynamic>> _expandRolesByModules(RoleHistoryModel role) {
    List<Map<String, dynamic>> expandedRows = [];
    List<String> activeModuleStrings =
    ModulesCubit().getRoleActiveModules(role);

    if (activeModuleStrings.isEmpty) {
      expandedRows.add({
        'role': role,
        'moduleString': null,
        'module': null,
        'permissionsCount': 0,
        'activeSwitches': <String>[],
      });
    } else {
      for (String moduleString in activeModuleStrings) {
        Modules? moduleEnum = _getModuleEnum(moduleString);
        int permissionCount = _getModulePermissionCount(moduleString);
        expandedRows.add({
          'role': role,
          'moduleString': moduleString,
          'module': moduleEnum,
          'permissionsCount': permissionCount,
        });
      }
    }
    return expandedRows;
  }

  int _getModulePermissionCount(String moduleString) {
    Map<String, bool> defaultPermissions =
    ModulesCubit().getDefaultPermissionsForModule(moduleString);
    return defaultPermissions.length;
  }

  // ── Permission name (AR/EN via .tr) ───────────────────────────────────────

  String _formatPermissionName(String permissionKey) {
    return permissionKey
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty
        ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
        : '')
        .join(' ')
        ; // ← .tr resolves AR/EN from GetX translations
  }

  // ── Created By: resolve full name from employee controller ────────────────

  // MOVED 12/8/2026 -> RoleCubit.resolveCreatedByName / _nameFromEmail.
  // The lookup ran inside this widget behind `try { ... } catch (_) {}` and
  // read the locale from `Get.locale` — a swallowed error plus a GetX
  // dependency in the UI layer (§11.2/§11.5, GetX standing rule).


  // ── Cell helpers ───────────────────────────────────────────────────────────

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
        FormatHelper.capitalize(text.isEmpty ? '-' : text),
        maxLines: maxLines,
        style: StyleText.fontSize12Weight600.copyWith(color: AppColors.text),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // MOVED 12/8/2026 -> RoleCubit.formatRoleDate. Date formatting can throw when
  // locale data is missing; §11.2 forbids handling that in a widget.

  // ── Switches cell ──────────────────────────────────────────────────────────

  Widget _switchesCell(
      BuildContext context, RoleHistoryModel role, String? moduleString) {
    if (moduleString == null) {
      return _cell(context, Text('-'));
    }

    return _cell(
      context,
      FutureBuilder<List<String>>(
        future: roleCubit.loadActivePermissionsFor(
          roleId: role.roleId,
          moduleName: moduleString,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              height: 20.sp,
              width: 20.sp,
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }

          if (snapshot.hasError) {
            return Text(
              S.of(context).error_loading,
              style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.red,
                fontStyle: FontStyle.italic,
              ),
            );
          }

          List<String> activeSwitches = snapshot.data ?? [];

          if (activeSwitches.isEmpty) {
            return Text(
              S.of(context).no_specific_permissions,
              style: StyleText.fontSize12Weight400.copyWith(
                fontStyle: FontStyle.italic,
              ),
            );
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              spacing: 6.sp,
              runSpacing: 6.sp,
              children: activeSwitches.map((permission) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.sp,
                    vertical: 4.sp,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.grey.withOpacity(.3),
                    borderRadius: BorderRadius.circular(4.sp),
                  ),
                  child: Text(
                    // TRANSLATED 29/8/2026: chips showed the raw storage key
                    // in English; resolve through PermissionLabel like the
                    // card view so they follow the locale.
                    PermissionLabel.fromStorageKey(context, permission),
                    style: StyleText.fontSize12Weight400,
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  // MOVED 12/8/2026 -> RoleCubit.loadActivePermissionsFor. This widget used to
  // construct its own RoleRepository and run the read behind a try/catch,
  // bypassing the cubit entirely (§11.2/§16).

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final lightMode = Theme.of(context).brightness == Brightness.light;

    final headers = <String>[
      s.number,
      s.role_name,
      s.role_name_ar,
      s.role_description,
      s.role_description_ar,
      s.status,
      s.created_by,
      s.created_at,
      s.modules,
      s.active_permissions,
    ];

    final columnWidths = <int, TableColumnWidth>{
      0: FixedColumnWidth(_calculateNoWidth(context)),
      1: FixedColumnWidth(_calculateRoleNameWidth(context)),
      2: FixedColumnWidth(_calculateRoleNameWidth(context)),
      3: FixedColumnWidth(_calculateRoleDescriptionWidth(context)),
      4: FixedColumnWidth(_calculateRoleDescriptionWidth(context)),
      5: FixedColumnWidth(_calculateStatusWidth(context)),
      6: FixedColumnWidth(_calculateCreatedByWidth(context)),
      7: FixedColumnWidth(_calculateStatusWidth(context)),
      8: FixedColumnWidth(_calculateModulesWidth(context)),
      9: FixedColumnWidth(_calculateSwitchesWidth(context)),
    };

    // Expand roles by modules
    List<Map<String, dynamic>> expandedData = [];
    int rowNumber = 1;

    for (var role in roles) {
      // Skip master admin role
      final roleName = role.currentRoleName.toLowerCase().trim();
      final roleNameAr = role.currentRoleNameAr.toLowerCase().trim();
      final roleId = role.roleId.toLowerCase();

      if (roleName == 'master admin' ||
          roleName == 'masteradmin' ||
          roleName == 'admin' ||
          roleNameAr == 'مسؤول رئيسي' ||
          roleNameAr == 'مدير النظام' ||
          roleId == 'master_admin' ||
          roleId == 'masteradmin') {
        continue;
      }

      var roleRows = _expandRolesByModules(role);
      for (int i = 0; i < roleRows.length; i++) {
        expandedData.add({
          ...roleRows[i],
          'rowNumber': rowNumber,
          'isFirstRow': i == 0,
          'rowSpan': roleRows.length,
        });
        rowNumber++;
      }
    }

    return Directionality(
      textDirection:
      _isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.sp),
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: columnWidths,
            children: [
              // ── Header row ───────────────────────────────────────────────
              TableRow(
                decoration: BoxDecoration(
                  color: AppColors.blackShadow
                ),
                children: headers
                    .map((name) => Padding(
                  padding: EdgeInsets.all(10.sp),
                  child: Text(
                    name,
                    style: _headerStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                  ),
                ))
                    .toList(),
              ),

              // ── Data rows ─────────────────────────────────────────────────
              ...List.generate(expandedData.length, (index) {
                final data = expandedData[index];
                final role = data['role'] as RoleHistoryModel;
                final moduleString = data['moduleString'] as String?;
                final module = data['module'] as Modules?;
                final rowNumber = data['rowNumber'] as int;

                final isEven = rowNumber.isEven;
                // Was four raw/inline colours (§12). The theme already
                // publishes alternating table-row tokens for both modes.
                final rowColor = isEven
                    ? AppColors.evenRowColor
                    : AppColors.oddRowColor;

                return TableRow(
                  decoration: BoxDecoration(color: rowColor),
                  children: [
                    // No
                    _textCell(context, rowNumber.toString(), maxLines: 1),

                    // Role Name EN
                    _textCell(context, role.currentRoleName, maxLines: 2),

                    // Role Name AR
                    _textCell(
                      context,
                      role.currentRoleNameAr.isNotEmpty
                          ? role.currentRoleNameAr
                          : '-',
                      maxLines: 2,
                    ),

                    // Role Description EN
                    _textCell(
                      context,
                      role.currentRoleDescription.isNotEmpty
                          ? role.currentRoleDescription
                          : '-',
                      maxLines: 3,
                    ),

                    // Role Description AR
                    _textCell(
                      context,
                      role.currentRoleDescriptionAr.isNotEmpty
                          ? role.currentRoleDescriptionAr
                          : '-',
                      maxLines: 3,
                    ),

                    // Status — localized via .tr on the enum name
                    _cell(
                      context,
                      Text(
                        // TRANSLATED 29/8/2026: was the raw Dart enum name
                        // (`FormatHelper.capitalize(currentStatus.name)`), so
                        // an Arabic user saw "Active"/"Draft" in English. Now
                        // the ARB-backed localized name, matching the card view.
                        role.currentStatus.getLocalizedName(context),
                        style:
                        StyleText.fontSize12Weight400.copyWith(
                          color: role.currentStatus.color,
                        ),
                      ),
                    ),

                    // Created By — resolved full name (AR/EN)
                    _textCell(
                      context,
                      roleCubit.resolveCreatedByName(
                        role.currentCreatedBy,
                        isArabic: _isArabic,
                      ),
                      maxLines: 2,
                    ),

                    // Created At
                    _textCell(
                      context,
                      roleCubit.formatRoleDate(
                        role.currentCreatedAt.toDate(),
                        isArabic: _isArabic,
                      ),
                      maxLines: 1,
                    ),

                    // Module — localized via S.of(context)
                    _textCell(
                      context,
                      module != null
                          ? _getModuleName(context, module)
                          : '-',
                      maxLines: 1,
                    ),

                    // Active Permissions — localized chips via .tr
                    _switchesCell(context, role, moduleString),
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