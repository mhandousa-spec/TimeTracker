// ******************* FILE INFO *******************
// File Name: helper_widget
// Description: Helper widget.
// Module: services_management_module / presentation/s9_admin_dashboard/ui/widgets
// *************************************************

import 'dart:ui';

import 'package:flutter/cupertino.dart';

double getTextWidth(String text, TextStyle style) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: 1,
    textDirection: TextDirection.ltr,
  )..layout();
  return textPainter.size.width;
}
