/// Module: knowledge_hub / core / submission_date_formatter.dart
/// ************************* FILE INFO *************************** ///
/// File Name: submission_date_formatter.dart
/// Purpose: Formats submission dates/times from mixed sources (Firestore
///          Timestamp, millis int, ISO string, TimeOfDay map). Owns the
///          cloud_firestore Timestamp handling so the S5 screen UI stays free
///          of the data SDK (CR-KH-S5 §3).
/// Author: Knowticed Team
/// Created At: 11/10/2025
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

/// Pure formatting helpers for submission date/time values.
abstract class SubmissionDateFormatter {
  /// Formats a date from Timestamp / int millis / ISO string / List.
  static String? formatDateTime(dynamic timestamp) {
    if (timestamp == null) return null;

    try {
      if (timestamp is List) {
        if (timestamp.isEmpty) return null;
        timestamp = timestamp.first;
      }

      if (timestamp is Timestamp) {
        return DateFormat('dd MMM yyyy').format(timestamp.toDate());
      } else if (timestamp is int) {
        final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
        return DateFormat('dd MMM yyyy').format(date);
      } else if (timestamp is String) {
        final int? ms = int.tryParse(timestamp);
        if (ms != null) {
          final date = DateTime.fromMillisecondsSinceEpoch(ms);
          return DateFormat('dd MMM yyyy').format(date);
        }
        try {
          final date = DateTime.parse(timestamp);
          return DateFormat('dd MMM yyyy').format(date);
        } catch (e) {
          debugPrint('⚠️ Could not parse date string: $timestamp');
        }
      }

      return null;
    } catch (e) {
      debugPrint('❌ Error formatting date: $e');
      return null;
    }
  }

  /// Formats a time from String / Map (TimeOfDay serialization) / List.
  static String? formatTime(dynamic timeData) {
    if (timeData == null) return null;

    try {
      if (timeData is List) {
        if (timeData.isEmpty) return null;
        timeData = timeData.first;
      }

      if (timeData is String) {
        if (timeData.contains('AM') || timeData.contains('PM')) {
          return timeData;
        }
        if (timeData.contains(':')) {
          try {
            final parts = timeData.split(':');
            if (parts.length == 2) {
              int hour = int.parse(parts[0]);
              int minute = int.parse(parts[1]);
              String period = hour >= 12 ? 'PM' : 'AM';
              int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
              return '${displayHour.toString().padLeft(2, '0')}:'
                  '${minute.toString().padLeft(2, '0')} $period';
            }
          } catch (e) {
            debugPrint('⚠️ Error parsing time string: $e');
            return timeData;
          }
        }
        return timeData;
      }

      if (timeData is Map) {
        int hour = timeData['hour'] ?? 0;
        int minute = timeData['minute'] ?? 0;
        String period = hour >= 12 ? 'PM' : 'AM';
        int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return '${displayHour.toString().padLeft(2, '0')}:'
            '${minute.toString().padLeft(2, '0')} $period';
      }

      return null;
    } catch (e) {
      debugPrint('❌ Error formatting time: $e');
      return null;
    }
  }
}
