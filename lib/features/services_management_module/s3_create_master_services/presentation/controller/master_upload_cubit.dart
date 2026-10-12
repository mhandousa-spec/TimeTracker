/// Module: services_management_module
/// Description: Cubit owning I/O for the master (bulk) upload flow: Excel
///              file picking/parsing (steps 1 and 2), storage-permission
///              requests, email enrichment, and the Firestore upload of
///              parsed services + service-requests. Pages
///              (ui/services_management_module/master_upload.dart, ui/services_management_module/upload_details.dart)
///              call these methods instead of doing I/O + try/catch inline.
/// Author: Knowticed Team
/// Date: 02/07/2026
/// Dependencies: excel, permission_handler, MediaPickerService,
///              CreateServicesRepository, MainCoreEmployeeController,
///              MainCoreDepartmentCubit
/// Revision History:
///   - 02/07/2026 (Knowticed Team): Initial version — extracted the 8 (+2)
///     try/catch blocks and Excel/Firebase I/O out of master_upload.dart and
///     upload_details.dart (fix items 4/5).
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart' hide BorderStyle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:knowticed_plus/features/services_management_module/main_controller/data/constants/master_upload_headers.dart';
import 'package:knowticed_plus/core/services/media_picker_service.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/domain/base_repository/service_repository.dart';
import 'package:knowticed_plus/features/services_management_module/s3_create_master_services/presentation/controller/master_upload_state.dart';

/// Result of parsing a step's Excel file.
class ParsedStepResult {
  final List<Map<String, TextEditingController>> formData;
  final List<Map<String, String>> validationErrors;
  final String fileName;

  const ParsedStepResult({
    required this.formData,
    required this.validationErrors,
    required this.fileName,
  });
}

class MasterUploadCubit extends Cubit<MasterUploadState> {
  // B5 FIX: guard against emit-after-close (StateError) when the user
  // navigates away mid-await. Applies to every emit in this cubit.
  @override
  void emit(state) {
    if (isClosed) return;
    super.emit(state);
  }

  final CreateServicesRepository repository;
  final MainCoreEmployeeController employeeController;
  final MainCoreDepartmentCubit departmentController;
  final MediaPickerService _mediaPicker;

  MasterUploadCubit({
    required this.repository,
    required this.employeeController,
    required this.departmentController,
    MediaPickerService? mediaPicker,
  })  : _mediaPicker = mediaPicker ?? MediaPickerService(),
        super(MasterUploadInitial());

  bool isValidEmail(String email) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim());

  /// [enrichEmailList] resolves each email against
  /// `employeeController.mapOfEmployeesWithEmailKey`. Parsing used to run
  /// before that map was ever populated, so every provider/approver was
  /// written with an empty name, title and department — which is why service
  /// details showed "provider data not found" and approver cards rendered
  /// with a blank name after a bulk upload. Load the directory first.
  Future<void> ensureEmployeesLoaded() async {
    if (employeeController.mapOfEmployeesWithEmailKey.isEmpty) {
      await employeeController.getAllNewEmployees();
    }
  }

  /// Requests storage permission on Android/iOS. Never throws — permission
  /// denial just means the subsequent file pick will fail/cancel.
  Future<void> requestStoragePermission() async {
    if (Platform.isAndroid) {
      await Permission.manageExternalStorage.request();
    } else if (Platform.isIOS) {
      await Permission.storage.request();
    }
  }

  /// Picks and parses Step 1 (services) Excel file. Returns null if the user
  /// cancelled the picker. Throws a [MasterUploadFailure] on parse errors —
  /// callers should catch this single, well-typed exception rather than a
  /// bare try/catch around raw plugin calls.
  Future<ParsedStepResult?> pickAndParseStep1() async {
    await ensureEmployeesLoaded();
    await requestStoragePermission();
    final picked = await _mediaPicker.pickExcelFile();
    if (picked == null) return null;
    return parseStep1File(picked.bytes, picked.name);
  }

  ParsedStepResult parseStep1File(List<int> bytes, String fileName) {
    final expectedHeaders = MasterUploadHeaders.step1ExpectedHeaders;
    final excel = Excel.decodeBytes(bytes);
    List<Map<String, TextEditingController>> parsedFormData = [];
    List<Map<String, String>> parsedErrors = [];

    for (var tableName in excel.tables.keys) {
      final sheet = excel.tables[tableName];
      if (sheet == null || sheet.rows.length < 2) continue;

      final rows = sheet.rows;
      // Keep blank header cells in place. `actualHeaders.indexOf(header)` is
      // used below as a raw column index into `rows[i]`, so compacting the
      // header row with `.where(isNotEmpty)` shifted every column that came
      // after an empty header — the provider/department columns read the
      // wrong cell (or nothing at all). Step 2 already did this correctly.
      final actualHeaders = <String>[];
      for (int hi = 0; hi < rows[0].length; hi++) {
        final cell = rows[0][hi];
        actualHeaders.add(
          cell?.value == null ? '' : cell!.value.toString().trim(),
        );
      }

      // Only the *required* columns gate the parse. `length >= 3` let a file
      // missing one or two required columns through, and those fields then
      // parsed as empty strings with no warning.
      final missingHeaders = MasterUploadHeaders.step1RequiredHeaders
          .where((h) => !actualHeaders.contains(h))
          .toList();

      if (missingHeaders.isNotEmpty) {
        throw MasterUploadFailure(
            'Missing required columns: ${missingHeaders.join(', ')}',
            missingColumns: missingHeaders);
      }

      for (int i = 1; i < rows.length; i++) {
        Map<String, TextEditingController> rowCtrl = {};
        Map<String, String> rowErr = {};

        for (final header in expectedHeaders) {
          String val = '';
          if (actualHeaders.contains(header)) {
            int col = actualHeaders.indexOf(header);
            if (col < rows[i].length && rows[i][col] != null) {
              val = rows[i][col]?.value?.toString().trim() ?? '';
            }
          }
          rowCtrl[header] = TextEditingController(text: val);
        }
        parsedFormData.add(rowCtrl);
        parsedErrors.add(rowErr);
      }
      break;
    }

    // Enrich provider/approver emails while the map is guaranteed populated.
    for (final row in parsedFormData) {
      final providerRaw = row['Service Provider']?.text.trim() ?? '';
      final approverRaw = row['Approvers']?.text.trim() ?? '';
      row['__enriched_providers__'] =
          TextEditingController(text: enrichEmailsToJson(providerRaw));
      row['__enriched_approvers__'] =
          TextEditingController(text: enrichEmailsToJson(approverRaw));
    }

    return ParsedStepResult(
      formData: parsedFormData,
      validationErrors: parsedErrors,
      fileName: fileName,
    );
  }

  /// Picks and parses Step 2 (service requests) Excel file.
  Future<ParsedStepResult?> pickAndParseStep2() async {
    await ensureEmployeesLoaded();
    await requestStoragePermission();
    final picked = await _mediaPicker.pickExcelFile();
    if (picked == null) return null;
    return parseStep2File(picked.bytes, picked.name);
  }

  ParsedStepResult parseStep2File(List<int> bytes, String fileName) {
    final expectedHeaders = MasterUploadHeaders.step2ExpectedHeaders;

    Excel excel;
    try {
      excel = Excel.decodeBytes(bytes);
    } catch (decodeError) {
      throw MasterUploadFailure(
          'Cannot read this Excel file. Please re-save it as .xlsx and try again.\n\nDetails: $decodeError');
    }

    List<Map<String, TextEditingController>> parsedFormData = [];
    List<Map<String, String>> parsedErrors = [];

    for (var tableName in excel.tables.keys) {
      final sheet = excel.tables[tableName];
      if (sheet == null || sheet.rows.length < 2) continue;

      final rows = sheet.rows;

      final actualHeaders = <String>[];
      for (int hi = 0; hi < rows[0].length; hi++) {
        final cell = rows[0][hi];
        String val = '';
        if (cell != null && cell.value != null) {
          val = cell.value.toString().trim();
        }
        actualHeaders.add(val);
      }

      final missingHeaders = MasterUploadHeaders.step2RequiredHeaders
          .where((h) => !actualHeaders.contains(h))
          .toList();

      if (missingHeaders.isNotEmpty) {
        throw MasterUploadFailure(
            'Missing required columns: ${missingHeaders.join(', ')}',
            missingColumns: missingHeaders);
      }

      for (int i = 1; i < rows.length; i++) {
        bool allEmpty = true;
        for (int ci = 0; ci < rows[i].length; ci++) {
          final v = rows[i][ci]?.value?.toString().trim() ?? '';
          if (v.isNotEmpty) {
            allEmpty = false;
            break;
          }
        }
        if (allEmpty) continue;

        Map<String, TextEditingController> rowCtrl = {};
        Map<String, String> rowErr = {};

        for (final header in expectedHeaders) {
          String val = '';
          if (actualHeaders.contains(header)) {
            int col = actualHeaders.indexOf(header);
            if (col < rows[i].length) {
              final cell = rows[i][col];
              if (cell != null && cell.value != null) {
                val = cell.value.toString().trim();
              }
            }
          }
          rowCtrl[header] = TextEditingController(text: val);

          if (header != 'Approvers' && header != 'Service Name') {
            final error = validateStep2Cell(header, val);
            if (error != null) rowErr[header] = error;
          }
        }

        parsedFormData.add(rowCtrl);
        parsedErrors.add(rowErr);
      }
      break;
    }

    if (parsedFormData.isEmpty) {
      throw MasterUploadFailure('No data rows found in the file.');
    }

    return ParsedStepResult(
      formData: parsedFormData,
      validationErrors: parsedErrors,
      fileName: fileName,
    );
  }

  /// Validates a single Step 2 cell. [messages] lets the page pass in
  /// localized strings for the standard error cases (required/invalid
  /// email/etc.) so this cubit doesn't need a BuildContext.
  String? validateStep2Cell(
    String key,
    String? value, {
    Step2ValidationMessages? messages,
  }) {
    final m = messages ?? const Step2ValidationMessages();

    if (key == 'Approvers') {
      if (value == null || value.trim().isEmpty) return null;
    }

    if (value == null || value.trim().isEmpty) {
      return m.required;
    }

    value = value.trim();

    switch (key) {
      case 'Service Name':
        break;

      case 'Email Requester':
        if (!isValidEmail(value)) return m.invalidEmailFormat;
        if (!employeeController.mapOfEmployeesWithEmailKey.containsKey(value)) {
          return m.emailDoesNotExist;
        }
        break;

      case 'Service Provider':
        if (value.contains(' ')) return m.emailsCommaSeparated;
        if (value.startsWith(',') || value.endsWith(',')) {
          return m.commaAtStartOrEnd;
        }
        final emails = value.split(',').map((e) => e.trim()).toList();
        for (final email in emails) {
          if (email.isEmpty) return m.emptyEmail;
          if (!isValidEmail(email)) return m.invalidEmailFormat;
          if (!employeeController.mapOfEmployeesWithEmailKey.containsKey(email)) {
            return m.emailDoesNotExist;
          }
        }
        break;

      case 'Approvers':
        if (value.contains(' ')) return m.emailsCommaSeparated;
        if (value.startsWith(',') || value.endsWith(',')) {
          return m.commaAtStartOrEnd;
        }
        final apEmails = value.split(',').map((e) => e.trim()).toList();
        for (final email in apEmails) {
          if (email.isEmpty) return m.emptyEmail;
          if (!isValidEmail(email)) return m.invalidEmailFormat;
          if (!employeeController.mapOfEmployeesWithEmailKey.containsKey(email)) {
            return m.emailDoesNotExist;
          }
        }
        break;

      case 'State':
        const allowed = ['pending', 'approved', 'done'];
        if (!allowed.contains(value.toLowerCase())) {
          return 'State must be: pending, approved, or done';
        }
        break;

      case 'Requested Date':
        final dateRegex = RegExp(r'^\d{1,2}\s+[A-Za-z]{3}\s+\d{4}$');
        if (!dateRegex.hasMatch(value)) {
          return 'Date format must be: 12 Feb 2023';
        }
        break;
    }

    return null;
  }

  /// Parses a dropped Step 2 file's raw bytes (drag & drop entry point).
  ParsedStepResult parseDroppedStep2File(List<int> bytes, String fileName) {
    return parseStep2File(bytes, fileName);
  }

  String enrichEmailsToJson(String emails) {
    if (emails.trim().isEmpty) return '[]';
    final enriched = enrichEmailList(emails);
    return jsonEncode(enriched);
  }

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
        'departmentNameEnglish':
            emp?.departmentId != null && emp!.departmentId!.isNotEmpty
                ? (departmentController.getEnglishDepartmentNameFromDepartmentId(
                        departmentId: emp.departmentId!) ??
                    '')
                : '',
        'departmentNameArabic':
            emp?.departmentId != null && emp!.departmentId!.isNotEmpty
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

  /// Uploads Step 1's services (via [step1UploadFunction], if provided) then
  /// uploads every row of [formData] as a RequestServices doc. Returns
  /// (success, failed) counts. Never throws for per-row failures (those are
  /// counted as `failed`); may throw if [step1UploadFunction] itself throws.
  Future<(int success, int failed)> uploadRequests({
    required List<Map<String, TextEditingController>> formData,
    required Future<Map<String, String>> Function()? step1UploadFunction,
  }) async {
    // Re-enrichment happens below via enrichEmailList; the directory must be
    // in memory or every provider/approver is written name-less.
    await ensureEmployeesLoaded();

    Map<String, String> serviceNameToDocId = {};
    if (step1UploadFunction != null) {
      serviceNameToDocId = await step1UploadFunction();
    }

    int success = 0, failed = 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final formatted = DateFormat("MMMdd_yyyy").format(DateTime.now());

    for (int rowIdx = 0; rowIdx < formData.length; rowIdx++) {
      final row = formData[rowIdx];

      final serviceName = row['Service Name']?.text.trim() ?? '';
      final emailRequester = row['Email Requester']?.text.trim() ?? '';
      final serviceProviderRaw = row['Service Provider']?.text.trim() ?? '';
      final approversRaw = row['Approvers']?.text.trim() ?? '';
      final state = row['State']?.text.trim().toLowerCase() ?? 'pending';
      final requestedDate = row['Requested Date']?.text.trim() ?? '';

      if (serviceName.isEmpty || emailRequester.isEmpty) {
        failed++;
        continue;
      }

      final serviceDocId = serviceNameToDocId[serviceName] ?? serviceName;

      final providerList = enrichEmailList(serviceProviderRaw);
      final approverList = enrichEmailList(approversRaw);
      final assignedProviderEmail = providerList.isNotEmpty
          ? (providerList[0]['email']?.toString() ?? '')
          : '';

      final random = Random().nextInt(100000);
      final docId = 'Request$random$formatted';

      final Map<String, dynamic> data = {
        ServicesHistoryModel.kTimestamps: [now],
        ServicesHistoryModel.kId: [serviceDocId],
        ServicesHistoryModel.kState: [state],
        ServicesHistoryModel.kStatus: ['active'],
        ServicesHistoryModel.kParentServiceId: [serviceDocId],
        ServicesHistoryModel.kEmailRequester: [emailRequester],
        ServicesHistoryModel.kAssignedProviderEmail: [assignedProviderEmail],
        ServicesHistoryModel.kProviderServices: [jsonEncode(providerList)],
        ServicesHistoryModel.kApprovalCycle: [jsonEncode(approverList)],
        'approveComment': '',
        'requestedDate': [requestedDate],
      };

      try {
        await repository.setRequestServiceDoc(docId, data);
        success++;
      } catch (_) {
        failed++;
      }
    }

    return (success, failed);
  }
}

/// Thrown by [MasterUploadCubit] parse methods on a recoverable parse
/// failure (missing columns, unreadable file, empty file). Callers show
/// [message] to the user.
class MasterUploadFailure implements Exception {
  final String message;

  /// Expected-but-absent column headers. When non-empty the UI builds a
  /// localized message from these instead of showing [message] verbatim —
  /// the cubit has no BuildContext, so it cannot translate on its own.
  final List<String> missingColumns;

  const MasterUploadFailure(this.message, {this.missingColumns = const []});

  @override
  String toString() => message;
}

/// Optional localized messages for [MasterUploadCubit.validateStep2Cell].
/// Defaults to English so the cubit never needs a BuildContext.
class Step2ValidationMessages {
  final String required;
  final String invalidEmailFormat;
  final String emailDoesNotExist;
  final String emailsCommaSeparated;
  final String commaAtStartOrEnd;
  final String emptyEmail;

  const Step2ValidationMessages({
    this.required = 'This field is required',
    this.invalidEmailFormat = 'Invalid email format',
    this.emailDoesNotExist = 'Email does not exist',
    this.emailsCommaSeparated = 'Emails must be comma separated',
    this.commaAtStartOrEnd = 'Comma cannot be at start or end',
    this.emptyEmail = 'Email cannot be empty',
  });
}
