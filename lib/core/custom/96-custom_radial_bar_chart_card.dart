/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: custom_radial_bar_chart_card.dart
/// Purpose: Declares `RadialBarChartCard` and `RadialBarPainter`.
/// Author: Knowticed Plus team
/// Created at: 23/8/2026 - Added with the Figma "Chart & Graph" tab pass.

// Figma: "Radial Bar Chart" — one concentric arc per series, longest ring
// outermost, each arc sitting on a faint full-circle track, with the legend
// stacked down the left of the rings.
//
// fl_chart has no radial-bar type, so this is a CustomPainter. Values are
// read as a fraction of [RadialBarChartCard.maxValue] (the largest value when
// none is given), so the longest arc sweeps [RadialBarChartCard.sweepDegrees].
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/24-custom_chart_card.dart';
import 'package:knowticed_plus/core/custom/91-custom_chart_extras.dart';

/// Radial (concentric arc) bar chart card.
///
/// ```dart
/// RadialBarChartCard(
///   title: 'Radial Bar Chart',
///   bars: const [
///     ChartData(label: 'Line 1 Label', value: 90),
///     ChartData(label: 'Line 2 Label', value: 70),
///     ChartData(label: 'Line 3 Label', value: 45),
///   ],
/// )
/// ```
class RadialBarChartCard extends StatelessWidget {
  final String title;

  /// One arc per entry, drawn outermost first.
  final List<ChartData> bars;

  final Widget? trailing;

  /// Anything placed under the chart — usually a [ChartViewDetails] link.
  final Widget? footer;

  /// Value that maps to a full [sweepDegrees] arc. Defaults to the largest
  /// value in [bars], so the longest arc always reaches the full sweep.
  final double? maxValue;

  /// How far a full-value arc travels, in degrees. The Figma card stops
  /// short of a full turn so the ring ends stay readable.
  final double sweepDegrees;

  final double chartSize;
  final double ringWidth;
  final double ringGap;
  final double? width;

  /// Fixed card height. Null keeps the card hugging its content; the Adding
  /// Widget picker passes Figma's 200 so a row of charts lines up.
  final double? height;

  /// Card padding. Null uses [ChartCard]'s default of 16; the Figma chart
  /// frames use 10.
  final EdgeInsetsGeometry? padding;

  /// Forwarded to [ChartCard.expandChild]: with a fixed [height], let the
  /// plot absorb the leftover space rather than leaving a gap underneath.
  final bool expandChild;

  /// Show the legend beside the rings.
  final bool showLegend;

  /// Color of the header dot.
  final Color? dotColor;

  /// Optional SVG asset placed inside the header dot.
  final String? dotIcon;

  const RadialBarChartCard({
    super.key,
    required this.title,
    required this.bars,
    this.trailing,
    this.footer,
    this.maxValue,
    this.sweepDegrees = 300,
    this.chartSize = 150,
    this.ringWidth = 8,
    this.ringGap = 5,
    this.width,
    this.height,
    this.padding,
    this.expandChild = false,
    this.showLegend = true,
    this.dotColor,
    this.dotIcon,
  });

  double get _maxValue {
    if (maxValue != null && maxValue! > 0) return maxValue!;
    double m = 0;
    for (final ChartData b in bars) {
      if (b.value > m) m = b.value;
    }
    return m == 0 ? 1 : m;
  }

  @override
  Widget build(BuildContext context) {
    final Widget rings = SizedBox(
      width: chartSize.r,
      height: chartSize.r,
      child: CustomPaint(
        painter: RadialBarPainter(
          values: <double>[
            for (final ChartData b in bars)
              (b.value / _maxValue).clamp(0.0, 1.0),
          ],
          colors: <Color>[
            for (int i = 0; i < bars.length; i++) resolveSeriesColor(bars, i),
          ],
          trackColor: AppColors.background,
          ringWidth: ringWidth.r,
          ringGap: ringGap.r,
          sweepRadians: sweepDegrees * math.pi / 180,
        ),
      ),
    );

    return ChartCard(
      title: title,
      trailing: trailing,
      width: width,
      height: height,
      padding: padding,
      expandChild: expandChild,
      dotColor: dotColor,
      dotIcon: dotIcon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (showLegend)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      for (int i = 0; i < bars.length; i++)
                        ChartLegendRow(
                          name: bars[i].label,
                          color: resolveSeriesColor(bars, i),
                          fontSize: 10,
                        ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                rings,
              ],
            )
          else
            Center(child: rings),
          if (footer != null) ...<Widget>[
            SizedBox(height: 6.h),
            footer!,
          ],
        ],
      ),
    );
  }
}

/// Paints the concentric arcs for [RadialBarChartCard].
///
/// [values] are already normalised to 0..1 and are drawn outermost first, so
/// index 0 gets the largest radius.
class RadialBarPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  final Color trackColor;
  final double ringWidth;
  final double ringGap;
  final double sweepRadians;

  const RadialBarPainter({
    required this.values,
    required this.colors,
    required this.trackColor,
    required this.ringWidth,
    required this.ringGap,
    required this.sweepRadians,
  });

  /// Arcs start at 12 o'clock and run clockwise, matching the Figma card.
  static const double _startAngle = -math.pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double outerRadius =
        math.min(size.width, size.height) / 2 - ringWidth / 2;

    final Paint track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringWidth
      ..strokeCap = StrokeCap.round
      ..color = trackColor;

    final Paint arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringWidth
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < values.length; i++) {
      final double radius = outerRadius - i * (ringWidth + ringGap);
      // Once the rings would collapse through the middle there is no room
      // left to draw a readable arc, so the remaining series are skipped.
      if (radius <= ringWidth) break;

      final Rect rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(rect, _startAngle, sweepRadians, false, track);

      arc.color = i < colors.length ? colors[i] : AppColors.primary;
      canvas.drawArc(
        rect,
        _startAngle,
        sweepRadians * values[i],
        false,
        arc,
      );
    }
  }

  @override
  bool shouldRepaint(covariant RadialBarPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.colors != colors ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.ringWidth != ringWidth ||
        oldDelegate.ringGap != ringGap ||
        oldDelegate.sweepRadians != sweepRadians;
  }
}
