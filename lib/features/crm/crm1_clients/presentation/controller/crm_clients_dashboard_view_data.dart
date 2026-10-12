// ****************** FILE INFO ******************
// File Name: crm_clients_dashboard_view_data.dart
// Purpose: Dashboard filter and aggregate models for the CRM clients dashboard
// Author: Mohand Adel
// Created At: 11/08/2026

import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_record_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/controller/crm_clients_list_state.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_client_type_model.dart';

class CrmDashboardOption {
  final String label;
  final String value;

  const CrmDashboardOption({
    required this.label,
    required this.value,
  });
}

class CrmDashboardSlice {
  final String label;
  final double value;

  const CrmDashboardSlice({
    required this.label,
    required this.value,
  });
}

class CrmDashboardKpiData {
  final int totalClients;
  final int companies;
  final int governments;
  final int persons;

  const CrmDashboardKpiData({
    required this.totalClients,
    required this.companies,
    required this.governments,
    required this.persons,
  });
}

class CrmDashboardDonutChartData {
  final String title;
  final List<CrmDashboardSlice> slices;

  const CrmDashboardDonutChartData({
    required this.title,
    required this.slices,
  });
}

class CrmDashboardGroupedChartData {
  final String title;
  final List<String> seriesLabels;
  final List<String> groupLabels;
  final List<List<double>> groupValues;

  const CrmDashboardGroupedChartData({
    required this.title,
    required this.seriesLabels,
    required this.groupLabels,
    required this.groupValues,
  });
}

class CrmDashboardHorizontalChartData {
  final String title;
  final List<CrmDashboardSlice> bars;

  const CrmDashboardHorizontalChartData({
    required this.title,
    required this.bars,
  });
}

class CrmDashboardFilterOptions {
  final List<CrmDashboardOption> cities;
  final List<CrmDashboardOption> countries;
  final List<CrmDashboardOption> statuses;
  final List<CrmDashboardOption> clientTypes;

  const CrmDashboardFilterOptions({
    required this.cities,
    required this.countries,
    required this.statuses,
    required this.clientTypes,
  });
}

class CrmClientsDashboardViewData {
  final CrmDashboardKpiData kpi;
  final CrmDashboardFilterOptions filterOptions;
  final List<CrmDashboardDonutChartData> donutCharts;
  final CrmDashboardGroupedChartData clientStatusChart;
  final List<CrmDashboardHorizontalChartData> horizontalCharts;

  const CrmClientsDashboardViewData({
    required this.kpi,
    required this.filterOptions,
    required this.donutCharts,
    required this.clientStatusChart,
    required this.horizontalCharts,
  });
}

abstract class CrmClientsDashboardViewDataBuilder {
  static CrmClientsDashboardViewData fromState(CrmClientsListState state) {
    final List<CrmClientRecordModel> activeRecords = state.records
        .where((CrmClientRecordModel record) => !_isDeleted(record))
        .toList();
    final List<CrmClientRecordModel> filteredRecords =
        _applyDashboardFilters(activeRecords, state);

    return CrmClientsDashboardViewData(
      kpi: CrmDashboardKpiData(
        totalClients: filteredRecords.length,
        companies: _countByType(filteredRecords, state.clientTypes, 'company'),
        governments:
            _countByType(filteredRecords, state.clientTypes, 'government'),
        persons: _countByType(filteredRecords, state.clientTypes, 'person'),
      ),
      filterOptions: CrmDashboardFilterOptions(
        cities: _optionsFromValues(activeRecords, const <String>['city']),
        countries: _optionsFromValues(activeRecords, const <String>['country']),
        statuses: _statusOptions(activeRecords),
        clientTypes: _clientTypeOptions(state.clientTypes),
      ),
      donutCharts: <CrmDashboardDonutChartData>[
        CrmDashboardDonutChartData(
          title: 'Sector',
          slices: _countValues(filteredRecords, const <String>['sector']),
        ),
        CrmDashboardDonutChartData(
          title: 'Industry',
          slices: _countValues(
            filteredRecords,
            const <String>['industry', 'sub_sector', 'subsector'],
          ),
        ),
        CrmDashboardDonutChartData(
          title: 'Preferred Language',
          slices: _countValues(
            filteredRecords,
            const <String>['preferred_language', 'language'],
          ),
        ),
        CrmDashboardDonutChartData(
          title: 'Preferred Contact Channel',
          slices: _countValues(
            filteredRecords,
            const <String>['preferred_contact_channel', 'channel'],
          ),
        ),
        CrmDashboardDonutChartData(
          title: 'Country',
          slices: _countValues(filteredRecords, const <String>['country']),
        ),
        CrmDashboardDonutChartData(
          title: 'Commercial Title',
          slices: _countValues(
            filteredRecords,
            const <String>['commercial_title', 'job_title', 'title'],
          ),
        ),
        CrmDashboardDonutChartData(
          title: 'Owner Status',
          slices: _countStatuses(filteredRecords),
        ),
        CrmDashboardDonutChartData(
          title: 'Clients Type',
          slices: _countClientTypes(filteredRecords, state.clientTypes),
        ),
      ],
      clientStatusChart: _buildClientStatusChart(
        filteredRecords,
        state.clientTypes,
      ),
      horizontalCharts: <CrmDashboardHorizontalChartData>[
        CrmDashboardHorizontalChartData(
          title: 'Industry Distribution',
          bars: _countValues(
            filteredRecords,
            const <String>['industry', 'sub_sector', 'subsector'],
          ),
        ),
        CrmDashboardHorizontalChartData(
          title: 'Government Sector',
          bars: _countValues(
            _recordsForType(filteredRecords, state.clientTypes, 'government'),
            const <String>['sector', 'industry'],
          ),
        ),
        CrmDashboardHorizontalChartData(
          title: 'Company Size',
          bars: _countValues(
            filteredRecords,
            const <String>['company_size', 'size'],
          ),
        ),
      ],
    );
  }

  static List<CrmClientRecordModel> _applyDashboardFilters(
    List<CrmClientRecordModel> records,
    CrmClientsListState state,
  ) {
    return records.where((CrmClientRecordModel record) {
      if (state.dashboardCity.isNotEmpty &&
          !_matchesAnyValue(
              record, const <String>['city'], state.dashboardCity)) {
        return false;
      }
      if (state.dashboardCountry.isNotEmpty &&
          !_matchesAnyValue(
            record,
            const <String>['country'],
            state.dashboardCountry,
          )) {
        return false;
      }
      if (state.dashboardStatus.isNotEmpty &&
          _normalizeStatus(record.status) !=
              _normalizeStatus(state.dashboardStatus)) {
        return false;
      }
      if (state.dashboardClientTypeId.isNotEmpty &&
          record.clientTypeId != state.dashboardClientTypeId) {
        return false;
      }
      if (!_matchesDateRange(
        record,
        state.dashboardStartDate,
        state.dashboardEndDate,
      )) {
        return false;
      }
      return true;
    }).toList();
  }

  static bool _matchesDateRange(
    CrmClientRecordModel record,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    if (startDate == null && endDate == null) return true;
    final DateTime createdAt = record.audit.createdAt;
    if (startDate != null && createdAt.isBefore(_startOfDay(startDate))) {
      return false;
    }
    if (endDate != null && createdAt.isAfter(_endOfDay(endDate))) {
      return false;
    }
    return true;
  }

  static bool _matchesAnyValue(
    CrmClientRecordModel record,
    List<String> keys,
    String expected,
  ) {
    final String normalizedExpected = _normalizeValue(expected);
    for (final String value in _valuesForKeys(record, keys)) {
      if (_normalizeValue(value) == normalizedExpected) {
        return true;
      }
    }
    return false;
  }

  static List<CrmDashboardOption> _optionsFromValues(
    List<CrmClientRecordModel> records,
    List<String> keys,
  ) {
    final Map<String, String> unique = <String, String>{};
    for (final CrmClientRecordModel record in records) {
      for (final String value in _valuesForKeys(record, keys)) {
        final String normalized = _normalizeValue(value);
        if (normalized.isEmpty) continue;
        unique.putIfAbsent(normalized, () => value.trim());
      }
    }
    final List<String> labels = unique.values.toList()..sort();
    return <CrmDashboardOption>[
      const CrmDashboardOption(label: 'All', value: ''),
      ...labels.map(
        (String label) => CrmDashboardOption(label: label, value: label),
      ),
    ];
  }

  static List<CrmDashboardOption> _statusOptions(
    List<CrmClientRecordModel> records,
  ) {
    final Map<String, String> unique = <String, String>{};
    for (final CrmClientRecordModel record in records) {
      final String status = _normalizeStatus(record.status);
      if (status.isEmpty) continue;
      unique.putIfAbsent(status, () => _titleCase(status));
    }
    final List<String> labels = unique.values.toList()..sort();
    return <CrmDashboardOption>[
      const CrmDashboardOption(label: 'All', value: ''),
      ...labels.map(
        (String label) => CrmDashboardOption(label: label, value: label),
      ),
    ];
  }

  static List<CrmDashboardOption> _clientTypeOptions(
    List<CrmClientTypeModel> clientTypes,
  ) {
    final List<CrmClientTypeModel> activeTypes = clientTypes
        .where((CrmClientTypeModel type) => !type.isDeleted && type.isActive)
        .toList()
      ..sort((CrmClientTypeModel a, CrmClientTypeModel b) {
        return a.nameEn.compareTo(b.nameEn);
      });
    return <CrmDashboardOption>[
      const CrmDashboardOption(label: 'All', value: ''),
      ...activeTypes.map(
        (CrmClientTypeModel type) => CrmDashboardOption(
          label: _typeLabel(type),
          value: type.id,
        ),
      ),
    ];
  }

  static List<CrmDashboardSlice> _countValues(
    List<CrmClientRecordModel> records,
    List<String> keys, {
    int limit = 4,
  }) {
    final Map<String, double> counts = <String, double>{};
    for (final CrmClientRecordModel record in records) {
      for (final String value in _valuesForKeys(record, keys)) {
        final String cleaned = value.trim();
        if (cleaned.isEmpty) continue;
        counts.update(cleaned, (double current) => current + 1,
            ifAbsent: () => 1);
      }
    }
    return _sortedSlices(counts, limit: limit);
  }

  static List<CrmDashboardSlice> _countStatuses(
    List<CrmClientRecordModel> records,
  ) {
    final Map<String, double> counts = <String, double>{};
    for (final CrmClientRecordModel record in records) {
      final String status = _normalizeStatus(record.status);
      if (status.isEmpty) continue;
      final String label = _titleCase(status);
      counts.update(label, (double current) => current + 1, ifAbsent: () => 1);
    }
    return _sortedSlices(counts, limit: 4);
  }

  static List<CrmDashboardSlice> _countClientTypes(
    List<CrmClientRecordModel> records,
    List<CrmClientTypeModel> clientTypes,
  ) {
    final Map<String, double> counts = <String, double>{};
    for (final CrmClientRecordModel record in records) {
      final CrmClientTypeModel? type = _clientTypeFor(record, clientTypes);
      final String label = type == null ? 'Unknown' : _typeLabel(type);
      counts.update(label, (double current) => current + 1, ifAbsent: () => 1);
    }
    return _sortedSlices(counts, limit: 4);
  }

  static CrmDashboardGroupedChartData _buildClientStatusChart(
    List<CrmClientRecordModel> records,
    List<CrmClientTypeModel> clientTypes,
  ) {
    const List<String> seriesLabels = <String>[
      'Active',
      'Inactive',
      'Prospect',
      'Archived',
    ];
    final List<CrmClientTypeModel> targetTypes = <CrmClientTypeModel>[
      ...clientTypes.where(
        (CrmClientTypeModel type) =>
            _normalizeValue(type.systemKey ?? '') == 'company',
      ),
      ...clientTypes.where(
        (CrmClientTypeModel type) =>
            _normalizeValue(type.systemKey ?? '') == 'government',
      ),
      ...clientTypes.where(
        (CrmClientTypeModel type) =>
            _normalizeValue(type.systemKey ?? '') == 'person',
      ),
    ];

    final List<String> groupLabels = targetTypes.isNotEmpty
        ? targetTypes.map(_typeLabel).toList()
        : const <String>['Company', 'Government', 'Person'];
    final List<List<double>> groupValues = <List<double>>[];

    for (final String groupLabel in groupLabels) {
      final List<CrmClientRecordModel> groupRecords = records.where(
        (CrmClientRecordModel record) {
          final CrmClientTypeModel? type = _clientTypeFor(record, clientTypes);
          return (type == null ? 'Unknown' : _typeLabel(type)) == groupLabel;
        },
      ).toList();

      groupValues.add(
        seriesLabels.map((String statusLabel) {
          return groupRecords
              .where(
                (CrmClientRecordModel record) =>
                    _normalizeStatus(record.status) ==
                    _normalizeStatus(statusLabel),
              )
              .length
              .toDouble();
        }).toList(),
      );
    }

    return CrmDashboardGroupedChartData(
      title: 'Clients Status',
      seriesLabels: seriesLabels,
      groupLabels: groupLabels,
      groupValues: groupValues,
    );
  }

  static List<CrmClientRecordModel> _recordsForType(
    List<CrmClientRecordModel> records,
    List<CrmClientTypeModel> clientTypes,
    String typeKey,
  ) {
    return records.where((CrmClientRecordModel record) {
      final CrmClientTypeModel? type = _clientTypeFor(record, clientTypes);
      final String normalizedType =
          _normalizeValue(type?.systemKey ?? type?.nameEn ?? '');
      return normalizedType == _normalizeValue(typeKey);
    }).toList();
  }

  static int _countByType(
    List<CrmClientRecordModel> records,
    List<CrmClientTypeModel> clientTypes,
    String typeKey,
  ) {
    return _recordsForType(records, clientTypes, typeKey).length;
  }

  static CrmClientTypeModel? _clientTypeFor(
    CrmClientRecordModel record,
    List<CrmClientTypeModel> clientTypes,
  ) {
    for (final CrmClientTypeModel type in clientTypes) {
      if (type.id == record.clientTypeId) return type;
    }
    return null;
  }

  static List<String> _valuesForKeys(
    CrmClientRecordModel record,
    List<String> keys,
  ) {
    for (final String key in keys) {
      final List<String> exactValues = _normalizeDynamicValue(
        record.valueFor(null, key),
      );
      if (exactValues.isNotEmpty) return exactValues;
    }

    for (final MapEntry<String, dynamic> entry in record.values.entries) {
      final String normalizedEntryKey = _normalizeValue(entry.key);
      for (final String key in keys) {
        final String normalizedKey = _normalizeValue(key);
        if (normalizedEntryKey.contains(normalizedKey)) {
          final List<String> fallbackValues =
              _normalizeDynamicValue(entry.value);
          if (fallbackValues.isNotEmpty) return fallbackValues;
        }
      }
    }
    return const <String>[];
  }

  static List<String> _normalizeDynamicValue(dynamic value) {
    if (value == null) return const <String>[];
    if (value is List) {
      final List<String> items = <String>[];
      for (final dynamic item in value) {
        final String text = item.toString().trim();
        if (text.isNotEmpty) items.add(text);
      }
      return items;
    }
    if (value is Map) {
      final List<String> items = <String>[];
      for (final dynamic item in value.values) {
        final String text = item.toString().trim();
        if (text.isNotEmpty) items.add(text);
      }
      return items;
    }
    final String text = value.toString().trim();
    return text.isEmpty ? const <String>[] : <String>[text];
  }

  static List<CrmDashboardSlice> _sortedSlices(
    Map<String, double> counts, {
    required int limit,
  }) {
    final List<CrmDashboardSlice> slices = counts.entries
        .map(
          (MapEntry<String, double> entry) => CrmDashboardSlice(
            label: entry.key,
            value: entry.value,
          ),
        )
        .toList()
      ..sort((CrmDashboardSlice a, CrmDashboardSlice b) {
        final int byValue = b.value.compareTo(a.value);
        return byValue != 0 ? byValue : a.label.compareTo(b.label);
      });
    if (slices.length <= limit) return slices;
    return slices.take(limit).toList();
  }

  static bool _isDeleted(CrmClientRecordModel record) {
    return _normalizeStatus(record.status) == 'deleted';
  }

  static String _normalizeStatus(String? value) {
    final String normalized = _normalizeValue(value ?? '');
    return normalized.isEmpty ? 'active' : normalized;
  }

  static String _normalizeValue(String value) {
    return value.trim().toLowerCase().replaceAll(' ', '_');
  }

  static String _typeLabel(CrmClientTypeModel type) {
    if (type.nameEn.trim().isNotEmpty) return type.nameEn.trim();
    if (type.title.trim().isNotEmpty) return type.title.trim();
    return 'Unknown';
  }

  static String _titleCase(String value) {
    if (value.isEmpty) return value;
    final List<String> parts = value.replaceAll('_', ' ').split(' ');
    return parts
        .where((String part) => part.trim().isNotEmpty)
        .map(
          (String part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  static DateTime _startOfDay(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  static DateTime _endOfDay(DateTime value) {
    return DateTime(value.year, value.month, value.day, 23, 59, 59, 999);
  }
}
