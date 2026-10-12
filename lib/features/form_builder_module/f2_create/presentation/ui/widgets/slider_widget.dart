import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

import 'package:knowticed_plus/core/custom/62-custom_date_time_helper.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
// Date: 14/1/2025
// By: Mohamed Mohy
// Last update: 20/1/2025
// Objectives:  A widget for creating a slider .

class SliderWidget extends StatelessWidget {
  const SliderWidget({
    super.key,
    required this.title,
    required this.currantValue,
    this.onChanged,
  });

  final String title;
  final double currantValue;
  final void Function(double)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(),
        verticalSpace(8),
        LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxWidth,
              height: 36, // Adjusted height to accommodate all elements
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // The main slider
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 5, // Adjusted to center vertically with ticks
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.primary,
                        inactiveTrackColor: AppColors.primary,
                        thumbColor: AppColors.primary,
                        trackHeight: 3,
                        // Custom track shape to extend to edges
                        trackShape: CustomSliderTrackShape(),
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                          elevation: 2.0,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 16.0,
                        ),
                      ),
                      child: Slider(
                        value: currantValue,
                        min: 0.0,
                        max: 100.0,
                        onChanged: onChanged,
                      ),
                    ),
                  ),
                  // Tick markers
                  Positioned(
                    left: 0,
                    top: 0,
                    child: _buildTick(context),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: _buildTick(context),
                  ),
                  // Percentage labels
                  Positioned(
                    left: 0,
                    bottom: 0,
                    child: Text(
                      context.isArabic
                          ? '${FormDateTimeHelper.formatInt(100)}%'
                          : '${FormDateTimeHelper.formatInt(0)}%',
                      style: StyleText.fontSize12Weight500.copyWith(color: AppColors.primary),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Text(
                      context.isArabic
                          ? '${FormDateTimeHelper.formatInt(0)}%'
                          : '${FormDateTimeHelper.formatInt(100)}%',
                      style: StyleText.fontSize12Weight500.copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      title,
      style:StyleText.fontSize14Weight400,
    );
  }

  Widget _buildTick(BuildContext context) {
    return Container(
      width: ContextExtension(context).isTablett ? 4.w:8.w,
      height: 12.h,
      color:AppColors.primary,
    );
  }
}

// Custom track shape to extend the track to the edges
class CustomSliderTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight!;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(
        trackLeft, ((trackHeight / 2) * -1), trackWidth, trackHeight);
  }
}
