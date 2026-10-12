/// Module: knowledge_hub / presentation / s8_dashboard / widgets/monthly_comparison_knowledge_chart.dart
/// ******************* FILE INFO *******************
/// File Name: monthly_comparison_knowledge_chart.dart
/// Description: Monthly comparison chart showing published vs removed knowledge documents across 12 months
/// Created by: Amr Mesbah
/// Last Update: 25/01/2026 - Changed to Published vs Removed with proper colors

import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/features/knowledge_hub/main_controller/domain/constants/knowledge_hub_colors.dart';
import 'package:knowticed_plus/features/knowledge_hub/main_controller/data/services/knowledge_hub_firebase_services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';


import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/custom/24-custom_chart_card.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../../main_controller/data/models/create_knowledge_new_model.dart';

class MonthlyComparisonKnowledgeChart extends StatefulWidget {
  final ChartOrientation orientation;
  final bool lightMode;
  final List<String>? selectedDepartments; // ✅ Global filter from parent

  const MonthlyComparisonKnowledgeChart({
    Key? key,
    this.orientation = ChartOrientation.vertical,
    required this.lightMode,
    this.selectedDepartments, // ✅ Global filter from parent
  }) : super(key: key);

  @override
  State<MonthlyComparisonKnowledgeChart> createState() => _MonthlyComparisonKnowledgeChartState();
}

class _MonthlyComparisonKnowledgeChartState extends State<MonthlyComparisonKnowledgeChart> {
  bool _isLoading = true;

  // REMOVED 28/8/2026 — the card's own "Department" dropdown, along with the
  // `_selectedDepartmentId` it wrote to and the `_allDepartments` list that
  // fed it. The dashboard already carries ONE department filter at the top of
  // the page (buildDepartmentFilterDropdown in dashboard_screen.dart), which
  // arrives here as [MonthlyComparisonKnowledgeChart.selectedDepartments] and
  // still narrows this chart along with every other card. A second, card-local
  // department picker that silently OVERRODE that page filter (see the old
  // "STEP 2" in _loadData) meant this one card could disagree with the rest of
  // the dashboard while both controls sat on screen looking equally in charge.

  // Department comparison data: department key -> {published, removed}.
  // The x-axis is departments (not months).
  Map<String, Map<String, int>> _deptData = {};
  // Ordered department keys plotted on the x-axis (only those with data).
  List<String> _plotDeptIds = [];

  final MainCoreDepartmentCubit _departmentController = Get.find<MainCoreDepartmentCubit>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  @override
  void didUpdateWidget(MonthlyComparisonKnowledgeChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ✅ Reload data when global department filter changes
    if (widget.selectedDepartments != oldWidget.selectedDepartments) {
      _loadData();
    }
  }

  /// ✅ Query from CreateKnowledge collection for published/removed documents
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {

      // ✅ Reload departments to ensure fresh data
      await _departmentController.getAllDepartments();

      // ✅ Build set of departments to filter by (from the page-level filter)
      Set<String> filterDeptIds = {};
      Set<String> filterDeptNames = {};

      // ✅ Apply the GLOBAL filter from parent (if exists)
      if (widget.selectedDepartments != null &&
          widget.selectedDepartments!.isNotEmpty &&
          !widget.selectedDepartments!.contains('all')) {

        for (var selectedId in widget.selectedDepartments!) {
          // Search by ID first
          for (var dept in _departmentController.departmentModels) {
            if (dept.departmentID == selectedId) {
              filterDeptIds.add(dept.departmentID!);
              // ✅ Add BOTH English AND Arabic names
              if (dept.departmentName != null && dept.departmentName!.isNotEmpty) {
                filterDeptNames.add(dept.departmentName!.toLowerCase());
              }
              if (dept.departmentNameInArabic != null && dept.departmentNameInArabic!.isNotEmpty) {
                filterDeptNames.add(dept.departmentNameInArabic!.toLowerCase());
              }
              break;
            }
          }

          // If not found by ID, try to find by name (legacy data)
          if (!filterDeptIds.contains(selectedId)) {
            for (var dept in _departmentController.departmentModels) {
              if (dept.departmentName?.toLowerCase() == selectedId.toLowerCase() ||
                  dept.departmentNameInArabic?.toLowerCase() == selectedId.toLowerCase()) {
                if (dept.departmentID != null) {
                  filterDeptIds.add(dept.departmentID!);
                  // ✅ Add BOTH English AND Arabic names
                  if (dept.departmentName != null && dept.departmentName!.isNotEmpty) {
                    filterDeptNames.add(dept.departmentName!.toLowerCase());
                  }
                  if (dept.departmentNameInArabic != null && dept.departmentNameInArabic!.isNotEmpty) {
                    filterDeptNames.add(dept.departmentNameInArabic!.toLowerCase());
                  }
                }
                break;
              }
            }
          }
        }

      }

      // REMOVED 28/8/2026 — the card-local dropdown's filter step used to sit
      // here and REPLACED filterDeptIds/filterDeptNames outright, so a
      // selection made inside this card beat the page-level filter above it.
      // The page filter is now the only one, and it is applied above.


      // ✅ Fetch via service (no Firestore in the chart widget, CR-KH-S8-01)
      final models = await KnowledgeHubFirebaseServices().fetchAllKnowledge();


      // Aggregate per department (built up as documents are seen).
      Map<String, Map<String, int>> deptData = {};

      // Process documents
      int publishedCount = 0;
      int removedCount = 0;
      int skippedNeverPublished = 0;
      int skippedDifferentDept = 0;
      int processedDocs = 0;

      for (var model in models) {
        try {

          // ✅ Skip if no status or timestamps
          if (model.status.isEmpty || model.timestamps.isEmpty) {
            continue;
          }

          final docDepartmentId = model.currentOwningDepartment;

          // ✅ Filter by departments if filter is active
          if (filterDeptIds.isNotEmpty) {
            bool isInFilteredDept = false;

            // ✅ Check 1: Match by department ID
            if (filterDeptIds.contains(docDepartmentId)) {
              isInFilteredDept = true;
            }

            // ✅ Check 2: Match by department NAME (case-insensitive)
            if (!isInFilteredDept && docDepartmentId.isNotEmpty) {
              if (filterDeptNames.contains(docDepartmentId.toLowerCase())) {
                isInFilteredDept = true;
              }
            }

            // ✅ Check 3: Find department by ID and compare names
            if (!isInFilteredDept) {
              for (var dept in _departmentController.departmentModels) {
                if (dept.departmentID == docDepartmentId) {
                  if (dept.departmentName != null && filterDeptNames.contains(dept.departmentName!.toLowerCase())) {
                    isInFilteredDept = true;
                    break;
                  }
                  if (dept.departmentNameInArabic != null && filterDeptNames.contains(dept.departmentNameInArabic!.toLowerCase())) {
                    isInFilteredDept = true;
                    break;
                  }
                }
              }
            }

            if (!isInFilteredDept) {
              skippedDifferentDept++;
              continue;
            }
          }

          processedDocs++;

          // Bucket by DEPARTMENT (x-axis). Documents without an owning
          // department can't be placed on a department axis, so skip them.
          final String deptKey = docDepartmentId.trim();
          if (deptKey.isEmpty) continue;
          deptData.putIfAbsent(deptKey, () => {'published': 0, 'removed': 0});

          // ✅ Get current status
          final currentStatus = model.status.last.toLowerCase();

          // ✅ PUBLISHED documents
          if (currentStatus == 'published') {
            deptData[deptKey]!['published'] =
                (deptData[deptKey]!['published'] ?? 0) + 1;
            publishedCount++;
          }

          // ✅ REMOVED documents (only if they were published first)
          if (currentStatus == 'removed') {
            if (!_wasEverPublished(model)) {
              skippedNeverPublished++;
              continue; // never published → not part of published/removed
            }
            deptData[deptKey]!['removed'] =
                (deptData[deptKey]!['removed'] ?? 0) + 1;
            removedCount++;
          }

        } catch (e) {
        }
      }

      // Keep only departments that actually have data, ordered by display name.
      final isArabicLoad = Get.locale?.languageCode == 'ar';
      final plotIds = deptData.entries
          .where((e) =>
              (e.value['published'] ?? 0) + (e.value['removed'] ?? 0) > 0)
          .map((e) => e.key)
          .toList()
        ..sort((a, b) => _getDepartmentDisplayName(a, isArabicLoad)
            .toLowerCase()
            .compareTo(_getDepartmentDisplayName(b, isArabicLoad).toLowerCase()));

      setState(() {
        _deptData = deptData;
        _plotDeptIds = plotIds;
        _isLoading = false;
      });


    } catch (e, stackTrace) {
      setState(() => _isLoading = false);
    }
  }

  /// ✅ Check if document was ever published
  bool _wasEverPublished(CreateKnowledgeModel doc) {
    if (doc.status.isEmpty) return false;

    // Check if 'published' exists anywhere in the status history
    for (var status in doc.status) {
      if (status.toLowerCase() == 'published') {
        return true;
      }
    }
    return false;
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

  /// Human-readable department name for a bucket key. The key is whatever
  /// `currentOwningDepartment` holds (an id or a name); resolve it against the
  /// department controller, localizing to Arabic when needed, and fall back to
  /// the raw key.
  String _getDepartmentDisplayName(String key, bool isArabic) {
    final k = key.toLowerCase();
    for (final dept in _departmentController.departmentModels) {
      final en = (dept.departmentName ?? '');
      final ar = (dept.departmentNameInArabic ?? '');
      if (dept.departmentID == key ||
          en.toLowerCase() == k ||
          ar.toLowerCase() == k) {
        return isArabic ? (ar.isNotEmpty ? ar : (en.isNotEmpty ? en : key))
                        : (en.isNotEmpty ? en : key);
      }
    }
    return key;
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
    if (_deptData.isEmpty) return 10.0;

    double maxValue = 0;
    for (var deptRow in _deptData.values) {
      final published = deptRow['published'] ?? 0;
      final removed = deptRow['removed'] ?? 0;
      final total = published + removed;
      if (total > maxValue) maxValue = total.toDouble();
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

  List<BarChartGroupData> _buildBarGroups() {
    List<BarChartGroupData> groups = [];

    for (int idx = 0; idx < _plotDeptIds.length; idx++) {
      final deptRow =
          _deptData[_plotDeptIds[idx]] ?? {'published': 0, 'removed': 0};
      final published = (deptRow['published'] ?? 0).toDouble();
      final removed = (deptRow['removed'] ?? 0).toDouble();

      groups.add(
        BarChartGroupData(
          x: idx,
          barsSpace: 4.sp,
          barRods: [
            BarChartRodData(
              toY: published,
              width: 12.sp,
              color: KnowledgeHubColors.greenAccent, // ✅ Green for published
              borderRadius: BorderRadius.circular(4.r),
            ),
            BarChartRodData(
              toY: removed,
              width: 12.sp,
              color: KnowledgeHubColors.redLight, // ✅ Red for removed
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

    return BarChart(
      BarChartData(
        maxY: maxY,
        minY: 0,
        alignment: BarChartAlignment.spaceEvenly,
        groupsSpace: 20.sp,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (value) {
            // Match the faint dashed gridlines used across the app's chart
            // cards (see BarChartCard) instead of a bold solid black line.
            return FlLine(
              color: AppColors.border.withOpacity(.4),
              strokeWidth: 1,
              dashArray: [4, 4],
            );
          },
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
                      color: AppColors.text
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
              reservedSize: 20.sp,
              interval: interval,
              getTitlesWidget: (value, _) {
                if (value % interval == 0) {
                  return Text(
                    _formatNumber(value.toInt(), isArabic),
                    style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.text
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
              reservedSize: 20.sp,
              interval: interval,
              getTitlesWidget: (value, _) {
                if (value % interval == 0) {
                  return Text(
                    _formatNumber(value.toInt(), isArabic),
                    style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.text
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              reservedSize: 30,
              showTitles: true,
              getTitlesWidget: (value, _) {
                final idx = value.toInt();
                if (idx >= 0 && idx < _plotDeptIds.length) {
                  return Padding(
                    padding: EdgeInsets.only(top: 3.sp),
                    child: SizedBox(
                      width: 70.w,
                      child: Text(
                        _getDepartmentDisplayName(_plotDeptIds[idx], isArabic),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: StyleText.fontSize12Weight500.copyWith(
                          color: AppColors.text,
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
        barGroups: _buildBarGroups(),
      ),
    );
  }

  Widget _buildHorizontalChart(BuildContext context, bool isArabic) {
    final maxY = _getMaxY();

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SizedBox(
        height: (_plotDeptIds.isEmpty ? 1 : _plotDeptIds.length) * 60.h,
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
                    final idx = value.toInt();
                    if (idx >= 0 && idx < _plotDeptIds.length) {
                      return Text(
                        _getDepartmentDisplayName(_plotDeptIds[idx], isArabic),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: widget.lightMode ? AppColors.colorBlack : AppColors.colorWhite,
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
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: widget.lightMode ? AppColors.colorGrey : Colors.grey.shade400,
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: _buildBarGroups(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // Calculate totals for legend
    int totalPublished = 0;
    int totalRemoved = 0;
    for (var deptRow in _deptData.values) {
      totalPublished += deptRow['published'] ?? 0;
      totalRemoved += deptRow['removed'] ?? 0;
    }

    return Container(
      padding: EdgeInsets.only(top: 15.sp, right: 15.w, left: 15.w, bottom: 10.h),
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
                            child: Icon(
                                Icons.insights,
                                size: 16.sp,
                                color: AppColors.textButton
                            ),
                          ),
                        ),
                        SizedBox(width: 8.sp),
                        Expanded(
                          child: Text(
                            S.of(context).knowledge_monthly_comparison ?? 'Knowledge Monthly Comparison',
                            style: StyleText.fontSize14Weight600.copyWith(
                                color: AppColors.text
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
                                color: KnowledgeHubColors.greenAccent, // ✅ Green
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '${S.of(context).published ?? "Published"}: ${_formatNumber(totalPublished, isArabic)}',
                              style: StyleText.fontSize12Weight400.copyWith(
                                  color: AppColors.text
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
                                color: KnowledgeHubColors.redLight, // ✅ Red
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '${S.of(context).removed ?? "Removed"}: ${_formatNumber(totalRemoved, isArabic)}',
                              style: StyleText.fontSize12Weight400.copyWith(
                                  color: AppColors.text
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // REMOVED 28/8/2026 — the card-local "Department" dropdown stood
              // here. The title and legend now have the header row to
              // themselves; the page-level department filter at the top of the
              // dashboard still narrows this chart via `selectedDepartments`.
            ],
          ),

          SizedBox(height: 20.sp),

          // Chart
          _isLoading
              ? SizedBox(
            height: 300.h,
            child: Center(child: CircleProgressMaster()),
          )
              : (totalPublished == 0 && totalRemoved == 0)
              ? SizedBox(
            height: 200,
            child: Center(
              child: Text(
                S.of(context).no_data_available ?? 'No published or removed documents found',
                style: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.text.withOpacity(0.6),
                ),
              ),
            ),
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
}