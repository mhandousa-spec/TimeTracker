/// Module: services_management_module
/// Description: CSV export helper (CSVHelper) plus provider-selection and
///              request/approval-state Firestore functions. Split via `part`
///              across csv_helper_provider_*.dart / csv_helper_state_*.dart
///              (each part ≤800 LOC) — this file holds the shared imports and
///              the CSVHelper class; see csv_helper_provider_lite.dart,
///              csv_helper_provider_main.dart, csv_helper_provider_request.dart,
///              csv_helper_provider_approval.dart, csv_helper_state_updates.dart,
///              csv_helper_state_calc.dart for the rest.
/// Author: Amr Mesbah
/// Date: 30/8/2025
/// Dependencies: csv, path_provider, cloud_firestore, get, core/network/get_base_url.dart,
///               core/network/api_constants.dart, data/models/model_employee.dart,
///               data/models/services_management_module.dart
/// Revision History: Initial version — split out of services_helper_function.dart
///                    (deleted; see audit fix #1) to satisfy the 800-LOC file cap.
import 'package:get/get.dart';

import 'dart:convert';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'dart:io';
import 'dart:math';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:knowticed_plus/core/helper/main_helper/export_directory.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
// REMOVED 30/8/2026: path_provider — the only call was the
// getApplicationDocumentsDirectory() in saveCsvToFile, now behind
// ExportDirectory. No `part` of this library uses it.

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/model_employee.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';

part 'csv_helper_provider_lite.dart';
part 'csv_helper_provider_main.dart';
part 'csv_helper_provider_request.dart';
part 'csv_helper_provider_approval.dart';
part 'csv_helper_state_updates.dart';
part 'csv_helper_state_calc.dart';

class CSVHelper {
  String createCsv(List<List<dynamic>> rows) {
    return Csv(autoDetect: false).encode(rows);
  }

  Future<File> saveCsvToFile(String csvData, String fileName) async {
    // FIXED 30/8/2026: the `else` branch here sent macOS, Windows and Linux to
    // `getApplicationDocumentsDirectory()`. Under `com.apple.security.app-sandbox`
    // that is the container's Documents folder, not `~/Documents`, so every
    // services CSV was written where the user could not find it. The Android
    // branch was already right and is preserved inside ExportDirectory.
    final Directory directory = await ExportDirectory.resolve();

    final path = '${directory.path}${Platform.pathSeparator}$fileName.csv';
    final file = File(path);

    List<int> csvBytes = utf8.encode(csvData);
    List<int> bom = [0xEF, 0xBB, 0xBF]; // Excel compatibility BOM

    return await file.writeAsBytes(bom + csvBytes);
  }

  Future<File> exportToCSV(List<List<dynamic>> rows, String fileName) async {
    final csv = createCsv(rows);
    return await saveCsvToFile(csv, fileName);
  }
}
