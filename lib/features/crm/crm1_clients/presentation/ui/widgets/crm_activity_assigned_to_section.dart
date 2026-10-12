// ****************** FILE INFO ******************
// File Name: crm_activity_assigned_to_section.dart
// Purpose: Assigned To employee selection section with search, filter, sort, and cards grid
// Author: Mohand Adel
// Created At: 26/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/69-cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/custom/98-custom_search_filter_sort_bar.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/domain/crm_employee_filter_helper.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_related_entity_card.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_relationship_champion_entity_card.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmActivityAssignedToSection extends StatefulWidget {
  final List<EmployeeEntityPro> allEmployees;
  final EmployeeEntityPro? selectedEmployee;
  final ValueChanged<EmployeeEntityPro?> onEmployeeSelected;
  final TextEditingController searchController;
  final bool isReadOnly;
  final bool isSubmitted;

  const CrmActivityAssignedToSection({
    super.key,
    required this.allEmployees,
    required this.selectedEmployee,
    required this.onEmployeeSelected,
    required this.searchController,
    required this.isReadOnly,
    required this.isSubmitted,
  });

  @override
  State<CrmActivityAssignedToSection> createState() =>
      _CrmActivityAssignedToSectionState();
}

class _CrmActivityAssignedToSectionState
    extends State<CrmActivityAssignedToSection> {
  String _searchQuery = '';
  String? _selectedFilter;
  String? _selectedSort;

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.searchController.text;
    widget.searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    widget.searchController.removeListener(_onSearchChanged);
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() => _searchQuery = widget.searchController.text);
  }

  List<EmployeeEntityPro> get _filteredAndSortedEmployees {
    final List<EmployeeEntityPro> all = widget.allEmployees;
    final String cleanQuery = _searchQuery.trim().toLowerCase();

    List<EmployeeEntityPro> list = all;

    if (_selectedFilter == 'management') {
      list = CrmEmployeeFilterHelper.filterManagementEmployees(list);
    }

    if (cleanQuery.isNotEmpty) {
      list = list.where((EmployeeEntityPro emp) {
        final String fullName =
            '${emp.firstName ?? ''} ${emp.middleName ?? ''} ${emp.lastName ?? ''}'
                .toLowerCase();
        final String fullNameAr =
            '${emp.firstNameInArabic ?? ''} ${emp.middleNameInArabic ?? ''} ${emp.lastNameInArabic ?? ''}'
                .toLowerCase();
        final String title = (emp.title ?? '').toLowerCase();
        final String titleAr = (emp.titleInArabic ?? '').toLowerCase();
        final String role = (emp.role ?? '').toLowerCase();
        final String email = (emp.email ?? '').toLowerCase();
        final String phone = (emp.mobilePhone?.number ?? '').toLowerCase();
        final String officePhone = (emp.officePhone ?? '').toLowerCase();
        final String department = (emp.departmentId ?? '').toLowerCase();

        return fullName.contains(cleanQuery) ||
            fullNameAr.contains(cleanQuery) ||
            title.contains(cleanQuery) ||
            titleAr.contains(cleanQuery) ||
            role.contains(cleanQuery) ||
            email.contains(cleanQuery) ||
            phone.contains(cleanQuery) ||
            officePhone.contains(cleanQuery) ||
            department.contains(cleanQuery);
      }).toList();
    }

    if (_selectedSort != null) {
      final List<EmployeeEntityPro> sorted = List<EmployeeEntityPro>.from(list);
      switch (_selectedSort) {
        case 'name_asc':
          sorted.sort((a, b) => ('${a.firstName ?? ''} ${a.lastName ?? ''}')
              .compareTo('${b.firstName ?? ''} ${b.lastName ?? ''}'));
          break;
        case 'name_desc':
          sorted.sort((a, b) => ('${b.firstName ?? ''} ${b.lastName ?? ''}')
              .compareTo('${a.firstName ?? ''} ${a.lastName ?? ''}'));
          break;
        case 'title_asc':
          sorted.sort((a, b) =>
              (a.title ?? a.role ?? '').compareTo(b.title ?? b.role ?? ''));
          break;
        case 'title_desc':
          sorted.sort((a, b) =>
              (b.title ?? b.role ?? '').compareTo(a.title ?? a.role ?? ''));
          break;
      }
      return sorted;
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final String? entityError =
        widget.isSubmitted && widget.selectedEmployee == null
            ? 'Field Required'
            : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          FormatHelper.localizedString(
            englishName: 'Assigned To',
            arabicName: 'المعين له',
          ),
          style: StyleText.fontSize14Weight400.copyWith(
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 8.sp),
        if (widget.isReadOnly && widget.selectedEmployee != null)
          CrmRelationshipChampionEntityCard.fromEmployee(
              widget.selectedEmployee!)
        else ...<Widget>[
          CustomSearchFilterSortBar<String, String>(
            searchController: widget.searchController,
            onSearchChanged: (String v) => setState(() => _searchQuery = v),
            searchHint: S.current.crmSearch,
            showFilter: true,
            filterTitle: S.current.crmFilter,
            filterItems: const <String>['all', 'management'],
            selectedFilter: _selectedFilter,
            filterLabelBuilder: (String option) {
              switch (option) {
                case 'management':
                  return FormatHelper.localizedString(
                    englishName: 'Management',
                    arabicName: 'الإدارة',
                  );
                case 'all':
                default:
                  return FormatHelper.localizedString(
                    englishName: 'All',
                    arabicName: 'الكل',
                  );
              }
            },
            onFilterChanged: (String? filter) {
              setState(() => _selectedFilter = filter);
            },
            showSort: true,
            selectedSort: _selectedSort,
            sortTitle: S.current.crmSort,
            sortItems: const <String>[
              'name_asc',
              'name_desc',
              'title_asc',
              'title_desc',
            ],
            sortLabelBuilder: (String option) {
              switch (option) {
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
                case 'title_asc':
                  return FormatHelper.localizedString(
                    englishName: 'Title (A-Z)',
                    arabicName: 'المسمى (أ-ي)',
                  );
                case 'title_desc':
                  return FormatHelper.localizedString(
                    englishName: 'Title (Z-A)',
                    arabicName: 'المسمى (ي-أ)',
                  );
                default:
                  return option;
              }
            },
            onSortChanged: (String? sort) {
              setState(() => _selectedSort = sort);
            },
            fillColor: const Color(0xFFF8F8F8),
            height: 38.sp,
            mobileBreakpoint: 0,
          ),
          if (entityError != null) ...<Widget>[
            SizedBox(height: 4.sp),
            Text(
              entityError,
              style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.red,
                fontSize: 12.sp,
              ),
            ),
          ],
          SizedBox(height: 8.sp),
          _buildGrid(context),
        ],
      ],
    );
  }

  Widget _buildGrid(BuildContext context) {
    final List<EmployeeEntityPro> employees = _filteredAndSortedEmployees;

    if (employees.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.sp),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(8.sp),
        ),
        alignment: Alignment.center,
        child: Text(
          FormatHelper.localizedString(
            englishName: 'No employees found',
            arabicName: 'لم يتم العثور على موظفين',
          ),
          style: StyleText.fontSize12Weight400.copyWith(
            color: AppColors.darkGrey,
          ),
        ),
      );
    }

    final int crossAxisCount =
        CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: employees.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisExtent: 64.sp,
        crossAxisSpacing: 8.sp,
        mainAxisSpacing: 8.sp,
      ),
      itemBuilder: (BuildContext ctx, int i) {
        final EmployeeEntityPro emp = employees[i];
        final bool isSelected = widget.selectedEmployee?.id == emp.id;
        return CrmRelatedEntityCard(
          employee: emp,
          isSelected: isSelected,
          onTap: () => widget.onEmployeeSelected(emp),
        );
      },
    );
  }
}
