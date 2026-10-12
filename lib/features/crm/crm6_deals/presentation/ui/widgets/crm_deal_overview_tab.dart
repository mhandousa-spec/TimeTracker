// ****************** FILE INFO ******************
// File Name: crm_deal_overview_tab.dart
// Purpose: Overview tab for Deal Details page with View Mode and Edit Mode matching Figma screenshots 1 and 2
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/13-custom_edit_icon.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/3-custom_dropdown_calander.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/data/models/crm_team_member_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_deal_model.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';
import 'crm_deal_overview_assigned_card.dart';
import 'crm_deal_overview_employee_picker.dart';

class CrmDealOverviewTab extends StatefulWidget {
  final CrmClientDealModel deal;
  final VoidCallback? onSave;

  const CrmDealOverviewTab({
    super.key,
    required this.deal,
    this.onSave,
  });

  @override
  State<CrmDealOverviewTab> createState() => _CrmDealOverviewTabState();
}

class _CrmDealOverviewTabState extends State<CrmDealOverviewTab> {
  bool _isEditMode = false;

  late final TextEditingController _dealNameEnController;
  late final TextEditingController _dealNameArController;
  late final TextEditingController _noteEnController;
  late final TextEditingController _noteArController;
  late final TextEditingController _expectedValueController;
  final TextEditingController _employeeSearchController =
      TextEditingController();

  String? _selectedCategory;
  String? _selectedAssignTo;
  String? _selectedCurrency = 'EGP';
  String? _selectedLikelihood;
  DateTime? _startDate;
  DateTime? _closeDate;
  CrmTeamMemberModel? _selectedEmployee;

  static const List<String> _categories = <String>[
    'ERP System',
    'CRM Solution',
    'POS Software',
    'Cloud Hosting',
    'Consulting',
    'Maintenance',
  ];

  static const List<String> _assignees = <String>[
    'Amro Handousa',
    'Mai Ahmed',
    'Sarah Jenkins',
    'Karim Omar',
  ];

  static const List<String> _currencies = <String>[
    'EGP',
    'USD',
    'EUR',
    'SAR',
    'AED',
  ];

  static const List<String> _likelihoods = <String>[
    '10%',
    '25%',
    '50%',
    '75%',
    '100%',
  ];

  static const List<CrmTeamMemberModel> _mockEmployees = <CrmTeamMemberModel>[
    CrmTeamMemberModel(
      id: 'emp_1',
      name: 'Amro Handousa',
      role: 'CEO',
      department: 'Executive',
      email: 'amro@example.com',
    ),
    CrmTeamMemberModel(
      id: 'emp_2',
      name: 'Amro Handousa',
      role: 'CEO',
      department: 'Executive',
      email: 'amro2@example.com',
    ),
    CrmTeamMemberModel(
      id: 'emp_3',
      name: 'Amro Handousa',
      role: 'CEO',
      department: 'Executive',
      email: 'amro3@example.com',
    ),
    CrmTeamMemberModel(
      id: 'emp_4',
      name: 'Amro Handousa',
      role: 'CEO',
      department: 'Executive',
      email: 'amro4@example.com',
    ),
    CrmTeamMemberModel(
      id: 'emp_5',
      name: 'Amro Handousa',
      role: 'CEO',
      department: 'Executive',
      email: 'amro5@example.com',
    ),
    CrmTeamMemberModel(
      id: 'emp_6',
      name: 'Amro Handousa',
      role: 'CEO',
      department: 'Executive',
      email: 'amro6@example.com',
    ),
    CrmTeamMemberModel(
      id: 'emp_7',
      name: 'Amro Handousa',
      role: 'CEO',
      department: 'Executive',
      email: 'amro7@example.com',
    ),
    CrmTeamMemberModel(
      id: 'emp_8',
      name: 'Amro Handousa',
      role: 'CEO',
      department: 'Executive',
      email: 'amro8@example.com',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _dealNameEnController = TextEditingController(text: widget.deal.dealNameEn);
    _dealNameArController = TextEditingController(text: widget.deal.dealNameAr);
    _noteEnController = TextEditingController(text: widget.deal.noteEn);
    _noteArController = TextEditingController(text: widget.deal.noteAr);
    _expectedValueController = TextEditingController(
      text: widget.deal.expectedValue.toInt().toString(),
    );
    _selectedCategory = widget.deal.category;
    _selectedAssignTo = widget.deal.assignedEmployee;
    _selectedLikelihood = widget.deal.likelihood;
  }

  @override
  void dispose() {
    _dealNameEnController.dispose();
    _dealNameArController.dispose();
    _noteEnController.dispose();
    _noteArController.dispose();
    _expectedValueController.dispose();
    _employeeSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Top Edit Button in View Mode
        if (!_isEditMode) ...<Widget>[
          Align(
            alignment: Alignment.centerRight,
            child: CustomEditIcon(
              title: FormatHelper.localizedString(
                englishName: 'Edit',
                arabicName: 'تعديل',
              ),
              color: AppColors.primary,
              borderColor: Colors.transparent,
              svgColor: AppColors.black,
              textStyle: StyleText.fontSize14Weight500.copyWith(
                fontWeight: FontWeight.bold,
              ),
              onTap: () => setState(() => _isEditMode = true),
            ),
          ),
          SizedBox(height: 16.sp),
        ],

        // Section 1: Deal Details
        CrmSectionCard(
          title: FormatHelper.localizedString(
            englishName: 'Deal Details',
            arabicName: 'تفاصيل الصفقة',
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Category & Assign to
              buildResponsiveFields(
                context: context,
                left: CustomDropdown<String>(
                  label: 'Category',
                  hint: 'Choose',
                  value: _selectedCategory,
                  enabled: _isEditMode,
                  items: _categories
                      .map((String c) =>
                          DropdownItem<String>(value: c, label: c))
                      .toList(),
                  fillColor: AppColors.background,
                  onChanged: (String? val) =>
                      setState(() => _selectedCategory = val),
                ),
                right: CustomDropdown<String>(
                  label: 'Assign to',
                  hint: 'Choose',
                  value: _selectedAssignTo,
                  enabled: _isEditMode,
                  items: _assignees
                      .map((String a) =>
                          DropdownItem<String>(value: a, label: a))
                      .toList(),
                  fillColor: AppColors.background,
                  onChanged: (String? val) =>
                      setState(() => _selectedAssignTo = val),
                ),
              ),

              SizedBox(height: 16.sp),

              // Deal Name Bilingual
              buildResponsiveFields(
                context: context,
                left: CustomTextField(
                  label: 'Deal Name',
                  hint: 'Text Here',
                  controller: _dealNameEnController,
                  readOnly: !_isEditMode,
                  fillColor: AppColors.background,
                ),
                right: Directionality(
                  textDirection: TextDirection.rtl,
                  child: CustomTextField(
                    label: 'اسم الصفقة',
                    hint: 'اكتب هنا',
                    textAlign: TextAlign.right,
                    controller: _dealNameArController,
                    readOnly: !_isEditMode,
                    fillColor: AppColors.background,
                  ),
                ),
              ),

              SizedBox(height: 16.sp),

              // Notes Bilingual
              _buildNotesRow(context),

              SizedBox(height: 16.sp),

              // Expected Value & Currency
              buildResponsiveFields(
                context: context,
                left: CustomTextField(
                  label: 'Expected Value',
                  hint: 'Text Here',
                  controller: _expectedValueController,
                  readOnly: !_isEditMode,
                  keyboardType: TextInputType.number,
                  fillColor: AppColors.background,
                ),
                right: CustomDropdown<String>(
                  label: 'Currency',
                  hint: 'Choose',
                  value: _selectedCurrency,
                  enabled: _isEditMode,
                  items: _currencies
                      .map((String c) =>
                          DropdownItem<String>(value: c, label: c))
                      .toList(),
                  fillColor: AppColors.background,
                  onChanged: (String? val) =>
                      setState(() => _selectedCurrency = val),
                ),
              ),

              SizedBox(height: 16.sp),

              // Likelihood in half-row
              buildResponsiveFields(
                context: context,
                left: CustomDropdown<String>(
                  label: 'Likelihood',
                  hint: 'Choose',
                  value: _selectedLikelihood,
                  enabled: _isEditMode,
                  items: _likelihoods
                      .map((String l) =>
                          DropdownItem<String>(value: l, label: l))
                      .toList(),
                  fillColor: AppColors.background,
                  onChanged: (String? val) =>
                      setState(() => _selectedLikelihood = val),
                ),
                right: const SizedBox.shrink(),
              ),
            ],
          ),
        ),

        SizedBox(height: 24.sp),

        // Section 2: Assigned & Date Details
        CrmSectionCard(
          title: FormatHelper.localizedString(
            englishName: 'Assigned & Date Details',
            arabicName: 'الموظف المعين وتفاصيل التاريخ',
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Dates Row
              buildResponsiveFields(
                context: context,
                left: CustomDropdownCalendar(
                  label: 'Start Date',
                  hint: 'Select Date',
                  value: _startDate,
                  enabled: _isEditMode,
                  fillColor: AppColors.background,
                  onChanged: (DateTime? val) =>
                      setState(() => _startDate = val),
                ),
                right: CustomDropdownCalendar(
                  label: 'Expected Close Date',
                  hint: 'Select Date',
                  value: _closeDate,
                  enabled: _isEditMode,
                  fillColor: AppColors.background,
                  onChanged: (DateTime? val) =>
                      setState(() => _closeDate = val),
                ),
              ),

              SizedBox(height: 20.sp),

              Text(
                'Assigned To',
                style: StyleText.fontSize14Weight500.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.sp),

              // Assigned Employee Details Card in View Mode (Screenshot 1)
              if (!_isEditMode)
                const CrmDealOverviewAssignedCard()
              // Employee Picker Grid in Edit Mode (Screenshot 2)
              else
                CrmDealOverviewEmployeePicker(
                  searchController: _employeeSearchController,
                  employees: _mockEmployees,
                  selectedEmployee: _selectedEmployee,
                  onEmployeeSelected: (CrmTeamMemberModel? emp) {
                    setState(() => _selectedEmployee = emp);
                  },
                  onSearchChanged: () => setState(() {}),
                ),
            ],
          ),
        ),

        // Bottom Discard / Save buttons in Edit Mode (Screenshot 2)
        if (_isEditMode) ...<Widget>[
          SizedBox(height: 32.sp),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              customButton(
                title: FormatHelper.localizedString(
                  englishName: 'Discard',
                  arabicName: 'إلغاء',
                ),
                color: const Color(0xFFE5E7EB),
                borderColor: Colors.transparent,
                textStyle: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.bold,
                ),
                function: () => setState(() => _isEditMode = false),
              ),
              customButton(
                title: FormatHelper.localizedString(
                  englishName: 'Save',
                  arabicName: 'حفظ',
                ),
                color: AppColors.primary,
                borderColor: Colors.transparent,
                textStyle: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.bold,
                ),
                function: () {
                  setState(() => _isEditMode = false);
                  widget.onSave?.call();
                },
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildNotesRow(BuildContext context) {
    return Column(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CustomTextField(
              label: 'Note',
              hint: 'Description',
              controller: _noteEnController,
              readOnly: !_isEditMode,
              fillColor: AppColors.background,
              maxLines: 4,
              onChanged: (_) => setState(() {}),
            ),
            if (_isEditMode) ...<Widget>[
              SizedBox(height: 4.sp),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${_noteEnController.text.length}/500',
                  style: StyleText.fontSize12Weight400.copyWith(
                    color: AppColors.darkGrey,
                    fontSize: 11.sp,
                  ),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 12.sp),
        Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CustomTextField(
                label: 'ملاحظة',
                hint: 'اكتب هنا',
                textAlign: TextAlign.right,
                controller: _noteArController,
                readOnly: !_isEditMode,
                fillColor: AppColors.background,
                maxLines: 4,
                onChanged: (_) => setState(() {}),
              ),
              if (_isEditMode) ...<Widget>[
                SizedBox(height: 4.sp),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${_noteArController.text.length}/500',
                    style: StyleText.fontSize12Weight400.copyWith(
                      color: AppColors.darkGrey,
                      fontSize: 11.sp,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
