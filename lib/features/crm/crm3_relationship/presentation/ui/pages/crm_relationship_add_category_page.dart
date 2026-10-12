// ****************** FILE INFO ******************
// File Name: crm_relationship_add_category_page.dart
// Purpose: Form/details page for CRM relationship category create and edit flow
// Author: Mohand Adel
// Created At: 12/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/12-custom_delete_icon.dart';
import 'package:knowticed_plus/core/custom/13-custom_edit_icon.dart';
import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm3_relationship/data/models/crm_relationship_category_model.dart';
import 'package:knowticed_plus/features/crm/crm3_relationship/data/models/crm_relationship_type_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';

enum CrmCategoryPageMode { view, edit, add }

class CrmRelationshipAddCategoryPage extends StatefulWidget {
  const CrmRelationshipAddCategoryPage({super.key});

  @override
  State<CrmRelationshipAddCategoryPage> createState() =>
      _CrmRelationshipAddCategoryPageState();
}

class _CrmRelationshipAddCategoryPageState
    extends State<CrmRelationshipAddCategoryPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameEnController = TextEditingController();
  final TextEditingController _nameArController = TextEditingController();
  final List<_TypeControllerGroup> _types = <_TypeControllerGroup>[];
  final List<_TypeControllerGroup> _disposables = <_TypeControllerGroup>[];

  CrmCategoryPageMode _mode = CrmCategoryPageMode.add;
  String _status = 'active';
  CrmRelationshipCategoryModel? _editingCategory;

  bool get _canSubmit =>
      _nameEnController.text.trim().isNotEmpty &&
      _nameArController.text.trim().isNotEmpty &&
      _types.isNotEmpty &&
      _types.every(
        (_TypeControllerGroup type) =>
            type.nameEn.text.trim().isNotEmpty &&
            type.nameAr.text.trim().isNotEmpty,
      );

  @override
  void initState() {
    super.initState();
    _nameEnController.addListener(_refreshSubmitState);
    _nameArController.addListener(_refreshSubmitState);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadArguments();
    });
  }

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameArController.dispose();
    for (final _TypeControllerGroup group in _disposables) {
      group.dispose();
    }
    super.dispose();
  }

  void _loadArguments() {
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      final CrmRelationshipCategoryModel? category =
          args['category'] as CrmRelationshipCategoryModel?;
      final String modeStr = (args['mode'] ?? 'add').toString();
      if (category != null) {
        _editingCategory = category;
        _applyCategory(category);
      } else {
        _clearForAdd();
      }
      if (!mounted) return;
      setState(() {
        _mode = _resolveMode(modeStr, category != null);
      });
      return;
    }
    _clearForAdd();
  }

  CrmCategoryPageMode _resolveMode(String modeStr, bool hasCategory) {
    if (!hasCategory) return CrmCategoryPageMode.add;
    if (modeStr == 'edit') return CrmCategoryPageMode.edit;
    return CrmCategoryPageMode.view;
  }

  void _applyCategory(CrmRelationshipCategoryModel category) {
    _nameEnController.text = category.nameEn;
    _nameArController.text = category.nameAr;
    _status = category.status;
    _types.clear();
    for (final CrmRelationshipTypeModel type in category.types) {
      final _TypeControllerGroup group = _TypeControllerGroup(
        id: type.id,
        nameEn: TextEditingController(text: type.nameEn),
        nameAr: TextEditingController(text: type.nameAr),
      );
      group.nameEn.addListener(_refreshSubmitState);
      group.nameAr.addListener(_refreshSubmitState);
      _types.add(group);
      _disposables.add(group);
    }
    if (_types.isEmpty) {
      _addTypeRow();
    }
  }

  void _clearForAdd() {
    setState(() {
      _mode = CrmCategoryPageMode.add;
      _status = 'active';
      _nameEnController.clear();
      _nameArController.clear();
      _types.clear();
    });
    _addTypeRow();
  }

  void _addTypeRow() {
    final _TypeControllerGroup group = _TypeControllerGroup(
      id: 'relationship_type_${DateTime.now().microsecondsSinceEpoch}'
          '_${_types.length}',
      nameEn: TextEditingController(),
      nameAr: TextEditingController(),
    );
    group.nameEn.addListener(_refreshSubmitState);
    group.nameAr.addListener(_refreshSubmitState);
    setState(() {
      _types.add(group);
      _disposables.add(group);
    });
  }

  void _refreshSubmitState() {
    if (mounted) setState(() {});
  }

  void _removeTypeRow(int index) {
    setState(() {
      _types.removeAt(index);
    });
  }

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final List<_TypeControllerGroup> validTypes = _types
        .where(
          (_TypeControllerGroup group) =>
              group.nameEn.text.trim().isNotEmpty ||
              group.nameAr.text.trim().isNotEmpty,
        )
        .toList();
    if (validTypes.isEmpty) {
      _showMessage(S.current.crmPleaseAddAtLeastOneType);
      return;
    }
    final bool hasIncompleteType = validTypes.any(
      (_TypeControllerGroup group) =>
          group.nameEn.text.trim().isEmpty || group.nameAr.text.trim().isEmpty,
    );
    if (hasIncompleteType) {
      _showMessage('Each relationship type must have English and Arabic names');
      return;
    }

    final CrmRelationshipCategoryModel formCategory =
        CrmRelationshipCategoryModel(
      id: _editingCategory?.id ??
          'relationship_category_${DateTime.now().microsecondsSinceEpoch}',
      nameEn: _nameEnController.text.trim(),
      nameAr: _nameArController.text.trim(),
      status: _editingCategory == null ? 'active' : _status.toLowerCase(),
      iconUrl: _editingCategory?.iconUrl ?? '',
      isActive:
          _editingCategory == null ? true : _status.toLowerCase() == 'active',
      isDeleted: false,
      order: _editingCategory?.order ?? 0,
      audit: _editingCategory?.audit,
      types: validTypes
          .map(
            (_TypeControllerGroup group) => CrmRelationshipTypeModel(
              id: group.id,
              nameEn: group.nameEn.text.trim(),
              nameAr: group.nameAr.text.trim(),
            ),
          )
          .toList(),
    );

    CrmControlDialogs.showSaveDialog(
      context: context,
      title: S.current.crmSaveRelationship,
      subtitle: S.current.crmSaveRelationshipConfirm,
      onConfirm: () async {
        if (!mounted) return;
        CrmNavigationHelper.pop(
          context,
          <String, dynamic>{
            'action': 'save',
            'category': formCategory,
          },
        );
      },
    );
  }

  void _onDiscard() {
    if (_mode == CrmCategoryPageMode.edit && _editingCategory != null) {
      setState(() {
        _mode = CrmCategoryPageMode.view;
        _applyCategory(_editingCategory!);
      });
      return;
    }
    CrmNavigationHelper.pop(context);
  }

  void _onRemoveTap() {
    CrmControlDialogs.showRemoveDialog(
      context: context,
      title: S.current.crmRemoveRelationship,
      subtitle: S.current.crmRemoveRelationshipConfirm,
      onConfirm: () {
        CrmNavigationHelper.pop(
          context,
          <String, dynamic>{
            'action': 'delete',
            'id': _editingCategory?.id,
          },
        );
      },
    );
  }

  void _showMessage(String message) {
    CrmControlDialogs.showErrorDialog(
      context: context,
      title: S.current.crmAlert,
      subtitle: message,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: S.current.crm,
        secondTitle: S.current.crmRelationship,
        thirdTitle: _pageTitle(isArabic),
        onFirstTap: () => CrmNavigationHelper.popToDashboard(context),
        onSecondTap: () => CrmNavigationHelper.pop(context),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (_mode == CrmCategoryPageMode.view) ...<Widget>[
                  _buildViewActions(isArabic),
                  SizedBox(height: 12.sp),
                ] else ...<Widget>[
                  Text(
                    S.current.crmDetails,
                    style: StyleText.fontSize14Weight600.copyWith(
                      color: AppColors.text,
                    ),
                  ),
                  SizedBox(height: 12.sp),
                ],
                _buildCardContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      buildResponsiveFields(
                        context: context,
                        left: CustomTextField(
                          controller: _nameEnController,
                          label: 'Category Name',
                          hint: 'Text Here',
                          readOnly: _mode == CrmCategoryPageMode.view,
                          required: true,
                        ),
                        right: Directionality(
                          textDirection: TextDirection.rtl,
                          child: CustomTextField(
                            controller: _nameArController,
                            label: 'اسم الفئة',
                            hint: 'اكتب هنا',
                            readOnly: _mode == CrmCategoryPageMode.view,
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                            required: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 18.sp),
                Text(
                  S.current.crmTypes,
                  style: StyleText.fontSize14Weight600.copyWith(
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 12.sp),
                _buildCardContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _types.length,
                        itemBuilder: (BuildContext context, int index) {
                          final _TypeControllerGroup item = _types[index];
                          final bool isMobile =
                              MediaQuery.of(context).size.width < 600;

                          if (isMobile) {
                            return Padding(
                              key: ValueKey<String>(item.id),
                              padding: EdgeInsets.only(bottom: 16.sp),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        isArabic
                                            ? 'نوع ${index + 1}'
                                            : 'Type ${index + 1}',
                                        style: StyleText.fontSize14Weight500
                                            .copyWith(
                                          color: AppColors.text,
                                        ),
                                      ),
                                      if (_mode != CrmCategoryPageMode.view &&
                                          _types.length > 1)
                                        GestureDetector(
                                          onTap: () => _removeTypeRow(index),
                                          child: CustomSvgImage(
                                            assetPath: AppAssets.minusCircle,
                                            width: 22.sp,
                                            height: 22.sp,
                                          ),
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 8.sp),
                                  CustomTextField(
                                    controller: item.nameEn,
                                    hint: 'Text Here',
                                    readOnly: _mode == CrmCategoryPageMode.view,
                                    textDirection: TextDirection.ltr,
                                    required: true,
                                  ),
                                  SizedBox(height: 10.sp),
                                  Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: CustomTextField(
                                      controller: item.nameAr,
                                      hint: 'اكتب هنا',
                                      readOnly:
                                          _mode == CrmCategoryPageMode.view,
                                      textDirection: TextDirection.rtl,
                                      textAlign: TextAlign.right,
                                      required: true,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Padding(
                            key: ValueKey<String>(item.id),
                            padding: EdgeInsets.only(bottom: 12.sp),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  child: CustomTextField(
                                    controller: item.nameEn,
                                    hint: 'Text Here',
                                    readOnly: _mode == CrmCategoryPageMode.view,
                                    textDirection: TextDirection.ltr,
                                    required: true,
                                  ),
                                ),
                                SizedBox(width: 15.sp),
                                Expanded(
                                  child: Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: CustomTextField(
                                      controller: item.nameAr,
                                      hint: 'اكتب هنا',
                                      readOnly:
                                          _mode == CrmCategoryPageMode.view,
                                      textDirection: TextDirection.rtl,
                                      textAlign: TextAlign.right,
                                      required: true,
                                    ),
                                  ),
                                ),
                                if (_mode != CrmCategoryPageMode.view &&
                                    _types.length > 1) ...<Widget>[
                                  SizedBox(width: 12.sp),
                                  GestureDetector(
                                    onTap: () => _removeTypeRow(index),
                                    child: CustomSvgImage(
                                      assetPath: AppAssets.minusCircle,
                                      width: 22.sp,
                                      height: 22.sp,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                      if (_mode != CrmCategoryPageMode.view) ...<Widget>[
                        SizedBox(height: 8.sp),
                        SizedBox(
                          width: 100.sp,
                          child: customButtonWithSvg(
                            title: isArabic ? 'نوع' : 'Type',
                            function: _addTypeRow,
                            color: AppColors.black,
                            image: AppAssets.add,
                            widthImage: 16.sp,
                            heightImage: 16.sp,
                            colorBorder: AppColors.transparent,
                            svgColor: AppColors.white,
                            textStyle: StyleText.fontSize12Weight500.copyWith(color: AppColors.background).copyWith(
                              fontSize: 14.sp,
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (_mode != CrmCategoryPageMode.view) ...<Widget>[
                  SizedBox(height: 24.sp),
                  Row(
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
                        color: _canSubmit
                            ? AppColors.primary
                            : AppColors.disabledGrey,
                        textStyle:
                            StyleText.fontSize14Weight500.copyWith(
                          color:
                              _canSubmit ? AppColors.black : AppColors.darkGrey,
                        ),
                        width: 110.sp,
                      ),
                    ],
                  ),
                  SizedBox(height: 32.sp),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewActions(bool isArabic) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          S.current.crmDetails,
          style: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.black,
          ),
        ),
        Row(
          children: <Widget>[
            CustomEditIcon(
              title: S.current.crmEdit,
              onTap: () {
                setState(() {
                  _mode = CrmCategoryPageMode.edit;
                });
              },
              color: AppColors.primary,
              svgColor: AppColors.black,
            ),
            SizedBox(width: 10.sp),
            CustomDeleteIcon(
              title: S.current.crmRemove,
              onTap: _onRemoveTap,
              color: AppColors.delete,
              svgColor: AppColors.white,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardContainer({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10.sp),
      ),
      child: child,
    );
  }

  String _pageTitle(bool isArabic) {
    if (_mode == CrmCategoryPageMode.view) {
      return isArabic
          ? '${_nameArController.text} علاقة'
          : '${_nameEnController.text} Relationship';
    }
    if (_mode == CrmCategoryPageMode.edit) {
      return S.current.crmEditRelationship;
    }
    return S.current.crmAddRelationship;
  }
}

class _TypeControllerGroup {
  final String id;
  final TextEditingController nameEn;
  final TextEditingController nameAr;

  _TypeControllerGroup({
    required this.id,
    required this.nameEn,
    required this.nameAr,
  });

  void dispose() {
    nameEn.dispose();
    nameAr.dispose();
  }
}
