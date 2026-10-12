// ***************************** FILE INFO ***************************** //
// File Name: employee_details_fields_grid.dart
// Purpose: Lays employee detail fields out responsively.
// Author: Mohamed Elrashidy
// Created At: 2026-08-17
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Arranges detail fields in three, two, or one responsive columns.
class EmployeeDetailsFieldsGrid extends StatelessWidget {
  const EmployeeDetailsFieldsGrid({required this.children, super.key});

  final List<Widget> children;

  /// Method Name: [_columnCount]
  ///
  /// Purpose: Resolves the appropriate detail-field column count.
  ///
  /// Parameters:
  /// - [width]: The available section body width.
  ///
  /// Returns: A desktop, tablet, or mobile column count.
  int _columnCount(double width) {
    if (width >= 900.w) return 3;
    if (width >= 560.w) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _columnCount(constraints.maxWidth);
        const gap = 18.0;
        final itemWidth =
            (constraints.maxWidth - ((columns - 1) * gap.w)) / columns;
        return Wrap(
          spacing: gap.w,
          runSpacing: 16.h,
          children: children
              .map((child) => SizedBox(width: itemWidth, child: child))
              .toList(),
        );
      },
    );
  }
}
