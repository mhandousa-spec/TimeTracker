// ****************** FILE INFO ******************
// File Name: crm_quote_versions_tab.dart
// Purpose: Versions tab content for Quote Details displaying list of quote versions and comparison actions
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_quote_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_quote_card.dart';

class CrmQuoteVersionsTab extends StatelessWidget {
  final CrmQuoteModel currentQuote;

  const CrmQuoteVersionsTab({
    super.key,
    required this.currentQuote,
  });

  @override
  Widget build(BuildContext context) {
    final List<CrmQuoteModel> versions = <CrmQuoteModel>[
      currentQuote,
      CrmQuoteModel(
        id: '${currentQuote.id}_v2',
        no: 2,
        quoteNo: currentQuote.quoteNo,
        version: '2',
        clientStatus: CrmQuoteStatus.adjustment,
        approvalStatus: 'Pending',
        approvalStatusColor: const Color(0xFFFF7A00),
        validUntil: currentQuote.validUntil,
        createdDate: '15 Jul 2026',
        total: currentQuote.total * 0.95,
        totalFormatted: '\$950',
      ),
      CrmQuoteModel(
        id: '${currentQuote.id}_v1',
        no: 1,
        quoteNo: currentQuote.quoteNo,
        version: '1',
        clientStatus: CrmQuoteStatus.expired,
        approvalStatus: 'Expired',
        approvalStatusColor: AppColors.darkGrey,
        validUntil: '1 Jul 2026',
        createdDate: '20 Jun 2026',
        total: currentQuote.total * 1.1,
        totalFormatted: '\$1,100',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          FormatHelper.localizedString(
            englishName: 'Quote Version History',
            arabicName: 'سجل إصدارات عرض الأسعار',
          ),
          style: StyleText.fontSize16Weight500.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 14.sp),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final int crossAxisCount = constraints.maxWidth > 700 ? 2 : 1;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisExtent: 94.sp,
                crossAxisSpacing: 12.sp,
                mainAxisSpacing: 12.sp,
              ),
              itemCount: versions.length,
              itemBuilder: (BuildContext context, int index) {
                final CrmQuoteModel item = versions[index];
                return CrmQuoteCard(
                  quote: item,
                  isSelected: item.version == currentQuote.version,
                  onTap: () {
                    CrmControlDialogs.showSuccessDialog(
                      context: context,
                      title: 'Version ${item.version}',
                      subtitle:
                          'Quote ${item.quoteNo} • Status: ${item.clientStatus.labelEn} • Total: ${item.totalFormatted}',
                    );
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
