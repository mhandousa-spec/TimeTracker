// ****************** FILE INFO ******************
// File Name: crm_deal_timeline_tab.dart
// Purpose: Timeline tab view for CRM Deal Details matching Clients tab design with activity filters and calendar date picker
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_deal_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_timeline_item_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_deal_timeline_item_card.dart';

class CrmDealTimelineTab extends StatefulWidget {
  final CrmClientDealModel deal;

  const CrmDealTimelineTab({
    super.key,
    required this.deal,
  });

  @override
  State<CrmDealTimelineTab> createState() => _CrmDealTimelineTabState();
}

class _CrmDealTimelineTabState extends State<CrmDealTimelineTab> {
  String _selectedActivityFilter = 'All Activity';
  DateTime? _selectedDateFilter;

  static const List<String> _activityFilterOptions = <String>[
    'All Activity',
    'Call',
    'Meeting',
    'Task',
    'Follow up',
    'Deal',
  ];

  final List<CrmDealTimelineItemModel> _timelineItems =
      <CrmDealTimelineItemModel>[
    CrmDealTimelineItemModel(
      id: '1',
      title: 'Contact',
      subtitle: 'With Aya At 16',
      date: DateTime(2026, 5, 16),
      time: '11:30am',
      activityType: 'Call',
      assignedUserName: 'Sara Ahmed',
      assignedUserAvatar: AppAssets.defaultEmployeeAvatar,
      tag: 'Deal',
      itemNumber: '8',
      duration: '35 min',
    ),
    CrmDealTimelineItemModel(
      id: '2',
      title: 'Contact',
      subtitle: 'With Aya At 16',
      date: DateTime(2026, 5, 16),
      time: '11:30am',
      activityType: 'Meeting',
      assignedUserName: 'Sara Ahmed',
      assignedUserAvatar: AppAssets.defaultEmployeeAvatar,
      tag: 'Follow Up',
      itemNumber: '8',
      duration: '35 min',
    ),
    CrmDealTimelineItemModel(
      id: '3',
      title: 'Contact',
      subtitle: 'With Aya At 16',
      date: DateTime(2026, 5, 16),
      time: '11:30am',
      activityType: 'Call',
      assignedUserName: 'Sara Ahmed',
      assignedUserAvatar: AppAssets.defaultEmployeeAvatar,
      tag: 'Deal',
      itemNumber: '8',
      duration: '35 min',
    ),
    CrmDealTimelineItemModel(
      id: '4',
      title: 'Contact',
      subtitle: 'With Aya At 16',
      date: DateTime(2026, 5, 16),
      time: '11:30am',
      activityType: 'Meeting',
      assignedUserName: 'Sara Ahmed',
      assignedUserAvatar: AppAssets.defaultEmployeeAvatar,
      tag: 'Deal',
      itemNumber: '8',
      duration: '35 min',
    ),
  ];

  List<CrmDealTimelineItemModel> get _filteredTimelineItems {
    return _timelineItems.where((CrmDealTimelineItemModel item) {
      // Activity type filter
      if (_selectedActivityFilter != 'All Activity') {
        final String filterLower = _selectedActivityFilter.toLowerCase();
        final bool matchesType =
            item.activityType.toLowerCase() == filterLower ||
                (item.tag?.toLowerCase() == filterLower);
        if (!matchesType) return false;
      }

      // Date filter
      if (_selectedDateFilter != null) {
        final bool isSameDay = item.date.year == _selectedDateFilter!.year &&
            item.date.month == _selectedDateFilter!.month &&
            item.date.day == _selectedDateFilter!.day;
        if (!isSameDay) return false;
      }

      return true;
    }).toList();
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateFilter ?? now,
      firstDate: now.subtract(const Duration(days: 365 * 2)),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() => _selectedDateFilter = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<CrmDealTimelineItemModel> displayItems = _filteredTimelineItems;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.sp),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ── 1. Top Filters Row (Activity Dropdown + Calendar Picker) ────────
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              // Activity Dropdown
              _buildActivityDropdown(),
              SizedBox(width: 12.sp),

              // Calendar Filter Button
              _buildCalendarFilterButton(),
            ],
          ),

          SizedBox(height: 24.sp),

          // ── 2. Timeline items or Empty State ────────────────────────────────
          if (displayItems.isEmpty)
            _buildEmptyTimeline()
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayItems.length,
              itemBuilder: (BuildContext context, int index) {
                final CrmDealTimelineItemModel item = displayItems[index];
                return CrmDealTimelineItemCard(
                  item: item,
                  isFirst: index == 0,
                  isLast: index == displayItems.length - 1,
                  onTap: () {
                    CrmControlDialogs.showSuccessDialog(
                      context: context,
                      title: '${item.title} (${item.activityType})',
                      subtitle:
                          'Assignee: ${item.assignedUserName ?? 'N/A'} • Date: ${DateFormat('d MMM yyyy').format(item.date)} ${item.time}',
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildActivityDropdown() {
    return Container(
      height: 36.sp,
      padding: EdgeInsets.symmetric(horizontal: 12.sp),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedActivityFilter,
          icon: Padding(
            padding: EdgeInsets.only(left: 6.sp),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.black,
              size: 18.sp,
            ),
          ),
          style: StyleText.fontSize12Weight400.copyWith(
            color: AppColors.black,
            fontWeight: FontWeight.w600,
          ),
          dropdownColor: AppColors.white,
          borderRadius: BorderRadius.circular(8.r),
          items: _activityFilterOptions.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(
                option,
                style: StyleText.fontSize12Weight400.copyWith(
                  color: AppColors.black,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? value) {
            if (value != null) {
              setState(() => _selectedActivityFilter = value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildCalendarFilterButton() {
    final bool hasDate = _selectedDateFilter != null;
    final String label = hasDate
        ? DateFormat('d MMM yyyy').format(_selectedDateFilter!)
        : FormatHelper.localizedString(
            englishName: 'Calendar',
            arabicName: 'التقويم',
          );

    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        height: 36.sp,
        padding: EdgeInsets.symmetric(horizontal: 12.sp),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              label,
              style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8.sp),
            CustomSvgImage(
              assetPath: AppAssets.calendar,
              width: 14.sp,
              height: 14.sp,
              color: AppColors.darkGrey,
            ),
            if (hasDate) ...<Widget>[
              SizedBox(width: 6.sp),
              InkWell(
                onTap: () => setState(() => _selectedDateFilter = null),
                child: Icon(
                  Icons.close_rounded,
                  size: 14.sp,
                  color: AppColors.darkGrey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTimeline() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.sp),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.timeline_rounded,
            size: 40.sp,
            color: AppColors.darkGrey,
          ),
          SizedBox(height: 10.sp),
          Text(
            FormatHelper.localizedString(
              englishName: 'No timeline events found for this filter.',
              arabicName: 'لا توجد أحداث في الخط الزمني لهذا الفلتر.',
            ),
            style: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.darkGrey,
            ),
          ),
        ],
      ),
    );
  }
}
