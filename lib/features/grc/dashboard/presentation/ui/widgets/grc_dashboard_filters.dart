/// Module: GRC — Dashboard
///
///*************************** FILE INFO ****************************///
/// File Name: grc_dashboard_filters.dart
/// Purpose: The small header controls on the dashboard cards (Figma: Sort,
///          Policies / Controls / Department dropdowns, Top | Least,
///          Baseline), all built on the shared custom widgets
///          (CustomDropdown 1, CustomSortButton 47,
///          CustomSegmentedTabs 9). Fills are AppColors.background so the
///          controls stand out on the card.
/// Author: Amr Mesbah
/// Created: 16/9/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/custom/47-custom_sort_button.dart';
import 'package:knowticed_plus/core/custom/9-filter_tab_with_container.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/dashboard/domain/entities/grc_dashboard_stats.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_l10n.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Corner radius shared by every dashboard filter control.
double get _radius => 4.r;

/// Height of every dashboard filter control, as a raw design number:
/// 30 on a phone, 37 on tablet / desktop. Callers that take a raw value
/// (CustomDropdown.height) use it as is; everything else uses [_filterHeight].
double _filterHeightRaw(BuildContext context) =>
    screenSizeOf(context) == ScreenSize.mobile ? 30 : 37;

/// [_filterHeightRaw] in `.sp`.
double _filterHeight(BuildContext context) => _filterHeightRaw(context).sp;

/// Public [_filterHeight], for controls that must line up with the filters
/// (the Color Coding button next to the page's Department picker).
double grcDashboardFilterHeight(BuildContext context) => _filterHeight(context);

/// A compact "hint = what it filters, first row = All" dropdown.
class GrcDashboardDropdown extends StatelessWidget {
  final String hint;
  final String? value;
  final List<DropdownItem<String?>> options;
  final ValueChanged<String?> onChanged;
  final double width;

  /// Trigger fill. Null keeps AppColors.background, which stands out on a
  /// card; the page-level picker (on the page background) passes
  /// AppColors.card instead.
  final Color? fillColor;

  const GrcDashboardDropdown({
    super.key,
    required this.hint,
    required this.value,
    required this.options,
    required this.onChanged,
    this.width = 130,
    this.fillColor,
  });

  static const String allValue = '__all__';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width.w,
      // The "All" row carries a sentinel, not null: a null value would match
      // it and the trigger would read "All" instead of the design's
      // placeholder (Policies / Controls / Department).
      child: CustomDropdown<String?>(
        value: value,
        hint: hint,
        // Raw value — CustomDropdown applies .sp itself.
        height: _filterHeightRaw(context),
        borderRadius: BorderRadius.circular(_radius),
        fillColor: fillColor ?? AppColors.background,
        items: [
          DropdownItem<String?>(value: allValue, label: S.of(context).all),
          ...options,
        ],
        onChanged: (v) => onChanged(v == allValue ? null : v),
      ),
    );
  }

  /// Policies in scope.
  static List<DropdownItem<String?>> policies(
    BuildContext context,
    GrcDashboardData data,
  ) =>
      [
        for (final p in data.policies)
          DropdownItem<String?>(
            value: p.id,
            label: p.localizedName(isArabic: context.isArabic),
          ),
      ];

  /// Controls of [policyId] (every control when null).
  static List<DropdownItem<String?>> controls(
    BuildContext context,
    GrcDashboardData data,
    String? policyId,
  ) =>
      [
        for (final c in data.controlsOf(policyId))
          DropdownItem<String?>(
            value: c.control.id,
            label: context.isArabic && c.control.controlsNameAr.isNotEmpty
                ? c.control.controlsNameAr
                : c.control.controlsNameEn,
          ),
      ];

  static List<DropdownItem<String?>> departments(
    BuildContext context,
    GrcDashboardData data,
  ) =>
      [
        for (final d in data.departments)
          DropdownItem<String?>(value: d, label: grcTr(context, d)),
      ];
}

/// ASC / DES sort, tap the active one again to clear.
class GrcDashboardSortButton extends StatelessWidget {
  final bool? ascending;
  final ValueChanged<bool?> onChanged;

  const GrcDashboardSortButton({
    super.key,
    required this.ascending,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomSortButton<String>(
      value: ascending == null ? null : (ascending! ? 'ASC' : 'DES'),
      items: const ['ASC', 'DES'],
      labelBuilder: (o) => grcTr(context, o),
      onChanged: (v) => onChanged(v == null ? null : v == 'ASC'),
      title: S.of(context).sort,
      showTitle: !context.isPhone,
      // Square on a phone, same height as the other filters.
      width: context.isPhone ? _filterHeight(context) : 90.w,
      height: _filterHeight(context),
      unselectedFillColor: AppColors.background,
      borderRadius: BorderRadius.circular(_radius),
    );
  }
}

/// Figma's Top | Least segmented control — CustomSegmentedTabs (9).
class GrcTopLeastToggle extends StatelessWidget {
  final bool top;
  final ValueChanged<bool> onChanged;

  const GrcTopLeastToggle({
    super.key,
    required this.top,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return CustomSegmentedTabs(
      tabs: [s.top, s.least],
      selectedIndex: top ? 0 : 1,
      onTabSelected: (i) => onChanged(i == 0),
      containerColor: AppColors.background,
      unselectedColor: AppColors.background,
      borderRadius: _radius,
      containerPadding: EdgeInsets.all(3.sp),
      spacing: 4.sp,
      tabHorizontalPadding: 14.sp,
      // Fills the filter height: 3 + 3 container padding, ~15 for the
      // 12-size label, the rest split above / below it.
      tabVerticalPadding:
          ((_filterHeight(context) - 6.sp - 15.sp) / 2).clamp(0, 20).toDouble(),
      textStyle: StyleText.fontSize12Weight600,
    );
  }
}

/// Figma's "Baseline" toggle on the Compliance Timeline.
///
/// A one-tab CustomSegmentedTabs (9) rather than customButton: customButton
/// always draws ButtonSizing.radius (8.r), and every dashboard filter is 4.r.
class GrcBaselineButton extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;

  const GrcBaselineButton({
    super.key,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100.w,
      child: CustomSegmentedTabs(
        tabs: [S.of(context).baseline],
        selectedIndex: active ? 0 : -1,
        onTabSelected: (_) => onTap(),
        equalWidth: true,
        borderRadius: _radius,
        containerColor: AppColors.background,
        containerPadding: EdgeInsets.zero,
        selectedColor: AppColors.primary,
        unselectedColor: AppColors.background,
        unselectedTextColor: AppColors.secondaryText,
        // ~18 for the 14-size label, the rest split above / below it.
        tabVerticalPadding:
            ((_filterHeight(context) - 18.sp) / 2).clamp(0, 20).toDouble(),
        textStyle: StyleText.fontSize14Weight400,
      ),
    );
  }
}

/// Lays header controls out in one wrapping row, trailing-aligned.
///
/// Every control gets the SAME box: [_filterHeight] (30 phone / 37 tablet
/// and desktop) tall with
/// 4.r corners ([_radius]). Each widget
/// asks for that on its own, but they apply it to different inner boxes, so
/// the height is also imposed here as a tight constraint.
class GrcFilterBar extends StatelessWidget {
  final List<Widget> children;

  const GrcFilterBar({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    // Phone (375): MAGDY has no dashboard frame at this width, so this
    // follows the other GRC phone screens:
    //   * no Sort button on a phone;
    //   * dropdowns (and Baseline) share rows two at a time, equal width,
    //     and a row with a single one keeps it on the trailing edge;
    //   * Top | Least sits on its own row at the trailing edge.
    if (screenSizeOf(context) == ScreenSize.mobile) {
      final double gap = 8.w;
      final List<Widget> toggles =
          children.whereType<GrcTopLeastToggle>().toList();
      final List<Widget> fields = children
          .where((c) => c is! GrcDashboardSortButton && c is! GrcTopLeastToggle)
          .toList();

      Widget box(Widget child) =>
          SizedBox(height: _filterHeight(context), child: child);

      final List<Widget> rows = [];
      for (var i = 0; i < fields.length; i += 2) {
        final bool single = i + 1 >= fields.length;
        rows.add(Row(
          children: [
            Expanded(
              child: single ? const SizedBox.shrink() : box(fields[i]),
            ),
            SizedBox(width: gap),
            Expanded(child: box(single ? fields[i] : fields[i + 1])),
          ],
        ));
      }
      for (final t in toggles) {
        rows.add(Align(
          alignment: AlignmentDirectional.centerEnd,
          child: box(t),
        ));
      }
      if (rows.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) SizedBox(height: gap),
            rows[i],
          ],
        ],
      );
    }
    return Wrap(
      spacing: 8.w,
      runSpacing: 6.h,
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final child in children)
          SizedBox(height: _filterHeight(context), child: child),
      ],
    );
  }
}
