/// Module: services_management_module
/// Description: Cubit owning the Firestore upload for the bulk "upload file
///              details" (master step 1) flow: builds each row into a
///              CreateServices doc, detects create/update/delete vs the
///              existing docs for the current requester, and writes them
///              through CreateServicesRepository. The page
///              (ui/services_management_module/upload_file_details.dart) only builds row data and
///              calls uploadToFirebase() — no direct Firestore/try-catch in
///              the page (audit fix #1/#3).
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: cloud_firestore (Timestamp only), CreateServicesRepository,
///               MainCoreEmployeeController, MainCoreDepartmentCubit
/// Revision History:
///   - Initial version — extracted from
///     UploadFileDetailsTabletMaster.uploadToFirebase() / _buildServiceData()
///     (audit fix #1).
///   - Fixed "No provider data found." on every bulk-uploaded service:
///     Provider_Services / Approval_Cycle were only ever filled by the
///     unreachable `__enriched_*` switch cases, so both were persisted as "[]".
///     _parseRow now enriches the 'Service Provider' / 'Approvers' columns
///     directly. See the fallback block in _parseRow.

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:flutter/material.dart';

import 'package:knowticed_plus/features/services_management_module/main_controller/data/constants/master_upload_headers.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/domain/base_repository/service_repository.dart';

/// One parsed Excel row, keyed by the same headers used by
/// MasterUploadHeaders. Kept as a plain map (TextEditingController values)
/// so the page's existing row-editing state can be passed through unchanged.
typedef UploadFileRow = Map<String, TextEditingController>;

class UploadFileDetailsCubit {
  final CreateServicesRepository repository;
  final MainCoreEmployeeController employeeController;
  final MainCoreDepartmentCubit departmentController;

  UploadFileDetailsCubit({
    required this.repository,
    required this.employeeController,
    required this.departmentController,
  });

  /// Enriches a comma-separated email string into full employee maps —
  /// mirrors MasterUploadCubit.enrichEmailList so both flows stay consistent.
  List<Map<String, dynamic>> enrichEmailList(String emails) {
    if (emails.trim().isEmpty) return [];

    return emails
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .map((email) {
      final emp = employeeController.mapOfEmployeesWithEmailKey[email];
      return {
        'email': emp?.email ?? email,
        'firstName': emp?.firstName ?? '',
        'lastName': emp?.lastName ?? '',
        'firstNameInArabic': emp?.firstNameInArabic ?? '',
        'lastNameInArabic': emp?.lastNameInArabic ?? '',
        'middleName': emp?.middleName ?? '',
        'middleNameInArabic': emp?.middleNameInArabic ?? '',
        'title': emp?.title ?? '',
        'titleInArabic': emp?.titleInArabic ?? '',
        'departmentId': emp?.departmentId ?? '',
        'departmentNameEnglish': emp?.departmentId != null && emp!.departmentId!.isNotEmpty
            ? (departmentController.getEnglishDepartmentNameFromDepartmentId(
                    departmentId: emp.departmentId!) ??
                '')
            : '',
        'departmentNameArabic': emp?.departmentId != null && emp!.departmentId!.isNotEmpty
            ? (departmentController.getArabicDepartmentNameFromDepartmentId(
                    departmentId: emp.departmentId!) ??
                '')
            : '',
        'photo': emp?.photo ?? '',
        'gender': emp?.gender ?? '',
        'role': emp?.role ?? '',
        'state': 'pending',
        'id': emp?.id ?? '',
        'mobilePhone': {
          'phone': emp?.mobilePhone?.phone ?? '',
          'countryCode': emp?.mobilePhone?.countryCode ?? '',
          'countryApp': emp?.mobilePhone?.countryApp ?? '',
        },
      };
    }).toList();
  }

  /// Uploads every row in [formData] as a CreateServices doc, updating
  /// existing docs (matched by english service name) and creating the rest.
  /// Services that already exist but are absent from the sheet are left
  /// untouched — this is an upsert, not a replace. Returns a map of
  /// serviceName -> firestoreDocId for rows that were created/updated, so the
  /// caller (Step 2 of the master flow) can set Parent_Service_Id correctly.
  Future<Map<String, String>> uploadToFirebase({
    required List<UploadFileRow> formData,
    required String requesterEmail,
  }) async {
    final Map<String, String> serviceNameToDocId = {};
    final now = DateTime.now().millisecondsSinceEpoch;

    final existingServices = await repository.getServicesByRequesterEmail(requesterEmail);

    final Map<String, String> firebaseItems = {};
    for (final model in existingServices) {
      final key = model.currentServiceNameEnglish;
      if (key.isNotEmpty) firebaseItems[key] = model.currentId;
    }

    for (final row in formData) {
      final rowResult = _parseRow(row);
      if (rowResult.serviceNameEnglish.isEmpty) continue;

      final keyValue = rowResult.serviceNameEnglish;

      if (firebaseItems.containsKey(keyValue)) {
        final docId = firebaseItems[keyValue]!;
        await repository.updateCreateServiceDoc(
          docId,
          _buildServiceData(docId: docId, now: now, row: rowResult, requesterEmail: requesterEmail),
        );
        serviceNameToDocId[keyValue] = docId;
      } else {
        final docId = repository.newCreateServiceId();
        await repository.setCreateServiceDoc(
          docId,
          _buildServiceData(docId: docId, now: now, row: rowResult, requesterEmail: requesterEmail),
        );
        serviceNameToDocId[keyValue] = docId;
      }
    }

    // REMOVED: a pass that deleted every existing CreateServices doc whose
    // English name was absent from the uploaded sheet. It treated the
    // spreadsheet as the complete authoritative set of the account's
    // services, so uploading a 5-row file deleted every other service the
    // account owned. A bulk *upload* upserts; it must never delete rows the
    // file simply does not mention.

    return serviceNameToDocId;
  }

  _ParsedRow _parseRow(UploadFileRow row) {
    String serviceNameEnglish = '';
    String serviceNameArabic = '';
    String serviceDescriptionEnglish = '';
    String serviceDescriptionArabic = '';
    String durationOfServices = '';
    String selectedDurationUnit = '';
    List<Map<String, dynamic>> providerServicesList = [];
    String assignedProviderEmail = '';
    List<Map<String, dynamic>> approvalCycleList = [];
    bool limitAvailability = false;
    bool requireApproval = false;
    List<String> selectDepartment = [];

    // ✅ FIX ("No provider data found." on every bulk-uploaded service):
    // the raw sheet cells are captured here so the enrichment fallback below
    // can run. See that fallback for the full explanation.
    String providerEmailsRaw = '';
    String approverEmailsRaw = '';

    row.forEach((key, controller) {
      final value = controller.text.trim();
      switch (key) {
        case MasterUploadHeaders.serviceNameEn:
          serviceNameEnglish = value;
          break;
        case MasterUploadHeaders.serviceNameAr:
          serviceNameArabic = value;
          break;
        case MasterUploadHeaders.serviceDescriptionEn:
          serviceDescriptionEnglish = value;
          break;
        case MasterUploadHeaders.serviceDescriptionAr:
          serviceDescriptionArabic = value;
          break;
        case 'Duration of Service':
          durationOfServices = value;
          break;
        case 'Time Unit':
          selectedDurationUnit = value;
          break;
        case 'Service Provider':
          providerEmailsRaw = value;
          if (assignedProviderEmail.isEmpty) {
            assignedProviderEmail = value.split(',').first.trim();
          }
          break;
        case 'Approvers':
          approverEmailsRaw = value;
          break;
        case 'Requires Approvals':
          requireApproval = value.toLowerCase() == 'yes';
          break;
        case 'Limit Service Availability':
          limitAvailability = value.toLowerCase() == 'yes';
          break;
        case 'Departments':
          selectDepartment = value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
          break;
        case '__enriched_providers__':
          if (value.isNotEmpty && value != '[]') {
            try {
              final decoded = (jsonDecode(value) as List<dynamic>).cast<Map<String, dynamic>>();
              if (decoded.isNotEmpty && decoded[0]['firstName'].toString().isNotEmpty) {
                providerServicesList = decoded;
              } else {
                final rawEmail = row['Service Provider']?.text.trim() ?? '';
                providerServicesList = enrichEmailList(rawEmail);
              }
              if (providerServicesList.isNotEmpty) {
                assignedProviderEmail = providerServicesList[0]['email']?.toString() ?? '';
              }
            } catch (_) {}
          }
          break;
        case '__enriched_approvers__':
          if (value.isNotEmpty && value != '[]') {
            try {
              final decoded = (jsonDecode(value) as List<dynamic>).cast<Map<String, dynamic>>();
              if (decoded.isNotEmpty && decoded[0]['firstName'].toString().isNotEmpty) {
                approvalCycleList = decoded;
              } else {
                final rawEmail = row['Approvers']?.text.trim() ?? '';
                approvalCycleList = enrichEmailList(rawEmail);
              }
            } catch (_) {}
          }
          break;
      }
    });

    // ✅ FIX: every bulk-uploaded service opened with "No provider data found."
    // while the same service created one-by-one showed its provider fine.
    //
    // `Provider_Services` / `Approval_Cycle` were populated ONLY by the two
    // `__enriched_*` cases above — synthetic keys that nothing in the codebase
    // ever writes into the row map. Rows are built strictly from
    // MasterUploadHeaders.step1ExpectedHeaders, which contains no such column,
    // so both cases were unreachable and both fields were always persisted as
    // the string "[]".
    //
    // ServicesHistoryModel.currentProviderServices short-circuits on "[]" and
    // returns an empty list; ServiceProviderSelector.computeProvider then gets
    // zero candidates, selectServiceProviderLite returns null, and
    // ServiceInfoCardWidget's FutureBuilder falls through to
    // S.of(context).Noproviderdatafound. The single-create path never hit this
    // because it goes through ServicesHistoryModel.createNew(), which encodes
    // the real provider objects.
    //
    // The emails ARE in the sheet, so enrich them here from the same employee
    // map the master flow uses. Guarded on `isEmpty` so a future flow that does
    // inject the `__enriched_*` keys still wins.
    if (providerServicesList.isEmpty && providerEmailsRaw.isNotEmpty) {
      providerServicesList = enrichEmailList(providerEmailsRaw);
      if (providerServicesList.isNotEmpty) {
        assignedProviderEmail =
            providerServicesList.first['email']?.toString() ?? assignedProviderEmail;
      }
    }

    // Approvers are only meaningful when the row asks for approval — the page
    // already clears the cell when "Requires Approvals" is "no", but the guard
    // keeps a hand-edited row from persisting an approval cycle it disabled.
    if (approvalCycleList.isEmpty && requireApproval && approverEmailsRaw.isNotEmpty) {
      approvalCycleList = enrichEmailList(approverEmailsRaw);
    }

    return _ParsedRow(
      serviceNameEnglish: serviceNameEnglish,
      serviceNameArabic: serviceNameArabic,
      serviceDescriptionEnglish: serviceDescriptionEnglish,
      serviceDescriptionArabic: serviceDescriptionArabic,
      durationOfServices: durationOfServices,
      selectedDurationUnit: selectedDurationUnit,
      assignedProviderEmail: assignedProviderEmail,
      providerServicesList: providerServicesList,
      approvalCycleList: approvalCycleList,
      limitAvailability: limitAvailability,
      requireApproval: requireApproval,
      selectDepartment: selectDepartment,
    );
  }

  Map<String, dynamic> _buildServiceData({
    required String docId,
    required int now,
    required _ParsedRow row,
    required String requesterEmail,
  }) {
    final employee = employeeController.mapOfEmployeesWithEmailKey[requesterEmail];

    return {
      'timestamps': [now],
      'id': [docId],
      'state': ['active'],
      'status': ['active'],
      'Parent_Service_Id': [docId],

      'First_Name_Requester': [employee?.firstName ?? ''],
      'Last_Name_Requester': [employee?.lastName ?? ''],
      'Department_Requester': [employee?.departmentId ?? ''],
      'Job_Title_Requester': [employee?.title ?? ''],
      'Email_Requester': [requesterEmail],
      'Phone_Requester': [employee?.mobilePhone?.phone ?? ''],
      'Gender_Requester': [employee?.gender ?? ''],
      'Assigned_Provider_Email': [row.assignedProviderEmail],

      'First_Name_Requester_Arabic': [employee?.firstNameInArabic ?? ''],
      'Last_Name_Requester_Arabic': [employee?.lastNameInArabic ?? ''],
      'Job_Title_Requester_Arabic': [employee?.titleInArabic ?? ''],
      'Department_Requester_Arabic': [''],

      'Service_Name_English': [row.serviceNameEnglish],
      'Service_Name_Arabic': [row.serviceNameArabic],
      'Service_Description_English': [row.serviceDescriptionEnglish],
      'Service_Description_Arabic': [row.serviceDescriptionArabic],
      'Duration_Of_Services': [row.durationOfServices],
      'Selected_Duration_Unit': [row.selectedDurationUnit],
      'Duration_Of_Services_Timestamp': [Timestamp.now()],
      'Image_Url': [''],

      'Provider_Services': [jsonEncode(row.providerServicesList)],
      'Limit_Availability': [row.limitAvailability],
      'Require_Approval': [row.requireApproval],
      'Select_Department': [jsonEncode(row.selectDepartment)],
      'Approval_Cycle': [jsonEncode(row.approvalCycleList)],

      'Sla_One_Controller_English': [''],
      'Sla_Two_Controller_English': [''],
      'Notify_Requester_Checked': [false],
      'Notify_Provider_Checked': [false],
      'Notify_Manager_Checked': [false],
      'Notify_Requester_Switch0': [false],
      'Notify_Manager_Switch1': [false],
    };
  }
}

class _ParsedRow {
  final String serviceNameEnglish;
  final String serviceNameArabic;
  final String serviceDescriptionEnglish;
  final String serviceDescriptionArabic;
  final String durationOfServices;
  final String selectedDurationUnit;
  final String assignedProviderEmail;
  final List<Map<String, dynamic>> providerServicesList;
  final List<Map<String, dynamic>> approvalCycleList;
  final bool limitAvailability;
  final bool requireApproval;
  final List<String> selectDepartment;

  const _ParsedRow({
    required this.serviceNameEnglish,
    required this.serviceNameArabic,
    required this.serviceDescriptionEnglish,
    required this.serviceDescriptionArabic,
    required this.durationOfServices,
    required this.selectedDurationUnit,
    required this.assignedProviderEmail,
    required this.providerServicesList,
    required this.approvalCycleList,
    required this.limitAvailability,
    required this.requireApproval,
    required this.selectDepartment,
  });
}
