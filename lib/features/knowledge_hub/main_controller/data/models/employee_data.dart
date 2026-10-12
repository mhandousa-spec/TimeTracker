/// Module: knowledge_hub / core/data/models/employee_data.dart
/// ************************* FILE INFO *************************** ///
/// File Name: employee_data.dart
/// Purpose: Employee data — knowledge_hub core/widgets.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'dart:developer';
class EmployeeData {
  final List<int> timestamps;
  final List<String> employeeName;
  final List<String> employeeNameArabic;
  final List<String> employeeId;
  final List<String> employeeEmail;
  final List<String>? employeePhoto;
  final List<String> employeeDepartment;
  final List<String> employeeRole;
  final List<String> employeeRoleArabic; // ✅ NEW: Arabic job title/role support
  final List<String> employeeJobTitle;
  final List<String>? employeePhone;
  final List<String> employeeSupervisor;

  EmployeeData({
    required this.timestamps,
    required this.employeeName,
    required this.employeeNameArabic,
    required this.employeeId,
    required this.employeeEmail,
    required this.employeeJobTitle,
    this.employeePhoto,
    required this.employeeDepartment,
    required this.employeeRole,
    required this.employeeRoleArabic, // ✅ NEW
    this.employeePhone,
    required this.employeeSupervisor,
  });

  // Helper getters for current (latest) values
  String get currentemployeeName => employeeName.isNotEmpty ? employeeName.last : '';
  String get currentemployeeNameArabic => employeeNameArabic.isNotEmpty ? employeeNameArabic.last : currentemployeeName;
  String get currentemployeeId => employeeId.isNotEmpty ? employeeId.last : '';
  String get currentemployeeEmail => employeeEmail.isNotEmpty ? employeeEmail.last : '';
  String get currentemployeePhoto => employeePhoto != null && employeePhoto!.isNotEmpty ? employeePhoto!.last : '';
  String get currentemployeeDepartment => employeeDepartment.isNotEmpty ? employeeDepartment.last : '';
  String get currentemployeeRole => employeeRole.isNotEmpty ? employeeRole.last : '';
  String get currentemployeeRoleAr => employeeRoleArabic.isNotEmpty ? employeeRoleArabic.last : currentemployeeRole; // ✅ NEW
  String get currentemployeePhone => employeePhone != null && employeePhone!.isNotEmpty ? employeePhone!.last : '';
  String get currentemployeeSupervisor => employeeSupervisor.isNotEmpty ? employeeSupervisor.last : '';

  int? getTimestampAt(int index) => index < timestamps.length ? timestamps[index] : null;
  int? get currentTimestamp => timestamps.isNotEmpty ? timestamps.last : null;

  // Factory: Create from JSON - UPDATED to handle Arabic job titles
  factory EmployeeData.fromJson(Map<String, dynamic> json) {
    try {
      final List<int> sharedTimestamps = _extractTimestamps(json);

      // Extract English name
      final List<String> firstNameList = _extractSimpleList(json['First_Name']);
      final List<String> lastNameList = _extractSimpleList(json['Last_Name']);
      final List<String> combinedNames = _combineNames(firstNameList, lastNameList);

      // Extract Arabic name
      final List<String> firstNameArabicList = _extractSimpleList(json['First_Name_Arabic']);
      final List<String> lastNameArabicList = _extractSimpleList(json['Last_Name_Arabic']);
      List<String> combinedNamesArabic = _combineNames(firstNameArabicList, lastNameArabicList);

      // Fallback to English if no Arabic names
      if (combinedNamesArabic.isEmpty && combinedNames.isNotEmpty) {
        combinedNamesArabic = combinedNames;
      }

      // ✅ Extract job title (English and Arabic)
      final List<String> jobTitleList = _extractSimpleList(json['Job_Title']);
      final List<String> jobTitleArabicList = _extractSimpleList(json['Job_Title_Arabic']);

      // Fallback to English job title if no Arabic
      List<String> jobTitleArabic = jobTitleArabicList.isNotEmpty
          ? jobTitleArabicList
          : jobTitleList;

      return EmployeeData(
        timestamps: sharedTimestamps,
        employeeName: combinedNames.isNotEmpty ? combinedNames : ['Unknown Employee'],
        employeeNameArabic: combinedNamesArabic.isNotEmpty ? combinedNamesArabic : combinedNames,
        employeeId: _extractIdList(json),
        employeeEmail: _extractSimpleList(json['Email']),
        employeePhoto: _extractSimpleList(json['Photo']),
        employeeDepartment: _extractSimpleList(json['Department_Id']),
        employeeRole: jobTitleList.isNotEmpty ? jobTitleList : _extractSimpleList(json['Role']),
        employeeRoleArabic: jobTitleArabic.isNotEmpty ? jobTitleArabic : jobTitleList, // ✅ NEW
        employeePhone: _extractPhoneList(json),
        employeeJobTitle: jobTitleList,
        employeeSupervisor: _extractSimpleList(json['Supervisor']),
      );
    } catch (e, stack) {
      log("❌ Error parsing EmployeeData: $e");
      log("📄 JSON keys: ${json.keys.toList()}");
      log("🧱 Stacktrace:\n$stack");

      // Return a fallback employee to prevent complete failure
      return EmployeeData(
        timestamps: [DateTime.now().millisecondsSinceEpoch],
        employeeName: ['Unknown Employee'],
        employeeNameArabic: ['موظف غير معروف'],
        employeeId: ['unknown'],
        employeeJobTitle: ['unknown'],
        employeeEmail: ['unknown@example.com'],
        employeeDepartment: [''],
        employeeRole: [''],
        employeeRoleArabic: [''], // ✅ NEW
        employeeSupervisor: [''],
      );
    }
  }

  // Helper: Extract timestamps from various structures
  static List<int> _extractTimestamps(Map<String, dynamic> json) {
    if (json['timestamps'] is List) {
      final timestamps = json['timestamps'] as List;
      return timestamps.map((e) {
        if (e is int) return e;
        if (e is num) return e.toInt();
        return DateTime.now().millisecondsSinceEpoch;
      }).toList();
    }
    return [DateTime.now().millisecondsSinceEpoch];
  }

  // Helper: Extract a simple list from various data structures
  static List<String> _extractSimpleList(dynamic value) {
    if (value == null) return [];

    if (value is List) {
      return value.map((item) {
        if (item == null) return '';

        // Handle nested map structure (like {First_Name: "John", Timestamp: ...})
        if (item is Map<String, dynamic>) {
          // Find the first non-Timestamp, non-null value
          for (var entry in item.entries) {
            if (entry.key != 'Timestamp' && entry.value != null) {
              if (entry.value is List && (entry.value as List).isNotEmpty) {
                return (entry.value as List).first?.toString() ?? '';
              }
              return entry.value.toString();
            }
          }
          return '';
        }

        // Handle simple values
        return item.toString();
      }).toList();
    }

    // Handle single value (not a list)
    if (value is Map<String, dynamic>) {
      for (var entry in value.entries) {
        if (entry.key != 'Timestamp' && entry.value != null) {
          if (entry.value is List && (entry.value as List).isNotEmpty) {
            return [(entry.value as List).first?.toString() ?? ''];
          }
          return [entry.value.toString()];
        }
      }
      return [];
    }

    // Handle simple string/number
    return [value.toString()];
  }

  // Helper: Extract ID list with special handling
  static List<String> _extractIdList(Map<String, dynamic> json) {
    // Try direct ID field first
    if (json['Id'] != null) {
      final idList = _extractSimpleList(json['Id']);
      if (idList.isNotEmpty) return idList;
    }

    // Try employeeId field
    if (json['employeeId'] != null) {
      final idList = _extractSimpleList(json['employeeId']);
      if (idList.isNotEmpty) return idList;
    }

    // Fallback: use timestamp as ID
    return [DateTime.now().millisecondsSinceEpoch.toString()];
  }

  // Helper: Extract phone numbers from Mobile_Phone field
  static List<String> _extractPhoneList(Map<String, dynamic> json) {
    if (json['Mobile_Phone'] == null) return [];

    final mobilePhone = json['Mobile_Phone'];
    final List<String> phones = [];

    if (mobilePhone is List) {
      for (var item in mobilePhone) {
        if (item is Map<String, dynamic>) {
          // Extract phone from nested structure
          String? phone = _extractPhoneFromMap(item);
          if (phone != null && phone.isNotEmpty) {
            phones.add(phone);
          }
        }
      }
    } else if (mobilePhone is Map<String, dynamic>) {
      String? phone = _extractPhoneFromMap(mobilePhone);
      if (phone != null && phone.isNotEmpty) {
        phones.add(phone);
      }
    }

    return phones;
  }

  // Helper: Extract phone number from mobile phone map
  static String? _extractPhoneFromMap(Map<String, dynamic> phoneMap) {
    // Try to find phone number in various field names
    if (phoneMap['Phone'] != null) {
      return phoneMap['Phone'].toString();
    }
    if (phoneMap['phone'] != null) {
      return phoneMap['phone'].toString();
    }

    // Look for any field that might contain a phone number
    for (var entry in phoneMap.entries) {
      if (entry.key != 'Timestamp' &&
          entry.key != 'Country_Code' &&
          entry.key != 'Country_App' &&
          entry.value != null) {
        final valueStr = entry.value.toString();
        // Basic check if this looks like a phone number
        if (valueStr.length >= 7 && valueStr.length <= 15 &&
            RegExp(r'^[0-9]+$').hasMatch(valueStr)) {
          return valueStr;
        }
      }
    }

    return null;
  }

  // Helper: Combine first and last names
  static List<String> _combineNames(List<String> firstNames, List<String> lastNames) {
    if (firstNames.isEmpty && lastNames.isEmpty) return [];

    final maxLength = firstNames.length > lastNames.length ? firstNames.length : lastNames.length;
    final List<String> combined = [];

    for (int i = 0; i < maxLength; i++) {
      final first = i < firstNames.length ? firstNames[i] : '';
      final last = i < lastNames.length ? lastNames[i] : '';
      combined.add('$first $last'.trim());
    }

    return combined;
  }

  // Convert to JSON (simplified) - ✅ UPDATED
  Map<String, dynamic> toJson() {
    return {
      'timestamps': timestamps,
      'employeeName': employeeName,
      'employeeNameArabic': employeeNameArabic,
      'employeeId': employeeId,
      'jobTitle': employeeJobTitle,
      'employeeEmail': employeeEmail,
      'employeePhoto': employeePhoto,
      'employeeDepartment': employeeDepartment,
      'employeeRole': employeeRole,
      'employeeRoleArabic': employeeRoleArabic, // ✅ NEW
      'employeePhone': employeePhone,
      'employeeSupervisor': employeeSupervisor,
    };
  }

  // Factory: Create with initial values - ✅ UPDATED
  factory EmployeeData.createNew({
    required String employeeName,
    String? employeeNameArabic,
    required String employeeId,
    required String employeeEmail,
    required String employeeJobTitle,
    required String employeeDepartment,
    String? employeePhoto,
    required String employeeRole,
    String? employeeRoleArabic, // ✅ NEW: Arabic job title parameter
    String? employeePhone,
    required String employeeSupervisor,
  }) {
    return EmployeeData(
      timestamps: [DateTime.now().millisecondsSinceEpoch],
      employeeName: [employeeName],
      employeeNameArabic: [employeeNameArabic ?? employeeName],
      employeeEmail: [employeeEmail],
      employeeId: [employeeId],
      employeeDepartment: [employeeDepartment],
      employeeRole: [employeeRole],
      employeeRoleArabic: [employeeRoleArabic ?? employeeRole], // ✅ Fallback to English
      employeeJobTitle: [employeeJobTitle],
      employeePhoto: employeePhoto != null ? [employeePhoto] : null,
      employeePhone: employeePhone != null ? [employeePhone] : null,
      employeeSupervisor: [employeeSupervisor],
    );
  }

  // copyWith method - ✅ UPDATED
  EmployeeData copyWith({
    String? employeeId,
    String? employeeName,
    String? employeeNameArabic,
    String? employeeEmail,
    String? employeePhoto,
    String? employeeDepartment,
    String? employeeRole,
    String? employeeRoleArabic, // ✅ NEW
    String? employeeJobTitle,
    String? employeePhone,
    String? employeeSupervisor,
  }) {
    final newTimestamps = List<int>.from(timestamps)
      ..add(DateTime.now().millisecondsSinceEpoch);

    return EmployeeData(
      timestamps: newTimestamps,
      employeeId: employeeId != null
          ? (List<String>.from(this.employeeId)..add(employeeId))
          : this.employeeId,
      employeeName: employeeName != null
          ? (List<String>.from(this.employeeName)..add(employeeName))
          : this.employeeName,
      employeeJobTitle: employeeJobTitle != null
          ? (List<String>.from(this.employeeJobTitle)..add(employeeJobTitle))
          : this.employeeJobTitle,
      employeeNameArabic: employeeNameArabic != null
          ? (List<String>.from(this.employeeNameArabic)..add(employeeNameArabic))
          : this.employeeNameArabic,
      employeeEmail: employeeEmail != null
          ? (List<String>.from(this.employeeEmail)..add(employeeEmail))
          : this.employeeEmail,
      employeeDepartment: employeeDepartment != null
          ? (List<String>.from(this.employeeDepartment)..add(employeeDepartment))
          : this.employeeDepartment,
      employeeRole: employeeRole != null
          ? (List<String>.from(this.employeeRole)..add(employeeRole))
          : this.employeeRole,
      employeeRoleArabic: employeeRoleArabic != null // ✅ NEW
          ? (List<String>.from(this.employeeRoleArabic)..add(employeeRoleArabic))
          : this.employeeRoleArabic,
      employeePhoto: employeePhoto != null
          ? (this.employeePhoto != null
          ? (List<String>.from(this.employeePhoto!)..add(employeePhoto))
          : [employeePhoto])
          : this.employeePhoto,
      employeePhone: employeePhone != null
          ? (this.employeePhone != null
          ? (List<String>.from(this.employeePhone!)..add(employeePhone))
          : [employeePhone])
          : this.employeePhone,
      employeeSupervisor: employeeSupervisor != null
          ? (List<String>.from(this.employeeSupervisor)..add(employeeSupervisor))
          : this.employeeSupervisor,
    );
  }
}