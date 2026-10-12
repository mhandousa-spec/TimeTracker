/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: chart_card.dart
/// Purpose: Declares `ChartSvg`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 9/10/2026 - (Time Tracker UI fix round 1) `ChartLegendRow.maxLines`
///          (default 1 = unchanged) so a legend label can wrap instead of "…".

// Shared shell + helpers for the chart widgets (Figma CHARTS section).
// Same style language as the card widgets: AppColors theme + screenutil.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';

/// SVG icon assets used by the chart widgets.
/// All paths point to existing, pubspec-declared assets in assets/icons_assets.
abstract class ChartSvg {
  static const String products = 'assets/icons_assets/home_assets/inventory_products_box.svg';
  static const String orders = 'assets/icons_assets/home_assets/service_requests_document.svg';
  static const String warehouse = 'assets/icons_assets/roles_assets/inventory_warehouse.svg';
  static const String lowStock = 'assets/icons_assets/home_assets/inventory_damaged_box.svg';
  static const String supplier = 'assets/icons_assets/services_assets/building_office.svg';
  static const String request = 'assets/icons_assets/settings_assets/requests_edit_document.svg';
  static const String present = 'assets/icons_assets/main_icons_assets/check_circle_green.svg';
  static const String absent = 'assets/icons_assets/main_icons_assets/prohibited_circle.svg';
  static const String late = 'assets/icons_assets/main_icons_assets/clock_circle.svg';
  static const String vacation = 'assets/icons_assets/home_assets/todo_scheduled_calendar.svg';
  static const String excused = 'assets/icons_assets/settings_assets/request_change_document.svg';
}

/// White rounded container with the standard chart header:
/// [yellow dot] Title ........................ [trailing controls]
class ChartCard extends StatelessWidget {
  final String title;
  final Color? dotColor;
  final Widget? trailing;
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final String? dotIcon; // ← add this

  /// Let [child] absorb the leftover vertical space instead of hugging
  /// its content. Only valid together with an explicit [height] (or a
  /// parent that gives a tight height) — a flexed child in an unbounded
  /// column asserts.
  final bool expandChild;

  const ChartCard({
    super.key,
    required this.title,
    required this.child,
    this.dotColor,
    this.trailing,
    this.width,
    this.height,
    this.padding,
    this.dotIcon, // ← add this
    this.expandChild = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      // Figma: card padding 16.
      padding: padding ?? EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: CardStyles.radius(),
        boxShadow: CardStyles.shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Header marker: a tinted SVG icon when [dotIcon] is given,
              // otherwise the standard small colored dot.
              if (dotIcon != null)
                // Same proportions as the bar-chart card header: a 26 circle
                // with a 16 glyph centered inside, so the icon reads as a
                // badge instead of filling the whole circle.
                Container(
                  width: 26.r,
                  height: 26.r,
                  decoration: BoxDecoration(
                    color: dotColor ?? AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: CustomSvgImage(
                      assetPath: dotIcon!,
                      width: 16.r,
                      height: 16.r,
                      fit: BoxFit.contain,
                      color: AppColors.textButton,
                    ),
                  ),
                )
              else
                Container(
                  width: 10.r,
                  height: 10.r,
                  decoration: BoxDecoration(
                    color: dotColor ?? AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              // GRC bug report p32: 6 read as the badge touching the title.
              SizedBox(width: dotIcon != null ? 10.w : 6.w),
              Expanded(
                child: Text(
                  title,
                  style: CardStyles.title(14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          // CHANGED 12/9/2026 — 20.sp on a phone, was 12.
          //
          // A bar chart draws its value label ABOVE the bar, so on a narrow
          // card the topmost "4" ended up level with the title row and the two
          // read as one line of overlapping text (Knowledge Hub Resources).
          // 12 was tuned on the wide cards, where the plot has room to breathe.
          //
          // Tablet and desktop keep 12.h — several cards there are pinned to a
          // fixed height with no slack to give, and they were never crowded.
          SizedBox(height: ContextExtension(context).isPhone ? 20.sp : 12.h),
          // NOTE: keep this branch intrinsic-safe. This card is used inside
          // IntrinsicHeight layouts (e.g. the knowledge dashboard's Dept +
          // Document-Utilization row, mirroring the services dashboard), and
          // IntrinsicHeight measures its children's intrinsic height. A
          // LayoutBuilder or a scroll view (viewport) cannot report an intrinsic
          // height, so wrapping [child] in either produces a zero-size render
          // box and crashes hit-testing ("Cannot hit test a render box with no
          // size"). Callers that give this card a FIXED height must therefore
          // pass one large enough for the content (or use expandChild).
          if (expandChild) Expanded(child: child) else child,
        ],
      ),
    );
  }
}

/// Whether a bar chart renders vertically ([BarChartCard], 26) or
/// horizontally ([HorizontalBarChartCard], 28).
///
/// Moved here from the removed
/// home/h1_home_page/presentation/ui/services_management_module/dashboard_view_data/, so the chart
/// cards and the enum that selects between them live together in core.
enum ChartOrientation {
  horizontal,
  vertical;

  /// Convert enum to string for Firestore storage
  String toFirestore() => name;

  /// Create enum from Firestore string
  static ChartOrientation fromFirestore(String value) {
    switch (value.toLowerCase()) {
      case 'horizontal':
        return ChartOrientation.horizontal;
      case 'vertical':
        return ChartOrientation.vertical;
      default:
        return ChartOrientation.vertical; // Default fallback
    }
  }
}

/// One data entry for charts: label + value + color.
class ChartData {
  final String label;
  final double value;
  final Color? color;

  const ChartData({required this.label, required this.value, this.color});
}

/// Legend row item: [colored dot] Name ..... Amount
class ChartLegendRow extends StatelessWidget {
  final String name;
  final String? amount;
  final Color color;
  final double fontSize;

  /// ADDED 9/10/2026: lines the name may use before it ends in "…".
  /// Defaults to 1 (the historical single line); null = wrap freely.
  final int? maxLines;

  const ChartLegendRow({
    super.key,
    required this.name,
    required this.color,
    this.amount,
    this.fontSize = 12,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        children: [
          Container(
            width: 10.r,
            height: 10.r,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              name,
              style: CardStyles.label(fontSize),
              maxLines: maxLines,
              overflow: maxLines == 1 ? TextOverflow.ellipsis : TextOverflow.visible,
            ),
          ),
          // 9/10/2026 (Time Tracker UI pass): a gap so a long name never
          // touches its amount ("Annual Vacation2").
          if (amount != null) ...[
            SizedBox(width: 8.w),
            Text(amount!, style: CardStyles.value(fontSize)),
          ],
        ],
      ),
    );
  }
}

/// Compact horizontal legend (dot + name) used above grouped charts.
class ChartLegendInline extends StatelessWidget {
  final List<ChartData> items;
  final double fontSize;

  const ChartLegendInline({super.key, required this.items, this.fontSize = 10});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10.w,
      runSpacing: 4.h,
      children: [
        for (final item in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8.r,
                height: 8.r,
                decoration: BoxDecoration(
                    color: item.color ?? AppColors.primary,
                    shape: BoxShape.circle),
              ),
              SizedBox(width: 4.w),
              Text(item.label, style: CardStyles.label(fontSize)),
            ],
          ),
      ],
    );
  }
}

/// Small yellow pill tab (e.g. "Consumables") used in chart headers.
class ChartTabPill extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final Color? color;

  const ChartTabPill({super.key, required this.text, this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: color ?? AppColors.primary,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          text,
          style: CardStyles.title(11).copyWith(color: AppColors.textButton),
        ),
      ),
    );
  }
}
