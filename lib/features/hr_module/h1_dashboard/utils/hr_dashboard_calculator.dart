// ***************************** FILE INFO ***************************** //
// File Name: hr_dashboard_calculator.dart
// Purpose: Calculates filtered HR dashboard statistics and chart data.
// Author: Mohamed Elrashidy
// Created At: 2026-08-05
// ********************************************************************* //

import 'dart:math';

import '../../h3_add_employee/utils/add_employee_form_options.dart';
import '../../main_controller/domain/entity/hr_dashboard_chart_item.dart';
import '../../main_controller/domain/entity/hr_dashboard_demographics_data.dart';
import '../../main_controller/domain/entity/hr_dashboard_distribution_item.dart';
import '../../main_controller/domain/entity/hr_dashboard_overall_data.dart';
import '../../main_controller/domain/entity/hr_dashboard_position_analytics_data.dart';
import '../../main_controller/domain/entity/hr_dashboard_range_summary.dart';
import 'package:knowticed_plus/features/hr_module/main_controller/domain/entity/hr_employee_entity.dart';

class HrDashboardCalculator {
  const HrDashboardCalculator._();

  /// Method Name: [filterEmployees]
  ///
  /// Purpose: Applies the active department and location filters.
  ///
  /// Parameters:
  /// - [employees]: Employees available to the dashboard.
  /// - [selectedDepartmentIds]: Selected stable department IDs.
  /// - [selectedLocations]: Selected work locations.
  ///
  /// Returns: Employees that satisfy all active filters.
  static List<HrEmployeeEntity> filterEmployees({
    required List<HrEmployeeEntity> employees,
    required List<String> selectedDepartmentIds,
    required List<String> selectedLocations,
  }) {
    return employees.where((employee) {
      final departmentId = employee.departmentId?.trim() ?? '';
      final location = employee.workLocation?.trim() ?? '';
      final matchesDepartment = selectedDepartmentIds.isEmpty ||
          selectedDepartmentIds.contains(departmentId);
      final matchesLocation =
          selectedLocations.isEmpty || selectedLocations.contains(location);
      return matchesDepartment && matchesLocation;
    }).toList();
  }

  /// Method Name: [calculateOverall]
  ///
  /// Purpose: Calculates overall employee and department dashboard totals.
  ///
  /// Parameters:
  /// - [filteredEmployees]: Employees after dashboard filters are applied.
  /// - [hasSourceData]: Whether any source data has loaded.
  ///
  /// Returns: Overall dashboard statistics.
  static HrDashboardOverallData calculateOverall({
    required List<HrEmployeeEntity> filteredEmployees,
    required bool hasSourceData,
  }) {
    final totalDepartments = filteredEmployees
        .map((employee) => employee.departmentId?.trim() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();

    return HrDashboardOverallData(
      totalEmployees: filteredEmployees.length,
      totalDepartments: totalDepartments.length,
      onboardingEmployees: 0,
      scheduledLeave: 0,
      attendanceCompliance: 0,
      hasData: hasSourceData,
    );
  }

  /// Method Name: [calculateAgeSummary]
  ///
  /// Purpose: Calculates completed-age minimum, average, and maximum values.
  ///
  /// Parameters:
  /// - [filteredEmployees]: Employees after dashboard filters are applied.
  /// - [asOfDate]: Date used as the calculation boundary.
  ///
  /// Returns: A range summary containing only valid birthday values.
  static HrDashboardRangeSummary calculateAgeSummary({
    required List<HrEmployeeEntity> filteredEmployees,
    DateTime? asOfDate,
  }) {
    final referenceDate = _dateOnly(asOfDate ?? DateTime.now());
    final ages = <int>[];
    for (final employee in filteredEmployees) {
      final birthDate = _parseDate(employee.birthDay);
      if (birthDate == null || birthDate.isAfter(referenceDate)) continue;
      ages.add(_completedYears(birthDate, referenceDate));
    }
    return _buildRangeSummary(ages);
  }

  /// Method Name: [calculateExperienceSummary]
  ///
  /// Purpose: Calculates completed organization-experience values from employment dates.
  ///
  /// Parameters:
  /// - [filteredEmployees]: Employees after dashboard filters are applied.
  /// - [asOfDate]: Date used as the calculation boundary.
  ///
  /// Returns: A range summary containing only valid start-date values.
  static HrDashboardRangeSummary calculateExperienceSummary({
    required List<HrEmployeeEntity> filteredEmployees,
    DateTime? asOfDate,
  }) {
    final referenceDate = _dateOnly(asOfDate ?? DateTime.now());
    final experiences = <int>[];
    for (final employee in filteredEmployees) {
      final startDate = _earliestExperienceStartDate(
        startDate: employee.startDate,
        firstLogin: employee.firstLogin,
        referenceDate: referenceDate,
      );
      if (startDate == null) continue;

      final endDate = _earliestEndDate(
        deactivationDate: _parseDate(employee.deactivationDate),
        referenceDate: referenceDate,
      );
      if (endDate.isBefore(startDate)) continue;
      experiences.add(_completedYears(startDate, endDate));
    }
    return _buildRangeSummary(experiences);
  }

  /// Method Name: [calculateDemographics]
  ///
  /// Purpose: Builds gender and marital-status distribution data.
  ///
  /// Parameters:
  /// - [filteredEmployees]: Employees after dashboard filters are applied.
  ///
  /// Returns: Demographic dashboard data.
  static HrDashboardDemographicsData calculateDemographics({
    required List<HrEmployeeEntity> filteredEmployees,
  }) {
    return HrDashboardDemographicsData(
      genderDistribution: _buildEnumDistribution(
        options: GenderOption.values,
        values: filteredEmployees
            .map((employee) => _normalizeGender(employee.gender)?.name),
      ),
      maritalStatusDistribution: _buildEnumDistribution(
        options: MaritalStatusOption.values,
        values: filteredEmployees.map(
          (employee) => _normalizeMaritalStatus(employee.maritalStatus)?.name,
        ),
      ),
      filteredEmployeeTotal: filteredEmployees.length,
    );
  }

  /// Method Name: [calculatePositionAnalytics]
  ///
  /// Purpose: Calculates enum-backed workforce and position distributions.
  ///
  /// Parameters:
  /// - [filteredEmployees]: Employees after dashboard filters are applied.
  ///
  /// Returns: Position analytics with configured zero-count categories included.
  static HrDashboardPositionAnalyticsData calculatePositionAnalytics({
    required List<HrEmployeeEntity> filteredEmployees,
  }) {
    final jobTypes = <String?>[];
    final workArrangements = <String?>[];
    final grades = <String?>[];
    final workforce = <String>[];

    for (final employee in filteredEmployees) {
      final jobType = employee.jobType;
      final workArrangement = employee.workArrangement;
      final grade = employee.employeeGrade;
      jobTypes.add(jobType);
      workArrangements.add(workArrangement);
      grades.add(grade);
      workforce.add(_workforceCategory(jobType: jobType, grade: grade));
    }

    final jobTypeDistribution = _buildEnumDistribution(
      options: AddEmployeeStandardOptions.jobTypes,
      values: jobTypes,
    );
    final workArrangementDistribution = _buildEnumDistribution(
      options: AddEmployeeStandardOptions.workArrangements,
      values: workArrangements,
    );
    final jobGradeDistribution = _buildEnumDistribution(
      options: AddEmployeeStandardOptions.grades,
      values: grades,
    );
    final workforceDistribution = _buildDistribution(
      categories: [
        JobTypeOption.contractor.name,
        EmployeeGradeOption.intern.name,
        HrDashboardPositionAnalyticsData.employeeCategoryKey,
      ],
      values: workforce,
      normalize: (value) => value,
    );

    return HrDashboardPositionAnalyticsData(
      workforceDistribution: workforceDistribution,
      jobTypeDistribution: jobTypeDistribution,
      workArrangementDistribution: workArrangementDistribution,
      jobGradeDistribution: jobGradeDistribution,
      hasData: jobTypes.any(_hasValue) ||
          workArrangements.any(_hasValue) ||
          grades.any(_hasValue),
    );
  }

  /// Method Name: [hasPositionData]
  ///
  /// Purpose: Reports whether loaded employees provide any current position values.
  ///
  /// Parameters:
  /// - [employees]: Employees available to the dashboard.
  ///
  /// Returns: True when at least one position value is available.
  static bool hasPositionData(List<HrEmployeeEntity> employees) {
    return employees.any(
      (employee) =>
          _hasValue(employee.jobType) ||
          _hasValue(employee.workArrangement) ||
          _hasValue(employee.employeeGrade) ||
          _hasValue(employee.startDate),
    );
  }

  /// Method Name: [calculateEmployeesPerLocation]
  ///
  /// Purpose: Counts employees by work location.
  ///
  /// Parameters:
  /// - [filteredEmployees]: Employees after dashboard filters are applied.
  ///
  /// Returns: Sorted location chart items.
  static List<HrDashboardChartItem> calculateEmployeesPerLocation({
    required List<HrEmployeeEntity> filteredEmployees,
  }) {
    return _buildChartItems(
      values: filteredEmployees.map((employee) => employee.workLocation),
    );
  }

  /// Method Name: [calculateNationalities]
  ///
  /// Purpose: Counts employees by nationality.
  ///
  /// Parameters:
  /// - [filteredEmployees]: Employees after dashboard filters are applied.
  ///
  /// Returns: Sorted nationality chart items.
  static List<HrDashboardChartItem> calculateNationalities({
    required List<HrEmployeeEntity> filteredEmployees,
  }) {
    return _buildChartItems(
      values: filteredEmployees.map((employee) => employee.nationality),
    );
  }

  /// Method Name: [calculateDepartmentEmployees]
  ///
  /// Purpose: Counts employees by stable department ID.
  ///
  /// Parameters:
  /// - [filteredEmployees]: Employees after dashboard filters are applied.
  ///
  /// Returns: Sorted department chart items.
  static List<HrDashboardChartItem> calculateDepartmentEmployees({
    required List<HrEmployeeEntity> filteredEmployees,
  }) {
    return _buildChartItems(
      values: filteredEmployees.map((employee) => employee.departmentId),
    );
  }

  /// Method Name: [_buildChartItems]
  ///
  /// Purpose: Aggregates non-empty values into descending chart items.
  ///
  /// Parameters:
  /// - [values]: Source values to aggregate.
  ///
  /// Returns: Chart items ordered by count and label.
  static List<HrDashboardChartItem> _buildChartItems({
    required Iterable<String?> values,
  }) {
    final labelsByKey = <String, String>{};
    final countsByKey = <String, int>{};

    for (final value in values) {
      final label = value?.trim() ?? '';
      if (label.isEmpty) continue;

      final key = label.toLowerCase();
      labelsByKey[key] ??= label;
      countsByKey[key] = (countsByKey[key] ?? 0) + 1;
    }

    final items = [
      for (final entry in countsByKey.entries)
        HrDashboardChartItem(
          category: labelsByKey[entry.key]!,
          count: entry.value,
        ),
    ];
    items.sort((a, b) => b.count.compareTo(a.count));
    return items;
  }

  /// Method Name: [_buildDistribution]
  ///
  /// Purpose: Aggregates normalized values into demographic distribution data.
  ///
  /// Parameters:
  /// - [values]: Source values to normalize and aggregate.
  /// - [normalize]: Converts a source value to a display category.
  /// - [filteredEmployeeTotal]: Total used to calculate distribution context.
  ///
  /// Returns: Distribution items ordered by count and label.
  static List<HrDashboardDistributionItem> _buildDistribution({
    required List<String> categories,
    required Iterable<String?> values,
    required String? Function(String?) normalize,
  }) {
    final counts = {for (final category in categories) category: 0};
    for (final value in values) {
      final category = normalize(value);
      if (category != null && counts.containsKey(category)) {
        counts[category] = counts[category]! + 1;
      }
    }
    return [
      for (final category in categories)
        HrDashboardDistributionItem(
          category: category,
          count: counts[category]!,
        ),
    ];
  }

  /// Method Name: [_buildEnumDistribution]
  ///
  /// Purpose: Keeps every configured option visible while preserving unknown values.
  ///
  /// Parameters:
  /// - [options]: Current Add Employee options for the distribution.
  /// - [values]: Latest normalized or legacy stored values.
  ///
  /// Returns: Distribution items in configured order followed by unknown values.
  static List<HrDashboardDistributionItem> _buildEnumDistribution({
    required List<Enum> options,
    required Iterable<String?> values,
  }) {
    final keys = options.map((option) => option.name).toList();
    final counts = {for (final key in keys) key: 0};
    final unknownCounts = <String, int>{};

    for (final value in values) {
      final rawValue = value?.trim() ?? '';
      if (rawValue.isEmpty) continue;
      final knownKey = _enumKeyForValue(rawValue, options);
      if (knownKey != null) {
        counts[knownKey] = counts[knownKey]! + 1;
      } else {
        unknownCounts[rawValue] = (unknownCounts[rawValue] ?? 0) + 1;
      }
    }

    return [
      for (final key in keys)
        HrDashboardDistributionItem(category: key, count: counts[key]!),
      for (final entry in unknownCounts.entries)
        HrDashboardDistributionItem(category: entry.key, count: entry.value),
    ];
  }

  /// Method Name: [_enumKeyForValue]
  ///
  /// Purpose: Matches enum names against legacy labels without using chart text.
  ///
  /// Parameters:
  /// - [value]: Stored enum name or legacy display label.
  /// - [options]: Enum options accepted by the owning Add Employee field.
  ///
  /// Returns: The matching enum name, or null for an unknown value.
  static String? _enumKeyForValue(
    String value,
    List<Enum> options,
  ) {
    final normalizedValue = _normalizeEnumKey(value);
    for (final option in options) {
      if (_normalizeEnumKey(option.name) == normalizedValue) {
        return option.name;
      }
    }
    return null;
  }

  /// Method Name: [_workforceCategory]
  ///
  /// Purpose: Applies the dashboard workforce precedence rules.
  ///
  /// Parameters:
  /// - [jobType]: Latest job-type enum value.
  /// - [grade]: Latest employee-grade enum value.
  ///
  /// Returns: A stable workforce category key.
  static String _workforceCategory({
    required String? jobType,
    required String? grade,
  }) {
    if (_matchesEnum(jobType, JobTypeOption.contractor)) {
      return JobTypeOption.contractor.name;
    }
    if (_matchesEnum(grade, EmployeeGradeOption.intern)) {
      return EmployeeGradeOption.intern.name;
    }
    return HrDashboardPositionAnalyticsData.employeeCategoryKey;
  }

  /// Method Name: [_matchesEnum]
  ///
  /// Purpose: Compares a stored value with an enum identity.
  ///
  /// Parameters:
  /// - [value]: Stored enum name or legacy label.
  /// - [option]: Expected enum option.
  ///
  /// Returns: Whether the values represent the same option.
  static bool _matchesEnum(String? value, Enum option) {
    return value != null &&
        _normalizeEnumKey(value) == _normalizeEnumKey(option.name);
  }

  /// Method Name: [_normalizeEnumKey]
  ///
  /// Purpose: Makes enum names and legacy labels comparable.
  ///
  /// Parameters:
  /// - [value]: Value to normalize.
  ///
  /// Returns: A case-insensitive key without separators.
  static String _normalizeEnumKey(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[\s_-]'), '');

  /// Method Name: [_hasValue]
  ///
  /// Purpose: Identifies a usable position value.
  ///
  /// Parameters:
  /// - [value]: Position value to inspect.
  ///
  /// Returns: Whether the value is non-empty.
  static bool _hasValue(String? value) => value?.trim().isNotEmpty ?? false;

  /// Method Name: [_normalizeGender]
  ///
  /// Purpose: Maps stored gender values to dashboard categories.
  ///
  /// Parameters:
  /// - [value]: Raw employee gender value.
  ///
  /// Returns: A normalized category or null when unsupported.
  static GenderOption? _normalizeGender(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'male':
      case 'm':
      case 'ذكر':
        return GenderOption.male;
      case 'female':
      case 'f':
      case 'انثى':
      case 'أنثى':
      case 'انثي':
      case 'أنثي':
        return GenderOption.female;
      default:
        return null;
    }
  }

  /// Method Name: [_normalizeMaritalStatus]
  ///
  /// Purpose: Maps stored marital-status values to dashboard categories.
  ///
  /// Parameters:
  /// - [value]: Raw employee marital-status value.
  ///
  /// Returns: A normalized category or null when unsupported.
  static MaritalStatusOption? _normalizeMaritalStatus(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'single':
      case 'اعزب':
      case 'أعزب':
        return MaritalStatusOption.single;
      case 'married':
      case 'متزوج':
        return MaritalStatusOption.married;
      case 'divorced':
      case 'مطلق':
        return MaritalStatusOption.divorced;
      case 'widowed':
      case 'ارمل':
      case 'أرمل':
        return MaritalStatusOption.widowed;
      default:
        return null;
    }
  }

  /// Method Name: [_buildRangeSummary]
  ///
  /// Purpose: Converts valid completed-year values into a summary range.
  ///
  /// Parameters:
  /// - [values]: Completed-year values to summarize.
  ///
  /// Returns: An empty or populated dashboard range summary.
  static HrDashboardRangeSummary _buildRangeSummary(List<int> values) {
    if (values.isEmpty) {
      return const HrDashboardRangeSummary(
        minimum: null,
        average: null,
        maximum: null,
        hasData: false,
      );
    }
    final total = values.fold<int>(0, (sum, value) => sum + value);
    values.sort();
    return HrDashboardRangeSummary(
      minimum: values.first,
      average: (total / values.length).round(),
      maximum: values.last,
      hasData: true,
    );
  }

  /// Method Name: [_earliestExperienceStartDate]
  ///
  /// Purpose: Chooses the earliest valid employment date from position history
  /// and the employee's first login date.
  ///
  /// Parameters:
  /// - [startDate]: Current employee start-date value.
  /// - [firstLogin]: Employee's first authenticated login date.
  /// - [referenceDate]: Current date used to reject future dates.
  ///
  /// Returns: The earliest valid experience start date, or null.
  static DateTime? _earliestExperienceStartDate({
    required String? startDate,
    required String? firstLogin,
    required DateTime referenceDate,
  }) {
    final candidates = [
      _parseDate(startDate),
      _parseDate(firstLogin),
    ].whereType<DateTime>().where((date) {
      return !date.isAfter(referenceDate);
    }).toList();
    if (candidates.isEmpty) return null;
    candidates.sort();
    return candidates.first;
  }

  /// Method Name: [_earliestEndDate]
  ///
  /// Purpose: Caps experience at the earlier of today and deactivation.
  ///
  /// Parameters:
  /// - [deactivationDate]: Optional employee end/deactivation date.
  /// - [referenceDate]: Current date used as the default end boundary.
  ///
  /// Returns: The effective end date for experience calculation.
  static DateTime _earliestEndDate({
    required DateTime? deactivationDate,
    required DateTime referenceDate,
  }) {
    if (deactivationDate == null || deactivationDate.isAfter(referenceDate)) {
      return referenceDate;
    }
    return deactivationDate;
  }

  /// Method Name: [_parseDate]
  ///
  /// Purpose: Parses a non-empty stored date into a local date-only value.
  ///
  /// Parameters:
  /// - [value]: Stored date value.
  ///
  /// Returns: A parsed date or null when the value is invalid.
  static DateTime? _parseDate(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    final parsed = DateTime.tryParse(trimmed);
    return parsed == null ? null : _dateOnly(parsed);
  }

  /// Method Name: [_completedYears]
  ///
  /// Purpose: Calculates completed calendar years between two dates.
  ///
  /// Parameters:
  /// - [startDate]: Birthday or employment start date.
  /// - [asOfDate]: Calculation boundary date.
  ///
  /// Returns: Completed whole years.
  static int _completedYears(DateTime startDate, DateTime asOfDate) {
    var years = asOfDate.year - startDate.year;
    final anniversaryDay = min(
      startDate.day,
      DateTime(asOfDate.year, startDate.month + 1, 0).day,
    );
    final anniversary = DateTime(
      asOfDate.year,
      startDate.month,
      anniversaryDay,
    );
    if (asOfDate.isBefore(anniversary)) years--;
    return max(0, years);
  }

  /// Method Name: [_dateOnly]
  ///
  /// Purpose: Removes time-of-day differences from date comparisons.
  ///
  /// Parameters:
  /// - [value]: Date to normalize.
  ///
  /// Returns: A local date at midnight.
  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
