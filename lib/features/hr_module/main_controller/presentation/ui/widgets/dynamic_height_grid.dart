// ***************************** FILE INFO ***************************** //
// File Name: dynamic_height_grid.dart
// Purpose: Arranges HR form fields into responsive dynamic-height rows.
// Author: Mohamed Elrashidy
// Created At: 2026-08-08
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Arranges widgets into equal-width responsive rows with dynamic heights.
class DynamicHeightGrid extends StatelessWidget {
  const DynamicHeightGrid({
    required this.widgets,
    this.horizontalSpacing,
    this.verticalSpacing,
    required this.crossAxisCount,
    super.key,
  });

  final List<Widget> widgets;
  final double? horizontalSpacing;
  final double? verticalSpacing;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    if (widgets.isEmpty || crossAxisCount <= 0) {
      return const SizedBox.shrink();
    }

    final modifiedWidgets = List<Widget>.from(widgets);
    while (modifiedWidgets.length % crossAxisCount != 0) {
      modifiedWidgets.add(const SizedBox.shrink());
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: verticalSpacing ?? 8.sp,
      children: [
        for (int i = 0; i < modifiedWidgets.length; i += crossAxisCount)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: horizontalSpacing ?? 8.sp,
            children: [
              ...modifiedWidgets
                  .skip(i)
                  .take(crossAxisCount)
                  .map((widget) => Expanded(child: widget)),
            ],
          ),
      ],
    );
  }
}
