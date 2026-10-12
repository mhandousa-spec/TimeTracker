/// Module: roles / r1_role_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: role_overview.dart
/// Purpose: Declares `RoleOverview`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 25/8/2026 - Role status now renders through RoleStatus.getLocalizedName
///                      instead of the raw enum name (Arabic support).
/// Updated: 29/8/2026 - The creation date and the module count on a role card
///                      now render in the locale's own numerals; both were
///                      Latin-digit on an Arabic screen.

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/ui/widgets/permission_label.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:ui' as ui;
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/core/helper/data_grc_module/core/extensions/extensions.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/inventory_module/core/circle_progress.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/modules_cubit.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/role_cubit.dart';

import 'package:knowticed_plus/core/helper/main_helper/employee_helper.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_date.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/custom/75-custom_title_value_widget.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/models/role_model.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/ui/pages/adding_new_role.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/ui/pages/role_details_page.dart';
class RoleOverview extends StatefulWidget {
  RoleOverview({required this.role, super.key});

  final RoleHistoryModel role;

  @override
  State<RoleOverview> createState() => _RoleOverviewState();
}

class _RoleOverviewState extends State<RoleOverview> {
  late List<String> activeModuleStrings;
  late List<Modules> activeModules;
  late RoleCubit roleCubit;
  late ModulesCubit modulesCubit;
  bool _permissionsLoaded = false;
  Map<String, List<String>> _modulePermissions = {};

  @override
  void initState() {
    super.initState();
  }

  /// ✅ CHECK IF THIS ROLE IS MASTER ADMIN
  bool _isMasterAdminRole() {
    String roleName = widget.role.currentRoleName.toLowerCase().trim();
    String roleNameAr = widget.role.currentRoleNameAr.toLowerCase().trim();

    return roleName == 'master admin' ||
        roleName == 'masteradmin' ||
        roleName == 'admin' ||
        roleNameAr == 'مسؤول رئيسي' ||
        roleNameAr == 'مدير النظام' ||
        widget.role.roleId.toLowerCase() == 'master_admin' ||
        widget.role.roleId.toLowerCase() == 'masteradmin';
  }

  // REMOVED 12/8/2026: `_loadPermissions()` — dead code, never invoked;
  // permissions for the overview arrive via RoleCubit state.

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // ✅ IF MASTER ADMIN ROLE - HIDE THE ENTIRE CONTAINER
    if (_isMasterAdminRole()) {
      return SizedBox.shrink();
    }

    // ✅ GET PERMISSIONS FROM CACHE INSTEAD OF LOADING
    roleCubit = context.read<RoleCubit>();
    modulesCubit = ModulesCubit();
    activeModuleStrings = modulesCubit.getRoleActiveModules(widget.role);

    // ✅ FIX 2: Get cached permissions (raw keys stored in cache)
    var cachedPermissions = roleCubit.getRolePermissions(widget.role.roleId);
    if (cachedPermissions != null) {
      _modulePermissions = cachedPermissions;
      _permissionsLoaded = true;
    }

    // Convert to Modules enums for UI display
    activeModules = _convertModuleStringsToEnums(activeModuleStrings);

    return InkWell(
      onTap: () async {
        // AWAITED 29/8/2026: `selectRole` loads the role's module permissions
        // from Firestore. Firing it and navigating in the same frame opened the
        // next page against a cubit that had a role but no permissions yet —
        // for a resumed DRAFT that is the page with no switches on it. The tap
        // now waits for the load, so whatever opens next reads a complete cubit.
        final RoleCubit roleCubit = context.read<RoleCubit>();
        await roleCubit.selectRole(widget.role);

        if (!context.mounted) return;

        if (widget.role.currentStatus.name.toLowerCase() == 'draft') {
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return BlocProvider<RoleCubit>.value(
              value: roleCubit,
              child: AddingNewRole(),
            );
          }));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return BlocProvider<RoleCubit>.value(
              value: roleCubit,
              child: RoleDetailsPage(),
            );
          }));
        }
      },
      child: Container(
        padding: EdgeInsets.all(15.sp),
        decoration: BoxDecoration(
          color: AppColors.field,
          borderRadius: BorderRadius.circular(8.sp),
        ),
        child: Column(
          spacing: 5.sp,
          children: [
            Row(
              children: [
                roleImage(),
                SizedBox(width: 10.sp),
                Expanded(
                  child: SizedBox(
                    height: 60.sp,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isArabic &&
                                        widget.role.currentRoleNameAr
                                            .isNotEmpty
                                        ? widget.role.currentRoleNameAr
                                        : FormatHelper.capitalize(
                                        widget.role.currentRoleName),
                                    style: StyleText.fontSize14Weight500
                                        .copyWith(
                                        color: AppColors.text, height: 1.2),
                                    overflow: TextOverflow.ellipsis,
                                    textDirection: isArabic
                                        ? ui.TextDirection.rtl
                                        : ui.TextDirection.ltr,
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  "${S.of(context).status}: ",
                                  style: StyleText.fontSize12Weight400.copyWith(
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                                Text(
                                  // LOCALIZED 25/8/2026: was
                                  // `FormatHelper.capitalize(currentStatus.name)`
                                  // — the raw Dart enum name, so an Arabic user
                                  // read "Active"/"Draft" in English next to an
                                  // otherwise fully translated card. [RoleStatus]
                                  // already carries its own ARB-backed name, the
                                  // same one the status filter chips use.
                                  widget.role.currentStatus
                                      .getLocalizedName(context),
                                  style: StyleText.fontSize10Weight500.copyWith(
                                      color: widget.role.currentStatus.color),
                                )
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 5.sp),
                        CustomTitleValueWidget(
                            title: "${S.of(context).createdBy}: ",
                            value: FormatHelper.capitalize(
                                _getCreatorName(context))),
                        // SizedBox(height: 22.sp),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: CustomTitleValueWidget(
                                    title: "${S.of(context).totalModules}: ",
                                    // `toString()` is always ASCII — the count
                                    // stayed "14" beside an Arabic-Indic date.
                                    value: LocalizedNumber.of(
                                        context, activeModules.length)),
                              ),
                              CustomTitleValueWidget(
                                title: "${S.of(context).created_at}: ",
                                // Month name AND numerals follow the locale;
                                // DateFormat('ar') only gives the month name.
                                value: LocalizedDate.of(
                                  context,
                                  widget.role.currentCreatedAt.toDate(),
                                  pattern: 'dd MMMM yyyy',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.sp),
            if (_permissionsLoaded)
              Column(
                spacing: 10.sp,
                children: [
                  for (String moduleString in activeModuleStrings)
                    buildModuleRow(moduleString),
                ],
              )
            else
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.sp),
                  child: CircleProgressMaster()),
          ],
        ),
      ),
    );
  }

  List<Modules> _convertModuleStringsToEnums(List<String> moduleStrings) {
    List<Modules> enums = [];
    for (String moduleName in moduleStrings) {
      Modules? moduleEnum = _getModuleEnum(moduleName);
      if (moduleEnum != null) {
        enums.add(moduleEnum);
      }
    }
    return enums;
  }

  Modules? _getModuleEnum(String moduleName) {
    String normalized =
    moduleName.toLowerCase().trim().replaceAll(' ', '_');

    switch (normalized) {
      case 'employees':
        return Modules.employees;
      case 'services':
        return Modules.services;
      case 'tasks':
        return Modules.tasks;
      case 'todo':
        return Modules.todo;
      case 'events':
        return Modules.events;
      case 'notes':
        return Modules.notes;
      case 'requests':
        return Modules.requests;
      case 'knowledge_hub':
      case 'knowledgehub':
        return Modules.knowledgeHub;
      case 'qiyas':
        return Modules.qiyas;
      case 'grc':
        return Modules.grc;
      case 'tracking':
        return Modules.tracking;
      case 'inventory':
        return Modules.inventory;
      case 'messages':
        return Modules.messages;
      case 'database_builder':
      case 'database':
        return Modules.database;
      case 'services_app':
      case 'formbuilder':
        return Modules.formBuilder;
      case 'roles':
        return Modules.roles;
      case 'settings':
        return Modules.settings;
      case 'home':
        return Modules.home;
      case 'time_tracker': // ADDED 8/10/2026 — Time Tracker
        return Modules.timeTracker;
      default:
        return null;
    }
  }

  /// Resolves the creator's display name.
  ///
  /// The controller lookup (and the `try/catch` it needed, plus its `Get.find`)
  /// moved to `RoleCubit.creatorEmployeeFor` — §11.2 forbids try/catch in
  /// widgets and GetX is banned. This method now only formats.
  String _getCreatorName(BuildContext context) {
    final creator = roleCubit.creatorEmployeeFor(widget.role.currentCreatedBy);
    if (creator == null) return widget.role.currentCreatedBy;

    return EmployeeHelper.getEmployeeLocalizedName(
        employee: creator, context: context);
  }

  Widget roleImage() {
    if (widget.role.currentRoleImage.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Image.network(
          widget.role.currentRoleImage,
          width: 60.sp,
          height: 60.sp,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
                width: 50.sp,
                height: 50.sp,
                color: AppColors.moreLightGrey,
                child: const CircleProgressMaster());
          },
          errorBuilder: (context, error, stackTrace) {
            return _defaultRoleIcon();
          },
        ),
      );
    }
    return _defaultRoleIcon();
  }

  Widget _defaultRoleIcon() {
    return Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8.sp),
        ),
        width: 50.sp,
        height: 50.sp,
        child: CustomSvgImage(assetPath: 
          'assets/icons_assets/roles_assets/roles_people_gear.svg',
          width: 30.sp,
          height: 30.sp,
          color: AppColors.text,
          fit: BoxFit.scaleDown,
        ));
  }

  Widget buildModuleRow(String moduleString) {
    Modules? module = _getModuleEnum(moduleString);
    if (module == null) return SizedBox.shrink();

    // ✅ FIX 3: Format at render time so .tr uses current locale (Arabic/English)
    List<String> activeSwitches =
    (_modulePermissions[moduleString] ?? [])
        .map((key) => PermissionLabel.fromStorageKey(context, key))
        .toList();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.sp),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.sp),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 32.sp,
            alignment: Alignment.center,
            width: 20.sp,
            child: CustomSvgImage(assetPath: 
              module.iconPathRole,
              width: 20.sp,
              height: 20.sp,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 10.sp),
          Expanded(
            child: activeSwitches.isEmpty
                ? SizedBox()
                : LayoutBuilder(
              builder: (context, constraints) {
                return _buildPermissionChips(
                  activeSwitches,
                  constraints.maxWidth,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionChips(List<String> permissions, double maxWidth) {
    List<Widget> firstRowChips = [];
    List<Widget> secondRowChips = [];

    double firstRowWidth = 0;
    double secondRowWidth = 0;
    final double spacing = 8.w;
    bool firstRowFull = false;

    for (int i = 0; i < permissions.length; i++) {
      final chipWidth = _calculateChipWidth(permissions[i]);

      if (!firstRowFull &&
          firstRowWidth + (firstRowChips.isEmpty ? 0 : spacing) + chipWidth <=
              maxWidth) {
        if (firstRowChips.isNotEmpty) {
          firstRowChips.add(SizedBox(width: spacing));
          firstRowWidth += spacing;
        }
        firstRowChips.add(_buildChip(permissions[i]));
        firstRowWidth += chipWidth;
      } else if (!firstRowFull) {
        firstRowFull = true;
        secondRowChips.add(_buildChip(permissions[i]));
        secondRowWidth += chipWidth;
      } else {
        if (secondRowWidth + spacing + chipWidth <= maxWidth) {
          if (secondRowChips.isNotEmpty) {
            secondRowChips.add(SizedBox(width: spacing));
            secondRowWidth += spacing;
          }
          secondRowChips.add(_buildChip(permissions[i]));
          secondRowWidth += chipWidth;
        } else {
          // overflow chip goes to scrollable second row anyway
          if (secondRowChips.isNotEmpty) {
            secondRowChips.add(SizedBox(width: spacing));
          }
          secondRowChips.add(_buildChip(permissions[i]));
        }
      }
    }

    return SizedBox(
      width: maxWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: firstRowChips,
            ),
          ),
          if (secondRowChips.isNotEmpty) ...[
            SizedBox(height: 8.w),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: secondRowChips,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChip(String text) {
    return Container(
      height: 32.sp,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(4.sp),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 5.sp),
      alignment: Alignment.center,
      child: Text(
          text,
          style: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.text,
          )),
    );
  }

  double _calculateChipWidth(String text) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: StyleText.fontSize12Weight400,
      ),
      textDirection: ui.TextDirection.ltr,
      maxLines: 1,
    );

    textPainter.layout();
    return textPainter.width + 20.sp + 4;
  }

  /// ✅ Format permission name at render time so .tr resolves current locale
  /// FIXED 13/8/2026: this title-cased the raw Firestore key
  /// (`View_Documents` -> `View Documents`) and rendered it, so every chip on
  /// this card stayed English regardless of locale. It now resolves through
  /// [PermissionLabel], which owns the identifier -> localized-label table.
  /// The English identifier is still the fallback for a permission the table
  /// does not know, so a new key shows its name rather than vanishing.
  // _formatPermissionName removed — superseded by PermissionLabel.fromStorageKey.
}