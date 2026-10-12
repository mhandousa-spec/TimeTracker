import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';

// Date: 22/1/2025
// By: Mohamed Mohy
// Last update: 22/1/2025
// Objectives:  A widget for displaying a watermark image overlay on top of a page widget.
class PdfWaterMarkImagePage extends StatelessWidget {
  const PdfWaterMarkImagePage(
      {super.key, required this.page, required this.model});

  /// The main page widget displayed beneath the watermark.
  final Widget page;
  final FormEntity model;
  @override
  Widget build(BuildContext context) {
    return _buildPageWithWatermark(context);
  }

  /// Builds the page with an optional watermark overlay.
  Widget _buildPageWithWatermark(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 342.h,
        ),
        child: Stack(
          children: [
            if (model.formHeadModel.watermark != null) _buildWatermarkOverlay(),
            page,
          ],
        ),
      ),
    );
  }

  /// Builds the watermark overlay.
  Widget _buildWatermarkOverlay() {
    return Positioned.fill(
      child: Transform.scale(
        scale: model.formHeadModel.watermarkSize! / 100,
        child: Opacity(
          opacity: model.formHeadModel.watermarkOpacity! / 100,
          child: (model.formHeadModel.watermark!.contains('http'))?Image.network(
              model.formHeadModel.watermark!,

          ):Image.file(
             File(model.formHeadModel.watermark!),
          ),
        ),
      ),
    );
  }
}
