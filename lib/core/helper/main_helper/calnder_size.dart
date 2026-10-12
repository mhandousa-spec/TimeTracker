/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: calnder_size.dart
/// Purpose: Declares `HomeHelper`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';

abstract class HomeHelper{
 static double getCalenderHeight(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    bool isDesktop = Platform.isLinux || Platform.isMacOS || Platform.isWindows;

    if (isDesktop && screenHeight >= 611 && screenHeight < 810) {
      return 0.245.w;
    } else if (isDesktop && screenHeight >= 810 && screenHeight < 900) {
      return 0.235.w;
    } else if (isDesktop && screenHeight >= 900 && screenHeight < 950) {
      return 0.22.w;
    } else if (isDesktop && screenHeight >= 950 && screenHeight < 1000) {
      return 0.2.w;
    } else if (isDesktop && screenHeight >= 1000) {
      return 0.195.w;
    }

    return 0.245.w;
  }
 static double getConditionalHeight(BuildContext context) {
   double screenHeight = MediaQuery.of(context).size.height;
   bool isDesktop = Platform.isLinux || Platform.isMacOS || Platform.isWindows;

   if (isDesktop && screenHeight >= 611 && screenHeight < 810) {
     return 0.37.h;
   } else if (isDesktop && screenHeight >= 810 && screenHeight < 900) {
     return 0.39.h;
   } else if (isDesktop && screenHeight >= 900 && screenHeight < 950) {
     return 0.41.h;
   } else if (isDesktop && screenHeight >= 950 && screenHeight < 1000) {
     return 0.43.h;
   } else if (isDesktop && screenHeight >= 1000) {
     return 0.375.h;
   }

   return 0.35.h;
 }

 static bool isDateWithinServiceRange(
     {required DateTime startDate,
       required String durationType,
       required int durationValue,
       required DateTime selectedDate})
 {
   DateTime endDate;
   switch (durationType) {
     case 'hours':
       endDate = startDate.add(Duration(hours: durationValue));
       break;
     case 'days':
       endDate = startDate.add(Duration(days: durationValue));
       break;
     case 'weeks':
       endDate = startDate.add(Duration(days: durationValue * 7));
       break;
     case 'months':
       endDate = DateTime(
           startDate.year, startDate.month + durationValue, startDate.day);
       break;
     default:
       throw ArgumentError('Invalid duration type');
   }
   return selectedDate.isAfter(startDate) && selectedDate.isBefore(endDate);
 }

 static bool isDateInRange(
     {required DateTime selectedDate,
       required DateTime startDate,
       required DateTime endDate})
 {
   return selectedDate.isAfter(startDate) && selectedDate.isBefore(endDate) ||
       selectedDate.isAtSameMomentAs(startDate) ||
       selectedDate.isAtSameMomentAs(endDate);
 }

 static Map<String, int> splitDateString(String dateString) {
   List<String> dateParts = dateString.split(' ');
   Map<String, int> monthMap = {
     'jan': 1,
     'feb': 2,
     'mar': 3,
     'apr': 4,
     'may': 5,
     'jun': 6,
     'jul': 7,
     'aug': 8,
     'sep': 9,
     'oct': 10,
     'nov': 11,
     'dec': 12,
   };

   // Return a map with day as int, month as the corresponding number, and year as int
   return {
     'day': int.parse(dateParts[0]), // Day
     'month': monthMap[dateParts[1]]!, // Month as number
     'year': int.parse(dateParts[2]), // Year
   };
 }

}