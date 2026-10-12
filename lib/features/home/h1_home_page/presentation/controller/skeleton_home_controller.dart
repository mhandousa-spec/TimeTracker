/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: skeleton_home_controller.dart
/// Purpose: Holds the quote of the day, the current date and the modules the
///          skeleton home layout may show.
/// Author: Amr Mesbah
/// Updated: 11/8/2026 - Locale is passed in from the widget layer instead of
///          read from GetX; start-up work moved out of the constructor.

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/constants/quotes_list.dart';
import 'package:knowticed_plus/features/home/h3_app_drawer/presentation/controller/app_drawer_cubit.dart';
import 'package:knowticed_plus/features/home/h2_nav_bar/presentation/controller/nav_bar_cubit.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/modules_cubit.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/schedule_controller.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

part './skeleton_home_state.dart';

/// Converted from GetxController to Cubit.
///
/// Dependency lookup still goes through GetX (`Get.put` in
/// home_responsive_page, `Get.find` at the call sites) — only the state
/// mechanism changed. Note the former `onInit()` hook now runs from the
/// constructor: GetX does not drive lifecycle callbacks on a Cubit, so the
/// quote/module initialisation would otherwise never fire.
class SkeletonHomeController extends Cubit<SkeletonHomeState> {
  SkeletonHomeController() : super(SkeletonHomeInitial());

  String quote = "";
  String author = "";
  List<Modules> modules = [];

  List<DateTime?> selectedDate = [DateTime.now()];

  bool _initialised = false;

  /// Function Name: [init]
  ///
  /// Purpose: Start-up work that used to run in the constructor. Called by the
  ///          widget layer, which is also where the locale comes from.
  ///
  /// Parameters:
  /// - [isEnglish]: Whether the app is currently displaying English.
  void init({required bool isEnglish}) {
    if (_initialised) return;
    _initialised = true;
    getHomeQuote(isEnglish: isEnglish);
    initModules();
    emit(SkeletonHomeReady());
  }

  /// Function Name: [initFor]
  ///
  /// Purpose: Convenience entry point for widgets — runs [init] once and
  ///          re-resolves the quote on later calls so it follows a language
  ///          switch.
  ///
  /// Parameters:
  /// - [context]: Build context used to read the active locale.
  void initFor(BuildContext context) {
    final bool isEnglish =
        (Localizations.maybeLocaleOf(context)?.languageCode ?? 'en') != 'ar';
    if (_initialised) {
      getHomeQuote(isEnglish: isEnglish);
    } else {
      init(isEnglish: isEnglish);
    }
  }

  /// Function Name: [getCurrentDate]
  ///
  /// Purpose: Current date formatted as 'dd MMMM yyyy' in English or Arabic.
  ///
  /// Parameters:
  /// - [isEnglish]: Whether to format in English. Pass `context.isEnglish`.
  ///
  /// Returns: [String] the formatted date.
  String getCurrentDate({required bool isEnglish}) {
    initializeDateFormatting('ar');
    final DateTime now = DateTime.now();
    if (isEnglish) {
      return DateFormat('dd MMMM yyyy').format(now);
    }
    return DateFormat.yMMMMd('ar').format(now);
  }

  /// Function Name: [getHomeQuote]
  ///
  /// Purpose: Resolve the quote of the day and split it into quote + author.
  ///
  /// Parameters:
  /// - [isEnglish]: Whether to capitalize (English only).
  void getHomeQuote({required bool isEnglish}) {
    final String quoteAndAuthor = isEnglish
        ? FormatHelper.capitalize(getQuoteForToday())
        : getQuoteForToday();
    final List<String> splitQuote = quoteAndAuthor.split(' - ');
    quote = splitQuote[0];
    author = splitQuote.length > 1 ? splitQuote[1] : "Unknown";
  }

  /// Function Name: [initModules]
  ///
  /// Purpose: Read the allowed modules from whichever shell is registered.
  void initModules() {
    try {
      modules = Get.find<AppDrawerCubit>().allowedDrawerModules;
    } catch (_) {
      modules = Get.find<NavBarCubit>().navBarModules;
    }
  }
}
