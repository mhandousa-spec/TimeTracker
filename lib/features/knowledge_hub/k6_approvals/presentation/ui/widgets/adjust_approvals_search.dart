/// Module: knowledge_hub / presentation / s6_approvals / widgets/adjust_approvals_search.dart
/// ************************* FILE INFO *************************** ///
/// File Name: adjust_approvals_search.dart
/// Purpose: Adjust approvals search — Approvals (S6) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import '../../../../main_controller/helper/responsive_helper.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../controller/approvals_cubit.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';

class AdjustApprovalsSearch extends StatefulWidget {
  const AdjustApprovalsSearch({super.key});

  @override
  State<AdjustApprovalsSearch> createState() => _AdjustApprovalsSearchState();
}

class _AdjustApprovalsSearchState extends State<AdjustApprovalsSearch> {
  String? _selectedStatus;
  String? _selectedDocType;
  DateTime? _startDate;
  DateTime? _endDate;

  static const List<Map<String, String>> _documentTypeItems = [
    {'key': 'Document Type', 'value': 'Document Type'},
    {'key': 'PDF', 'value': 'PDF'},
    {'key': 'Word', 'value': 'Word'},
    {'key': 'Excel', 'value': 'Excel'},
    {'key': 'PowerPoint', 'value': 'PowerPoint'},
    {'key': 'Text', 'value': 'Text'},
  ];

  static const List<Map<String, String>> _statusMenuItems = [
    {'key': 'Status', 'value': 'Status'},
    {'key': 'Published', 'value': 'Published'},
    {'key': 'Pending', 'value': 'Pending'},
    {'key': 'Rejected', 'value': 'Rejected'},
    {'key': 'Removed', 'value': 'Removed'},
    {'key': 'Archive', 'value': 'Archive'},
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialFilterValues();
  }

  void _loadInitialFilterValues() {
    final cubit = context.read<ApprovalsCubit>();
    _selectedStatus = cubit.selectedStatus;
    _selectedDocType = cubit.selectedDocumentType;
    _startDate = cubit.selectedStartDate;
    _endDate = cubit.selectedEndDate;
  }

  void _updateStatus(String? newStatus) {
    setState(() {
      _selectedStatus = newStatus;
    });
  }

  void _updateDocumentType(String? newDocType) {
    setState(() {
      _selectedDocType = newDocType;
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedDocType = null;
      _startDate = null;
      _endDate = null;
    });
  }

  void _applyFilters() {
    final cubit = context.read<ApprovalsCubit>();
    cubit.applyFilters(
      documentType: _selectedDocType,
      status: _selectedStatus,
      startDate: _startDate,
      endDate: _endDate,
    );
    Navigator.of(context).pop();
  }

  Future<void> _selectDate(bool isStartDate) async {
    DateTime? initialDate = isStartDate ? _startDate : _endDate;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
        } else {
          _endDate = pickedDate;
        }
      });
      log('${isStartDate ? 'Start' : 'End'} date: ${pickedDate.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return Material(
      color: AppColors.transparent,
      child: Container(
        width: isMobile ? double.infinity : 655.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: lightMode ? AppColors.white : AppColors.background,
        ),
        padding: EdgeInsets.all(isMobile ? 15.w : 20.w),
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, lightMode),
            SizedBox(height: 15.h),
            _buildDropdowns(isMobile, lightMode, context),
            SizedBox(height: 15.h),
            _buildDateRangeSelectors(lightMode, context),
            SizedBox(height: 15.h),
            _buildActionButtons(isMobile, lightMode, context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool lightMode) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: AppColors.primary,
          radius: 15.r,
          child: CustomSvgImage(
            assetPath: 'assets/icons_assets/knowledge_hub_assets/svg_filter.svg',
            width: 16.w,
            height: 16.h,
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          S.of(context).filter,
          style: StyleText.fontSize16Weight500.copyWith(
            color: lightMode
                ? AppColors.blackButton
                : AppColors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdowns(bool isMobile, bool lightMode, BuildContext context) {
    final statusDropdown = SizedBox(
                             width: isMobile ? double.infinity : null,
                             height: 36,
                             child: CustomDropdown<String>(
                               value: _selectedStatus,
                               items: _statusMenuItems
                               .map((e) => DropdownItem<String>(
                                 value: e['key'] ?? '',
                                 label: e['value'] ?? '',
                               ))
                               .toList(),
                               onChanged: (v) => _updateStatus(v),
                               hint: 'Status',
                               hintStyle: StyleText.fontSize12Weight400.copyWith(
          color: lightMode ? AppColors.secondaryText : AppColors.grey,
        ),
                               fillColor: lightMode
          ? AppColors.background
          : AppColors.chatBackground,
                             ),
                           );

    final docTypeDropdown = SizedBox(
                              width: isMobile ? double.infinity : null,
                              height: 36,
                              child: CustomDropdown<String>(
                                value: _selectedDocType,
                                items: _documentTypeItems
                                .map((e) => DropdownItem<String>(
                                  value: e['key'] ?? '',
                                  label: e['value'] ?? '',
                                ))
                                .toList(),
                                onChanged: (v) => _updateDocumentType(v),
                                hint: S.of(context).document_type,
                                hintStyle: StyleText.fontSize12Weight400.copyWith(
          color: lightMode ? AppColors.secondaryText : AppColors.grey,
        ),
                                fillColor: AppColors.card,
                              ),
                            );
    return isMobile
        ? Column(
            children: [
              statusDropdown,
              SizedBox(height: 15.h),
              docTypeDropdown,
            ],
          )
        : Row(
            children: [
              Expanded(child: statusDropdown),
              SizedBox(width: 15.w),
              Expanded(child: docTypeDropdown),
            ],
          );
  }

  Widget _buildDateRangeSelectors(bool lightMode, BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildDateSelector(true, lightMode, context)),
        SizedBox(width: 15.w),
        Expanded(child: _buildDateSelector(false, lightMode, context)),
      ],
    );
  }

  Widget _buildDateSelector(
    bool isStartDate,
    bool lightMode,
    BuildContext context,
  ) {
    final selectedDate = isStartDate ? _startDate : _endDate;
    final hintText = isStartDate
        ? S.of(context).start_date
        : S.of(context).end_date;

    return GestureDetector(
      onTap: () => _selectDate(isStartDate),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.r),
          color: lightMode
              ? AppColors.background
              : AppColors.chatBackground,
        ),
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: 8.sp,
          vertical: 4.sp,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedDate == null
                    ? hintText
                    : DateFormat('dd/MM/yyyy').format(selectedDate),
                style: StyleText.fontSize12Weight400.copyWith(
                  color: selectedDate == null
                      ? (lightMode
                            ? AppColors.secondaryText
                            : AppColors.grey)
                      : (lightMode
                            ? AppColors.blackButton
                            : AppColors.white),
                ),
              ),
            ),
            CustomSvgImage(
              assetPath: 'assets/icons_assets/main_icons_assets/images_Calendar.svg',
              height: 16.h,
              width: 16.w,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    bool isMobile,
    bool lightMode,
    BuildContext context,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        customButton(
          height: 38.h,
          width: isMobile ? 130.w : 150.w,
          title: S.of(context).reset,
          function: () {
            _resetFilters();
            context.read<ApprovalsCubit>().resetFilters();
            Navigator.of(context).pop();
          },
          color: lightMode ?  AppColors.colorGrey : AppColors.colorGreyDark,
          textStyle: StyleText.fontSize16Weight500.copyWith(
            color: lightMode ? AppColors.colorBlack : AppColors.colorWhite,
          ),
        ),
        SizedBox(width: 45.w),
        customButton(
          height: 38.h,
          width: isMobile ? 130.w : 150.w,
          title: S.of(context).apply,
          function: _applyFilters,
          textStyle: StyleText.fontSize16Weight500.copyWith(
            color: AppColors.textButton,
          ),
        ),
      ],
    );
  }
}
