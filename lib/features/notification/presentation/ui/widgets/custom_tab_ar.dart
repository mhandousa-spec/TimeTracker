/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: custom_tab_ar.dart
/// Purpose: A tab label that lays out correctly in Arabic.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - Added the standard header (Docs).

// custom_tab_underline.dart
import 'package:flutter/material.dart';

class CustomTabUnderline extends StatelessWidget {
  final String text;
  final TextStyle textStyle;
  final Color color;
  final double height;

  const CustomTabUnderline({
    super.key,
    required this.text,
    required this.textStyle,
    required this.color,
    this.height = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    return Container(
      width: textPainter.width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}