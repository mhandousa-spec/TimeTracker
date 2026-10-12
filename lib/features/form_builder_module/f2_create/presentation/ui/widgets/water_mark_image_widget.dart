import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_head_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_head_state.dart';

// Date: 22/1/2025
// By: Mohamed Mohy
// Last update: 22/1/2025
// Objectives: A widget for displaying a watermark image overlay on top of a page widget.
class WaterMarkImagePage extends StatelessWidget {
  const WaterMarkImagePage({super.key, required this.page});

  /// The main page widget displayed beneath the watermark.
  final Widget page;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateFormHeadCubit, CreateFormHeadState>(
      builder: (context, state) {
        if (state is! CreateFormHeadLoaded) {
          return Column(
            children: [
              _buildPageWithoutWatermark(context),
            ],
          );
        }

        return Column(
          children: [
            _buildPageWithWatermark(context, state),
          ],
        );
      },
    );
  }

  /// Builds the page without watermark (fallback)
  Widget _buildPageWithoutWatermark(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.card,
      constraints: BoxConstraints(minHeight: 321.h),
      child: page,
    );
  }

  /// Builds the page with an optional watermark overlay.
  Widget _buildPageWithWatermark(
      BuildContext context,
      CreateFormHeadLoaded state,
      ) {
    return Container(
      width: double.infinity,
      color: AppColors.card,
      constraints: BoxConstraints(minHeight: 321.h),
      child: Stack(
        children: [
          if (state.watermark != null) _buildWatermarkOverlay(state),
          page,
        ],
      ),
    );
  }

  /// Builds the watermark overlay.
  Widget _buildWatermarkOverlay(CreateFormHeadLoaded state) {
    final watermarkSize =
        double.tryParse(state.watermarkSizeController.text) ?? 100.0;
    final watermarkOpacity =
        double.tryParse(state.watermarkOpacityController.text) ?? 50.0;

    return Positioned.fill(
      child: Transform.scale(
        scale: watermarkSize / 100,
        child: Opacity(
          opacity: watermarkOpacity / 100,
          child: state.watermark!.contains('http')
              ? Image.network(state.watermark!)
              : Image.file(File(state.watermark!)),
        ),
      ),
    );
  }
}