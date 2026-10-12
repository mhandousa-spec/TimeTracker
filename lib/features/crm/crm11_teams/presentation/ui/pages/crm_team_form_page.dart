// ****************** FILE INFO ******************
// File Name: crm_team_form_page.dart
// Purpose: Add & Edit Team form page with bilingual validation and employee selection.
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';

import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/data/models/crm_team_member_model.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/data/models/crm_team_model.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/domain/enums/crm_team_status_enum.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/presentation/controller/crm_teams_cubit.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/presentation/controller/crm_teams_state.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/presentation/ui/widgets/crm_employee_picker_section.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/presentation/ui/widgets/crm_team_conditions_section.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmTeamFormPage extends StatefulWidget {
  final CrmTeamModel? team;
  final String mode; // 'add' or 'edit'
  final List<CrmTeamModel> existingTeams;

  const CrmTeamFormPage({
    super.key,
    this.team,
    this.mode = 'add',
    this.existingTeams = const <CrmTeamModel>[],
  });

  @override
  State<CrmTeamFormPage> createState() => _CrmTeamFormPageState();
}

class _CrmTeamFormPageState extends State<CrmTeamFormPage> {
  final TextEditingController _nameEnController = TextEditingController();
  final TextEditingController _nameArController = TextEditingController();
  final TextEditingController _noteEnController = TextEditingController();
  final TextEditingController _noteArController = TextEditingController();


  String _teamType = 'Choose';
  CrmTeamMemberModel? _selectedManager;
  final List<CrmTeamMemberModel> _selectedMembers = <CrmTeamMemberModel>[];

  String _selectedCountry = 'Choose';
  String _countryPriority = 'Choose';
  String _selectedLanguage = 'Choose';
  String _languagePriority = 'Choose';
  String _selectedIndustry = 'Choose';
  String _industryPriority = 'Choose';
  String _selectedSector = 'Choose';
  String _sectorPriority = 'Choose';

  String? _teamTypeError;
  String? _nameEnError;
  String? _nameArError;
  String? _managerError;
  String? _membersError;
  bool _submitted = false;

  static const List<String> teamTypeOptions = <String>[
    'Choose',
    'Sales',
    'Marketing',
    'Support',
    'Operations',
    'Consulting',
    'Development',
  ];

  @override
  void initState() {
    super.initState();
    _nameEnController.addListener(_onFieldChanged);
    _nameArController.addListener(_onFieldChanged);
    _noteEnController.addListener(_onFieldChanged);
    _noteArController.addListener(_onFieldChanged);

    final CrmTeamModel? item = widget.team;
    if (item != null) {
      _teamType = item.teamType;
      _nameEnController.text = item.nameEn;
      _nameArController.text = item.nameAr;
      _noteEnController.text = item.noteEn;
      _noteArController.text = item.noteAr;

      if (item.manager != null) {
        _selectedManager = item.manager is CrmTeamMemberModel
            ? item.manager as CrmTeamMemberModel
            : CrmTeamMemberModel.fromEntity(item.manager!);
      }

      _selectedMembers.clear();
      for (final m in item.members) {
        _selectedMembers.add(
          m is CrmTeamMemberModel ? m : CrmTeamMemberModel.fromEntity(m),
        );
      }

      _selectedCountry = item.getConditionValue('Countries');
      _countryPriority = item.getConditionPriority('Countries');
      _selectedLanguage = item.getConditionValue('Preferred Language');
      _languagePriority = item.getConditionPriority('Preferred Language');
      _selectedIndustry = item.getConditionValue('Industry');
      _industryPriority = item.getConditionPriority('Industry');
      _selectedSector = item.getConditionValue('Sector');
      _sectorPriority = item.getConditionPriority('Sector');
    }
  }

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameArController.dispose();
    _noteEnController.dispose();
    _noteArController.dispose();
    super.dispose();
  }

  bool get _isEdit => widget.mode == 'edit';

  void _validateRealtime() {
    final String en = _nameEnController.text.trim();
    final String ar = _nameArController.text.trim();
    final String currentId = widget.team?.id ?? '';

    // 1. English Name real-time validation
    if (en.isEmpty) {
      _nameEnError = _submitted ? 'Field Required' : null;
    } else if (RegExp(r'[\u0600-\u06FF]').hasMatch(en)) {
      _nameEnError = 'This field accepts English letters only';
    } else if (widget.existingTeams.any((CrmTeamModel t) =>
        t.id != currentId && t.nameEn.trim().toLowerCase() == en.toLowerCase())) {
      _nameEnError = 'This Name Exist Before';
    } else {
      _nameEnError = null;
    }

    // 2. Arabic Name real-time validation
    if (ar.isEmpty) {
      _nameArError = _submitted ? 'الحقل مطلوب' : null;
    } else if (RegExp(r'[a-zA-Z]').hasMatch(ar)) {
      _nameArError = 'يقبل هذا الحقل الحروف العربية فقط';
    } else if (widget.existingTeams.any((CrmTeamModel t) =>
        t.id != currentId && t.nameAr.trim() == ar)) {
      _nameArError = 'هذا الاسم موجود من قبل';
    } else {
      _nameArError = null;
    }

    // 3. Dropdown and picker error states (if already submitted)
    if (_submitted) {
      if (_teamType == 'Choose' || _teamType.isEmpty) {
        _teamTypeError = 'Field Required';
      } else {
        _teamTypeError = null;
      }

      if (_selectedManager == null) {
        _managerError = 'Field Required';
      } else {
        _managerError = null;
      }

      if (_selectedMembers.isEmpty) {
        _membersError = 'Field Required';
      } else {
        _membersError = null;
      }
    }
  }

  void _onFieldChanged() {
    _validateRealtime();
    if (mounted) setState(() {});
  }

  bool get _canSubmit {
    final String en = _nameEnController.text.trim();
    final String ar = _nameArController.text.trim();
    final String currentId = widget.team?.id ?? '';

    // 1. Team Type
    if (_teamType == 'Choose' || _teamType.isEmpty) return false;

    // 2. English Name
    if (en.isEmpty) return false;
    if (RegExp(r'[\u0600-\u06FF]').hasMatch(en)) return false;
    if (widget.existingTeams.any((CrmTeamModel t) =>
        t.id != currentId && t.nameEn.trim().toLowerCase() == en.toLowerCase())) {
      return false;
    }

    // 3. Arabic Name
    if (ar.isEmpty) return false;
    if (RegExp(r'[a-zA-Z]').hasMatch(ar)) return false;
    if (widget.existingTeams.any((CrmTeamModel t) =>
        t.id != currentId && t.nameAr.trim() == ar)) {
      return false;
    }

    // 4. Team Manager
    if (_selectedManager == null) return false;

    // 5. Team Members
    if (_selectedMembers.isEmpty) return false;

    return true;
  }

  bool _validateForm() {
    final String en = _nameEnController.text.trim();
    final String ar = _nameArController.text.trim();
    final String currentId = widget.team?.id ?? '';

    // 1. Team Type
    if (_teamType == 'Choose' || _teamType.isEmpty) {
      _teamTypeError = 'Field Required';
    } else {
      _teamTypeError = null;
    }

    // 2. English Name
    if (en.isEmpty) {
      _nameEnError = 'Field Required';
    } else if (RegExp(r'[\u0600-\u06FF]').hasMatch(en)) {
      _nameEnError = 'This field accepts English letters only';
    } else if (widget.existingTeams.any((CrmTeamModel t) =>
        t.id != currentId && t.nameEn.trim().toLowerCase() == en.toLowerCase())) {
      _nameEnError = 'This Name Exist Before';
    } else {
      _nameEnError = null;
    }

    // 3. Arabic Name
    if (ar.isEmpty) {
      _nameArError = 'الحقل مطلوب';
    } else if (RegExp(r'[a-zA-Z]').hasMatch(ar)) {
      _nameArError = 'يقبل هذا الحقل الحروف العربية فقط';
    } else if (widget.existingTeams.any((CrmTeamModel t) =>
        t.id != currentId && t.nameAr.trim() == ar)) {
      _nameArError = 'هذا الاسم موجود من قبل';
    } else {
      _nameArError = null;
    }

    // 4. Team Manager
    if (_selectedManager == null) {
      _managerError = 'Field Required';
    } else {
      _managerError = null;
    }

    // 5. Team Members
    if (_selectedMembers.isEmpty) {
      _membersError = 'Field Required';
    } else {
      _membersError = null;
    }

    setState(() {});
    return _teamTypeError == null &&
        _nameEnError == null &&
        _nameArError == null &&
        _managerError == null &&
        _membersError == null;
  }

  Future<void> _handleSubmit() async {
    _submitted = true;
    if (!_validateForm()) return;

    final CrmTeamModel teamModel = CrmTeamModel(
      id: widget.team?.id ?? '',
      teamType: _teamType,
      nameEn: _nameEnController.text.trim(),
      nameAr: _nameArController.text.trim(),
      manager: _selectedManager,
      members: _selectedMembers,
      noteEn: _noteEnController.text.trim(),
      noteAr: _noteArController.text.trim(),
      conditions: CrmTeamConditionsSection(
        selectedCountry: _selectedCountry,
        countryPriority: _countryPriority,
        selectedLanguage: _selectedLanguage,
        languagePriority: _languagePriority,
        selectedIndustry: _selectedIndustry,
        industryPriority: _industryPriority,
        selectedSector: _selectedSector,
        sectorPriority: _sectorPriority,
      ).toConditionsList(),
      status: widget.team?.status ?? CrmTeamStatus.active,
      createdAt: widget.team?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final CrmTeamsCubit cubit = context.read<CrmTeamsCubit>();
    final bool success = _isEdit
        ? await cubit.updateTeam(teamModel)
        : await cubit.createTeam(teamModel);

    if (success && mounted) {
      CrmControlDialogs.showSuccessDialog(
        context: context,
        title: FormatHelper.localizedString(
          englishName: _isEdit ? 'Team Updated' : 'Team Created',
          arabicName: _isEdit ? 'تم تحديث الفريق' : 'تم إنشاء الفريق',
        ),
        subtitle: FormatHelper.localizedString(
          englishName: '${teamModel.displayName} saved successfully.',
          arabicName: 'تم حفظ ${teamModel.displayName} بنجاح.',
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String pageTitle = _isEdit
        ? FormatHelper.localizedString(
            englishName: 'Edit Team',
            arabicName: 'تعديل الفريق',
          )
        : FormatHelper.localizedString(
            englishName: 'Add Team',
            arabicName: 'إضافة فريق',
          );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: S.current.crm,
        secondTitle: FormatHelper.localizedString(
          englishName: 'Team',
          arabicName: 'الفريق',
        ),
        onFirstTap: () => Navigator.pop(context),
        thirdTitle: pageTitle,
        onSecondTap: () => Navigator.pop(context),
        child: BlocBuilder<CrmTeamsCubit, CrmTeamsState>(
          builder: (BuildContext context, CrmTeamsState state) {
            final List<CrmTeamMemberModel> employees =
                state.availableEmployees;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // 1. Team Details Card
                  _buildTeamDetailsSection(employees),
                  SizedBox(height: 16.sp),

                  // 2. Conditions Details Card
                  CrmTeamConditionsSection(
                    selectedCountry: _selectedCountry,
                    countryPriority: _countryPriority,
                    onCountryChanged: (val) =>
                        setState(() => _selectedCountry = val ?? 'Choose'),
                    onCountryPriorityChanged: (val) =>
                        setState(() => _countryPriority = val ?? 'Choose'),
                    selectedLanguage: _selectedLanguage,
                    languagePriority: _languagePriority,
                    onLanguageChanged: (val) =>
                        setState(() => _selectedLanguage = val ?? 'Choose'),
                    onLanguagePriorityChanged: (val) =>
                        setState(() => _languagePriority = val ?? 'Choose'),
                    selectedIndustry: _selectedIndustry,
                    industryPriority: _industryPriority,
                    onIndustryChanged: (val) =>
                        setState(() => _selectedIndustry = val ?? 'Choose'),
                    onIndustryPriorityChanged: (val) =>
                        setState(() => _industryPriority = val ?? 'Choose'),
                    selectedSector: _selectedSector,
                    sectorPriority: _sectorPriority,
                    onSectorChanged: (val) =>
                        setState(() => _selectedSector = val ?? 'Choose'),
                    onSectorPriorityChanged: (val) =>
                        setState(() => _sectorPriority = val ?? 'Choose'),
                  ),
                  SizedBox(height: 24.sp),

                  // 3. Action Buttons Row
                  _buildActionButtons(state.isLoading),
                  SizedBox(height: 32.sp),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTeamDetailsSection(List<CrmTeamMemberModel> employees) {
    return CrmSectionCard(
      title: FormatHelper.localizedString(
        englishName: 'Team Details',
        arabicName: 'تفاصيل الفريق',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Team Type (Single field in half row)
          buildResponsiveFields(
            context: context,
            left: _buildTeamTypeDropdown(),
            right: const SizedBox.shrink(),
          ),
          SizedBox(height: 16.sp),

          // Team Name Bilingual Pair
          buildResponsiveFields(
            context: context,
            left: CustomTextField(
              controller: _nameEnController,
              label: 'Team Name',
              hint: 'Text Here',
              errorText: _nameEnError,
              onChanged: (_) => _onFieldChanged(),
            ),
            right: Directionality(
              textDirection: TextDirection.rtl,
              child: CustomTextField(
                controller: _nameArController,
                label: 'اسم الفريق',
                hint: 'اكتب هنا',
                textAlign: TextAlign.right,
                errorText: _nameArError,
                onChanged: (_) => _onFieldChanged(),
              ),
            ),
          ),
          SizedBox(height: 16.sp),



          // Team Manager Selection (eligible managers only, single-select)
          CrmEmployeePickerSection(
            title: FormatHelper.localizedString(
              englishName: 'Team Manager',
              arabicName: 'مدير الفريق',
            ),
            employees: employees
                .where((CrmTeamMemberModel e) => e.isManagerEligible)
                .toList(),
            isSelected: (CrmTeamMemberModel e) => _selectedManager?.id == e.id,
            onToggle: (CrmTeamMemberModel e) {
              setState(() {
                _selectedManager =
                    _selectedManager?.id == e.id ? null : e;
                if (_submitted) _validateForm();
              });
            },
            errorText: _managerError,
          ),
          SizedBox(height: 16.sp),

          // Team Members Selection (all employees, multi-select)
          CrmEmployeePickerSection(
            title: FormatHelper.localizedString(
              englishName: 'Team Members',
              arabicName: 'أعضاء الفريق',
            ),
            employees: employees,
            isSelected: (CrmTeamMemberModel e) =>
                _selectedMembers.any((CrmTeamMemberModel m) => m.id == e.id),
            onToggle: (CrmTeamMemberModel e) {
              setState(() {
                final bool alreadyIn =
                    _selectedMembers.any((CrmTeamMemberModel m) => m.id == e.id);
                if (alreadyIn) {
                  _selectedMembers.removeWhere(
                      (CrmTeamMemberModel m) => m.id == e.id);
                } else {
                  _selectedMembers.add(e);
                }
                if (_submitted) _validateForm();
              });
            },
            errorText: _membersError,
          ),
          SizedBox(height: 16.sp),

          // Bilingual Notes Pair
          _buildNotesPair(),
        ],
      ),
    );
  }

  Widget _buildTeamTypeDropdown() {
    return CustomDropdown<String>(
      label: FormatHelper.localizedString(
        englishName: 'Team Type',
        arabicName: 'نوع الفريق',
      ),
      hint: 'Choose',
      value: teamTypeOptions.contains(_teamType) && _teamType != 'Choose'
          ? _teamType
          : null,
      items: teamTypeOptions
          .where((t) => t != 'Choose')
          .map((t) => DropdownItem<String>(value: t, label: t))
          .toList(),
      errorText: _teamTypeError,
      onChanged: (String? val) {
        setState(() {
          _teamType = val ?? 'Choose';
          if (_submitted) _validateForm();
        });
      },
    );
  }




  Widget _buildNotesPair() {
    return buildResponsiveFields(
      context: context,
      left: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Note',
            style: StyleText.fontSize14Weight400,
          ),
          SizedBox(height: 6.sp),
          CustomTextField(
            controller: _noteEnController,
            hint: 'Description',
            maxLines: 3,
          ),
          SizedBox(height: 4.sp),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${_noteEnController.text.length}/500',
              style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.darkGrey,
              ),
            ),
          ),
        ],
      ),
      right: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'ملاحظة',
              style: StyleText.fontSize14Weight400,
            ),
            SizedBox(height: 6.sp),
            CustomTextField(
              controller: _noteArController,
              hint: 'اكتب هنا',
              textAlign: TextAlign.right,
              maxLines: 3,
            ),
            SizedBox(height: 4.sp),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '٥٠٠/${_noteArController.text.length}',
                style: StyleText.fontSize12Weight400.copyWith(
                  color: AppColors.darkGrey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildActionButtons(bool isLoading) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        // Discard Button (Left)
        customButton(
          title: S.current.crmDiscard,
          color: AppColors.grey,
          textColor: AppColors.text,
          function: () => Navigator.pop(context),
        ),

        // Add / Save Button (Right) - inactive until all required & validation are valid
        customButton(
          title: _isEdit ? S.current.crmSave : S.current.crmAdd,
          color: _canSubmit ? AppColors.primary : AppColors.disabledGrey,
          textStyle: StyleText.fontSize14Weight500.copyWith(
            color: _canSubmit ? AppColors.text : AppColors.darkGrey,
          ),
          function: _canSubmit ? _handleSubmit : () {},
        ),
      ],
    );
  }
}

