// ******************* FILE INFO *******************
// File Name: home_services_action_button_metrics
// Description: Shared sizing for the 2x2 action-button grid in the top-right
//              corner of the Services home page.
// Module: services_management_module / presentation/s1_home_page_services/ui/widgets
// *************************************************
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/41-custom_button_sizing.dart';

import 'package:knowticed_plus/core/custom/41-custom_button_sizing.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Sizing for the four top-right action buttons, which read as a 2x2 grid:
///
/// ```
/// [ Bulk Upload ][ Admin Dashboard ]
/// [ Dashboard   ][ Approvals       ]
/// ```
///
/// Row 1 is built in `management_widget`, row 2 in `request_services_button`,
/// and both are right-aligned — so the columns only line up when the buttons
/// in each column are literally the same width.
///
/// Why this measures instead of hardcoding a number:
/// `customButton` ignores its `width` argument on purpose (see
/// 5-custom_button.dart) and defers to [ButtonSizing], which returns the
/// standard 135.sp *only when the label fits*. "Admin Dashboard" does not fit,
/// so it silently fell back to wrapping its own text and came out ~23px wider
/// than "Approvals" below it. Passing a width did nothing; the value was
/// discarded before it reached the widget.
///
/// So each column is measured against the widest label it contains — in the
/// active language, at the active text scale — and both rows pass that single
/// value through `customButton(exactWidth: ...)`. Translate a label or bump a
/// font and the columns stay aligned on their own.
class HomeServicesActionButtons {
  const HomeServicesActionButtons._();

  /// The style both rows render these buttons with. Measurement has to use the
  /// exact same style or the computed width will be wrong.
  static TextStyle labelStyle(BuildContext context) =>
      StyleText.fontSize16Weight500.copyWith(
        color: AppColors.textButton,
      );

  /// Leading column — "Bulk Upload" (row 1) and "Dashboard" (row 2).
  static double leadingWidth(BuildContext context) => _widestOf(
        context,
        ['Bulk Upload', S.of(context).dashboard],
      );

  /// Trailing column — "Admin Dashboard" (row 1) and "Approvals" (row 2).
  static double trailingWidth(BuildContext context) => _widestOf(
        context,
        [S.of(context).adminDashboard, S.of(context).approvals],
      );

  /// Gutter between the two columns.
  ///
  /// `.w`, not `.sp`: ScreenUtil scales those on different axes, and the two
  /// rows previously used one each (20.w vs 15.sp), so they drifted apart as
  /// the window resized even when the widths matched.
  static double get columnGap => 15.w;

  /// Width for whichever single button survives on phone layouts, where the
  /// grid collapses and alignment no longer applies.
  static double get mobileWidth => 140.w;

  static double get height => ButtonSizing.height;

  static double get radius => ButtonSizing.radius;

  /// Widest rendered label in [titles], plus the padding `customButton` adds
  /// when it wraps content. Never narrower than the app-standard button width,
  /// so a column of short labels still looks like every other button.
  static double _widestOf(BuildContext context, List<String> titles) {
    final style = labelStyle(context);
    final textDirection = Directionality.maybeOf(context) ?? TextDirection.ltr;
    final textScaler = MediaQuery.textScalerOf(context);

    double widest = 0;
    for (final title in titles) {
      final painter = TextPainter(
        text: TextSpan(text: title, style: style),
        textDirection: textDirection,
        textScaler: textScaler,
        maxLines: 1,
      )..layout();
      if (painter.width > widest) widest = painter.width;
    }

    final needed = widest + (2 * ButtonSizing.horizontalPadding);
    final standard = 135.sp;
    return needed > standard ? needed : standard;
  }
}
