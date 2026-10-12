// ******************* FILE INFO *******************
// File Name: table_helpers.dart
// Description: Pure formatting helpers for ServiceRequestTableWidget.
// Module: services_management_module / presentation / s9_admin_dashboard / ui / widgets
//              No widgets, no Flutter imports — plain Dart only.
// Created by: Amr Mesbah

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

class TableHelpers {
  const TableHelpers._();

  // ─── Arabic digit conversion ───────────────────────────────────────────────

  static String toArabicDigits(String input, {required bool isArabic}) {
    if (!isArabic) return input;
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const ar = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String result = input;
    for (int i = 0; i < en.length; i++) {
      result = result.replaceAll(en[i], ar[i]);
    }
    return result;
  }

  static String fmtInt(int n, {required bool isArabic}) =>
      toArabicDigits(n.toString(), isArabic: isArabic);

  // ─── Status helpers ────────────────────────────────────────────────────────

  static String getStatusText(
      String status,
      BuildContext context, {
        required bool isArabic,
      }) {
    final s = status.toLowerCase();
    if (isArabic) {
      switch (s) {
        case 'done':      return S.of(context).Done;
        case 'pending':   return S.of(context).Pending;
        case 'inprogress':return S.of(context).Inprogress;
        case 'branchsla': return S.of(context).BreachedSLA;
        case 'rejected':  return S.of(context).Rejected;
        case 'canceled':
        case 'cancel':    return S.of(context).Canceled;
        case 'approved':  return S.of(context).Approved;
        default:          return s.isNotEmpty ? s : '-';
      }
    }
    switch (s) {
      case 'cancel':
      case 'canceled': return 'Canceled';
      default:
        return s.isNotEmpty ? FormatHelper.capitalize(s) : '-';
    }
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':      return AppColors.green;
      case 'done':          return AppColors.green;
      case 'inprogress':    return AppColors.yellow;
      case 'pending':       return AppColors.orange;
      case 'rejected':      return AppColors.red;
      case 'cancel':
      case 'canceled':      return AppColors.darkRed;
      case 'branchsla':
      case 'breached sla':  return AppColors.orange;
      default:              return AppColors.black;
    }
  }

  // ─── Date formatting ───────────────────────────────────────────────────────

  static String formatDate(dynamic dateValue, {required bool isArabic}) {
    if (dateValue == null) return 'N/A';

    DateTime? dt;

    if (dateValue is Timestamp) {
      dt = dateValue.toDate();
    } else if (dateValue is Map && dateValue.containsKey('seconds')) {
      final secs = int.tryParse('${dateValue['seconds']}');
      if (secs != null) {
        dt = DateTime.fromMillisecondsSinceEpoch(secs * 1000);
      }
    } else if (dateValue is int) {
      dt = DateTime.fromMillisecondsSinceEpoch(
        dateValue > 1000000000000 ? dateValue : dateValue * 1000,
      );
    } else if (dateValue is DateTime) {
      dt = dateValue;
    } else {
      final s = dateValue.toString().trim();
      if (s.isEmpty || s == 'null') return 'N/A';
      dt = _parseDateString(s);
      if (dt == null) return s;
    }

    return _formatAsDDMonYYYY(dt!, isArabic: isArabic);
  }

  static String _formatAsDDMonYYYY(DateTime dt, {required bool isArabic}) {
    const monthsEn = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const monthsAr = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];

    final month =
    isArabic ? monthsAr[dt.month - 1] : monthsEn[dt.month - 1];
    final day =
    isArabic ? toArabicDigits(dt.day.toString(), isArabic: true) : dt.day.toString();
    final year =
    isArabic ? toArabicDigits(dt.year.toString(), isArabic: true) : dt.year.toString();

    return '$day $month $year';
  }

  static DateTime? _parseDateString(String s) {
    // W36: no try/catch — DateTime.tryParse / int.tryParse return null on failure.
    if (s.contains('T') || s.contains('-')) {
      final parsed = DateTime.tryParse(s);
      if (parsed != null) return parsed;
    }

    final regexDate = RegExp(r'(\d{4})-(\d{2})-(\d{2})');
    final m = regexDate.firstMatch(s);
    if (m != null) {
      final y = int.tryParse(m.group(1)!);
      final mo = int.tryParse(m.group(2)!);
      final d = int.tryParse(m.group(3)!);
      if (y != null && mo != null && d != null) return DateTime(y, mo, d);
    }

    if (s.contains('/')) {
      final parts = s.split('/');
      if (parts.length >= 3) {
        final y = int.tryParse(parts[2]);
        final mo = int.tryParse(parts[1]);
        final d = int.tryParse(parts[0]);
        if (y != null && mo != null && d != null) return DateTime(y, mo, d);
      }
    }

    final ts = int.tryParse(s);
    if (ts != null) {
      return DateTime.fromMillisecondsSinceEpoch(
        ts > 1000000000000 ? ts : ts * 1000,
      );
    }

    return null;
  }
}
