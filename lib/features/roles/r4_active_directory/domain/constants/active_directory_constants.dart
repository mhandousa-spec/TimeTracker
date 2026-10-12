/// Module: roles / r4_active_directory / domain / constants
///
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/enums/employee_data.dart';

/// ********************** FILE INFO ********************///
/// FILE NAME: active_directory_constants.dart
/// Purpose: contains all constants of active directory.
/// Author: Mohamed Elrashidy
/// created at: 15/12/2024
///
/// Layer: domain (moved here from r4_active_directory/utils).
///
/// These are business rules, not data-layer literals: [optionalItems] and
/// [uniqueItems] express which employee fields may be blank / must be unique,
/// and [defaultAccessTypeModules] is a default-policy list — all stated purely
/// in terms of the domain enums [EmployeeDataItems] and [Modules], with no
/// Firestore keys, serialization or transport concerns. The file imports only
/// domain enums, so nothing here points at the data layer.
///
/// Contrast with services_management_module/data/constants, which holds literal
/// external column names (spreadsheet headers) and therefore belongs in data.
///
/// [validEmployeesData] / [invalidEmployeesData] are the in-memory bucket keys
/// the CSV pipeline uses to hand parsed rows to the controller — they are never
/// persisted.

class ActiveDirectoryConstants {
  static const String validEmployeesData = 'validEmployeesData';
  static const String invalidEmployeesData = 'invalidEmployeesData';

  static const List<EmployeeDataItems> optionalItems = [
    EmployeeDataItems.gender,
    EmployeeDataItems.country,
    EmployeeDataItems.province,
    EmployeeDataItems.city,
    EmployeeDataItems.postalCode,
    EmployeeDataItems.street,
    EmployeeDataItems.language,
    EmployeeDataItems.workLocation,
  ];

  static List<EmployeeDataItems> uniqueItems = [
    EmployeeDataItems.id,
    EmployeeDataItems.email,
  ];

  static List<Modules> defaultAccessTypeModules = [
    Modules.inventory,
    Modules.tracking,
    Modules.messages,
    Modules.todo,
    Modules.tasks,
    Modules.employees,
    Modules.services
  ];
}