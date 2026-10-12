// ****************** FILE INFO ******************
// File Name: crm_deal_overview_employee_picker.dart
// Purpose: CustomSearchFilterSortBar and responsive selectable employee grid for Deal Overview Edit mode matching Figma screenshot 2
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/98-custom_search_filter_sort_bar.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/data/models/crm_team_member_model.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/presentation/ui/widgets/crm_employee_selection_card.dart';

class CrmDealOverviewEmployeePicker extends StatelessWidget {
  final TextEditingController searchController;
  final List<CrmTeamMemberModel> employees;
  final CrmTeamMemberModel? selectedEmployee;
  final ValueChanged<CrmTeamMemberModel?> onEmployeeSelected;
  final VoidCallback onSearchChanged;

  const CrmDealOverviewEmployeePicker({
    super.key,
    required this.searchController,
    required this.employees,
    required this.selectedEmployee,
    required this.onEmployeeSelected,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final String query = searchController.text.trim().toLowerCase();
    final List<CrmTeamMemberModel> filtered =
        employees.where((CrmTeamMemberModel e) {
      return query.isEmpty ||
          e.name.toLowerCase().contains(query) ||
          e.role.toLowerCase().contains(query);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Search Toolbar via CustomSearchFilterSortBar
        CustomSearchFilterSortBar<String, String>(
          searchController: searchController,
          onSearchChanged: (_) => onSearchChanged(),
          searchHint: 'Search',
          showFilter: true,
          onFilterTap: () {},
          showSort: true,
          sortItems: const <String>['Name: A-Z', 'Name: Z-A', 'Role'],
          selectedSort: 'Name: A-Z',
          sortLabelBuilder: (String item) => item,
          onSortChanged: (String? sort) {},
          fillColor: AppColors.background,
        ),

        SizedBox(height: 12.sp),

        // Selectable Employee Grid
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final int crossAxisCount = constraints.maxWidth > 900
                ? 4
                : (constraints.maxWidth > 600 ? 3 : 2);

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisExtent: 64.sp,
                crossAxisSpacing: 10.sp,
                mainAxisSpacing: 10.sp,
              ),
              itemCount: filtered.length,
              itemBuilder: (BuildContext context, int index) {
                final CrmTeamMemberModel employee = filtered[index];
                final bool isSelected = selectedEmployee?.id == employee.id;

                return CrmEmployeeSelectionCard(
                  employee: employee,
                  isSelected: isSelected,
                  onTap: () {
                    if (isSelected) {
                      onEmployeeSelected(null);
                    } else {
                      onEmployeeSelected(employee);
                    }
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
