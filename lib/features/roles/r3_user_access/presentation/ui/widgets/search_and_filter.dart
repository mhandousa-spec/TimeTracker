/// Module: roles / r3_user_access / presentation / ui / widgets
///
///************************** FILE INFO ****************************///
/// File Name: search_and_filter.dart
/// Purpose : Contains the ui for search and filter in account status screen.
/// Author: Amr Mesbah
/// Created at : 28/1/2025
/// Updated: 29/8/2026 - The Sort control is now the same button + anchored
///          dropdown used on the Requests screen
///          (`r2_user_management/.../request_page_approval.dart`), instead of
///          `SortDropdownWidgetRole` / `CustomDropdown`. Picking the active
///          option again clears the sort instead of flipping its direction.
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';


import 'package:knowticed_plus/core/helper/main_helper/icon_size.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/presentation/controller/user_access_cubit.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/presentation/controller/user_access_state.dart';
import './filter.dart';
import './filter_widget.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/domain/enums/sort_option_role.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class SearchAndFilter extends StatefulWidget {
  const SearchAndFilter({super.key});

  @override
  State<SearchAndFilter> createState() => _SearchAndFilterState();
}

class _SearchAndFilterState extends State<SearchAndFilter> {
  /// The search field's controller.
  ///
  /// Was `UserAccessCubit.searchController`, which §16 forbids — form state
  /// belongs to the page's StatefulWidget, not the cubit. The widget owns and
  /// disposes it, and pushes the text down as a plain value.
  late final TextEditingController _searchController;

  late UserAccessCubit controller;

  /// Anchor for the sort dropdown.
  ///
  /// ADDED 29/8/2026 with the port from `CustomDropdown` to `showMenu`. The
  /// menu is positioned from this key's RenderBox measured against the overlay,
  /// so it follows the button in both LTR and RTL with no hardcoded offsets —
  /// same approach as `RequestPageApprovalMethods1._showSortMenu`.
  final GlobalKey _sortButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _searchController =
        TextEditingController(text: context.read<UserAccessCubit>().searchTerm);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var isMobile = ContextExtension(context).isPhone;
    controller = context.read<UserAccessCubit>();
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    bool isTablet = MediaQuery.of(context).size.width > 600;

    return IntrinsicHeight(
      child: Row(
        spacing: 5.sp,
        crossAxisAlignment:
        isPortrait ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          // AppSearchTextField already returns an Expanded, so it must NOT be
          // wrapped in one here (nested Expanded is a runtime error).
          AppSearchTextField(
            controller: _searchController,
            onChanged: (value) {
              controller.searchAccountsStatusEntities(
                  value, controller.selectedSortOption);
            },
          ),

          // BlocBuilder so the trigger reflects the current option AND its
          // direction after every pick — without it the arrow and label kept
          // showing the previous state until something else rebuilt this row.
          // Role QA p.42: Sort was hidden on phones; it now shows there too,
          // as a 38×38 square like the Filter button beside it.
          BlocBuilder<UserAccessCubit, UserAccessState>(
            builder: (context, state) =>
                _sortButton(isPortrait || isMobile),
          ),

          // BlocBuilder for the same reason as the Sort button: applying or
          // clearing a department in the dialog writes
          // `UserAccessCubit.selectedDepartment` and re-runs the search, and
          // this button has to repaint on that emit to show whether a filter
          // is on (9/9/2026).
          BlocBuilder<UserAccessCubit, UserAccessState>(
            builder: (context, state) => _filterButton(isTablet),
          ),
        ],
      ),
    );
  }

  // ── Filter ─────────────────────────────────────────────────────────────────

  /// Whether a department filter is applied — the cubit keeps it in
  /// [UserAccessCubit.selectedDepartment], and the Filter dialog's "Reset"
  /// puts it back to null.
  bool get _filterSelected =>
      controller.selectedDepartment != null || controller.selectedTitle != null;

  /// ADDED 9/9/2026. Two changes over the inline version this replaces:
  ///
  ///  * Square on mobile — 38×38, per the Figma. The label is what needs the
  ///    extra width and it is only drawn from tablet up, so below that the
  ///    100.w box was a wide slab holding one 15.sp icon.
  ///  * A selected state, matching [_sortButton]: a primary fill with
  ///    on-primary icon and label whenever a department filter is applied, so
  ///    the two controls in this row read the same way.
  Widget _filterButton(bool isTablet) {
    final Color foreground =
        _filterSelected ? AppColors.textButton : AppColors.secondaryText;

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: BlocProvider<UserAccessCubit>.value(
                value: controller,
                child: Filter(),
              ),
            );
          },
        );
      },
      child: Container(
        height: 38.sp,
        width: isTablet ? 100.w : 38.sp,
        decoration: BoxDecoration(
          color: _filterSelected ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.scale(
              scale: IconSizeHelper.getIconSize(context),
              child: CustomSvgImage(
                assetPath:
                    "assets/icons_assets/main_icons_assets/filter_sliders.svg",
                width: 15.sp,
                height: 15.sp,
                color: foreground,
              ),
            ),
            if (isTablet) ...[
              SizedBox(width: 8.sp),
              Text(
                S.of(context).Filter,
                style: StyleText.fontSize14Weight500.copyWith(
                  color: foreground,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Sort ───────────────────────────────────────────────────────────────────
  //
  // PORTED 29/8/2026 from `RequestPageApprovalMethods1` so both screens present
  // one sort control. This used to be `SortDropdownWidgetRole`, a
  // `CustomDropdown` dressed up as a button: it carried a form field's trigger,
  // hint and `alwaysShowHint` hack just to keep the word "Sort" on a control
  // that was never a form field, and its menu was styled by the dropdown rather
  // than by this screen.
  //
  // The direction flip that came with the old widget is gone (29/8/2026).
  // Re-picking the active option now CLEARS the sort — see
  // `UserAccessCubit.selectSortOption` — so the icon has no direction left to
  // mirror and `Transform.flip` came off with it.

  /// Whether a sort is active. Drives the button's fill, exactly as
  /// `sortSelected` does on the Requests screen.
  bool get _sortSelected => controller.selectedSortOption != null;

  Widget _sortButton(bool isPortrait) {
    return GestureDetector(
      onTap: _showSortMenu,
      child: Container(
        key: _sortButtonKey,
        width: isPortrait ? 38.sp : 100.w,
        height: 38.sp,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: _sortSelected ? AppColors.primary : AppColors.card,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomSvgImage(
              assetPath: AppAssets.sort,
              width: 20.sp,

              height: 20.sp,
              fit: BoxFit.fill,
              color: _sortSelected
                  ? AppColors.textButton
                  : AppColors.secondaryText,
            ),
            if (!isPortrait) ...[
              SizedBox(width: 8.w),
              Text(
                S.of(context).Sort,
                style: StyleText.fontSize16Weight500.copyWith(
                  color: _sortSelected
                      ? AppColors.textButton
                      : AppColors.secondaryText,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// The sort menu, anchored under the button and at least as wide as it.
  ///
  /// `minWidth`, not `tightFor`: the option labels ("First Login" / "Last
  /// Login", and their longer Arabic forms) must show in full, never
  /// ellipsised, so the menu is allowed to grow past the button.
  Future<void> _showSortMenu() async {
    final BuildContext? buttonContext = _sortButtonKey.currentContext;
    if (buttonContext == null) return;

    final RenderBox button = buttonContext.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final Size buttonSize = button.size;
    final Offset topLeft = button.localToGlobal(Offset.zero, ancestor: overlay);

    // 4px of breathing room so the menu reads as attached to the button
    // without touching it.
    const double gap = 4.0;

    final RelativeRect position = RelativeRect.fromLTRB(
      topLeft.dx,
      topLeft.dy + buttonSize.height + gap,
      overlay.size.width - (topLeft.dx + buttonSize.width),
      0,
    );

    final SortOptionRole? selected = await showMenu<SortOptionRole>(
      context: context,
      position: position,
      color: AppColors.card,
      constraints: BoxConstraints(minWidth: buttonSize.width),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      // The selected row is painted edge to edge, so the menu does the
      // rounding and gives up its default vertical list padding — otherwise a
      // strip of `AppColors.card` shows above and below the fill and the row
      // reads as unfilled.
      clipBehavior: Clip.antiAlias,
      menuPadding: EdgeInsets.zero,
      // `selectable`, not `values`: first name and last name were dropped from
      // the Sort menu on 25/8/2026 while their enum values — and the cubit's
      // comparators for them — stay. See sort_option_role.dart.
      items: <PopupMenuEntry<SortOptionRole>>[
        for (final SortOptionRole option in SortOptionRole.selectable)
          _sortMenuItem(option),
      ],
    );

    if (selected == null) return;

    // selectSortOption, not sortAccountsStatusEntities: picking the row that is
    // already active clears the sort, and only `selectSortOption` knows that.
    // `sortAccountsStatusEntities` would re-apply the same order instead.
    controller.selectSortOption(selected);
  }

  /// One row of the sort dropdown — same treatment as the Requests screen: the
  /// active option is a full-width primary fill with on-primary text, and there
  /// is no tick, so every row is the same width.
  PopupMenuItem<SortOptionRole> _sortMenuItem(SortOptionRole option) {
    final bool isSelected = controller.selectedSortOption == option;

    return PopupMenuItem<SortOptionRole>(
      value: option,
      height: 40.h,
      padding: EdgeInsets.zero,
      child: Container(
        height: 40.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        alignment: AlignmentDirectional.centerStart,
        color: isSelected ? AppColors.primary : AppColors.transparent,
        child: Row(
          // Stretches the fill across the menu. The menu measures its width
          // from its children's INTRINSIC width, so the row must not be given
          // an explicit `double.infinity` — that makes the measurement
          // unbounded and throws at layout.
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              option.label(context),
              style: StyleText.fontSize14Weight500.copyWith(
                color: isSelected ? AppColors.textButton : AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}