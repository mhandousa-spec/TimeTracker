/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: status_chip_filter.dart
/// Purpose: Declares `StatusChipFilter`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

// Date: 3/3/2026
// CreatedBy : Amr Mesbah
// Purpose: Reusable horizontal status chip filter widget
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class StatusChipFilter extends StatelessWidget {
  /// List of chip items to display
  final List<StatusChipItem> items;

  /// Currently selected key
  final String selectedKey;

  /// Called when a chip is tapped — returns the tapped item's key
  final ValueChanged<String> onSelected;

  /// Selected chip background color — defaults to primary
  final Color? selectedColor;

  /// Selected count text color — defaults to white
  final Color? selectedCountTextColor;

  /// Unselected chip background color — defaults to theme card color
  final Color? unselectedColor;

  /// Spacing between chips — defaults to 30.sp
  final double? chipSpacing;

  /// Spacing between count box and label — defaults to 15.sp
  final double? innerSpacing;

  /// Size of the count box — defaults to 45.sp (35.sp on mobile)
  final double? chipSize;

  const StatusChipFilter({
    super.key,
    required this.items,
    required this.selectedKey,
    required this.onSelected,
    this.selectedColor,
    this.selectedCountTextColor,
    this.unselectedColor,
    this.chipSpacing,
    this.innerSpacing,
    this.chipSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final isMobile = ContextExtension(context).isPhone;

    final resolvedSelectedColor = selectedColor ?? theme.colorScheme.primary;
    final resolvedUnselectedColor =
        unselectedColor ?? (isLight ? AppColors.white : theme.cardColor);
    final resolvedSelectedCountColor = selectedCountTextColor ?? AppColors.white;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.map((item) {
          final isSelected = item.key == selectedKey;
          return _StatusChip(
            key: item.widgetKey,
            item: item,
            isSelected: isSelected,
            isLight: isLight,
            selectedColor: resolvedSelectedColor,
            unselectedColor: resolvedUnselectedColor,
            selectedCountTextColor: resolvedSelectedCountColor,
            chipSpacing: chipSpacing ?? 30.sp,
            innerSpacing: innerSpacing ?? 15.sp,
            chipSize: chipSize ?? (isMobile ? 35.sp : 45.sp),
            onTap: () => onSelected(item.key),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal chip widget
// ─────────────────────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final StatusChipItem item;
  final bool isSelected;
  final bool isLight;
  final Color selectedColor;
  final Color unselectedColor;
  final Color selectedCountTextColor;
  final double chipSpacing;
  final double innerSpacing;
  final double chipSize;
  final VoidCallback onTap;

  const _StatusChip({
    super.key,
    required this.item,
    required this.isSelected,
    required this.isLight,
    required this.selectedColor,
    required this.unselectedColor,
    required this.selectedCountTextColor,
    required this.chipSpacing,
    required this.innerSpacing,
    required this.chipSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // ── Label color logic ─────────────────────────────────────────────────
    // Priority: item.labelColor → selected: AppColors.text / unselected: AppColors.secondaryText
    final Color labelColor = item.labelColor ??
        (isSelected ? AppColors.text : AppColors.secondaryText);

    // ── Count text color ──────────────────────────────────────────────────
    final Color countColor =
    isSelected ? AppColors.textButton : AppColors.text;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Count box ───────────────────────────────────────────────────
          Container(
            width: chipSize,
            height: chipSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.card,
              borderRadius: BorderRadius.circular(4.r),
            ),
            // FIXED 8/9/2026 — the number sat low in the box instead of
            // centred, most visibly on phones.
            //
            // The cause was the `textHeightBehavior` that used to be here.
            // `height: 1.0` plus `TextLeadingDistribution.even` is the pair
            // that centres a glyph in its line box: the line is pinned to
            // exactly one em and the slack is split equally above and below.
            // But `applyHeightToFirstAscent: false` exempts the first line's
            // ascent from precisely that treatment, so the space above the
            // digit reverted to the font's own, larger ascent while the space
            // below stayed clamped. The line box came out top-heavy, and
            // `Alignment.center` faithfully centred that lopsided box — which
            // is what pushed the digit below the middle.
            //
            // Both overrides are gone. The digit is centred by the Container's
            // own `alignment` against the font's natural metrics, which need no
            // correction for a numeral — it has neither ascender nor descender.
            //
            // Why it read as phone-only: the offset is a fixed number of
            // pixels and the box is 35.sp on a phone against 45.sp elsewhere,
            // so the same few pixels are a much bigger share of the box.
            child: Text(
              // FIXED 13/8/2026: was `item.count.toString()`, always ASCII, so
              // an Arabic screen showed "14"/"0" next to Arabic-Indic dates.
              // Display only — `item.count` stays an int everywhere else.
              LocalizedNumber.of(context, item.count),
              textAlign: TextAlign.center,
              style: StyleText.fontSize20Weight500.copyWith(
                color: countColor,
              ),
            ),
          ),

          SizedBox(width: innerSpacing),

          // ── Label ───────────────────────────────────────────────────────
          Text(
            item.label,
            style: StyleText.fontSize16Weight600.copyWith(color: labelColor),
          ),

          SizedBox(width: chipSpacing),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data model for a single chip
// ─────────────────────────────────────────────────────────────────────────────

class StatusChipItem {
  /// Unique identifier — used to match [StatusChipFilter.selectedKey]
  final String key;

  /// Display label shown next to the count box
  final String label;

  /// Count shown inside the box
  final int count;

  /// Optional fixed label color.
  /// If null → selected uses AppColors.text, unselected uses AppColors.secondaryText.
  final Color? labelColor;

  /// ADDED 13/10/2026 (Time Tracker) — optional widget key of this chip
  /// (tests tap one chip by it). Null = no key.
  final Key? widgetKey;

  const StatusChipItem({
    required this.key,
    required this.label,
    required this.count,
    this.labelColor,
    this.widgetKey,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Department / status filter helper
// Reproduces the behaviour of the former DepartmentFilterChips widget so it can
// be used together with [StatusChipFilter]:
//   • prepends an "All" chip (canonical key 'All') showing [totalCount]
//   • localizes known English department names to Arabic when [isArabic]
//   • capitalizes labels via FormatHelper.capitalize
// The chip `key` stays the English/canonical value so selection logic is
// unchanged; only the displayed label is localized.
// ─────────────────────────────────────────────────────────────────────────────

/// English → Arabic labels for known departments (and the "All" chip).
const Map<String, String> kDepartmentEnToAr = {
  'All': 'الكل',
  'Executive': 'الإدارة التنفيذية',
  'Customer Support': 'دعم العملاء',
  'Finance': 'المالية',
  'Operations': 'العمليات',
  'Information Technology': 'تقنية المعلومات',
  'Human Resources': 'الموارد البشرية',
  'Marketing': 'التسويق',
  'Sales': 'المبيعات',
  'Data Management': 'إدارة البيانات',
  'Compliance & Legal': 'الامتثال والشؤون القانونية',
  'Software': 'البرمجيات',
};

/// Builds the [StatusChipItem] list for a department/status filter.
List<StatusChipItem> departmentChipItems({
  required int totalCount,
  required Map<String, int> departmentCounts,
  required bool isArabic,
  Map<String, Color>? labelColors,

  /// Order chips by how many items each one holds, busiest first -- useful on
  /// a list where the populated filters are the only ones worth reaching for
  /// and a row of zeroes just pushes them off screen. 'All' always stays
  /// first regardless; ties keep their original relative order, so the layout
  /// does not reshuffle between two equal counts. Defaults to false, which
  /// keeps the insertion order of [departmentCounts] -- what screens with a
  /// meaningful fixed order (a status lifecycle, say) want.
  bool sortByCountDescending = false,
}) {
  String displayLabel(String key) {
    final raw = isArabic ? (kDepartmentEnToAr[key] ?? key) : key;
    return FormatHelper.capitalize(raw);
  }

  var entries = departmentCounts.entries.toList();

  if (sortByCountDescending) {
    // Decorate with the original index so the sort is stable: List.sort is not
    // guaranteed stable, and without this two chips with the same count could
    // swap places on every rebuild.
    final indexed = entries.asMap().entries.toList()
      ..sort((a, b) {
        final byCount = b.value.value.compareTo(a.value.value);
        return byCount != 0 ? byCount : a.key.compareTo(b.key);
      });
    entries = indexed.map((e) => e.value).toList();
  }

  return [
    StatusChipItem(
      key: 'All',
      label: displayLabel('All'),
      count: totalCount,
    ),
    ...entries.map(
      (entry) => StatusChipItem(
        key: entry.key,
        label: displayLabel(entry.key),
        count: entry.value,
        labelColor: labelColors?[entry.key],
      ),
    ),
  ];
}


// How to Use
// StatusChipFilter(
//   selectedKey: selectedStateFilter,
//   onSelected: (key) => setState(() {
//     selectedStateFilter = key;
//     _applyFilters();
//   }),
//   items: [
//     StatusChipItem(key: "In Use",       label: S.of(context).inUse,       count: stateCounts["In Use"]!,       labelColor: const Color(0xFF4BB609)),
//     StatusChipItem(key: "Returned",     label: S.of(context).returned,     count: stateCounts["Returned"]!,     labelColor: const Color(0xFFDF1C1C)),
//     StatusChipItem(key: "Maintenance",  label: S.of(context).maintenance,  count: stateCounts["Maintenance"]!,  labelColor: const Color(0xFFE5B800)),
//     StatusChipItem(key: "Under Repair", label: S.of(context).underRepair,  count: stateCounts["Under Repair"]!, labelColor: const Color(0xFFFFDE59)),
//     StatusChipItem(key: "Damaged",      label: S.of(context).damaged,      count: stateCounts["Damaged"]!,      labelColor: const Color(0xFFBA1B1B)),
//     StatusChipItem(key: "Missing",      label: S.of(context).missing,      count: stateCounts["Missing"]!,      labelColor: const Color(0xFF797979)),
//     StatusChipItem(key: "Stolen",       label: S.of(context).stolen,       count: stateCounts["Stolen"]!,       labelColor: const Color(0xFF797979)),
//   ],
// ),