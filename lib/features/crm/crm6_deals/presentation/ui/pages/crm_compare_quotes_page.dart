// ****************** FILE INFO ******************
// File Name: crm_compare_quotes_page.dart
// Purpose: Quote Details comparison full page matching Figma screenshot with breadcrumbs, Group Details, and Side-by-Side Comparison Table
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_deal_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_quote_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_compare_group_details_row.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_compare_quotes_table.dart';

class CrmCompareQuotesPage extends StatelessWidget {
  final CrmClientDealModel deal;
  final List<CrmQuoteModel> quotes;

  const CrmCompareQuotesPage({
    super.key,
    required this.deal,
    required this.quotes,
  });

  @override
  Widget build(BuildContext context) {
    final String dealTitle =
        deal.dealNameEn.isNotEmpty ? deal.dealNameEn : 'ERP System Deal';

    return SideFrameMasterServices(
      titleText: dealTitle,
      secondTitle: 'Quote Details',
      thirdTitle: 'Compare',
      onFirstTap: () => Navigator.of(context).pop(),
      onSecondTap: () => Navigator.of(context).pop(),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 1. Group Details Cards Row
            CrmCompareGroupDetailsRow(quotes: quotes),

            SizedBox(height: 20.sp),

            // 2. Comparison Table
            CrmCompareQuotesTable(quotes: quotes),

            SizedBox(height: 30.sp),
          ],
        ),
      ),
    );
  }
}
