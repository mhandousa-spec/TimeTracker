// ****************** FILE INFO ******************
// File Name: crm_client_timeline_tab.dart
// Purpose: Dynamic Timeline tab view reacting to client status changes (Active/Inactive/Blacklist/Unblacklist), activities, and relationships
// Author: Mohand Adel
// Created At: 27/08/2026

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_activity_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_record_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_relationship_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_timeline_item_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/repository/crm_client_activity_repository.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/repository/crm_client_relationship_repository.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/controller/crm_client_activities_cubit.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/pages/crm_client_add_activity_page.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/pages/crm_client_add_relationship_page.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_timeline_item_card.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_client_type_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_model.dart';

class CrmClientTimelineTab extends StatefulWidget {
  final CrmClientRecordModel record;
  final CrmTemplateModel? template;
  final CrmClientTypeModel? clientType;

  const CrmClientTimelineTab({
    super.key,
    required this.record,
    this.template,
    this.clientType,
  });

  @override
  State<CrmClientTimelineTab> createState() => _CrmClientTimelineTabState();
}

class _CrmClientTimelineTabState extends State<CrmClientTimelineTab> {
  final CrmClientActivityRepository _activityRepository =
      CrmClientActivityRepository();
  final CrmClientRelationshipRepository _relationshipRepository =
      CrmClientRelationshipRepository();

  StreamSubscription? _activitySubscription;
  StreamSubscription? _relationshipSubscription;

  List<CrmClientActivityModel> _activities = <CrmClientActivityModel>[];
  List<CrmClientRelationshipModel> _relationships =
      <CrmClientRelationshipModel>[];
  bool _isLoading = true;

  String _selectedActivityFilter = 'All Activity';
  DateTime? _selectedDateFilter;

  static const List<String> _activityFilterOptions = <String>[
    'All Activity',
    'Status',
    'Blacklist',
    'Unblacklist',
    'Call',
    'Meeting',
    'Task',
    'Relationship',
    'Deal',
  ];

  @override
  void initState() {
    super.initState();
    _subscribeData();
  }

  @override
  void didUpdateWidget(covariant CrmClientTimelineTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.record.id != widget.record.id ||
        oldWidget.record.status != widget.record.status ||
        oldWidget.record.blacklistDetails != widget.record.blacklistDetails) {
      _subscribeData();
    }
  }

  void _subscribeData() {
    _activitySubscription?.cancel();
    _relationshipSubscription?.cancel();

    _activitySubscription =
        _activityRepository.watch(widget.record.id).listen((activities) {
      if (mounted) {
        setState(() {
          _activities = activities.where((a) => !a.isDeleted).toList();
          _isLoading = false;
        });
      }
    });

    _relationshipSubscription = _relationshipRepository
        .watchClientRelationships(widget.record.id)
        .listen((relationships) {
      if (mounted) {
        setState(() {
          _relationships = relationships.where((r) => !r.isDeleted).toList();
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _activitySubscription?.cancel();
    _relationshipSubscription?.cancel();
    super.dispose();
  }

  List<CrmTimelineItemModel> _buildAllTimelineItems() {
    final List<CrmTimelineItemModel> items = <CrmTimelineItemModel>[];

    // 1. Status lifecycle events (Active, Inactive, Blacklist, Unblacklist)
    items.addAll(CrmTimelineItemModel.generateStatusEvents(widget.record));

    // 2. Dynamic Activity events
    for (int i = 0; i < _activities.length; i++) {
      items
          .add(CrmTimelineItemModel.fromActivity(_activities[i], index: i + 1));
    }

    // 3. Dynamic Relationship events
    for (final CrmClientRelationshipModel rel in _relationships) {
      items.add(CrmTimelineItemModel.fromRelationship(rel));
    }

    // Sort descending by event date (most recent on top)
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  List<CrmTimelineItemModel> get _filteredTimelineItems {
    final List<CrmTimelineItemModel> all = _buildAllTimelineItems();

    return all.where((CrmTimelineItemModel item) {
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _activities.isEmpty && _relationships.isEmpty) {
      return Container(
        width: double.infinity,
        height: 250.sp,
        alignment: Alignment.center,
        child: const CircleProgressMaster(),
      );
    }

    final List<CrmTimelineItemModel> displayItems = _filteredTimelineItems;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16.sp),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Filters Row (Activity Type Dropdown + Calendar Date Picker)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildActivityDropdown(),
              SizedBox(width: 12.sp),
              _buildCalendarFilterButton(),
            ],
          ),
          SizedBox(height: 20.sp),

          // 2. Timeline items or Empty State
          if (displayItems.isEmpty)
            _buildEmptyTimeline()
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayItems.length,
              itemBuilder: (BuildContext context, int index) {
                final CrmTimelineItemModel item = displayItems[index];
                return CrmTimelineItemCard(
                  item: item,
                  isFirst: index == 0,
                  isLast: index == displayItems.length - 1,
                  onTap: () => _handleItemTap(item),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildActivityDropdown() {
    return Container(
      height: 32.sp,
      padding: EdgeInsets.symmetric(horizontal: 12.sp),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6.sp),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedActivityFilter,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.text,
            size: 20.sp,
          ),
          style: StyleText.fontSize12Weight400.copyWith(
            color: AppColors.text,
          ),
          dropdownColor: AppColors.card,
          borderRadius: BorderRadius.circular(8.sp),
          items: _activityFilterOptions.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(
                option,
                style: StyleText.fontSize12Weight400.copyWith(
                  color: AppColors.text,
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
    final String label = _selectedDateFilter != null
        ? DateFormat('dd/MM/yyyy').format(_selectedDateFilter!)
        : FormatHelper.localizedString(
            englishName: 'Calendar',
            arabicName: 'التقويم',
          );

    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _selectedDateFilter ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2035),
        );
        if (picked != null) {
          setState(() => _selectedDateFilter = picked);
        }
      },
      borderRadius: BorderRadius.circular(4.sp),
      child: Container(
        height: 32.sp,
        padding: EdgeInsets.symmetric(horizontal: 12.sp),
        decoration: BoxDecoration(
          color: AppColors.offWhite,
          borderRadius: BorderRadius.circular(4.sp),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 8.sp),
            CustomSvgImage(
              assetPath: AppAssets.calendar,
              width: 14.sp,
              height: 14.sp,
              color: AppColors.text,
            ),
            if (_selectedDateFilter != null) ...[
              SizedBox(width: 6.sp),
              GestureDetector(
                onTap: () => setState(() => _selectedDateFilter = null),
                child: Icon(
                  Icons.close,
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
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.sp),
        child: Column(
          children: [
            CustomSvgImage(
              assetPath: AppAssets.crmTemplateEmpty,
              width: 80.sp,
              height: 80.sp,
            ),
            SizedBox(height: 12.sp),
            Text(
              FormatHelper.localizedString(
                englishName: 'No events found on the timeline',
                arabicName: 'لا توجد أحداث مسجلة في الجدول الزمني',
              ),
              style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.darkGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleItemTap(CrmTimelineItemModel item) {
    if (item.activityModel != null) {
      final CrmClientActivitiesCubit activitiesCubit =
          CrmClientActivitiesCubit(clientId: widget.record.id);
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => CrmClientAddActivityPage(
            clientId: widget.record.id,
            existingActivity: item.activityModel,
            mode: 'view',
            cubit: activitiesCubit,
          ),
        ),
      );
      return;
    }

    if (item.relationshipModel != null) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => CrmClientAddRelationshipPage(
            clientId: widget.record.id,
            existingRelationship: item.relationshipModel,
            mode: 'view',
          ),
        ),
      );
      return;
    }

    CrmControlDialogs.showSuccessDialog(
      context: context,
      title: item.title,
      subtitle: item.subtitle ??
          '${item.activityType} on ${DateFormat('dd MMM yyyy').format(item.date)} at ${item.time}',
    );
  }
}
