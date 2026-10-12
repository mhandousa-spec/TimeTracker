// Date: 2/9/2024
// By: Youssef Ashraf
// Last update: 2/9/2024
// Objectives: This file is responsible for providing an enums for the messaging feature.

import 'package:get/get.dart';
import 'package:knowticed_plus/generated/l10n.dart';

// ---------------- for message disappearing messages/mute chat options ------------

enum DurationValues {
  days_90,
  days_7,
  hours_8,
  hours_24,
  week_1,
  off,
  always,
}

extension GetDurationName on DurationValues {
  String get name {
    switch (this) {
      case DurationValues.days_90:
        return '90 days';
      case DurationValues.days_7:
        return '7 days';
      case DurationValues.hours_24:
        return '24 hours';
      case DurationValues.hours_8:
        return '8 hours';
      case DurationValues.week_1:
        return '1 week';
      case DurationValues.off:
        return 'Off';
      case DurationValues.always:
        return 'Always';
    }
  }
}

// ------------ for clear chat options ------------

enum ClearOptions {
  deleteStarred,
  deleteMediaFromGallery,
}

extension GetClearOptionsName on ClearOptions {
  String get name {
    switch (this) {
      case ClearOptions.deleteStarred:
        return S.current.deleteStarredMessages;
      case ClearOptions.deleteMediaFromGallery:
        return S.current.alsoDeleteMediaReceivedInThisChatFromTheDeviceGallery;
    }
  }
}

// ----------------- for sorting options in media ---------------

enum SortedDate {
  lastYear,
  lastMonth,
  thisWeek,
  weekAgo,
  month,
  year,
  today,
}

extension GetName on SortedDate {
  String getName({String? month, String? number, String? year}) {
    switch (this) {
      case SortedDate.year:
        return year!;

      case SortedDate.lastYear:
        return S.current.lastYear;

      case SortedDate.lastMonth:
        return S.current.lastMonth;

      case SortedDate.month:
        return month!;

      case SortedDate.weekAgo:
        return Get.locale.toString().contains('ar')
            ? 'منذ $number اسبوع'
            : '$number Week Ago';

      case SortedDate.thisWeek:
        return S.current.thisWeek;
      case SortedDate.today:
        return S.current.today;
    }
  }
}
