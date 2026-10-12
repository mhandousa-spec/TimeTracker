/// Module: roles / r1_role_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: module_permissions_widget.dart
/// Purpose: Read-only, expandable summary of the permissions granted to the
///          selected role, grouped by module.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Renamed from "module select.dart" (a literal space in a
///          filename is an auto-reject, §6.2/§20) and the Firestore read moved
///          out of the widget into RoleCubit (§16).
/// Updated: 29/8/2026 - An expanded module now RENDERS module_switches_builder
///          in read-only mode instead of a hand-packed row of chips. Not a
///          copy of that layout — the widget itself, so the details screen and
///          the edit screen cannot drift apart: same sections, same two-column
///          split, same master rows with their children nested underneath.
///          The chips only ever showed the permissions that were ON, so
///          "granted" and "not granted" were indistinguishable from "not part
///          of this module"; the switches show every permission with its real
///          state. The module header row keeps its original design, and the
///          switches are read-only — editing belongs behind the تعديل button.

import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/ui/widgets/module_switches_builder.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/core/helper/inventory_module/core/svg_custom.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/core/new_theme.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
class ModulePermissionsWidget extends StatefulWidget {
  const ModulePermissionsWidget({super.key});

  @override
  State<ModulePermissionsWidget> createState() => _ModulePermissionsWidgetState();
}

class _ModulePermissionsWidgetState extends State<ModulePermissionsWidget> {
  Map<String, bool> expandedModules = {};
  late RoleCubit controller;
  bool isLoading = true;
  Map<String, Map<String, bool>> allModulePermissions = {};

  @override
  void initState() {
    super.initState();
    controller = context.read<RoleCubit>();
    _loadPermissions();
  }

  /// Loads the permission snapshot for the selected role.
  ///
  /// The Firestore query and the response reshaping moved to
  /// `RoleCubit.modulePermissionsSnapshotFor` — this widget used to reach
  /// through the cubit into `roleRepository` and do the work itself (§16).
  Future<void> _loadPermissions() async {
    final role = controller.selectedRole;
    if (role == null) return;

    setState(() {
      isLoading = true;
    });

    final snapshot = await controller.modulePermissionsSnapshotFor(role);
    if (!mounted) return;

    setState(() {
      allModulePermissions = snapshot;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (controller.selectedRole == null) {
      return SizedBox.shrink();
    }

    // Canonicalised to match the snapshot's keys: `modulePermissionsSnapshotFor`
    // keys by [RoleCubit.canonicalModuleName], so a role storing the older
    // spelling of a module (`form_builder`) looked up an empty bucket here and
    // rendered as a module with no permissions at all.
    List<String> moduleStrings = controller.selectedRole!.currentSelectedModules
        .map(RoleCubit.canonicalModuleName)
        .toSet()
        .toList();

    return Column(
      spacing: 8.sp,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).permissionControls,
          style: StyleText.fontSize16Weight600,
        ),
        if (isLoading)
          Center(
            child: Padding(
              padding: EdgeInsets.all(20.sp),
              child: CircleProgressMaster(),
            ),
          )
        else
          Column(
            spacing: 10.sp,
            children: [
              for (String moduleName in moduleStrings)
                _buildModuleSection(moduleName),
              SizedBox(height: 10.h,)
            ],
          ),
      ],
    );
  }

  Widget _buildModuleSection(String moduleName) {
    bool isExpanded = expandedModules[moduleName] ?? false;
    Map<String, bool> permissions = allModulePermissions[moduleName] ?? {};

    String displayName = _getModuleDisplayName(moduleName);

    // The switch layout is keyed off the module's enum (its sections and their
    // permissions), so a name with no enum has nothing to draw.
    final List<Modules> moduleEnums = controller.moduleEnumsFor(<String>[moduleName]);

    // A module is expandable when it HAS permissions at all — not only when
    // some are switched on. Under the old chip list an all-off module had
    // nothing to draw, so it was collapsed shut; a switch list has something
    // to say about it.
    final bool hasPermissions = permissions.isNotEmpty && moduleEnums.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(8.sp),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: hasPermissions
                ? () {
              setState(() {
                expandedModules[moduleName] = !isExpanded;
              });
            }
                : null, // ✅ Disabled if no permissions
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 12.sp),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      displayName,
                      style: StyleText.fontSize14Weight500,
                    ),
                  ),
                  // ✅ Only show arrow if there are active permissions
                  if (hasPermissions)
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: CustomSvgImage(
                        assetPath: "assets/icons_assets/main_icons_assets/chevron_down.svg",
                        width: 12.w,
                        height: 15.h,
                        fit: BoxFit.scaleDown,
                        color: AppColors.text
                      ),
                    ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: isExpanded && hasPermissions
                ? Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(15.sp, 0, 15.sp, 15.sp),
              // The edit screen's own widget, reading this screen's saved
              // snapshot and with its switches made read-only. `showHeader` is
              // off because the collapsible bar above is already this module's
              // header.
              child: ModuleSwitchesBuilder(
                module: moduleEnums.first,
                permissions: permissions,
                readOnly: true,
                showHeader: false,
              ),
            )
                : SizedBox.shrink(),
          ),


        ],
      ),
    );
  }

  String _getModuleDisplayName(String moduleName) {
    switch (moduleName.toLowerCase()) {
      case 'services':
        return S.of(context).service;
      case 'todo':
        return S.of(context).toDoListTitle;
      case 'notes':
        return S.of(context).notes;
      case 'knowledge_hub':
        return S.of(context).knowledge_hub;
      case 'notification':
        return S.of(context).notifications;
      case 'qiyas':
      case 'grc':
        return S.of(context).qiyas;
      case 'inventory':
        return S.of(context).inventory;
      case 'messages':
        return S.of(context).messages;
      case 'services_app':
        return S.of(context).services_app;
      case 'roles':
        return S.of(context).roles;
      case 'settings':
        return S.of(context).settings;
      case 'employees':
        return S.of(context).Employees;
      case 'tasks':
        return S.of(context).tasks;
      case 'events':
        return S.of(context).events;
      case 'requests':
        return S.of(context).requests;
      case 'tracking':
        return S.of(context).tracking;
      case 'database_builder':
        return S.of(context).database_builder;
      case 'time_tracker': // ADDED 8/10/2026 — Time Tracker
        return S.of(context).timeTracker;
      default:
        return moduleName.replaceAll('_', ' ').split(' ').map((word) =>
        word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : ''
        ).join(' ');
    }
  }

  // Permission LABELS are no longer resolved here (29/8/2026): the rendering
  // moved wholesale to module_switches_builder.dart, which resolves them
  // through PermissionLabel exactly as this file used to.
}