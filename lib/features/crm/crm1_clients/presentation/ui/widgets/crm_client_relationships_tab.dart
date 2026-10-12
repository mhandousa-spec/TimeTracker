// ****************** FILE INFO ******************
// File Name: crm_client_relationships_tab.dart
// Purpose: Main Relationships tab view under Client Profile displaying client relationships
// Author: Mohand Adel
// Created At: 26/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/8-custom_filter_app.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/custom/69-cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_record_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_relationship_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/controller/crm_client_relationship_cubit.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/controller/crm_client_relationship_state.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/pages/crm_client_add_relationship_page.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_client_relationship_card.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_client_relationships_header_widget.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_client_relationships_table_widget.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmClientRelationshipsTab extends StatefulWidget {
  final CrmClientRecordModel record;

  const CrmClientRelationshipsTab({
    super.key,
    required this.record,
  });

  @override
  State<CrmClientRelationshipsTab> createState() =>
      _CrmClientRelationshipsTabState();
}

class _CrmClientRelationshipsTabState extends State<CrmClientRelationshipsTab> {
  late final CrmClientRelationshipCubit _cubit;
  final TextEditingController _searchController = TextEditingController();
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _cubit = CrmClientRelationshipCubit(clientId: widget.record.id);
  }

  @override
  void dispose() {
    _searchController.dispose();
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
              height: 200.sp,
              alignment: Alignment.center,
              child: const CircleProgressMaster(),
            );
          }

          final List<CrmClientRelationshipModel> filteredList =
              state.visibleRelationships;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CrmClientRelationshipsHeaderWidget(
                statusItems: _statusItems(state),
                selectedStatus: state.relationshipStatusFilter,
                onStatusChanged: _cubit.setRelationshipStatusFilter,
                searchController: _searchController,
                onSearchChanged: _cubit.searchRelationships,
                categoryFilters: state.relationshipCategoryFilters,
                selectedCategoryFilter: state.relationshipCategoryFilter,
                onCategoryFilterChanged: _cubit.setRelationshipCategoryFilter,
                selectedSort: state.relationshipSort,
                onSortChanged: _cubit.setRelationshipSort,
                onAddTap: _onAddRelationship,
                onExportTap: _onExportRelationships,
                isGridView: _isGridView,
                onGridTap: () => setState(() => _isGridView = true),
                onTableTap: () => setState(() => _isGridView = false),
              ),
              SizedBox(height: 16.sp),

              // Relationships Content
              if (filteredList.isEmpty)
                _buildEmptyState()
              else if (_isGridView)
                _buildRelationshipsGrid(filteredList)
              else
                _buildRelationshipsTable(filteredList),
            ],
          );
        },
      ),
    );
  }

  List<StatusChipItem> _statusItems(CrmClientRelationshipState state) {
    return <StatusChipItem>[
      StatusChipItem(
        key: 'all',
        label: S.current.crmAll,
        count: state.relationshipTotalCount,
      ),
      StatusChipItem(
        key: 'active',
        label: S.current.crmActive,
        count: state.relationshipActiveCount,
        labelColor: AppColors.green,
      ),
      StatusChipItem(
        key: 'inactive',
        label: S.current.crmInactive,
        count: state.relationshipInactiveCount,
        labelColor: AppColors.orange,
      ),
    ];
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 48.sp, horizontal: 16.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10.sp),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomSvgImage(
            assetPath: AppAssets.crmPerson,
            width: 80.sp,
            height: 80.sp,
          ),
          SizedBox(height: 16.sp),
          Text(
            FormatHelper.localizedString(
              englishName: 'No Relationships Found',
              arabicName: 'لا توجد علاقات مسجلة',
            ),
            style: StyleText.fontSize16Weight600.copyWith(
              color: AppColors.darkGrey,
            ),
          ),
          SizedBox(height: 8.sp),
          Text(
            FormatHelper.localizedString(
              englishName:
                  'Click "Add Relationship" to link employees or entities to this client.',
              arabicName:
                  'اضغط على "إضافة علاقة" لربط الموظفين أو الجهات بهذا العميل.',
            ),
            style: StyleText.fontSize12Weight600.copyWith(color: AppColors.darkGrey).copyWith(
              color: AppColors.darkGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRelationshipsGrid(
      List<CrmClientRelationshipModel> relationships) {
    final double pageWidth = MediaQuery.sizeOf(context).width;
    final int crossAxisCount = pageWidth >= 500.sp
        ? 2
        : CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: relationships.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisExtent: 128.sp,
        crossAxisSpacing: 12.sp,
        mainAxisSpacing: 12.sp,
      ),
      itemBuilder: (context, index) {
        final CrmClientRelationshipModel relationship = relationships[index];
        return CrmClientRelationshipCard(
          relationship: relationship,
          onTap: () => _onViewRelationship(relationship),
          onEdit: () => _onEditRelationship(relationship),
          onDelete: () => _onDeleteRelationship(relationship),
        );
      },
    );
  }

  Widget _buildRelationshipsTable(
      List<CrmClientRelationshipModel> relationships) {
    return CrmClientRelationshipsTableWidget(
      relationships: relationships,
      onTap: _onViewRelationship,
      onEdit: _onEditRelationship,
      onDelete: _onDeleteRelationship,
    );
  }

  Future<void> _onAddRelationship() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CrmClientAddRelationshipPage(
          clientId: widget.record.id,
          mode: 'add',
        ),
      ),
    );
  }

  void _onExportRelationships() {
    CrmControlDialogs.showSuccessDialog(
      context: context,
      title: S.current.crmExport,
      subtitle: S.current.crmExportComingSoon,
    );
  }

  Future<void> _onViewRelationship(
      CrmClientRelationshipModel relationship) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CrmClientAddRelationshipPage(
          clientId: widget.record.id,
          existingRelationship: relationship,
          mode: 'view',
        ),
      ),
    );
  }

  Future<void> _onEditRelationship(
      CrmClientRelationshipModel relationship) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CrmClientAddRelationshipPage(
          clientId: widget.record.id,
          existingRelationship: relationship,
          mode: 'edit',
        ),
      ),
    );
  }

  void _onDeleteRelationship(CrmClientRelationshipModel relationship) {
    CrmControlDialogs.showRemoveDialog(
      context: context,
      title: FormatHelper.localizedString(
        englishName: 'Delete Relationship',
        arabicName: 'حذف العلاقة',
      ),
      subtitle: FormatHelper.localizedString(
        englishName:
            'Are you sure you want to delete the relationship with "${relationship.relatedEntityName}"?',
        arabicName:
            'هل أنت متأكد من رغبتك في حذف العلاقة مع "${relationship.relatedEntityName}"؟',
      ),
      onConfirm: () async {
        final bool success = await _cubit.deleteRelationship(
          clientId: widget.record.id,
          relationshipId: relationship.id,
        );
        if (mounted && success) {
          CrmControlDialogs.showSuccessDialog(
            context: context,
            title: FormatHelper.localizedString(
              englishName: 'Success',
              arabicName: 'نجاح',
            ),
            subtitle: FormatHelper.localizedString(
              englishName: 'Relationship deleted successfully',
              arabicName: 'تم حذف العلاقة بنجاح',
            ),
          );
        }
      },
    );
  }
}
