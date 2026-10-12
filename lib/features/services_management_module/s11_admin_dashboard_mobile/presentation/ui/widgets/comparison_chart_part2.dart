part of 'comparison_chart.dart';

// Split from comparison_chart.dart to keep files <700 LOC.

class _MonthlyComparisonChartState extends State<MonthlyComparisonChart> {
  bool _isLoading = true;
  String? _selectedDepartmentId;
  Map<int, Map<String, int>> _monthlyData = {};
  ScrollController? _scrollController;

  late final MainCoreDepartmentCubit _departmentController;

  @override
  void initState() {
    super.initState();
    _departmentController = context.read<MainCoreDepartmentCubit>();
    _loadData();
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // 003: request docs come from the repository, not Firestore directly.
      final docs = await ServicesManagerCubit.get(context)
          .repository
          .getAllRequestServiceDocs();

      Map<int, Map<String, int>> data = {};
      for (int i = 1; i <= 12; i++) {
        data[i] = {'canceled': 0, 'rejected': 0};
      }

      final currentYear = DateTime.now().year;
      final employeeController = AppControllers.employee;

      for (var doc in docs) {
        try {
          final docData = doc.value;
          final model = ServicesHistoryModel.fromJson(docData, doc.key);

          String? documentDepartment;
          final emailRequester = docData['Email_Requester'];
          if (emailRequester is List && emailRequester.isNotEmpty) {
            final email = emailRequester[0];
            documentDepartment =
                employeeController.getEmployeeDepartmentName(email);
            if (documentDepartment == "no department") {
              documentDepartment = null;
            }
          }

          if (_selectedDepartmentId != null &&
              _selectedDepartmentId!.isNotEmpty) {
            if (documentDepartment == null) continue;
            final documentDepartmentId =
            _departmentController.getDepartmentIdFromDepartmentName(
              departmentName: documentDepartment.toLowerCase(),
            );
            if (documentDepartmentId != _selectedDepartmentId) continue;
          }

          String status = '';
          final stateArray = docData['state'];
          if (stateArray is List && stateArray.isNotEmpty) {
            status = stateArray.last?.toString().toLowerCase().trim() ?? '';
          }
          if (status.isEmpty) {
            status = _getFinalStateFromModel(model).toLowerCase();
          }

          if (status == 'cancel' ||
              status == 'canceled' ||
              status == 'rejected') {
            int? timestampValue;
            final timestampsArray = docData['timestamps'];
            if (timestampsArray is List && timestampsArray.isNotEmpty) {
              timestampValue = timestampsArray.last as int?;
            } else if (model.currentTimestamp != null) {
              timestampValue = model.currentTimestamp;
            }

            if (timestampValue != null) {
              final date = DateTime.fromMillisecondsSinceEpoch(timestampValue);
              if (date.year == currentYear) {
                final month = date.month;
                if (status == 'cancel' || status == 'canceled') {
                  data[month]!['canceled'] =
                      (data[month]!['canceled'] ?? 0) + 1;
                } else if (status == 'rejected') {
                  data[month]!['rejected'] =
                      (data[month]!['rejected'] ?? 0) + 1;
                }
              }
            }
          }
        } catch (e) {
          continue;
        }
      }

      setState(() {
        _monthlyData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _getFinalStateFromModel(ServicesHistoryModel service) {
    final outerState = service.currentState.toLowerCase().trim();
    final knownStates = [
      'done', 'inprogress', 'branchsla', 'breached sla', 'cancel',
      'canceled', 'pending', 'approved', 'rejected',
    ];
    if (knownStates.contains(outerState)) return outerState;

    final approvalList = service.currentApprovalCycle;
    if (approvalList.isEmpty) return 'pending';

    final states = <String>[];
    for (var approval in approvalList) {
      final state = (approval.state ?? '').toString().toLowerCase();
      if (state.isNotEmpty) states.add(state);
    }

    if (states.isEmpty) return 'pending';
    if (states.contains('cancel') || states.contains('canceled'))
      return 'cancel';
    if (states.contains('rejected')) return 'rejected';
    if (states.contains('pending')) return 'pending';
    if (states.contains('inprogress')) return 'inprogress';
    if (states.isNotEmpty && states.every((s) => s == 'approved'))
      return 'approved';
    return 'pending';
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

  double _getMaxY() {
    if (_monthlyData.isEmpty) return 10.0;
    double maxValue = 0;
    for (var monthData in _monthlyData.values) {
      final canceled = monthData['canceled'] ?? 0;
      final rejected = monthData['rejected'] ?? 0;
      // Bug report p.27: the two bars stand SIDE BY SIDE, so the scale is the
      // taller of the two — not their sum, which pushed the top of the axis
      // far above every bar.
      final tallest = canceled > rejected ? canceled : rejected;
      if (tallest > maxValue) maxValue = tallest.toDouble();
    }
    if (maxValue == 0) return 10.0;
    // A little headroom so the number drawn above the tallest bar is not
    // cut off by the top of the plot.
    int intMax = (maxValue * 1.15).ceil();
    int niceCeiling;
    if (intMax <= 5) {
      niceCeiling = 5;
    } else if (intMax <= 10) {
      // Even ceiling (6, 8 or 10) with the step of 2 below — a tallest bar of
      // 6 now tops out at 8, not 10.
      niceCeiling = (intMax / 2).ceil() * 2;
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

  // ── Y-axis labels ──────────────────────────────────────────────────────────

  Widget _buildYAxisLabels(double maxY, double interval, bool isArabic) {
    // FIXED 29/9/2026 (bug report p.27). The labels were N equal Expanded
    // rows spanning the plot AND the 28.sp month-name row under it, each
    // label at the TOP of its row — so no number sat on its gridline. Each
    // label is now centred on the exact height of its gridline, and the
    // month row is reserved at the bottom like the bars column does.
    final TextStyle style = StyleText.fontSize14Weight400
        .copyWith(fontSize: 9, color: AppColors.grey, height: 1);
    const double labelHeight = 12;
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double h = constraints.maxHeight;
              final List<Widget> labels = [];
              for (double value = 0; value <= maxY + 0.0001; value += interval) {
                final double y = h - (value / maxY) * h;
                labels.add(Positioned(
                  top: (y - labelHeight / 2).clamp(0.0, h - labelHeight),
                  left: 0,
                  right: 0,
                  height: labelHeight,
                  child: Center(
                    child: Text(_formatNumber(value.toInt(), isArabic),
                        style: style),
                  ),
                ));
              }
              return Stack(clipBehavior: Clip.none, children: labels);
            },
          ),
        ),
        SizedBox(height: 28.sp),
      ],
    );
  }

  // ── Single month bar (2 rods: canceled + rejected) ─────────────────────────

  Widget _buildSingleMonthBar({
    required double canceled,
    required double rejected,
    required double maxY,
    required double interval,
    required bool isArabic,
    required bool showGrid,
  }) {
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
            tooltipMargin: 6.sp,
            getTooltipColor: (_) => AppColors.transparent,
            tooltipBorder: BorderSide.none,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              if (rod.toY > 0) {
                return BarTooltipItem(
                  _formatNumber(rod.toY.toInt(), isArabic),
                  StyleText.fontSize10Weight400.copyWith(color: AppColors.text),
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
        // Bug report p.27: the Canceled bar had no number over it. Both rods
        // lived in ONE group, and fl_chart draws one tooltip per group —
        // positioned over the taller rod. Each rod is now its own group, so
        // each gets its own number right above it.
        groupsSpace: 4.sp,
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: canceled,
                width: 12.sp,
                color: AppColors.pending,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ],
            showingTooltipIndicators: canceled > 0 ? [0] : [],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: rejected,
                width: 12.sp,
                color: AppColors.block,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ],
            showingTooltipIndicators: rejected > 0 ? [0] : [],
          ),
        ],
      ),
    );
  }

  // ── Scrollable vertical chart with centered bars ───────────────────────────

  Widget _buildVerticalChart(BuildContext context, bool isArabic) {
    final maxY = _getMaxY();
    final interval = _getInterval(maxY);
    final double axisReservedSize = 28.0;
    final double itemWidth = 80.0;
    final double scrollContentWidth = 12 * itemWidth;

    final screenWidth = MediaQuery.of(context).size.width;
    final shouldScroll = (12 * 70.0) > (screenWidth - 30.sp);

    if (shouldScroll) {
      _scrollController ??= ScrollController();

      // Auto-scroll to first month with data
      int firstNonZeroIndex = -1;
      for (int m = 1; m <= 12; m++) {
        final monthData = _monthlyData[m] ?? {'canceled': 0, 'rejected': 0};
        if ((monthData['canceled'] ?? 0) > 0 ||
            (monthData['rejected'] ?? 0) > 0) {
          firstNonZeroIndex = m - 1;
          break;
        }
      }

      if (firstNonZeroIndex > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController!.hasClients) {
            double targetOffset = (firstNonZeroIndex * itemWidth) -
                (screenWidth / 2) +
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

      // ── Scrollable layout ──
      return Row(
        children: [
          if (!isArabic)
            SizedBox(
              width: axisReservedSize,
              child: _buildYAxisLabels(maxY, interval, isArabic),
            ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              child: SizedBox(
                width: scrollContentWidth,
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: List.generate(12, (index) {
                          final month = index + 1;
                          final monthData = _monthlyData[month] ??
                              {'canceled': 0, 'rejected': 0};
                          return SizedBox(
                            width: itemWidth,
                            child: _buildSingleMonthBar(
                              canceled:
                              (monthData['canceled'] ?? 0).toDouble(),
                              rejected:
                              (monthData['rejected'] ?? 0).toDouble(),
                              maxY: maxY,
                              interval: interval,
                              isArabic: isArabic,
                              // ✅ FIX (bug report p25 "complete the lines"):
                              // the chart is 12 independent mini BarCharts laid
                              // out in a Row, so `index == 0` meant only
                              // January drew grid lines and they stopped dead
                              // after the first column. Each segment has to
                              // draw its own portion for the line to read as
                              // continuous across the plot.
                              showGrid: true,
                            ),
                          );
                        }),
                      ),
                    ),
                    SizedBox(
                      height: 28.sp,
                      child: Row(
                        children: List.generate(12, (index) {
                          return SizedBox(
                            width: itemWidth,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 2),
                                child: Text(
                                  _getMonthName(index + 1, isArabic),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  style: StyleText.fontSize14Weight400.copyWith(
                                    fontSize: 11.sp,
                                    color: AppColors.text,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isArabic)
            SizedBox(
              width: axisReservedSize,
              child: _buildYAxisLabels(maxY, interval, isArabic),
            ),
        ],
      );
    }

    // ── Static layout (tablet/desktop) ──
    return Row(
      children: [
        if (!isArabic)
          SizedBox(
            width: 45.sp,
            child: _buildYAxisLabels(maxY, interval, isArabic),
          ),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: List.generate(12, (index) {
                    final month = index + 1;
                    final monthData =
                        _monthlyData[month] ?? {'canceled': 0, 'rejected': 0};
                    return Expanded(
                      child: _buildSingleMonthBar(
                        canceled: (monthData['canceled'] ?? 0).toDouble(),
                        rejected: (monthData['rejected'] ?? 0).toDouble(),
                        maxY: maxY,
                        interval: interval,
                        isArabic: isArabic,
                        // ✅ FIX (bug report p25): see the scrollable variant
                        // above — every month must draw its own grid segment.
                        showGrid: true,
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(
                height: 28.sp,
                child: Row(
                  textDirection:
                  isArabic ? TextDirection.rtl : TextDirection.ltr,
                  children: List.generate(12, (index) {
                    return Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 2),
                          child: Text(
                            _getMonthName(index + 1, isArabic),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            style: StyleText.fontSize14Weight400.copyWith(
                              fontSize: 10.sp,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        if (isArabic)
          SizedBox(
            width: 45.sp,
            child: _buildYAxisLabels(maxY, interval, isArabic),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final List<Map<String, String>> departmentItems = [
      {
        'key': '',
        'value': S.of(context).all_departments ?? 'All Departments'
      },
      ..._departmentController.departmentIds.map((id) {
        final name = isArabic
            ? _departmentController
            .getArabicDepartmentNameFromDepartmentId(departmentId: id)
            : _departmentController
            .getEnglishDepartmentNameFromDepartmentId(departmentId: id);
        return {'key': id, 'value': name ?? id};
      }).toList(),
    ];

    var isMobile = ContextExtension(context).isPhone;

    if (_isLoading) {
      return Container(
        height: isMobile ? 385.h : 330.h,
        padding: EdgeInsets.all(15.sp),
        decoration: BoxDecoration(
          color: widget.lightMode ? AppColors.white : AppColors.chatBackground,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(child: CircleProgressMaster()),
      );
    }

    // ✅ FIX (bug report p9 "use the chart of the component above"): this card
    // used to hand-roll its own container, header, legend and a grid of 12
    // separate mini BarCharts. It now renders through the shared
    // CustomVerticalBarChartWidget — the same component the Number Of Services
    // card above it uses — via that widget's new optional second-series
    // parameters, so Canceled and Rejected are both preserved.
    final labels = List.generate(12, (i) => _getMonthName(i + 1, isArabic));
    final canceledValues = List.generate(
      12,
      (i) => (_monthlyData[i + 1]?['canceled'] ?? 0).toDouble(),
    );
    final rejectedValues = List.generate(
      12,
      (i) => (_monthlyData[i + 1]?['rejected'] ?? 0).toDouble(),
    );

    return CustomVerticalBarChartWidget(
      title: S.of(context).monthlyComparison ?? 'Monthly Comparison',
      iconAsset: "assets/icons_assets/services_assets/headset_support.svg",
      labels: labels,
      values: canceledValues,
      secondaryValues: rejectedValues,
      legendLabel: S.of(context).Canceled,
      secondaryLegendLabel: S.of(context).Rejected,
      barColor: AppColors.pending,
      secondaryBarColor: AppColors.block,
      height: isMobile ? 385 : 330,
      lightMode: widget.lightMode,
      backgroundColor:
          widget.lightMode ? AppColors.white : AppColors.chatBackground,
      // The department picker keeps its existing mobile-only placement — the
      // shared widget drops headerWidget onto its own row on mobile.
      headerWidget: isMobile
          // QA p.43: full card width (was 45% of the screen, leaving the
          // department names ellipsised beside empty space) — the same rule
          // the employee dashboard's Service picker follows.
          ? SizedBox(
              width: double.infinity,
              child: CustomDropdown<String>(
                value: _selectedDepartmentId,
                items: departmentItems
                    .map((item) => DropdownItem<String>(
                          value: item['key']!,
                          label: item['value']!,
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedDepartmentId = value);
                  _loadData();
                },
                hint: S.of(context).selectDepartment ?? 'Select Department',
                hintStyle: StyleText.fontSize12Weight400
                    .copyWith(color: AppColors.secondaryText),
                label: S.of(context).department,
              ),
            )
          : null,
    );
  }
}
