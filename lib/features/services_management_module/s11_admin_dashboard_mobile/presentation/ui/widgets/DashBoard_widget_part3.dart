part of 'DashBoard_widget.dart';

// Split from DashBoard_widget.dart to keep files <700 LOC.

class CustomHorizontalBarChartWidget extends StatelessWidget {
  final String title;
  final String? iconAsset;
  final List<String> labels;
  final List<double> values;
  final double? maxValue;
  final double? height;
  final double? width;
  final double? barHeight;
  final Widget? headerWidget;
  final Color? barColor;
  final List<Color>? barColors;
  final Color? backgroundColor;
  final bool lightMode;

  const CustomHorizontalBarChartWidget({
    Key? key,
    required this.title,
    required this.labels,
    required this.values,
    this.maxValue,
    this.height,
    this.width,
    this.barHeight,
    this.iconAsset,
    this.headerWidget,
    this.barColor,
    this.barColors,
    this.backgroundColor,
    required this.lightMode,
  }) : super(key: key);

  Map<String, double> _calculateAxisParams() {
    if (values.isEmpty) {
      return {'maxValue': 100, 'interval': 25};
    }

    final dataMax = values.reduce((a, b) => a > b ? a : b);
    final calculatedMaxValue = maxValue ?? dataMax;

    double roundedMaxValue;
    if (calculatedMaxValue <= 10) {
      roundedMaxValue = (calculatedMaxValue / 2).ceil() * 2.0;
    } else if (calculatedMaxValue <= 20) {
      roundedMaxValue = (calculatedMaxValue / 4).ceil() * 4.0;
    } else if (calculatedMaxValue <= 40) {
      roundedMaxValue = (calculatedMaxValue / 8).ceil() * 8.0;
    } else if (calculatedMaxValue <= 100) {
      roundedMaxValue = (calculatedMaxValue / 20).ceil() * 20.0;
    } else if (calculatedMaxValue <= 200) {
      roundedMaxValue = (calculatedMaxValue / 40).ceil() * 40.0;
    } else if (calculatedMaxValue <= 400) {
      roundedMaxValue = (calculatedMaxValue / 80).ceil() * 80.0;
    } else if (calculatedMaxValue <= 500) {
      roundedMaxValue = (calculatedMaxValue / 100).ceil() * 100.0;
    } else if (calculatedMaxValue <= 1000) {
      roundedMaxValue = (calculatedMaxValue / 200).ceil() * 200.0;
    } else {
      roundedMaxValue = (calculatedMaxValue / 400).ceil() * 400.0;
    }

    double interval = roundedMaxValue / 4;

    // ✅ FIX (bug report p32): _generateAxisLabels renders each tick with
    // toInt(), which truncates. A fractional interval therefore produced
    // duplicate labels — a max of 1 rounded to 2, gave an interval of 0.5 and
    // an axis reading "0 0 1 1 2".
    //
    // Force a whole-number step and stretch the axis to 4 x that step so all
    // five ticks are distinct integers.
    if (interval < 1 || interval != interval.roundToDouble()) {
      interval = interval < 1 ? 1 : interval.ceilToDouble();
      roundedMaxValue = interval * 4;
    }

    return {'maxValue': roundedMaxValue, 'interval': interval};
  }

  List<String> _generateAxisLabels(double maxValue, double interval) {
    return [
      '0',
      interval.toInt().toString(),
      (interval * 2).toInt().toString(),
      (interval * 3).toInt().toString(),
      maxValue.toInt().toString(),
    ];
  }

  double _calculateRequiredHeight() {
    final calculatedBarHeight = barHeight ?? 20;

    // ✅ Check if there's no data
    final hasNoData = labels.isEmpty || values.isEmpty || values.every((v) => v == 0);

    if (hasNoData) {
      // Return a taller height for "No data" message display
      // Header + "No data" message area + padding
      final showHeader = title.isNotEmpty || iconAsset != null;
      final headerHeight = showHeader ? (26.sp + 12.sp) : 0.0;
      final noDataMessageHeight = 150.h; // Tall enough to center "No data" message nicely
      final padding = 32.sp;

      return (headerHeight + noDataMessageHeight + padding).clamp(200.h, 298.h);
    }

    // Normal calculation when data exists
    // Each item: bar height + spacing above bar + label height + bottom padding
    final itemHeight = calculatedBarHeight.sp + 6.sp + 18.sp + 12.sp;
    final contentHeight = labels.length * itemHeight;

    // Header: icon/title height + bottom spacing (only if title or icon exists)
    final showHeader = title.isNotEmpty || iconAsset != null;
    final headerHeight = showHeader ? (26.sp + 12.sp) : 0.0;

    // Bottom axis: text height + top spacing
    final axisHeight = 10.sp + 8.sp;

    // Container padding (top + bottom)
    final padding = 32.sp;

    final totalHeight = contentHeight + headerHeight + axisHeight + padding;

    // Return the smaller of calculated height or max height
    return totalHeight.clamp(0, 298.h);
  }

  @override
  Widget build(BuildContext context) {
    final defaultBarColor = barColor ?? AppColors.primary;
    final defaultBgColor = backgroundColor ??
        (lightMode ? AppColors.white : AppColors.chatBackground);

    final axisParams = _calculateAxisParams();
    final calculatedMaxValue = axisParams['maxValue']!;
    final interval = axisParams['interval']!;
    final axisLabels = _generateAxisLabels(calculatedMaxValue, interval);
    final calculatedBarHeight = barHeight ?? 20;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // Only show header if title or icon is provided
    final showHeader = title.isNotEmpty || iconAsset != null;

    return Stack(
      children: [
        Container(
          width: width?.w,
          height: 300.h,
          padding: EdgeInsets.all(15.sp), // Added padding back
          decoration: BoxDecoration(
            color: defaultBgColor,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 12.h),
              // Header - only show if needed
              if (showHeader)
                Row(
                  children: [
                    const Spacer(),
                    if (headerWidget != null) headerWidget!,
                  ],
                ),

              if (showHeader) SizedBox(height: 25.sp),

              // Horizontal Bars - Fixed overflow issue
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate if content needs scrolling
                    final itemHeight =
                        calculatedBarHeight.sp + 6.sp + 18.sp + 12.sp;
                    final totalContentHeight = labels.length * itemHeight;
                    final availableHeight = constraints.maxHeight;

                    if (totalContentHeight > availableHeight) {
                      // Content is too tall, make it scrollable
                      return SingleChildScrollView(
                        child: Column(
                          children: _buildBarList(
                            labels,
                            values,
                            calculatedMaxValue,
                            calculatedBarHeight,
                            defaultBarColor,
                          ),
                        ),
                      );
                    } else {
                      // Content fits, no scroll needed
                      return Column(
                        children: _buildBarList(
                          labels,
                          values,
                          calculatedMaxValue,
                          calculatedBarHeight,
                          defaultBarColor,
                        ),
                      );
                    }
                  },
                ),
              ),

              SizedBox(height: 8.sp),

              // Bottom Axis - Always 5 labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: axisLabels.map((label) {
                  return Text(
                      label,
                      style: StyleText.fontSize14Weight600.copyWith(
                          color: lightMode
                              ? AppColors.secondaryText
                              : AppColors.grey));
                }).toList(),
              ),
            ],
          ),
        ),
        // ✅ FIX: Positioned must be direct child of Stack, then Padding inside
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          child: Row(
            children: [
              if (iconAsset != null)
                Container(
                  width: 26.sp,
                  height: 26.sp,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: defaultBarColor,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      iconAsset!,
                      width: 16.sp,
                      height: 16.sp,
                      color: AppColors.textButton,
                    ),
                  ),
                ),
              if (iconAsset != null) SizedBox(width: 8.sp),
              if (title.isNotEmpty)
                Text(
                  title,
                  style: StyleText.fontSize14Weight600.copyWith(
                      color: lightMode
                          ? AppColors.blackButton
                          : AppColors.white),
                ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildBarList(
      List<String> labels,
      List<double> values,
      double calculatedMaxValue,
      double calculatedBarHeight,
      Color defaultBarColor,
      ) {
    return List.generate(labels.length, (index) {
      final label = labels[index];
      final value = values[index];
      final percent = (value / calculatedMaxValue).clamp(0.0, 1.0);
      final Color currentBarColor =
      (barColors != null && index < barColors!.length)
          ? barColors![index]
          : defaultBarColor;

      return Padding(
        padding: EdgeInsets.only(bottom: 12.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label & Value
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                    child: Text(label,
                        style: StyleText.fontSize14Weight400.copyWith(
                            color: lightMode
                                ? AppColors.secondaryText
                                : AppColors.grey))),
                SizedBox(width: 8.w),
                if (value > 0)
                  Text(value.toInt().toString(),
                      style: StyleText.fontSize12Weight500.copyWith(
                          color: lightMode
                              ? AppColors.secondaryText
                              : AppColors.grey)),
              ],
            ),

            SizedBox(height: 13.sp),

            // Progress Bar
            Stack(
              children: [
                Container(
                  height: calculatedBarHeight.sp,
                  decoration: BoxDecoration(
                    color: lightMode
                        ? const Color(0xFFF5F5FF)
                        : Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: percent,
                  child: Container(
                    height: calculatedBarHeight.sp,
                    decoration: BoxDecoration(
                      color: currentBarColor,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
