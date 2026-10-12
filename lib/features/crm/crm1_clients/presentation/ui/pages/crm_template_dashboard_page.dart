// ****************** FILE INFO ******************
// File Name: crm_template_dashboard_page.dart
// Purpose: Dynamic template-specific dashboard page displaying KPIs, field-based donut charts, and monthly trends.
// Author: Mohand Adel
// Created At: 11/08/2026

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/custom/4-custom_dropdwon_range_calander.dart';
import 'package:knowticed_plus/core/custom/27-custom_donut_chart_card.dart';
import 'package:knowticed_plus/core/custom/26-custom_bar_chart_card.dart';
import 'package:knowticed_plus/core/custom/29-custom_grouped_bar_chart_card.dart';
import 'package:knowticed_plus/core/custom/24-custom_chart_card.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_navigation_helper.dart';

import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_record_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/controller/crm_clients_list_cubit.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/controller/crm_clients_list_state.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_kpi_stats_widget.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_field_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/domain/base_repository/crm_controls_base_repository.dart';

import 'package:knowticed_plus/generated/l10n.dart';

/// Page displaying a dynamic dashboard for a specific client template.
class CrmTemplateDashboardPage extends StatefulWidget {
  final String templateId;
  final String templateName;
  final String clientType;
  final String? clientTypeId;

  const CrmTemplateDashboardPage({
    super.key,
    required this.templateId,
    required this.templateName,
    required this.clientType,
    this.clientTypeId,
  });

  @override
  State<CrmTemplateDashboardPage> createState() =>
      _CrmTemplateDashboardPageState();
}

class _CrmTemplateDashboardPageState extends State<CrmTemplateDashboardPage> {
  late final CrmControlsBaseRepository _controlsRepository =
      Get.find<CrmControlsBaseRepository>();
  StreamSubscription? _fieldsSubscription;
  List<CrmTemplateFieldModel> _fields = [];
  bool _loadingFields = true;

  @override
  void initState() {
    super.initState();
    _fieldsSubscription = _controlsRepository
        .watchTemplateFields(templateId: widget.templateId)
        .listen((result) {
      if (mounted) {
        setState(() {
          _fields = result.fold(
            (failure) => [],
            (fields) => fields.where((f) => !f.isDeleted).toList(),
          );
          _loadingFields = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _fieldsSubscription?.cancel();
    super.dispose();
  }

  bool get _isArabic => Get.locale.toString().contains('ar');
  String get _locale => _isArabic ? 'ar' : 'en';

  static const List<String> _englishMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  static const List<String> _arabicMonths = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر'
  ];

  /// Checks if a field type is choice-based.
  bool _isChoiceField(CrmTemplateFieldModel field) {
    final String type = field.fieldTypeId.toLowerCase();
    return const [
      'dropdown',
      'multiselect',
      'checkbox',
      'radio',
      'preferred_language',
      'company_size',
      'sector',
      'industry',
      'tag'
    ].contains(type);
  }

  /// Extracts unique values from client records for city/country options.
  List<String> _extractUniqueValues(
      List<CrmClientRecordModel> records, String systemKey) {
    final Set<String> unique = {};
    for (final record in records) {
      final dynamic raw = record.valueFor(null, systemKey);
      if (raw == null) continue;
      if (raw is List) {
        for (final item in raw) {
          if (item != null && item.toString().trim().isNotEmpty) {
            unique.add(item.toString().trim());
          }
        }
      } else if (raw is Map) {
        final val = raw[_locale] ?? raw['en'] ?? raw['ar'];
        if (val != null && val.toString().trim().isNotEmpty) {
          unique.add(val.toString().trim());
        }
      } else {
        if (raw.toString().trim().isNotEmpty) {
          unique.add(raw.toString().trim());
        }
      }
    }
    return unique.toList()..sort();
  }

  /// Normalizes dynamic field values to a list of strings.
  List<String> _normalizeDynamicValue(dynamic value) {
    if (value == null) return const [];
    if (value is List) {
      return value
          .map((item) => item?.toString().trim() ?? '')
          .where((item) => item.isNotEmpty)
          .toList();
    }
    if (value is Map) {
      final val = value[_locale] ?? value['en'] ?? value['ar'];
      if (val != null && val.toString().trim().isNotEmpty) {
        return [val.toString().trim()];
      }
      return value.values
          .map((item) => item?.toString().trim() ?? '')
          .where((item) => item.isNotEmpty)
          .toList();
    }
    final String text = value.toString().trim();
    return text.isEmpty ? const [] : [text];
  }

  /// Verifies if a field value matches expected criteria.
  bool _matchesExpected(dynamic raw, String expected) {
    final String exp = expected.trim().toLowerCase();
    if (raw is List) {
      return raw.any((item) => item?.toString().trim().toLowerCase() == exp);
    }
    if (raw is Map) {
      final val = raw[_locale] ?? raw['en'] ?? raw['ar'];
      return val?.toString().trim().toLowerCase() == exp;
    }
    return raw.toString().trim().toLowerCase() == exp;
  }

  /// Filters client records according to the active filters.
  List<CrmClientRecordModel> _getFilteredRecords(
    List<CrmClientRecordModel> records,
    CrmClientsListState state,
  ) {
    return records.where((record) {
      if (record.templateId != widget.templateId) {
        final bool legacyMatch = record.templateId.isEmpty &&
            record.clientTypeId == widget.clientTypeId;
        if (!legacyMatch) return false;
      }
      if (record.status.toLowerCase() == 'deleted') return false;

      if (state.dashboardCity.isNotEmpty) {
        final dynamic cityRaw = record.valueFor(null, 'city');
        if (cityRaw == null ||
            !_matchesExpected(cityRaw, state.dashboardCity)) {
          return false;
        }
      }

      if (state.dashboardCountry.isNotEmpty) {
        final dynamic countryRaw = record.valueFor(null, 'country');
        if (countryRaw == null ||
            !_matchesExpected(countryRaw, state.dashboardCountry)) {
          return false;
        }
      }

      if (state.dashboardStatus.isNotEmpty) {
        if (record.status.toLowerCase() !=
            state.dashboardStatus.toLowerCase()) {
          return false;
        }
      }

      if (state.dashboardStartDate != null) {
        if (record.audit.createdAt.isBefore(state.dashboardStartDate!)) {
          return false;
        }
      }
      if (state.dashboardEndDate != null) {
        final DateTime endLimit = DateTime(
            state.dashboardEndDate!.year,
            state.dashboardEndDate!.month,
            state.dashboardEndDate!.day,
            23,
            59,
            59,
            999);
        if (record.audit.createdAt.isAfter(endLimit)) return false;
      }

      return true;
    }).toList();
  }

  /// Aggregates choice field statistics for the donut charts.
  List<ChartData> _getDonutSections(
    List<CrmClientRecordModel> records,
    CrmTemplateFieldModel field,
  ) {
    final Map<String, double> counts = {};
    for (final record in records) {
      final dynamic raw = record.valueFor(field.id, field.systemKey);
      if (raw == null) continue;

      final List<String> items = _normalizeDynamicValue(raw);
      for (final val in items) {
        if (val.trim().isNotEmpty) {
          counts[val] = (counts[val] ?? 0.0) + 1.0;
        }
      }
    }

    final List<Color> sectionColors = [
      AppColors.primary,
      AppColors.grey,
      AppColors.darkGrey,
      AppColors.black,
      AppColors.blue,
      AppColors.orange,
      AppColors.green,
      AppColors.red,
      AppColors.yellow,
    ];

    final List<ChartData> sections = [];
    int idx = 0;

    final sortedEntries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final entry in sortedEntries) {
      sections.add(ChartData(
        label: entry.key,
        value: entry.value,
        color: sectionColors[idx % sectionColors.length],
      ));
      idx++;
    }
    return sections;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: S.current.crm,
        secondTitle: S.current.crmClients,
        thirdTitle: widget.templateName,
        fourthTitle: S.current.crmDashboardTab,
        onFirstTap: () => CrmNavigationHelper.popToDashboard(context),
        onSecondTap: () => CrmNavigationHelper.pop(context),
        onThirdTap: () => CrmNavigationHelper.pop(context),
        child: BlocBuilder<CrmClientsListCubit, CrmClientsListState>(
          builder: (BuildContext context, CrmClientsListState state) {
            if (_loadingFields || state.isLoading) {
              return const CircleProgressMaster();
            }

            final List<CrmClientRecordModel> activeRecords = state.records
                .where((r) =>
                    r.templateId == widget.templateId ||
                    (r.templateId.isEmpty &&
                        r.clientTypeId == widget.clientTypeId))
                .where((r) => r.status.toLowerCase() != 'deleted')
                .toList();

            final List<CrmClientRecordModel> filteredRecords =
                _getFilteredRecords(state.records, state);

            final List<String> cities =
                _extractUniqueValues(activeRecords, 'city');
            final List<String> countries =
                _extractUniqueValues(activeRecords, 'country');

            final List<DropdownItem<String>> cityOptions = [
              DropdownItem(value: '', label: S.current.crmAllCity),
              ...cities.map((c) => DropdownItem(value: c, label: c)),
            ];

            final List<DropdownItem<String>> countryOptions = [
              DropdownItem(value: '', label: S.current.crmAllCountry),
              ...countries.map((c) => DropdownItem(value: c, label: c)),
            ];

            final List<DropdownItem<String>> statusOptions = [
              DropdownItem(value: '', label: S.current.crmAllStatus),
              DropdownItem(value: 'active', label: S.current.crmActive),
              DropdownItem(value: 'inactive', label: S.current.crmInactive),
              DropdownItem(value: 'prospect', label: S.current.crmProspect),
              DropdownItem(value: 'archived', label: S.current.crmArchived),
            ];

            final List<CrmTemplateFieldModel> choiceFields =
                _fields.where(_isChoiceField).toList();

            final double screenWidth = MediaQuery.of(context).size.width;
            final bool isMobile = screenWidth < 600;
            final int crossAxisCount = screenWidth >= 600 ? 2 : 1;

            final List<ChartData> monthlyTrends = [];
            final List<ChartData> statusSeries = [
              ChartData(
                label: S.current.crmActive,
                value: 0,
                color: AppColors.green,
              ),
              ChartData(
                label: S.current.crmInactive,
                value: 0,
                color: AppColors.orange,
              ),
              ChartData(
                label: S.current.crmProspect,
                value: 0,
                color: AppColors.blue,
              ),
              ChartData(
                label: S.current.crmArchived,
                value: 0,
                color: AppColors.grey,
              ),
            ];

            final List<GroupedBarData> statusGroups = [];
            final DateTime now = DateTime.now();

            for (int i = 5; i >= 0; i--) {
              final DateTime date = DateTime(now.year, now.month - i, 1);
              final String monthName = _isArabic
                  ? _arabicMonths[date.month - 1]
                  : _englishMonths[date.month - 1];

              final List<CrmClientRecordModel> monthRecords =
                  filteredRecords.where((r) {
                final DateTime createdAt = r.audit.createdAt;
                return createdAt.year == date.year &&
                    createdAt.month == date.month;
              }).toList();

              monthlyTrends.add(ChartData(
                label: monthName,
                value: monthRecords.length.toDouble(),
              ));

              final double activeCount = monthRecords
                  .where((r) => r.status.toLowerCase() == 'active')
                  .length
                  .toDouble();
              final double inactiveCount = monthRecords
                  .where((r) => r.status.toLowerCase() == 'inactive')
                  .length
                  .toDouble();
              final double prospectCount = monthRecords
                  .where((r) => r.status.toLowerCase() == 'prospect')
                  .length
                  .toDouble();
              final double archivedCount = monthRecords
                  .where((r) => r.status.toLowerCase() == 'archived')
                  .length
                  .toDouble();

              statusGroups.add(GroupedBarData(
                label: monthName,
                values: [
                  activeCount,
                  inactiveCount,
                  prospectCount,
                  archivedCount
                ],
              ));
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filters row
                  if (isMobile)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 112.sp,
                            child: CustomDropdown<String>(
                              hint: S.current.crmCity,
                              value: state.dashboardCity.isEmpty
                                  ? null
                                  : state.dashboardCity,
                              items: cityOptions,
                              onChanged: (val) {
                                context
                                    .read<CrmClientsListCubit>()
                                    .setDashboardCityFilter(val);
                              },
                              fillColor: AppColors.card,
                              borderRadius: BorderRadius.circular(10.sp),
                              hintStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.mediumGrey)
                                  .copyWith(
                                color: AppColors.secondaryBlack,
                              ),
                              valueStyle: StyleText.fontSize12Weight400
                                  .copyWith(
                                color: AppColors.black,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.sp),
                          SizedBox(
                            width: 112.sp,
                            child: CustomDropdown<String>(
                              hint: S.current.crmCountry,
                              value: state.dashboardCountry.isEmpty
                                  ? null
                                  : state.dashboardCountry,
                              items: countryOptions,
                              onChanged: (val) {
                                context
                                    .read<CrmClientsListCubit>()
                                    .setDashboardCountryFilter(val);
                              },
                              fillColor: AppColors.card,
                              borderRadius: BorderRadius.circular(10.sp),
                              hintStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.mediumGrey)
                                  .copyWith(
                                color: AppColors.secondaryBlack,
                              ),
                              valueStyle: StyleText.fontSize12Weight400
                                  .copyWith(
                                color: AppColors.black,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.sp),
                          SizedBox(
                            width: 112.sp,
                            child: CustomDropdown<String>(
                              hint: S.current.crmStatus,
                              value: state.dashboardStatus.isEmpty
                                  ? null
                                  : state.dashboardStatus,
                              items: statusOptions,
                              onChanged: (val) {
                                context
                                    .read<CrmClientsListCubit>()
                                    .setDashboardStatusFilter(val);
                              },
                              fillColor: AppColors.card,
                              borderRadius: BorderRadius.circular(10.sp),
                              hintStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.mediumGrey)
                                  .copyWith(
                                color: AppColors.secondaryBlack,
                              ),
                              valueStyle: StyleText.fontSize12Weight400
                                  .copyWith(
                                color: AppColors.black,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.sp),
                          SizedBox(
                            width: 150.sp,
                            child: CustomDropdownRangeCalendar(
                              startDate: state.dashboardStartDate,
                              endDate: state.dashboardEndDate,
                              hint: S.current.calendar,
                              fillColor: AppColors.card,
                              borderRadius: BorderRadius.circular(10.sp),
                              hintStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.mediumGrey)
                                  .copyWith(
                                color: AppColors.secondaryBlack,
                              ),
                              valueStyle: StyleText.fontSize12Weight400
                                  .copyWith(
                                color: AppColors.black,
                              ),
                              onChanged: (start, end) {
                                context
                                    .read<CrmClientsListCubit>()
                                    .setDashboardDateRange(start, end);
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8.sp,
                      runSpacing: 8.sp,
                      children: [
                        SizedBox(
                          width: 112.sp,
                          child: CustomDropdown<String>(
                            hint: S.current.crmCity,
                            value: state.dashboardCity.isEmpty
                                ? null
                                : state.dashboardCity,
                            items: cityOptions,
                            onChanged: (val) {
                              context
                                  .read<CrmClientsListCubit>()
                                  .setDashboardCityFilter(val);
                            },
                            fillColor: AppColors.card,
                            borderRadius: BorderRadius.circular(10.sp),
                            hintStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.mediumGrey)
                                .copyWith(
                              color: AppColors.secondaryBlack,
                            ),
                            valueStyle:
                                StyleText.fontSize12Weight400.copyWith(
                              color: AppColors.black,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 112.sp,
                          child: CustomDropdown<String>(
                            hint: S.current.crmCountry,
                            value: state.dashboardCountry.isEmpty
                                ? null
                                : state.dashboardCountry,
                            items: countryOptions,
                            onChanged: (val) {
                              context
                                  .read<CrmClientsListCubit>()
                                  .setDashboardCountryFilter(val);
                            },
                            fillColor: AppColors.card,
                            borderRadius: BorderRadius.circular(10.sp),
                            hintStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.mediumGrey)
                                .copyWith(
                              color: AppColors.secondaryBlack,
                            ),
                            valueStyle:
                                StyleText.fontSize12Weight400.copyWith(
                              color: AppColors.black,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 112.sp,
                          child: CustomDropdown<String>(
                            hint: S.current.crmStatus,
                            value: state.dashboardStatus.isEmpty
                                ? null
                                : state.dashboardStatus,
                            items: statusOptions,
                            onChanged: (val) {
                              context
                                  .read<CrmClientsListCubit>()
                                  .setDashboardStatusFilter(val);
                            },
                            fillColor: AppColors.card,
                            borderRadius: BorderRadius.circular(10.sp),
                            hintStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.mediumGrey)
                                .copyWith(
                              color: AppColors.secondaryBlack,
                            ),
                            valueStyle:
                                StyleText.fontSize12Weight400.copyWith(
                              color: AppColors.black,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 150.sp,
                          child: CustomDropdownRangeCalendar(
                            startDate: state.dashboardStartDate,
                            endDate: state.dashboardEndDate,
                            hint: S.current.calendar,
                            fillColor: AppColors.card,
                            borderRadius: BorderRadius.circular(10.sp),
                            hintStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.mediumGrey)
                                .copyWith(
                              color: AppColors.secondaryBlack,
                            ),
                            valueStyle:
                                StyleText.fontSize12Weight400.copyWith(
                              color: AppColors.black,
                            ),
                            onChanged: (start, end) {
                              context
                                  .read<CrmClientsListCubit>()
                                  .setDashboardDateRange(start, end);
                            },
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 16.sp),

                  // KPIs Cards
                  CrmKpiStatsWidget(
                    totalCount: filteredRecords.length,
                    activeCount: filteredRecords
                        .where((r) => r.status.toLowerCase() == 'active')
                        .length,
                    inactiveCount: filteredRecords
                        .where((r) => r.status.toLowerCase() == 'inactive')
                        .length,
                    prospectCount: filteredRecords
                        .where((r) => r.status.toLowerCase() == 'prospect')
                        .length,
                    archivedCount: filteredRecords
                        .where((r) => r.status.toLowerCase() == 'archived')
                        .length,
                  ),
                  SizedBox(height: 16.sp),

                  // Choice Fields Donut Charts Grid
                  if (choiceFields.isNotEmpty) ...[
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisExtent: 230.sp,
                        crossAxisSpacing: 12.sp,
                        mainAxisSpacing: 12.sp,
                      ),
                      itemCount: choiceFields.length,
                      itemBuilder: (BuildContext context, int index) {
                        final field = choiceFields[index];
                        final sections =
                            _getDonutSections(filteredRecords, field);
                        final double total =
                            sections.fold<double>(0, (sum, s) => sum + s.value);
                        final String title =
                            _locale == 'ar' && field.nameAr.isNotEmpty
                                ? field.nameAr
                                : field.nameEn;

                        return DonutChartCard(
                          title: title,
                          sections: sections,
                          centerValue: total >= 1000
                              ? '${(total / 1000).toStringAsFixed(1)}K'
                              : total.toInt().toString(),
                          centerLabel: S.current.crmTotal,
                        );
                      },
                    ),
                    SizedBox(height: 16.sp),
                  ],

                  // Monthly signup Bar Chart
                  BarChartCard(
                    title: S.current.crmClients,
                    bars: monthlyTrends,
                  ),
                  SizedBox(height: 16.sp),

                  // Monthly grouped status Bar Chart
                  GroupedBarChartCard(
                    title: S.current.crmClientsStatus,
                    series: statusSeries,
                    groups: statusGroups,
                  ),
                  SizedBox(height: 32.sp),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
