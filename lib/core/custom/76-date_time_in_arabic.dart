/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: date_time_in_arabic.dart
/// Purpose: Widget used by the feature's screens.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/helper/main_helper/arabic_number_format.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/helper/main_helper/extensions.dart';
Map<String, String> monthsMap = {
  'Jan': 'يناير',
  'Feb': 'فبراير',
  'Mar': 'مارس',
  'Apr': 'أبريل',
  'May': 'مايو',
  'Jun': 'يونيو',
  'Jul': 'يوليو',
  'Aug': 'أغسطس',
  'Sep': 'سبتمبر',
  'Oct': 'أكتوبر',
  'Nov': 'نوفمبر',
  'Dec': 'ديسمبر',
};
String convertNumberToEnglish(String number) {
  String englishNumber = '';
  for (int i = 0; i < number.length; i++) {
    switch (number[i]) {
      case '٠':
        englishNumber += '0';
        break;
      case '١':
        englishNumber += '1';
        break;
      case '٢':
        englishNumber += '2';
        break;
      case '٣':
        englishNumber += '3';
        break;
      case '٤':
        englishNumber += '4';
        break;
      case '٥':
        englishNumber += '5';
        break;
      case '٦':
        englishNumber += '6';
        break;
      case '٧':
        englishNumber += '7';
        break;
      case '٨':
        englishNumber += '8';
        break;
      case '٩':
        englishNumber += '9';
        break;
      case ',':
        englishNumber += '.';
        break;
      default:
        englishNumber += number[i];
    }
  }
  return englishNumber;
}

///CONVERT RANGE DATE TO ARABIC
String convertToArabicDateRange(String date) {
  String arabicDate = "";
  if (Get.locale.toString().contains("ar")) {
    date.split(" ").forEach((element) {
      if (monthsMap.containsKey(element)) {
        arabicDate = "$arabicDate ${monthsMap[element]}";
      } else if (element == "To" || element == "From") {
        arabicDate = "$arabicDate ${element}";
      } else {
        arabicDate = "$arabicDate $element";
      }
    });
    return englishArabicNumber(arabicDate);
  } else {
    return date;
  }
}

String formatTimeToArabic(String time) {
  try {
    // Parse the input time string
    DateFormat englishFormat = DateFormat("hh:mm a"); // Parsing "02:59 PM"
    DateTime dateTime = englishFormat.parse(time);

    // Format the time into Arabic
    DateFormat arabicFormat = DateFormat('h:mm a', 'ar');
    return arabicFormat.format(dateTime);
  } catch (e) {
    // Handle parsing errors and provide feedback
    return "Error parsing time: $e";
  }
}

DateFormat dateFormat = DateFormat("d MMM yyyy");
String convertToArabicDate(String date) {
  // Split the input string by comma and space
  List<String> dateParts = date.split(", ");

  // Split the date part by space to get month, day, and year
  List<String> dateComponents = dateParts[0].split(" ");

  // Define a map of English months to Arabic months

  // Convert the month to Arabic using the map
  String arabicMonth =
      monthsMap[dateComponents[0].capitalize] ?? dateComponents[0];

  // Convert the day and year to Arabic
  String arabicDay = ArabicDigits(dateComponents[1]).toArabicNumbers();
  String arabicYear = ArabicDigits(dateParts[1]).toArabicNumbers();

  // Return the Arabic date format
  return '$arabicMonth $arabicDay, $arabicYear';
}

// Function to convert numbers to Arabic


String englishArabicNumber(String number) {
  String arabicNumber = '';
  for (int i = 0; i < number.length; i++) {
    switch (number[i]) {
      case '0':
        arabicNumber += '٠';
        break;
      case '1':
        arabicNumber += '١';
        break;
      case '2':
        arabicNumber += '٢';
        break;
      case '3':
        arabicNumber += '٣';
        break;
      case '4':
        arabicNumber += '٤';
        break;
      case '5':
        arabicNumber += '٥';
        break;
      case '6':
        arabicNumber += '٦';
        break;
      case '7':
        arabicNumber += '٧';
        break;
      case '8':
        arabicNumber += '٨';
        break;
      case '9':
        arabicNumber += '٩';
        break;

      default:
        arabicNumber += number[i];
    }
  }
  return Get.locale!.toString().contains('ar') ? arabicNumber : number;
}

List<DateTime> extractDates(String input) {
  String cleanString = input.replaceAll("From ", "").replaceAll(" To ", " ");
  List<String> dateParts = cleanString.split(" ");
  String startDateStr = dateParts.sublist(0, 3).join(" ");
  String endDateStr = dateParts.sublist(3).join(" ");

  try {
    DateTime startDate = dateFormat.parse(startDateStr);
    DateTime endDate = dateFormat.parse(endDateStr);
    return [startDate, endDate];
  } catch (e) {
    return [];
  }
}

String convertToArabic(String dateStr) {
  // Define the input format
  DateFormat inputFormat = DateFormat('d MMM yyyy', 'en');

  // Parse the input date string
  DateTime date = inputFormat.parse(dateStr);

  // Define the output format with Arabic locale
  DateFormat outputFormat = DateFormat('d MMMM yyyy', 'ar');

  // Format the date to Arabic
  String formattedDate = outputFormat.format(date);
  return formattedDate;
}

String convertTimeToArabic(String timeString) {
  // Convert input time to DateTime object
  DateTime dateTime = DateFormat.jm().parse(timeString);

  // Format DateTime object to desired format
  String formattedHour =
      ArabicDigits(DateFormat('h').format(dateTime)).toArabicNumbers();
  String formattedMinute =
      ArabicDigits(DateFormat('mm').format(dateTime)).toArabicNumbers();
  String formattedAMPM = DateFormat('a').format(dateTime);

  // Map AM/PM to Arabic equivalents
  String ampmInArabic = formattedAMPM == 'AM' ? 'صباحًا' : 'مساءً';

  // Final formatted string
  String formattedTimeString = '$formattedHour:$formattedMinute $ampmInArabic';

  return formattedTimeString;
}

String translateDateFormatToArabic(String formattedDate) {
  // Define a map of English days of the week to Arabic
  Map<String, String> arabicDaysOfWeek = {
    'Monday': 'الاثنين',
    'Tuesday': 'الثلاثاء',
    'Wednesday': 'الأربعاء',
    'Thursday': 'الخميس',
    'Friday': 'الجمعة',
    'Saturday': 'السبت',
    'Sunday': 'الأحد',
  };

  try {
    // Split the formatted date to extract the day of the week, day, month, and year
    List<String> dateParts = formattedDate.split(', ');
    String dayOfWeek = dateParts[0];
    String dateWithoutDayOfWeek = dateParts[1];

    // Parse the date without the day of the week
    DateTime parsedDate =
        DateFormat('dd MMMM yyyy').parse(dateWithoutDayOfWeek);

    // Get the Arabic translation of the day of the week
    String arabicDayOfWeek = arabicDaysOfWeek[dayOfWeek] ?? '';

    // Get the Arabic translation of the month
    String arabicMonth = monthsMap[DateFormat('MMMM').format(parsedDate)] ?? '';

    // Convert the day and year to Arabic
    String arabicDay =
        ArabicDigits(DateFormat('dd').format(parsedDate)).toArabicNumbers();
    String arabicYear =
        ArabicDigits(DateFormat('yyyy').format(parsedDate)).toArabicNumbers();

    // Return the translated Arabic date format
    return '$arabicDayOfWeek، $arabicDay $arabicMonth $arabicYear';
  } catch (e) {
    return '';
  }
}

String convertToArabicDateSpaceVersion(String date) {
  // Split the input string by space
  List<String> dateComponents = date.split(" ");

  // Define a map of English months to Arabic months

  // Convert the month to Arabic using the map
  String arabicMonth = monthsMap[dateComponents[1]] ??
      dateComponents[1]; // Using full month name

  // Convert the day and year to Arabic
  String arabicDay = ArabicDigits(dateComponents[0]).toArabicNumbers();
  String arabicYear = ArabicDigits(dateComponents[2]).toArabicNumbers();

  // Return the Arabic date format
  return '$arabicDay $arabicMonth $arabicYear';
}

String translateMonthYearToArabic(String text) {
  // Check if the text already contains Arabic characters
  bool containsArabic = text.contains(RegExp(
      r'[\u0600-\u06FF\u0750-\u077F\uFB50-\uFDFF\uFE70-\uFEFF\uFB50-\uFDFF]'));

  if (containsArabic) {
    // If text contains Arabic characters, assume it's already translated
    return text;
  }

  try {
    // Split the text to separate month and year
    List<String> textParts = text.split(" ");
    String month = textParts[0];
    String year = textParts[1];

    // Translate the month into Arabic
    String arabicMonth = monthsMap[month] ?? month;

    // Translate the year into Arabic numbers
    String arabicYear = ArabicDigits(year).toArabicNumbers();

    // Return the translated date format
    return '$arabicMonth $arabicYear';
  } catch (e) {
    return '';
  }
}

String convertToArabicDateTime(String dateTimeString) {
  if (dateTimeString == '') {
    return '';
  }
  // Split the input string by comma and space
  List<String> dateParts = dateTimeString.split(", ");

  // Split the date part by space to get day, month, and year
  List<String> dateComponents = dateParts[0].split(" ");

  // Define a map of English months to Arabic months

  // Convert the month to Arabic using the map
  String arabicMonth = monthsMap[dateComponents[1]] ?? dateComponents[1];

  // Convert the day and year to Arabic
  String arabicDay = ArabicDigits(dateComponents[0]).toArabicNumbers();
  String arabicYear = ArabicDigits(dateComponents[2]).toArabicNumbers();

  // Split the time part by space to get hour, minute, and AM/PM
  List<String> timeComponents = dateParts[1].split(" ");
  String time = timeComponents[0];
  String amPm = timeComponents[1];

  // Convert AM/PM to Arabic equivalents
  String arabicAMPM = amPm == 'AM' ? 'صباحًا' : 'مساءً';

  // Return the Arabic date-time format
  return '$arabicDay $arabicMonth $arabicYear، $time $arabicAMPM';
}

String reduceNumber(int number) {
  if (number >= 1000000) {
    return '${(number / 1000000).toStringAsFixed(1)}${S.current.m}';
  } else if (number >= 1000) {
    return '${(number / 1000).toStringAsFixed(1)}${S.current.k}';
  } else {
    return '$number';
  }
}

String timeAgo(DateTime dateTime) {
  Duration diff = DateTime.now().difference(dateTime);

  String timeString;

  if (diff.inSeconds < 60) {
    timeString = Get.locale.toString().contains('en')
        ? '${diff.inSeconds} ${S.current.secondsAgo}'
        : (diff.inSeconds == 1
            ? '${"قبل ثانية"}'
            : '${"قبل ${diff.inSeconds} ثانية"}');
  } else if (diff.inMinutes < 60) {
    timeString = Get.locale.toString().contains('en')
        ? '${diff.inMinutes} ${S.current.minutesAgo}'
        : (diff.inMinutes == 1
            ? '${"قبل دقيقة"}'
            : '${"قبل ${diff.inMinutes} دقيقة"}');
  } else if (diff.inHours < 24) {
    timeString = Get.locale.toString().contains('en')
        ? '${diff.inHours} ${S.current.hoursAgo}'
        : (diff.inHours == 1
            ? '${"قبل ساعة"}'
            : '${"قبل ${diff.inHours} ساعات"}');
  } else if (diff.inDays < 7) {
    timeString = Get.locale.toString().contains('en')
        ? '${diff.inDays} ${S.current.daysAgo}'
        : (diff.inDays == 1
            ? '${"امس"}'
            : '${"قبل ${diff.inDays} ايام"}');
  } else if (diff.inDays < 30) {
    timeString = Get.locale.toString().contains('en')
        ? '${(diff.inDays / 7).floor()} ${S.current.weeksAgo}'
        : ((diff.inDays / 7).floor() == 1
            ? '${"قبل اسبوع"}'
            : '${"قبل ${(diff.inDays / 7).floor()} اسابيع"}');
  } else if (diff.inDays < 365) {
    timeString = Get.locale.toString().contains('en')
        ? '${(diff.inDays / 30).floor()} ${S.current.monthsAgo}'
        : ((diff.inDays / 30).floor() == 1
            ? '${"قبل شهر"}'
            : '${"قبل ${(diff.inDays / 30).floor()} شهور"}');
  } else {
    timeString = Get.locale.toString().contains('en')
        ? '${(diff.inDays / 365).floor()} ${S.current.yearsAgo}'
        : ((diff.inDays / 365).floor() == 1
            ? '${"قبل سنة"}'
            : '${"قبل ${(diff.inDays / 365).floor()} سنين"}');
  }

  if (Get.locale.toString().contains('ar')) {
    timeString = ArabicDigits(timeString).toArabicNumbers();
  }

  return timeString;
}

String translateDate(String original) {
  // Define month translations
  const Map<String, String> monthTranslations = {
    "Jan": "يناير",
    "Feb": "فبراير",
    "Mar": "مارس",
    "Apr": "أبريل",
    "May": "مايو",
    "Jun": "يونيو",
    "Jul": "يوليو",
    "Aug": "أغسطس",
    "Sep": "سبتمبر",
    "Oct": "أكتوبر",
    "Nov": "نوفمبر",
    "Dec": "ديسمبر"
  };

  // Define number translations
  const Map<String, String> numberTranslations = {
    '0': '٠',
    '1': '١',
    '2': '٢',
    '3': '٣',
    '4': '٤',
    '5': '٥',
    '6': '٦',
    '7': '٧',
    '8': '٨',
    '9': '٩'
  };

  // Split the input string to separate day, month, and year
  List<String> parts = original.split(" ");

  // Debug print to check the split parts

  // Translate the day part
  String dayPart = parts[0];
  String translatedDayPart = dayPart
      .split('')
      .map((char) => numberTranslations[char] ?? char)
      .join('');

  // Translate the month part
  String monthPart = parts[1];
  String translatedMonthPart = monthTranslations[monthPart] ?? monthPart;

  // Translate the year part
  String yearPart = parts[2];
  String translatedYearPart = yearPart
      .split('')
      .map((char) => numberTranslations[char] ?? char)
      .join('');

  // Combine translated parts
  String translatedDate =
      "$translatedDayPart $translatedMonthPart $translatedYearPart";

  return translatedDate;
}

String translateTime(String original) {
  // Define AM and PM translations
  const Map<String, String> amPmTranslations = {"AM": "ص", "PM": "م"};

  // Define number translations
  const Map<String, String> numberTranslations = {
    '0': '٠',
    '1': '١',
    '2': '٢',
    '3': '٣',
    '4': '٤',
    '5': '٥',
    '6': '٦',
    '7': '٧',
    '8': '٨',
    '9': '٩'
  };

  // Split the input string to separate time and period
  List<String> parts = original.split(" ");

  // Translate the time part
  String timePart = parts[0];
  String translatedTimePart = timePart
      .split('')
      .map((char) => numberTranslations[char] ?? char)
      .join('');

  // Translate AM/PM part
  String periodPart = parts[1];
  String translatedPeriodPart = amPmTranslations[periodPart] ?? periodPart;

  // Combine translated parts
  String translatedTime = "$translatedTimePart $translatedPeriodPart";

  return translatedTime;
}

String localizeNumber(String value) {
  return Get.locale.toString().contains('ar')
      ? ArabicDigits(value).toArabicNumbers()
      : value;
}

// Method to translate date to Arabic format
String translateDateTask(String date) {
  // Define Arabic numerals mapping
  final arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

  // Format the input date
  DateFormat inputFormat = DateFormat('dd/MM/yyyy');
  DateFormat outputFormat = DateFormat('dd MMMM yyyy', 'ar');
  DateTime dateTime = inputFormat.parse(date);
  String formattedDate = outputFormat.format(dateTime);

  // Translate to Arabic numerals
  String translatedDate = formattedDate.split('').map((char) {
    if (char.contains(RegExp(r'[0-9]'))) {
      return arabicNumerals[int.parse(char)];
    } else {
      return char;
    }
  }).join('');

  return translatedDate;
}

/// Function Name: [dateforamtToArabic]
///
/// Purpose: Render a stored date string in Arabic, for notification bodies.
///
/// HARDENED 25/8/2026. This accepted exactly ONE input pattern,
/// `dd MMMM yyyy, hh:mm a`, and let `DateFormat.parse` throw on anything else.
/// `UserAccessCubit.scheduleReactivation` feeds it `Constants
/// .userAccessDateFormat` ("MMM dd, yyyy"), which never matched — so the very
/// first thing the success branch did was throw
/// `FormatException: Trying to read dd from Aug 31, 2026 at 0`, and the
/// uncaught error took down the rest of the `fold`: no notification, no list
/// refresh. It was worse in Arabic, where the stored value was
/// "أغسطس ٣١, ٢٠٢٦" and could not be parsed by any English pattern at all.
///
/// Two changes: it tries the formats this app actually writes, and a value it
/// cannot parse comes back UNCHANGED instead of throwing. A notification body
/// carrying an unconverted date is a cosmetic problem; an exception on the
/// success path is a broken feature.
///
/// Parameters:
/// - [date]: a stored date string, optionally prefixed "since ".
///
/// Returns: [String] the date in Arabic, or [date] itself when unparseable.
String dateforamtToArabic(String date) {
  final String input = date.replaceAll('since ', '').trim();
  if (input.isEmpty) return date;

  // Arabic-Indic digits first: intl's `ar` locale is Latin-digit, so its own
  // parser cannot read "٣١" even with the Arabic month symbols loaded.
  const List<String> arabicIndic = <String>[
    '٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩',
  ];
  String normalized = input;
  for (int i = 0; i < arabicIndic.length; i++) {
    normalized = normalized.replaceAll(arabicIndic[i], '$i');
  }

  // Every shape this app stores, in both locales. `Constants
  // .userAccessDateFormat` is "MMM dd, yyyy" — the one that was missing.
  const List<String> patterns = <String>[
    'MMM dd, yyyy',
    'dd MMMM yyyy, hh:mm a',
    'dd MMMM yyyy',
    'MMMM dd, yyyy',
    'yyyy-MM-dd',
  ];

  final DateFormat outputFormat = DateFormat('dd MMMM yyyy HH:mm a', 'ar');

  for (final String locale in <String>['en_US', 'ar']) {
    for (final String pattern in patterns) {
      try {
        return outputFormat.format(
          DateFormat(pattern, locale).parse(normalized),
        );
      } catch (_) {
        continue;
      }
    }
  }

  try {
    return outputFormat.format(DateTime.parse(normalized));
  } catch (_) {
    // Unparseable — hand back what we were given rather than throwing.
    return date;
  }
}
