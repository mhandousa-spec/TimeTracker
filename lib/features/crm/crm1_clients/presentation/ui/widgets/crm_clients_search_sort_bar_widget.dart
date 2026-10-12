// ****************** FILE INFO ******************
// File Name: crm_clients_search_sort_bar_widget.dart
// Purpose: CRM clients adapter for the isolated search, filter, and sort toolbar
// Author: Mohand Adel
// Created At: 08/08/2026

import 'package:knowticed_plus/core/custom/98-custom_search_filter_sort_bar.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter/material.dart';

/// CRM clients configuration for [CustomSearchFilterSortBar].
class CrmClientsSearchSortBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String? selectedSortOption;
  final ValueChanged<String?>? onSortChanged;
  final VoidCallback? onFilterTap;
  final bool showFilterButton;

  const CrmClientsSearchSortBarWidget({
    super.key,
    required this.controller,
    this.onChanged,
    this.selectedSortOption,
    this.onSortChanged,
    this.onFilterTap,
    this.showFilterButton = true,
  });

  String _getSortLabel(String option) {
    switch (option) {
      case 'date_desc':
        return S.current.crmSortNewest;
      case 'date_asc':
        return S.current.crmSortOldest;
      case 'name_asc':
        return S.current.crmSortNameAsc;
      case 'name_desc':
        return S.current.crmSortNameDesc;
      default:
        return option;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomSearchFilterSortBar<Object?, String>(
      searchController: controller,
      onSearchChanged: onChanged,
      searchHint: S.current.search,
      showFilter: showFilterButton,
      filterTitle: S.current.crmFilter,
      onFilterTap: onFilterTap,
      showSort: true,
      selectedSort: selectedSortOption,
      sortTitle: S.current.crmSort,
      sortItems: const <String>[
        'date_desc',
        'date_asc',
        'name_asc',
        'name_desc',
      ],
      sortLabelBuilder: _getSortLabel,
      onSortChanged: onSortChanged,
      mobileBreakpoint: 0,
    );
  }
}
