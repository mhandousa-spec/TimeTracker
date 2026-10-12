// ****************** FILE INFO ******************
// File Name: crm_product_category_form_page.dart
// Purpose: Category details, add, and edit UI for CRM Products with real-time validation.
// Author: Mohand Adel
// Created At: 23/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/12-custom_delete_icon.dart';
import 'package:knowticed_plus/core/custom/13-custom_edit_icon.dart';
import 'package:knowticed_plus/core/custom/31-custom_multi_select_dropdown.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_client_type_model.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/data/models/crm_tag_model.dart';
import 'package:knowticed_plus/features/crm/crm7_products/data/models/crm_product_category_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmProductCategoryFormPage extends StatefulWidget {
  final CrmProductCategoryModel? category;
  final String mode;
  final List<CrmClientTypeModel> clientTypes;
  final List<CrmTagModel> tags;
  final List<CrmProductCategoryModel> existingCategories;

  const CrmProductCategoryFormPage({
    super.key,
    this.category,
    required this.mode,
    required this.clientTypes,
    required this.tags,
    this.existingCategories = const <CrmProductCategoryModel>[],
  });

  @override
  State<CrmProductCategoryFormPage> createState() =>
      _CrmProductCategoryFormPageState();
}

class _CrmProductCategoryFormPageState
    extends State<CrmProductCategoryFormPage> {
  final TextEditingController _nameEn = TextEditingController();
  final TextEditingController _nameAr = TextEditingController();
  final TextEditingController _noteEn = TextEditingController();
  final TextEditingController _noteAr = TextEditingController();

  late String _mode;
  String? _typeId;
  List<String> _tagIds = <String>[];
  String _status = 'active';

  String? _nameEnError;
  String? _nameArError;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _nameEn.addListener(_refreshSubmitState);
    _nameAr.addListener(_refreshSubmitState);
    _mode = widget.mode;
    final CrmProductCategoryModel? item = widget.category;
    if (item != null) {
      _nameEn.text = item.nameEn;
      _nameAr.text = item.nameAr;
      _noteEn.text = item.noteEn;
      _noteAr.text = item.noteAr;
      _typeId = item.clientTypeId.isNotEmpty ? item.clientTypeId : null;
      _tagIds = List<String>.from(item.tagIds);
      _status = item.status;
    }
  }

  @override
  void dispose() {
    _nameEn.dispose();
    _nameAr.dispose();
    _noteEn.dispose();
    _noteAr.dispose();
    super.dispose();
  }

  bool get _view => _mode == 'view';

  void _refreshSubmitState() {
    if (mounted) setState(() {});
  }

  bool get _hasChanges {
    if (_mode != 'edit') return true;
    final CrmProductCategoryModel? orig = widget.category;
    if (orig == null) return true;
    if (_nameEn.text.trim() != orig.nameEn.trim()) return true;
    if (_nameAr.text.trim() != orig.nameAr.trim()) return true;
    if (_noteEn.text.trim() != orig.noteEn.trim()) return true;
    if (_noteAr.text.trim() != orig.noteAr.trim()) return true;
    final String origTypeId =
        orig.clientTypeId.isNotEmpty ? orig.clientTypeId : '';
    if ((_typeId ?? '') != origTypeId) return true;
    if (_status != orig.status) return true;
    final Set<String> origTags = orig.tagIds.toSet();
    final Set<String> currentTags = _tagIds.toSet();
    if (origTags.length != currentTags.length ||
        !origTags.containsAll(currentTags)) {
      return true;
    }
    return false;
  }

  bool get _canSubmit {
    final String en = _nameEn.text.trim();
    final String ar = _nameAr.text.trim();
    final String currentId = widget.category?.id ?? '';
    return en.isNotEmpty &&
        ar.isNotEmpty &&
        !RegExp(r'[\u0600-\u06FF]').hasMatch(en) &&
        !RegExp(r'[a-zA-Z]').hasMatch(ar) &&
        !widget.existingCategories.any(
          (CrmProductCategoryModel category) =>
              category.id != currentId &&
              (category.nameEn.trim().toLowerCase() == en.toLowerCase() ||
                  category.nameAr.trim() == ar),
        ) &&
        _hasChanges;
  }

  String _label(CrmClientTypeModel item, bool isArabic) =>
      isArabic && item.nameAr.isNotEmpty ? item.nameAr : item.nameEn;

  void _validateEn(String val) {
    if (_view) return;
    final String text = val.trim();
    if (text.isEmpty) {
      if (_submitted) {
        setState(() => _nameEnError = S.current.crmFieldRequired);
      } else {
        if (_nameEnError != null) setState(() => _nameEnError = null);
      }
    } else if (RegExp(r'[\u0600-\u06FF]').hasMatch(val)) {
      setState(() => _nameEnError = S.current.crmEnglishLettersOnlyTitle);
    } else {
      final String currentId = widget.category?.id ?? '';
      final bool isDuplicate = widget.existingCategories.any(
        (CrmProductCategoryModel cat) =>
            cat.id != currentId &&
            cat.nameEn.trim().toLowerCase() == text.toLowerCase(),
      );
      if (isDuplicate) {
        setState(() => _nameEnError = S.current.crmNameAlreadyExists);
      } else {
        if (_nameEnError != null) setState(() => _nameEnError = null);
      }
    }
  }

  void _validateAr(String val) {
    if (_view) return;
    final String text = val.trim();
    if (text.isEmpty) {
      if (_submitted) {
        setState(() => _nameArError = S.current.crmFieldRequiredAr);
      } else {
        if (_nameArError != null) setState(() => _nameArError = null);
      }
    } else if (RegExp(r'[a-zA-Z]').hasMatch(val)) {
      setState(() => _nameArError = S.current.crmArabicLettersOnlyTitle);
    } else {
      final String currentId = widget.category?.id ?? '';
      final bool isDuplicate = widget.existingCategories.any(
        (CrmProductCategoryModel cat) =>
            cat.id != currentId && cat.nameAr.trim() == text,
      );
      if (isDuplicate) {
        setState(() => _nameArError = S.current.crmNameAlreadyExists);
      } else {
        if (_nameArError != null) setState(() => _nameArError = null);
      }
    }
  }

  bool _validateForm() {
    final String en = _nameEn.text.trim();
    final String ar = _nameAr.text.trim();

    String? enErr;
    String? arErr;

    if (en.isEmpty) {
      enErr = S.current.crmFieldRequired;
    } else if (RegExp(r'[\u0600-\u06FF]').hasMatch(_nameEn.text)) {
      enErr = S.current.crmEnglishLettersOnlyTitle;
    } else {
      final String currentId = widget.category?.id ?? '';
      final bool isDuplicate = widget.existingCategories.any(
        (CrmProductCategoryModel cat) =>
            cat.id != currentId &&
            cat.nameEn.trim().toLowerCase() == en.toLowerCase(),
      );
      if (isDuplicate) {
        enErr = S.current.crmNameAlreadyExists;
      }
    }

    if (ar.isEmpty) {
      arErr = S.current.crmFieldRequiredAr;
    } else if (RegExp(r'[a-zA-Z]').hasMatch(_nameAr.text)) {
      arErr = S.current.crmArabicLettersOnlyTitle;
    } else {
      final String currentId = widget.category?.id ?? '';
      final bool isDuplicate = widget.existingCategories.any(
        (CrmProductCategoryModel cat) =>
            cat.id != currentId && cat.nameAr.trim() == ar,
      );
      if (isDuplicate) {
        arErr = S.current.crmNameAlreadyExists;
      }
    }

    setState(() {
      _nameEnError = enErr;
      _nameArError = arErr;
    });

    return enErr == null && arErr == null;
  }

  void _save() {
    setState(() => _submitted = true);
    if (!_validateForm()) {
      return;
    }
    final CrmProductCategoryModel item =
        (widget.category ?? CrmProductCategoryModel.empty()).copyWith(
      nameEn: _nameEn.text.trim(),
      nameAr: _nameAr.text.trim(),
      noteEn: _noteEn.text.trim(),
      noteAr: _noteAr.text.trim(),
      clientTypeId: _typeId ?? '',
      tagIds: _tagIds,
      status: _status,
      isActive: _status == 'active',
    );
    CrmControlDialogs.showSaveDialog(
      context: context,
      title: S.current.crmSaveCategory,
      subtitle: S.current.crmSaveCategoryConfirm,
      onConfirm: () => CrmNavigationHelper.pop(
        context,
        <String, dynamic>{'action': 'save', 'category': item},
      ),
    );
  }

  void _delete() => CrmControlDialogs.showRemoveDialog(
        context: context,
        title: S.current.crmDeleteCategory,
        subtitle: S.current.crmDeleteCategoryConfirm,
        onConfirm: () => CrmNavigationHelper.pop(
          context,
          <String, dynamic>{'action': 'delete'},
        ),
      );

  @override
  Widget build(BuildContext context) {
    final bool arabic = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: S.current.crm,
        secondTitle: S.current.crmSectionProducts,
        thirdTitle: S.current.crmCategories,
        fourthTitle: _view
            ? widget.category?.localizedName(arabic)
            : _mode == 'edit'
                ? S.current.crmEditCategory
                : S.current.crmAddCategory,
        onFirstTap: () => CrmNavigationHelper.popToDashboard(context),
        onSecondTap: () => CrmNavigationHelper.pop(context),
        onThirdTap: () => CrmNavigationHelper.pop(context),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (_view)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      height: 38.sp,
                      padding: EdgeInsets.symmetric(horizontal: 12.sp),
                      decoration: BoxDecoration(
                        color: _status == 'active'
                            ? AppColors.green
                            : AppColors.darkGrey,
                        borderRadius: BorderRadius.circular(8.sp),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _status,
                          dropdownColor: AppColors.white,
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.white,
                            size: 18.sp,
                          ),
                          items: <DropdownMenuItem<String>>[
                            DropdownMenuItem<String>(
                              value: 'active',
                              child: Text(
                                S.current.crmActive,
                                style: StyleText.fontSize12Weight400,
                              ),
                            ),
                            DropdownMenuItem<String>(
                              value: 'inactive',
                              child: Text(
                                S.current.crmInactive,
                                style: StyleText.fontSize12Weight400,
                              ),
                            ),
                          ],
                          selectedItemBuilder: (BuildContext context) {
                            return <Widget>[
                              Center(
                                child: Text(
                                  S.current.crmActive,
                                  style: StyleText.fontSize12Weight500.copyWith(color: AppColors.background),
                                ),
                              ),
                              Center(
                                child: Text(
                                  S.current.crmInactive,
                                  style: StyleText.fontSize12Weight500.copyWith(color: AppColors.background),
                                ),
                              ),
                            ];
                          },
                          onChanged: (String? value) {
                            if (value == null || value == _status) return;
                            CrmControlDialogs.showSaveDialog(
                              context: context,
                              title: S.current.crmSaveCategory,
                              subtitle: S.current.crmSaveCategoryConfirm,
                              onConfirm: () => CrmNavigationHelper.pop(
                                context,
                                <String, dynamic>{
                                  'action': 'status',
                                  'isActive': value == 'active',
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        CustomEditIcon(
                          title: S.current.crmEdit,
                          onTap: () => setState(() => _mode = 'edit'),
                          color: AppColors.primary,
                          svgColor: AppColors.black,
                        ),
                        SizedBox(width: 10.sp),
                        CustomDeleteIcon(
                          title: S.current.crmRemove,
                          onTap: _delete,
                          color: AppColors.delete,
                          svgColor: AppColors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              SizedBox(height: 14.sp),
              CrmSectionCard(
                title: S.current.crmCategoryDetails,
                showHideToggle: false,
                child: Column(
                  children: <Widget>[
                    buildResponsiveFields(
                      context: context,
                      left: CustomTextField(
                        controller: _nameEn,
                        label: 'Name',
                        hint: 'Text Here',
                        readOnly: _view,
                        errorText: _nameEnError,
                        onChanged: (dynamic val) =>
                            _validateEn(val?.toString() ?? ''),
                      ),
                      right: Directionality(
                        textDirection: TextDirection.rtl,
                        child: CustomTextField(
                          controller: _nameAr,
                          label: 'الاسم',
                          hint: 'اكتب هنا',
                          readOnly: _view,
                          textAlign: TextAlign.right,
                          errorText: _nameArError,
                          onChanged: (dynamic val) =>
                              _validateAr(val?.toString() ?? ''),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.sp),
                    buildResponsiveFields(
                      context: context,
                      left: IgnorePointer(
                        ignoring: _view,
                        child: CustomDropdown<String>(
                          fillColor: AppColors.background,
                          labelStyle: TextStyle(
                            color: AppColors.text,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          value: _typeId,
                          label: 'Client Type',
                          hint: 'Choose',
                          enabled: true,
                          items: widget.clientTypes
                              .map((CrmClientTypeModel item) =>
                                  DropdownItem<String>(
                                    value: item.id,
                                    label: _label(item, arabic),
                                  ))
                              .toList(),
                          onChanged: (String? value) =>
                              setState(() => _typeId = value),
                        ),
                      ),
                      right: IgnorePointer(
                        ignoring: _view,
                        child: CustomMultiSelectDropdown<String>(
                          values: _tagIds,
                          fillColor: AppColors.background,
                          label: 'Tags',
                          labelStyle: TextStyle(
                            color: AppColors.text,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          hint: 'Choose',
                          enabled: true,
                          items: widget.tags
                              .map((CrmTagModel item) =>
                                  MultiSelectDropdownItem<String>(
                                    value: item.id,
                                    label: item.localizedName(arabic),
                                  ))
                              .toList(),
                          onChanged: (List<String> value) =>
                              setState(() => _tagIds = value),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.sp),
                    CustomTextField(
                      controller: _noteEn,
                      label: 'Note',
                      hint: 'Description',
                      readOnly: _view,
                      maxLines: 4,
                      maxLength: 500,
                      showCharCount: true,
                    ),
                    SizedBox(height: 16.sp),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: CustomTextField(
                        controller: _noteAr,
                        label: 'ملاحظة',
                        hint: 'اكتب هنا',
                        readOnly: _view,
                        maxLines: 4,
                        maxLength: 500,
                        showCharCount: true,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
              if (!_view)
                Padding(
                  padding: EdgeInsets.only(top: 20.sp),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      customButton(
                        title: S.current.crmDiscard,
                        function: () => CrmNavigationHelper.pop(context),
                        color: AppColors.grey,
                        textColor: AppColors.text,
                      ),
                      customButton(
                        title: _mode == 'edit'
                            ? S.current.crmSave
                            : S.current.crmAdd,
                        function: _canSubmit ? _save : () {},
                        color: _canSubmit
                            ? AppColors.primary
                            : AppColors.disabledGrey,
                        textStyle:
                            StyleText.fontSize14Weight500.copyWith(
                          color:
                              _canSubmit ? AppColors.black : AppColors.darkGrey,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
