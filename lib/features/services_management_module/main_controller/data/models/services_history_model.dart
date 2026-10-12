// ******************* FILE INFO *******************
// File Name: services_history_model
// Description: DTO for a service history record (providers, approval cycle, SLA).
// Module: services_management_module / data / models
// *************************************************

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/model_employee.dart';

class ServicesHistoryModel {
  // ---- Firestore field keys ----
  static const String kTimestamps = 'timestamps';
  static const String kId = 'id';
  static const String kState = 'state';
  static const String kStatus = 'status';
  static const String kParentServiceId = 'Parent_Service_Id';
  static const String kFirstNameRequester = 'First_Name_Requester';
  static const String kLastNameRequester = 'Last_Name_Requester';
  static const String kDepartmentRequester = 'Department_Requester';
  static const String kJobTitleRequester = 'Job_Title_Requester';
  static const String kEmailRequester = 'Email_Requester';
  static const String kPhoneRequester = 'Phone_Requester';
  static const String kGenderRequester = 'Gender_Requester';
  static const String kAssignedProviderEmail = 'Assigned_Provider_Email';
  static const String kFirstNameRequesterArabic = 'First_Name_Requester_Arabic';
  static const String kLastNameRequesterArabic = 'Last_Name_Requester_Arabic';
  static const String kJobTitleRequesterArabic = 'Job_Title_Requester_Arabic';
  static const String kDepartmentRequesterArabic = 'Department_Requester_Arabic';
  static const String kServiceNameEnglish = 'Service_Name_English';
  static const String kServiceNameArabic = 'Service_Name_Arabic';
  static const String kServiceDescriptionEnglish = 'Service_Description_English';
  static const String kServiceDescriptionArabic = 'Service_Description_Arabic';
  static const String kDurationOfServices = 'Duration_Of_Services';
  static const String kSelectedDurationUnit = 'Selected_Duration_Unit';
  static const String kDurationOfServicesTimestamp = 'Duration_Of_Services_Timestamp';
  static const String kImageUrl = 'Image_Url';
  static const String kProviderServices = 'Provider_Services';
  static const String kSelectDepartment = 'Select_Department';
  static const String kApprovalCycle = 'Approval_Cycle';
  static const String kLimitAvailability = 'Limit_Availability';
  static const String kRequireApproval = 'Require_Approval';
  static const String kSlaOneControllerEnglish = 'Sla_One_Controller_English';
  static const String kSlaTwoControllerEnglish = 'Sla_Two_Controller_English';
  static const String kNotifyRequesterChecked = 'Notify_Requester_Checked';
  static const String kNotifyProviderChecked = 'Notify_Provider_Checked';
  static const String kNotifyManagerChecked = 'Notify_Manager_Checked';
  static const String kNotifyRequesterSwitch0 = 'Notify_Requester_Switch0';
  static const String kNotifyManagerSwitch1 = 'Notify_Manager_Switch1';
  /// Soft-delete flag (ADDED 25/9/2026). A deleted service keeps its document
  /// so requests made before the delete still resolve its name/duration/image,
  /// but it is hidden from the Services home page and the Service Requests list.
  static const String kIsDeleted = 'Is_Deleted';
  static const String kDeletedAt = 'Deleted_At';

  // ✅ SHARED timestamps for ALL fields
  final List<int> timestamps;

  // Core fields - Direct lists!
  final List<String> id;
  final List<String> state;
  final List<String> status;
  final List<String> parentServiceId;

  // Requester information
  final List<String> firstNameRequester;
  final List<String> lastNameRequester;
  final List<String> departmentRequester;
  final List<String> jobTitleRequester;
  final List<String> emailRequester;
  final List<String> phoneRequester;
  final List<String> genderRequester;
  final List<String> assignedProviderEmail;

  // Arabic fields
  final List<String> firstNameRequesterArabic;
  final List<String> lastNameRequesterArabic;
  final List<String> jobTitleRequesterArabic;
  final List<String> departmentRequesterArabic;

  // Service details
  final List<String> serviceNameEnglish;
  final List<String> serviceNameArabic;
  final List<String> serviceDescriptionEnglish;
  final List<String> serviceDescriptionArabic;
  final List<String> durationOfServices;
  final List<String> selectedDurationUnit;
  final List<Timestamp> durationOfServicesTimestamp;
  final List<String> imageUrl;

  // Provider services (stored as JSON string)
  final List<String> providerServices;

  // Boolean fields
  final List<bool> limitAvailability;
  final List<bool> requireApproval;

  // Department selection (stored as JSON string)
  final List<String> selectDepartment;

  // Approval cycle (stored as JSON string)
  final List<String> approvalCycle;

  // SLA fields
  final List<String> slaOneControllerEnglish;
  final List<String> slaTwoControllerEnglish;

  // Notification fields
  final List<bool> notifyRequesterChecked;
  final List<bool> notifyProviderChecked;
  final List<bool> notifyManagerChecked;
  final List<bool> notifyRequesterSwitch0;
  final List<bool> notifyManagerSwitch1;

  /// See [kIsDeleted]. Read-only here — written by `deleteService`.
  final bool isDeleted;

  ServicesHistoryModel({
    this.isDeleted = false,
    required this.timestamps,
    required this.id,
    required this.state,
    required this.status,
    required this.parentServiceId,
    required this.firstNameRequester,
    required this.lastNameRequester,
    required this.departmentRequester,
    required this.jobTitleRequester,
    required this.emailRequester,
    required this.phoneRequester,
    required this.genderRequester,
    required this.assignedProviderEmail,
    required this.firstNameRequesterArabic,
    required this.lastNameRequesterArabic,
    required this.jobTitleRequesterArabic,
    required this.departmentRequesterArabic,
    required this.serviceNameEnglish,
    required this.serviceNameArabic,
    required this.serviceDescriptionEnglish,
    required this.serviceDescriptionArabic,
    required this.durationOfServices,
    required this.selectedDurationUnit,
    required this.durationOfServicesTimestamp,
    required this.imageUrl,
    required this.providerServices,
    required this.limitAvailability,
    required this.requireApproval,
    required this.selectDepartment,
    required this.approvalCycle,
    required this.slaOneControllerEnglish,
    required this.slaTwoControllerEnglish,
    required this.notifyRequesterChecked,
    required this.notifyProviderChecked,
    required this.notifyManagerChecked,
    required this.notifyRequesterSwitch0,
    required this.notifyManagerSwitch1,
  });

  // ✅ Helper getters for current (latest) values
  String get currentId => id.isNotEmpty ? id.last : '';
  String get currentState => state.isNotEmpty ? state.last : '';
  String get currentStatus => status.isNotEmpty ? status.last : '';
  String get currentParentServiceId => parentServiceId.isNotEmpty ? parentServiceId.last : '';
  String get currentFirstNameRequester => firstNameRequester.isNotEmpty ? firstNameRequester.last : '';
  String get currentLastNameRequester => lastNameRequester.isNotEmpty ? lastNameRequester.last : '';
  String get currentDepartmentRequester => departmentRequester.isNotEmpty ? departmentRequester.last : '';
  String get currentJobTitleRequester => jobTitleRequester.isNotEmpty ? jobTitleRequester.last : '';
  String get currentEmailRequester => emailRequester.isNotEmpty ? emailRequester.last : '';
  String get currentPhoneRequester => phoneRequester.isNotEmpty ? phoneRequester.last : '';
  String get currentGenderRequester => genderRequester.isNotEmpty ? genderRequester.last : '';
  String get currentAssignedProviderEmail => assignedProviderEmail.isNotEmpty ? assignedProviderEmail.last : '';
  String get currentFirstNameRequesterArabic => firstNameRequesterArabic.isNotEmpty ? firstNameRequesterArabic.last : '';
  String get currentLastNameRequesterArabic => lastNameRequesterArabic.isNotEmpty ? lastNameRequesterArabic.last : '';
  String get currentJobTitleRequesterArabic => jobTitleRequesterArabic.isNotEmpty ? jobTitleRequesterArabic.last : '';
  String get currentDepartmentRequesterArabic => departmentRequesterArabic.isNotEmpty ? departmentRequesterArabic.last : '';
  String get currentServiceNameEnglish => serviceNameEnglish.isNotEmpty ? serviceNameEnglish.last : '';
  String get currentServiceNameArabic => serviceNameArabic.isNotEmpty ? serviceNameArabic.last : '';
  String get currentServiceDescriptionEnglish => serviceDescriptionEnglish.isNotEmpty ? serviceDescriptionEnglish.last : '';
  String get currentServiceDescriptionArabic => serviceDescriptionArabic.isNotEmpty ? serviceDescriptionArabic.last : '';
  String get currentDurationOfServices => durationOfServices.isNotEmpty ? durationOfServices.last : '';
  String get currentSelectedDurationUnit => selectedDurationUnit.isNotEmpty ? selectedDurationUnit.last : '';
  Timestamp get currentDurationOfServicesTimestamp => durationOfServicesTimestamp.isNotEmpty ? durationOfServicesTimestamp.last : Timestamp.now();
  String get currentImageUrl => imageUrl.isNotEmpty ? imageUrl.last : '';
  bool get currentLimitAvailability => limitAvailability.isNotEmpty ? limitAvailability.last : false;
  bool get currentRequireApproval => requireApproval.isNotEmpty ? requireApproval.last : false;
  String get currentSlaOneControllerEnglish => slaOneControllerEnglish.isNotEmpty ? slaOneControllerEnglish.last : '';
  String get currentSlaTwoControllerEnglish => slaTwoControllerEnglish.isNotEmpty ? slaTwoControllerEnglish.last : '';
  bool get currentNotifyRequesterChecked => notifyRequesterChecked.isNotEmpty ? notifyRequesterChecked.last : false;
  bool get currentNotifyProviderChecked => notifyProviderChecked.isNotEmpty ? notifyProviderChecked.last : false;
  bool get currentNotifyManagerChecked => notifyManagerChecked.isNotEmpty ? notifyManagerChecked.last : false;
  bool get currentNotifyRequesterSwitch0 => notifyRequesterSwitch0.isNotEmpty ? notifyRequesterSwitch0.last : false;
  bool get currentNotifyManagerSwitch1 => notifyManagerSwitch1.isNotEmpty ? notifyManagerSwitch1.last : false;

  // ✅ Get timestamp at specific index
  int? getTimestampAt(int index) => index < timestamps.length ? timestamps[index] : null;

  // ✅ Get current (latest) timestamp
  int? get currentTimestamp => timestamps.isNotEmpty ? timestamps.last : null;

  // Factory: Create from JSON.
  // NOTE: Pure data mapping only — no try/catch (§11.2/§10). Any parsing guards
  // belong at the repository call site, which is responsible for catching and
  // translating malformed-data errors into an error state.
  factory ServicesHistoryModel.fromJson(Map<String, dynamic> json, [String? docId]) {
    // ✅ Parse shared timestamps first
    // B6 FIX: was `(e) => e as int`, which threw TypeError on legacy/cross-platform
    // docs where a timestamp is stored as a Timestamp or double. Coerce the known
    // shapes (int / num / Firestore Timestamp) instead of a hard cast.
    final List<int> sharedTimestamps =
        (json[kTimestamps] as List<dynamic>?)?.map(_coerceEpochMs).toList() ??
            [DateTime.now().millisecondsSinceEpoch];

    return ServicesHistoryModel(
      isDeleted: json[kIsDeleted] == true,
      timestamps: sharedTimestamps,
      id: _parseList<String>(docId ?? json[kId], (v) => v as String? ?? ''),
        state: _parseList<String>(json[kState], (v) => v as String? ?? ''),
        status: _parseList<String>(json[kStatus], (v) => v as String? ?? ''),
        parentServiceId: _parseList<String>(json[kParentServiceId], (v) => v as String? ?? ''),
        firstNameRequester: _parseList<String>(json[kFirstNameRequester], (v) => v as String? ?? ''),
        lastNameRequester: _parseList<String>(json[kLastNameRequester], (v) => v as String? ?? ''),
        departmentRequester: _parseList<String>(json[kDepartmentRequester], (v) => v as String? ?? ''),
        jobTitleRequester: _parseList<String>(json[kJobTitleRequester], (v) => v as String? ?? ''),
        emailRequester: _parseList<String>(json[kEmailRequester], (v) => v as String? ?? ''),
        phoneRequester: _parseList<String>(json[kPhoneRequester], (v) => v as String? ?? ''),
        genderRequester: _parseList<String>(json[kGenderRequester], (v) => v as String? ?? ''),
        assignedProviderEmail: _parseList<String>(json[kAssignedProviderEmail], (v) => v as String? ?? ''),
        firstNameRequesterArabic: _parseList<String>(json[kFirstNameRequesterArabic], (v) => v as String? ?? ''),
        lastNameRequesterArabic: _parseList<String>(json[kLastNameRequesterArabic], (v) => v as String? ?? ''),
        jobTitleRequesterArabic: _parseList<String>(json[kJobTitleRequesterArabic], (v) => v as String? ?? ''),
        departmentRequesterArabic: _parseList<String>(json[kDepartmentRequesterArabic], (v) => v as String? ?? ''),
        serviceNameEnglish: _parseList<String>(json[kServiceNameEnglish], (v) => v as String? ?? ''),
        serviceNameArabic: _parseList<String>(json[kServiceNameArabic], (v) => v as String? ?? ''),
        serviceDescriptionEnglish: _parseList<String>(json[kServiceDescriptionEnglish], (v) => v as String? ?? ''),
        serviceDescriptionArabic: _parseList<String>(json[kServiceDescriptionArabic], (v) => v as String? ?? ''),
        durationOfServices: _parseList<String>(json[kDurationOfServices], (v) => v as String? ?? ''),
        selectedDurationUnit: _parseList<String>(json[kSelectedDurationUnit], (v) => v as String? ?? ''),
        durationOfServicesTimestamp: _parseList<Timestamp>(
          json[kDurationOfServicesTimestamp],
              (v) {
            if (v is Timestamp) return v;
            if (v is int) return Timestamp.fromMillisecondsSinceEpoch(v);
            return Timestamp.now();
          },
        ),
        imageUrl: _parseList<String>(json[kImageUrl], (v) => v as String? ?? ''),
        providerServices: _parseList<String>(json[kProviderServices], (v) => _parseEmployeeListToJson(v)),
        selectDepartment: _parseList<String>(json[kSelectDepartment], (v) => _parseJsonArray(v)),
        approvalCycle: _parseList<String>(json[kApprovalCycle], (v) => _parseEmployeeListToJson(v)),
        limitAvailability: _parseList<bool>(json[kLimitAvailability], (v) => v as bool? ?? false),
        requireApproval: _parseList<bool>(json[kRequireApproval], (v) => v as bool? ?? false),
        slaOneControllerEnglish: _parseList<String>(json[kSlaOneControllerEnglish], (v) => v as String? ?? ''),
        slaTwoControllerEnglish: _parseList<String>(json[kSlaTwoControllerEnglish], (v) => v as String? ?? ''),
        notifyRequesterChecked: _parseList<bool>(json[kNotifyRequesterChecked], (v) => v as bool? ?? false),
        notifyProviderChecked: _parseList<bool>(json[kNotifyProviderChecked], (v) => v as bool? ?? false),
        notifyManagerChecked: _parseList<bool>(json[kNotifyManagerChecked], (v) => v as bool? ?? false),
        notifyRequesterSwitch0: _parseList<bool>(json[kNotifyRequesterSwitch0], (v) => v as bool? ?? false),
      notifyManagerSwitch1: _parseList<bool>(json[kNotifyManagerSwitch1], (v) => v as bool? ?? false),
    );
  }

  // Helper: Parse list (handles multiple legacy formats)
  // B6 FIX helper: coerce a timestamp entry that may arrive as an int (epoch ms),
  // a num (double epoch), or a Firestore Timestamp into epoch milliseconds.
  static int _coerceEpochMs(dynamic e) {
    if (e is int) return e;
    if (e is Timestamp) return e.millisecondsSinceEpoch;
    if (e is num) return e.toInt();
    return DateTime.now().millisecondsSinceEpoch;
  }

  static List<T> _parseList<T>(dynamic value, T Function(dynamic) deserializer) {
    // If it's already a list
    if (value is List) {
      return value.map((e) => deserializer(e)).toList();
    }

    // Legacy format with FieldHistory: {timestamps: [...], values: [...]}
    if (value is Map<String, dynamic> && value.containsKey('values')) {
      final values = value['values'];
      if (values is List) {
        return values.map((e) => deserializer(e)).toList();
      }
    }

    // Legacy format: {value: ..., timestamp: ...}
    if (value is Map<String, dynamic> && value.containsKey('value')) {
      return [deserializer(value['value'])];
    }

    // Simple value
    return [deserializer(value)];
  }

  // Helper: Convert arrays to JSON string
  static String _parseJsonArray(dynamic value) {
    if (value == null) return '[]';
    if (value is String) return value;
    if (value is List) return jsonEncode(value);
    return '[]';
  }

  // Helper: Convert employee list to JSON string
  static String _parseEmployeeListToJson(dynamic value) {
    if (value == null) return '[]';
    if (value is String) return value;
    if (value is List) {
      final employees = value.map((e) {
        if (e is Map<String, dynamic>) {
          return e;
        } else if (e is Map) {
          return Map<String, dynamic>.from(e);
        }
        return null;
      }).whereType<Map<String, dynamic>>().toList();
      return jsonEncode(employees);
    }
    return '[]';
  }

  // ---- Canonical map serialization (§10) ----
  // toMap()/fromMap() are the standard names. They delegate to the existing
  // toJson()/fromJson() so the 100+ call sites keep working during migration.
  Map<String, dynamic> toMap() => toJson();

  factory ServicesHistoryModel.fromMap(Map<String, dynamic> map, [String? docId]) =>
      ServicesHistoryModel.fromJson(map, docId);

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      kTimestamps: timestamps,
      kId: id,
      kState: state,
      kStatus: status,
      kParentServiceId: parentServiceId,
      kFirstNameRequester: firstNameRequester,
      kLastNameRequester: lastNameRequester,
      kDepartmentRequester: departmentRequester,
      kJobTitleRequester: jobTitleRequester,
      kEmailRequester: emailRequester,
      kPhoneRequester: phoneRequester,
      kGenderRequester: genderRequester,
      kAssignedProviderEmail: assignedProviderEmail,
      kFirstNameRequesterArabic: firstNameRequesterArabic,
      kLastNameRequesterArabic: lastNameRequesterArabic,
      kJobTitleRequesterArabic: jobTitleRequesterArabic,
      kDepartmentRequesterArabic: departmentRequesterArabic,
      kServiceNameEnglish: serviceNameEnglish,
      kServiceNameArabic: serviceNameArabic,
      kServiceDescriptionEnglish: serviceDescriptionEnglish,
      kServiceDescriptionArabic: serviceDescriptionArabic,
      kDurationOfServices: durationOfServices,
      kSelectedDurationUnit: selectedDurationUnit,
      kDurationOfServicesTimestamp: durationOfServicesTimestamp.map((v) => v.millisecondsSinceEpoch).toList(),
      kImageUrl: imageUrl,
      kProviderServices: providerServices,
      kLimitAvailability: limitAvailability,
      kRequireApproval: requireApproval,
      kSelectDepartment: selectDepartment,
      kApprovalCycle: approvalCycle,
      kSlaOneControllerEnglish: slaOneControllerEnglish,
      kSlaTwoControllerEnglish: slaTwoControllerEnglish,
      kNotifyRequesterChecked: notifyRequesterChecked,
      kNotifyProviderChecked: notifyProviderChecked,
      kNotifyManagerChecked: notifyManagerChecked,
      kNotifyRequesterSwitch0: notifyRequesterSwitch0,
      kNotifyManagerSwitch1: notifyManagerSwitch1,
    };
  }

  // ✅ NEW: Convert to JSON, ONLY including fields that have values
  // ✅ UPDATED: Convert to JSON, ONLY including fields that have values
  Map<String, dynamic> toJsonMinimal() {
    final Map<String, dynamic> json = {};

    // ✅ Always include timestamps
    json['timestamps'] = timestamps;

    // ✅ Only add fields if they are NOT EMPTY AND have non-empty values
    if (parentServiceId.isNotEmpty && parentServiceId.last.isNotEmpty) {
      json['Parent_Service_Id'] = parentServiceId;
    }
    if (id.isNotEmpty && id.last.isNotEmpty) {
      json['id'] = id;
    }
    if (providerServices.isNotEmpty && providerServices.last.isNotEmpty) {
      json['Provider_Services'] = providerServices;
    }
    if (approvalCycle.isNotEmpty && approvalCycle.last.isNotEmpty) {
      json['Approval_Cycle'] = approvalCycle;
    }
    if (state.isNotEmpty && state.last.isNotEmpty) {
      json['state'] = state;
    }
    if (status.isNotEmpty && status.last.isNotEmpty) {
      json['status'] = status;
    }
    if (emailRequester.isNotEmpty && emailRequester.last.isNotEmpty) {  // ✅ ADDED CHECK
      json['Email_Requester'] = emailRequester;
    }
    if (assignedProviderEmail.isNotEmpty && assignedProviderEmail.last.isNotEmpty) {
      json['Assigned_Provider_Email'] = assignedProviderEmail;
    }

    // ✅ Don't include selectDepartment or any other empty fields
    return json;
  }

  // copyWith method - adds new timestamp and new values
  ServicesHistoryModel copyWith({
    String? id,
    String? state,
    String? status,
    String? parentServiceId,
    String? firstNameRequester,
    String? lastNameRequester,
    String? departmentRequester,
    String? jobTitleRequester,
    String? emailRequester,
    String? phoneRequester,
    String? genderRequester,
    String? assignedProviderEmail,
    String? firstNameRequesterArabic,
    String? lastNameRequesterArabic,
    String? jobTitleRequesterArabic,
    String? departmentRequesterArabic,
    String? serviceNameEnglish,
    String? serviceNameArabic,
    String? serviceDescriptionEnglish,
    String? serviceDescriptionArabic,
    String? durationOfServices,
    String? selectedDurationUnit,
    Timestamp? durationOfServicesTimestamp,
    String? imageUrl,
    List<EmployeeEntityModell>? providerServices,
    bool? limitAvailability,
    bool? requireApproval,
    List<dynamic>? selectDepartment,
    List<EmployeeEntityModell>? approvalCycle,
    String? slaOneControllerEnglish,
    String? slaTwoControllerEnglish,
    bool? notifyRequesterChecked,
    bool? notifyProviderChecked,
    bool? notifyManagerChecked,
    bool? notifyRequesterSwitch0,
    bool? notifyManagerSwitch1,

    /// Whether this copy counts as a real edit and should append "now" to the
    /// [timestamps] history.
    ///
    /// ✅ FIX ("Last Update" identical on every card in My Requests): this used
    /// to be unconditional, so ANY copyWith stamped DateTime.now() — including
    /// the read-time repairs that backfill a missing service name or requester
    /// name for display. Those run once per document inside a single loop over
    /// the whole collection (see
    /// CreateServicesRepositoryImpl.getMyRequestServices and
    /// ServicesFilterLoader), and ServicesHistoryModel.createMinimalRequest
    /// never sets a service name, so essentially EVERY request hit the repair
    /// branch on EVERY list load. All their `timestamps.last` values collapsed
    /// to the same millisecond, and my_request.dart renders that as
    /// "Last Update" — so opening the page (or creating one new request, which
    /// reloads the list) appeared to re-date every past request at once.
    ///
    /// Pass false for cosmetic/derived changes; leave it true for a genuine
    /// state, assignment or content edit that belongs in the revision history.
    bool bumpTimestamp = true,
  }) {
    final newTimestamps = bumpTimestamp
        ? (List<int>.from(timestamps)..add(DateTime.now().millisecondsSinceEpoch))
        : List<int>.from(timestamps);

    return ServicesHistoryModel(
      isDeleted: isDeleted,
      timestamps: newTimestamps,
      id: id != null ? (List<String>.from(this.id)..add(id)) : this.id,
      state: state != null ? (List<String>.from(this.state)..add(state)) : this.state,
      status: status != null ? (List<String>.from(this.status)..add(status)) : this.status,
      parentServiceId: parentServiceId != null ? (List<String>.from(this.parentServiceId)..add(parentServiceId)) : this.parentServiceId,
      firstNameRequester: firstNameRequester != null ? (List<String>.from(this.firstNameRequester)..add(firstNameRequester)) : this.firstNameRequester,
      lastNameRequester: lastNameRequester != null ? (List<String>.from(this.lastNameRequester)..add(lastNameRequester)) : this.lastNameRequester,
      departmentRequester: departmentRequester != null ? (List<String>.from(this.departmentRequester)..add(departmentRequester)) : this.departmentRequester,
      jobTitleRequester: jobTitleRequester != null ? (List<String>.from(this.jobTitleRequester)..add(jobTitleRequester)) : this.jobTitleRequester,
      emailRequester: emailRequester != null ? (List<String>.from(this.emailRequester)..add(emailRequester)) : this.emailRequester,
      phoneRequester: phoneRequester != null ? (List<String>.from(this.phoneRequester)..add(phoneRequester)) : this.phoneRequester,
      genderRequester: genderRequester != null ? (List<String>.from(this.genderRequester)..add(genderRequester)) : this.genderRequester,
      assignedProviderEmail: assignedProviderEmail != null ? (List<String>.from(this.assignedProviderEmail)..add(assignedProviderEmail)) : this.assignedProviderEmail,
      firstNameRequesterArabic: firstNameRequesterArabic != null ? (List<String>.from(this.firstNameRequesterArabic)..add(firstNameRequesterArabic)) : this.firstNameRequesterArabic,
      lastNameRequesterArabic: lastNameRequesterArabic != null ? (List<String>.from(this.lastNameRequesterArabic)..add(lastNameRequesterArabic)) : this.lastNameRequesterArabic,
      jobTitleRequesterArabic: jobTitleRequesterArabic != null ? (List<String>.from(this.jobTitleRequesterArabic)..add(jobTitleRequesterArabic)) : this.jobTitleRequesterArabic,
      departmentRequesterArabic: departmentRequesterArabic != null ? (List<String>.from(this.departmentRequesterArabic)..add(departmentRequesterArabic)) : this.departmentRequesterArabic,
      serviceNameEnglish: serviceNameEnglish != null ? (List<String>.from(this.serviceNameEnglish)..add(serviceNameEnglish)) : this.serviceNameEnglish,
      serviceNameArabic: serviceNameArabic != null ? (List<String>.from(this.serviceNameArabic)..add(serviceNameArabic)) : this.serviceNameArabic,
      serviceDescriptionEnglish: serviceDescriptionEnglish != null ? (List<String>.from(this.serviceDescriptionEnglish)..add(serviceDescriptionEnglish)) : this.serviceDescriptionEnglish,
      serviceDescriptionArabic: serviceDescriptionArabic != null ? (List<String>.from(this.serviceDescriptionArabic)..add(serviceDescriptionArabic)) : this.serviceDescriptionArabic,
      durationOfServices: durationOfServices != null ? (List<String>.from(this.durationOfServices)..add(durationOfServices)) : this.durationOfServices,
      selectedDurationUnit: selectedDurationUnit != null ? (List<String>.from(this.selectedDurationUnit)..add(selectedDurationUnit)) : this.selectedDurationUnit,
      durationOfServicesTimestamp: durationOfServicesTimestamp != null ? (List<Timestamp>.from(this.durationOfServicesTimestamp)..add(durationOfServicesTimestamp)) : this.durationOfServicesTimestamp,
      imageUrl: imageUrl != null ? (List<String>.from(this.imageUrl)..add(imageUrl)) : this.imageUrl,
      providerServices: providerServices != null ? (List<String>.from(this.providerServices)..add(jsonEncode(providerServices.map((e) => e.toJson()).toList()))) : this.providerServices,
      limitAvailability: limitAvailability != null ? (List<bool>.from(this.limitAvailability)..add(limitAvailability)) : this.limitAvailability,
      requireApproval: requireApproval != null ? (List<bool>.from(this.requireApproval)..add(requireApproval)) : this.requireApproval,
      selectDepartment: selectDepartment != null ? (List<String>.from(this.selectDepartment)..add(jsonEncode(selectDepartment))) : this.selectDepartment,
      approvalCycle: approvalCycle != null ? (List<String>.from(this.approvalCycle)..add(jsonEncode(approvalCycle.map((e) => e.toJson()).toList()))) : this.approvalCycle,
      slaOneControllerEnglish: slaOneControllerEnglish != null ? (List<String>.from(this.slaOneControllerEnglish)..add(slaOneControllerEnglish)) : this.slaOneControllerEnglish,
      slaTwoControllerEnglish: slaTwoControllerEnglish != null ? (List<String>.from(this.slaTwoControllerEnglish)..add(slaTwoControllerEnglish)) : this.slaTwoControllerEnglish,
      notifyRequesterChecked: notifyRequesterChecked != null ? (List<bool>.from(this.notifyRequesterChecked)..add(notifyRequesterChecked)) : this.notifyRequesterChecked,
      notifyProviderChecked: notifyProviderChecked != null ? (List<bool>.from(this.notifyProviderChecked)..add(notifyProviderChecked)) : this.notifyProviderChecked,
      notifyManagerChecked: notifyManagerChecked != null ? (List<bool>.from(this.notifyManagerChecked)..add(notifyManagerChecked)) : this.notifyManagerChecked,
      notifyRequesterSwitch0: notifyRequesterSwitch0 != null ? (List<bool>.from(this.notifyRequesterSwitch0)..add(notifyRequesterSwitch0)) : this.notifyRequesterSwitch0,
      notifyManagerSwitch1: notifyManagerSwitch1 != null ? (List<bool>.from(this.notifyManagerSwitch1)..add(notifyManagerSwitch1)) : this.notifyManagerSwitch1,
    );
  }

  // Factory: Create new service
  factory ServicesHistoryModel.createNew({
    String id = '',
    String state = '',
    String status = 'draft',
    String parentServiceId = '',
    String firstNameRequester = '',
    String lastNameRequester = '',
    String departmentRequester = '',
    String jobTitleRequester = '',
    String emailRequester = '',
    String phoneRequester = '',
    String genderRequester = '',
    String assignedProviderEmail = '',
    String firstNameRequesterArabic = '',
    String lastNameRequesterArabic = '',
    String jobTitleRequesterArabic = '',
    String departmentRequesterArabic = '',
    String serviceNameEnglish = '',
    String serviceNameArabic = '',
    String serviceDescriptionEnglish = '',
    String serviceDescriptionArabic = '',
    String durationOfServices = '',
    String selectedDurationUnit = '',
    Timestamp? durationOfServicesTimestamp,
    String imageUrl = '',
    List<EmployeeEntityModell> providerServices = const [],
    bool limitAvailability = false,
    bool requireApproval = false,
    List<dynamic> selectDepartment = const [],
    List<EmployeeEntityModell> approvalCycle = const [],
    String slaOneControllerEnglish = '',
    String slaTwoControllerEnglish = '',
    bool notifyRequesterChecked = false,
    bool notifyProviderChecked = false,
    bool notifyManagerChecked = false,
    bool notifyRequesterSwitch0 = false,
    bool notifyManagerSwitch1 = false,
  }) {
    return ServicesHistoryModel(
      timestamps: [DateTime.now().millisecondsSinceEpoch],
      id: [id],
      state: [state],
      status: [status],
      parentServiceId: [parentServiceId],
      firstNameRequester: [firstNameRequester],
      lastNameRequester: [lastNameRequester],
      departmentRequester: [departmentRequester],
      jobTitleRequester: [jobTitleRequester],
      emailRequester: [emailRequester],
      phoneRequester: [phoneRequester],
      genderRequester: [genderRequester],
      assignedProviderEmail: [assignedProviderEmail],
      firstNameRequesterArabic: [firstNameRequesterArabic],
      lastNameRequesterArabic: [lastNameRequesterArabic],
      jobTitleRequesterArabic: [jobTitleRequesterArabic],
      departmentRequesterArabic: [departmentRequesterArabic],
      serviceNameEnglish: [serviceNameEnglish],
      serviceNameArabic: [serviceNameArabic],
      serviceDescriptionEnglish: [serviceDescriptionEnglish],
      serviceDescriptionArabic: [serviceDescriptionArabic],
      durationOfServices: [durationOfServices],
      selectedDurationUnit: [selectedDurationUnit],
      durationOfServicesTimestamp: [durationOfServicesTimestamp ?? Timestamp.now()],
      imageUrl: [imageUrl],
      providerServices: [jsonEncode(providerServices.map((e) => e.toJson()).toList())],
      limitAvailability: [limitAvailability],
      requireApproval: [requireApproval],
      selectDepartment: [jsonEncode(selectDepartment)],
      approvalCycle: [jsonEncode(approvalCycle.map((e) => e.toJson()).toList())],
      slaOneControllerEnglish: [slaOneControllerEnglish],
      slaTwoControllerEnglish: [slaTwoControllerEnglish],
      notifyRequesterChecked: [notifyRequesterChecked],
      notifyProviderChecked: [notifyProviderChecked],
      notifyManagerChecked: [notifyManagerChecked],
      notifyRequesterSwitch0: [notifyRequesterSwitch0],
      notifyManagerSwitch1: [notifyManagerSwitch1],
    );
  }

  // ✅ NEW: For CREATING/UPDATING services - includes ALL service data, NO personal requester info
  Map<String, dynamic> toJsonForCreate() {
    final Map<String, dynamic> json = {};

    // ✅ Always include timestamps
    json['timestamps'] = timestamps;

    // ✅ Core identifiers
    if (id.isNotEmpty) json['id'] = id;
    if (state.isNotEmpty) json['state'] = state;
    if (status.isNotEmpty) json['status'] = status;
    if (parentServiceId.isNotEmpty) json['Parent_Service_Id'] = parentServiceId;

    // ✅ Email Requester (ADDED)
    if (emailRequester.isNotEmpty && emailRequester.last.isNotEmpty) {
      json['Email_Requester'] = emailRequester;
    }

    // ✅ Service details (INCLUDE ALL)
    if (serviceNameEnglish.isNotEmpty) json['Service_Name_English'] = serviceNameEnglish;
    if (serviceNameArabic.isNotEmpty) json['Service_Name_Arabic'] = serviceNameArabic;
    if (serviceDescriptionEnglish.isNotEmpty) json['Service_Description_English'] = serviceDescriptionEnglish;
    if (serviceDescriptionArabic.isNotEmpty) json['Service_Description_Arabic'] = serviceDescriptionArabic;
    if (durationOfServices.isNotEmpty) json['Duration_Of_Services'] = durationOfServices;
    if (selectedDurationUnit.isNotEmpty) json['Selected_Duration_Unit'] = selectedDurationUnit;
    if (durationOfServicesTimestamp.isNotEmpty) {
      json['Duration_Of_Services_Timestamp'] = durationOfServicesTimestamp.map((v) => v.millisecondsSinceEpoch).toList();
    }

    // ✅ Image URL (only if not empty)
    if (imageUrl.isNotEmpty && imageUrl.last.isNotEmpty) {
      json['Image_Url'] = imageUrl;
    }

    // ✅ Provider and approval data
    if (providerServices.isNotEmpty && providerServices.last.isNotEmpty && providerServices.last != '[]') {
      json['Provider_Services'] = providerServices;
    }
    if (approvalCycle.isNotEmpty && approvalCycle.last.isNotEmpty && approvalCycle.last != '[]') {
      json['Approval_Cycle'] = approvalCycle;
    }
    if (selectDepartment.isNotEmpty && selectDepartment.last.isNotEmpty && selectDepartment.last != '[]') {
      json['Select_Department'] = selectDepartment;
    }

    // ✅ Boolean flags
    if (limitAvailability.isNotEmpty) json['Limit_Availability'] = limitAvailability;
    if (requireApproval.isNotEmpty) json['Require_Approval'] = requireApproval;

    // ✅ SLA fields
    if (slaOneControllerEnglish.isNotEmpty && slaOneControllerEnglish.last.isNotEmpty) {
      json['Sla_One_Controller_English'] = slaOneControllerEnglish;
    }
    if (slaTwoControllerEnglish.isNotEmpty && slaTwoControllerEnglish.last.isNotEmpty) {
      json['Sla_Two_Controller_English'] = slaTwoControllerEnglish;
    }

    // ✅ Notification settings
    if (notifyRequesterChecked.isNotEmpty) json['Notify_Requester_Checked'] = notifyRequesterChecked;
    if (notifyProviderChecked.isNotEmpty) json['Notify_Provider_Checked'] = notifyProviderChecked;
    if (notifyManagerChecked.isNotEmpty) json['Notify_Manager_Checked'] = notifyManagerChecked;
    if (notifyRequesterSwitch0.isNotEmpty) json['Notify_Requester_Switch0'] = notifyRequesterSwitch0;
    if (notifyManagerSwitch1.isNotEmpty) json['Notify_Manager_Switch1'] = notifyManagerSwitch1;

    // ✅ Assigned provider email (for requests)
    if (assignedProviderEmail.isNotEmpty && assignedProviderEmail.last.isNotEmpty) {
      json['Assigned_Provider_Email'] = assignedProviderEmail;
    }

    // ❌ EXCLUDE OTHER requester personal fields:
    // - First_Name_Requester
    // - Last_Name_Requester
    // - Department_Requester
    // - Job_Title_Requester
    // - Phone_Requester
    // - Gender_Requester
    // - First_Name_Requester_Arabic
    // - Last_Name_Requester_Arabic
    // - Job_Title_Requester_Arabic
    // - Department_Requester_Arabic

    return json;
  }

  /// The selection fields that [toJson] / [toJsonForCreate] deliberately omit
  /// when they are empty, re-expressed so an empty selection can be written.
  ///
  /// Those encoders skip `Provider_Services`, `Approval_Cycle` and
  /// `Select_Department` when the newest revision is empty or `'[]'`. That is
  /// correct for a partial write, but drafts are persisted with
  /// `update()` / `set(merge: true)`, where a missing key means "keep whatever
  /// is already stored". The result was that clearing a selection could not be
  /// saved: the previously chosen provider/approver/department came back the
  /// next time the draft was opened, looking like a default the user never
  /// picked.
  ///
  /// Callers that own the whole document (the draft repository) spread this on
  /// top of the encoded json so "nothing selected" round-trips as `['[]']`.
  static Map<String, dynamic> emptyableSelectionJson(
    ServicesHistoryModel model,
  ) {
    List<String> revisions(List<String> raw) =>
        raw.isEmpty ? <String>['[]'] : raw;

    return {
      kProviderServices: revisions(model.providerServices),
      kApprovalCycle: revisions(model.approvalCycle),
      kSelectDepartment: revisions(model.selectDepartment),
    };
  }

  // ✅ NEW: Creates a MINIMAL request with ONLY the required fields
  /// All other fields will remain as EMPTY LISTS (not included in toJsonMinimal)
  factory ServicesHistoryModel.createMinimalRequest({
    required String parentServiceId,
    required String id,
    required List<EmployeeEntityModell> providerServices,
    required List<EmployeeEntityModell> approvalCycle,
    required String state,
    required String status,
    required String emailRequester,  // ✅ ADDED
  }) {
    return ServicesHistoryModel(
      // ✅ Required fields ONLY
      timestamps: [DateTime.now().millisecondsSinceEpoch],
      parentServiceId: [parentServiceId],
      id: [id],
      providerServices: [jsonEncode(providerServices.map((e) => e.toJson()).toList())],
      selectDepartment: [],  // ✅ Empty - will not be uploaded
      emailRequester: [emailRequester],  // ✅ ADDED - will be uploaded
      approvalCycle: [jsonEncode(approvalCycle.map((e) => e.toJson()).toList())],
      state: [state],
      status: [status],

      // ✅ ALL other fields are EMPTY LISTS (won't be uploaded when using toJsonMinimal)
      firstNameRequester: [],
      lastNameRequester: [],
      departmentRequester: [],
      jobTitleRequester: [],
      phoneRequester: [],
      genderRequester: [],
      assignedProviderEmail: [],
      firstNameRequesterArabic: [],
      lastNameRequesterArabic: [],
      jobTitleRequesterArabic: [],
      departmentRequesterArabic: [],
      serviceNameEnglish: [],
      serviceNameArabic: [],
      serviceDescriptionEnglish: [],
      serviceDescriptionArabic: [],
      durationOfServices: [],
      selectedDurationUnit: [],
      durationOfServicesTimestamp: [],
      imageUrl: [],
      limitAvailability: [],
      requireApproval: [],
      slaOneControllerEnglish: [],
      slaTwoControllerEnglish: [],
      notifyRequesterChecked: [],
      notifyProviderChecked: [],
      notifyManagerChecked: [],
      notifyRequesterSwitch0: [],
      notifyManagerSwitch1: [],
    );
  }

  // Update methods - add new values to lists
  void updateServiceName(String englishName, String arabicName) {
    timestamps.add(DateTime.now().millisecondsSinceEpoch);
    serviceNameEnglish.add(englishName);
    serviceNameArabic.add(arabicName);
  }

  void updateServiceDescription(String englishDesc, String arabicDesc) {
    timestamps.add(DateTime.now().millisecondsSinceEpoch);
    serviceDescriptionEnglish.add(englishDesc);
    serviceDescriptionArabic.add(arabicDesc);
  }

  void updateStatus(String newStatus) {
    timestamps.add(DateTime.now().millisecondsSinceEpoch);
    status.add(newStatus);
  }

  void updateProviderServices(List<EmployeeEntityModell> providers) {
    timestamps.add(DateTime.now().millisecondsSinceEpoch);
    providerServices.add(jsonEncode(providers.map((e) => e.toJson()).toList()));
  }

  void updateApprovalCycle(List<EmployeeEntityModell> approvers) {
    timestamps.add(DateTime.now().millisecondsSinceEpoch);
    approvalCycle.add(jsonEncode(approvers.map((e) => e.toJson()).toList()));
  }

  void updateSelectDepartment(List<String> departments) {
    timestamps.add(DateTime.now().millisecondsSinceEpoch);
    selectDepartment.add(jsonEncode(departments));
  }

  void updateDurationTimestamp(Timestamp timestamp) {
    timestamps.add(DateTime.now().millisecondsSinceEpoch);
    durationOfServicesTimestamp.add(timestamp);
  }

  // Helper methods to get decoded values.
  // NOTE: No try/catch in the model (§11.2). These read back JSON strings that
  // were produced by this same model's encoders, guarded by empty/`[]` checks.
  List<EmployeeEntityModell> get currentProviderServices {
    if (providerServices.isEmpty) return [];

    final jsonStr = providerServices.last;
    if (jsonStr.isEmpty || jsonStr == '[]' || jsonStr == '""') return [];

    final List<dynamic> list = jsonDecode(jsonStr);
    if (list.isEmpty) return [];

    return list.map((e) => EmployeeEntityModell.fromJson(e)).toList();
  }

  List<EmployeeEntityModell> get currentApprovalCycle {
    if (approvalCycle.isEmpty) return [];

    final jsonStr = approvalCycle.last;
    if (jsonStr.isEmpty || jsonStr == '[]' || jsonStr == '""') return [];

    final List<dynamic> list = jsonDecode(jsonStr);
    return list.map((e) => EmployeeEntityModell.fromJson(e)).toList();
  }

  List<String> get currentSelectDepartment {
    if (selectDepartment.isEmpty) return [];

    final jsonStr = selectDepartment.last;
    if (jsonStr.isEmpty || jsonStr == '[]' || jsonStr == '""') return [];

    final List<dynamic> list = jsonDecode(jsonStr);
    return list.map((e) => e.toString()).toList();
  }
}
