// ****************** FILE INFO ******************
// File Name: crm_category_form_page.dart
// Purpose: Form and details page for viewing, adding, and editing Activity Categories
// Author: Mohand Adel
// Created At: 17/08/2026

import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/custom/12-custom_delete_icon.dart';
import 'package:knowticed_plus/core/custom/13-custom_edit_icon.dart';
import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_card_helper.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/data/models/crm_category_model.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/data/models/crm_category_type_model.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/presentation/ui/widgets/crm_category_type_row.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class _TypeControllerGroup {
  final String id;
  final TextEditingController en;
  final TextEditingController ar;
  String? enError;
  String? arError;

  _TypeControllerGroup({
    required this.id,
    required this.en,
    required this.ar,
  });

  void dispose() {
    en.dispose();
    ar.dispose();
  }
}

class CrmCategoryFormPage extends StatefulWidget {
  final CrmCategoryModel? category;
  final String mode; // 'add', 'edit', 'view'

  const CrmCategoryFormPage({
    super.key,
    this.category,
    this.mode = 'add',
  });

  @override
  State<CrmCategoryFormPage> createState() => _CrmCategoryFormPageState();
}

class _CrmCategoryFormPageState extends State<CrmCategoryFormPage> {
  late String _currentMode;
  final TextEditingController _nameEnController = TextEditingController();
  final TextEditingController _nameArController = TextEditingController();
  String? _nameEnError;
  String? _nameArError;
  final List<_TypeControllerGroup> _typeControllers = <_TypeControllerGroup>[];

  bool get _hasChanges {
    if (_currentMode != 'edit') return true;
    final CrmCategoryModel? cat = widget.category;
    if (cat == null) return true;
    if (_nameEnController.text.trim() != cat.nameEn.trim()) return true;
    if (_nameArController.text.trim() != cat.nameAr.trim()) return true;
    if (_typeControllers.length != cat.types.length) return true;
    for (int i = 0; i < _typeControllers.length; i++) {
      final _TypeControllerGroup group = _typeControllers[i];
      final CrmCategoryTypeModel orig = cat.types[i];
      if (group.en.text.trim() != orig.nameEn.trim() ||
          group.ar.text.trim() != orig.nameAr.trim()) {
        return true;
      }
    }
    return false;
  }

  bool get _canSubmit =>
      _nameEnController.text.trim().isNotEmpty &&
      _nameArController.text.trim().isNotEmpty &&
      _typeControllers.isNotEmpty &&
      _typeControllers.every(
        (_TypeControllerGroup type) =>
            type.en.text.trim().isNotEmpty && type.ar.text.trim().isNotEmpty,
      ) &&
      _hasChanges;

  @override
  void initState() {
    super.initState();
    _nameEnController.addListener(_refreshSubmitState);
    _nameArController.addListener(_refreshSubmitState);
    _currentMode = widget.mode;
    _initializeForm();
  }

  void _initializeForm() {
    final CrmCategoryModel? cat = widget.category;
    if (cat != null) {
      _nameEnController.text = cat.nameEn;
      _nameArController.text = cat.nameAr;
      for (final CrmCategoryTypeModel t in cat.types) {
        final _TypeControllerGroup type = _TypeControllerGroup(
          id: t.id,
          en: TextEditingController(text: t.nameEn),
          ar: TextEditingController(text: t.nameAr),
        );
        type.en.addListener(_refreshSubmitState);
        type.ar.addListener(_refreshSubmitState);
        _typeControllers.add(type);
      }
    }

    if (_typeControllers.isEmpty) {
      _addNewType();
    }
  }

  void _addNewType() {
    final _TypeControllerGroup type = _TypeControllerGroup(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      en: TextEditingController(),
      ar: TextEditingController(),
    );
    type.en.addListener(_refreshSubmitState);
    type.ar.addListener(_refreshSubmitState);
    setState(() {
      _typeControllers.add(type);
    });
  }

  void _refreshSubmitState() {
    if (mounted) setState(() {});
  }

  void _removeType(int index) {
    if (_typeControllers.length <= 1) return;
    setState(() {
      final _TypeControllerGroup removed = _typeControllers.removeAt(index);
      removed.dispose();
    });
  }

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameArController.dispose();
    for (final _TypeControllerGroup t in _typeControllers) {
      t.dispose();
    }
    super.dispose();
  }

  void _switchToEditMode() {
    setState(() {
      _currentMode = 'edit';
    });
  }

  void _onDiscard() {
    CrmNavigationHelper.pop(context);
  }

  void _onSave() {
    final String nameEn = _nameEnController.text.trim();
    final String nameAr = _nameArController.text.trim();

    bool hasError = false;
    if (nameEn.isEmpty) {
      _nameEnError = 'Please enter category name';
      hasError = true;
    }
    if (nameAr.isEmpty) {
      _nameArError = 'يرجى إدخال اسم الفئة';
      hasError = true;
    }

    final List<CrmCategoryTypeModel> types = <CrmCategoryTypeModel>[];
    for (final _TypeControllerGroup t in _typeControllers) {
      final String en = t.en.text.trim();
      final String ar = t.ar.text.trim();
      if (en.isEmpty) {
        t.enError = 'Please enter type';
        hasError = true;
      }
      if (ar.isEmpty) {
        t.arError = 'يرجى إدخال النوع';
        hasError = true;
      }
      if (en.isNotEmpty && ar.isNotEmpty) {
        types.add(
          CrmCategoryTypeModel(
            id: t.id,
            nameEn: en,
            nameAr: ar,
          ),
        );
      }
    }

    if (hasError) {
      setState(() {});
      return;
    }

    if (types.isEmpty) {
      CrmControlDialogs.showErrorDialog(
        context: context,
        title: S.current.crmAlert,
        subtitle: S.current.crmPleaseAddAtLeastOneType,
      );
      return;
    }

    final CrmCategoryModel savedCategory =
        (widget.category ?? CrmCategoryModel.getEmptyModel()).copyWith(
      nameEn: nameEn,
      nameAr: nameAr,
      types: types,
      status: widget.category?.status ?? 'active',
    );

    CrmControlDialogs.showSaveDialog(
      context: context,
      title: S.current.crmSaveCategory,
      subtitle: S.current.crmSaveCategoryConfirm,
      onConfirm: () {
        CrmNavigationHelper.pop(context, <String, dynamic>{
          'action': 'save',
          'category': savedCategory,
        });
      },
    );
  }

  void _onRemoveTap() {
    CrmControlDialogs.showRemoveDialog(
      context: context,
      title: S.current.crmDeleteCategory,
      subtitle: S.current.crmDeleteCategoryConfirm,
      onConfirm: () {
        CrmNavigationHelper.pop(context, <String, dynamic>{
          'action': 'delete',
          'category': widget.category,
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final bool isView = _currentMode == 'view';
    final String pageTitle = _resolvePageTitle(isArabic);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: S.current.crm,
        secondTitle: S.current.crmSectionControls,
        thirdTitle: S.current.crmControlActivity,
        fourthTitle: pageTitle,
        onFirstTap: () => CrmNavigationHelper.popToDashboard(context),
        onSecondTap: () {
          CrmNavigationHelper.pop(context);
          CrmNavigationHelper.pop(context);
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Top Header in View Mode
              if (isView) ...[
                _buildViewHeader(isArabic),
                SizedBox(height: 16.h),
              ],

              // Section Title (Outside Container)
              Text(
                S.current.crmDetails,
                style: StyleText.fontSize16Weight600.copyWith(
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: 8.h),

              // Details Container
              _buildDetailsCard(isView, isArabic),

              SizedBox(height: 24.h),

              // Bottom Action Buttons
              if (!isView) _buildBottomActions(isArabic),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewHeader(bool isArabic) {
    final bool isActive = widget.category?.isActive ?? true;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        // Status Chip
        CrmCardHelper.buildInlineStatusChip(
          isActive: isActive,
          isArabic: isArabic,
        ),

        // Action Buttons: Edit and Delete
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CustomEditIcon(
              onTap: _switchToEditMode,
            ),
            SizedBox(width: 8.w),
            CustomDeleteIcon(
              onTap: _onRemoveTap,
              color: AppColors.red,
              svgColor: AppColors.black,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailsCard(bool isView, bool isArabic) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Category Name Row
          buildResponsiveFields(
            context: context,
            left: CustomTextField(
              label: 'Category Name',
              controller: _nameEnController,
              hint: 'Text Here',
              errorText: _nameEnError,
              readOnly: isView,
              textDirection: TextDirection.ltr,
              onChanged: (_) {
                if (_nameEnError != null) {
                  setState(() => _nameEnError = null);
                }
              },
            ),
            right: Directionality(
              textDirection: TextDirection.rtl,
              child: CustomTextField(
                label: 'اسم الفئة',
                controller: _nameArController,
                hint: 'اكتب هنا',
                errorText: _nameArError,
                readOnly: isView,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                onChanged: (_) {
                  if (_nameArError != null) {
                    setState(() => _nameArError = null);
                  }
                },
              ),
            ),
          ),

          if (!isMobile) ...[
            SizedBox(height: 16.h),
            // Types Header
            Text(
              S.current.crmTypes,
              style: StyleText.fontSize14Weight400,
            ),
            SizedBox(height: 8.h),
          ] else ...[
            SizedBox(height: 16.h),
          ],

          // Types Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _typeControllers.length,
            separatorBuilder: (_, __) => SizedBox(height: isMobile ? 4.h : 8.h),
            itemBuilder: (BuildContext ctx, int index) {
              final _TypeControllerGroup t = _typeControllers[index];
              return CrmCategoryTypeRow(
                index: index,
                enController: t.en,
                arController: t.ar,
                enErrorText: t.enError,
                arErrorText: t.arError,
                onEnChanged: (_) {
                  if (t.enError != null) {
                    setState(() => t.enError = null);
                  }
                },
                onArChanged: (_) {
                  if (t.arError != null) {
                    setState(() => t.arError = null);
                  }
                },
                isReadOnly: isView,
                canDelete: _typeControllers.length > 1,
                onRemove: _typeControllers.length > 1
                    ? () => _removeType(index)
                    : null,
              );
            },
          ),

          if (!isView) ...[
            SizedBox(height: 16.h),
            Align(
              alignment:
                  isArabic ? Alignment.centerRight : Alignment.centerLeft,
              child: SizedBox(
                width: 100.w,
                child: customButtonWithSvg(
                  title: S.current.crmType,
                  function: _addNewType,
                  color: AppColors.black,
                  image: AppAssets.add,
                  svgColor: AppColors.white,
                  widthImage: 16.sp,
                  heightImage: 16.sp,
                  colorBorder: AppColors.transparent,
                  textStyle: StyleText.fontSize12Weight500.copyWith(color: AppColors.background).copyWith(
                    fontSize: 14.sp,
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomActions(bool isArabic) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        customButton(
          title: S.current.crmDiscard,
          function: _onDiscard,
          color: AppColors.grey,
          textColor: AppColors.black,
          width: 110.sp,
        ),
        customButton(
          title: S.current.crmSave,
          function: _canSubmit ? _onSave : () {},
          color: _canSubmit ? AppColors.primary : AppColors.disabledGrey,
          textStyle: StyleText.fontSize14Weight500.copyWith(
            color: _canSubmit ? AppColors.black : AppColors.darkGrey,
          ),
          width: 110.sp,
        ),
      ],
    );
  }

  String _resolvePageTitle(bool isArabic) {
    if (_currentMode == 'add') {
      return S.current.crmAddCategory;
    }
    if (_currentMode == 'edit') {
      return S.current.crmEditCategory;
    }
    final CrmCategoryModel? c = widget.category;
    if (c != null) {
      return isArabic
          ? (c.nameAr.isNotEmpty ? c.nameAr : c.nameEn)
          : (c.nameEn.isNotEmpty ? c.nameEn : c.nameAr);
    }
    return S.current.crmCategoryDetails;
  }
}
