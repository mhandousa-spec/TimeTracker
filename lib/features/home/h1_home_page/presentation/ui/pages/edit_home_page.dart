/// Module: home/h1_home_page
///
///*********************** FILE INFO ****************************///
/// File Name: edit_home_page.dart
/// Purpose: UI for editing home page components
/// Author: Amr Mesbah
/// Created at: 21/9/2025
/// Updated: 11/8/2026 - Added the BlocListener that surfaces HomeError. The
///          cubit had been emitting HomeError with no listener anywhere in the
///          app, so a failed layout save looked like a success to the user.

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/home_cubit.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/pages/adding_widget_page.dart';
import 'package:flutter/services.dart';

import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/home/h3_app_drawer/presentation/controller/app_drawer_cubit.dart';
import 'package:knowticed_plus/features/home/h3_app_drawer/presentation/ui/pages/custom_drawer.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/ui/pages/settings_screen.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/utils/home_constants.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/home_state.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/add_component_widget.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/app_bar_date.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/app_bar_greetings.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/dashed_icon_container.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/edit_home_page_custom_button.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/icon_selector_dialog_widget.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/remove_component_wrapper.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/home_card_metrics.dart';

import 'package:knowticed_plus/core/custom/32-custom_svg.dart';

import 'package:knowticed_plus/core/custom/33-custom_haptic.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
// The same calendar column HomeScreen renders on the right of its tablet
// layout — the editor previews the real home page, so it shows the real widget.
import 'package:knowticed_plus/features/calendar/c1_calendar/presentation/ui/pages/home_calendar_page.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
class EditHomePage extends StatelessWidget {
  EditHomePage({super.key});
  late bool isTablet;

  @override
  Widget build(BuildContext context) {
    var isMobile = ContextExtension(context).isPhone;
    isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    AppHomeCubit homeCubit = context.read<AppHomeCubit>();
    var lightMode = Theme.of(context).brightness == Brightness.light;

    // Same condition HomeScreen._tabletLayout uses for its calendar column, so
    // the editor splits left/right exactly when the real home page does.
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final bool showSideCalendar = isTablet && !isPortrait;

    return BlocListener<AppHomeCubit, HomeState>(
      // HomeError is emitted when a layout save fails. Without this listener
      // the reorder silently did nothing and the user was never told.
      listenWhen: (HomeState previous, HomeState current) =>
          current is HomeError,
      listener: (BuildContext context, HomeState state) {
        if (state is! HomeError) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              backgroundColor: AppColors.red,
              behavior: SnackBarBehavior.floating,
              content: Text(
                state.message,
                style: StyleText.fontSize16Weight400
                    .copyWith(color: AppColors.white),
              ),
            ),
          );
      },
      // CHANGED: the page frame is SideFrameMasterServices — the breadcrumb
      // frame the settings pages use — in place of the hand-built
      // Scaffold > SafeArea > Padding > Column > PaginationAppBar stack. The
      // frame supplies the SafeArea, the horizontal inset and the trail.
      //
      // TWO segments: this page is pushed with exactly ONE route, so
      // `onFirstTap` pops exactly once.
      //
      // The Scaffold stays: the frame only supplies one on phone.
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SideFrameMasterServices(
          titleText: S.of(context).settings,
          onFirstTap: () => Navigator.of(context).maybePop(),
          secondTitle: S.of(context).homeLayout,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (Get.isRegistered<AppDrawerCubit>())
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      BlocBuilder<AppDrawerCubit, AppDrawerState>(
                          bloc: Get.find<AppDrawerCubit>(),
                          builder: (BuildContext context,
                              AppDrawerState drawerState) {
                            final AppDrawerCubit drawerCubit =
                            Get.find<AppDrawerCubit>();
                            final bool isReorderingActive =
                                drawerCubit.isReorderingActive;
                            return GestureDetector(
                              onTap: () {
                                hapticController.triggerHapticFeedback(
                                    vibration: VibrateType.mediumImpact,
                                    hapticFeedback:
                                    HapticFeedback.mediumImpact);

                                drawerCubit.toggleReorderingActive();
                              },
                              child: Container(
                                width: 300.w,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius:
                                  BorderRadius.circular(8.sp),
                                  border: Border.all(
                                    color: AppColors.primary,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isReorderingActive
                                          ? Icons.check_circle
                                          : Icons.reorder,
                                      color: AppColors.textButton,
                                      size: 15.sp,
                                    ),
                                    SizedBox(width: 8.sp),
                                    Text(
                                      isReorderingActive
                                          ? S.of(context).reorderingActive
                                          : S
                                          .of(context)
                                          .enableDrawerReordering,
                                      style: StyleText.fontSize12Weight500
                                          .copyWith(
                                        color: AppColors.textButton,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                    ],
                  ),
                SizedBox(height: 20.sp),
                _expandOnTablet(
                  isMobile: isMobile,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left — the editor itself. flex 5 against the calendar's
                      // flex 3 is HomeScreen's split, so the widgets are laid
                      // out at the width they will actually get on the home
                      // page. Without the calendar it takes the row whole.
                      Expanded(
                        flex: showSideCalendar ? 5 : 1,
                        child: ScrollConfiguration(
                    behavior:
                    const ScrollBehavior().copyWith(scrollbars: false),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Drawer reordering toggle.
                          //
                          // The flag used to be a module-global RxBool declared
                          // in h3's custom_drawer.dart; it is now AppDrawerCubit
                          // state. The cubit only exists on layouts that show a
                          // drawer (it is deleted on mobile), so the toggle is
                          // hidden when it is not registered — previously it
                          // rendered there and flipped a flag nothing read.

                          // SizedBox(height: 20.sp),
                          Row(
                            spacing: 10.sp,
                            children: [
                              Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    spacing: 15.sp,
                                    children: [
                                      // ✅ FIX: Wrapped in LayoutBuilder to prevent Row overflow.
                                      // The icons row now uses Flexible so it won't overflow
                                      // when 3 icons are added.
                                      Row(
                                        spacing: 10.sp,
                                        children: [
                                          Container(
                                              padding:
                                              EdgeInsets.all(10.sp),
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color:
                                                      AppColors.primary),
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      8.sp)),
                                              child: AppBarDate()),
                                          Spacer(),

                                          // ✅ FIX: Wrapped icons row in Flexible to prevent
                                          // overflow when multiple icons are displayed.
                                          Flexible(
                                            child: BlocBuilder<AppHomeCubit,
                                                HomeState>(
                                              builder: (context, state) {
                                                return SingleChildScrollView(
                                                  scrollDirection:
                                                  Axis.horizontal,
                                                  child: Row(
                                                    spacing: 4.sp,
                                                    children: [
                                                      for (int i = 0;
                                                      i <
                                                          homeCubit
                                                              .selectedHeaderIcons
                                                              .length;
                                                      i++)
                                                        Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                              horizontal:
                                                              2.sp,
                                                              vertical:
                                                              4.sp),
                                                          child: InkWell(
                                                            onTap: () {
                                                              Navigator.of(
                                                                  context)
                                                                  .push(
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                      homeCubit
                                                                          .selectedHeaderIcons[i]
                                                                          .navigateTo(context),
                                                                ),
                                                              );
                                                            },
                                                            child:
                                                            DashedIconContainer(
                                                              svgAssetPath: homeCubit
                                                                  .selectedHeaderIcons[
                                                              i]
                                                                  .svgPath,
                                                              onMinusTap: () {
                                                                homeCubit
                                                                    .removeHeaderIcon(
                                                                    i);
                                                              },
                                                              dashColor:
                                                              AppColors
                                                                  .primary,
                                                              backgroundColor:
                                                              AppColors
                                                                  .primary,
                                                              width: 48.sp,
                                                              height: 48.sp,
                                                            ),
                                                          ),
                                                        ),

                                                      // MOVED 24/8/2026 (again): the add button is now the
                                                      // last child of the ICON STRIP, not a sibling of it.
                                                      //
                                                      // As a sibling it left dead space at the end of the
                                                      // row: `Row.spacing` inserted a gap on each side of
                                                      // it and the SizedBox added 8 more, and once three
                                                      // icons were chosen the button collapsed to
                                                      // SizedBox.shrink() while all that padding stayed —
                                                      // so the strip stopped short of the column edge with
                                                      // nothing visible in the gap.
                                                      //
                                                      // Inside the strip there is nothing after the last
                                                      // icon, so the row now ends exactly where its content
                                                      // does, and the button still follows the icons.
                                                      // MOVED 24/8/2026: the add button used to be the FIRST child of
                                                      // this row, so it sat to the LEFT of the icons already chosen and
                                                      // the row grew away from it. It belongs after them — new icons
                                                      // appear where the button is, not on the far side of the strip.
                                                      //
                                                      // Order, not alignment: in Arabic the Row mirrors with the rest of
                                                      // the UI, so "after the icons" stays correct in both directions.
                                                      BlocBuilder<AppHomeCubit,
                                                          HomeState>(
                                                        builder: (context, state) {
                                                          if (homeCubit
                                                              .selectedHeaderIcons
                                                              .length <
                                                              3) {
                                                            return InkWell(
                                                              onTap: () {
                                                                hapticController
                                                                    .triggerHapticFeedback(
                                                                    vibration:
                                                                    VibrateType
                                                                        .lightImpact,
                                                                    hapticFeedback:
                                                                    HapticFeedback
                                                                        .lightImpact);
                                                                showDialog(
                                                                  context: context,
                                                                  builder: (dialogContext) =>
                                                                      IconSelectorDialog(
                                                                        onIconSelected:
                                                                            (icon) {
                                                                          homeCubit
                                                                              .addHeaderIcon(
                                                                              icon);
                                                                        },
                                                                      ),
                                                                );
                                                              },
                                                              child: Container(
                                                                width: 25.sp,
                                                                height: 25.sp,
                                                                decoration: BoxDecoration(
                                                                    color:
                                                                    AppColors.primary,
                                                                    borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                        4.r)),
                                                                child: SizedBox(
                                                                  child: CustomSvgImage(
                                                                    assetPath:
                                                                    "assets/icons_assets/main_icons_assets/plus.svg",
                                                                    width: 12.w,
                                                                    height: 12.h,
                                                                    color: AppColors
                                                                        .textButton,
                                                                    fit: BoxFit.scaleDown,
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          } else {
                                                            return SizedBox.shrink();
                                                          }
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),

                                        ],
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(10.sp),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: AppColors.primary),
                                            borderRadius:
                                            BorderRadius.circular(8.sp)),
                                        child: const AppBarGreetings(),
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                                height: 80.sp,
                                                padding:
                                                EdgeInsets.all(10.sp),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color:
                                                        AppColors.primary),
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        8.sp)),
                                                child: Text(
                                                    context
                                                        .read<AppHomeCubit>()
                                                        .quote
                                                        ,
                                                    style: StyleText.fontSize16Weight500
                                                        .copyWith(
                                                        fontWeight:
                                                        FontWeight.w700,
                                                        color: AppColors
                                                            .text))),
                                          ),
                                        ],
                                      ),

                                      BlocBuilder<AppHomeCubit, HomeState>(
                                          builder: (_, state) {
                                            return Column(
                                              spacing: 15.sp,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                for (int rowIndex = 1;
                                                rowIndex <=
                                                    HomeConstants
                                                        .NUMBER_OF_ROWS;
                                                rowIndex++)
                                                  // The grid is always
                                                  // NUMBER_OF_COLUMNS (4) wide —
                                                  // the count is fixed by the
                                                  // layout, never derived from
                                                  // how wide the cards happen to
                                                  // be.
                                                  //
                                                  // Each slot takes the width IT
                                                  // needs: no Expanded (that
                                                  // forced every card to an
                                                  // identical quarter of the
                                                  // panel) and no fixed card
                                                  // width. Only the HEIGHT is
                                                  // pinned, by
                                                  // HomeCardMetrics.heightBox in
                                                  // item() below.
                                                  //
                                                  // spacing: HomeCardMetrics.gap
                                                  // (20.sp) is the gap BETWEEN
                                                  // two cards and nothing at the
                                                  // two outer ends — see the
                                                  // note on `gap`.
                                                  //
                                                  // ✅ RESTORED 31/8/2026: the
                                                  // horizontal scroll view.
                                                  // Natural widths mean a row's
                                                  // total is whatever its four
                                                  // cards happen to need, and a
                                                  // row of wide ones exceeded the
                                                  // panel — Flutter reported
                                                  // "RIGHT OVERFLOWED BY 61
                                                  // PIXELS" and clipped the last
                                                  // card behind a striped bar.
                                                  // A Row cannot both keep its
                                                  // children at their own width
                                                  // and guarantee they fit a
                                                  // fixed space; the scroll view
                                                  // is what makes the surplus
                                                  // reachable instead of clipped.
                                                  // COLUMN COUNT IS DERIVED,
                                                  // NOT FIXED.
                                                  //
                                                  // It was pinned to
                                                  // NUMBER_OF_COLUMNS, so on a
                                                  // wide row the slots stopped
                                                  // partway across and on a
                                                  // narrow one the last slot
                                                  // was cut off by the panel
                                                  // edge. LayoutBuilder gives
                                                  // the width actually
                                                  // available; the row then
                                                  // holds as many
                                                  // natural-width slots as fit.
                                                  //
                                                  // The +gap / (slot + gap)
                                                  // shape is what makes the
                                                  // count right: N slots have
                                                  // only N-1 gaps between them
                                                  // (Row.spacing adds nothing
                                                  // at the two outer ends), so
                                                  // lending the row one extra
                                                  // gap before dividing stops
                                                  // it dropping a slot that
                                                  // would have fitted.
                                                  //
                                                  // NUMBER_OF_COLUMNS stays as
                                                  // the FLOOR — a narrow panel
                                                  // still offers the full grid,
                                                  // reachable by scrolling.
                                                  LayoutBuilder(
                                                    builder: (BuildContext context,
                                                        BoxConstraints constraints) {
                                                      final double slot =
                                                          AddComponentWidget
                                                              .slotWidth;
                                                      final double gap =
                                                          HomeCardMetrics.gap;
                                                      final int fitCount =
                                                          ((constraints.maxWidth +
                                                                      gap) /
                                                                  (slot + gap))
                                                              .floor();
                                                      final int columnsCount =
                                                          fitCount <
                                                                  HomeConstants
                                                                      .NUMBER_OF_COLUMNS
                                                              ? HomeConstants
                                                                  .NUMBER_OF_COLUMNS
                                                              : fitCount;

                                                      return SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          spacing: gap,
                                                          children: [
                                                            for (int columnIndex = 1;
                                                                columnIndex <=
                                                                    columnsCount;
                                                                columnIndex++)
                                                              item(
                                                                  columnIndex:
                                                                      columnIndex,
                                                                  rowIndex:
                                                                      rowIndex,
                                                                  cubit:
                                                                      homeCubit)
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  )
                                              ],
                                            );
                                          })
                                    ]),
                              ),
                              // ✅ FIX: Removed the fixed-width Container(355.sp) that was
                              // causing a large empty space on the left in RTL (Arabic) mode.
                              // In RTL layouts, a trailing spacer becomes a leading spacer,
                              // pushing all content away from the drawer side.
                            ],
                          ),
                          SizedBox(height: 20.sp),
                          // Phone: the real Home page shows the month calendar
                          // at the end of its scroll (HomeScreen._mobileCalendar),
                          // so the editor shows it in the same place. Month grid
                          // only — the day timeline sits in an Expanded and this
                          // column has unbounded height.
                          if (isMobile) ...[
                            HomeCalendarWidget(
                              showDayTimeline: false,
                              currentUserEmail:
                                  Get.find<MainCoreEmployeeController>()
                                          .employeeEntity
                                          ?.email ??
                                      '',
                            ),
                            SizedBox(height: 20.sp),
                          ],
                          SizedBox(height: 10.sp),
                          EditHomePageCustomButton(),
                          SizedBox(height: 20.sp)
                        ],
                      ),
                    ),
                        ),
                      ),

                      // Right — the calendar column, landscape tablet only,
                      // matching HomeScreen. No `onDateSelected`: this page has
                      // no upcoming-schedule list to filter, it only shows
                      // where the calendar sits on the real home page.
                      if (showSideCalendar)
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: EdgeInsets.only(top: 0.sp, bottom: 15.sp),
                            child: HomeCalendarWidget(
                              currentUserEmail:
                                  Get.find<MainCoreEmployeeController>()
                                          .employeeEntity
                                          ?.email ??
                                      '',
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 20.sp)
              ],
            ),
        ),
      ),
    );
  }

  /// [child] in an [Expanded] on tablet, as-is on phone.
  ///
  /// SideFrameMasterServices hands its child UNBOUNDED height on phone — the
  /// child sits inside the frame's own SingleChildScrollView — so an Expanded
  /// there throws. On tablet the frame wraps the child in an Expanded itself,
  /// and the pinned layout keeps working unchanged.
  Widget _expandOnTablet({
    required bool isMobile,
    required Widget child,
  }) =>
      isMobile ? child : Expanded(child: child);

  Widget item(
      {required int columnIndex,
        required int rowIndex,
        required AppHomeCubit cubit}) {
    HomeComponentModel? model =
    cubit.getEditedComponent(columnIndex: columnIndex, rowIndex: rowIndex);

    return Builder(
      builder: (BuildContext context) {
        if (model == null) {
          return InkWell(
            hoverColor: AppColors.transparent,
            highlightColor: AppColors.transparent,
            splashColor: AppColors.transparent,
            onTap: () {
              cubit.selectComponentToEdit(
                  rowIndex: rowIndex, columnIndex: columnIndex);

              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => BlocProvider<AppHomeCubit>.value(
                      value: cubit, child: AddingWidgetPage())));
            },
            child: AddComponentWidget(
                columnIndex: columnIndex, rowIndex: rowIndex),
          );
        } else {
          // ✅ CHANGED 31/8/2026: heightBox, not box — HEIGHT is pinned to
          // HomeCardMetrics.height so every slot in a row lines up, WIDTH is
          // the card's own. Forcing a shared width here squeezed cards that
          // need more and padded out cards that need less.
          return RemoveComponentWrapper(
              model: model,
              component: HomeCardMetrics.heightBox(
                // SizedBox.shrink, not Container(): heightBox now bounds the
                // width (7/10/2026), and a bare Container would expand to it.
                child: model.component.widget(model) ??
                    const SizedBox.shrink(),
              ));
        }
      },
    );
  }
}