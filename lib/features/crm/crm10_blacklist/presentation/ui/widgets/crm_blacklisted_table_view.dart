// ****************** FILE INFO ******************
// File Name: crm_blacklisted_table_view.dart
// Purpose: Responsive Table view for blacklisted clients matching the Figma table layout.
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm10_blacklist/data/models/crm_blacklist_item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CrmBlacklistedTableView extends StatelessWidget {
  final List<CrmBlacklistItemModel> items;
  final void Function(CrmBlacklistItemModel item)? onItemTap;

  const CrmBlacklistedTableView({
    super.key,
    required this.items,
    this.onItemTap,
  });

  Color _typeColor(String type) {
    final String t = type.toLowerCase();
    if (t.contains('company')) return AppColors.green;
    if (t.contains('government')) return AppColors.yellow;
    if (t.contains('person') || t.contains('client')) return AppColors.blue;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: SizedBox(
        width: 1050.w,
        child: Column(
          children: <Widget>[
            // 1. Table Header
            _buildTableHeader(),

            // 2. Table Rows
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                final CrmBlacklistItemModel item = items[index];
                return _buildTableRow(index + 1, item);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      height: 44.sp,
      decoration: BoxDecoration(
        color: AppColors.header,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8.r),
          topRight: Radius.circular(8.r),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.sp),
      child: Row(
        children: <Widget>[
          _headerCell('NO', width: 50.w),
          _headerCell('Client Name', width: 140.w),
          _headerCell('اسم العميل', width: 140.w),
          _headerCell('Photo', width: 80.w, alignment: Alignment.center),
          _headerCell('Clients Type', width: 130.w),
          _headerCell('Reason', width: 140.w),
          _headerCell('By', width: 120.w),
          _headerCell('Date', width: 110.w),
          _headerCell('Time', width: 100.w),
        ],
      ),
    );
  }

  Widget _headerCell(
    String title, {
    required double width,
    Alignment alignment = Alignment.centerLeft,
  }) {
    return SizedBox(
      width: width,
      child: Align(
        alignment: alignment,
        child: Text(
          title,
          style: StyleText.fontSize12Weight600.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildTableRow(int no, CrmBlacklistItemModel item) {
    return InkWell(
      onTap: () => onItemTap?.call(item),
      child: Container(
        height: 52.sp,
        padding: EdgeInsets.symmetric(horizontal: 16.sp),
        decoration: BoxDecoration(
          color: no.isEven ? AppColors.card : AppColors.background,
          border: Border(
            bottom: BorderSide(color: AppColors.borderCard, width: 0.8),
          ),
        ),
        child: Row(
          children: <Widget>[
            // 1. NO
            SizedBox(
              width: 50.w,
              child: Text(
                '$no',
                style: StyleText.fontSize12Weight400.copyWith(
                  color: AppColors.text,
                ),
              ),
            ),

            // 2. Client Name (EN)
            SizedBox(
              width: 140.w,
              child: Text(
                item.clientNameEn.isNotEmpty ? item.clientNameEn : '—',
                style: StyleText.fontSize12Weight400.copyWith(
                  color: AppColors.text,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // 3. Client Name (AR)
            SizedBox(
              width: 140.w,
              child: Text(
                item.clientNameAr.isNotEmpty ? item.clientNameAr : '—',
                style: StyleText.fontSize12Weight400.copyWith(
                  color: AppColors.text,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // 4. Photo
            SizedBox(
              width: 80.w,
              child: Center(
                child: Container(
                  width: 32.sp,
                  height: 32.sp,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.greyDark,
                    image: item.photoUrl != null && item.photoUrl!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(item.photoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: item.photoUrl == null || item.photoUrl!.isEmpty
                      ? Center(
                          child: Text(
                            item.displayName.isNotEmpty
                                ? item.displayName[0].toUpperCase()
                                : 'C',
                            style:
                                StyleText.fontSize12Weight600.copyWith(
                              color: AppColors.text,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
            ),

            // 5. Clients Type
            SizedBox(
              width: 130.w,
              child: Text(
                item.clientType,
                style: StyleText.fontSize12Weight600.copyWith(
                  color: _typeColor(item.clientType),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // 6. Reason
            SizedBox(
              width: 140.w,
              child: Text(
                item.reason,
                style: StyleText.fontSize12Weight400.copyWith(
                  color: AppColors.text,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // 7. By
            SizedBox(
              width: 120.w,
              child: Text(
                item.requestedByName.isNotEmpty ? item.requestedByName : '—',
                style: StyleText.fontSize12Weight400.copyWith(
                  color: AppColors.text,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // 8. Date
            SizedBox(
              width: 110.w,
              child: Text(
                item.date,
                style: StyleText.fontSize12Weight400.copyWith(
                  color: AppColors.text,
                ),
              ),
            ),

            // 9. Time
            SizedBox(
              width: 100.w,
              child: Text(
                item.time,
                style: StyleText.fontSize12Weight400.copyWith(
                  color: AppColors.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
