/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: preview_page.dart
/// Purpose: Declares `HomePreview`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:get/get.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/gradient_container.dart';
import 'package:device_frame/device_frame.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/helper/main_helper/pagination_app_bar.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/core/new_theme.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/home_cubit.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/home_state.dart';
import 'package:knowticed_plus/core/extensions/calendar_package/src/models/calendar_date_picker2_config.dart';
import 'package:knowticed_plus/core/custom/72-custom_calendar_picker.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/utils/home_constants.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/app_bar_date.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/app_bar_greetings.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/upcoming_schedule_listview.dart';

import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/settings/se8_watermark/presentation/ui/widgets/watermark_layer.dart';

class HomePreview extends StatelessWidget {
  const HomePreview({super.key});

  @override
  Widget build(BuildContext context) {
    var isMobile = ContextExtension(context).isPhone;
    bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final homeCubit = context.read<AppHomeCubit>();
    var l = S.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      // WATERMARK 25/8/2026. Wrapped here rather than relying on an ancestor: on
      // the phone branch this page is pushed onto an OUTER navigator, so it is
      // not a descendant of the wrapped HomeResponsivePage. On tablet it is,
      // and the inner layer then hands its child straight back — see the
      // nesting note in watermark_layer.dart.
      body: WatermarkLayer(
        module: Modules.settings, // ADDED 28/9/2026 — Home Layout is a settings page
        child: SafeArea(
        child: Padding(
          padding: EdgeInsetsDirectional.only(
              start: isTablet ? 30.sp : 15.sp, end: 15.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [



              PaginationAppBar(screensTitles: [
                S.of(context).settings,
                 S.of(context).homeLayout,
                S.of(context).homePreview
              ]),

              SizedBox(height: 20.sp),

              // Preview Mode Tabs
              BlocBuilder<AppHomeCubit, HomeState>(
                builder: (context, state) {
                  return Row(
                    spacing: isMobile ? 40.sp : 30.sp,
                    children: [
                      _buildPreviewTab(
                        context: context,
                        title: l.desktopView,
                        mode: PreviewMode.desktop,
                        isSelected: homeCubit.currentPreviewMode == PreviewMode.desktop,
                        onTap: () => homeCubit.setPreviewMode(PreviewMode.desktop),
                      ),
                      _buildPreviewTab(
                        context: context,
                        title: l.tabletView,
                        mode: PreviewMode.tablet,
                        isSelected: homeCubit.currentPreviewMode == PreviewMode.tablet,
                        onTap: () => homeCubit.setPreviewMode(PreviewMode.tablet),
                      ),
                      _buildPreviewTab(
                        context: context,
                        title: l.mobileView,
                        mode: PreviewMode.mobile,
                        isSelected: homeCubit.currentPreviewMode == PreviewMode.mobile,
                        onTap: () => homeCubit.setPreviewMode(PreviewMode.mobile),
                      ),
                    ],
                  );
                },
              ),

              SizedBox(height: 20.sp),

              // Preview Content with Device Simulation and Animation
              Expanded(
                child: BlocBuilder<AppHomeCubit, HomeState>(
                  builder: (context, state) {
                    return Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                                CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutCubic,
                                ),
                              ),
                              child: child,
                            ),
                          );
                        },
                        child: _buildDevicePreview(
                          context,
                          homeCubit,
                          key: ValueKey(homeCubit.currentPreviewMode),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 20.sp),

              // ADDED 13/8/2026: the preview screen had Back and Discard but no
              // Save, so a layout you had just previewed could only be kept by
              // going back and pressing Save on the edit screen. Mirrors the
              // Preview / Save pair in EditHomePageCustomButton, and calls the
              // same `updateHomeComponents()` so both routes persist
              // identically.
              Row(
                children: [
                  customButton(
                    width: 150.w,
                    height: 38.h,
                    color: AppColors.darkGrey,
                    title: S.of(context).back,
                    textStyle: StyleText.fontSize16Weight500.copyWith(
                      color: AppColors.text
                    ),
                    function: () {
                      Navigator.of(context).pop();
                    },),
                  const Spacer(),
                  customButton(
                    width: 150.w,
                    height: 38.h,
                    color: AppColors.primary,
                    title: S.of(context).Save,
                    textStyle: StyleText.fontSize16Weight500.copyWith(
                      color: AppColors.textButton
                    ),
                    function: () {
                      context.read<AppHomeCubit>().updateHomeComponents();
                      Navigator.of(context).pop();
                    },)
                ],
              ),

              SizedBox(height: 20.sp),
              Row(
                children: [
                  customButton(
                    width: 150.w,
                    height: 38.h,
                    color: AppColors.darkGrey,
                    title: S.of(context).discardChange,
                    textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.text
                    ),
                    function: () {
                      Navigator.of(context).pop();
                    },)
                ],
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  // Build Preview Tab Button with animation
  Widget _buildPreviewTab({
    required BuildContext context,
    required String title,
    required PreviewMode mode,
    required bool isSelected,
    required VoidCallback onTap,
  }) {

    var isMobile = ContextExtension(context).isPhone;
    var lightMode = Theme.of(context).brightness == Brightness.light;

    return GestureDetector(
      onTap: onTap,
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: isMobile ? StyleText.fontSize16Weight700.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? (AppColors.secondaryPrimary)
                    : (AppColors.secondaryText),
              ): StyleText.fontSize20Weight500.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? (AppColors.secondaryPrimary)
                    : (AppColors.secondaryText),
              ),
              child: Text(title),
            ),
            SizedBox(height: 2.sp),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: isSelected ? 1.sp : 0,
              color: isSelected
                  ? (AppColors.secondaryPrimary)
                  : (AppColors.secondaryText),
            ),
          ],
        ),
      ),
    );
  }

  // Build Device Preview with Specific Dimensions
  Widget _buildDevicePreview(
      BuildContext context,
      AppHomeCubit homeCubit, {
        Key? key,
      })
  {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    double deviceWidth;
    double deviceHeight;
    bool showSidebar;
    DeviceInfo device;

    switch (homeCubit.currentPreviewMode) {
      case PreviewMode.desktop:
        deviceWidth = MediaQuery.sizeOf(context).width;
        deviceHeight = MediaQuery.sizeOf(context).height;
        showSidebar = true;
        device = Devices.macOS.macBookPro;
        break;
      case PreviewMode.tablet:
        deviceWidth = 768;
        deviceHeight = 1024;
        showSidebar = true;
        device = Devices.ios.iPadPro13InchesM4;
        break;
      case PreviewMode.mobile:
        deviceWidth = 375;
        deviceHeight = 812;
        showSidebar = false;
        device = Devices.ios.iPhone13;
        break;
    }

    return DeviceFrame(
      key: key,
      device: device,
      screen: Container(
        color: lightMode ? AppColors.white : AppColors.background,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            size: Size(deviceWidth, deviceHeight),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(15.sp),
              child: Column(
                children: [
                  SizedBox(height: 30.sp),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 15.sp,
                          children: [
                            Row(
                              spacing: 10.sp,
                              children: [
                                AppBarDate(),
                              ],
                            ),
                            const AppBarGreetings(),
                            GradientContainer(),
                            Column(
                              spacing: 15.sp,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (int rowIndex = 0;
                                rowIndex < HomeConstants.NUMBER_OF_ROWS;
                                rowIndex++)
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      spacing: 15.sp,
                                      children: [
                                        for (HomeComponentModel model
                                        in homeCubit.getEditRowComponents(rowIndex))
                                          model.component.widget(model) ?? Container(),
                                      ],
                                    ),
                                  )
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 15.sp),
                      if (showSidebar)
                        Container(
                          width: 355.sp,
                          child: _buildPreviewScheduleSection(context),
                        )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Real calendar widget for preview (without Expanded)
  Widget _buildPreviewScheduleSection(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    List<DateTime?> selectedDate = [DateTime.now()];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 25.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.0),
            color: AppColors.primary,
          ),
          child: CustomCalendarPicker(
            calendarType: CalendarDatePicker2Type.single,
            isHome: true,
            selectedDate: selectedDate,
            selectedDateState: (value) {
              // Preview mode - don't update
            },
          ),
        ),
        SizedBox(height: 20.h),
        Text(
          S.of(context).upcomingSchedule,
          style: StyleText.fontSize22Weight700.copyWith(
            color: lightMode  ? AppColors.red : AppColors.red
          ),
        ),
        Container(
          height: 300.h,
          child: UpcomingScheduleListview(selectedDate: selectedDate),
        ),
      ],
    );
  }
}