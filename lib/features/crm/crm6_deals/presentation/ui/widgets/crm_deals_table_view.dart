// ****************** FILE INFO ******************
// File Name: crm_deals_table_view.dart
// Purpose: Multi-column Table widget matching standard CRM table UI with dark header and alternating rows
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_deal_model.dart';

class CrmDealsTableView extends StatelessWidget {
  final List<CrmClientDealModel> deals;
  final ValueChanged<CrmClientDealModel>? onDealTap;

  const CrmDealsTableView({
    super.key,
    required this.deals,
    this.onDealTap,
  });

  TextStyle get _headerStyle => StyleText.fontSize14Weight600.copyWith(
        color: AppColors.white,
        fontSize: 13.sp,
      );

  TextStyle _cellStyle(BuildContext context) =>
      StyleText.fontSize14Weight400.copyWith(
        fontSize: 13.sp,
        color: AppColors.text,
      );

  @override
  Widget build(BuildContext context) {
    if (deals.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 48.sp),
        alignment: Alignment.center,
        child: Text(
          'No deals found',
          style: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.darkGrey,
          ),
        ),
      );
    }

    final List<_DealTableColumn> columns = _buildColumns(context);
    final Map<int, TableColumnWidth> columnWidths = <int, TableColumnWidth>{
      for (int i = 0; i < columns.length; i++) i: columns[i].width,
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: Table(
          columnWidths: columnWidths,
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: <TableRow>[
            // 1. Dark Header Row
            TableRow(
              decoration: const BoxDecoration(
                color: Color(0xFF333333),
              ),
              children: columns
                  .map(
                    (_DealTableColumn col) => Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.sp,
                        vertical: 12.sp,
                      ),
                      child: Text(
                        col.title,
                        style: _headerStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
            ),

            // 2. Data Rows with alternating background colors
            ...List.generate(deals.length, (int index) {
              final CrmClientDealModel deal = deals[index];
              final Color rowColor =
                  index.isEven ? AppColors.evenRowColor : AppColors.oddRowColor;

              return TableRow(
                decoration: BoxDecoration(color: rowColor),
                children: columns
                    .map(
                      (_DealTableColumn col) => InkWell(
                        onTap: () => onDealTap?.call(deal),
                        child: col.cellBuilder(context, index, deal),
                      ),
                    )
                    .toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  List<_DealTableColumn> _buildColumns(BuildContext context) {
    return <_DealTableColumn>[
      _DealTableColumn(
        title: 'NO',
        width: FixedColumnWidth(55.sp),
        cellBuilder: (ctx, index, deal) => _textCell(ctx, '${index + 1}'),
      ),
      _DealTableColumn(
        title: 'Category',
        width: FixedColumnWidth(140.sp),
        cellBuilder: (ctx, index, deal) => _textCell(ctx, deal.category),
      ),
      _DealTableColumn(
        title: 'Deal Name',
        width: FixedColumnWidth(230.sp),
        cellBuilder: (ctx, index, deal) => _textCell(ctx, deal.dealNameEn),
      ),
      _DealTableColumn(
        title: 'اسم الصفقة',
        width: FixedColumnWidth(230.sp),
        cellBuilder: (ctx, index, deal) => _textCell(ctx, deal.dealNameAr),
      ),
      _DealTableColumn(
        title: 'Expected Value',
        width: FixedColumnWidth(140.sp),
        cellBuilder: (ctx, index, deal) =>
            _textCell(ctx, deal.expectedValueFormatted),
      ),
      _DealTableColumn(
        title: 'Stage',
        width: FixedColumnWidth(130.sp),
        cellBuilder: (ctx, index, deal) => _stageCell(ctx, deal),
      ),
      _DealTableColumn(
        title: 'Note',
        width: FixedColumnWidth(180.sp),
        cellBuilder: (ctx, index, deal) => _textCell(ctx, deal.noteEn),
      ),
      _DealTableColumn(
        title: 'ملاحظة',
        width: FixedColumnWidth(180.sp),
        cellBuilder: (ctx, index, deal) => _textCell(ctx, deal.noteAr),
      ),
      _DealTableColumn(
        title: 'Likelihood',
        width: FixedColumnWidth(110.sp),
        cellBuilder: (ctx, index, deal) => _textCell(ctx, deal.likelihood),
      ),
      _DealTableColumn(
        title: 'Assigned Employee',
        width: FixedColumnWidth(160.sp),
        cellBuilder: (ctx, index, deal) =>
            _textCell(ctx, deal.assignedEmployee),
      ),
      _DealTableColumn(
        title: 'Manager',
        width: FixedColumnWidth(140.sp),
        cellBuilder: (ctx, index, deal) => _textCell(ctx, deal.manager),
      ),
      _DealTableColumn(
        title: 'Start Date',
        width: FixedColumnWidth(120.sp),
        cellBuilder: (ctx, index, deal) => _textCell(ctx, deal.startDate),
      ),
      _DealTableColumn(
        title: 'Close Date',
        width: FixedColumnWidth(120.sp),
        cellBuilder: (ctx, index, deal) => _textCell(ctx, deal.closeDate),
      ),
      _DealTableColumn(
        title: 'Last Activity',
        width: FixedColumnWidth(130.sp),
        cellBuilder: (ctx, index, deal) => _textCell(ctx, deal.lastActivity),
      ),
      _DealTableColumn(
        title: 'Products',
        width: FixedColumnWidth(140.sp),
        cellBuilder: (ctx, index, deal) => _textCell(
          ctx,
          deal.products.isNotEmpty ? deal.products.first.productName : '-',
        ),
      ),
      _DealTableColumn(
        title: 'Category',
        width: FixedColumnWidth(110.sp),
        cellBuilder: (ctx, index, deal) => _textCell(
          ctx,
          deal.products.isNotEmpty ? deal.products.first.category : '-',
        ),
      ),
      _DealTableColumn(
        title: 'Qty',
        width: FixedColumnWidth(60.sp),
        cellBuilder: (ctx, index, deal) => _textCell(
          ctx,
          deal.products.isNotEmpty ? '${deal.products.first.qty}' : '-',
        ),
      ),
      _DealTableColumn(
        title: 'Price',
        width: FixedColumnWidth(90.sp),
        cellBuilder: (ctx, index, deal) => _textCell(
          ctx,
          deal.products.isNotEmpty
              ? '\$${deal.products.first.price.toInt()}'
              : '-',
        ),
      ),
      _DealTableColumn(
        title: 'Discount',
        width: FixedColumnWidth(80.sp),
        cellBuilder: (ctx, index, deal) => _textCell(
          ctx,
          deal.products.isNotEmpty
              ? '${deal.products.first.discount.toInt()}%'
              : '-',
        ),
      ),
      _DealTableColumn(
        title: 'Tax',
        width: FixedColumnWidth(70.sp),
        cellBuilder: (ctx, index, deal) => _textCell(
          ctx,
          deal.products.isNotEmpty
              ? '${deal.products.first.tax.toInt()}%'
              : '-',
        ),
      ),
      _DealTableColumn(
        title: 'Total',
        width: FixedColumnWidth(110.sp),
        cellBuilder: (ctx, index, deal) => _textCell(
          ctx,
          deal.products.isNotEmpty
              ? '\$${deal.products.first.total.toInt()}'
              : '-',
        ),
      ),
      _DealTableColumn(
        title: 'Services',
        width: FixedColumnWidth(150.sp),
        cellBuilder: (ctx, index, deal) => _textCell(
          ctx,
          deal.services.isNotEmpty ? deal.services.first.serviceName : '-',
        ),
      ),
      _DealTableColumn(
        title: 'Category',
        width: FixedColumnWidth(110.sp),
        cellBuilder: (ctx, index, deal) => _textCell(
          ctx,
          deal.services.isNotEmpty ? deal.services.first.category : '-',
        ),
      ),
      _DealTableColumn(
        title: 'Price',
        width: FixedColumnWidth(90.sp),
        cellBuilder: (ctx, index, deal) => _textCell(
          ctx,
          deal.services.isNotEmpty
              ? '\$${deal.services.first.price.toInt()}'
              : '-',
        ),
      ),
      _DealTableColumn(
        title: 'Discount',
        width: FixedColumnWidth(80.sp),
        cellBuilder: (ctx, index, deal) => _textCell(
          ctx,
          deal.services.isNotEmpty
              ? '${deal.services.first.discount.toInt()}%'
              : '-',
        ),
      ),
      _DealTableColumn(
        title: 'Tax',
        width: FixedColumnWidth(70.sp),
        cellBuilder: (ctx, index, deal) => _textCell(
          ctx,
          deal.services.isNotEmpty
              ? '${deal.services.first.tax.toInt()}%'
              : '-',
        ),
      ),
      _DealTableColumn(
        title: 'Total',
        width: FixedColumnWidth(110.sp),
        cellBuilder: (ctx, index, deal) => _textCell(
          ctx,
          deal.services.isNotEmpty
              ? '\$${deal.services.first.total.toInt()}'
              : '-',
        ),
      ),
    ];
  }

  Widget _textCell(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 12.sp),
      child: Text(
        text.isEmpty ? '-' : text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: _cellStyle(context),
      ),
    );
  }

  Widget _stageCell(BuildContext context, CrmClientDealModel deal) {
    final Color stageColor = _getStageColor(deal.stage);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 12.sp),
      child: Text(
        deal.stageLabelEn,
        style: _cellStyle(context).copyWith(
          color: stageColor,
          fontWeight: FontWeight.bold,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Color _getStageColor(String stage) {
    switch (stage.toLowerCase()) {
      case 'new':
        return AppColors.blue;
      case 'discovery':
        return const Color(0xFFEAB308);
      case 'qualified':
        return const Color(0xFFF97316);
      case 'proposal':
        return const Color(0xFF8B5CF6);
      case 'negotiation':
        return const Color(0xFFEC4899);
      case 'closedlost':
        return AppColors.red;
      case 'closedwon':
        return AppColors.green;
      default:
        return AppColors.primary;
    }
  }
}

class _DealTableColumn {
  final String title;
  final TableColumnWidth width;
  final Widget Function(
    BuildContext context,
    int index,
    CrmClientDealModel deal,
  ) cellBuilder;

  const _DealTableColumn({
    required this.title,
    required this.width,
    required this.cellBuilder,
  });
}
