// ******************* FILE INFO *******************
// File Name: shared.dart
// Description: Shared SharedPreferences keys/helpers used across the services module.
// Module: services_management_module / data / utils
// *************************************************

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

// NOTE: SharedPrefsEmployeeHelper / SharedPrefsApprovalHelper moved to the
// services module (data/data_source/local_data_source/services_prefs_employee.dart)
// so core no longer depends on the module's EmployeeEntityModell and survives
// module deletion.

class SharedPrefsHelper {
  static Future<void> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }
  static Future<void> setStringList(String key, List<String> value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, value);
  }

  static Future<List<String>?> getStringList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key);
  }

  static Future<bool?> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  static Future<void> setInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  static Future<int?> getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  static Future<void> setDouble(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }

  static Future<double?> getDouble(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key);
  }

  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}


class SharedPrefsDepartmentsHelper {
  static const _departmentsKey = 'selected_departments';

  static Future<void> saveDepartments(List<String> departments) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_departmentsKey, jsonEncode(departments));
  }

  static Future<List<String>> getDepartments() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_departmentsKey);
    if (jsonString == null) return [];
    final List decoded = jsonDecode(jsonString);
    return decoded.cast<String>();
  }

  static Future<void> clearDepartments() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_departmentsKey);
  }
}



class SharedPrefsSlaHelper {
  static const String _slaPercentageKey = 'sla_breach_percentage';
  static const String _checkboxStatePrefix = 'checkbox_state_';
  static const String _customNotificationPrefix = 'custom_notification_';

  static Future<void> saveSlaPercentage(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_slaPercentageKey, value);
  }

  static Future<String?> getSlaPercentage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_slaPercentageKey);
  }

  static Future<void> saveCheckboxState(String id, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_checkboxStatePrefix$id', value);
  }

  static Future<bool?> getCheckboxState(String id) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_checkboxStatePrefix$id');
  }

  static Future<void> saveCustomNotification(String id, String content) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_customNotificationPrefix$id', content);
  }

  static Future<String?> getCustomNotification(String id) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_customNotificationPrefix$id');
  }

  static Future<void> clearSlaData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_slaPercentageKey);
    // Optionally: loop through keys and remove custom/checkbox keys
  }
}


