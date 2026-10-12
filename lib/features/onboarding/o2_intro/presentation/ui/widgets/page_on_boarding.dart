/// Module: onboarding/o2_intro
///
///*************************** FILE INFO ****************************///
/// File Name: page_on_boarding.dart
/// Purpose: One slide of the intro carousel — illustration, title, body.
/// Author: Mazen Shabaan
/// Created at: 1/September/2023
/// Updated: 12/8/2026 - CR-SKEL-O2-N01/N02/N15/N16: moved out of
///          `presentation/ui/pages/` into `presentation/ui/widgets/` (it is a
///          reusable presentational widget, not a page) and renamed from
///          `page_onBoarding.dart`, so the `ignore_for_file: file_names`
///          suppression could go; `package:get` and the internal
///          `get/get_core/src/get_main.dart` import are removed — the latter
///          reaches into GetX's private source and can break on any patch
///          release; the locale now comes from `Localizations.localeOf(context)`.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:knowticed_plus/core/constants/app_constants.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

/// A single onboarding slide.
class CustomPageView extends StatelessWidget {
  const CustomPageView({
    super.key,
    required this.title,
    required this.description,
    required this.imgurl,
  });

  final String title;
  final String description;
  final String imgurl;

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.shortestSide >
        AppConstants.tabletShortestSideBreakpoint;
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    // Latin titles carry a heavier weight than Arabic ones, which read too
    // dense at w600. Was `Get.locale.toString().contains('en')` (§13).
    final bool isEnglish = Localizations.localeOf(context).languageCode ==
        AppConstants.englishLanguageCode;

    return Container(
      // Explicit rather than inherited: AppTheme.lightTheme / darkTheme are
      // `static final`, so their `scaffoldBackgroundColor` freezes whichever
      // palette was active the first time the ThemeData was built. Reading
      // AppColors directly always reflects the live palette.
      color: AppColors.background,
      padding: EdgeInsets.only(left: 0.005.w, right: 0.005.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            imgurl,
            height: isTablet ? 0.39.h : 0.35.h,
            fit: BoxFit.fill,
          ),
          SizedBox(
            height: isTablet ? (isPortrait ? 0.04.h : 0.06.h) : 0.05.h,
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: StyleText.fontSize24Weight600.copyWith(
              height: 1.3,
              fontSize: isTablet
                  ? FontConstants.fontSize030.h
                  : FontConstants.fontSize032.h,
              // FIXED 22/8/2026: was `Theme.of(context).colorScheme
              // .secondaryContainer`. Neither ColorScheme.light nor
              // ColorScheme.dark in app_theme.dart sets `secondaryContainer`,
              // so it fell back to Material's own default — the cyan/teal seen
              // on every slide. The slide title is copy, so it takes the
              // palette's text colour, which also makes it follow dark mode.
              color: AppColors.text,
              fontWeight: isEnglish ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          SizedBox(
            height: isTablet ? (isPortrait ? 0.015.h : 0.02.h) : 0.015.h,
          ),
          Text(
            description,
            textAlign: TextAlign.center,
            softWrap: true,
            overflow: TextOverflow.fade,
            style: StyleText.fontSize18Weight500.copyWith(
              height: 1.7,
              fontSize: isTablet
                  ? FontConstants.fontSize024.h
                  : FontConstants.fontSize018.h,
              // Theme-aware grey (was the const AppColors.colorGrey, which is
              // the same value in both palettes).
              color: AppColors.darkGrey,
              fontWeight: FontWeight.w200,
            ),
          ),
        ],
      ),
    );
  }
}
