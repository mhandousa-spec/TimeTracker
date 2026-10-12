// ****************** FILE INFO ******************
// File Name: crm_deals_filter_dialog.dart
// Purpose: Filter modal dialog for CRM Deals matching Figma screenshot 4
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/3-custom_dropdown_calander.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class CrmDealsFilterDialog extends StatefulWidget {
  final String? initialStage;
  final String? initialCategory;
  final double? initialValueFrom;
  final double? initialValueTo;
  final DateTime? initialStartDate;
  final DateTime? initialCloseDate;
  final String? initialEmployee;
  final void Function({
    String? stage,
    String? category,
    double? expectedValueFrom,
    double? expectedValueTo,
    DateTime? startDate,
    DateTime? closeDate,
    String? assignedEmployee,
  }) onApply;

  const CrmDealsFilterDialog({
    super.key,
    this.initialStage,
    this.initialCategory,
    this.initialValueFrom,
    this.initialValueTo,
    this.initialStartDate,
    this.initialCloseDate,
    this.initialEmployee,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    String? initialStage,
    String? initialCategory,
    double? initialValueFrom,
    double? initialValueTo,
    DateTime? initialStartDate,
    DateTime? initialCloseDate,
    String? initialEmployee,
    required void Function({
      String? stage,
      String? category,
      double? expectedValueFrom,
      double? expectedValueTo,
      DateTime? startDate,
      DateTime? closeDate,
      String? assignedEmployee,
    }) onApply,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext ctx) => Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        insetPadding: EdgeInsets.symmetric(horizontal: 24.sp, vertical: 24.sp),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 680.sp),
          child: CrmDealsFilterDialog(
            initialStage: initialStage,
            initialCategory: initialCategory,
            initialValueFrom: initialValueFrom,
            initialValueTo: initialValueTo,
            initialStartDate: initialStartDate,
            initialCloseDate: initialCloseDate,
            initialEmployee: initialEmployee,
            onApply: onApply,
          ),
        ),
      ),
    );
  }

  @override
  State<CrmDealsFilterDialog> createState() => _CrmDealsFilterDialogState();
}

class _CrmDealsFilterDialogState extends State<CrmDealsFilterDialog> {
  String? _stage;
  String? _category;
  late final TextEditingController _valueFromController;
  late final TextEditingController _valueToController;
  DateTime? _startDate;
  DateTime? _closeDate;
  String? _employee;

  final List<String> _stages = <String>[
    'All',
    'New',
    'Discovery',
    'Qualified',
    'Proposal',
    'Negotiation',
    'Closed Lost',
    'Closed Won',
  ];

  final List<String> _categories = <String>[
    'All',
    'ERP System',
    'CRM Integration',
    'Cloud Migration',
  ];

  final List<String> _employees = <String>[
    'All',
    'Ahmed Ali',
    'Mohamed Tarek',
    'Karim Hassan',
    'Nour El-Din',
  ];

  @override
  void initState() {
    super.initState();
    _stage = widget.initialStage;
    _category = widget.initialCategory;
    _valueFromController = TextEditingController(
      text: widget.initialValueFrom != null
          ? widget.initialValueFrom.toString()
          : '',
    );
    _valueToController = TextEditingController(
      text:
          widget.initialValueTo != null ? widget.initialValueTo.toString() : '',
    );
    _startDate = widget.initialStartDate;
    _closeDate = widget.initialCloseDate;
    _employee = widget.initialEmployee;
  }

  @override
  void dispose() {
    _valueFromController.dispose();
    _valueToController.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _stage = null;
      _category = null;
      _valueFromController.clear();
      _valueToController.clear();
      _startDate = null;
      _closeDate = null;
      _employee = null;
    });
  }

  void _submit() {
    final double? fromVal = double.tryParse(_valueFromController.text.trim());
    final double? toVal = double.tryParse(_valueToController.text.trim());

    widget.onApply(
      stage: (_stage == 'All') ? null : _stage,
      category: (_category == 'All') ? null : _category,
      expectedValueFrom: fromVal,
      expectedValueTo: toVal,
      startDate: _startDate,
      closeDate: _closeDate,
      assignedEmployee: (_employee == 'All') ? null : _employee,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: EdgeInsets.all(24.sp),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Header: Filter Icon & Title
            Row(
              children: <Widget>[
                Container(
                  width: 36.sp,
                  height: 36.sp,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: CustomSvgImage(
                    assetPath: AppAssets.filter,
                    width: 18.sp,
                    height: 18.sp,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(width: 12.sp),
                Text(
                  FormatHelper.localizedString(
                    englishName: 'Filter',
                    arabicName: 'تصفية',
                  ),
                  style: StyleText.fontSize16Weight600.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.sp),

            // Form Rows
            if (isMobile) ...<Widget>[
              // Single column on mobile
              _buildStageDropdown(),
              SizedBox(height: 12.sp),
              _buildCategoryDropdown(),
              SizedBox(height: 12.sp),
              _buildValueFromField(),
              SizedBox(height: 12.sp),
              _buildValueToField(),
              SizedBox(height: 12.sp),
              _buildStartDatePicker(),
              SizedBox(height: 12.sp),
              _buildCloseDatePicker(),
              SizedBox(height: 12.sp),
              _buildEmployeeDropdown(),
            ] else ...<Widget>[
              // 2-Column Grid on Tablet / Desktop
              Row(
                children: <Widget>[
                  Expanded(child: _buildStageDropdown()),
                  SizedBox(width: 16.sp),
                  Expanded(child: _buildCategoryDropdown()),
                ],
              ),
              SizedBox(height: 16.sp),
              Row(
                children: <Widget>[
                  Expanded(child: _buildValueFromField()),
                  SizedBox(width: 16.sp),
                  Expanded(child: _buildValueToField()),
                ],
              ),
              SizedBox(height: 16.sp),
              Row(
                children: <Widget>[
                  Expanded(child: _buildStartDatePicker()),
                  SizedBox(width: 16.sp),
                  Expanded(child: _buildCloseDatePicker()),
                ],
              ),
              SizedBox(height: 16.sp),
              Row(
                children: <Widget>[
                  Expanded(child: _buildEmployeeDropdown()),
                  SizedBox(width: 16.sp),
                  const Expanded(child: SizedBox.shrink()),
                ],
              ),
            ],

            SizedBox(height: 32.sp),

            // Bottom Buttons: Reset & Apply
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                customButton(
                  title: FormatHelper.localizedString(
                    englishName: 'Reset',
                    arabicName: 'إعادة ضبط',
                  ),
                  color: AppColors.grey,
                  textColor: AppColors.text,
                  function: _reset,
                ),
                customButton(
                  title: FormatHelper.localizedString(
                    englishName: 'Apply',
                    arabicName: 'تطبيق',
                  ),
                  color: AppColors.primary,
                  textColor: AppColors.text,
                  function: _submit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStageDropdown() {
    return CustomDropdown<String>(
      hint: FormatHelper.localizedString(
        englishName: 'Stage',
        arabicName: 'المرحلة',
      ),
      value: _stage,
      items:
          _stages.map((s) => DropdownItem<String>(value: s, label: s)).toList(),
      fillColor: AppColors.background,
      onChanged: (val) => setState(() => _stage = val),
    );
  }

  Widget _buildCategoryDropdown() {
    return CustomDropdown<String>(
      hint: FormatHelper.localizedString(
        englishName: 'Category',
        arabicName: 'التصنيف',
      ),
      value: _category,
      items: _categories
          .map((c) => DropdownItem<String>(value: c, label: c))
          .toList(),
      fillColor: AppColors.background,
      onChanged: (val) => setState(() => _category = val),
    );
  }

  Widget _buildValueFromField() {
    return CustomTextField(
      controller: _valueFromController,
      hint: FormatHelper.localizedString(
        englishName: 'Expected Value (from)',
        arabicName: 'القيمة المتوقعة (من)',
      ),
      fillColor: AppColors.background,
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildValueToField() {
    return CustomTextField(
      controller: _valueToController,
      hint: FormatHelper.localizedString(
        englishName: 'Expected Value (to)',
        arabicName: 'القيمة المتوقعة (إلى)',
      ),
      fillColor: AppColors.background,
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildStartDatePicker() {
    return CustomDropdownCalendar(
      hint: FormatHelper.localizedString(
        englishName: 'Start Date',
        arabicName: 'تاريخ البدء',
      ),
      value: _startDate,
      fillColor: AppColors.background,
      onChanged: (DateTime? date) => setState(() => _startDate = date),
    );
  }

  Widget _buildCloseDatePicker() {
    return CustomDropdownCalendar(
      hint: FormatHelper.localizedString(
        englishName: 'Close Date',
        arabicName: 'تاريخ الإغلاق',
      ),
      value: _closeDate,
      fillColor: AppColors.background,
      onChanged: (DateTime? date) => setState(() => _closeDate = date),
    );
  }

  Widget _buildEmployeeDropdown() {
    return CustomDropdown<String>(
      hint: FormatHelper.localizedString(
        englishName: 'Assigned Employee',
        arabicName: 'الموظف المسؤول',
      ),
      value: _employee,
      items: _employees
          .map((e) => DropdownItem<String>(value: e, label: e))
          .toList(),
      fillColor: AppColors.background,
      onChanged: (val) => setState(() => _employee = val),
    );
  }
}
