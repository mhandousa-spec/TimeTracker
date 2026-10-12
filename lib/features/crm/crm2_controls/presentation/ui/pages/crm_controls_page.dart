// ****************** FILE INFO ******************
// File Name: crm_controls_page.dart
// Purpose: Control page in CRM displaying control options grid
// Author: Mohand Adel
// Created At: 04/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/69-cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_navigation_helper.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_control_item_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_control_card.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmControlsPage extends StatelessWidget {
  const CrmControlsPage({super.key});

  List<CrmControlItemModel> _getControlItems(BuildContext context) => [
        CrmControlItemModel(
          title: S.current.crmControlClientsTypes,
          description: S.current.crmControlClientsTypesDesc,
          svgAsset: AppAssets.crmClientsType,
          onTap: () => CrmNavigationHelper.navigateToClientTypes(context),
        ),
        CrmControlItemModel(
          title: S.current.crmControlTemplates,
          description: S.current.crmControlTemplatesDesc,
          svgAsset: AppAssets.crmTemplate,
          onTap: () => CrmNavigationHelper.navigateToControlTemplates(context),
        ),
        CrmControlItemModel(
          title: S.current.crmControlRelationship,
          description: S.current.crmControlRelationshipDesc,
          svgAsset: AppAssets.crmRelationship,
          onTap: () =>
              CrmNavigationHelper.navigateToControlRelationships(context),
        ),
        CrmControlItemModel(
          title: S.current.crmControlTerms,
          description: S.current.crmControlTermsDesc,
          svgAsset: AppAssets.crmTablerContract,
          onTap: () => CrmNavigationHelper.navigateToControlTerms(context),
        ),
        CrmControlItemModel(
          title: S.current.crmControlPermissions,
          description: S.current.crmControlPermissionsDesc,
          svgAsset: AppAssets.crmPermissions,
        ),
        CrmControlItemModel(
          title: S.current.crmControlDeals,
          description: S.current.crmControlDealsDesc,
          svgAsset: AppAssets.crmDeal,
          onTap: () => CrmNavigationHelper.navigateToControlDeals(context),
        ),
        CrmControlItemModel(
          title: S.current.crmControlDiscount,
          description: S.current.crmControlDiscountDesc,
          svgAsset: AppAssets.crmDiscount,
          onTap: () => CrmNavigationHelper.navigateToControlDiscounts(context),
        ),
        CrmControlItemModel(
          title: S.current.crmControlActivity,
          description: S.current.crmControlActivityDesc,
          svgAsset: AppAssets.timeSelectorIcon,
          onTap: () => CrmNavigationHelper.navigateToControlActivity(context),
        ),
        CrmControlItemModel(
          title: S.current.crmSectionMerge,
          description: S.current.crmSectionMergeDesc,
          svgAsset: AppAssets.crmMerge,
          onTap: () => CrmNavigationHelper.navigateToControlMerge(context),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final int crossAxisCount = isMobile
        ? 2
        : CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(context);
    final List<CrmControlItemModel> controlItems = _getControlItems(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: S.current.crm,
        secondTitle: S.current.crmSectionControls,
        onFirstTap: () => CrmNavigationHelper.popToDashboard(context),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Controls Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisExtent: isMobile ? 82.sp : 95.sp,
                  crossAxisSpacing: isMobile ? 10.sp : 14.sp,
                  mainAxisSpacing: isMobile ? 10.sp : 14.sp,
                ),
                itemCount: controlItems.length,
                itemBuilder: (BuildContext context, int index) {
                  return CrmControlCard(item: controlItems[index]);
                },
              ),
              SizedBox(height: 32.sp),
            ],
          ),
        ),
      ),
    );
  }
}
