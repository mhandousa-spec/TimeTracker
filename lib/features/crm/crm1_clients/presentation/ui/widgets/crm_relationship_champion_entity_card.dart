// ****************** FILE INFO ******************
// File Name: crm_relationship_champion_entity_card.dart
// Purpose: Large champion summary card for related entity in view mode without forced text truncation
// Author: Mohand Adel
// Created At: 26/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_relationship_model.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_card_info_row.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';

class CrmRelationshipChampionEntityCard extends StatelessWidget {
  final String entityName;
  final String entityType;
  final String? entityRole;
  final String? entityAvatar;
  final String? entityPhone;
  final String? entityEmail;
  final String status;

  const CrmRelationshipChampionEntityCard({
    super.key,
    required this.entityName,
    this.entityType = 'Employee',
    this.entityRole,
    this.entityAvatar,
    this.entityPhone,
    this.entityEmail,
    this.status = 'active',
  });

  factory CrmRelationshipChampionEntityCard.fromModel(
      CrmClientRelationshipModel model) {
    return CrmRelationshipChampionEntityCard(
      entityName: model.relatedEntityName,
      entityType: model.relatedEntityType,
      entityRole: model.relatedEntityRole,
      entityAvatar: model.relatedEntityAvatar,
      entityPhone: model.relatedEntityPhone,
      entityEmail: model.relatedEntityEmail,
      status: model.status,
    );
  }

  factory CrmRelationshipChampionEntityCard.fromEmployee(
      EmployeeEntityPro employee) {
    final String fullName =
        '${employee.firstName ?? ''} ${employee.lastName ?? ''}'.trim();
    return CrmRelationshipChampionEntityCard(
      entityName: fullName.isNotEmpty ? fullName : (employee.email ?? ''),
      entityType: 'Employee',
      entityRole: employee.title ?? employee.role,
      entityAvatar: employee.photo,
      entityPhone: employee.mobilePhone?.number,
      entityEmail: employee.email,
      status: employee.status ?? 'active',
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = status.toLowerCase() == 'active';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.sp),
      ),
      child: Stack(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _buildAvatar(),
              SizedBox(width: 16.sp),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: 64.sp),
                      child: Text(
                        entityName,
                        style: StyleText.fontSize16Weight600.copyWith(
                          color: AppColors.text,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 10.sp),
                    _buildMetadataRow(),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: _buildStatusBadge(isActive),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (entityAvatar != null && entityAvatar!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(50.sp),
        child: Image.network(
          entityAvatar!,
          width: 64.sp,
          height: 64.sp,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallbackAvatar(),
        ),
      );
    }
    return _buildFallbackAvatar();
  }

  Widget _buildFallbackAvatar() {
    return Container(
      width: 64.sp,
      height: 64.sp,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: CustomSvgImage(
        assetPath: AppAssets.crmPerson,
        width: 28.sp,
        height: 28.sp,
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 2.sp),
      decoration: BoxDecoration(
        color: isActive ? AppColors.green : AppColors.grey,
        borderRadius: BorderRadius.circular(4.sp),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: StyleText.fontSize12Weight500.copyWith(color: AppColors.background).copyWith(
          fontSize: 10.sp,
        ),
      ),
    );
  }

  Widget _buildMetadataRow() {
    final bool isEmployee = entityType.toLowerCase() == 'employee';
    final String roleLabel = isEmployee ? 'Role:' : 'Industry:';

    final List<Widget> metadata = <Widget>[
      _buildMetadataItem(
        asset: AppAssets.crmClientsType,
        label: 'Type:',
        value: entityType,
      ),
      _buildMetadataItem(
        asset: AppAssets.crmIndustryField,
        label: roleLabel,
        value: entityRole?.isNotEmpty == true ? entityRole! : '-',
      ),
      _buildMetadataItem(
        asset: AppAssets.phone,
        label: 'Phone:',
        value: entityPhone?.isNotEmpty == true ? entityPhone! : '-',
      ),
      _buildMetadataItem(
        asset: AppAssets.email,
        label: 'Email:',
        value: entityEmail?.isNotEmpty == true ? entityEmail! : '-',
      ),
    ];

    return Wrap(
      spacing: 20.sp,
      runSpacing: 8.sp,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: metadata,
    );
  }

  Widget _buildMetadataItem({
    required String asset,
    required String label,
    required String value,
  }) {
    return CrmCardInfoItem(
      svgAsset: asset,
      label: label,
      value: value,
      iconSize: 15,
      fontSize: 12,
    );
  }
}
