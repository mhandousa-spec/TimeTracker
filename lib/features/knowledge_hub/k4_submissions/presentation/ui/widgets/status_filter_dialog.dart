/// Module: knowledge_hub / presentation / s4_submissions / widgets/status_filter_dialog.dart
/// ************************* FILE INFO *************************** ///
/// File Name: status_filter_dialog.dart
/// Purpose: Status filter dialog — Submissions (S4) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'dart:developer';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/custom/53-custom_date_pic.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../controller/submissions_cubit.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class StatusFilterDialog extends StatefulWidget {
  const StatusFilterDialog({super.key});

  @override
  State<StatusFilterDialog> createState() => _StatusFilterDialogState();
}

/// The one set of metrics every control in this dialog is built from.
///
/// ADDED 22/9/2026 — "equalize the field size + same color".
///
/// The dropdowns and the two date boxes were each sized by hand and did not
/// agree: the dropdowns pinned themselves to `SizedBox(height: 36)` and passed
/// `triggerPadding` of 8 vertical / 12 horizontal, while the date boxes pinned
/// the same 36 but carried NO vertical padding and 16/12 horizontal. Two
/// controls standing side by side, sized two different ways, drift apart on
/// any text scale or locale even when the numbers happen to line up at one
/// size.
///
/// The fixed height is gone. Padding decides the height now, so all four boxes
/// are `12.sp + one line + 12.sp` by construction and cannot drift. Note that
/// a pinned `height` on [CustomDropdown] would FORCE its vertical padding to
/// zero (see `pinnedHeight` in 1-custom_dropdown.dart) — which is exactly why
/// the requested 12.sp had to replace the height rather than join it.
EdgeInsets _kFieldPadding() =>
    EdgeInsets.symmetric(vertical: 12.sp, horizontal: 12.sp);

class _StatusFilterDialogState extends State<StatusFilterDialog> {
  String? _selectedStatus;
  String? _selectedDocType;
  DateTime? _startDate;
  DateTime? _endDate;

  final DatePicker _datePicker = DatePicker(); // ✅ Initialize DatePicker

  @override
  void initState() {
    super.initState();
    _loadInitialFilterValues();
  }

  void _loadInitialFilterValues() {
    final cubit = context.read<SubmissionsCubit>();
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
      {'key': 'Published', 'value': S.of(context).published},
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
    final cubit = context.read<SubmissionsCubit>();

    // ✅ FIXED: Only pass values if they're actually selected
    cubit.applyFilters(
      documentType: _selectedDocType,
      status: _selectedStatus,
      startDate: _startDate,
      endDate: _endDate,
    );
    Navigator.of(context).pop();
  }

  // ✅ UPDATED: Use DatePicker class instead of showDatePicker
  Future<void> _selectDate(bool isStartDate) async {
    DateTime? currentDate = isStartDate ? _startDate : _endDate;

    final pickedDates = await _datePicker.showDatePicker(
      context,
      [currentDate], // Pass current date as list
      currentDate,
      CalendarDatePicker2Type.single, // Single date selection
    );

    if (pickedDates != null && pickedDates.isNotEmpty && pickedDates[0] != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDates[0];
        } else {
          _endDate = pickedDates[0];
        }
      });
      log('${isStartDate ? 'Start' : 'End'} date: ${pickedDates[0].toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ContextExtension(context).isPhone;
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

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, lightMode),
            SizedBox(height: 15.sp),
            _buildDropdowns(isMobile, lightMode, context),
            SizedBox(height: 15.sp),
            _buildDateRangeSelectors(lightMode, context),
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
            assetPath: 'assets/icons_assets/knowledge_hub_assets/knowlege_module_Tuning.svg',
            width: 16.w,
            height: 16.h,
            color: AppColors.textButton,
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          S.of(context).filter,
          style: StyleText.fontSize16Weight500.copyWith(
            color:
            lightMode ? AppColors.blackButton : AppColors.white,
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
                             child: CustomDropdown<String>(
                               value: _selectedStatus,
                               triggerPadding: _kFieldPadding(),
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
                               fillColor: AppColors.background, // 28/9/2026: KH p.18
                             ),
                           );

    final docTypeDropdown = SizedBox(
                              width: isMobile ? double.infinity : null,
                              child: CustomDropdown<String>(
                                triggerPadding: _kFieldPadding(),

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
                                maxOverlayHeight: 216.0,
                                fillColor: AppColors.background, // 28/9/2026: KH p.18
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
    return ContextExtension(context).isPhone ? Column(
      children: [
        _buildDateSelector(true, lightMode, context),
        SizedBox(height: 15.w),
        _buildDateSelector(false, lightMode, context),
      ],
    ) : Row(
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
    isStartDate ? S.of(context).publishDate : S.of(context).archiveDate;

    // Built to the same three rules as the dropdowns above it — see
    // [_kFieldPadding]: no fixed height, 12.sp vertical padding, and the
    // dropdown's own fill colour rather than a hand-picked match for it.
    return GestureDetector(
      onTap: () => _selectDate(isStartDate),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.r),
          // CHANGED 28/9/2026 (Knowledge Hub p.18): AppColors.background,
          // matching the two dropdowns above.
          color: AppColors.background,
        ),
        padding: _kFieldPadding(),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedDate == null
                    ? hintText
                    : DateFormat('dd MMM yyyy').format(selectedDate),
                style: StyleText.fontSize12Weight400.copyWith(
                  color: selectedDate == null
                      ? AppColors.secondaryText.withOpacity(.5)
                      : (lightMode
                      ? AppColors.blackButton
                      : AppColors.white),
                ),
              ),
            ),
            // 20.sp and the dropdown's own trailing-icon colour, so the
            // calendar glyph and the chevron beside it are the same size and
            // the same shade — including the way both dim while the field is
            // still empty.
            CustomSvgImage(
              assetPath: 'assets/icons_assets/main_icons_assets/images_Calendar.svg',
              height: 20.sp,
              width: 20.sp,
              color: kDropdownTrailingIconColor(hasValue: selectedDate != null),
              fit: BoxFit.contain,
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
            context.read<SubmissionsCubit>().resetFilters();
            Navigator.of(context).pop();
          },
          color: AppColors.darkGrey,
          textStyle: StyleText.fontSize16Weight500.copyWith(
            color: AppColors.white,
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