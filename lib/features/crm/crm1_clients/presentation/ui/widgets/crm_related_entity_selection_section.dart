// ****************** FILE INFO ******************
// File Name: crm_related_entity_selection_section.dart
// Purpose: Related Entity selection section with search, filter/sort triggers and employee cards grid
// Author: Mohand Adel
// Created At: 26/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/98-custom_search_filter_sort_bar.dart';
import 'package:knowticed_plus/core/custom/69-cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_relationship_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/controller/crm_client_relationship_cubit.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/controller/crm_client_relationship_state.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_related_entity_card.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_relationship_champion_entity_card.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmRelatedEntitySelectionSection extends StatefulWidget {
  final CrmClientRelationshipState state;
  final CrmClientRelationshipCubit cubit;
  final TextEditingController searchController;
  final bool isReadOnly;
  final bool isSubmitted;
  final CrmClientRelationshipModel? existingRelationship;

  const CrmRelatedEntitySelectionSection({
    super.key,
    required this.state,
    required this.cubit,
    required this.searchController,
    required this.isReadOnly,
    required this.isSubmitted,
    this.existingRelationship,
  });

  @override
  State<CrmRelatedEntitySelectionSection> createState() =>
      _CrmRelatedEntitySelectionSectionState();
}

class _CrmRelatedEntitySelectionSectionState
    extends State<CrmRelatedEntitySelectionSection> {
  String? _selectedSort;

  @override
  Widget build(BuildContext context) {
    if (widget.isReadOnly && widget.existingRelationship != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            FormatHelper.localizedString(
              englishName: 'Related Entity',
              arabicName: 'الجهة المرتبطة',
            ),
            style: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 8.sp),
          CrmRelationshipChampionEntityCard.fromModel(
              widget.existingRelationship!),
        ],
      );
    }

    final String? entityError =
        widget.isSubmitted && widget.state.selectedEmployee == null
            ? 'Field Required'
            : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          FormatHelper.localizedString(
            englishName: 'Related Entity',
            arabicName: 'الجهة المرتبطة',
          ),
          style: StyleText.fontSize14Weight400.copyWith(
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 8.sp),

        // Search & Filter / Sort Toolbar using shared CustomSearchFilterSortBar
        CustomSearchFilterSortBar<String, String>(
          searchController: widget.searchController,
          onSearchChanged: widget.cubit.searchEmployees,
          searchHint: S.current.crmSearch,
          showFilter: true,
          filterTitle: S.current.crmFilter,
          onFilterTap: () {},
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
            widget.cubit.sortEmployees(sort);
          },
          fillColor: const Color(0xFFF8F8F8),
          height: 38.sp,
          mobileBreakpoint: 0,
        ),
        if (entityError != null) ...[
          SizedBox(height: 4.sp),
          Text(
            entityError,
            style: StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
          ),
        ],
        SizedBox(height: 12.sp),

        // Selectable Employee Grid
        _buildEmployeeGrid(context),
      ],
    );
  }

  Widget _buildEmployeeGrid(BuildContext context) {
    if (widget.state.filteredEmployees.isEmpty) {
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
            englishName: 'No management employees found',
            arabicName: 'لم يتم العثور على موظفين في الإدارة',
          ),
          style: StyleText.fontSize12Weight600.copyWith(color: AppColors.darkGrey).copyWith(
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
      itemCount: widget.state.filteredEmployees.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisExtent: 64.sp,
        crossAxisSpacing: 8.sp,
        mainAxisSpacing: 8.sp,
      ),
      itemBuilder: (context, index) {
        final EmployeeEntityPro emp = widget.state.filteredEmployees[index];
        final bool isSelected = widget.state.selectedEmployee?.id == emp.id;
        return CrmRelatedEntityCard(
          employee: emp,
          isSelected: isSelected,
          onTap: () => widget.cubit.selectEmployee(emp),
        );
      },
    );
  }
}
