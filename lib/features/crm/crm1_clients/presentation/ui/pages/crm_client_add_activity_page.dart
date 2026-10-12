// ****************** FILE INFO ******************
// File Name: crm_client_add_activity_page.dart
// Purpose: Full-page form for Add / Edit / View / Reschedule CRM client activity.
//          Modes: 'add', 'edit', 'view', 'reschedule'
// Author: Mohand Adel
// Created At: 26/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/12-custom_delete_icon.dart';
import 'package:knowticed_plus/core/custom/13-custom_edit_icon.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_activity_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/controller/crm_client_activities_cubit.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/controller/crm_client_activities_state.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_activity_assigned_to_section.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_activity_notes_section.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_activity_status_dropdown.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/data/models/crm_category_model.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/data/models/crm_tag_model.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/generated/l10n.dart';

abstract class _Mode {
  static const String add = 'add';
  static const String edit = 'edit';
  static const String view = 'view';
  static const String reschedule = 'reschedule';
}

class CrmClientAddActivityPage extends StatefulWidget {
  final String clientId;
  final CrmClientActivityModel? existingActivity;
  final String mode;
  final CrmClientActivitiesCubit cubit;

  const CrmClientAddActivityPage({
    super.key,
    required this.clientId,
    required this.cubit,
    this.existingActivity,
    this.mode = _Mode.add,
  });

  @override
  State<CrmClientAddActivityPage> createState() =>
      _CrmClientAddActivityPageState();
}

class _CrmClientAddActivityPageState extends State<CrmClientAddActivityPage> {
  late String _currentMode;

  final TextEditingController _subjectEnController = TextEditingController();
  final TextEditingController _subjectArController = TextEditingController();
  final TextEditingController _noteEnController = TextEditingController();
  final TextEditingController _noteArController = TextEditingController();
  final TextEditingController _employeeSearchController =
      TextEditingController();

  CrmCategoryModel? _selectedCategory;
  String? _selectedTypeId;
  EmployeeEntityPro? _selectedEmployee;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  List<String> _selectedTagIds = <String>[];
  List<String> _selectedTagNames = <String>[];
  String? _dealLabel;

  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _currentMode = widget.mode;
    _populateFromExisting();
  }

  void _populateFromExisting() {
    final CrmClientActivityModel? item = widget.existingActivity;
    if (item == null) return;

    _subjectEnController.text = item.subjectEn;
    _subjectArController.text = item.subjectAr;
    _noteEnController.text = item.noteEn;
    _noteArController.text = item.noteAr;
    _dueDate = item.dueAt;
    _dueTime = TimeOfDay.fromDateTime(item.dueAt);
    _selectedTagIds = List<String>.from(item.tagIds);
    _selectedTagNames = List<String>.from(item.tagNames);
    _dealLabel = item.dealLabel;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final CrmClientActivitiesState s = widget.cubit.state;
      for (final CrmCategoryModel c in s.categories) {
        if (c.id == item.categoryId) {
          setState(() => _selectedCategory = c);
          break;
        }
      }

      for (final EmployeeEntityPro emp in widget.cubit.employees) {
        if (emp.id == item.assigneeId) {
          setState(() => _selectedEmployee = emp);
          break;
        }
      }

      setState(() => _selectedTypeId = item.typeId);
    });
  }

  @override
  void dispose() {
    _subjectEnController.dispose();
    _subjectArController.dispose();
    _noteEnController.dispose();
    _noteArController.dispose();
    _employeeSearchController.dispose();
    super.dispose();
  }

  String _resolveThirdTitle() {
    switch (_currentMode) {
      case _Mode.view:
        return 'Activity';
      case _Mode.edit:
        return FormatHelper.localizedString(
          englishName: 'Edit Activity',
          arabicName: 'تعديل النشاط',
        );
      case _Mode.reschedule:
        return 'Reschedule Activity';
      default:
        return FormatHelper.localizedString(
          englishName: 'Add New Activity',
          arabicName: 'إضافة نشاط جديد',
        );
    }
  }

  bool get _isReadOnly => _currentMode == _Mode.view;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.cubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SideFrameMasterServices(
          titleText: S.current.crmClients,
          secondTitle: FormatHelper.localizedString(
            englishName: 'Activity',
            arabicName: 'الأنشطة',
          ),
          thirdTitle: _resolveThirdTitle(),
          onFirstTap: () => CrmNavigationHelper.pop(context),
          onSecondTap: () => CrmNavigationHelper.pop(context),
          child:
              BlocBuilder<CrmClientActivitiesCubit, CrmClientActivitiesState>(
            builder: (BuildContext ctx, CrmClientActivitiesState state) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (_currentMode == _Mode.view) _buildViewTopActions(),
                    _buildActivityDetailsSection(state),
                    SizedBox(height: 24.sp),
                    if (!_isReadOnly) _buildBottomActions(state),
                    SizedBox(height: 40.sp),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildViewTopActions() {
    final CrmClientActivityModel? item = widget.existingActivity;
    if (item == null) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 16.sp),
      child: Row(
        children: <Widget>[
          CrmActivityStatusDropdown(
            currentStatus: item.status,
            onChanged: (String newStatus) async {
              await widget.cubit.save(item.copyWith(status: newStatus));
              if (mounted) Navigator.of(context).pop(true);
            },
          ),
          const Spacer(),
          CustomEditIcon(
            onTap: () => setState(() => _currentMode = _Mode.edit),
          ),
          SizedBox(width: 12.sp),
          CustomDeleteIcon(
            color: AppColors.red,
            svgColor: AppColors.black,
            textStyle: StyleText.fontSize14Weight600,
            onTap: _handleDelete,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityDetailsSection(CrmClientActivitiesState state) {
    return CrmSectionCard(
      title: FormatHelper.localizedString(
        englishName: 'Activity Details',
        arabicName: 'تفاصيل النشاط',
      ),
      cardColor: AppColors.white,
      showHideToggle: false,
      padding: EdgeInsets.all(16.sp),
      borderRadius: BorderRadius.circular(8.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildCategoryAndTypeRow(state),
          SizedBox(height: 16.sp),
          _buildSubjectRow(),
          SizedBox(height: 16.sp),
          CrmActivityAssignedToSection(
            allEmployees: widget.cubit.employees,
            selectedEmployee: _selectedEmployee,
            onEmployeeSelected: (EmployeeEntityPro? emp) {
              setState(() => _selectedEmployee = emp);
            },
            searchController: _employeeSearchController,
            isReadOnly: _isReadOnly,
            isSubmitted: _submitted,
          ),
          SizedBox(height: 16.sp),
          _buildDueDateAndTimeRow(),
          SizedBox(height: 16.sp),
          _buildTagsAndDealRow(state),
          SizedBox(height: 16.sp),
          CrmActivityNotesSection(
            noteEnController: _noteEnController,
            noteArController: _noteArController,
            isReadOnly: _isReadOnly,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryAndTypeRow(CrmClientActivitiesState state) {
    final String? categoryError =
        _submitted && _selectedCategory == null ? 'Field Required' : null;
    final String? typeError =
        _submitted && _selectedTypeId == null ? 'Field Required' : null;

    final Widget leftField = _labeledField(
      label: 'Activity Category',
      child: CustomDropdown<String>(
        hint: 'Choose',
        value: _selectedCategory?.id,
        items: state.categories
            .map((CrmCategoryModel c) => DropdownItem<String>(
                  value: c.id,
                  label: c.nameEn,
                ))
            .toList(),
        onChanged: _isReadOnly
            ? null
            : (String? catId) {
                CrmCategoryModel? found;
                for (final CrmCategoryModel c in state.categories) {
                  if (c.id == catId) {
                    found = c;
                    break;
                  }
                }
                setState(() {
                  _selectedCategory = found;
                  _selectedTypeId = null;
                });
              },
        errorText: categoryError,
      ),
    );

    final Widget rightField = _labeledField(
      label: 'Activity Type',
      child: CustomDropdown<String>(
        hint: 'Choose',
        value: _selectedTypeId,
        items: (_selectedCategory?.types ?? const <dynamic>[])
            .map((dynamic t) => DropdownItem<String>(
                  value: t.id as String,
                  label: t.nameEn as String,
                ))
            .toList(),
        onChanged: (_isReadOnly || _selectedCategory == null)
            ? null
            : (String? v) {
                setState(() => _selectedTypeId = v);
              },
        errorText: typeError,
      ),
    );

    return buildResponsiveFields(
      context: context,
      left: leftField,
      right: rightField,
    );
  }

  Widget _buildSubjectRow() {
    final String? enError =
        _submitted && _subjectEnController.text.trim().isEmpty
            ? 'Field Required'
            : null;
    final String? arError =
        _submitted && _subjectArController.text.trim().isEmpty
            ? 'الحقل مطلوب'
            : null;

    final Widget leftField = _labeledField(
      label: 'Subject',
      child: CustomTextField(
        controller: _subjectEnController,
        hint: 'Text Here',
        readOnly: _isReadOnly,
        errorText: enError,
      ),
    );

    final Widget rightField = _labeledField(
      label: 'الموضوع',
      isRtl: true,
      child: CustomTextField(
        controller: _subjectArController,
        hint: 'اكتب هنا',
        textAlign: TextAlign.right,
        readOnly: _isReadOnly,
        errorText: arError,
      ),
    );

    return buildResponsiveFields(
      context: context,
      left: leftField,
      right: rightField,
    );
  }

  Widget _buildDueDateAndTimeRow() {
    final String? dueDateError =
        _submitted && _dueDate == null ? 'Field Required' : null;
    final String? dueTimeError =
        _submitted && _dueTime == null ? 'Field Required' : null;

    final String dueDateText =
        _dueDate != null ? DateFormat('dd/MM/yyyy').format(_dueDate!) : '';
    final String dueTimeText =
        _dueTime != null ? _dueTime!.format(context) : '';

    final Widget leftField = _labeledField(
      label: 'Due Date',
      child: InkWell(
        onTap: _isReadOnly ? null : _pickDate,
        child: IgnorePointer(
          child: CustomTextField(
            controller: TextEditingController(text: dueDateText),
            hint: 'Select Date',
            suffixIcon: CustomSvgImage(
              assetPath: AppAssets.calendar,
              width: 16.sp,
              height: 16.sp,
            ),
            errorText: dueDateError,
          ),
        ),
      ),
    );

    final Widget rightField = _labeledField(
      label: 'Time',
      child: InkWell(
        onTap: _isReadOnly ? null : _pickTime,
        child: IgnorePointer(
          child: CustomTextField(
            controller: TextEditingController(text: dueTimeText),
            hint: 'Select Time',
            suffixIcon: const Icon(Icons.access_time_outlined),
            errorText: dueTimeError,
          ),
        ),
      ),
    );

    return buildResponsiveFields(
      context: context,
      left: leftField,
      right: rightField,
    );
  }

  Widget _buildTagsAndDealRow(CrmClientActivitiesState state) {
    final Widget leftField = _labeledField(
      label: 'Tags',
      child: CustomDropdown<String>(
        hint: 'Choose',
        value: _selectedTagIds.isNotEmpty ? _selectedTagIds.first : null,
        items: state.tags
            .map((CrmTagModel t) => DropdownItem<String>(
                  value: t.id,
                  label: t.nameEn,
                ))
            .toList(),
        onChanged: _isReadOnly
            ? null
            : (String? tagId) {
                if (tagId == null) return;
                CrmTagModel? found;
                for (final CrmTagModel t in state.tags) {
                  if (t.id == tagId) {
                    found = t;
                    break;
                  }
                }
                if (found != null) {
                  setState(() {
                    if (!_selectedTagIds.contains(tagId)) {
                      _selectedTagIds = <String>[..._selectedTagIds, tagId];
                      _selectedTagNames = <String>[
                        ..._selectedTagNames,
                        found!.nameEn,
                      ];
                    }
                  });
                }
              },
      ),
    );

    final Widget rightField = _labeledField(
      label: 'Deal',
      child: CustomDropdown<String>(
        hint: 'Choose',
        value: _dealLabel,
        items: const <DropdownItem<String>>[],
        onChanged:
            _isReadOnly ? null : (String? v) => setState(() => _dealLabel = v),
      ),
    );

    return buildResponsiveFields(
      context: context,
      left: leftField,
      right: rightField,
    );
  }

  Widget _buildBottomActions(CrmClientActivitiesState state) {
    final bool isSaving = state.isSaving;

    if (_currentMode == _Mode.reschedule || _currentMode == _Mode.edit) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          customButton(
            title: FormatHelper.localizedString(
              englishName: 'Discard',
              arabicName: 'تراجع',
            ),
            color: AppColors.grey,
            textColor: AppColors.text,
            textStyle: StyleText.fontSize16Weight600,
            exactWidth: 150.sp,
            function: () => Navigator.of(context).pop(),
          ),
          customButton(
            title: FormatHelper.localizedString(
              englishName: 'Save',
              arabicName: 'حفظ',
            ),
            color: AppColors.primary,
            textColor: AppColors.black,
            textStyle: StyleText.fontSize16Weight600,
            exactWidth: 150.sp,
            function: isSaving ? () {} : _handleSave,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            customButton(
              title: 'Discard',
              color: AppColors.grey,
              textColor: AppColors.text,
              textStyle: StyleText.fontSize16Weight600,
              exactWidth: 150.sp,
              function: () => Navigator.of(context).pop(),
            ),
            customButton(
              title: 'Add',
              color: AppColors.primary,
              textColor: AppColors.black,
              textStyle: StyleText.fontSize16Weight600,
              exactWidth: 150.sp,
              function: isSaving ? () {} : _handleSave,
            ),
          ],
        ),
        SizedBox(height: 16.sp),
        customButton(
          title: 'Save For Later',
          color: AppColors.darkGrey,
          textColor: AppColors.white,
          textStyle: StyleText.fontSize16Weight600.copyWith(
            color: AppColors.white,
          ),
          exactWidth: 150.sp,
          function: isSaving ? () {} : _handleSaveDraft,
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _dueTime = picked);
  }

  Future<void> _handleSave() async {
    setState(() => _submitted = true);
    if (!_validate(isDraft: false)) return;
    await _persist(status: widget.existingActivity?.status ?? 'scheduled');
  }

  Future<void> _handleSaveDraft() async {
    await _persist(status: 'draft');
  }

  bool _validate({required bool isDraft}) {
    if (isDraft) return true;
    return _selectedCategory != null &&
        _selectedTypeId != null &&
        _subjectEnController.text.trim().isNotEmpty &&
        _subjectArController.text.trim().isNotEmpty &&
        _selectedEmployee != null &&
        _dueDate != null &&
        _dueTime != null;
  }

  Future<void> _persist({required String status}) async {
    final DateTime dueDateTime = _buildDueDateTime();
    final String typeId = _selectedTypeId ?? '';
    String typeName = '';
    if (_selectedCategory != null) {
      for (final dynamic t in _selectedCategory!.types) {
        if ((t.id as String) == typeId) {
          typeName = t.nameEn as String;
          break;
        }
      }
    }
    final CrmClientActivityModel activity = CrmClientActivityModel(
      id: widget.existingActivity?.id ?? '',
      clientId: widget.clientId,
      categoryId: _selectedCategory?.id ?? '',
      categoryName: _selectedCategory?.nameEn ?? '',
      typeId: typeId,
      typeName: typeName,
      subjectEn: _subjectEnController.text.trim(),
      subjectAr: _subjectArController.text.trim(),
      assigneeId: _selectedEmployee?.id ?? '',
      assigneeName:
          '${_selectedEmployee?.firstName ?? ''} ${_selectedEmployee?.lastName ?? ''}'
              .trim(),
      assigneeRole: _selectedEmployee?.title ?? _selectedEmployee?.role,
      tagIds: _selectedTagIds,
      tagNames: _selectedTagNames,
      dealLabel: _dealLabel,
      noteEn: _noteEnController.text,
      noteAr: _noteArController.text,
      dueAt: dueDateTime,
      status: status,
      audit: widget.existingActivity?.audit,
    );

    final bool success = await widget.cubit.save(activity);
    if (success && mounted) Navigator.of(context).pop(true);
  }

  DateTime _buildDueDateTime() {
    final DateTime base = _dueDate ?? DateTime.now();
    final TimeOfDay time = _dueTime ?? TimeOfDay.now();
    return DateTime(base.year, base.month, base.day, time.hour, time.minute);
  }

  void _handleDelete() {
    final CrmClientActivityModel? item = widget.existingActivity;
    if (item == null) return;
    CrmControlDialogs.showRemoveDialog(
      context: context,
      title: 'Delete Activity',
      subtitle:
          'Are you sure you want to delete "${item.subjectEn.isNotEmpty ? item.subjectEn : item.subjectAr}"?',
      onConfirm: () async {
        await widget.cubit.remove(item.id);
        if (mounted) Navigator.of(context).pop(true);
      },
    );
  }

  Widget _labeledField({
    required String label,
    required Widget child,
    bool isRtl = false,
  }) {
    return Column(
      crossAxisAlignment:
          isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: StyleText.fontSize14Weight400.copyWith(
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 6.sp),
        child,
      ],
    );
  }
}
