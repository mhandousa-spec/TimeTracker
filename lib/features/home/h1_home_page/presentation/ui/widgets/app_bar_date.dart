/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: app_bar_date.dart
/// Purpose: Shows today's date, localized, in the home app bar.
/// Author: Amr Mesbah
/// Created at: 20/9/2025
/// Updated: 11/8/2026 - try/catch removed (forbidden in presentation/ui);
///          locale now comes from Localizations instead of GetX.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class AppBarDate extends StatelessWidget {
  const AppBarDate({super.key});

  /// Locales this widget formats dates for. Their symbol data is registered by
  /// [ensureDateFormattingInitialized] at app start, which is what removes the
  /// need for the old defensive try/catch around [DateFormat].
  static const List<String> supportedDateLocales = <String>['en_US', 'ar'];

  /// Function Name: [ensureDateFormattingInitialized]
  ///
  /// Purpose: Load `intl` symbol data for every supported locale. Call once
  ///          from `main()` before `runApp`. Formatting a locale whose data is
  ///          missing is what used to throw here.
  ///
  /// Returns: [Future<void>] completing when symbol data is registered.
  static Future<void> ensureDateFormattingInitialized() async {
    for (final String locale in supportedDateLocales) {
      await initializeDateFormatting(locale, null);
    }
  }

  /// Function Name: [_formattedDate]
  ///
  /// Purpose: Format today's date for the active locale.
  ///
  /// Parameters:
  /// - [context]: Build context used to read the active locale.
  ///
  /// Returns: [String] e.g. `11 August 2026`.
  String _formattedDate(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return DateFormat('dd MMMM yyyy', isArabic ? 'ar' : 'en_US')
        .format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // CHANGED 22/8/2026: was the inline
        // "assets/icons_assets/home_assets/todo_scheduled_calendar.svg" — the
        // to-do glyph, not a calendar. Routed through AppAssets rather than a
        // second string literal, since the constant for this file already
        // exists (§15, no magic asset paths in widgets).
        SvgPicture.asset(
          AppAssets.calendar,
          height: 20.sp,
          color: AppColors.icon,
        ),
        SizedBox(width: 10.sp),
        Text(
          _formattedDate(context),
          style: StyleText.fontSize18Weight500,
        ),
      ],
    );
  }
}
