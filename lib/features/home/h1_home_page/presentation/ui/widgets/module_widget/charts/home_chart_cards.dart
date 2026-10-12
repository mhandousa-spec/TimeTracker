/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: home_chart_cards.dart
/// Purpose: Declares `HomeServicesOfferedChart`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

///********************** FILE INFO ****************************///
/// Purpose: The chart components offered on the Home Layout "Chart & Graph"
///          tab. Extracted from chart_widget_layout.dart so they can be
///          rendered by HomeComponents.widget() like any other component —
///          that is what lets the picker add them through the same
///          AddComponentWrapper flow the widget tab uses.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/24-custom_chart_card.dart';
import 'package:knowticed_plus/core/custom/26-custom_bar_chart_card.dart';
import 'package:knowticed_plus/core/custom/28-custom_horizontal_bar_chart_card.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Shared sizing so every chart card lines up in the picker grid and on the
/// home page.
const double kHomeChartWidth = 265;
const double kHomeChartHeight = 200;

/// Converts digits and the S1..S4 series labels to Arabic when the locale
/// calls for it. Lifted verbatim from the old HomeLayoutChartWidget.
String _formatLabel(String label, bool isArabic) {
  if (!isArabic) return label;
  const english = [
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
    'S', 's', 'A', 'a', 'B', 'b', 'C', 'c', 'D', 'd',
  ];
  const arabic = [
    '٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩',
    'س', 'س', 'أ', 'أ', 'ب', 'ب', 'ج', 'ج', 'د', 'د',
  ];
  String result = label;
  for (int i = 0; i < english.length; i++) {
    result = result.replaceAll(english[i], arabic[i]);
  }
  return result;
}

List<ChartData> _bars(List<String> labels, List<double> values, bool isArabic) {
  return [
    for (int i = 0; i < labels.length; i++)
      ChartData(label: _formatLabel(labels[i], isArabic), value: values[i]),
  ];
}

/// Services Offered — horizontal bars.
class HomeServicesOfferedChart extends StatelessWidget {
  const HomeServicesOfferedChart({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return HorizontalBarChartCard(
      title: S.of(context).servicesOffered,
      bars: _bars(
        const ['S1', 'S2', 'S3', 'S4'],
        const [10, 20, 30, 40],
        isArabic,
      ),
      width: kHomeChartWidth.w,
      barHeight: 10,
    );
  }
}

/// Number of Services — vertical bars.
class HomeNumberOfServicesChart extends StatelessWidget {
  const HomeNumberOfServicesChart({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return BarChartCard(
      title: S.of(context).numberOfServices,
      bars: _bars(
        const ['S1', 'S2', 'S3', 'S4'],
        const [100, 120, 104, 125],
        isArabic,
      ),
      width: kHomeChartWidth.w,
      chartHeight: kHomeChartHeight.h,
      barWidth: 20,
    );
  }
}
