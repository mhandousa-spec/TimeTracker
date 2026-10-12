// ******************* FILE INFO *******************
// File Name: export
// Description: Export.
// Module: services_management_module / presentation/s9_admin_dashboard/ui/widgets
// *************************************************

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:get/get.dart';
// REPLACED 30/8/2026: path_provider — both getApplicationDocumentsDirectory()
// calls below wrote into the macOS sandbox container, where the user could not
// find the exported CSV. See core/helper/main_helper/export_directory.dart.
import 'package:knowticed_plus/core/helper/main_helper/export_directory.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/request_filter_dialog.dart';

class AdminExportService {
  static bool _isExporting = false;
  static OverlayEntry? _exportOverlayEntry;

  static Future<void> _showLoadingIndicator(BuildContext context) async {
    // Services mobile QA p.21 ("remove this loading"): the dark 70pt spinner
    // box stayed on screen behind the phone's Save sheet for as long as the
    // sheet was open. The save sheet is the feedback now, so no overlay is
    // shown. Kept (empty) so the callers and _hideLoadingIndicator are
    // unchanged.
  }

  static void _hideLoadingIndicator() {
    _exportOverlayEntry?.remove();
    _exportOverlayEntry = null;
  }

  static String _safeString(dynamic value) {
    if (value == null) return '';
    String str = value.toString();
    // Escape quotes and commas for CSV
    if (str.contains(',') || str.contains('"') || str.contains('\n')) {
      str = '"${str.replaceAll('"', '""')}"';
    }
    return str;
  }

  // Helper method to get requester department
  static String _getRequesterDepartment(Map<String, dynamic> item) {
    return item["requesterDepartment"]?.toString() ??
        item["departmentRequester"]?.toString() ??
        item["department"]?.toString() ??
        'N/A';
  }

  // Helper method to get job title
  static String _getJobTitle(Map<String, dynamic> item, {bool isArabic = false}) {
    if (isArabic) {
      final arabicJobTitle = item["jobTitleRequesterArabic"]?.toString() ?? '';
      if (arabicJobTitle.isNotEmpty && arabicJobTitle != 'null') {
        return arabicJobTitle;
      }
    }

    final jobTitle = item["jobTitleRequester"]?.toString() ?? '';
    return jobTitle.isNotEmpty && jobTitle != 'null' ? jobTitle : 'N/A';
  }

  static Future<bool> exportRequestsToCSV({
    required BuildContext context,
    required String fileName,
    required List<Map<String, dynamic>> displayedItems,
    String? selectStatus, // Add this parameter to determine if Department column should be included
  }) async {
    if (_isExporting) return false;

    if (fileName.isEmpty) {
      Get.snackbar(
        'Error',
        S.of(context).pleaseEnterFileName,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.orange,
        colorText: AppColors.white,
      );
      return false;
    }

    _isExporting = true;

    try {
      await _showLoadingIndicator(context);

      if (displayedItems.isEmpty) {
        _hideLoadingIndicator();
        _isExporting = false;
        Get.snackbar(
          'No Data',
          'No requests to export',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.orange,
          colorText: AppColors.white,
        );
        return false;
      }

      // The folder the user can actually open — real Downloads on desktop.
      final Directory directory = await ExportDirectory.resolve();

      // Ensure filename has .csv extension
      String finalFileName = fileName.toLowerCase().endsWith('.csv')
          ? fileName
          : '$fileName.csv';

      final filePath =
          '${directory.path}${Platform.pathSeparator}$finalFileName';
      final file = File(filePath);

      // Prepare CSV headers - match exactly what's shown in the table
      List<String> headers = ['No'];

      // Add Department column only when showing "All" status (matching table logic)
      if (selectStatus == "All") {
        headers.add('Department');
      }

      headers.addAll([
        'Service Name (EN)',
        'Service Name (AR)',
        'Service Requestor (EN)',
        'Service Requestor (AR)',
        'Requester Department',
        'Job Title (EN)',
        'Job Title (AR)',
        'Request Date',
        'Status',
        'Service Provider (EN)',
        'Service Provider (AR)',
      ]);

      List<List<dynamic>> rows = [headers];

      // Add data rows
      for (var item in displayedItems) {
        try {
          List<dynamic> row = [_safeString(item['no'])];

          // Add Department only for "All" view (matching table logic)
          if (selectStatus == "All") {
            row.add(_safeString(item['department']));
          }

          row.addAll([
            // Service Names
            _safeString(item['serviceName']),
            _safeString(item['serviceNameArabic']),

            // Requester Names
            _safeString('${item['firstNameRequester'] ?? ''} ${item['lastNameRequester'] ?? ''}'.trim()),
            _safeString('${item['firstNameRequesterArabic'] ?? ''} ${item['lastNameRequesterArabic'] ?? ''}'.trim()),

            // Requester Department (this was missing!)
            _safeString(_getRequesterDepartment(item)),

            // Job Titles (this was missing!)
            _safeString(_getJobTitle(item, isArabic: false)),
            _safeString(_getJobTitle(item, isArabic: true)),

            // Request Date
            _safeString(item['requestDate']),

            // Status
            _safeString(item['status']),

            // Provider Names
            _safeString('${item['firstNameProvider'] ?? ''} ${item['lastNameProvider'] ?? ''}'.trim()),
            _safeString('${item['firstNameProviderArabic'] ?? ''} ${item['lastNameProviderArabic'] ?? ''}'.trim()),

          ]);

          rows.add(row);
        } catch (e) {
          continue;
        }
      }

      // Convert to CSV
      StringBuffer csvBuffer = StringBuffer();
      for (List<dynamic> row in rows) {
        csvBuffer.writeln(row.join(','));
      }

      // Write file. The UTF-8 BOM is what makes Excel read the Arabic
      // department and service names as UTF-8 instead of the local codepage —
      // CSVHelper already prefixes it, these two writers were the outliers.
      const List<int> utf8Bom = <int>[0xEF, 0xBB, 0xBF];
      await file.writeAsBytes(utf8Bom + utf8.encode(csvBuffer.toString()));

      _hideLoadingIndicator();
      _isExporting = false;

      // Show success message
      await showSuccessDialog(
        lottiePath: 'assets/lottie_assets/main_lottie_assets/lottie_approved.json',
        title: S.of(context).download,
        subtitle: S.of(context).successDownloadFile,
        context: context,
      );

      return true;

    } catch (e) {
      _hideLoadingIndicator();
      _isExporting = false;

      Get.snackbar(
        'Export Failed',
        'Error: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
        duration: Duration(seconds: 5),
      );

      return false;
    }
  }

  static Future<bool> exportServicesStatsToCSV({
    required BuildContext context,
    required String fileName,
    required List<Map<String, dynamic>> allServices,
  }) async {
    if (_isExporting) return false;

    if (fileName.isEmpty) {
      Get.snackbar(
        'Error',
        S.of(context).pleaseEnterFileName,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.orange,
        colorText: AppColors.white,
      );
      return false;
    }

    _isExporting = true;

    try {
      await _showLoadingIndicator(context);

      if (allServices.isEmpty) {
        _hideLoadingIndicator();
        _isExporting = false;
        Get.snackbar(
          'No Data',
          'No services to export',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.orange,
          colorText: AppColors.white,
        );
        return false;
      }

      // The folder the user can actually open — real Downloads on desktop.
      final Directory directory = await ExportDirectory.resolve();

      // Ensure filename has .csv extension
      String finalFileName = fileName.toLowerCase().endsWith('.csv')
          ? fileName
          : '$fileName.csv';

      final filePath =
          '${directory.path}${Platform.pathSeparator}$finalFileName';
      final file = File(filePath);

      // Prepare CSV headers for services stats
      List<List<dynamic>> rows = [
        [
          'Service Name',
          'Start Date',
          'Services Done',
          'Total Hours',
        ],
      ];

      // Add data rows
      for (var service in allServices) {
        try {
          rows.add([
            _safeString(service['title']),
            _safeString(service['startDate']),
            _safeString(service['done']),
            _safeString(service['total']),
          ]);
        } catch (e) {
          continue;
        }
      }

      // Convert to CSV
      StringBuffer csvBuffer = StringBuffer();
      for (List<dynamic> row in rows) {
        csvBuffer.writeln(row.join(','));
      }

      // Write file. The UTF-8 BOM is what makes Excel read the Arabic
      // department and service names as UTF-8 instead of the local codepage —
      // CSVHelper already prefixes it, these two writers were the outliers.
      const List<int> utf8Bom = <int>[0xEF, 0xBB, 0xBF];
      await file.writeAsBytes(utf8Bom + utf8.encode(csvBuffer.toString()));

      _hideLoadingIndicator();
      _isExporting = false;

      // Show success message
      Get.snackbar(
        'Export Successful',
        'File saved: $finalFileName',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.green,
        colorText: AppColors.white,
        duration: Duration(seconds: 3),
      );

      return true;

    } catch (e) {
      _hideLoadingIndicator();
      _isExporting = false;

      Get.snackbar(
        'Export Failed',
        'Error: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
        duration: Duration(seconds: 5),
      );

      return false;
    }
  }

  static void dispose() {
    _hideLoadingIndicator();
  }
}
