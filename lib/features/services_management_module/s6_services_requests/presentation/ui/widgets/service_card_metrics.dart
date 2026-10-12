// ******************* FILE INFO *******************
// File Name: service_card_metrics
// Description: Height calculation for the services request cards so each
//              grid's mainAxisExtent matches the card's real content height.
//              Hard-coded extents (234.sp / 257.sp) broke because the cards mix
//              .sp and .h units and ignore the device text scale, so the numbers
//              only lined up on one screen.
// Module: services_management_module / presentation/s6_services_requests/ui/widgets
// *************************************************

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class ServiceCardMetrics {
  /// System font-size setting, clamped so a large accessibility scale
  /// doesn't produce absurd card heights. Cards clamp to the same value.
  static const double maxTextScale = 1.4;

  static double textScale(BuildContext context) =>
      MediaQuery.textScalerOf(context).scale(1.0).clamp(1.0, maxTextScale);

  /// Height of one detail row: a 16.h icon beside a 14.sp line of text.
  static double _detailRow(BuildContext context) {
    final lineHeight = 14.sp * 1.45 * textScale(context);
    return lineHeight > 16.h ? lineHeight : 16.h;
  }

  /// Header row: 40.sp avatar + service name.
  static double _header(BuildContext context) {
    final title = 16.sp * 1.45 * textScale(context);
    return title > 40.sp ? title : 40.sp;
  }

  static const double _safety = 4.0; // guards sub-pixel rounding

  /// show_requests_service_card: header + 5 rows (5.sp gaps) + Request button.
  /// Padding: 15.sp top and bottom.
  static double requestCardExtent(BuildContext context) {
    final rows = 5 * _detailRow(context);
    final gaps = 5 * 5.sp;
    final button = 35.sp * textScale(context);

    return 15.sp + _header(context) + 5.sp + rows + gaps + 10.sp + button + 15.sp + _safety;
  }

  /// my_requests_service_card: header + 7 rows separated by 11.sp gaps,
  /// no button. Padding: 15.sp top and bottom.
  static double myRequestCardExtent(BuildContext context) {
    final rows = 7 * _detailRow(context);
    final gaps = 6 * 11.sp;

    return 15.sp + _header(context) + 5.sp + rows + gaps + 15.sp + _safety;
  }
}
