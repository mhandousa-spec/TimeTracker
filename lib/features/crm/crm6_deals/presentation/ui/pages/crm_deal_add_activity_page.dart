// ****************** FILE INFO ******************
// File Name: crm_deal_add_activity_page.dart
// Purpose: Full-page form for Add / View / Edit / Reschedule Activity in Deals matching Figma screenshots
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/12-custom_delete_icon.dart';
import 'package:knowticed_plus/core/custom/13-custom_edit_icon.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_activity_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_deal_activity_form_details.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_deal_activity_status_dropdown_button.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_deal_cancel_activity_dialog.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/data/models/crm_team_member_model.dart';

class CrmDealAddActivityPage extends StatefulWidget {
  final String dealTitle;
  final String mode; // 'add', 'view', 'edit', 'reschedule'
  final CrmDealActivityModel? activity;
  final ValueChanged<CrmDealActivityModel>? onActivityAdded;
  final ValueChanged<CrmDealActivityModel>? onActivityUpdated;
  final ValueChanged<String>? onActivityDeleted;

  const CrmDealAddActivityPage({
    super.key,
    this.dealTitle = 'ERP System Deal',
    this.mode = 'add',
    this.activity,
    this.onActivityAdded,
    this.onActivityUpdated,
    this.onActivityDeleted,
  });

  @override
  State<CrmDealAddActivityPage> createState() => _CrmDealAddActivityPageState();
}

class _CrmDealAddActivityPageState extends State<CrmDealAddActivityPage> {
  late String _currentMode;
  late CrmDealActivityStatus _currentStatus;

  final TextEditingController _subjectEnController = TextEditingController();
  final TextEditingController _subjectArController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  final TextEditingController _dueTimeController = TextEditingController();
  final TextEditingController _noteEnController = TextEditingController();
  final TextEditingController _noteArController = TextEditingController();
  final TextEditingController _employeeSearchController =
      TextEditingController();

  String? _selectedActivityType;
  String? _selectedTag;
  CrmTeamMemberModel? _selectedEmployee;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool _submitted = false;

  static const List<String> _activityTypes = <String>[
    'Communication',
    'Call',
    'Meeting',
    'Task',
    'Follow up',
    'Email',
  ];

  static const List<String> _tags = <String>[
    'Deals',
    'VIP',
    'Urgent',
    'Follow up',
    'Product Demo',
  ];

  final List<CrmTeamMemberModel> _employees = const <CrmTeamMemberModel>[
    CrmTeamMemberModel(
      id: '1',
      name: 'Amro Handousa',
      role: 'CEO',
      avatarUrl: AppAssets.defaultEmployeeAvatar,
    ),
    CrmTeamMemberModel(
      id: '2',
      name: 'Amro Handousa',
      role: 'CEO',
      avatarUrl: AppAssets.defaultEmployeeAvatar,
    ),
    CrmTeamMemberModel(
      id: '3',
      name: 'Amro Handousa',
      role: 'CEO',
      avatarUrl: AppAssets.defaultEmployeeAvatar,
    ),
    CrmTeamMemberModel(
      id: '4',
      name: 'Amro Handousa',
      role: 'CEO',
      avatarUrl: AppAssets.defaultEmployeeAvatar,
    ),
    CrmTeamMemberModel(
      id: '5',
      name: 'Amro Handousa',
      role: 'CEO',
      avatarUrl: AppAssets.defaultEmployeeAvatar,
    ),
    CrmTeamMemberModel(
      id: '6',
      name: 'Amro Handousa',
      role: 'CEO',
      avatarUrl: AppAssets.defaultEmployeeAvatar,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentMode = widget.mode;
    _currentStatus = widget.activity?.status ?? CrmDealActivityStatus.scheduled;
    _populateFromActivity();
  }

  void _populateFromActivity() {
    final CrmDealActivityModel? act = widget.activity;
    if (act != null) {
      _selectedActivityType =
          act.activityType.isNotEmpty ? act.activityType : 'Communication';
      _subjectEnController.text = act.subjectEn;
      _subjectArController.text = act.subjectAr;
      _dueDateController.text = act.dueDate;
      _dueTimeController.text = act.time;
      _selectedTag = act.tags.isNotEmpty ? act.tags : 'Deals';
      _noteEnController.text = act.noteEn;
      _noteArController.text = act.noteAr;
      _selectedEmployee = _employees.firstWhere(
        (CrmTeamMemberModel e) => e.name == act.assigneeName,
        orElse: () => _employees.first,
      );
    }
  }

  @override
  void dispose() {
    _subjectEnController.dispose();
    _subjectArController.dispose();
    _dueDateController.dispose();
    _dueTimeController.dispose();
    _noteEnController.dispose();
    _noteArController.dispose();
    _employeeSearchController.dispose();
    super.dispose();
  }

  bool get _isReadOnly => _currentMode == 'view';

  String _resolveThirdTitle() {
    switch (_currentMode) {
      case 'view':
        return FormatHelper.localizedString(
          englishName: 'Activity',
          arabicName: 'النشاط',
        );
      case 'edit':
        return FormatHelper.localizedString(
          englishName: 'Edit Activity',
          arabicName: 'تعديل النشاط',
        );
      case 'reschedule':
        return FormatHelper.localizedString(
          englishName: 'Reschedule Activity',
          arabicName: 'إعادة جدولة النشاط',
        );
      case 'add':
      default:
        return FormatHelper.localizedString(
          englishName: 'Add New Activity',
          arabicName: 'إضافة نشاط جديد',
        );
    }
  }

  Future<void> _pickDate() async {
    if (_isReadOnly) return;
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dueDateController.text = DateFormat('d/M/yyyy').format(picked);
      });
    }
  }

  Future<void> _pickTime() async {
    if (_isReadOnly) return;
    final TimeOfDay now = TimeOfDay.now();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? now,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        final MaterialLocalizations localizations =
            MaterialLocalizations.of(context);
        _dueTimeController.text =
            localizations.formatTimeOfDay(picked, alwaysUse24HourFormat: false);
      });
    }
  }

  void _onSaveOrAdd() {
    setState(() => _submitted = true);

    if (_selectedActivityType == null ||
        _subjectEnController.text.trim().isEmpty ||
        _subjectArController.text.trim().isEmpty ||
        _dueDateController.text.trim().isEmpty ||
        _dueTimeController.text.trim().isEmpty) {
      return;
    }

    final CrmDealActivityModel savedActivity = (widget.activity ??
            CrmDealActivityModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              no: 1,
            ))
        .copyWith(
      categoryName: _selectedActivityType ?? 'IT',
      activityType: _selectedActivityType ?? 'Communication',
      subjectEn: _subjectEnController.text.trim(),
      subjectAr: _subjectArController.text.trim(),
      assigneeName: _selectedEmployee?.name ?? 'Aya Ali',
      assigneeRole: _selectedEmployee?.role ?? 'CEO',
      dueDate: _dueDateController.text.trim(),
      time: _dueTimeController.text.trim(),
      tags: _selectedTag ?? 'Deals',
      status: _currentStatus,
      noteEn: _noteEnController.text.trim(),
      noteAr: _noteArController.text.trim(),
    );

    if (_currentMode == 'add') {
      widget.onActivityAdded?.call(savedActivity);
    } else {
      widget.onActivityUpdated?.call(savedActivity);
    }

    CrmControlDialogs.showSuccessDialog(
      context: context,
      title: FormatHelper.localizedString(
        englishName:
            _currentMode == 'add' ? 'Activity Added' : 'Activity Saved',
        arabicName:
            _currentMode == 'add' ? 'تمت إضافة النشاط' : 'تم حفظ النشاط',
      ),
      subtitle: FormatHelper.localizedString(
        englishName: 'Activity has been saved successfully.',
        arabicName: 'تم حفظ تفاصيل النشاط بنجاح.',
      ),
    );
    Navigator.pop(context);
  }

  void _handleStatusChange(String val) {
    if (val == 'cancel' || val == 'cancelled') {
      CrmDealCancelActivityDialog.show(
        context: context,
        onReschedule: () {
          setState(() => _currentMode = 'reschedule');
        },
        onConfirmCancel: () {
          setState(() {
            _currentStatus = CrmDealActivityStatus.cancelled;
          });
          if (widget.activity != null) {
            widget.onActivityUpdated?.call(
              widget.activity!.copyWith(
                status: CrmDealActivityStatus.cancelled,
              ),
            );
          }
          CrmControlDialogs.showSuccessDialog(
            context: context,
            title: 'Activity Cancelled',
            subtitle: 'The activity has been marked as cancelled.',
          );
        },
      );
    } else if (val == 'completed') {
      setState(() {
        _currentStatus = CrmDealActivityStatus.completed;
      });
      if (widget.activity != null) {
        widget.onActivityUpdated?.call(
          widget.activity!.copyWith(
            status: CrmDealActivityStatus.completed,
          ),
        );
      }
      CrmControlDialogs.showSuccessDialog(
        context: context,
        title: 'Activity Completed',
        subtitle: 'The activity has been marked as completed.',
      );
    } else if (val == 'reschedule') {
      setState(() => _currentMode = 'reschedule');
    } else {
      setState(() {
        _currentStatus = CrmDealActivityStatus.values.firstWhere(
          (CrmDealActivityStatus s) => s.name == val,
          orElse: () => _currentStatus,
        );
      });
      if (widget.activity != null) {
        widget.onActivityUpdated?.call(
          widget.activity!.copyWith(status: _currentStatus),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: FormatHelper.localizedString(
          englishName: 'Deals',
          arabicName: 'الصفقات',
        ),
        secondTitle: widget.dealTitle,
        thirdTitle: _resolveThirdTitle(),
        onFirstTap: () => Navigator.pop(context),
        onSecondTap: () => Navigator.pop(context),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // ── Top Action Bar for View Mode ───────────────────────────────
              if (_currentMode == 'view') _buildViewTopBar(),

              // ── 1. Activity Details Section Card ───────────────────────────
              CrmDealActivityFormDetails(
                isReadOnly: _isReadOnly,
                submitted: _submitted,
                selectedActivityType: _selectedActivityType,
                activityTypes: _activityTypes,
                onActivityTypeChanged: (String? val) =>
                    _selectedActivityType = val,
                subjectEnController: _subjectEnController,
                subjectArController: _subjectArController,
                employees: _employees,
                selectedEmployee: _selectedEmployee,
                onEmployeeSelected: (CrmTeamMemberModel? emp) =>
                    _selectedEmployee = emp,
                employeeSearchController: _employeeSearchController,
                dueDateController: _dueDateController,
                dueTimeController: _dueTimeController,
                onPickDate: _pickDate,
                onPickTime: _pickTime,
                selectedTag: _selectedTag,
                tags: _tags,
                onTagChanged: (String? val) => _selectedTag = val,
                noteEnController: _noteEnController,
                noteArController: _noteArController,
                onFormStateChanged: () => setState(() {}),
              ),

              SizedBox(height: 24.sp),

              // ── 2. Bottom Action Buttons (for Add / Edit / Reschedule) ─────
              if (!_isReadOnly) _buildBottomActionButtons(),

              SizedBox(height: 32.sp),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewTopBar() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.sp),
      child: Row(
        children: <Widget>[
          // Status Dropdown Button
          CrmDealActivityStatusDropdownButton(
            currentStatus: _currentStatus,
            onStatusSelected: _handleStatusChange,
          ),

          const Spacer(),

          // Edit Button
          CustomEditIcon(
            title: FormatHelper.localizedString(
              englishName: 'Edit',
              arabicName: 'تعديل',
            ),
            color: AppColors.primary,
            borderColor: Colors.transparent,
            onTap: () => setState(() => _currentMode = 'edit'),
          ),

          SizedBox(width: 12.sp),

          // Remove Button
          CustomDeleteIcon(
            title: FormatHelper.localizedString(
              englishName: 'Remove',
              arabicName: 'حذف',
            ),
            color: const Color(0xFFDC2626),
            borderColor: Colors.transparent,
            svgColor: AppColors.white,
            textStyle: StyleText.fontSize14Weight500.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
            onTap: () {
              CrmControlDialogs.showRemoveDialog(
                context: context,
                title: 'Delete Activity',
                subtitle: 'Are you sure you want to remove this activity?',
                onConfirm: () {
                  if (widget.activity != null) {
                    widget.onActivityDeleted?.call(widget.activity!.id);
                  }
                  Navigator.pop(context);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionButtons() {
    final bool isEditOrReschedule =
        _currentMode == 'edit' || _currentMode == 'reschedule';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            // Discard Button
            customButton(
              title: FormatHelper.localizedString(
                englishName: 'Discard',
                arabicName: 'إلغاء',
              ),
              color: const Color(0xFFE5E7EB),
              textColor: AppColors.black,
              width: 140.sp,
              height: 40.sp,
              function: () {
                if (isEditOrReschedule) {
                  setState(() => _currentMode = 'view');
                } else {
                  Navigator.pop(context);
                }
              },
            ),
            const Spacer(),
            // Add / Save Button
            customButton(
              title: FormatHelper.localizedString(
                englishName: isEditOrReschedule ? 'Save' : 'Add',
                arabicName: isEditOrReschedule ? 'حفظ' : 'إضافة',
              ),
              color: AppColors.primary,
              textColor: AppColors.black,
              width: 140.sp,
              height: 40.sp,
              function: _onSaveOrAdd,
            ),
          ],
        ),
        if (!isEditOrReschedule) ...<Widget>[
          SizedBox(height: 12.sp),
          // Save For Later Button
          customButton(
            title: FormatHelper.localizedString(
              englishName: 'Save For Later',
              arabicName: 'حفظ لوقت لاحق',
            ),
            color: const Color(0xFF6B7280),
            textColor: AppColors.white,
            width: 140.sp,
            height: 40.sp,
            function: () {
              CrmControlDialogs.showSuccessDialog(
                context: context,
                title: 'Draft Saved',
                subtitle: 'Activity draft has been saved.',
              );
              Navigator.pop(context);
            },
          ),
        ],
      ],
    );
  }
}
