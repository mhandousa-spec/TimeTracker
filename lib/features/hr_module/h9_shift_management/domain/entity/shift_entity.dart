// ***************************** FILE INFO ***************************** //
// File Name: shift_entity.dart
// Purpose: Defines the latest business values of an HR shift.
// Author: Mohamed Elrashidy
// Created At: 2026-08-23
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Represents the latest usable values of one recurring shift.
class ShiftEntity {
  const ShiftEntity({
    required this.id,
    required this.locationId,
    required this.branchId,
    required this.startMinutes,
    required this.endMinutes,
  });

  final String id;
  final String locationId;
  final String branchId;
  final int startMinutes;
  final int endMinutes;

  static const int minutesPerDay = 24 * 60;

  bool get isOvernight => endMinutes < startMinutes;

  int get durationMinutes {
    final duration = endMinutes - startMinutes;
    return duration <= 0 ? duration + minutesPerDay : duration;
  }

  String get startTimeLabel => formatMinutes(startMinutes);
  String get endTimeLabel => formatMinutes(endMinutes);

  /// Method Name: [toMinutes]
  ///
  /// Purpose: Converts a Flutter time value to minutes since midnight.
  ///
  /// Parameters:
  /// - [time]: Time selected by the user.
  ///
  /// Returns: Minutes since midnight.
  static int toMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

  /// Method Name: [fromMinutes]
  ///
  /// Purpose: Converts persisted minutes into a Flutter time value.
  ///
  /// Parameters:
  /// - [minutes]: Minutes since midnight.
  ///
  /// Returns: A Flutter [TimeOfDay].
  static TimeOfDay fromMinutes(int minutes) =>
      TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);

  /// Method Name: [formatMinutes]
  ///
  /// Purpose: Formats persisted minutes for localized UI display.
  ///
  /// Parameters:
  /// - [minutes]: Minutes since midnight.
  ///
  /// Returns: A localized time label.
  static String formatMinutes(int minutes) {
    final time = fromMinutes(minutes);
    final date = DateTime(2000, 1, 1, time.hour, time.minute);
    final locale = Get.locale?.languageCode == 'ar' ? 'ar' : 'en';
    return DateFormat('h:mm a', locale).format(date);
  }

  /// Method Name: [copyWith]
  ///
  /// Purpose: Creates a copy with selected latest values replaced.
  ///
  /// Returns: A copied current-value shift entity.
  ShiftEntity copyWith({
    String? id,
    String? locationId,
    String? branchId,
    int? startMinutes,
    int? endMinutes,
  }) {
    return ShiftEntity(
      id: id ?? this.id,
      locationId: locationId ?? this.locationId,
      branchId: branchId ?? this.branchId,
      startMinutes: startMinutes ?? this.startMinutes,
      endMinutes: endMinutes ?? this.endMinutes,
    );
  }
}
