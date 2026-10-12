/// Module: knowledge_hub / presentation / s6_approvals / approval_filter.dart
/// ************************* FILE INFO *************************** ///
/// File Name: approval_filter.dart
/// Purpose: Approval filter — Approvals (S6) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../controller/approvals_cubit.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class ApprovalsFilterDialog extends StatefulWidget {
  const ApprovalsFilterDialog({super.key});

  @override
  State<ApprovalsFilterDialog> createState() => _ApprovalsFilterDialogState();
}

class _ApprovalsFilterDialogState extends State<ApprovalsFilterDialog> {
  String? _selectedStatus;
  String? _selectedDocType;
  DateTime? _startDate;
  DateTime? _endDate;

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

  // ✅ FIXED: Match the exact document types from creation
  List<Map<String, String>> _getDocumentTypeItems(BuildContext context) {
    return [
      {'key': 'Presentation', 'value': S.of(context).presentation},
      {'key': 'Form', 'value': S.of(context).form},
      {'key': 'Report', 'value': S.of(context).report},
      {'key': 'Letter', 'value': S.of(context).letter},
      {'key': 'Video', 'value': S.of(context).video},
      {'key': 'Recording', 'value': S.of(context).recording},
      {'key': 'Booklet', 'value': S.of(context).booklet},
      {'key': 'WorkShop', 'value': S.of(context).workshop},
      {'key': 'Frame Work', 'value': S.of(context).framework},
      {'key': 'Policy', 'value': S.of(context).policy},
      {'key': 'Mandate', 'value': S.of(context).mandate},
      {'key': 'Guidelines', 'value': S.of(context).guidelines},
      {'key': 'Other', 'value': S.of(context).other},
    ];
  }

  // ✅ Build localized status items
  List<Map<String, String>> _getStatusMenuItems(BuildContext context) {
    return [
      {'key': 'Approved', 'value': S.of(context).approved},
      {'key': 'Pending', 'value': S.of(context).pending},
      {'key': 'Rejected', 'value': S.of(context).rejected},
      {'key': 'Removed', 'value': S.of(context).removed},
      {'key': 'Archive', 'value': S.of(context).archive},
    ];
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

    // ✅ Only pass values if they're actually selected
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
    final isMobile = ContextExtension(context).isPhone;
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return Material(
      color: AppColors.transparent,
      child: Container(
        width: isMobile ? 350.w : 411.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: AppColors.card,
        ),
        padding: EdgeInsets.all(isMobile ? 15.w : 15.w),
        //  margin: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, lightMode),
            SizedBox(height: 15.sp),
            _buildDropdowns(isMobile, lightMode, context),
            // SizedBox(height: 15.h),
            //   _buildDateRangeSelectors(lightMode, context),
            SizedBox(height: 15.sp),
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
            assetPath:
                'assets/icons_assets/knowledge_hub_assets/svg_filter.svg',
            width: 16.w,
            height: 16.h,
            color: AppColors.textButton,
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          S.of(context).filter,
          style: StyleText.fontSize16Weight500.copyWith(
            color: lightMode ? AppColors.blackButton : AppColors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdowns(bool isMobile, bool lightMode, BuildContext context) {
    // ✅ Get localized items
    final statusItems = _getStatusMenuItems(context);
    final docTypeItems = _getDocumentTypeItems(context);

    final statusDropdown = SizedBox(
      width: isMobile ? double.infinity : null,
      height: 36,
      child: CustomDropdown<String>(
        // FIXED 12/9/2026 — THE SELECTED VALUE WAS CLIPPED ON PHONES.
        // The trigger is pinned to 36 by the SizedBox above, while the
        // InputDecorator inside asks for its 14.sp value line PLUS the default
        // 10.sp vertical content padding — about 44 on a phone. It does not
        // shrink to fit: it aligns to the top and the bottom of the glyphs is
        // cut off, so a picked value ("Form") rendered as half a word. The hint
        // is 12.sp and fitted, which is why the field only looked broken once
        // something was selected.
        //
        // Trimming the vertical padding is what makes the line fit inside 36;
        // the horizontal 12.sp is the widget's own default, repeated here
        // because triggerPadding replaces the pair.
        triggerPadding: isMobile
            ? EdgeInsets.symmetric(horizontal: 12.sp, vertical: 14.sp)
            : null,
        value: _selectedStatus,
        items: statusItems
            .map((e) => DropdownItem<String>(
                  value: e['key'] ?? '',
                  label: e['value'] ?? '',
                ))
            .toList(),
        onChanged: (v) => _updateStatus(v),
        hint: S.of(context).status,
        hintStyle: StyleText.fontSize12Weight400.copyWith(
          color: lightMode ? AppColors.secondaryText : AppColors.grey,
        ),
        fillColor: AppColors.background,
      ),
    );

    final docTypeDropdown = SizedBox(
      width: isMobile ? double.infinity : null,
      height: 36,
      child: CustomDropdown<String>(
        // FIXED 12/9/2026 — THE SELECTED VALUE WAS CLIPPED ON PHONES.
        // The trigger is pinned to 36 by the SizedBox above, while the
        // InputDecorator inside asks for its 14.sp value line PLUS the default
        // 10.sp vertical content padding — about 44 on a phone. It does not
        // shrink to fit: it aligns to the top and the bottom of the glyphs is
        // cut off, so a picked value ("Form") rendered as half a word. The hint
        // is 12.sp and fitted, which is why the field only looked broken once
        // something was selected.
        //
        // Trimming the vertical padding is what makes the line fit inside 36;
        // the horizontal 12.sp is the widget's own default, repeated here
        // because triggerPadding replaces the pair.
        triggerPadding: isMobile
            ? EdgeInsets.symmetric(horizontal: 12.sp, vertical: 7.sp)
            : null,
        value: _selectedDocType,
        items: docTypeItems
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
        fillColor: AppColors.background,
      ),
    );

    return isMobile
        ? Column(
            children: [
              // statusDropdown,
              // SizedBox(height: 15.h),
              docTypeDropdown,
            ],
          )
        : Row(
            children: [
              // Expanded(child: statusDropdown),
              // SizedBox(width: 15.w),
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
    final hintText =
        isStartDate ? S.of(context).start_date : S.of(context).end_date;

    return GestureDetector(
      onTap: () => _selectDate(isStartDate),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.r),
            color: AppColors.background),
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
                      ? (lightMode ? AppColors.secondaryText : AppColors.grey)
                      : (lightMode ? AppColors.blackButton : AppColors.white),
                ),
              ),
            ),
            CustomSvgImage(
              assetPath:
                  'assets/icons_assets/main_icons_assets/images_Calendar.svg',
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
          color: AppColors.darkGrey,
          textStyle: StyleText.fontSize16Weight500.copyWith(
            color: AppColors.colorWhite,
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
