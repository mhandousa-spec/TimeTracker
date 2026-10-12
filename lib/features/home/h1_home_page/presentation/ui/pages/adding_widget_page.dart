/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: adding_widget_page.dart
/// Purpose: Declares `AddingWidgetPage`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/8-custom_filter_app.dart';
import 'package:knowticed_plus/core/custom/9-filter_tab_with_container.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/home/h3_app_drawer/presentation/controller/app_drawer_cubit.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/core/new_theme.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/home_cubit.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/add_component_wrapper.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/home_card_metrics.dart';
import 'package:knowticed_plus/features/settings/se8_watermark/presentation/ui/widgets/watermark_layer.dart';

class AddingWidgetPage extends StatefulWidget {
  AddingWidgetPage({super.key});

  @override
  State<AddingWidgetPage> createState() => _AddingWidgetPageState();
}

class _AddingWidgetPageState extends State<AddingWidgetPage> {
  // Card size lives in HomeCardMetrics, shared with the layout editor
  // (edit_home_page.dart) and the dashboard (home_screen.dart). It used to be
  // a pair of getters here, which sized the picker only and left the other two
  // screens ragged.

  int selectedTab = 0; // 0 for Widgets, 1 for Chart & Graph

  /// Canonical key for the "show everything" chip.
  static const String _allKey = 'All';

  /// Selected chip key: [_allKey] or a `Modules.name`.
  String selectedModuleKey = _allKey;

  /// Every widget the picker can offer, before any filter.
  List<HomeComponentModel> get _allComponents =>
      context.read<AppHomeCubit>().readyToAddComponent;

  /// Function Name: [_allowedModules]
  ///
  /// Purpose: The modules this employee's role actually grants, or `null` when
  ///          that cannot be determined.
  ///
  /// `null` and "empty list" mean different things and must not be conflated:
  /// no cubit means *unknown*, and the picker then shows everything rather than
  /// nothing.
  Set<Modules>? get _allowedModules {
    if (!Get.isRegistered<AppDrawerCubit>()) return null;
    final List<Modules> allowed = Get.find<AppDrawerCubit>().allowedDrawerModules;
    if (allowed.isEmpty) return null;
    return allowed.toSet();
  }

  /// Function Name: [_grantedComponents]
  ///
  /// Purpose: Every component the employee is actually entitled to add.
  ///
  /// FIXED 13/8/2026: the picker offered every component in
  /// `readyToAddComponent`, while the filter chips were built only from modules
  /// in `allowedDrawerModules`. Two consequences, both reported:
  ///
  ///  1. "الكل" counted components whose module had no chip, so the chips could
  ///     never sum to the total — the 14 / 0 / 1 on the add-widget screen.
  ///  2. Widgets for modules the account does not have were listed and could be
  ///     added to the home layout at all.
  ///
  /// Both are the same gap, so both close here: the entitlement filter now
  /// applies to the components themselves, and the counts derive from the
  /// filtered list. A component with no module is kept — it belongs to no
  /// module, so no grant can exclude it, and it is counted under "الكل" only.
  List<HomeComponentModel> get _grantedComponents {
    final Set<Modules>? allowed = _allowedModules;
    if (allowed == null) return _allComponents;

    return _allComponents.where((m) {
      final Modules? module = m.component.module;
      return module == null || allowed.contains(module);
    }).toList();
  }

  /// Components for the active tab: plain widgets on tab 0, charts on tab 1.
  /// Both come from the same readyToAddComponent list, so a chart is added to
  /// the layout by exactly the same AddComponentWrapper flow as a widget.
  List<HomeComponentModel> get _tabComponents => _grantedComponents
      .where((m) => m.component.isChart == (selectedTab == 1))
      .toList();

  Map<Modules, int> _countsFor(List<HomeComponentModel> models) {
    final counts = <Modules, int>{};
    for (final model in models) {
      final module = model.component.module;
      if (module == null) continue;
      counts[module] = (counts[module] ?? 0) + 1;
    }
    return counts;
  }

  /// Widgets per module. Counted off [_grantedComponents], not
  /// [_allComponents], so the chips and the "الكل" total describe the same set.
  Map<Modules, int> get _widgetCounts =>
      _countsFor(_grantedComponents.where((m) => !m.component.isChart).toList());

  /// Charts per module.
  Map<Modules, int> get _chartCounts =>
      _countsFor(_grantedComponents.where((m) => m.component.isChart).toList());

  /// Counts for whichever tab is showing — the chips describe what you're
  /// actually looking at.
  Map<Modules, int> get _activeCounts =>
      selectedTab == 0 ? _widgetCounts : _chartCounts;

  int get _activeTotal => _tabComponents.length;

  /// Modules that (a) the employee's role actually has and (b) own at least one
  /// widget or chart. Deliberately spans BOTH tabs so the chip row doesn't
  /// reshuffle when you switch between Widget and Chart & Graph.
  List<Modules> get _filterModules {
    final Set<Modules> withContent = {
      ..._widgetCounts.keys,
      ..._chartCounts.keys,
    };

    if (!Get.isRegistered<AppDrawerCubit>()) return withContent.toList();

    final List<Modules> allowed =
        Get.find<AppDrawerCubit>().allowedDrawerModules;
    // Entitlement unknown — mirror [_grantedComponents] and show everything
    // that has content rather than collapsing the row to nothing.
    if (allowed.isEmpty) return withContent.toList();

    // Keep the drawer's ordering so the chips match the rail the user knows.
    return allowed.where(withContent.contains).toList();
  }

  List<HomeComponentModel> get _visibleComponents {
    if (selectedModuleKey == _allKey) return _tabComponents;
    return _tabComponents
        .where((m) => m.component.module?.name == selectedModuleKey)
        .toList();
  }

  // ── Filter chips ──────────────────────────────────────────────────────────

  /// Uses the shared StatusChipFilter (core/custom/8-custom_filter_app.dart) so
  /// this page's filter looks and behaves like every other filter in the app.
  Widget _moduleFilter() {
    final modules = _filterModules;

    // Nothing to filter by — don't take up a row for a lone "All" chip.
    if (modules.isEmpty) return const SizedBox.shrink();

    final counts = _activeCounts;

    return StatusChipFilter(
      selectedKey: selectedModuleKey,
      onSelected: (key) => setState(() => selectedModuleKey = key),
      items: [
        StatusChipItem(
          key: _allKey,
          label: S.of(context).all,
          count: _activeTotal,
        ),
        ...modules.map(
          (module) => StatusChipItem(
            key: module.name,
            label: module.getModuleName,
            count: counts[module] ?? 0,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // CHANGED 23/8/2026: was
    // `EdgeInsetsDirectional.only(start: isTablet ? 30.sp : 15.sp, end: 15.sp)`
    // — one flat 15.sp on both sides now, so the leading edge is the same on
    // phone and tablet and every child starts from the same line. `isTablet`
    // went with that breakpoint (its only reader), along with an already-unused
    // `lightMode` local.
    //
    // Horizontal only, deliberately: the app bar sits flush at the top as it
    // did before, and the column already ends with its own 20.sp spacer.
    //
    // The cards carry a further inset of their own — AddComponentWrapper pads
    // each one by 12 to reserve room for the gear badge — so the grid sits
    // 15 + 12 from the edge, not 15.
    final bool isMobile = MediaQuery.of(context).size.shortestSide < 600;

    // CHANGED: the page frame is SideFrameMasterServices — the breadcrumb
    // frame the settings pages use — in place of the hand-built
    // SafeArea > Padding > Column > PaginationAppBar stack. The frame supplies
    // the SafeArea and the 15.sp horizontal inset, so both went with it.
    //
    // THREE segments, and the pop counts are load-bearing. This page is two
    // routes deep (Settings > Home Layout > Adding Widget), and
    // PaginationAppBar encoded that as `length - (i + 1)` pops. The frame takes
    // the callbacks instead, so the same counts are written out: "Settings"
    // pops twice, "Home" once. On phone the frame collapses the trail to the
    // last segment plus a back chevron, which pops once.
    return Scaffold(
      backgroundColor: AppColors.background,
        // WATERMARK 25/8/2026. Wrapped here rather than relying on an ancestor: on
        // the phone branch this page is pushed onto an OUTER navigator, so it is
        // not a descendant of the wrapped HomeResponsivePage. On tablet it is,
        // and the inner layer then hands its child straight back — see the
        // nesting note in watermark_layer.dart.
        body: WatermarkLayer(
          module: Modules.settings, // ADDED 28/9/2026 — Home Layout is a settings page
          child: SideFrameMasterServices(
            titleText: S.of(context).settings,
            onFirstTap: () {
              // Two routes deep — Adding Widget and Home Layout both come off.
              Navigator.of(context)
                ..pop()
                ..pop();
            },
            secondTitle: S.of(context).home,
            onSecondTap: () => Navigator.of(context).maybePop(),
            thirdTitle: S.of(context).addingWidget,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                _expandOnTablet(
                  isMobile: isMobile,
                  child: ScrollConfiguration(
                    behavior: const ScrollBehavior().copyWith(scrollbars: false),
                    child: SingleChildScrollView(
                      child: Column(
                        // A Column centres its children by default, and the
                        // Wrap below sizes to its runs rather than to the full
                        // width — so a row of cards that did not fill the page
                        // sat centred, drifting further from the edge the fewer
                        // widgets a filter left. Start-aligned now (23/8/2026).
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [


                          // CustomSegmentedTabs (core/custom/9_filter_tab_with_container.dart).
                          // The hand-rolled switcher this replaced wired BOTH
                          // tabs to `selectedTab = 0`, so tapping
                          // "Chart & Graph" just re-opened the Widget tab.
                          Row(
                            // Was MainAxisAlignment.end, which parked the
                            // switcher against the trailing edge while
                            // everything else on the page began at the leading
                            // one (23/8/2026).
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: 300.w,
                                height: 41.h,
                                child: CustomSegmentedTabs(
                                  tabs: [
                                    S.of(context).widget,
                                    S.of(context).chartGraph,
                                  ],
                                  selectedIndex: selectedTab,
                                  onTabSelected: (index) =>
                                      setState(() => selectedTab = index),
                                  equalWidth: true,
                                  containerColor: AppColors.card,
                                  unselectedColor: AppColors.card,
                                  selectedColor: AppColors.primary,
                                  borderRadius: 4.r,
                                  containerPadding: EdgeInsets.all(4.sp),
                                  spacing: 4.sp,
                                  textStyle: StyleText.fontSize16Weight500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.sp),

                          // Module filter and the Widget / Chart & Graph
                          // switcher both start at the leading edge. The filter
                          // stays visible on both tabs and applies to charts too.
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(child: _moduleFilter()),
                    
                            ],
                          ),
                          SizedBox(height: 12.w),

                          // Animated Content Switcher
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            switchInCurve: Curves.easeInOut,
                            switchOutCurve: Curves.easeInOut,
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.05, 0),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            // Both tabs render the same way — charts are just
                            // components whose isChart flag is true — so tapping
                            // a chart runs the identical AddComponentWrapper
                            // flow (editComponent + pop back to Home Layout)
                            // that tapping a widget does.
                            child: Wrap(
                              // Key includes the tab and filter so
                              // AnimatedSwitcher cross-fades on either change.
                              key: ValueKey('tab${selectedTab}_$selectedModuleKey'),
                              // Figma's card gutter is 15 in both directions.
                              // AddComponentWrapper already pads each card by
                              // 12 (it reserves room for the gear badge), so
                              // the Wrap only has to contribute the last 3.
                              // Changing either number changes how many cards
                              // land per row — see the geometry note in
                              // home_chart_cards_extra.dart.
                              runSpacing: 3.h,
                              spacing: 3.w,
                              children: [
                                for (HomeComponentModel componentModel
                                in _visibleComponents)
                                  AddComponentWrapper(
                                    model: componentModel,
                                    // ✅ Every card is exactly
                                    // HomeCardMetrics.height tall — widgets and
                                    // charts alike, and the same height the
                                    // layout editor and dashboard use. Each
                                    // module widget used to bring its own
                                    // height too, so the grid was ragged.
                                    //
                                    // CHANGED 12/9/2026: `heightBox`, not
                                    // `box`. HEIGHT is unchanged — still pinned
                                    // to HomeCardMetrics.height, still the same
                                    // number. WIDTH is no longer forced to
                                    // HomeCardMetrics.width: each card is as
                                    // wide as its own module widget declares,
                                    // which is how this picker behaved before
                                    // the shared metrics landed on 31/8/2026.
                                    // A uniform tile grid is not what this
                                    // screen is for — the cards are previews of
                                    // widgets whose real proportions differ,
                                    // and clamping a wide one to 250 misled
                                    // about what you were picking.
                                    //
                                    // Widths are whatever the module widgets
                                    // declare. UPDATED 7/10/2026: heightBox
                                    // now caps a card at the screen width
                                    // (HomeCardMetrics.maxWidthOf) — a safety
                                    // net only, so a 400–600 card cannot run
                                    // off a phone; narrower cards are never
                                    // stretched or squeezed.
                                    //
                                    // The box goes around the component rather
                                    // than around AddComponentWrapper on
                                    // purpose: the wrapper adds its own 12.h/
                                    // 12.w padding (gear-badge room), so sizing
                                    // the wrapper would leave the visible card
                                    // 12 short. Constraining the child keeps
                                    // that padding outside the card and leaves
                                    // the 15 gutter (12 here + 3 from the Wrap)
                                    // intact.
                                    //
                                    // The page's ScrollConfiguration above sets
                                    // scrollbars: false, and the box's inner
                                    // scroll view inherits it, so no per-card
                                    // scrollbar appears on desktop.
                                    component: HomeCardMetrics.heightBox(
                                      child: componentModel.component
                                              .widget(componentModel) ??
                                          Container(),
                                    ),
                                  )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.sp,
                )
              ],
            ),
          ),
        ));
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
}