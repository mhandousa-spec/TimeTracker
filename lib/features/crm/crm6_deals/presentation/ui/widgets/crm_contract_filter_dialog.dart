// ****************** FILE INFO ******************
// File Name: crm_contract_filter_dialog.dart
// Purpose: Contract Filter dialog matching Figma screenshot with Version, Employee, Date from, Date to, Reset and Apply actions
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class CrmContractFilterState {
  final String? version;
  final String? employee;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const CrmContractFilterState({
    this.version,
    this.employee,
    this.dateFrom,
    this.dateTo,
  });

  bool get isActive =>
      (version != null && version != 'Versions') ||
      (employee != null && employee != 'By Employee') ||
      dateFrom != null ||
      dateTo != null;
}

class CrmContractFilterDialog extends StatefulWidget {
  final CrmContractFilterState initialState;
  final ValueChanged<CrmContractFilterState> onApply;

  const CrmContractFilterDialog({
    super.key,
    required this.initialState,
    required this.onApply,
  });

  static Future<CrmContractFilterState?> show({
    required BuildContext context,
    required CrmContractFilterState initialState,
  }) {
    return showDialog<CrmContractFilterState>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext ctx) => CrmContractFilterDialog(
        initialState: initialState,
        onApply: (CrmContractFilterState state) => Navigator.pop(ctx, state),
      ),
    );
  }

  @override
  State<CrmContractFilterDialog> createState() =>
      _CrmContractFilterDialogState();
}

class _CrmContractFilterDialogState extends State<CrmContractFilterDialog> {
  late String _selectedVersion;
  late String _selectedEmployee;
  DateTime? _dateFrom;
  DateTime? _dateTo;

  static const List<String> _versionOptions = <String>[
    'Versions',
    'Version 1.0',
    'Version 2.0',
    'Version 3.0',
    'Draft',
  ];

  static const List<String> _employeeOptions = <String>[
    'By Employee',
    'Aya Ahmed',
    'Amro Handousa',
    'Sara Ahmed',
    'Ahmed Handousa',
  ];

  @override
  void initState() {
    super.initState();
    _selectedVersion = widget.initialState.version ?? 'Versions';
    _selectedEmployee = widget.initialState.employee ?? 'By Employee';
    _dateFrom = widget.initialState.dateFrom;
    _dateTo = widget.initialState.dateTo;
  }

  Future<void> _pickDateFrom() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateFrom ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _dateFrom = picked);
    }
  }

  Future<void> _pickDateTo() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateTo ?? _dateFrom ?? now,
      firstDate: _dateFrom ?? DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _dateTo = picked);
    }
  }

  void _onReset() {
    setState(() {
      _selectedVersion = 'Versions';
      _selectedEmployee = 'By Employee';
      _dateFrom = null;
      _dateTo = null;
    });
  }

  void _onApply() {
    widget.onApply(
      CrmContractFilterState(
        version: _selectedVersion,
        employee: _selectedEmployee,
        dateFrom: _dateFrom,
        dateTo: _dateTo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      backgroundColor: AppColors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.sp, vertical: 24.sp),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 540.sp),
        child: Padding(
          padding: EdgeInsets.all(20.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // ── Header: Yellow circle icon + Filter title ──────────────────
              Row(
                children: <Widget>[
                  Container(
                    width: 28.sp,
                    height: 28.sp,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.tune_rounded,
                      size: 16.sp,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(width: 10.sp),
                  Text(
                    FormatHelper.localizedString(
                      englishName: 'Filter',
                      arabicName: 'تصفية',
                    ),
                    style: StyleText.fontSize16Weight600.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.sp),

              // ── Row 1: Versions & By Employee Dropdowns ─────────────────────
              Row(
                children: <Widget>[
                  Expanded(
                    child: _buildDropdownField(
                      value: _selectedVersion,
                      items: _versionOptions,
                      onChanged: (String val) =>
                          setState(() => _selectedVersion = val),
                    ),
                  ),
                  SizedBox(width: 14.sp),
                  Expanded(
                    child: _buildDropdownField(
                      value: _selectedEmployee,
                      items: _employeeOptions,
                      onChanged: (String val) =>
                          setState(() => _selectedEmployee = val),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.sp),

              // ── Row 2: Date from & Date to Pickers ──────────────────────────
              Row(
                children: <Widget>[
                  Expanded(
                    child: _buildDateField(
                      label: FormatHelper.localizedString(
                        englishName: 'Date from',
                        arabicName: 'من تاريخ',
                      ),
                      date: _dateFrom,
                      onTap: _pickDateFrom,
                    ),
                  ),
                  SizedBox(width: 14.sp),
                  Expanded(
                    child: _buildDateField(
                      label: FormatHelper.localizedString(
                        englishName: 'Date to',
                        arabicName: 'إلى تاريخ',
                      ),
                      date: _dateTo,
                      onTap: _pickDateTo,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24.sp),

              // ── Row 3: Action Buttons (Reset & Apply) ───────────────────────
              Row(
                children: <Widget>[
                  // Reset Button
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: _onReset,
                      borderRadius: BorderRadius.circular(8.r),
                      child: Container(
                        height: 42.sp,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          FormatHelper.localizedString(
                            englishName: 'Reset',
                            arabicName: 'إعادة تعيين',
                          ),
                          style: StyleText.fontSize14Weight500.copyWith(
                            color: AppColors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.sp),

                  // Spacer to push Apply to right (or give Apply prominence)
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: _onApply,
                      borderRadius: BorderRadius.circular(8.r),
                      child: Container(
                        height: 42.sp,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          FormatHelper.localizedString(
                            englishName: 'Apply',
                            arabicName: 'تطبيق',
                          ),
                          style: StyleText.fontSize14Weight500.copyWith(
                            color: AppColors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      height: 42.sp,
      padding: EdgeInsets.symmetric(horizontal: 14.sp),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.darkGrey,
            size: 20.sp,
          ),
          style: StyleText.fontSize12Weight400.copyWith(
            color: AppColors.black,
          ),
          dropdownColor: AppColors.white,
          borderRadius: BorderRadius.circular(8.r),
          items: items.map((String item) {
            final bool isPlaceholder =
                item == 'Versions' || item == 'By Employee';
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: StyleText.fontSize12Weight400.copyWith(
                  color: isPlaceholder ? AppColors.darkGrey : AppColors.black,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? val) {
            if (val != null) onChanged(val);
          },
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    final String displayText =
        date != null ? DateFormat('d MMM yyyy').format(date) : label;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        height: 42.sp,
        padding: EdgeInsets.symmetric(horizontal: 14.sp),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              displayText,
              style: StyleText.fontSize12Weight400.copyWith(
                color: date != null ? AppColors.black : AppColors.darkGrey,
              ),
            ),
            CustomSvgImage(
              assetPath: AppAssets.calendar,
              width: 16.sp,
              height: 16.sp,
              color: AppColors.darkGrey,
            ),
          ],
        ),
      ),
    );
  }
}
