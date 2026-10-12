// ****************** FILE INFO ******************
// File Name: crm_client_relationship_map_tab.dart
// Purpose: Relationship Map tab displaying interactive organizational hierarchy tree diagram
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_record_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_relationship_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/controller/crm_client_relationship_cubit.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/controller/crm_client_relationship_state.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/pages/crm_client_add_relationship_page.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_relationship_tree_canvas.dart';
import 'package:knowticed_plus/features/crm/crm3_relationship/data/models/crm_relationship_category_model.dart';

class CrmClientRelationshipMapTab extends StatefulWidget {
  final CrmClientRecordModel record;

  const CrmClientRelationshipMapTab({
    super.key,
    required this.record,
  });

  @override
  State<CrmClientRelationshipMapTab> createState() =>
      _CrmClientRelationshipMapTabState();
}

class _CrmClientRelationshipMapTabState
    extends State<CrmClientRelationshipMapTab> {
  late final CrmClientRelationshipCubit _cubit;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _cubit = CrmClientRelationshipCubit(clientId: widget.record.id);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child:
          BlocBuilder<CrmClientRelationshipCubit, CrmClientRelationshipState>(
        builder: (context, state) {
          if (state.isLoading && state.relationships.isEmpty) {
            return Container(
              width: double.infinity,
              height: 250.sp,
              alignment: Alignment.center,
              child: const CircleProgressMaster(),
            );
          }

          final List<CrmClientRelationshipModel> relationships =
              _filterRelationships(state.relationships);

          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.sp),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(10.sp),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Top Bar: Category Dropdown
                _buildCategoryFilter(state.categories),
                SizedBox(height: 20.sp),

                // Main Tree Map Content
                if (relationships.isEmpty)
                  _buildEmptyState()
                else
                  Center(
                    child: CrmRelationshipTreeCanvas(
                      relationships: relationships,
                      onNodeTap: _onNodeTap,
                    ),
                  ),
                SizedBox(height: 24.sp),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryFilter(List<CrmRelationshipCategoryModel> categories) {
    final List<DropdownItem<String>> items = <DropdownItem<String>>[
      DropdownItem<String>(
        value: 'all',
        label: FormatHelper.localizedString(
          englishName: 'All Categories',
          arabicName: 'جميع الفئات',
        ),
      ),
      ...categories.map(
        (CrmRelationshipCategoryModel cat) => DropdownItem<String>(
          value: cat.id,
          label: cat.nameEn.isNotEmpty ? cat.nameEn : cat.nameAr,
        ),
      ),
    ];

    return SizedBox(
      width: 160.sp,
      child: CustomDropdown<String>(
        hint: FormatHelper.localizedString(
          englishName: 'Category',
          arabicName: 'الفئة',
        ),
        value: _selectedCategoryId ?? 'all',
        items: items,
        onChanged: (String? value) {
          setState(() {
            _selectedCategoryId = value == 'all' ? null : value;
          });
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 48.sp, horizontal: 16.sp),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.account_tree_outlined,
            size: 48.sp,
            color: AppColors.darkGrey,
          ),
          SizedBox(height: 12.sp),
          Text(
            FormatHelper.localizedString(
              englishName: 'No Relationship Hierarchy Found',
              arabicName: 'لا توجد خريطة علاقات مسجلة',
            ),
            style: StyleText.fontSize16Weight600.copyWith(
              color: AppColors.darkGrey,
            ),
          ),
          SizedBox(height: 6.sp),
          Text(
            FormatHelper.localizedString(
              englishName:
                  'Add client relationships to view the hierarchy map.',
              arabicName: 'أضف علاقات للعميل لعرض خريطة الهيكل التنظيمي.',
            ),
            style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.darkGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<CrmClientRelationshipModel> _filterRelationships(
      List<CrmClientRelationshipModel> all) {
    if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) {
      return all;
    }
    return all.where((rel) => rel.categoryId == _selectedCategoryId).toList();
  }

  void _onNodeTap(CrmClientRelationshipModel relationship) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CrmClientAddRelationshipPage(
          clientId: widget.record.id,
          existingRelationship: relationship,
          mode: 'view',
        ),
      ),
    );
  }
}
