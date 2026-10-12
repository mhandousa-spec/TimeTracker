// ******************* FILE INFO *******************
// File Name: services_ui_helpers
// Description: Services ui helpers.
// Module: services_management_module / data/helper
// *************************************************

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

/// Module-local copy of CurvedArrowPainter so the services-management module
/// is self-contained and portable between apps (no dependency on host `core`).
class CurvedArrowPainter extends CustomPainter {
  final Color color;
  final bool isArabic;

  CurvedArrowPainter({required this.color, required this.isArabic});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    final arrowSize = 6.0;

    if (isArabic) {
      // RTL arrow
      path.moveTo(size.width / 2 + 10, 0);
      path.lineTo(size.width / 2 + 10, size.height / 2);
      path.lineTo(size.width / 2 - 10, size.height / 2);

      final arrowPath = Path();
      arrowPath.moveTo(size.width / 2 - 10 + arrowSize, size.height / 2 - arrowSize);
      arrowPath.lineTo(size.width / 2 - 10, size.height / 2);
      arrowPath.lineTo(size.width / 2 - 10 + arrowSize, size.height / 2 + arrowSize);

      canvas.drawPath(path, paint);
      canvas.drawPath(arrowPath, paint);
    } else {
      // LTR arrow
      path.moveTo(size.width / 2 - 10, 0);
      path.lineTo(size.width / 2 - 10, size.height / 2);
      path.lineTo(size.width / 2 + 10, size.height / 2);

      final arrowPath = Path();
      arrowPath.moveTo(size.width / 2 + 10 - arrowSize, size.height / 2 - arrowSize);
      arrowPath.lineTo(size.width / 2 + 10, size.height / 2);
      arrowPath.lineTo(size.width / 2 + 10 - arrowSize, size.height / 2 + arrowSize);

      canvas.drawPath(path, paint);
      canvas.drawPath(arrowPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
