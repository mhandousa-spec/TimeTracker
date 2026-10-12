// ****************** FILE INFO ******************
// File Name: crm_client_add_relationship_page.dart
// Purpose: Add, View, and Edit Client Relationship Page (matching Figma 302:169432, 302:169503, 302:169576, 302:170180)
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
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_relationship_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/controller/crm_client_relationship_cubit.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/controller/crm_client_relationship_state.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_related_entity_selection_section.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';
import 'package:knowticed_plus/features/crm/crm3_relationship/data/models/crm_relationship_category_model.dart';
import 'package:knowticed_plus/features/crm/crm3_relationship/data/models/crm_relationship_type_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmClientAddRelationshipPage extends StatefulWidget {
  final String clientId;
  final CrmClientRelationshipModel? existingRelationship;
  final String mode; // 'add', 'edit', 'view'

  const CrmClientAddRelationshipPage({
    super.key,
    required this.clientId,
    this.existingRelationship,
    this.mode = 'add',
  });

  @override
  State<CrmClientAddRelationshipPage> createState() =>
      _CrmClientAddRelationshipPageState();
}

class _CrmClientAddRelationshipPageState
    extends State<CrmClientAddRelationshipPage> {
  late final CrmClientRelationshipCubit _cubit;
  late String _currentMode;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _noteEnController = TextEditingController();
  final TextEditingController _noteArController = TextEditingController();

  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _currentMode = widget.mode;
    _cubit = CrmClientRelationshipCubit(clientId: widget.clientId);

    if (widget.existingRelationship != null) {
      _noteEnController.text = widget.existingRelationship!.noteEn ?? '';
      _noteArController.text = widget.existingRelationship!.noteAr ?? '';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _cubit.populateFromExisting(widget.existingRelationship!);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _noteEnController.dispose();
    _noteArController.dispose();
    _cubit.close();
    super.dispose();
  }

  String _resolveThirdTitle() {
    if (_currentMode == 'view') {
      return widget.existingRelationship?.relatedEntityName ?? 'Relationship';
    }
    if (_currentMode == 'edit') {
      return 'Edit ${widget.existingRelationship?.relatedEntityName ?? 'Relationship'}';
    }
    return FormatHelper.localizedString(
      englishName: 'Add New Relationship',
      arabicName: 'إضافة علاقة جديدة',
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SideFrameMasterServices(
          titleText: S.current.crmClients,
          secondTitle: FormatHelper.localizedString(
            englishName: 'Relationship',
            arabicName: 'العلاقات',
          ),
          thirdTitle: _resolveThirdTitle(),
          onFirstTap: () => CrmNavigationHelper.pop(context),
          onSecondTap: () => CrmNavigationHelper.pop(context),
          child: BlocConsumer<CrmClientRelationshipCubit,
              CrmClientRelationshipState>(
            listener: (context, state) {
              if (state.errorMessage != null &&
                  state.errorMessage!.isNotEmpty) {
                CrmControlDialogs.showErrorDialog(
                  context: context,
                  title: S.current.errorOccurred,
                  subtitle: state.errorMessage!,
                );
                _cubit.clearMessages();
              }
              if (state.successMessage != null &&
                  state.successMessage!.isNotEmpty) {
                CrmControlDialogs.showSuccessDialog(
                  context: context,
                  title: FormatHelper.localizedString(
                    englishName: 'Success',
                    arabicName: 'نجاح',
                  ),
                  subtitle: state.successMessage!,
                );
                _cubit.clearMessages();
                Navigator.of(context).pop(true);
              }
            },
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircleProgressMaster());
              }

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_currentMode == 'view') _buildViewTopActions(),
                    _buildRelationshipDetailsSection(state),
                    SizedBox(height: 24.sp),
                    if (_currentMode != 'view')
                      _buildBottomActionButtons(state),
                    SizedBox(height: 32.sp),
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
    return Padding(
      padding: EdgeInsets.only(bottom: 16.sp),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CustomEditIcon(
            onTap: () => setState(() => _currentMode = 'edit'),
          ),
          SizedBox(width: 12.sp),
          CustomDeleteIcon(onTap: _handleDelete),
        ],
      ),
    );
  }

  Widget _buildRelationshipDetailsSection(CrmClientRelationshipState state) {
    final bool isReadOnly = _currentMode == 'view';

    return CrmSectionCard(
      title: FormatHelper.localizedString(
        englishName: 'Relationship Details',
        arabicName: 'تفاصيل العلاقة',
      ),
      cardColor: AppColors.white,
      showHideToggle: false,
      padding: EdgeInsets.all(16.sp),
      borderRadius: BorderRadius.circular(8.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Category & Type Dropdowns
          _buildCategoryAndTypeRow(state, isReadOnly),
          SizedBox(height: 16.sp),

          // Row 2: Related Entity Selection / Champion Card
          _buildRelatedEntitySection(state, isReadOnly),
          SizedBox(height: 16.sp),

          // Row 3: Start Date & End Date Pickers
          _buildDatesRow(state, isReadOnly),
          SizedBox(height: 16.sp),

          // Row 4: Bilingual Pair of Notes
          _buildNotesSection(state, isReadOnly),
        ],
      ),
    );
  }

  Widget _buildCategoryAndTypeRow(
      CrmClientRelationshipState state, bool isReadOnly) {
    final String? categoryError =
        _submitted && state.selectedCategory == null ? 'Field Required' : null;
    final String? typeError =
        _submitted && state.selectedType == null ? 'Field Required' : null;

    final Widget leftField = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          FormatHelper.localizedString(
            englishName: 'Relationship Category',
            arabicName: 'فئة العلاقة',
          ),
          style: StyleText.fontSize14Weight400.copyWith(
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 6.sp),
        CustomDropdown<String>(
          hint: FormatHelper.localizedString(
            englishName: 'Choose',
            arabicName: 'اختر',
          ),
          value: state.selectedCategory?.id,
          items: state.categories
              .map((cat) => DropdownItem<String>(
                    value: cat.id,
                    label: FormatHelper.localizedString(
                      englishName: cat.nameEn,
                      arabicName: cat.nameAr,
                    ),
                  ))
              .toList(),
          onChanged: isReadOnly
              ? null
              : (catId) {
                  CrmRelationshipCategoryModel? selectedCat;
                  for (final c in state.categories) {
                    if (c.id == catId) {
                      selectedCat = c;
                      break;
                    }
                  }
                  _cubit.selectCategory(selectedCat);
                },
          errorText: categoryError,
        ),
      ],
    );

    final List<CrmRelationshipTypeModel> types =
        state.selectedCategory?.types ?? [];
    final Widget rightField = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          FormatHelper.localizedString(
            englishName: 'Relationship Type',
            arabicName: 'نوع العلاقة',
          ),
          style: StyleText.fontSize14Weight400.copyWith(
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 6.sp),
        CustomDropdown<String>(
          hint: FormatHelper.localizedString(
            englishName: 'Choose',
            arabicName: 'اختر',
          ),
          value: state.selectedType?.id,
          items: types
              .map((t) => DropdownItem<String>(
                    value: t.id,
                    label: FormatHelper.localizedString(
                      englishName: t.nameEn,
                      arabicName: t.nameAr,
                    ),
                  ))
              .toList(),
          onChanged: (isReadOnly || state.selectedCategory == null)
              ? null
              : (typeId) {
                  CrmRelationshipTypeModel? selectedType;
                  for (final t in types) {
                    if (t.id == typeId) {
                      selectedType = t;
                      break;
                    }
                  }
                  _cubit.selectType(selectedType);
                },
          errorText: typeError,
        ),
      ],
    );

    return buildResponsiveFields(
      context: context,
      left: leftField,
      right: rightField,
    );
  }

  Widget _buildRelatedEntitySection(
      CrmClientRelationshipState state, bool isReadOnly) {
    return CrmRelatedEntitySelectionSection(
      state: state,
      cubit: _cubit,
      searchController: _searchController,
      isReadOnly: isReadOnly,
      isSubmitted: _submitted,
      existingRelationship: widget.existingRelationship,
    );
  }

  Widget _buildDatesRow(CrmClientRelationshipState state, bool isReadOnly) {
    final String startDateText = state.startDate != null
        ? DateFormat('dd/MM/yyyy').format(state.startDate!)
        : '';
    final String endDateText = state.endDate != null
        ? DateFormat('dd/MM/yyyy').format(state.endDate!)
        : '';
    final String? startError =
        _submitted && state.startDate == null ? 'Field Required' : null;

    final Widget leftField = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          FormatHelper.localizedString(
            englishName: 'Start Date',
            arabicName: 'تاريخ البدء',
          ),
          style: StyleText.fontSize14Weight400.copyWith(
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 6.sp),
        InkWell(
          onTap: isReadOnly ? null : () => _pickDate(isStart: true),
          child: IgnorePointer(
            child: CustomTextField(
              controller: TextEditingController(text: startDateText),
              hint: FormatHelper.localizedString(
                englishName: 'Select Date',
                arabicName: 'اختر التاريخ',
              ),
              suffixIcon: CustomSvgImage(
                assetPath: AppAssets.calendar,
                width: 16.sp,
                height: 16.sp,
              ),
              errorText: startError,
            ),
          ),
        ),
      ],
    );

    final Widget rightField = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          FormatHelper.localizedString(
            englishName: 'End Date',
            arabicName: 'تاريخ الانتهاء',
          ),
          style: StyleText.fontSize14Weight400.copyWith(
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 6.sp),
        InkWell(
          onTap: isReadOnly ? null : () => _pickDate(isStart: false),
          child: IgnorePointer(
            child: CustomTextField(
              controller: TextEditingController(text: endDateText),
              hint: FormatHelper.localizedString(
                englishName: 'Select Date',
                arabicName: 'اختر التاريخ',
              ),
              suffixIcon: CustomSvgImage(
                assetPath: AppAssets.calendar,
                width: 16.sp,
                height: 16.sp,
              ),
            ),
          ),
        ),
      ],
    );

    return buildResponsiveFields(
      context: context,
      left: leftField,
      right: rightField,
    );
  }

  Widget _buildNotesSection(CrmClientRelationshipState state, bool isReadOnly) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // English Note (Left)
        Text(
          'Note',
          style: StyleText.fontSize14Weight400.copyWith(
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 6.sp),
        CustomTextField(
          controller: _noteEnController,
          hint: 'Description',
          maxLines: 3,
          maxLength: 500,
          readOnly: isReadOnly,
          onChanged: _cubit.setNoteEn,
        ),
        SizedBox(height: 16.sp),

        // Arabic Note (Right)
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'ملاحظة',
            style: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.text,
            ),
          ),
        ),
        SizedBox(height: 6.sp),
        CustomTextField(
          controller: _noteArController,
          hint: 'اكتب هنا',
          textAlign: TextAlign.right,
          maxLines: 3,
          maxLength: 500,
          readOnly: isReadOnly,
          onChanged: _cubit.setNoteAr,
        ),
      ],
    );
  }

  Widget _buildBottomActionButtons(CrmClientRelationshipState state) {
    if (_currentMode == 'edit') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          customButton(
            title: FormatHelper.localizedString(
              englishName: 'Discard Changes',
              arabicName: 'إلغاء التغييرات',
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
            textColor: AppColors.text,
            textStyle: StyleText.fontSize16Weight600,
            exactWidth: 150.sp,
            function: state.isSaving ? () {} : _handleSave,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
                englishName: 'Add',
                arabicName: 'إضافة',
              ),
              color: AppColors.primary,
              textColor: AppColors.text,
              textStyle: StyleText.fontSize16Weight600,
              exactWidth: 150.sp,
              function: state.isSaving ? () {} : _handleSave,
            ),
          ],
        ),
        SizedBox(height: 20.sp),
        customButton(
          title: FormatHelper.localizedString(
            englishName: 'Save For Later',
            arabicName: 'حفظ لاحقاً',
          ),
          color: AppColors.darkGrey,
          textColor: AppColors.white,
          textStyle: StyleText.fontSize16Weight600
              .copyWith(color: AppColors.white),
          exactWidth: 150.sp,
          function: state.isSaving ? () {} : _handleSave,
        ),
      ],
    );
  }

  Future<void> _pickDate({required bool isStart}) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      if (isStart) {
        _cubit.setStartDate(picked);
      } else {
        _cubit.setEndDate(picked);
      }
    }
  }

  void _handleSave() {
    setState(() => _submitted = true);
    _cubit.saveRelationship(
      clientId: widget.clientId,
      existingModel: widget.existingRelationship,
    );
  }

  void _handleDelete() {
    if (widget.existingRelationship == null) return;
    CrmControlDialogs.showRemoveDialog(
      context: context,
      title: FormatHelper.localizedString(
        englishName: 'Delete Relationship',
        arabicName: 'حذف العلاقة',
      ),
      subtitle: FormatHelper.localizedString(
        englishName: 'Are you sure you want to delete this relationship?',
        arabicName: 'هل أنت متأكد من رغبتك في حذف هذه العلاقة؟',
      ),
      onConfirm: () async {
        final bool success = await _cubit.deleteRelationship(
          clientId: widget.clientId,
          relationshipId: widget.existingRelationship!.id,
        );
        if (mounted && success) {
          Navigator.of(context).pop(true);
        }
      },
    );
  }
}
