// ******************* FILE INFO *******************
// File Name: table_data_extractors.dart
// Description: All item-map field extraction for ServiceRequestTableWidget.
// Module: services_management_module / presentation / s9_admin_dashboard / ui / widgets
//              Pure data reading — no widgets, no formatting.
// Created by: Amr Mesbah

import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/ui/widgets/table_helpers.dart';

class TableDataExtractors {
  final bool isArabic;
  final Map<String, String>? enToArDepartments;

  const TableDataExtractors({
    required this.isArabic,
    this.enToArDepartments,
  });

  // ── No ────────────────────────────────────────────────────────────────────

  String getRequestNumber(Map<String, dynamic> item, int index) {
    final no = item['no'];
    final n = no is int ? no : (int.tryParse(no?.toString() ?? '') ?? index + 1);
    return TableHelpers.fmtInt(n, isArabic: isArabic);
  }

  // ── Department ────────────────────────────────────────────────────────────

  String getDepartmentName(Map<String, dynamic> item) {
    final dept = item['department']?.toString() ?? '';
    if (dept.isEmpty || dept == 'null') return 'N/A';
    if (isArabic && enToArDepartments != null) {
      return enToArDepartments![dept] ?? dept;
    }
    return dept;
  }

  // ── Service name ──────────────────────────────────────────────────────────

  String getServiceName(Map<String, dynamic> item) {
    if (isArabic) {
      final ar = item['serviceNameArabic']?.toString() ?? '';
      if (ar.isNotEmpty && ar != 'null') return ar;
    }
    final en = item['serviceName']?.toString() ?? '';
    return (en.isNotEmpty && en != 'null') ? en : 'N/A';
  }

  // ── Requester name ────────────────────────────────────────────────────────

  String getRequesterName(Map<String, dynamic> item) {
    if (isArabic) {
      final firstAr = item['firstNameRequesterArabic']?.toString().trim() ?? '';
      final lastAr = item['lastNameRequesterArabic']?.toString().trim() ?? '';
      final nameAr = '$firstAr $lastAr'.trim();
      if (nameAr.isNotEmpty &&
          !nameAr.toLowerCase().contains('null') &&
          nameAr.length > 1) return nameAr;

      final requestorAr = item['requestorArabic']?.toString().trim() ?? '';
      if (requestorAr.isNotEmpty &&
          !requestorAr.toLowerCase().contains('null') &&
          requestorAr.length > 1) return requestorAr;
    }

    final requestor = item['requestor']?.toString().trim() ?? '';
    if (requestor.isNotEmpty && !requestor.toLowerCase().contains('null')) {
      return requestor;
    }

    final firstEn = item['firstNameRequester']?.toString().trim() ?? '';
    final lastEn = item['lastNameRequester']?.toString().trim() ?? '';
    final nameEn = '$firstEn $lastEn'.trim();
    return (nameEn.isNotEmpty && !nameEn.toLowerCase().contains('null'))
        ? nameEn
        : 'N/A';
  }

  // ── Requester department ──────────────────────────────────────────────────

  String getRequesterDepartment(Map<String, dynamic> item) =>
      getDepartmentName(item);

  // ── Requester job title ───────────────────────────────────────────────────

  String getRequesterJobTitle(Map<String, dynamic> item) {
    String jobTitle = '';

    if (isArabic) {
      final ar = item['jobTitleRequesterArabic']?.toString() ?? '';
      jobTitle =
      (ar.isNotEmpty && ar != 'null') ? ar : (item['jobTitleRequester']?.toString() ?? '');
    } else {
      jobTitle = item['jobTitleRequester']?.toString() ?? '';
    }

    if (jobTitle.isEmpty || jobTitle == 'null') return 'N/A';

    // Extract abbreviation from parentheses if present
    final match = RegExp(r'\(([^)]+)\)').firstMatch(jobTitle);
    return match?.group(1) ?? jobTitle;
  }

  // ── Request date ──────────────────────────────────────────────────────────

  String getRequestDate(Map<String, dynamic> item) =>
      TableHelpers.formatDate(item['requestDate'], isArabic: isArabic);

  // ── Status ────────────────────────────────────────────────────────────────

  String getRawStatus(Map<String, dynamic> item) =>
      item['status']?.toString() ?? '';

  // ── Requester gender ──────────────────────────────────────────────────────

  String? getRequesterGender(Map<String, dynamic> item) =>
      item['gender']?.toString();

  // ── Provider gender ───────────────────────────────────────────────────────

  /// Reads from selectedProvider map first, then top-level field as fallback.
  String? getProviderGender(Map<String, dynamic> item) {
    final selectedProvider = item['selectedProvider'];
    if (selectedProvider is Map) {
      final g = selectedProvider['gender']?.toString();
      if (g != null && g.isNotEmpty) return g;
    }
    return item['providerGender']?.toString();
  }

  // ── Provider name ─────────────────────────────────────────────────────────

  String getProviderName(Map<String, dynamic> item) {
    if (isArabic) {
      final firstAr = item['firstNameProviderArabic']?.toString().trim() ?? '';
      final lastAr = item['lastNameProviderArabic']?.toString().trim() ?? '';
      final nameAr = '$firstAr $lastAr'.trim();
      if (nameAr.isNotEmpty &&
          !nameAr.toLowerCase().contains('null') &&
          nameAr.length > 1) return nameAr;

      final selectedProvider = item['selectedProvider'];
      if (selectedProvider is Map) {
        final spFirstAr =
            selectedProvider['firstNameInArabic']?.toString().trim() ?? '';
        final spLastAr =
            selectedProvider['lastNameInArabic']?.toString().trim() ?? '';
        final spNameAr = '$spFirstAr $spLastAr'.trim();
        if (spNameAr.isNotEmpty &&
            !spNameAr.toLowerCase().contains('null') &&
            spNameAr.length > 1) return spNameAr;
      }
    }

    final preComputed = item['provider']?.toString().trim() ?? '';
    if (preComputed.isNotEmpty &&
        preComputed != 'null' &&
        preComputed != 'N/A') return preComputed;

    final firstEn = item['firstNameProvider']?.toString().trim() ?? '';
    final lastEn = item['lastNameProvider']?.toString().trim() ?? '';
    final nameEn = '$firstEn $lastEn'.trim();
    if (nameEn.isNotEmpty &&
        !nameEn.toLowerCase().contains('null') &&
        nameEn.length > 1) return nameEn;

    final selectedProvider = item['selectedProvider'];
    if (selectedProvider is Map) {
      final spFirst =
          selectedProvider['firstName']?.toString().trim() ?? '';
      final spLast =
          selectedProvider['lastName']?.toString().trim() ?? '';
      final spName = '$spFirst $spLast'.trim();
      if (spName.isNotEmpty &&
          !spName.toLowerCase().contains('null') &&
          spName.length > 1) return spName;
    }

    return 'N/A';
  }

  // ── Gender util ───────────────────────────────────────────────────────────

  bool isMale(String? gender) =>
      gender?.toString().toLowerCase() == 'male';
}
