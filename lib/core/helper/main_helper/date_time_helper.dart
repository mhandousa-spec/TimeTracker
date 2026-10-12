/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: date_time_helper.dart
/// Purpose: Declares `DateTimeHelper`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/generated/l10n.dart';

///************************ FILE INFO ********************///
/// FILE NAME: date_time_helper.dart
/// PURPOSE: handle all formatting and parsing of date and time
/// Author: Amr Mesbah
/// Created at: 29/1/2025
abstract class DateTimeHelper {
  /// Method Name: [formatDateTimeMMMDDYYYY]
  ///
  /// Description: format the date time to be in MMM dd, yyyy format
  ///
  /// Parameters:
  ///            [DateTime?][dateTime] : the date time to be formatted
  ///
  /// Returns:
  ///         [String] : the formatted date time
  static String formatDateTimeMMMDDYYYY(DateTime? dateTime) {
    if (dateTime == null) return "";
    if (Get.locale.toString().contains('en')) {
      DateFormat formatter = DateFormat('MMM dd, yyyy');
      return formatter.format(dateTime);
    }
    else {
      DateFormat formatter = DateFormat('MMM dd, yyyy', 'ar');
      return formatter.format(dateTime);
    }
  }

  /// Method Name: [formatDateTimeHHMM]
  ///
  /// Description: format the date time to be in hh:mm a format
  ///
  /// Parameters:
  ///           [DateTime?][dateTime] : the date time to be formatted
  ///
  /// Returns:
  ///        [String] : the formatted date time
  static String formatDateTimeHHMM(DateTime? dateTime) {
    if (dateTime == null) return "";
    if (Get.locale.toString().contains('en')) {
      DateFormat formatter = DateFormat('hh:mm a');
      return formatter.format(dateTime);
    }
    else {
      DateFormat formatter = DateFormat('hh:mm a', 'ar');
      return formatter.format(dateTime);
    }
  }

  /// Method Name: [formatDateDDMMMYYYY]
  ///
  /// Description: format the date as "23 Aug 2026" (EN) or "23 أغسطس 2026" (AR).
  ///              Always uses Western numerals regardless of locale.
  ///
  /// Parameters:
  ///           [DateTime?][dateTime] : the date to be formatted
  ///
  /// Returns:
  ///        [String] : the formatted date, or "-" when [dateTime] is null
  static String formatDateDDMMMYYYY(DateTime? dateTime) {
    if (dateTime == null) return '-';
    final bool isArabic = !Get.locale.toString().contains('en');
    final String day = dateTime.day.toString().padLeft(2, '0');
    final String month =
        (isArabic ? _arMonths : _enMonths)[dateTime.month - 1];
    return '$day $month ${dateTime.year}';
  }

  /// Method Name: [formatDateDDMMMYYYYForLocale]
  ///
  /// Description: as [formatDateDDMMMYYYY] — "30 Aug 2026" (EN) /
  ///              "30 أغسطس 2026" (AR), Western numerals in both — but with the
  ///              language passed IN rather than read from `Get.locale`.
  ///
  ///              ADDED 30/8/2026 for callers that already know the active
  ///              language and must not reach into a service locator for it
  ///              (the `domain/` layer, which is framework-pure). Plain Dart:
  ///              no intl, no GetX, no BuildContext.
  ///
  /// Parameters:
  ///           [DateTime?][dateTime] : the date to be formatted
  ///           [bool][isArabic] : selects the Arabic month names
  ///
  /// Returns:
  ///        [String] : the formatted date, or "-" when [dateTime] is null
  static String formatDateDDMMMYYYYForLocale(
    DateTime? dateTime, {
    required bool isArabic,
  }) {
    if (dateTime == null) return '-';
    final String day = dateTime.day.toString().padLeft(2, '0');
    final String month =
        (isArabic ? _arMonths : _enMonths)[dateTime.month - 1];
    return '$day $month ${dateTime.year}';
  }

  /// Formats an integer to a locale-aware string (used for Arabic number display).
  static String formatInt(int number) {
    return NumberFormat('0', Get.locale.toString()).format(number);
  }

  /// Method Name: [formatDate]
  ///
  /// Description: formats a date as d/M/yyyy in the active locale.
  ///
  /// Returns:
  ///        [String] : the formatted date
  static String formatDate(DateTime dateTime) {
    return DateFormat('d/M/yyyy', Get.locale.toString()).format(dateTime);
  }

  /// Method Name: [formatTime]
  ///
  /// Description: formats a timestamp the way a chat list does — the time of
  /// day if it happened today, "Yesterday" if it happened yesterday, and the
  /// full date otherwise.
  ///
  /// Returns:
  ///        [String] : the formatted time
  static String formatTime(DateTime dateTime) {
    final int daysAgo = DateTime.now().difference(dateTime).inDays;
    if (daysAgo == 0) {
      return DateFormat('h:mm a', Get.locale.toString()).format(dateTime);
    } else if (daysAgo == 1) {
      return S.current.yesterday;
    }
    return DateFormat('d/M/yyyy', Get.locale.toString()).format(dateTime);
  }

  /// Method Name: [formatChatDate]
  ///
  /// Description: builds the date separator shown between groups of chat
  /// messages — "Today", "Yesterday", or "19 Feb 2026".
  ///
  /// Returns:
  ///        [String] : the separator label
  static String formatChatDate(DateTime date) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime yesterday = today.subtract(const Duration(days: 1));
    final DateTime messageDay = DateTime(date.year, date.month, date.day);

    if (messageDay == today) return S.current.today;
    if (messageDay == yesterday) return S.current.yesterday;
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// Method Name: [sortDate]
  ///
  /// Description: buckets a date into the heading used by media and message
  /// lists — "Today", "This Week", "2 Week Ago", "Last Month", a month name,
  /// "Last Year", or a year.
  ///
  /// Returns:
  ///        [String] : the bucket label
  static String sortDate(DateTime dateTime) {
    final DateTime now = DateTime.now();
    final bool isArabic = Get.locale.toString().contains('ar');

    if (dateTime.year < now.year) {
      return now.year - dateTime.year < 1
          ? S.current.lastYear
          : DateFormat.y().format(dateTime);
    }
    if (now.month - dateTime.month > 1) {
      return DateFormat.MMMM().format(dateTime);
    }
    if (now.month - dateTime.month == 1) {
      return S.current.lastMonth;
    }

    final Duration diff = now.difference(dateTime);
    if (diff.inDays >= 7) {
      final String weeks = (diff.inDays / 7).floor().toString();
      return isArabic ? 'منذ $weeks اسبوع' : '$weeks Week Ago';
    }
    return diff.inDays == 0 ? S.current.today : S.current.thisWeek;
  }

  static const List<String> _enMonths = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static const List<String> _arMonths = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];
}
