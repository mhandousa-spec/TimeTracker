// ****************** FILE INFO ******************
// File Name: crm_employee_filter_helper.dart
// Purpose: Helper to filter employees matching C-Suite executive and Management titles
// Author: Mohand Adel
// Created At: 26/08/2026

import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';

class CrmEmployeeFilterHelper {
  const CrmEmployeeFilterHelper._();

  static const List<String> _cLevelKeywords = [
    'chief executive officer',
    'ceo',
    'chief operating officer',
    'coo',
    'chief financial officer',
    'cfo',
    'chief technology officer',
    'cto',
    'chief human resources officer',
    'chro',
    'chief marketing officer',
    'cmo',
    'chief sales officer',
    'cso',
    'chief data officer',
    'cdo',
    'chief compliance officer',
    'cco',
    'chief customer experience officer',
    'cxo',
  ];

  /// Checks if an employee is a C-Suite executive or Manager
  static bool isManagementOrExecutive(EmployeeEntityPro employee) {
    final String title = (employee.title ?? '').toLowerCase().trim();
    final String role = (employee.role ?? '').toLowerCase().trim();
    final String titleAr = (employee.titleInArabic ?? '').trim();

    // 1. Check exact/substring C-level keywords
    for (final keyword in _cLevelKeywords) {
      if (_matchesKeyword(title, keyword) || _matchesKeyword(role, keyword)) {
        return true;
      }
    }

    // 2. Check Manager / Manger (spelling tolerance) in English title or role
    if (title.contains('manager') ||
        title.contains('manger') ||
        role.contains('manager') ||
        role.contains('manger')) {
      return true;
    }

    // 3. Check Arabic title for management terms (مدير / رئيس)
    if (titleAr.contains('مدير') ||
        titleAr.contains('رئيس') ||
        titleAr.contains('تنفيذي')) {
      return true;
    }

    return false;
  }

  static bool _matchesKeyword(String text, String keyword) {
    if (text.isEmpty || keyword.isEmpty) return false;
    if (text == keyword) return true;
    if (text.contains(keyword)) return true;

    // Word boundary check for short acronyms like 'ceo', 'cfo'
    final List<String> words = text.split(RegExp(r'[\s,\-_/()]+'));
    return words.contains(keyword);
  }

  /// Filters a list of employees to only C-Suite executives and Managers
  static List<EmployeeEntityPro> filterManagementEmployees(
      List<EmployeeEntityPro> employees) {
    return employees.where(isManagementOrExecutive).toList();
  }
}
