// ****************** FILE INFO ******************
// File Name: crm_merge_level_form_page.dart
// Purpose: Multi-mode form page for Add, Details (Readonly), and Edit CRM Merge Level in Controls
// Author: Mohand Adel
// Created At: 26/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/12-custom_delete_icon.dart';
import 'package:knowticed_plus/core/custom/13-custom_edit_icon.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:knowticed_plus/core/custom/61-custom_color_picker.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_merge_level_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/controller/crm_merge_levels_cubit.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/controller/crm_merge_levels_state.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';
import 'package:knowticed_plus/generated/l10n.dart';

enum CrmMergeLevelFormMode { add, details, edit }

class CrmMergeLevelFormPage extends StatefulWidget {
  final CrmMergeLevelFormMode initialMode;
  final CrmMergeLevelModel? level;

  const CrmMergeLevelFormPage({
    super.key,
    this.initialMode = CrmMergeLevelFormMode.add,
    this.level,
  });

  @override
  State<CrmMergeLevelFormPage> createState() => _CrmMergeLevelFormPageState();
}

class _CrmMergeLevelFormPageState extends State<CrmMergeLevelFormPage> {
  late CrmMergeLevelFormMode _mode;
  late final TextEditingController _nameController;
  late final TextEditingController _nameArController;
  late final TextEditingController _rangeFromController;
  late final TextEditingController _rangeToController;
  CrmMergeLevelModel? _level;
  late Color _selectedColor;
  late bool _isActive;
  String? _nameEnError;
  String? _nameArError;
  String? _rangeFromError;
  String? _rangeToError;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _level = widget.level;
    _nameController = TextEditingController(text: _level?.nameEn ?? '');
    _nameArController = TextEditingController(text: _level?.nameAr ?? '');
    _rangeFromController = TextEditingController(
      text: _level != null ? '${_level!.rangeFrom}' : '',
    );
    _rangeToController = TextEditingController(
      text: _level != null ? '${_level!.rangeTo}' : '',
    );
    _selectedColor = _level?.color ?? const Color(0xFFFFD043);
    _isActive = _level?.isActive ?? true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CrmMergeLevelsCubit>().init();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameArController.dispose();
    _rangeFromController.dispose();
    _rangeToController.dispose();
    super.dispose();
  }

  void _validateEn(String val) {
    if (_mode == CrmMergeLevelFormMode.details) return;
    final String text = val.trim();
    if (text.isEmpty) {
      setState(() => _nameEnError = 'This field is required');
    } else if (RegExp(r'[\u0600-\u06FF]').hasMatch(val)) {
      setState(() => _nameEnError = 'English letters only');
    } else {
      setState(() => _nameEnError = null);
    }
  }

  void _validateAr(String val) {
    if (_mode == CrmMergeLevelFormMode.details) return;
    final String text = val.trim();
    if (text.isEmpty) {
      setState(() => _nameArError = 'هذا الحقل مطلوب');
    } else if (RegExp(r'[a-zA-Z]').hasMatch(val)) {
      setState(() => _nameArError = 'يرجى إدخال حروف عربية فقط');
    } else {
      setState(() => _nameArError = null);
    }
  }

  void _validateRangeFrom(String val) {
    if (_mode == CrmMergeLevelFormMode.details) return;
    final String text = val.trim();
    if (text.isEmpty) {
      setState(() => _rangeFromError = 'This field is required');
    } else if (double.tryParse(text) == null) {
      setState(() => _rangeFromError = 'Please enter a valid number');
    } else {
      setState(() => _rangeFromError = null);
    }
  }

  void _validateRangeTo(String val) {
    if (_mode == CrmMergeLevelFormMode.details) return;
    final String text = val.trim();
    if (text.isEmpty) {
      setState(() => _rangeToError = 'This field is required');
    } else if (double.tryParse(text) == null) {
      setState(() => _rangeToError = 'Please enter a valid number');
    } else if (double.tryParse(_rangeFromController.text.trim()) != null &&
        double.parse(text) < double.parse(_rangeFromController.text.trim())) {
      setState(
          () => _rangeToError = 'Must be greater than or equal to Range From');
    } else {
      setState(() => _rangeToError = null);
    }
  }

  bool _validateForm() {
    final String en = _nameController.text.trim();
    final String ar = _nameArController.text.trim();
    final String range = _rangeFromController.text.trim();
    final String rangeTo = _rangeToController.text.trim();

    String? enErr;
    String? arErr;
    String? rangeErr;
    String? rangeToErr;

    if (en.isEmpty) {
      enErr = 'This field is required';
    } else if (RegExp(r'[\u0600-\u06FF]').hasMatch(en)) {
      enErr = 'English letters only';
    }

    if (ar.isEmpty) {
      arErr = 'هذا الحقل مطلوب';
    } else if (RegExp(r'[a-zA-Z]').hasMatch(ar)) {
      arErr = 'يرجى إدخال حروف عربية فقط';
    }

    if (range.isEmpty) {
      rangeErr = 'This field is required';
    } else if (double.tryParse(range) == null) {
      rangeErr = 'Please enter a valid number';
    }
    if (rangeTo.isEmpty) {
      rangeToErr = 'This field is required';
    } else if (double.tryParse(rangeTo) == null) {
      rangeToErr = 'Please enter a valid number';
    } else if (rangeErr == null &&
        double.parse(rangeTo) < double.parse(range)) {
      rangeToErr = 'Must be greater than or equal to Range From';
    }

    setState(() {
      _nameEnError = enErr;
      _nameArError = arErr;
      _rangeFromError = rangeErr;
      _rangeToError = rangeToErr;
    });

    return enErr == null &&
        arErr == null &&
        rangeErr == null &&
        rangeToErr == null;
  }

  String get _fourthTitle {
    switch (_mode) {
      case CrmMergeLevelFormMode.add:
        return S.current.crmMergeAddLevel;
      case CrmMergeLevelFormMode.edit:
        return S.current.crmMergeEditLevel;
      case CrmMergeLevelFormMode.details:
        return S.current.crmMergePossibleLevel;
    }
  }

  void _handleRemove() {
    final CrmMergeLevelModel? level = _level;
    if (level == null) return;

    CrmControlDialogs.showRemoveDialog(
      context: context,
      title: S.current.crmRemove,
      subtitle: S.current.crmMergeDeleteConfirm,
      onConfirm: () async {
        showLoadingIndicator();
        final bool removed =
            await context.read<CrmMergeLevelsCubit>().removeLevel(level);
        hideLoadingIndicator();
        if (!mounted || !removed) return;
        CrmControlDialogs.showSuccessDialog(
          context: context,
          title: S.current.crmSuccessful,
          subtitle: S.current.crmMergeDeletedSuccess,
          onComplete: () => CrmNavigationHelper.pop(context),
        );
      },
    );
  }

  void _handleSubmit() {
    if (!_validateForm()) return;

    CrmControlDialogs.showSaveDialog(
      context: context,
      title: S.current.crmSave,
      subtitle: S.current.crmSaveSubtitle,
      onConfirm: () async {
        final CrmMergeLevelsCubit cubit = context.read<CrmMergeLevelsCubit>();
        showLoadingIndicator();
        bool saved = false;

        final double rangeFrom =
            double.tryParse(_rangeFromController.text.trim()) ?? 0.0;
        final double rangeTo =
            double.tryParse(_rangeToController.text.trim()) ?? 0.0;
        final String colorHex = CustomColorPickerField.hexOf(_selectedColor);

        if (_mode == CrmMergeLevelFormMode.edit && _level != null) {
          saved = await cubit.updateLevel(
            currentLevel: _level!,
            nameEn: _nameController.text,
            nameAr: _nameArController.text,
            rangeFrom: rangeFrom,
            rangeTo: rangeTo,
            colorHex: colorHex,
            isActive: _isActive,
          );
          _level = cubit.state.selectedLevel ?? _level;
        } else {
          saved = await cubit.createLevel(
            nameEn: _nameController.text,
            nameAr: _nameArController.text,
            rangeFrom: rangeFrom,
            rangeTo: rangeTo,
            colorHex: colorHex,
          );
          _level = cubit.state.selectedLevel;
        }
        hideLoadingIndicator();

        if (!mounted) return;
        if (!saved) {
          CrmControlDialogs.showErrorDialog(
            context: context,
            title: FormatHelper.localizedString(
              englishName: 'Error',
              arabicName: 'خطأ',
            ),
            subtitle: cubit.state.errorMessage ??
                FormatHelper.localizedString(
                  englishName: 'Failed to save merge level',
                  arabicName: 'فشل حفظ مستوى الدمج',
                ),
          );
          return;
        }

        if (_mode == CrmMergeLevelFormMode.edit) {
          CrmControlDialogs.showSuccessDialog(
            context: context,
            title: S.current.crmSuccessful,
            subtitle: S.current.crmSubmitSuccessfully,
            onComplete: () {
              setState(() {
                _mode = CrmMergeLevelFormMode.details;
              });
            },
          );
        } else {
          CrmControlDialogs.showSuccessDialog(
            context: context,
            title: S.current.crmSuccessful,
            subtitle: S.current.crmSubmitSuccessfully,
            onComplete: () => CrmNavigationHelper.pop(context),
          );
        }
      },
    );
  }

  void _handleDiscard() {
    if (_mode == CrmMergeLevelFormMode.edit && _level != null) {
      setState(() {
        _mode = CrmMergeLevelFormMode.details;
        _nameController.text = _level!.nameEn;
        _nameArController.text = _level!.nameAr;
        _rangeFromController.text = _level!.rangeFrom.toString();
        _rangeToController.text = _level!.rangeTo.toString();
        _selectedColor = _level!.color;
        _isActive = _level!.isActive;
        _nameEnError = null;
        _nameArError = null;
        _rangeFromError = null;
        _rangeToError = null;
      });
      return;
    }
    CrmNavigationHelper.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final bool isReadOnly = _mode == CrmMergeLevelFormMode.details;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: S.current.crm,
        secondTitle: S.current.crmSectionControls,
        thirdTitle: S.current.crmSectionMerge,
        fourthTitle: _fourthTitle,
        onFirstTap: () => CrmNavigationHelper.popToDashboard(context),
        onSecondTap: () => CrmNavigationHelper.popToControls(context),
        onThirdTap: () => CrmNavigationHelper.pop(context),
        child: BlocBuilder<CrmMergeLevelsCubit, CrmMergeLevelsState>(
          builder: (BuildContext context, CrmMergeLevelsState state) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Details mode action triggers (Edit / Delete)
                  if (isReadOnly && _level != null) ...[
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          CustomEditIcon(
                            title: isMobile ? '' : S.current.crmEdit,
                            onTap: () {
                              setState(() {
                                _mode = CrmMergeLevelFormMode.edit;
                              });
                            },
                          ),
                          SizedBox(width: 8.sp),
                          CustomDeleteIcon(
                            title: isMobile ? '' : S.current.crmRemove,
                            onTap: _handleRemove,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.sp),
                  ],

                  // Form Section Card
                  CrmSectionCard(
                    title: S.current.crmTypeDetails,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Bilingual Name fields
                        buildResponsiveFields(
                          context: context,
                          left: CustomTextField(
                            label: 'Name',
                            hint: 'Text Here',
                            controller: _nameController,
                            readOnly: isReadOnly,
                            errorText: _nameEnError,
                            onChanged: _validateEn,
                          ),
                          right: Directionality(
                            textDirection: TextDirection.rtl,
                            child: CustomTextField(
                              label: 'اسم',
                              hint: 'اكتب هنا',
                              controller: _nameArController,
                              readOnly: isReadOnly,
                              textAlign: TextAlign.right,
                              errorText: _nameArError,
                              onChanged: _validateAr,
                            ),
                          ),
                        ),
                        SizedBox(height: 16.sp),

                        // Range boundaries
                        buildResponsiveFields(
                          context: context,
                          left: CustomTextField(
                            label: S.current.crmMergeRangeFrom,
                            hint: 'Text Here',
                            controller: _rangeFromController,
                            readOnly: isReadOnly,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            errorText: _rangeFromError,
                            onChanged: _validateRangeFrom,
                          ),
                          right: CustomTextField(
                            label: S.current.crmMergeRangeTo,
                            hint: 'Text Here',
                            controller: _rangeToController,
                            readOnly: isReadOnly,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            errorText: _rangeToError,
                            onChanged: _validateRangeTo,
                          ),
                        ),
                        SizedBox(height: 16.sp),

                        // Color Picker (Half-row)
                        buildResponsiveFields(
                          context: context,
                          left: CustomColorPickerField(
                            label: S.current.crmMergeColor,
                            color: _selectedColor,
                            enabled: !isReadOnly,
                            onColorSelected: (Color picked) {
                              setState(() {
                                _selectedColor = picked;
                              });
                            },
                          ),
                          right: const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Save Action Button (Add / Edit mode)
                  if (!isReadOnly) ...[
                    SizedBox(height: 24.sp),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        customButton(
                          title: S.current.crmDiscard,
                          function: _handleDiscard,
                          color: AppColors.grey,
                          textColor: AppColors.black,
                          width: isMobile ? 120.sp : 140.sp,
                        ),
                        customButton(
                          title: S.current.crmSave,
                          function: _handleSubmit,
                          color: AppColors.primary,
                          textColor: AppColors.black,
                          width: isMobile ? 120.sp : 140.sp,
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 32.sp),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
