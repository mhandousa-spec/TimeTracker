/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: home_screen.dart
/// Purpose: Declares `HomeScreen`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

/// Date Created :12/November/2023
/// Developer Name : Bassem Mohamed
/// App Version : Version 2
/// Objectives: the home page.
///
/// Merged from the former mobile/home_screen_mobile.dart and
/// tablet/tablet_home_screen.dart into a single widget that branches on form
/// factor internally. The component grid was identical in both, so it now
/// lives in one place ([_buildComponentsGrid]); everything else that genuinely
/// differed (mobile greeting header vs tablet calendar column) is kept as-is.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';

import 'package:knowticed_plus/core/helper/main_helper/role_access.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/presentation/ui/pages/home_calendar_page.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/home_cubit.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/home_state.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/skeleton_home_controller.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/gradient_container.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/apply_all_modules_button.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/module_widget/tablet/home_appbar_section.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/upcoming_schedule_listview.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/utils/home_constants.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/home_card_metrics.dart';
import 'package:knowticed_plus/features/home/h2_nav_bar/presentation/controller/nav_bar_cubit.dart';
import 'package:knowticed_plus/features/home/h2_nav_bar/persistent_nav_bar.dart';
import 'package:knowticed_plus/core/custom/71-custom_appbar_mobile.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
// Provides the app-wide `employee` global used by the greeting below.
import 'package:knowticed_plus/features/settings/main_controller/presentation/ui/pages/settings_screen.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Tablet-only: the day picked in the side calendar.
  DateTime? selectedDate;

  /// Declared here rather than relying on the global that leaks out of
  /// timeline_widget.dart, which is how the former mobile page resolved it.
  final HapticController hapticController = Get.put(HapticController());

  /// Bumped after "Apply all modules" runs, so the calendar widget is rebuilt
  /// with a fresh key and reloads — the seeded entries show straight away.
  int _calendarReloadKey = 0;

  /// The "Apply all modules" card (demo accounts / debug builds only).
  List<Widget> _applyAllModules({required double gapAfter}) {
    if (!ApplyAllModulesButton.isVisible) return const <Widget>[];
    return <Widget>[
      ApplyAllModulesButton(
        onApplied: () {
          if (mounted) setState(() => _calendarReloadKey++);
        },
      ),
      SizedBox(height: gapAfter),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.width >= 768.0;

    return BlocBuilder<AppHomeCubit, HomeState>(
      buildWhen: (_, __) => true,
      builder: (context, state) {
        final homeCubit = context.read<AppHomeCubit>();
        return isTablet ? _tabletLayout(homeCubit) : _mobileLayout(context, homeCubit);
      },
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // Shared
  // ───────────────────────────────────────────────────────────────────────

  /// The dashboard component grid — identical on both form factors.
  Widget _buildComponentsGrid(AppHomeCubit homeCubit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10.sp,
      children: [
        for (int rowIndex = 0;
            rowIndex < HomeConstants.NUMBER_OF_ROWS;
            rowIndex++)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 10.sp,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CHANGED 7/10/2026 (owner): each card keeps its OWN width —
                // the same width it has in the widget picker and the layout
                // editor — instead of being forced to a shared 250. fitBox
                // only caps it at the screen width (see HomeCardMetrics).
                //
                // FIXED 13/9/2026 — `box` pins the height and scrolls the
                // overflow away inside the card, which is what clipped the
                // Forms card's third button while ~300px of panel sat empty
                // underneath. `fitBox` keeps that height as a MINIMUM and lets
                // a card grow to its content: nothing is hidden, and the page
                // only scrolls when the dashboard genuinely outgrows the pane.
                for (HomeComponentModel component
                    in homeCubit.getActiveRowComponents(rowIndex))
                  HomeCardMetrics.fitBox(
                    // SizedBox.shrink, not Container(): a bare Container
                    // expands to the width cap, which would paint a blank
                    // screen-wide slot for a stored-but-unknown component.
                    child: component.component.widget(component) ??
                        const SizedBox.shrink(),
                  )
              ],
            ),
          ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // Mobile
  // ───────────────────────────────────────────────────────────────────────

  Widget _mobileLayout(BuildContext context, AppHomeCubit homeCubit) {
    final SkeletonHomeController controller = Get.find();

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Container(
          color: AppColors.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomAppBarMobile(
                showIcon: false,
                isHome: true,
                showMoreIcon: true,
                showNotification: true,
              ),
              SizedBox(height: 10.h),
              Expanded(
                child: Container(
                  color: AppColors.background,
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _mobileDateRow(controller),
                        SizedBox(height: 10.h),
                        Text(
                          "${DateTime.now().hour < 12 ? S.of(context).goodMorning : DateTime.now().hour < 14 ? S.of(context).goodAfternoon : S.of(context).goodEvening} ${context.isEnglish ? employee!.firstName!.last!.capitalize : employee!.firstNameInArabic!.last!.capitalize}",
                          style: StyleText.fontSize25Weight600
                              .copyWith(height: 1.4),
                        ),
                        SizedBox(height: 15.h),
                        GradientContainer(),
                        SizedBox(height: 15.h),
                        // ..._applyAllModules(gapAfter: 15.h),
                        _buildComponentsGrid(homeCubit),
                        SizedBox(height: 20.h),
                        _mobileCalendar(),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The calendar, last thing on the mobile home page.
  ///
  /// ADDED 12/9/2026. The tablet layout has carried it in a right-hand column
  /// since this file was merged; mobile had nothing, so a phone user could not
  /// see the month at all from Home. It goes at the END of the scroll — below
  /// the dashboard components — because the components are what the page is
  /// for; the calendar is the thing you scroll down to.
  ///
  /// `showDayTimeline: false` — the month grid only. The timeline's header Row
  /// overflows at 375px (the "RenderFlex overflowed by 51 pixels" this page
  /// reported), and a full day of half-hour rows is more page than a dashboard
  /// summary should spend. Turning it off is also what makes the widget safe
  /// here at all: the timeline sits in an `Expanded`, which throws under the
  /// unbounded height a `SingleChildScrollView` hands its child. Without it
  /// the column is all intrinsic height, so the widget sizes itself and needs
  /// no height guess from this file.
  ///
  /// No `onDateSelected`: unlike the tablet's portrait branch there is no
  /// `UpcomingScheduleListview` here to filter, and the widget drives its own
  /// selection from its internal controller. Passing one would rebuild the
  /// whole page on every tap for nothing — which is why `edit_home_page.dart`
  /// omits it too.
  Widget _mobileCalendar() {
    return HomeCalendarWidget(
      key: ValueKey<int>(_calendarReloadKey),
      // CHANGED 13/9/2026 — the phone now gets the day section too, the one
      // the desktop column has had all along.
      //
      // It was off because the timeline lives in an `Expanded`, which throws
      // under the unbounded height a SingleChildScrollView hands its child.
      // `dayTimelineHeight` swaps that Expanded for a SizedBox, so the section
      // scrolls with the page down to its own height and the half-hour rows
      // scroll inside it. (The header Row that used to overflow at 375pt was
      // fixed separately on 12/9 — both Texts are Flexible now.)
      showDayTimeline: true,
      dayTimelineHeight: 320.h,
      currentUserEmail:
          Get.find<MainCoreEmployeeController>().employeeEntity?.email ?? '',
    );
  }

  Widget _mobileDateRow(SkeletonHomeController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              width: 22.sp,
              height: 22.sp,
              "assets/icons_assets/roles_assets/calendar.svg",
              color: AppColors.icon,
            ),
            SizedBox(width: 8.w),
            Text(
              controller.getCurrentDate(isEnglish: context.isEnglish),
              style: StyleText.fontSize20Weight500.copyWith(color: AppColors.secondaryBlack)
                  .copyWith(height: 1.8, color: AppColors.icon),
            ),
          ],
        ),
        controller.modules.contains(Modules.employees)
            ? GestureDetector(
                onTap: () {
                  hapticController.triggerHapticFeedback(
                      vibration: VibrateType.lightImpact,
                      hapticFeedback: HapticFeedback.lightImpact);
                  if (Get.find<NavBarCubit>()
                      .navBarModules
                      .contains(Modules.employees)) {
                    RoleAccess.controller.jumpToTab(Get.find<NavBarCubit>()
                        .navBarModules
                        .indexOf(Modules.employees));
                  } else {
                    PersistentNavBarNavigator.pushNewScreen(context,
                        pageTransitionAnimation: PageTransitionAnimation.fade,
                        withNavBar: true,
                        screen: Modules.employees.widget);
                  }
                },
                child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.signOut,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.all(8.h),
                    child: SvgPicture.asset(
                      "assets/icons_assets/roles_assets/organization_chart_tree.svg",
                      color: AppColors.black,
                    )),
              )
            : const SizedBox()
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // Tablet
  // ───────────────────────────────────────────────────────────────────────

  Widget _tabletLayout(AppHomeCubit homeCubit) {
    final bool lightMode = Theme.of(context).brightness == Brightness.light;
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Container(
          color: AppColors.background,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Section - Main Content
              Expanded(
                flex: 5,
                child: Container(
                  // FIXED 13/9/2026 — was `isPortrait ? 930.h : 699.h`.
                  //
                  // A hardcoded height cannot know how tall the window
                  // actually is. `.h` scales against the design size, not the
                  // real viewport, so this pane came out around 91% of the
                  // screen: the last ~9% sat empty below it while the content
                  // inside scrolled, i.e. the page asked you to scroll for
                  // rows that would have fitted on screen.
                  //
                  // double.infinity in a bounded Row takes the full available
                  // height instead. The SingleChildScrollView below stays as
                  // the safety net for a genuinely over-long dashboard —
                  // removing it would turn that case into a RenderFlex
                  // overflow — but it no longer scrolls content that fits.
                  height: double.infinity,
                  color: AppColors.background,
                  padding: EdgeInsetsDirectional.only(
                    start: 20.w,
                    end: isPortrait ? 20.w : 10.w,
                  ),
                  child: ScrollConfiguration(
                    behavior:
                        const ScrollBehavior().copyWith(scrollbars: false),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(flex: 1, child: HomeAppbarSection()),
                              SizedBox(width: 0.sp),
                            ],
                          ),
                          SizedBox(height: 20.sp),
                          // ..._applyAllModules(gapAfter: 20.sp),
                          _buildComponentsGrid(homeCubit),

                          // Portrait mode schedule section
                          if (isPortrait) SizedBox(height: 30.h),
                          if (isPortrait)
                            Text(S.of(context).upcomingSchedule,
                                style: StyleText.fontSize20Weight500.copyWith(
                                    color: lightMode
                                        ? AppColors.red
                                        : AppColors.white)),
                          if (isPortrait)
                            UpcomingScheduleListview(
                                selectedDate: selectedDate != null
                                    ? [selectedDate!]
                                    : [DateTime.now()]),
                          if (!isPortrait) SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Right Section - Calendar (only in landscape)
              if (!isPortrait)
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.only(top: 15.sp, bottom: 15.sp),
                    child: HomeCalendarWidget(
                      key: ValueKey<int>(_calendarReloadKey),
                      currentUserEmail: Get.find<MainCoreEmployeeController>()
                              .employeeEntity
                              ?.email ??
                          '',
                      onDateSelected: (date) {
                        setState(() {
                          selectedDate = date;
                        });
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
