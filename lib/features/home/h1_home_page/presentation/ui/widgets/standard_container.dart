/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: standard_container.dart
/// Purpose: Declares `StandardContainer`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

class StandardContainer extends StatelessWidget {
  StandardContainer(
      {this.padding = 10, this.height, required this.child, super.key});
  int padding;
  Widget child;
  double? height;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.all(padding.sp),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}
