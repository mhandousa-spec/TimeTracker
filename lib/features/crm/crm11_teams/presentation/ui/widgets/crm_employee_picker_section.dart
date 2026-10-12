// ****************** FILE INFO ******************
// File Name: crm_employee_picker_section.dart
// Purpose: Reusable employee picker section using the shared CustomSearchFilterSortBar
//          and a responsive 4-column card grid. Used for Team Manager and Team Members.
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/98-custom_search_filter_sort_bar.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/data/models/crm_team_member_model.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/presentation/ui/widgets/crm_employee_selection_card.dart';

/// A fully self-contained employee picker section.
///
/// Renders:
///  • Title label
///  • Standard [CustomSearchFilterSortBar] (Search + Filter dropdown + Sort dropdown)
///  • Responsive card grid (4 cols on wide screen, 3 on tablet, 2 on mobile)
///  • Optional red error text when [errorText] is set
class CrmEmployeePickerSection extends StatefulWidget {
  /// Section title displayed above the search bar.
  final String title;

  /// Full list of candidates to display.
  final List<CrmTeamMemberModel> employees;

  /// Returns true if a given employee is currently selected.
  final bool Function(CrmTeamMemberModel) isSelected;

  /// Called when the user taps a card.
  final void Function(CrmTeamMemberModel) onToggle;

  /// Validation error text shown below the grid.
  final String? errorText;

  const CrmEmployeePickerSection({
    super.key,
    required this.title,
    required this.employees,
    required this.isSelected,
    required this.onToggle,
    this.errorText,
  });

  @override
  State<CrmEmployeePickerSection> createState() =>
      _CrmEmployeePickerSectionState();
}

class _CrmEmployeePickerSectionState extends State<CrmEmployeePickerSection> {
  final TextEditingController _searchController = TextEditingController();

  String? _selectedFilter;
  String? _selectedSort;

  static const List<String> _sortItems = <String>[
    'name_asc',
    'name_desc',
  ];

  List<String> get _filterItems {
    final Set<String> deps = <String>{};
    for (final CrmTeamMemberModel e in widget.employees) {
      if (e.department.isNotEmpty) {
        deps.add(e.department);
      }
    }
    return <String>['All', ...deps];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CrmTeamMemberModel> get _filtered {
    final String q = _searchController.text.trim().toLowerCase();

    final List<CrmTeamMemberModel> list =
        widget.employees.where((CrmTeamMemberModel e) {
      // 1. Text search
      final bool matchesSearch = q.isEmpty ||
          e.name.toLowerCase().contains(q) ||
          e.role.toLowerCase().contains(q) ||
          e.department.toLowerCase().contains(q);

      // 2. Department filter
      final bool matchesFilter = _selectedFilter == null ||
          _selectedFilter!.isEmpty ||
          _selectedFilter == 'All' ||
          e.department.toLowerCase() == _selectedFilter!.toLowerCase();

      return matchesSearch && matchesFilter;
    }).toList();

    // 3. Sorting
    if (_selectedSort == 'name_asc') {
      list.sort((CrmTeamMemberModel a, CrmTeamMemberModel b) =>
          a.name.compareTo(b.name));
    } else if (_selectedSort == 'name_desc') {
      list.sort((CrmTeamMemberModel a, CrmTeamMemberModel b) =>
          b.name.compareTo(a.name));
    }

    return list;
  }

  int _crossAxisCount(BuildContext context) {
    if (context.isPhone) return 2;
    if (MediaQuery.of(context).size.width >= 900) return 4;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    final List<CrmTeamMemberModel> filtered = _filtered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // ── Title ──────────────────────────────────────────────────────────
        Text(
          widget.title,
          style: StyleText.fontSize14Weight400,
        ),
        SizedBox(height: 8.sp),

        // ── CustomSearchFilterSortBar ──────────────────────────────────────
        CustomSearchFilterSortBar<String, String>(
          searchController: _searchController,
          onSearchChanged: (String v) => setState(() {}),
          fillColor: AppColors.background,
          searchHint: FormatHelper.localizedString(
            englishName: 'Search',
            arabicName: 'بحث',
          ),
          showFilter: true,
          filterTitle: FormatHelper.localizedString(
            englishName: 'Filter',
            arabicName: 'تصفية',
          ),
          filterItems: _filterItems,
          selectedFilter: _selectedFilter,
          filterLabelBuilder: (String item) => item,
          onFilterChanged: (String? val) {
            setState(() => _selectedFilter = (val == 'All') ? null : val);
          },
          showSort: true,
          sortTitle: FormatHelper.localizedString(
            englishName: 'Sort',
            arabicName: 'ترتيب',
          ),
          sortItems: _sortItems,
          selectedSort: _selectedSort,
          sortLabelBuilder: (String item) {
            switch (item) {
              case 'name_asc':
                return FormatHelper.localizedString(
                  englishName: 'Name (A-Z)',
                  arabicName: 'الاسم (أ-ي)',
                );
              case 'name_desc':
                return FormatHelper.localizedString(
                  englishName: 'Name (Z-A)',
                  arabicName: 'الاسم (ي-أ)',
                );
              default:
                return item;
            }
          },
          onSortChanged: (String? val) {
            setState(() => _selectedSort = val);
          },
        ),
        SizedBox(height: 12.sp),

        // ── Grid of cards ──────────────────────────────────────────────────
        if (filtered.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.sp),
            child: Center(
              child: Text(
                FormatHelper.localizedString(
                  englishName: 'No employees found',
                  arabicName: 'لا يوجد موظفون',
                ),
                style: StyleText.fontSize14Weight400.copyWith(
                  color: AppColors.darkGrey,
                ),
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _crossAxisCount(context),
              mainAxisExtent: 58.sp,
              crossAxisSpacing: 10.sp,
              mainAxisSpacing: 10.sp,
            ),
            itemCount: filtered.length,
            itemBuilder: (BuildContext ctx, int i) {
              final CrmTeamMemberModel emp = filtered[i];
              return CrmEmployeeSelectionCard(
                employee: emp,
                isSelected: widget.isSelected(emp),
                onTap: () => widget.onToggle(emp),
              );
            },
          ),

        // ── Validation error ───────────────────────────────────────────────
        if (widget.errorText != null && widget.errorText!.isNotEmpty) ...<Widget>[
          SizedBox(height: 6.sp),
          Text(
            widget.errorText!,
            style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.red,
            ),
          ),
        ],
      ],
    );
  }
}
