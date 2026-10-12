/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: custom_responsive_fields.dart
/// Purpose: Shared form field widget.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

/// ******************* FILE INFO *******************
/// File Name: custom_responsive_field.dart
/// Description: Custom responsive field to handle how fields preview on all platforms.
/// Created by: Amr Mesbah
/// Last Update: 30/8/2025

import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget buildResponsiveFields({
  required BuildContext context,
  required Widget left,
  required Widget right,
  double? mobileSpacing, // ← optional height for mobile
}) {
  final isMobile = MediaQuery.of(context).size.width < 600;

  if (isMobile) {
    return Column(
      children: [
        left,
        SizedBox(height: (mobileSpacing ?? 15).h), // ← default 15 if null
        right,
      ],
    );
  } else {
    return Row(
      children: [
        Expanded(child: left),
        SizedBox(width: 15.sp),
        Expanded(child: right),
      ],
    );
  }
}
