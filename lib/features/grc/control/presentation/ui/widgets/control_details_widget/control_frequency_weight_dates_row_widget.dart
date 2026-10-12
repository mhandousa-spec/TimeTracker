/// Module: GRC Policy Management
/// Description: Frequency/Weight/Start Date/End Date read-only info row for
///              the Control Details page, extracted from
///              ControlDetailsPage.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-21
/// Dependencies: flutter, CardStyles
/// Revision History: 2026-07-21 - Initial creation (inline in
///                                control_details_page.dart)
///                   2026-07-28 - Split out into its own widget file
library;

/// ************************* FILE INFO *************************** ///
/// File Name: control_frequency_weight_dates_row_widget.dart
/// Purpose: Contains ControlFrequencyWeightDatesRowWidget, the four-column
///          read-only row showing Frequency, Control Weight, Start Date,
///          and End Date.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 28/7/2026

import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:knowticed_plus/generated/l10n.dart';

/// class name: [ControlFrequencyWeightDatesRowWidget]
///
/// purpose: renders the read-only Frequency / Control Weight / Start Date /
///          End Date four-column row.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 28/7/2026
class ControlFrequencyWeightDatesRowWidget extends StatelessWidget {
  final String frequency;
  final double weight;
  final DateTime startDate;
  final DateTime endDate;
  final DateFormat dateFormat;

  const ControlFrequencyWeightDatesRowWidget({
    super.key,
    required this.frequency,
    required this.weight,
    required this.startDate,
    required this.endDate,
    required this.dateFormat,
  });

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text.rich(
        TextSpan(
          text: '$label ',
          style: CardStyles.label(14),
          children: [TextSpan(text: value, style: CardStyles.value(14))],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Four columns fit at 768 and 1024. At 375 they do not, so the design
    // stacks them one label/value per line.
    final bool isMobile = screenSizeOf(context) == ScreenSize.mobile;

    Widget cell(Widget child) => isMobile ? child : Expanded(child: child);

    final List<Widget> cells = [
      cell(_infoRow('${S.of(context).frequency}:', frequency)),
      cell(_infoRow(
        '${S.of(context).controlWeight}:',
        weight.toStringAsFixed(0),
      )),
      cell(_infoRow(
        '${S.of(context).startDate}:',
        dateFormat.format(startDate),
      )),
      cell(_infoRow(
        '${S.of(context).endDate}:',
        dateFormat.format(endDate),
      )),
    ];

    return isMobile
        ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: cells)
        : Row(crossAxisAlignment: CrossAxisAlignment.start, children: cells);
  }
}
