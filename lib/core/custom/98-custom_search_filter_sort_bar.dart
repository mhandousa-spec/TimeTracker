// ****************** FILE INFO ******************
// File Name: 98-custom_search_filter_sort_bar.dart
// Purpose: Isolated responsive search toolbar with optional filter, sort, and actions
// Author: Mohand Adel
// Created At: 25/08/2026

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// An isolated toolbar for list pages.
///
/// Its private search field and action controls intentionally live in this
/// file, so changing this toolbar never changes existing shared widgets.
class CustomSearchFilterSortBar<TFilter, TSort> extends StatelessWidget {
  CustomSearchFilterSortBar({
    super.key,
    required this.searchController,
    this.onSearchChanged,
    this.searchHint = 'Search',
    this.showFilter = false,
    this.filterItems,
    this.selectedFilter,
    this.filterLabelBuilder,
    this.onFilterChanged,
    this.filterDialogBuilder,
    this.onFilterTap,
    this.isFilterActive = false,
    this.filterTitle = 'Filter',
    this.showSort = false,
    this.sortItems,
    this.selectedSort,
    this.sortLabelBuilder,
    this.onSortChanged,
    this.sortTitle = 'Sort',
    this.trailingChildren = const <Widget>[],
    this.trailingActionsBuilder,
    this.height,
    this.spacing,
    this.fillColor,
    this.mobileBreakpoint,
  })  : assert(!showFilter ||
            filterItems == null ||
            filterItems.isEmpty ||
            (filterLabelBuilder != null && onFilterChanged != null)),
        assert(!showSort ||
            (sortItems != null &&
                sortItems.isNotEmpty &&
                sortLabelBuilder != null &&
                onSortChanged != null)),
        assert(filterDialogBuilder == null || onFilterTap == null);

  final TextEditingController searchController;
  final ValueChanged<String>? onSearchChanged;
  final String searchHint;

  final bool showFilter;
  final List<TFilter>? filterItems;
  final TFilter? selectedFilter;
  final String Function(TFilter item)? filterLabelBuilder;
  final ValueChanged<TFilter?>? onFilterChanged;
  final WidgetBuilder? filterDialogBuilder;
  final VoidCallback? onFilterTap;
  final bool isFilterActive;
  final String filterTitle;

  final bool showSort;
  final List<TSort>? sortItems;
  final TSort? selectedSort;
  final String Function(TSort item)? sortLabelBuilder;
  final ValueChanged<TSort?>? onSortChanged;
  final String sortTitle;

  /// Existing custom actions, such as the module's Add button.
  final List<Widget> trailingChildren;

  /// Builds toolbar-only actions with the current phone layout state.
  final List<Widget> Function(BuildContext context, bool isPhone)?
      trailingActionsBuilder;

  /// Height of this toolbar's private controls. Defaults to 38.sp.
  final double? height;
  final double? spacing;
  final Color? fillColor;

  /// Width below which controls move beneath search. Defaults to `0`, keeping
  /// search, filter, sort, and actions together on one row.
  final double? mobileBreakpoint;

  @override
  Widget build(BuildContext context) {
    final double effectiveHeight = height ?? 38.sp;
    final double effectiveSpacing = spacing ?? 10.sp;
    final bool isPhone = MediaQuery.sizeOf(context).shortestSide < 600;
    final List<Widget> controls = <Widget>[
      if (showFilter)
        _buildFilter(context, effectiveHeight, filterItems ?? <TFilter>[]),
      if (showSort)
        _buildSort(context, effectiveHeight, sortItems ?? <TSort>[]),
      ...trailingChildren,
      ...?trailingActionsBuilder?.call(context, isPhone),
    ];

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final Widget search = _ToolbarSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          hintText: searchHint,
          height: effectiveHeight,
          fillColor: fillColor,
        );

        return Row(
          children: <Widget>[
            search,
            for (final Widget control in controls) ...<Widget>[
              SizedBox(width: effectiveSpacing),
              control,
            ],
          ],
        );
      },
    );
  }

  Widget _buildFilter(
    BuildContext context,
    double effectiveHeight,
    List<TFilter> effectiveFilterItems,
  ) {
    final bool hasExplicitActive = isFilterActive ||
        (selectedFilter != null &&
            (selectedFilter is! String ||
                (selectedFilter.toString().isNotEmpty &&
                    selectedFilter.toString().toLowerCase() != 'all')));

    if (effectiveFilterItems.isNotEmpty) {
      return _ToolbarDropdownButton<TFilter>(
        value: selectedFilter,
        items: effectiveFilterItems,
        labelBuilder: filterLabelBuilder!,
        onChanged: onFilterChanged!,
        title: filterTitle,
        iconPath: AppAssets.filter,
        height: effectiveHeight,
        fillColor: fillColor,
        activeOverride: hasExplicitActive,
      );
    }

    return _ToolbarActionButton(
      title: filterTitle,
      iconPath: AppAssets.filter,
      height: effectiveHeight,
      fillColor: fillColor,
      isActive: hasExplicitActive,
      onTap: () => _handleFilterTap(context),
    );
  }

  Widget _buildSort(
    BuildContext context,
    double effectiveHeight,
    List<TSort> effectiveSortItems,
  ) {
    final bool hasSortActive = selectedSort != null &&
        (selectedSort is! String || selectedSort.toString().isNotEmpty);

    return _ToolbarDropdownButton<TSort>(
      value: selectedSort,
      items: effectiveSortItems,
      labelBuilder: sortLabelBuilder!,
      onChanged: onSortChanged!,
      title: sortTitle,
      iconPath: AppAssets.sort,
      height: effectiveHeight,
      fillColor: fillColor,
      activeOverride: hasSortActive,
    );
  }

  void _handleFilterTap(BuildContext context) {
    if (filterDialogBuilder != null) {
      showDialog<void>(context: context, builder: filterDialogBuilder!);
      return;
    }
    onFilterTap?.call();
  }
}

class _ToolbarSearchField extends StatelessWidget {
  const _ToolbarSearchField({
    required this.controller,
    required this.hintText,
    required this.height,
    this.onChanged,
    this.fillColor,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String hintText;
  final double height;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    final Color effectiveFill = fillColor ?? AppColors.card;

    return Expanded(
      child: SizedBox(
        height: height,
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          maxLines: 1,
          style: StyleText.fontSize14Weight500,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: StyleText.fontSize14Weight500.copyWith(
              color: AppColors.secondaryText,
            ),
            filled: true,
            fillColor: effectiveFill,
            hoverColor: effectiveFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.sp),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.sp),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.sp),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.sp),
            prefixIcon: Padding(
              padding: EdgeInsets.all(11.sp),
              child: SvgPicture.asset(
                AppAssets.search,
                colorFilter: ColorFilter.mode(
                  AppColors.secondaryText,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolbarDropdownButton<T> extends StatelessWidget {
  const _ToolbarDropdownButton({
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
    required this.title,
    required this.iconPath,
    required this.height,
    this.activeOverride,
    this.fillColor,
  });

  final T? value;
  final List<T> items;
  final String Function(T item) labelBuilder;
  final ValueChanged<T?> onChanged;
  final String title;
  final String iconPath;
  final double height;
  final bool? activeOverride;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isActuallyActive = activeOverride ??
        (value != null &&
            (value is! String ||
                (value.toString().isNotEmpty &&
                    value.toString().toLowerCase() != 'all')));

    return Theme(
      data: theme.copyWith(
        hoverColor: AppColors.transparent,
        highlightColor: AppColors.transparent,
        splashColor: AppColors.transparent,
      ),
      child: PopupMenuButton<T>(
        tooltip: '',
        color: AppColors.card,
        style: ButtonStyle(
          overlayColor: const WidgetStatePropertyAll<Color>(AppColors.transparent),
          splashFactory: NoSplash.splashFactory,
        ),
        offset: Offset(0, height),
        onSelected: (T item) => onChanged(item == value ? null : item),
        itemBuilder: (BuildContext context) => items
            .map(
              (T item) => PopupMenuItem<T>(
                value: item,
                child: Text(
                  labelBuilder(item),
                  style: StyleText.fontSize14Weight500,
                ),
              ),
            )
            .toList(),
        child: _ToolbarActionButton(
          title: title,
          iconPath: iconPath,
          height: height,
          fillColor: fillColor,
          isActive: isActuallyActive,
        ),
      ),
    );
  }
}

class _ToolbarActionButton extends StatelessWidget {
  const _ToolbarActionButton({
    required this.title,
    required this.iconPath,
    required this.height,
    this.isActive = false,
    this.fillColor,
    this.onTap,
  });

  final String title;
  final String iconPath;
  final double height;
  final bool isActive;
  final Color? fillColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isPhone = MediaQuery.sizeOf(context).shortestSide < 600;
    final Color contentColor =
        isActive ? AppColors.textButton : AppColors.secondaryText;
    final Color defaultBg = fillColor ?? AppColors.card;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isPhone ? height : 100.sp,
        height: height,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : defaultBg,
          borderRadius: BorderRadius.circular(8.sp),
        ),
        child: Center(
          child: isPhone
              ? SvgPicture.asset(
                  iconPath,
                  width: 20.sp,
                  height: 20.sp,
                  colorFilter: ColorFilter.mode(contentColor, BlendMode.srcIn),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SvgPicture.asset(
                      iconPath,
                      width: 20.sp,
                      height: 20.sp,
                      colorFilter:
                          ColorFilter.mode(contentColor, BlendMode.srcIn),
                    ),
                    SizedBox(width: 8.sp),
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: StyleText.fontSize14Weight500.copyWith(
                          color: contentColor,
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

