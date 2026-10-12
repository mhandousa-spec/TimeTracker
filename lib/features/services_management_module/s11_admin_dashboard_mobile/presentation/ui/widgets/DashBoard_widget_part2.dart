part of 'DashBoard_widget.dart';

// Split from DashBoard_widget.dart to keep files <700 LOC.

class _CustomVerticalBarChartWidgetState
    extends State<CustomVerticalBarChartWidget> {
  ScrollController? _scrollController;
  bool _didInitScroll = false;

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  double _getMaxY() {
    if (widget.values.isEmpty) return 10.0;
    if (widget.maxY != null) return widget.maxY!;
    double dataMax = 0.0;
    for (var value in widget.values) {
      if (value > dataMax) dataMax = value;
    }
    // ✅ NEW (bug report p9): the axis has to cover both series, otherwise a
    // tall secondary bar would overflow the plot.
    if (widget.hasSecondarySeries) {
      for (var value in widget.secondaryValues!) {
        if (value > dataMax) dataMax = value;
      }
    }
    if (dataMax == 0) return 10.0;
    int intMax = dataMax.ceil();
    int niceCeiling;
    if (intMax <= 5) {
      niceCeiling = 5;
    } else if (intMax <= 10) {
      niceCeiling = 10;
    } else if (intMax <= 20) {
      niceCeiling = 20;
    } else if (intMax <= 50) {
      niceCeiling = ((intMax / 10).ceil() * 10);
    } else if (intMax <= 100) {
      niceCeiling = ((intMax / 20).ceil() * 20);
    } else if (intMax <= 500) {
      niceCeiling = ((intMax / 50).ceil() * 50);
    } else {
      niceCeiling = ((intMax / 100).ceil() * 100);
    }
    return niceCeiling.toDouble();
  }

  double _getInterval(double maxY) {
    if (maxY <= 5) return 1.0;
    if (maxY <= 10) return 2.0;
    if (maxY <= 20) return 5.0;
    if (maxY <= 50) return 10.0;
    if (maxY <= 100) return 20.0;
    if (maxY <= 200) return 50.0;
    if (maxY <= 500) return 100.0;
    return (maxY / 5).ceilToDouble();
  }

  String _formatNumber(num number, bool isArabic) {
    int intNumber = number.toInt();
    if (isArabic) {
      final westernDigits = [
        '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'
      ];
      final arabicDigits = [
        '٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'
      ];
      String numStr = intNumber.toString();
      for (int i = 0; i < westernDigits.length; i++) {
        numStr = numStr.replaceAll(westernDigits[i], arabicDigits[i]);
      }
      return numStr;
    }
    return intNumber.toString();
  }

  String _getMonthName(int month, bool isArabic) {
    final englishMonths = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final arabicMonths = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    if (month >= 1 && month <= 12) {
      return isArabic ? arabicMonths[month - 1] : englishMonths[month - 1];
    }
    return '';
  }

  String _convertLabelToArabic(String label, bool isArabic) {
    if (!isArabic) return label;
    final englishMonths = [
      'jan', 'feb', 'mar', 'apr', 'may', 'jun',
      'jul', 'aug', 'sep', 'oct', 'nov', 'dec'
    ];
    final arabicMonths = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    String lowerLabel = label.toLowerCase().trim();
    for (int i = 0; i < englishMonths.length; i++) {
      if (lowerLabel == englishMonths[i] ||
          lowerLabel.startsWith(englishMonths[i])) {
        return arabicMonths[i];
      }
    }
    return label;
  }

  Map<String, dynamic> _prepareMonthlyData(bool isArabic) {
    // ✅ NEW (bug report p9): the secondary series is padded/reordered exactly
    // like the primary one so the two stay index-aligned. Stays null when no
    // second series was supplied.
    if (!widget.showAllMonths) {
      List<String> processedLabels = widget.labels
          .map((l) => _convertLabelToArabic(l, isArabic))
          .toList();
      return {
        'labels': processedLabels,
        'values': List<double>.from(widget.values),
        'secondaryValues': widget.hasSecondarySeries
            ? List<double>.from(widget.secondaryValues!)
            : null,
      };
    }

    Map<String, double> dataMap = {};
    Map<String, double> secondaryMap = {};
    for (int i = 0; i < widget.labels.length; i++) {
      final key = widget.labels[i].toLowerCase();
      dataMap[key] = widget.values[i];
      if (widget.hasSecondarySeries && i < widget.secondaryValues!.length) {
        secondaryMap[key] = widget.secondaryValues![i];
      }
    }

    List<String> allLabels = [];
    List<double> allValues = [];
    List<double> allSecondaryValues = [];

    for (int month = 1; month <= 12; month++) {
      allLabels.add(_getMonthName(month, isArabic));
      final monthKey = _getMonthName(month, false).toLowerCase();
      allValues.add(dataMap[monthKey] ?? 0);
      allSecondaryValues.add(secondaryMap[monthKey] ?? 0);
    }

    return {
      'labels': allLabels,
      'values': allValues,
      'secondaryValues': widget.hasSecondarySeries ? allSecondaryValues : null,
    };
  }

  /// The colour of every piece of text that ANNOTATES the plot rather than
  /// carrying a value: the left axis numbers, the month labels under the bars,
  /// and the legend keys.
  ///
  /// ADDED 30/8/2026. The axis numbers were `Colors.grey` while the month
  /// labels and the legend were `AppColors.text` — full-strength body colour,
  /// which is white in dark mode. Three labels around one plot, at two
  /// different weights, with the month row shouting louder than the data. They
  /// share this now.
  ///
  /// [AppColors.colorGrey] is `0xFF9E9E9E` — the same value `Colors.grey`
  /// resolved to, so the axis numbers do not change; it is the palette's own
  /// name for that neutral, and theme-unaware on purpose (the annotation grey
  /// reads against both the light and the dark card).
  ///
  /// Tooltips are deliberately NOT in this group: a tooltip is a VALUE, and it
  /// keeps `AppColors.text`.
  Color get _plotLabelColor => AppColors.colorGrey;

  /// Legend shown above the plot, only when a second series is present.
  ///
  /// ✅ Built inside a collection-if at the call site, so in single-series mode
  /// this widget is never constructed and reserves no height at all.
  Widget _buildLegend(Color primaryColor, Color secondaryColor) {
    Widget entry(Color color, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.sp,
              height: 10.sp,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 6.sp),
            Text(
              label,
              style: StyleText.fontSize12Weight500
                  .copyWith(color: _plotLabelColor),
            ),
          ],
        );

    return Row(
      children: [
        if ((widget.legendLabel ?? '').isNotEmpty)
          entry(primaryColor, widget.legendLabel!),
        if ((widget.legendLabel ?? '').isNotEmpty &&
            (widget.secondaryLegendLabel ?? '').isNotEmpty)
          SizedBox(width: 16.sp),
        if ((widget.secondaryLegendLabel ?? '').isNotEmpty)
          entry(secondaryColor, widget.secondaryLegendLabel!),
      ],
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    final defaultBarColor = widget.barColor ?? AppColors.primary;
    final defaultIconBgColor = widget.iconBackgroundColor ?? AppColors.primary;
    final defaultBgColor = widget.backgroundColor ?? AppColors.card;

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final preparedData = _prepareMonthlyData(isArabic);
    final displayLabels = preparedData['labels'] as List<String>;
    final displayValues = preparedData['values'] as List<double>;
    final displaySecondaryValues =
        preparedData['secondaryValues'] as List<double>?;
    final secondaryColor = widget.secondaryBarColor ?? AppColors.red;

    final double rawMaxY = _getMaxY();
    final calculatedBarWidth = widget.barWidth ?? 30;
    final interval = _getInterval(rawMaxY);
    // 1/10/2026: the top of the axis is always a whole number of intervals
    // (e.g. 250 with a step of 100 becomes 300), so the top grid line, the top
    // number and maxY are the same height — QA p.35-45.
    final double calculatedMaxY =
        (rawMaxY / interval).ceilToDouble() * interval;

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final itemCount = displayLabels.length;

    // ── When the plot scrolls (10/9/2026) ──────────────────────────────────
    //
    // Was `(itemCount * 70) > screenWidth - 30`, which on a 402-wide phone let
    // FIVE columns share the plot before it would scroll — "Services Offered"
    // drew five bars whose labels ("Leave Request Processing", "Training
    // Development Enrollment") shrank to an unreadable smear.
    //
    // A phone now shows at most [_kMobileVisibleBars] and scrolls past that.
    // Desktop keeps its original rule: it has the width, and the tablet and
    // desktop layouts are deliberately untouched.
    final double availableWidth = screenWidth - 30.sp;
    final double minWidthPerItem = 70.0;
    final shouldScroll = isMobile
        ? itemCount > _kMobileVisibleBars
        : (itemCount * minWidthPerItem) > availableWidth;

    // Width of the fixed value-axis strip.
    //
    // CHANGED 10/9/2026 on the phone branch, from 28. The numbers are drawn at
    // 9pt, so 28 was roughly double what they need and the plot started a
    // visible step in from the card's own 15 padding. [_kMobileAxisWidth] fits
    // a two-digit label and the gap after it, and nothing else sits between the
    // card edge and the plot. Desktop's 13.w is unchanged.
    //
    // FIXED 29/9/2026 (bug report p.28): on desktop a fixed 13.w strip only
    // fits two digits, so Total Hours' "150" / "100" wrapped onto two lines
    // ("15" over "0"). The strip is now at least as wide as its widest label.
    final double desktopAxisWidth = () {
      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: _formatNumber(calculatedMaxY.toInt(), isArabic),
          style: TextStyle(fontSize: 11.sp),
        ),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();
      final double needed = tp.width + 6.sp;
      return needed > 13.w ? needed : 13.w;
    }();
    // FIXED 1/10/2026 (Services mobile QA p.44): the phone kept the fixed
    // 14pt strip, so Total Hours' "150" / "100" still wrapped to "15" over
    // "0" there. The phone strip now also grows to its widest label.
    final double mobileAxisWidth = () {
      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: _formatNumber(calculatedMaxY.toInt(), isArabic),
          style: _axisLabelStyle(true),
        ),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();
      final double needed = tp.width + 5;
      return needed > _kMobileAxisWidth ? needed : _kMobileAxisWidth;
    }();
    final double axisReservedSize =
        isMobile ? mobileAxisWidth : desktopAxisWidth;

    if (shouldScroll) {
      _scrollController ??= ScrollController();
      if (isArabic && !_didInitScroll) {
        _didInitScroll = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController!.hasClients) {
            _scrollController!.jumpTo(
              _scrollController!.position.maxScrollExtent,
            );
          }
        });
      }
    }

    return Container(
      width: widget.width?.w,
      height: widget.height?.h,
      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(
        color: defaultBgColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row: Icon + Title (+ toggle on tablet) ──
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (widget.iconAsset != null)
                Container(
                  width: 26.sp,
                  height: 26.sp,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: defaultIconBgColor,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      widget.iconAsset!,
                      width: 16.sp,
                      height: 16.sp,
                      color: AppColors.textButton,
                    ),
                  ),
                ),
              if (widget.iconAsset != null) SizedBox(width: 8.sp),
              Expanded(
                child: Text(
                  widget.title,
                  style: StyleText.fontSize14Weight600
                      .copyWith(color: AppColors.text),
                ),
              ),
              // ✅ Show toggle inline on tablet/desktop only
              if (!isMobile && widget.headerWidget != null)
                widget.headerWidget!,
            ],
          ),

          // ── Legend (second series only) ────────────────
          // ✅ Collection-if: in single-series mode neither the legend nor its
          // spacer is created, so the layout is byte-for-byte what it was.
          //
          // MOVED 1/10/2026 (Services mobile QA p.43): the legend now sits
          // straight under the title, above the header control (Monthly
          // Comparison's Department picker), so it reads as the chart's key
          // rather than as a caption of the dropdown.
          if (displaySecondaryValues != null) ...[
            SizedBox(height: 12.sp),
            _buildLegend(defaultBarColor, secondaryColor),
          ],

          // ✅ Show toggle on separate row for mobile only.
          //
          // CHANGED 1/10/2026 (QA p.43): an Align instead of an end-aligned
          // Row, so a header control that asks for the full width (the
          // Department picker) can take it; a toggle that sizes itself still
          // sits at the end as before.
          if (isMobile && widget.headerWidget != null) ...[
            SizedBox(height: 12.sp),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: widget.headerWidget!,
            ),
          ],

          SizedBox(height: 20.sp),

          // ── Chart + Labels ─────────────────────────────
          Expanded(
            child: shouldScroll
                ? _buildScrollableContent(
              context,
              displayLabels,
              displayValues,
              calculatedMaxY,
              calculatedBarWidth,
              interval,
              isArabic,
              defaultBarColor,
              isMobile: isMobile,
              axisReservedSize: axisReservedSize,
              secondaryValues: displaySecondaryValues,
              secondaryColor: secondaryColor,
            )
                : _buildStaticContent(
              context,
              displayLabels,
              displayValues,
              calculatedMaxY,
              calculatedBarWidth,
              interval,
              isArabic,
              defaultBarColor,
              isMobile: isMobile,
              axisReservedSize: axisReservedSize,
              secondaryValues: displaySecondaryValues,
              secondaryColor: secondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableContent(
      BuildContext context,
      List<String> displayLabels,
      List<double> displayValues,
      double calculatedMaxY,
      double calculatedBarWidth,
      double interval,
      bool isArabic,
      Color defaultBarColor, {
        required bool isMobile,
        required double axisReservedSize,
        List<double>? secondaryValues,
        Color? secondaryColor,
      }) {
    // The column width is measured by the LayoutBuilder below rather than
    // passed in, so the auto-scroll that depends on it moved in there too.
    return Row(
      // Physical order, independent of the ambient Directionality: the value
      // axis is drawn first (left) in English and last (right) in Arabic, so
      // the whole plot mirrors with the language instead of always sitting
      // against the left edge.
      textDirection: TextDirection.ltr,
      children: [
        if (!isArabic)
          SizedBox(
            width: axisReservedSize,
            // Inset by the label row — see [_kLabelRowHeight]. Without it the
            // numbers span a taller box than the plot and slide downward.
            //
            // PHONE ONLY. The same misalignment is there on desktop whenever
            // this scrolling layout is used, but desktop is not to change, so
            // it keeps its existing spacing untouched.
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isMobile ? _kLabelRowHeight : 0,
              ),
              child: _buildLeftAxisLabels(
                  calculatedMaxY, interval, isMobile, isArabic),
            ),
          ),
        Expanded(
          // LayoutBuilder, not a pinned 80: a column has to be a third of the
          // PLOT on a phone, and the plot is what is left after the page
          // padding, the card padding and the axis strip. Only this box knows
          // that — a number derived from the screen width is a guess that
          // drifts with every phone size. Desktop keeps the fixed 80.
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          final double itemWidth = isMobile
              ? constraints.maxWidth / _kMobileVisibleBars
              : 80.0;
          final double scrollContentWidth = displayValues.length * itemWidth;

          // ✅ Open on the first bar that actually has a value. It lives in the
          // builder because it needs the measured column width.
          //
          // Centring on the PLOT width rather than the screen is more correct —
          // the screen is wider than the scroll view by the page padding, the
          // card padding and the axis strip — but that is a phone-only change:
          // desktop keeps the screen-width maths it has always used.
          final int firstNonZeroIndex =
              displayValues.indexWhere((double v) => v > 0);
          if (firstNonZeroIndex > 0 && _scrollController != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController!.hasClients) {
                final double centreOn = isMobile
                    ? constraints.maxWidth
                    : MediaQuery.of(context).size.width;
                double targetOffset = (firstNonZeroIndex * itemWidth) -
                    (centreOn / 2) +
                    (itemWidth / 2);
                targetOffset = targetOffset.clamp(
                  0.0,
                  _scrollController!.position.maxScrollExtent,
                );
                _scrollController!.animateTo(
                  targetOffset,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            });
          }

          return SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            reverse: false,
            physics: const ClampingScrollPhysics(),
            child: SizedBox(
              width: scrollContentWidth,
              child: Column(
                children: [
                  // ✅ Chart area — each bar centered in its itemWidth slot,
                  // over one grid layer spanning the whole plot (QA p.35-45:
                  // the per-slot fl_chart grid skipped the top line).
                  Expanded(
                    child: Stack(
                      children: [
                        if (widget.showGrid)
                          Positioned.fill(
                            child: _buildGridOnly(
                              maxY: calculatedMaxY,
                              interval: interval,
                            ),
                          ),
                        Row(
                      children: List.generate(displayValues.length, (index) {
                        return SizedBox(
                          width: itemWidth,
                          child: _buildSingleBarChart(
                            value: displayValues[index],
                            maxY: calculatedMaxY,
                            interval: interval,
                            isArabic: isArabic,
                            barColor: defaultBarColor,
                            barWidth: isMobile ? 20.0 : 24.0,
                            // Grid is the shared layer under the Row now.
                            showGrid: false,
                            secondValue: (secondaryValues != null &&
                                    index < secondaryValues.length)
                                ? secondaryValues[index]
                                : null,
                            secondBarColor: secondaryColor,
                          ),
                        );
                      }),
                        ),
                      ],
                    ),
                  ),
                  // ✅ Labels — each centered in same itemWidth slot
                  SizedBox(
                    height: _kLabelRowHeight,
                    child: Row(
                      children: displayLabels.map((label) {
                        return SizedBox(
                          width: itemWidth,
                          child: _categoryLabel(label, isMobile),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
            },
          ),
        ),
        if (isArabic)
          SizedBox(
            width: axisReservedSize,
            // Same phone-only inset as the English strip above.
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isMobile ? _kLabelRowHeight : 0,
              ),
              child: _buildLeftAxisLabels(
                  calculatedMaxY, interval, isMobile, isArabic),
            ),
          ),
      ],
    );
  }

  /// ✅ NEW: Single bar chart per slot — ensures bar is perfectly centered under label
  Widget _buildSingleBarChart({
    required double value,
    required double maxY,
    required double interval,
    required bool isArabic,
    required Color barColor,
    required double barWidth,
    required bool showGrid,
    // ✅ NEW (bug report p9): when non-null a second rod is drawn beside the
    // first in the same slot. Null keeps the original single-rod output.
    double? secondValue,
    Color? secondBarColor,
  }) {
    final hasSecond = secondValue != null;
    // Two rods have to share the slot, so narrow them rather than overflow it.
    final effectiveBarWidth = hasSecond ? barWidth * 0.55 : barWidth;
    return BarChart(
      BarChartData(
        maxY: maxY,
        minY: 0,
        alignment: BarChartAlignment.center,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: showGrid,
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (v) => FlLine(
            color: widget.lightMode
                ? const Color(0xffEFF3F9)
                : Colors.grey.shade800,
            strokeWidth: 1,
          ),
        ),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipPadding: EdgeInsets.zero,
            tooltipMargin: 6.sp,
            getTooltipColor: (_) => Colors.transparent,
            tooltipBorder: BorderSide.none,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              if (rod.toY > 0) {
                return BarTooltipItem(
                  _formatNumber(rod.toY.toInt(), isArabic),
                  StyleText.fontSize12Weight500.copyWith(color: AppColors.text),
                );
              }
              return null;
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barsSpace: hasSecond ? 4.sp : 0,
            barRods: [
              BarChartRodData(
                toY: value,
                // FIXED 1/10/2026 (Services mobile QA p.43, "same column
                // style"): this was a hard-coded 22 while the second rod used
                // [effectiveBarWidth], so Monthly Comparison drew a wide
                // Canceled bar next to a thin Rejected one. Both rods now share
                // the width.
                width: effectiveBarWidth,
                borderRadius: BorderRadius.circular(4.r),
                color: barColor,
              ),
              if (hasSecond)
                BarChartRodData(
                  toY: secondValue,
                  width: effectiveBarWidth,
                  borderRadius: BorderRadius.circular(4.r),
                  color: secondBarColor ?? AppColors.red,
                ),
            ],
            showingTooltipIndicators: [
              if (value > 0) 0,
              if (hasSecond && secondValue > 0) 1,
            ],
          ),
        ],
      ),
    );
  }

  // ✅ FIXED: Static content now uses the SAME Row layout as scrollable
  // Y-axis labels are OUTSIDE the chart — no internal reservedSize padding
  Widget _buildStaticContent(
      BuildContext context,
      List<String> displayLabels,
      List<double> displayValues,
      double calculatedMaxY,
      double calculatedBarWidth,
      double interval,
      bool isArabic,
      Color defaultBarColor, {
        required bool isMobile,
        required double axisReservedSize,
        List<double>? secondaryValues,
        Color? secondaryColor,
      }) {
    return Column(
      children: [
        Expanded(
          child: Row(
            // Physical order: value axis on the left in English, on the right
            // in Arabic (see _buildScrollableContent).
            textDirection: TextDirection.ltr,
            children: [
              // ✅ Y-axis labels
              if (!isArabic)
                SizedBox(
                  width: axisReservedSize,
                  child: _buildLeftAxisLabels(
                      calculatedMaxY, interval, isMobile, isArabic),
                ),

              // ✅ Chart area with grid as background layer
              // In _buildStaticContent, change the Stack to:
              Expanded(
                child: Stack(
                  children: [
                    // Layer 1: Full-width grid lines — ONLY if showGrid is true
                    if (widget.showGrid)
                      Positioned.fill(
                        child: _buildGridOnly(
                          maxY: calculatedMaxY,
                          interval: interval,
                        ),
                      ),
                    // Layer 2: Bars
                    Row(
                      children: List.generate(displayValues.length, (index) {
                        return Expanded(
                          child: _buildSingleBarChart(
                            value: displayValues[index],
                            maxY: calculatedMaxY,
                            interval: interval,
                            isArabic: isArabic,
                            barColor: defaultBarColor,
                            barWidth: isMobile ? 20.0 : calculatedBarWidth,
                            // Grid is drawn once as a full-width backdrop layer
                            // in the Stack above, so each bar skips its own.
                            showGrid: false,
                            secondValue: (secondaryValues != null &&
                                    index < secondaryValues.length)
                                ? secondaryValues[index]
                                : null,
                            secondBarColor: secondaryColor,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              if (isArabic)
                SizedBox(
                  width: axisReservedSize,
                  child: _buildLeftAxisLabels(
                      calculatedMaxY, interval, isMobile, isArabic),
                ),
            ],
          ),
        ),
        // Labels row — inset on the same physical side the axis strip
        // occupies, so each label stays centred under its own bar.
        Padding(
          padding: EdgeInsets.only(
            left: isArabic ? 0 : axisReservedSize,
            right: isArabic ? axisReservedSize : 0,
          ),
          child: SizedBox(
            // Same constant the scrolling layout insets its axis by, so the
            // two layouts cannot drift apart.
            height: _kLabelRowHeight,
            child: Row(
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              children: displayLabels.map((label) {
                return Expanded(
                  child: _categoryLabel(label, isMobile),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  /// Horizontal grid lines spanning the full plot width.
  ///
  /// CHANGED 1/10/2026 (Services mobile QA p.35, p.36, p.37, p.42, p.45):
  /// was an empty fl_chart BarChart, and fl_chart does not draw a grid line
  /// at maxY — so the top value on the axis ("20", "5", "8") floated in empty
  /// space with no line beside it. The lines are painted here instead, one
  /// per interval from the first step up to and including maxY, at exactly
  /// the heights [_buildLeftAxisLabels] centres its numbers on.
  Widget _buildGridOnly({
    required double maxY,
    required double interval,
  }) {
    return CustomPaint(
      painter: _PlotGridPainter(
        maxY: maxY,
        interval: interval,
        color: widget.lightMode
            ? const Color(0xffEFF3F9)
            : Colors.grey.shade800,
      ),
    );
  }

  /// One category label under the plot.
  ///
  /// CHANGED 1/10/2026 (Services mobile QA p.35 / p.36, "same font size and
  /// not bold"): each label sat in a FittedBox, so a long name ("Information
  /// Technology", "Business Continuity Plan Review") was shrunk to a smaller
  /// size than a short one next to it, and the style set no weight, so the
  /// row inherited the theme's bold. Every label is now the same size and
  /// regular weight; a long one wraps to a second line and is ellipsised
  /// after that instead of shrinking.
  Widget _categoryLabel(String label, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: isMobile ? 10.sp : 12.sp,
            fontWeight: FontWeight.w400,
            height: 1.15,
            color: _plotLabelColor,
          ),
        ),
      ),
    );
  }

  TextStyle _axisLabelStyle(bool isMobile) => TextStyle(
        fontSize: isMobile ? 9 : 11.sp,
        fontWeight: FontWeight.w400,
        height: 1.0,
        // Was the raw `Colors.grey`; [_plotLabelColor] is the same value
        // under the palette's own name, shared with the category labels and
        // the legend.
        color: _plotLabelColor,
      );

  /// How many bars a phone shows at once before the plot starts scrolling.
  ///
  /// ADDED 10/9/2026. Three columns share the plot width whatever the phone
  /// is, so a category label has room to be read, and anything past the third
  /// is a swipe away rather than crushed in beside it.
  static const int _kMobileVisibleBars = 3;

  /// Height of the category-label row under the plot.
  ///
  /// ADDED 11/9/2026. The scrolling layout is a Row of [axis strip | scroll
  /// view], and the scroll view stacks the plot ABOVE this label row. So the
  /// axis strip was as tall as plot + labels while the plot it annotates was
  /// only as tall as the plot — the numbers spread over the taller box, and
  /// `0` came to rest a whole label row BELOW the baseline it marks, with
  /// every number above it out by the same amount.
  ///
  /// The strip is inset by this at the bottom so the two spans match. The
  /// static layout never had the bug: there the labels are a sibling BELOW the
  /// row that holds the axis, not inside it.
  static double get _kLabelRowHeight => 28.sp;

  /// Width of the fixed value-axis strip on a phone — see where it is used.
  ///
  /// CHANGED 11/9/2026 to 14, HALF the original 28, as asked. The numbers are
  /// drawn at 9pt, so two digits and the gap after them fit inside it; 28 was
  /// reserving a second column's worth of nothing to the left of the plot.
  static const double _kMobileAxisWidth = 14.0;

  /// The value axis.
  ///
  /// CHANGED 1/10/2026 (Services mobile QA p.35-p.45, "make the values align
  /// with the grey line"): the numbers were a Column with spaceBetween, which
  /// puts the TOP of the first number at the top of the plot and the BOTTOM
  /// of the last at its base — so every number sat up to half a line off the
  /// grid line it labels (the top one below its line, "0" above the base).
  /// Each number is now centred vertically on the exact height of its line:
  /// y = h × (1 − v / maxY), the same mapping [_PlotGridPainter] and fl_chart
  /// use. The top and bottom numbers overhang the plot by half a line, which
  /// is what centring on the line means.
  Widget _buildLeftAxisLabels(
      double maxY, double interval, bool isMobile, bool isArabic) {
    final List<double> values = [];
    double value = maxY;
    while (value >= -0.0001) {
      values.add(value < 0 ? 0 : value);
      value -= interval;
    }
    final TextStyle style = _axisLabelStyle(isMobile);
    final double lineHeight = (style.fontSize ?? 11) * 1.2;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double h = constraints.maxHeight;
        return Stack(
          clipBehavior: Clip.none,
          children: values.map((v) {
            final double y = maxY <= 0 ? h : h * (1 - v / maxY);
            return Positioned(
              top: y - lineHeight / 2,
              height: lineHeight,
              // Physical alignment: the numbers hug the edge that faces the
              // plot — right in English, left in Arabic.
              left: 0,
              right: 0,
              child: Align(
                alignment: isArabic
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Text(
                  _formatNumber(v.round(), isArabic),
                  maxLines: 1,
                  softWrap: false,
                  style: style,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildBarChartOnly(
      BuildContext context,
      List<double> displayValues,
      double calculatedMaxY,
      double calculatedBarWidth,
      double interval,
      bool isArabic,
      Color defaultBarColor, {
        required bool isMobile,
        required bool shouldScroll,
      }) {
    final double effectiveBarWidth =
    shouldScroll ? 24 : (isMobile ? 20 : calculatedBarWidth.sp);
    final double effectiveGroupsSpace =
    shouldScroll ? 5 : (isMobile ? 8 : widget.groupsSpace.sp);

    return BarChart(
      BarChartData(
        maxY: calculatedMaxY,
        minY: 0,
        alignment: BarChartAlignment.spaceEvenly,
        groupsSpace: effectiveGroupsSpace,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: widget.showGrid,
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (value) => FlLine(
            color: widget.lightMode
                ? const Color(0xffEFF3F9)
                : Colors.grey.shade800,
            strokeWidth: 1,
          ),
        ),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipPadding: EdgeInsets.zero,
            tooltipMargin: 6.sp,
            getTooltipColor: (_) => Colors.transparent,
            tooltipBorder: BorderSide.none,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              if (rod.toY > 0) {
                return BarTooltipItem(
                  _formatNumber(rod.toY.toInt(), isArabic),
                  StyleText.fontSize12Weight500
                      .copyWith(color: AppColors.text),
                );
              }
              return null;
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles:
          AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
          AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
          AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles:
          AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: List.generate(displayValues.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: displayValues[index],
                width: effectiveBarWidth,
                borderRadius: BorderRadius.circular(4.r),
                color: defaultBarColor,
              ),
            ],
            showingTooltipIndicators:
            displayValues[index] > 0 ? [0] : [],
          );
        }),
      ),
    );
  }
}





// ============================================
// 2. HORIZONTAL BAR CHART WIDGET
// ============================================


/// Paints the plot's horizontal grid: one line per [interval], from the first
/// step above 0 up to and including [maxY]. No baseline at 0 (the bars stand
/// on it), matching the look the fl_chart grid had.
class _PlotGridPainter extends CustomPainter {
  _PlotGridPainter({
    required this.maxY,
    required this.interval,
    required this.color,
  });

  final double maxY;
  final double interval;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (maxY <= 0 || interval <= 0) return;
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (double v = interval; v <= maxY + 0.0001; v += interval) {
      final double y = size.height * (1 - v / maxY);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_PlotGridPainter old) =>
      old.maxY != maxY || old.interval != interval || old.color != color;
}
