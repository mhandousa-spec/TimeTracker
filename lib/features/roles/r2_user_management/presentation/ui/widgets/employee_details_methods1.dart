/// Module: roles / r2_user_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: employee_details_methods1.dart
/// Purpose: Declares `EmployeeDetailsMethods1`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 25/8/2026 - Module count renders in the reader's numerals.

part of '../pages/employee_details.dart';

extension EmployeeDetailsMethods1 on _RoleEmployeeDetailsPageState {
  Future<void> _initializePage() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final roleCubit = context.read<RoleCubit>();
      if (roleCubit.roles.isEmpty) {
        await roleCubit.getUnDeletedRoles();
      }
      await _loadPermissions();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
  void _loadEmployeeData() {
    try {
      currentEmployeeEntity =
          employeeController.allEmployeesEntities?.firstWhereOrNull(
                (employee) => employee.id == widget.userPermission.employeeId,
          );
      if (currentEmployeeEntity != null && mounted) setState(() {});
    } catch (e, stackTrace) {
      // Was an empty `catch {}` — the header silently rendered without the
      // employee's details (§11.5).
      debugPrint('_loadEmployeeData failed: $e\n$stackTrace');
    }
  }
  Future<void> _loadPermissions() async {
    if (_permissionsLoaded) return;

    final roleName = widget.userPermission.accessName;

    if (roleName == null || roleName.isEmpty) {
      setState(() {
        _permissionsLoaded = true;
        _isLoading = false;
      });
      return;
    }

    try {
      final roleCubit = context.read<RoleCubit>();

      if (roleCubit.roles.isEmpty) {
        await roleCubit.getUnDeletedRoles();
      }

      if (roleCubit.roles.isEmpty) {
        setState(() {
          _errorMessage = 'No roles found. Please try again.';
          _isLoading = false;
        });
        return;
      }

      final role = roleCubit.roles.firstWhereOrNull(
            (r) => r.roleId == roleName || r.currentRoleName == roleName,
      );

      if (role == null) {
        setState(() {
          _errorMessage = 'Role "$roleName" not found';
          _isLoading = false;
        });
        return;
      }

      activeModuleStrings = role.currentSelectedModules;

      var result = await roleCubit.roleRepository.getAllRolePermissions(
        roleId: role.roleId,
        selectedModules: activeModuleStrings,
      );

      if (result.isRight()) {
        Map<String, Map<String, dynamic>> allPermissions =
        result.getOrElse(() => {});

        for (String moduleName in activeModuleStrings) {
          List<String> activePermissions = [];

          if (allPermissions.containsKey(moduleName)) {
            Map<String, dynamic> moduleData = allPermissions[moduleName]!;

            moduleData.forEach((key, value) {
              if (key != 'Role_Id' && key != 'timestamps') {
                bool isActive = false;
                if (value is List && value.isNotEmpty) {
                  var lastValue = value.last;
                  isActive =
                  (lastValue == true || lastValue == 1 || lastValue == '1');
                } else if (value is bool) {
                  isActive = value;
                }
                if (isActive) activePermissions.add(key);
              }
            });
          }

          _modulePermissions[moduleName] = activePermissions;
        }
      }

      setState(() {
        _permissionsLoaded = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
  // REMOVED 25/8/2026: `_formatPermissionName` — it title-cased the raw
  // Firestore permission key for display, which is what kept every permission
  // chip on this page English. Its two call sites in
  // `employee_details_methods3.dart` now go through `PermissionLabel.of`,
  // which translates the same identifiers; nothing else referenced it.
  // REMOVED 12/8/2026: dead code (analyzer: unused member, 0 call sites).
  Modules? _getModuleEnum(String moduleName) {
    switch (moduleName.toLowerCase().trim()) {
      case 'employees':         return Modules.employees;
      case 'services':          return Modules.services;
      case 'tasks':             return Modules.tasks;
      case 'todo':              return Modules.todo;
      case 'events':            return Modules.events;
      case 'notes':             return Modules.notes;
      case 'requests':          return Modules.requests;
      case 'knowledge_hub':
      case 'knowledgehub':      return Modules.knowledgeHub;
      case 'qiyas':             return Modules.qiyas;
      case 'grc':               return Modules.grc;
      case 'tracking':          return Modules.tracking;
      case 'inventory':         return Modules.inventory;
      case 'messages':          return Modules.messages;
      case 'database_builder':
      case 'database':          return Modules.database;
      case 'services_app':
      case 'formbuilder':       return Modules.formBuilder;
      case 'roles':             return Modules.roles;
      case 'settings':          return Modules.settings;
      case 'home':              return Modules.home;
      case 'notification':
      case 'notifications':     return Modules.notification;
      case 'crm':               return Modules.crm;
      default:                  return null;
    }
  }
  String _getSupervisorName() {
    if (currentEmployeeEntity?.supervisor == null ||
        currentEmployeeEntity!.supervisor!.isEmpty) return '-';
    return employeeController
        .getEmployeeName(currentEmployeeEntity!.supervisor!);
  }
  // REMOVED 12/8/2026: dead code (analyzer: unused member, 0 call sites).
  /// The "total modules" figure for this user's role, as display text.
  ///
  /// LOCALIZED 25/8/2026: this returned `length.toString()`, i.e. always Latin
  /// figures, so the Arabic card read "إجمالي الوحدات: 3". The count now uses
  /// the reader's numerals ("٣"). It is display text and nothing parses it.
  String _getTotalModules() {
    return _localizedCount(_totalModulesCount());
  }

  int _totalModulesCount() {
    if (widget.userPermission.accessName == null ||
        widget.userPermission.accessName!.isEmpty) return 0;
    try {
      final roleCubit = context.read<RoleCubit>();
      final role = roleCubit.roles.firstWhereOrNull((r) =>
      r.roleId == widget.userPermission.accessName ||
          r.currentRoleName == widget.userPermission.accessName);
      if (role != null && role.currentSelectedModules.isNotEmpty) {
        return role.currentSelectedModules.length;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// A number rendered in the active locale's numerals.
  String _localizedCount(int value) => LocalizedDigits.apply(
        value.toString(),
        Localizations.localeOf(context).languageCode,
      );
  Future<bool> _removeUserAccess({required String employeeId}) async {
    try {
      final userMgmtCubit = context.read<UserManagementAccessCubit>();
      final currentUserEmail =
      AppControllers.employee.employeeEntity!.email!;

      final dynamic result =
      await userMgmtCubit.repository.deleteEmployeePermission(
        employeeId: employeeId,
        currentUserEmail: currentUserEmail,
      );

      final resultStr = result.toString();
      if (resultStr.startsWith('Left(')) return false;
      return true;
    } catch (e) {
      return false;
    }
  }
  // REMOVED 12/8/2026: dead code (analyzer: unused member, 0 call sites).
}
