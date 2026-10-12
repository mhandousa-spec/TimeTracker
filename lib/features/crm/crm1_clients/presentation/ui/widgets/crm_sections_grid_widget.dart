// ****************** FILE INFO ******************
// File Name: crm_sections_grid_widget.dart
// Purpose: Widget displaying the CRM sections grid view when Sections tab is selected
// Author: Mohand Adel
// Created At: 02/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/69-cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_section_item_card.dart';

class CrmSectionItem {
  final String title;
  final String description;
  final String svgAsset;
  final VoidCallback? onTap;

  const CrmSectionItem({
    required this.title,
    required this.description,
    required this.svgAsset,
    this.onTap,
  });
}

class CrmSectionsGridWidget extends StatelessWidget {
  final Function(String sectionTitle)? onSectionTap;

  const CrmSectionsGridWidget({
    super.key,
    this.onSectionTap,
  });

  List<CrmSectionItem> _getSections(BuildContext context) => [
        CrmSectionItem(
          title: S.current.crmSectionLeads,
          description: S.current.crmSectionLeadsDesc,
          svgAsset: AppAssets.crmGroup,
        ),
        CrmSectionItem(
          title: S.current.crmSectionClients,
          description: S.current.crmSectionClientsDesc,
          svgAsset: AppAssets.crmClients,
        ),
        CrmSectionItem(
          title: S.current.crmSectionDeals,
          description: S.current.crmSectionDealsDesc,
          svgAsset: AppAssets.crmDeal,
        ),
        CrmSectionItem(
          title: S.current.crmSectionProducts,
          description: S.current.crmSectionProductsDesc,
          svgAsset: AppAssets.crmProducts,
          onTap: () => CrmNavigationHelper.navigateToProducts(context),
        ),
        CrmSectionItem(
          title: S.current.crmSectionServices,
          description: S.current.crmSectionServicesDesc,
          svgAsset: AppAssets.crmServices,
          onTap: () => CrmNavigationHelper.navigateToServices(context),
        ),
        CrmSectionItem(
          title: S.current.crmSectionQuotes,
          description: S.current.crmSectionQuotesDesc,
          svgAsset: AppAssets.crmQuotes,
        ),
        CrmSectionItem(
          title: S.current.crmSectionContracts,
          description: S.current.crmSectionContractsDesc,
          svgAsset: AppAssets.crmTablerContract,
        ),
        CrmSectionItem(
          title: S.current.crmSectionMerge,
          description: S.current.crmSectionMergeDesc,
          svgAsset: AppAssets.crmMerge,
          onTap: () => CrmNavigationHelper.navigateToDuplicates(context),
        ),
        CrmSectionItem(
          title: S.current.crmSectionRequests,
          description: S.current.crmSectionRequestsDesc,
          svgAsset: AppAssets.crmRequestQuote,
        ),
        CrmSectionItem(
          title: S.current.crmSectionBlacklist,
          description: S.current.crmSectionBlacklistDesc,
          svgAsset: AppAssets.crmBlacklist,
          onTap: () => CrmNavigationHelper.navigateToBlacklisted(context),
        ),
        CrmSectionItem(
          title: S.current.crmSectionControls,
          description: S.current.crmSectionControlsDesc,
          svgAsset: AppAssets.crmControl,
          onTap: () => CrmNavigationHelper.navigateToControls(context),
        ),
        CrmSectionItem(
          title: FormatHelper.localizedString(
            englishName: 'Team',
            arabicName: 'الفريق',
          ),
          description: FormatHelper.localizedString(
            englishName: 'Manage CRM teams and members',
            arabicName: 'إدارة فرق العمل والأعضاء',
          ),
          svgAsset: AppAssets.crmGroup,
          onTap: () => CrmNavigationHelper.navigateToTeams(context),
        ),
        CrmSectionItem(
          title: S.current.crmSectionGuide,
          description: S.current.crmSectionGuideDesc,
          svgAsset: AppAssets.crmGuide,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final int crossAxisCount = isMobile
        ? 2
        : CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(context);

    final List<CrmSectionItem> sections = _getSections(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisExtent: isMobile ? 82.sp : 90.sp,
        crossAxisSpacing: isMobile ? 10.sp : 14.sp,
        mainAxisSpacing: isMobile ? 10.sp : 14.sp,
      ),
      itemCount: sections.length,
      itemBuilder: (BuildContext context, int index) {
        final CrmSectionItem item = sections[index];
        return CrmSectionItemCard(
          item: item,
          onSectionTap: onSectionTap,
        );
      },
    );
  }
}
