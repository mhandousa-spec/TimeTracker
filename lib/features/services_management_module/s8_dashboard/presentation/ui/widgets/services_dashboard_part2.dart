part of 'services_dashboard.dart';

// Split from services_dashboard.dart to keep files <700 LOC.

class _MonthlyComparisonServicesChartState extends State<MonthlyComparisonServicesChart> {
  /// The colour of every piece of text that ANNOTATES the plot rather than
  /// carrying a value: the axis numbers, the month labels under the bars, and
  /// the two legend keys.
  ///
  /// ADDED 30/8/2026. The axis numbers were already `AppColors.grey`, while the
  /// month row was `AppColors.text` and the legend was
  /// `lightMode ? blackButton : white` — three labels around one plot at three
  /// different strengths, with the month row reading louder than the bars it
  /// labels. They share this now.
  ///
  /// Tooltips are deliberately NOT in this group: a tooltip is a VALUE and
  /// keeps its full-contrast colour.
  //
  // CHANGED 1/10/2026 (Services mobile QA p.39, "Branding"): was
  // AppColors.grey (#D9D9D9), which left the axis numbers, month names and
  // legend barely visible on the white card. colorGrey (#9E9E9E) is the value
  // the other dashboard charts (CustomVerticalBarChartWidget) use.
  Color get _plotLabelColor => AppColors.colorGrey;

  /// How many bars a phone shows at once before the plot starts scrolling.
  ///
  /// ADDED 10/9/2026. Twelve months were laid out at a fixed 60 each, so a
  /// phone showed five or six columns of unreadable labels at a time. Three
  /// columns share the plot width whatever the phone is, so a month label has
  /// room to be read, and the rest are a swipe away.
  static const int _kMobileVisibleBars = 3;

  /// Width of the fixed value-axis strip on a phone.
  ///
  /// CHANGED 11/9/2026 to 14, HALF the original 28, as asked. The numbers are
  /// drawn at 10, so two digits and the gap after them fit inside it; 28 was
  /// reserving a second column's worth of nothing to the left of the plot.
  static const double _kMobileAxisWidth = 14.0;

  bool _isLoading = true;
  String? _selectedServiceName;

  // Map to store monthly data: month (1-12) -> {canceled: count, rejected: count}
  Map<int, Map<String, int>> _monthlyData = {};

  // All services available (both English and Arabic)
  List<String> _allServicesEnglish = [];
  List<String> _allServicesArabic = [];

  late final MainCoreDepartmentCubit _departmentController;

  // This widget is embedded from two unrelated subtrees (s8 dashboard under
  // ServicesManagerCubit, and s11 mobile dashboard under DashboardMasterCubit)
  // with no common Bloc ancestor to source a repository from, so the cubit
  // owns its own repository instance here — matching the existing pattern in
  // DashboardMasterCubit (s11) and RequestStatisticsCubit (s9).
  late final ServicesDashboardCubit _dashboardCubit;

  @override
  void initState() {
    super.initState();
    _departmentController = context.read<MainCoreDepartmentCubit>();
    _dashboardCubit = ServicesDashboardCubit(
      repository: GetServiceRepositoryImpl(firestore: FirebaseFirestore.instance),
    );
    // Don't load data here - wait for didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      // Only load once when first mounted
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final employeeController = AppControllers.employee;
    final userDepartmentId = employeeController.employeeEntity?.departmentId;

    String? userDepartmentName;
    if (userDepartmentId != null) {
      userDepartmentName = _departmentController.getDepartmentName(userDepartmentId, true);
    }

    await _dashboardCubit.loadData(
      departmentController: _departmentController,
      employeeController: employeeController,
      userDepartmentName: userDepartmentName,
      selectedServiceName: _selectedServiceName,
    );

    final state = _dashboardCubit.state;
    if (state is ServicesDashboardLoaded && mounted) {
      setState(() {
        _monthlyData = state.data.monthlyData;
        _allServicesEnglish = state.data.allServicesEnglish;
        _allServicesArabic = state.data.allServicesArabic;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
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

  String _formatNumber(num number, bool isArabic) {
    int intNumber = number.toInt();

    if (isArabic) {
      final westernDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
      final arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

      String numStr = intNumber.toString();
      for (int i = 0; i < westernDigits.length; i++) {
        numStr = numStr.replaceAll(westernDigits[i], arabicDigits[i]);
      }
      return numStr;
    }
    return intNumber.toString();
  }

  double _getMaxY() {
    if (_monthlyData.isEmpty) return 10.0;

    double maxValue = 0;
    for (var monthData in _monthlyData.values) {
      final canceled = monthData['canceled'] ?? 0;
      final rejected = monthData['rejected'] ?? 0;
      // 1/10/2026 (QA p.39, same fix as P-27 on the admin chart): the two
      // bars stand side by side, not stacked, so the axis follows the
      // TALLER bar — adding them made the scale about twice too high.
      final tallest = canceled > rejected ? canceled : rejected;
      if (tallest > maxValue) maxValue = tallest.toDouble();
    }

    if (maxValue == 0) return 10.0;

    int intMax = maxValue.ceil();
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

    // Round up to a whole number of grid steps (250 with a step of 100 → 300)
    // so the top number and the top grid line coincide.
    final double step = _getInterval(niceCeiling.toDouble());
    return (niceCeiling / step).ceilToDouble() * step;
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

  List<BarChartGroupData> _buildBarGroups(bool isArabic) {
    List<BarChartGroupData> groups = [];

    for (int i = 0; i < 12; i++) {
      // ✅ FIXED: Reverse data order for Arabic
      int month;
      if (isArabic) {
        // Arabic: Display Dec (12) → Jan (1) from right to left
        month = 12 - i;
      } else {
        // English: Display Jan (1) → Dec (12) from left to right
        month = i + 1;
      }

      final monthData = _monthlyData[month] ?? {'canceled': 0, 'rejected': 0};
      final canceled = (monthData['canceled'] ?? 0).toDouble();
      final rejected = (monthData['rejected'] ?? 0).toDouble();

      groups.add(
        BarChartGroupData(
          x: i, // Keep x as 0-11 for positioning
          barsSpace: 4.sp,
          barRods: [
            BarChartRodData(
              toY: canceled,
              width: 12.sp,
              color: AppColors.pending, // Red for canceled
              borderRadius: BorderRadius.circular(4.r),
            ),
            BarChartRodData(
              toY: rejected,
              width: 12.sp,
              color: AppColors.block, // Dark red for rejected
              borderRadius: BorderRadius.circular(4.r),
            ),
          ],
          showingTooltipIndicators: [0, 1],
        ),
      );
    }

    return groups;
  }

  Widget _buildVerticalChart(BuildContext context, bool isArabic) {
    final maxY = _getMaxY();
    final interval = _getInterval(maxY);

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    if (!isMobile) {
      // ✅ TABLET/DESKTOP: No scroll — everything fits on screen
      return BarChart(
        BarChartData(
          maxY: maxY,
          minY: 0,
          alignment: BarChartAlignment.spaceEvenly,
          groupsSpace: 8.sp,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: interval,
            getDrawingHorizontalLine: (value) => FlLine(
              color: widget.lightMode
                  ? AppColors.background
                  : AppColors.darkGrey,
              strokeWidth: 1,
            ),
          ),
          barTouchData: BarTouchData(
            enabled: true,
            // The value labels are ALWAYS shown (showingTooltipIndicators). With
            // built-in touches on, tapping one bar replaced them with just the
            // touched rod's label, so the other bar's number vanished (bug p24).
            handleBuiltInTouches: false,
            touchTooltipData: BarTouchTooltipData(
              tooltipPadding: EdgeInsets.zero,
              tooltipMargin: 8.sp,
              getTooltipColor: (_) => AppColors.transparent,
              tooltipBorder: BorderSide.none,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                if (rod.toY > 0) {
                  return BarTooltipItem(
                    _formatNumber(rod.toY.toInt(), isArabic),
                    StyleText.fontSize10Weight400.copyWith(
                      color: widget.lightMode
                          ? AppColors.blackButton
                          : AppColors.white,
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: !isArabic,
                reservedSize: 28,
                interval: interval,
                getTitlesWidget: (value, _) {
                  if (value % interval == 0) {
                    return Text(
                      _formatNumber(value.toInt(), isArabic),
                      style: StyleText.fontSize14Weight400.copyWith(
                        fontSize: 11.sp,
                        color: _plotLabelColor,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: isArabic,
                reservedSize: 28,
                interval: interval,
                getTitlesWidget: (value, _) {
                  if (value % interval == 0) {
                    return Text(
                      _formatNumber(value.toInt(), isArabic),
                      style: StyleText.fontSize14Weight400.copyWith(
                        fontSize: 11.sp,
                        color: _plotLabelColor,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                reservedSize: 28,
                showTitles: true,
                getTitlesWidget: (value, _) {
                  int month = isArabic ? 12 - value.toInt() : value.toInt() + 1;
                  if (month >= 1 && month <= 12) {
                    return FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: EdgeInsets.only(top: 3.sp),
                        child: Text(
                          _getMonthName(month, isArabic),
                          style: StyleText.fontSize12Weight500.copyWith(
                            // See [_plotLabelColor]: the month row annotates
                            // the plot, it does not carry a value.
                            color: _plotLabelColor,
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          barGroups: _buildBarGroups(isArabic),
        ),
      );
    }

    // ✅ MOBILE: Fixed Y-axis + scrollable chart
    const double axisReservedSize = _kMobileAxisWidth;

    return Row(
      children: [
        // ✅ Fixed Y-axis — does NOT scroll
        if (!isArabic)
          SizedBox(
            width: axisReservedSize,
            child: _buildYAxisLabels(maxY, interval, isArabic),
          ),

        // ✅ Scrollable chart area
        Expanded(
          // LayoutBuilder, not a number derived from `MediaQuery`: the column
          // width has to be a third of the PLOT, and the plot is what is left
          // after the page padding, the card padding and the axis strip. Only
          // this box knows that; computing it from the screen width would be a
          // guess that drifts on every phone size.
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          final double itemWidth =
              constraints.maxWidth / _kMobileVisibleBars;
          final double scrollContentWidth = 12 * itemWidth;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: isArabic,
            physics: const ClampingScrollPhysics(),
            child: SizedBox(
              width: scrollContentWidth,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  minY: 0,
                  alignment: BarChartAlignment.spaceEvenly,
                  groupsSpace: 12.sp,
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: interval,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: widget.lightMode
                          ? AppColors.background
                          : AppColors.darkGrey,
                      strokeWidth: 1,
                    ),
                  ),
                  // QA p.39 / p.42: fl_chart draws no grid line at maxY, so
                  // the top axis number sat in empty space. Add that line.
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      HorizontalLine(
                        y: maxY,
                        color: widget.lightMode
                            ? AppColors.background
                            : AppColors.darkGrey,
                        strokeWidth: 1,
                      ),
                    ],
                  ),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipPadding: EdgeInsets.zero,
                      tooltipMargin: 8.sp,
                      getTooltipColor: (_) => AppColors.transparent,
                      tooltipBorder: BorderSide.none,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        if (rod.toY > 0) {
                          return BarTooltipItem(
                            _formatNumber(rod.toY.toInt(), isArabic),
                            StyleText.fontSize10Weight400.copyWith(
                              color: widget.lightMode
                                  ? AppColors.blackButton
                                  : AppColors.white,
                            ),
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
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        reservedSize: 28,
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          int month = isArabic ? 12 - value.toInt() : value.toInt() + 1;
                          if (month >= 1 && month <= 12) {
                            return FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Padding(
                                padding: EdgeInsets.only(top: 3.sp),
                                child: Text(
                                  _getMonthName(month, isArabic),
                                  style: StyleText.fontSize12Weight400.copyWith(
                                    // See [_plotLabelColor] — same row, the
                                    // scrollable layout.
                                    color: _plotLabelColor,
                                  ),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  barGroups: _buildBarGroups(isArabic),
                ),
              ),
            ),
          );
            },
          ),
        ),

        // ✅ Fixed Y-axis for Arabic (right side)
        if (isArabic)
          SizedBox(
            width: axisReservedSize,
            child: _buildYAxisLabels(maxY, interval, isArabic),
          ),
      ],
    );
  }

  /// CHANGED 1/10/2026 (Services mobile QA p.39): a spaceBetween Column put
  /// each number up to half a line off the grid line it labels. Each number
  /// is now centred on its line's height, h × (1 − v / maxY).
  Widget _buildYAxisLabels(double maxY, double interval, bool isArabic) {
    final List<double> values = [];
    double value = maxY;
    while (value >= -0.0001) {
      values.add(value < 0 ? 0 : value);
      value -= interval;
    }
    final TextStyle style = StyleText.fontSize14Weight400.copyWith(
      fontSize: 10.sp,
      height: 1.0,
      color: _plotLabelColor,
    );
    final double lineHeight = 10.sp * 1.2;

    return Padding(
      padding: EdgeInsets.only(bottom: 28), // match bottomTitles reservedSize
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double h = constraints.maxHeight;
          return Stack(
            clipBehavior: Clip.none,
            children: values.map((v) {
              final double y = maxY <= 0 ? h : h * (1 - v / maxY);
              return Positioned(
                top: y - lineHeight / 2,
                height: lineHeight,
                left: 0,
                right: 0,
                child: Align(
                  alignment:
                      isArabic ? Alignment.centerLeft : Alignment.centerRight,
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
      ),
    );
  }

  Widget _buildHorizontalChart(BuildContext context, bool isArabic) {
    final maxY = _getMaxY();

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SizedBox(
        height: 12 * 60.h,
        child: BarChart(
          BarChartData(
            maxY: maxY,
            minY: 0,
            alignment: BarChartAlignment.spaceEvenly,
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              show: true,
              drawHorizontalLine: false,
              drawVerticalLine: true,
            ),
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipPadding: EdgeInsets.all(0.sp),
                tooltipMargin: 8.sp,
                getTooltipColor: (_) => AppColors.transparent,
                tooltipBorder: BorderSide.none,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  if (rod.toY > 0) {
                    return BarTooltipItem(
                      _formatNumber(rod.toY.toInt(), isArabic),
                      StyleText.fontSize10Weight400.copyWith(
                        color: widget.lightMode
                            ? AppColors.blackButton
                            : AppColors.white,
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 80.sp,
                  getTitlesWidget: (value, _) {
                    // ✅ FIXED: Reverse month order for Arabic
                    int month;
                    if (isArabic) {
                      month = 12 - value.toInt();
                    } else {
                      month = value.toInt() + 1;
                    }

                    if (month >= 1 && month <= 12) {
                      return Text(
                        _getMonthName(month, isArabic),
                        style: StyleText.fontSize14Weight400.copyWith(
                          fontSize: 12.sp,
                          color: widget.lightMode ? AppColors.black : AppColors.white,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30.sp,
                  getTitlesWidget: (value, _) {
                    return Text(
                      _formatNumber(value.toInt(), isArabic),
                      style: StyleText.fontSize14Weight400.copyWith(
                        fontSize: 12.sp,
                        color: _plotLabelColor,
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: _buildBarGroups(isArabic), // ✅ Pass isArabic parameter
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // Use appropriate language list
    final allServices = isArabic ? _allServicesArabic : _allServicesEnglish;

    // Prepare service dropdown items
    final List<Map<String, String>> serviceItems = [
      {'key': '', 'value': S.of(context).all_services ?? 'All Services'},
      ...allServices.map((serviceName) {
        return {'key': serviceName, 'value': serviceName};
      }).toList(),
    ];

    // Calculate totals for legend
    int totalCanceled = 0;
    int totalRejected = 0;
    for (var monthData in _monthlyData.values) {
      totalCanceled += monthData['canceled'] ?? 0;
      totalRejected += monthData['rejected'] ?? 0;
    }

    var isMobile = ContextExtension(context).isPhone;

    return Container(
      padding: EdgeInsets.only(top: 15.sp, right: 15.w,left: 15.w,bottom: 10.h),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 26.sp,
                          height: 26.sp,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              "assets/icons_assets/services_assets/headset_support.svg",
                              width: 16.sp,
                              height: 16.sp,
                              color: AppColors.textButton,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.sp),
                        Expanded(
                          child: Text(
                            S.of(context).monthlyComparison ?? 'Monthly Comparison',
                            style: StyleText.fontSize14Weight600.copyWith(
                              color: widget.lightMode
                                  ? AppColors.blackButton
                                  : AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.sp),
                    // Legend
                    Wrap(
                      spacing: 12.w,
                      runSpacing: 8.h,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12.sp,
                              height: 12.sp,
                              decoration: BoxDecoration(
                                color: AppColors.pending,
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '${S.of(context).Canceled}: ${_formatNumber(totalCanceled, isArabic)}',
                              // QA p.39: the legend was the faint plot-label
                              // grey; it is readable text like every other
                              // chart legend.
                              style: StyleText.fontSize12Weight400.copyWith(
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12.sp,
                              height: 12.sp,
                              decoration: BoxDecoration(
                                color: AppColors.block,
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '${S.of(context).Rejected}: ${_formatNumber(totalRejected, isArabic)}',
                              // QA p.39: the legend was the faint plot-label
                              // grey; it is readable text like every other
                              // chart legend.
                              style: StyleText.fontSize12Weight400.copyWith(
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
             isMobile ? SizedBox() : Spacer(),
              isMobile ? SizedBox() : SizedBox(
                width: MediaQuery.sizeOf(context).width * .25,
                child: CustomDropdown<String>(
                  value: _selectedServiceName,
                  items: serviceItems
                      .map((item) => DropdownItem<String>(
                            value: item['key']!,
                            label: item['value']!,
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedServiceName = value;
                    });
                    _loadData();
                  },
                  hint: S.of(context).select_service ?? 'Select Service',
                  hintStyle: StyleText.fontSize12Weight400.copyWith(
                    color: AppColors.secondaryText,
                  ),
                  label: S.of(context).service ?? 'Service',
                ),
              ),
            ],
          ),
          isMobile ? SizedBox(height: 10.sp) : SizedBox(),
          // FULL WIDTH on a phone (10/9/2026). This was
          // `MediaQuery.sizeOf(context).width * .45`, which left the field
          // stopping under half the card with dead space beside it and the
          // service names ellipsised for no reason. It is the only control on
          // its row, so it takes the row.
          isMobile ? SizedBox(
            width: double.infinity,
            child: CustomDropdown<String>(
              value: _selectedServiceName,
              items: serviceItems
                  .map((item) => DropdownItem<String>(
                        value: item['key']!,
                        label: item['value']!,
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedServiceName = value;
                });
                _loadData();
              },
              hint: S.of(context).select_service ?? 'Select Service',
              hintStyle: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.secondaryText,
              ),
              label: S.of(context).service ?? 'Service',
              // QA p.39: the chevron was faint. Same asset / size / colour as
              // the multi-select chevrons in the services filters.
              suffixIcon: CustomSvgImage(
                assetPath:
                    'assets/icons_assets/main_icons_assets/chevron_down.svg',
                width: 20.sp,
                height: 20.sp,
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(
                  AppColors.text.withOpacity(0.6),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ) : SizedBox(),

          SizedBox(height: 20.sp),

          // Chart
          _isLoading
              ? SizedBox(
            height: 300.h,
            child: Center(child: CircleProgressMaster()),
          )
              : SizedBox(
            height: widget.orientation == ChartOrientation.vertical ? 200.h : 200.h,
            child: widget.orientation == ChartOrientation.vertical
                ? _buildVerticalChart(context, isArabic)
                : _buildHorizontalChart(context, isArabic),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _dashboardCubit.close();
    super.dispose();
  }
}
