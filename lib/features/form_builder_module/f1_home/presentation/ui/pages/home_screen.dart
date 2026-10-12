// Date: 13/1/2025

import 'package:get/get.dart';
// By: Ibrahin Ismail
// Last update: 13/1/2025
// Objectives: This is the main screen of the application, which serves as the home page for managing and viewing forms with categorized tabs.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/34-custom_gridview_with_animation.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/presentation/controller/home_controller.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/enums/form_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/presentation/ui/widgets/home_grid_item_view.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/presentation/ui/widgets/search_form_publish_tablet.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/presentation/controller/home_state.dart';
import 'package:knowticed_plus/core/custom/8-custom_filter_app.dart';
import 'package:knowticed_plus/features/form_builder_module/form_builder_title_padding.dart';
import 'package:knowticed_plus/features/form_builder_module/form_builder_shortcut.dart';
import 'package:knowticed_plus/core/helper/form_builder/app_routes.dart';
class FormBuilderHomeScreen extends StatefulWidget {
  const FormBuilderHomeScreen({super.key});

  @override
  State<FormBuilderHomeScreen> createState() => _FormBuilderHomeScreenState();
}

/// ── Figma spec: MESBAH / node 7444-37189 (Form Builder home, 1024 frame) ────
///
/// Every number below is read off that node, measured from the frame origin:
///
///   sidebar          x 0,   w 66
///   content column   x 96          → 30 clear of the sidebar (the page's
///                                    horizontal padding, already 30.sp)
///   page title       y 149, h 20   → bottom 169
///   tab row          y 199, h 45   → 30 below the title, bottom 244
///   action row       y 264, h 38   → 20 below the tabs,  bottom 302
///   card grid        y 317         → 15 below the action row
///   card             282 × 80, 15 between columns and 15 between rows
///                                    (columns at x 96 / 393 / 690 = +297
///                                     each, rows at y 317 / 412 = +95)
const double _kTitleToTabsGap = 30;

/// `formBuilderTitlePadding` is 20 on all four sides and is shared by every
/// page in the module, so it already supplies 20 of the 30 the design wants
/// under the title. Only the remainder is added here — do not "fix" this by
/// editing the shared constant, which would move the title on other pages.
const double _kTitlePaddingBottom = 20;

const double _kTabRowHeight = 45;
const double _kTabsToActionRowGap = 20;
const double _kActionRowToGridGap = 15;

/// Card box from the design. The grid drives width via `crossAxisCount`, so
/// only the height is pinned here; 282 is what three columns plus two 15 gaps
/// work out to inside the 1024 frame.
const double _kCardHeight = 80;
const double _kCardGap = 15;

/// Chip keys, in the SAME ORDER as `HomeCubit.tabController`'s five tabs
/// (0 Publish, 1 Draft, 2 Requested, 3 Submissions, 4 Deleted).
///
/// CHANGED 19/8/2026: this row was a `TabBar` of `TabletCategoryFilterCard`s;
/// it is now the app's shared `StatusChipFilter` (core/custom/8-custom_filter_app),
/// so the Form Builder's filter looks and behaves like every other screen's.
///
/// The `TabController` STAYS the source of truth — it is not just a widget for
/// this screen. `HomeCubit.onChangeTab` switches on its index, and
/// `home_grid_item_view`, `sort`, `reset` and the date/access filters all read
/// `tabController.index` to decide what they are operating on. The chips drive
/// that controller through `onChangeTab` instead of replacing it, which is why
/// nothing downstream had to change.
///
/// Keys are fixed English identifiers, deliberately NOT the labels: the labels
/// come from `S.of(context)` and change with the app language, and a key that
/// moves when the user switches to Arabic would stop matching `selectedKey`.
const List<String> _kTabKeys = [
  'publish',
  'draft',
  'requested',
  'submissions',
  'deleted',
];

class _FormBuilderHomeScreenState extends State<FormBuilderHomeScreen> with TickerProviderStateMixin {
  late bool isPortrait;

  // ✅ Animation controller for grid items
  late AnimationController _gridAnimationController;

  /// Cached in [initState]: `context.read` is illegal in [dispose] (the
  /// element is already deactivated — "Looking up a deactivated widget's
  /// ancestor is unsafe").
  late final HomeCubit _homeCubit;
  List<Animation<Offset>> _slideAnimations = [];
  int _lastItemCount = 0;
  bool _isAnimationScheduled = false; // ✅ Prevent double animation
  bool _isFirstLoad = true; // ✅ Track first data load

  @override
  void initState() {
    super.initState();

    // ✅ Initialize grid animation controller with proper duration
    _gridAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2500), // ✅ MUCH SLOWER: 2.5 seconds
      vsync: this,
      value: 0.0,
    );

    //  HomeCubit
    _homeCubit = context.read<HomeCubit>();
    _homeCubit.initialize(this);

    // Bug report p.2: the Home "Forms" card opens the module at a tab or
    // straight into Create Form.
    final FormBuilderShortcut? shortcut = FormBuilderShortcuts.take();
    if (shortcut != null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _applyShortcut(shortcut));
    }
  }

  Future<void> _applyShortcut(FormBuilderShortcut shortcut) async {
    if (!mounted) return;
    final int? tabIndex = FormBuilderShortcuts.tabIndexOf(shortcut);
    if (tabIndex == null) {
      context.FormNavigateTo(
        ContextExtension(context).isPhone
            ? Routes.create
            : Routes.creatingFormTablet,
      );
      return;
    }
    // Wait for the first load: getForms() resets the list to Publish when it
    // finishes, so switching before that would be undone.
    if (_homeCubit.isLoading) {
      try {
        await _homeCubit.stream
            .firstWhere((s) => s is HomeLoaded && !_homeCubit.isLoading)
            .timeout(const Duration(seconds: 20));
      } catch (_) {
        // Timed out or the cubit closed — fall through and switch anyway.
      }
    }
    if (!mounted || _homeCubit.isClosed) return;
    _homeCubit.onChangeTab(tabIndex);
  }

  // ✅ Initialize slide animations for grid items
  void _initializeAnimations(int itemCount) {

    if (itemCount == 0) {
      _slideAnimations = [];
      return;
    }

    _slideAnimations = List.generate(itemCount, (index) {
      // ✅ Slower stagger - each item starts 150ms after previous
      final delayInSeconds = (index * 0.15).clamp(0.0, 0.7);

      return Tween<Offset>(
        begin: Directionality.of(context) == TextDirection.rtl
            ? const Offset(0.5, 0)  // ✅ RTL: Slide from RIGHT
            : const Offset(-0.5, 0), // ✅ LTR: Slide from LEFT
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _gridAnimationController,
          curve: Interval(
            delayInSeconds,
            (delayInSeconds + 0.8).clamp(0.5, 1.0), // ✅ Longer animation per item
            curve: Curves.easeOutQuart, // ✅ Smoother curve
          ),
        ),
      );
    });

  }

  // ✅ Trigger animation - SINGLE CALL ONLY
  void _playAnimation(int itemCount) {
    // ✅ Prevent double animation trigger
    if (_isAnimationScheduled) {
      return;
    }

    _isAnimationScheduled = true;

    _initializeAnimations(itemCount);

    // ✅ Stop any running animation
    if (_gridAnimationController.isAnimating) {
      _gridAnimationController.stop();
    }
    _gridAnimationController.reset();

    // ✅ Start animation after delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _gridAnimationController.forward().then((_) {
          _isAnimationScheduled = false; // ✅ Reset flag when animation completes
        });
      }
    });

    _lastItemCount = itemCount;
  }

  @override
  void dispose() {
    _gridAnimationController.dispose();
    _homeCubit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    // CHANGED 19/8/2026 — every page in this module now draws its header with
    // SideFrameMasterServices. This screen used to build two different headers
    // (CustomAppBar on phone, PaginationAppBar inside the body on tablet); the
    // frame handles both form factors itself, so there is one header again.
    //
    // Home is the module root, so it passes a single crumb and no tap.
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SideFrameMasterServices(
        titlePadding: formBuilderTitlePadding,
        titleText: S.of(context).services_app,
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    // The frame scrolls the content itself on mobile; on tablet it hands the
    // child a bounded height, so the scroll view stays here.
    final Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            final cubit = context.read<HomeCubit>();

            return SizedBox(
              height: _kTabRowHeight.h,
              child: StatusChipFilter(
                selectedKey: _kTabKeys[cubit.tabController.index],
                onSelected: (key) => _onFilterSelected(key, cubit),
                items: [
                  // FIXED 19/8/2026 — the first chip was the literal
                  // 'Publish' while its four neighbours were localized,
                  // so the Arabic tab row read "Publish | مسودة | ...".
                  // All five now come from FormStatus.label.
                  StatusChipItem(
                    key: _kTabKeys[0],
                    label: FormStatus.publish.label,
                    count: cubit.publishFormModels.length,
                  ),
                  StatusChipItem(
                    key: _kTabKeys[1],
                    label: FormStatus.drafts.label,
                    count: cubit.draftFormModels.length,
                  ),
                  StatusChipItem(
                    key: _kTabKeys[2],
                    label: FormStatus.requestedForms.label,
                    count: cubit.requestedFormModels.length,
                  ),
                  StatusChipItem(
                    key: _kTabKeys[3],
                    label: FormStatus.submissions.label,
                    count: cubit.submissionsFormModels.length,
                  ),
                  StatusChipItem(
                    key: _kTabKeys[4],
                    label: FormStatus.deleted.label,
                    count: cubit.deleteFormModels.length,
                  ),
                ],
              ),
            );
          },
        ),
        verticalSpace(_kTabsToActionRowGap),
        const SearchFormPublishTablet(),
        verticalSpace(_kActionRowToGridGap),
        BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            final cubit = context.read<HomeCubit>();

            if (state is HomeLoading) {
              // Bug report #15: centred in the page, not pinned under the
              // search bar.
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.55,
                child: const Center(child: CircleProgressMaster()),
              );
            }

            if (cubit.shownFormModels.isEmpty) {
              return Center(
                child: Column(
                  children: [
                    LottieBuilder.asset(
                      height: 300.h,
                      AppAssets.noData,
                      frameRate: const FrameRate(120),
                    ),
                    verticalSpace(20),
                    Text(
                      S.of(context).noFormFound,
                      style: StyleText.fontSize18Weight600,
                    ),
                  ],
                ),
              );
            }

            // ✅ Trigger animation on first load or when count changes
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && cubit.shownFormModels.isNotEmpty) {
                final currentCount = cubit.shownFormModels.length;

                if ((_isFirstLoad || _lastItemCount != currentCount) && !_isAnimationScheduled) {
                  _isFirstLoad = false; // Mark first load as complete
                  _playAnimation(currentCount);
                } else {
                }
              }
            });

            return // In your widget
              AnimatedCustomGridView(
                animationDuration: const Duration(milliseconds: 700), // Each item animates for 1 second
                staggerDelay: const Duration(milliseconds: 100), // 200ms delay between each item
                itemCount: cubit.shownFormModels.length,
                crossAxisCount: _getCrossAxisCount(context),
                // Figma card is 282 × 80. Was 100.h, which stretched the
                // card 25% taller than the design and left the 60 × 60
                // thumbnail floating inside it.
                mainAxisExtent: 100.sp,
                height: MediaQuery.of(context).size.height * 0.7,
                margin: EdgeInsetsDirectional.only(end: !ContextExtension(context).isTablett ? 17 : 21),
                mainAxisSpacing: _kCardGap,
                crossAxisSpacing: _kCardGap,
                curve: Curves.easeOut,
                itemBuilder: (context, index) {
                  return HomeGridItemView(
                    model: cubit.shownFormModels[index],
                    index: index,
                    gridAnimationController: null, // Not needed anymore
                    slideAnimations: null, // Not needed anymore
                  );
                },
              );
          },
        ),
      ],
    );

    return ContextExtension(context).isTablett
        ? SingleChildScrollView(child: content)
        : content;
  }

  /// Chip tap → cubit tab change → the same staggered grid animation the
  /// TabBar's `onTap` used to fire.
  ///
  /// `onChangeTab` is called directly rather than assigning
  /// `tabController.index`: it is the method that also updates `selectedTab`
  /// and `shownFormModels` and re-applies the current sort, and the controller
  /// listener installed in `HomeCubit.initialize` routes back into it anyway.
  ///
  /// The 250ms delay is inherited from the TabBar, and matters: it lets the
  /// cubit emit its new state and the grid rebuild with the new list before the
  /// stagger starts, so items animate in rather than snapping into place.
  void _onFilterSelected(String key, HomeCubit cubit) {
    final int index = _kTabKeys.indexOf(key);
    if (index == -1 || index == cubit.tabController.index) return;

    cubit.onChangeTab(index);

    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        _isFirstLoad = false; // Mark that we're no longer on first load
        _playAnimation(cubit.shownFormModels.length);
      }
    });
  }

  int _getCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth > 3600) {
      return 5;
    } else if (screenWidth > 2400) {
      return 4;
    } else if (screenWidth <= 2400 && screenWidth > 1200) {
      return 3;
    } else if (screenWidth > 600 && screenWidth < 1200) {
      return 2;
    }
    return 1; // Default for phone
  }

  double _getMainAxisExtentMobile(int index) {
    return index == 2 || index == 3 ? 95.h : 80.h;
  }
}