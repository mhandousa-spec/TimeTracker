// ****************** FILE INFO ******************
// File Name: crm_discount_form_page.dart
// Purpose: Add and Edit Form Page for CRM Discount Rules with real-time validation and dynamic dropdowns
// Author: Mohand Adel
// Created At: 23/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/31-custom_multi_select_dropdown.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_client_type_model.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/data/models/crm_tag_model.dart';
import 'package:knowticed_plus/features/crm/crm7_products/data/models/crm_product_category_model.dart';
import 'package:knowticed_plus/features/crm/crm7_products/data/models/crm_product_item_model.dart';
import 'package:knowticed_plus/features/crm/crm8_discounts/data/models/crm_discount_model.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmDiscountFormPage extends StatefulWidget {
  final CrmDiscountModel? discount;
  final String mode; // 'add' or 'edit'
  final List<CrmDiscountModel> existingDiscounts;
  final List<CrmProductCategoryModel> categories;
  final List<CrmProductItemModel> products;
  final List<CrmClientTypeModel> clientTypes;
  final List<CrmTagModel> tags;

  const CrmDiscountFormPage({
    super.key,
    this.discount,
    required this.mode,
    this.existingDiscounts = const <CrmDiscountModel>[],
    this.categories = const <CrmProductCategoryModel>[],
    this.products = const <CrmProductItemModel>[],
    this.clientTypes = const <CrmClientTypeModel>[],
    this.tags = const <CrmTagModel>[],
  });

  @override
  State<CrmDiscountFormPage> createState() => _CrmDiscountFormPageState();
}

class _CrmDiscountFormPageState extends State<CrmDiscountFormPage> {
  final TextEditingController _nameEn = TextEditingController();
  final TextEditingController _nameAr = TextEditingController();
  final TextEditingController _minQuantity = TextEditingController();
  final TextEditingController _maxQuantity = TextEditingController();
  final TextEditingController _discountValue = TextEditingController();
  final TextEditingController _applyOnTeam = TextEditingController();

  String _type = 'Product'; // 'Product', 'Both', 'Service'
  String? _categoryId;
  String? _productId;
  String? _clientTypeId;
  List<String> _selectedTagNames = <String>[];
  String _status = 'active';

  String? _nameEnError;
  String? _nameArError;
  String? _discountValueError;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _nameEn.addListener(_refreshSubmitState);
    _nameAr.addListener(_refreshSubmitState);
    _discountValue.addListener(_refreshSubmitState);
    final CrmDiscountModel? item = widget.discount;
    if (item != null) {
      _nameEn.text = item.nameEn;
      _nameAr.text = item.nameAr;
      _type = item.type.isNotEmpty ? item.type : 'Product';
      _categoryId = item.categoryId.isNotEmpty ? item.categoryId : null;
      _productId = item.productId.isNotEmpty ? item.productId : null;
      _minQuantity.text =
          item.minQuantity > 0 ? item.minQuantity.toString() : '';
      _maxQuantity.text =
          item.maxQuantity > 0 ? item.maxQuantity.toString() : '';
      _discountValue.text = item.discountValue > 0
          ? (item.discountValue.truncateToDouble() == item.discountValue
              ? item.discountValue.toStringAsFixed(0)
              : item.discountValue.toString())
          : '';
      _applyOnTeam.text = item.applyOnTeam;
      _clientTypeId = item.clientTypeId.isNotEmpty ? item.clientTypeId : null;
      _selectedTagNames = List<String>.from(item.tags);
      _status = item.status;
    }
  }

  @override
  void dispose() {
    _nameEn.dispose();
    _nameAr.dispose();
    _minQuantity.dispose();
    _maxQuantity.dispose();
    _discountValue.dispose();
    _applyOnTeam.dispose();
    super.dispose();
  }

  bool get _isServiceOnly => _type == 'Service';

  void _refreshSubmitState() {
    if (mounted) setState(() {});
  }

  bool get _hasChanges {
    if (widget.mode != 'edit') return true;
    final CrmDiscountModel? orig = widget.discount;
    if (orig == null) return true;
    if (_nameEn.text.trim() != orig.nameEn.trim()) return true;
    if (_nameAr.text.trim() != orig.nameAr.trim()) return true;
    if (_type != orig.type) return true;
    if ((_categoryId ?? '') != orig.categoryId) return true;
    if ((_productId ?? '') != orig.productId) return true;
    final int currentMin = int.tryParse(_minQuantity.text.trim()) ?? 0;
    if (currentMin != orig.minQuantity) return true;
    final int currentMax = int.tryParse(_maxQuantity.text.trim()) ?? 0;
    if (currentMax != orig.maxQuantity) return true;
    final double currentVal =
        double.tryParse(_discountValue.text.trim()) ?? 0.0;
    if (currentVal != orig.discountValue) return true;
    if (_applyOnTeam.text.trim() != orig.applyOnTeam.trim()) return true;
    if ((_clientTypeId ?? '') != orig.clientTypeId) return true;
    if (_status != orig.status) return true;
    final Set<String> origTags = orig.tags.toSet();
    final Set<String> currentTags = _selectedTagNames.toSet();
    if (origTags.length != currentTags.length ||
        !origTags.containsAll(currentTags)) {
      return true;
    }
    return false;
  }

  bool get _canSubmit {
    final String en = _nameEn.text.trim();
    final String ar = _nameAr.text.trim();
    final double? value = double.tryParse(_discountValue.text.trim());
    final bool duplicate =
        widget.existingDiscounts.any((CrmDiscountModel item) {
      if (widget.mode == 'edit' && widget.discount?.id == item.id) {
        return false;
      }
      return item.nameEn.trim().toLowerCase() == en.toLowerCase() ||
          item.nameAr.trim() == ar;
    });
    return en.isNotEmpty &&
        ar.isNotEmpty &&
        value != null &&
        value > 0 &&
        !RegExp(r'[\u0600-\u06FF]').hasMatch(en) &&
        !RegExp(r'[a-zA-Z]').hasMatch(ar) &&
        !duplicate &&
        _hasChanges;
  }

  List<CrmProductItemModel> get _availableProducts {
    if (_isServiceOnly) return const <CrmProductItemModel>[];
    if (_categoryId != null && _categoryId!.isNotEmpty) {
      return widget.products.where((p) => p.categoryId == _categoryId).toList();
    }
    return widget.products;
  }

  void _validateEn(String val) {
    final String text = val.trim();
    if (text.isEmpty) {
      if (_submitted) {
        setState(() => _nameEnError = 'This field is required');
      } else {
        if (_nameEnError != null) setState(() => _nameEnError = null);
      }
      return;
    }

    final RegExp arabicRegex = RegExp(r'[\u0600-\u06FF]');
    if (arabicRegex.hasMatch(text)) {
      setState(() => _nameEnError = 'Please enter English letters only');
      return;
    }

    final bool duplicate = widget.existingDiscounts.any((CrmDiscountModel d) {
      if (widget.mode == 'edit' &&
          widget.discount != null &&
          d.id == widget.discount!.id) {
        return false;
      }
      return d.nameEn.trim().toLowerCase() == text.toLowerCase();
    });

    if (duplicate) {
      setState(() => _nameEnError = 'Name already exists');
      return;
    }

    if (_nameEnError != null) setState(() => _nameEnError = null);
  }

  void _validateAr(String val) {
    final String text = val.trim();
    if (text.isEmpty) {
      if (_submitted) {
        setState(() => _nameArError = 'هذا الحقل مطلوب');
      } else {
        if (_nameArError != null) setState(() => _nameArError = null);
      }
      return;
    }

    final RegExp englishRegex = RegExp(r'[a-zA-Z]');
    if (englishRegex.hasMatch(text)) {
      setState(() => _nameArError = 'يرجى إدخال حروف عربية فقط');
      return;
    }

    final bool duplicate = widget.existingDiscounts.any((CrmDiscountModel d) {
      if (widget.mode == 'edit' &&
          widget.discount != null &&
          d.id == widget.discount!.id) {
        return false;
      }
      return d.nameAr.trim() == text;
    });

    if (duplicate) {
      setState(() => _nameArError = 'الاسم موجود بالفعل');
      return;
    }

    if (_nameArError != null) setState(() => _nameArError = null);
  }

  void _validateValue(String val) {
    final String text = val.trim();
    if (text.isEmpty) {
      if (_submitted) {
        setState(() => _discountValueError = S.current.crmFieldRequired);
      } else {
        if (_discountValueError != null) {
          setState(() => _discountValueError = null);
        }
      }
      return;
    }
    final double? numVal = double.tryParse(text);
    if (numVal == null || numVal <= 0) {
      setState(
          () => _discountValueError = S.current.crmPleaseEnterDiscountValue);
      return;
    }
    if (_discountValueError != null) setState(() => _discountValueError = null);
  }

  bool _validateForm() {
    final String en = _nameEn.text.trim();
    final String ar = _nameAr.text.trim();
    final String valText = _discountValue.text.trim();

    String? enErr;
    String? arErr;
    String? valErr;

    final RegExp arabicRegex = RegExp(r'[\u0600-\u06FF]');
    final RegExp englishRegex = RegExp(r'[a-zA-Z]');

    if (en.isEmpty) {
      enErr = 'This field is required';
    } else if (arabicRegex.hasMatch(en)) {
      enErr = 'Please enter English letters only';
    } else if (widget.existingDiscounts.any((CrmDiscountModel d) {
      if (widget.mode == 'edit' &&
          widget.discount != null &&
          d.id == widget.discount!.id) {
        return false;
      }
      return d.nameEn.trim().toLowerCase() == en.toLowerCase();
    })) {
      enErr = 'Name already exists';
    }

    if (ar.isEmpty) {
      arErr = 'هذا الحقل مطلوب';
    } else if (englishRegex.hasMatch(ar)) {
      arErr = 'يرجى إدخال حروف عربية فقط';
    } else if (widget.existingDiscounts.any((CrmDiscountModel d) {
      if (widget.mode == 'edit' &&
          widget.discount != null &&
          d.id == widget.discount!.id) {
        return false;
      }
      return d.nameAr.trim() == ar;
    })) {
      arErr = 'الاسم موجود بالفعل';
    }

    final double? parsedVal = double.tryParse(valText);
    if (valText.isEmpty) {
      valErr = S.current.crmFieldRequired;
    } else if (parsedVal == null || parsedVal <= 0) {
      valErr = S.current.crmPleaseEnterDiscountValue;
    }

    setState(() {
      _nameEnError = enErr;
      _nameArError = arErr;
      _discountValueError = valErr;
    });

    return enErr == null && arErr == null && valErr == null;
  }

  void _onSave() {
    setState(() => _submitted = true);
    if (!_validateForm()) return;

    // Resolve category names
    CrmProductCategoryModel? selectedCategory;
    if (_categoryId != null && !_isServiceOnly) {
      try {
        selectedCategory =
            widget.categories.firstWhere((c) => c.id == _categoryId);
      } catch (_) {}
    }

    // Resolve product names
    CrmProductItemModel? selectedProduct;
    if (_productId != null && !_isServiceOnly) {
      try {
        selectedProduct = widget.products.firstWhere((p) => p.id == _productId);
      } catch (_) {}
    }

    // Resolve client type name
    CrmClientTypeModel? selectedClientType;
    if (_clientTypeId != null) {
      try {
        selectedClientType =
            widget.clientTypes.firstWhere((t) => t.id == _clientTypeId);
      } catch (_) {}
    }

    final CrmDiscountModel item =
        (widget.discount ?? CrmDiscountModel.getEmptyModel()).copyWith(
      nameEn: _nameEn.text.trim(),
      nameAr: _nameAr.text.trim(),
      type: _type,
      categoryId: _isServiceOnly ? '' : (_categoryId ?? ''),
      categoryNameEn: _isServiceOnly ? '' : (selectedCategory?.nameEn ?? ''),
      categoryNameAr: _isServiceOnly ? '' : (selectedCategory?.nameAr ?? ''),
      productId: _isServiceOnly ? '' : (_productId ?? ''),
      productNameEn: _isServiceOnly ? '' : (selectedProduct?.nameEn ?? ''),
      productNameAr: _isServiceOnly ? '' : (selectedProduct?.nameAr ?? ''),
      minQuantity: int.tryParse(_minQuantity.text.trim()) ?? 0,
      maxQuantity: int.tryParse(_maxQuantity.text.trim()) ?? 0,
      discountValue: double.tryParse(_discountValue.text.trim()) ?? 0.0,
      discountType: 'percentage',
      applyOnTeam: _applyOnTeam.text.trim(),
      clientTypeId: _clientTypeId ?? '',
      clientTypeName: selectedClientType != null
          ? (selectedClientType.nameEn.isNotEmpty
              ? selectedClientType.nameEn
              : selectedClientType.nameAr)
          : '',
      tags: _selectedTagNames,
      status: _status,
      isActive: _status == 'active',
    );

    CrmControlDialogs.showSaveDialog(
      context: context,
      title: widget.mode == 'edit'
          ? S.current.crmEditDiscount
          : S.current.crmAddDiscount,
      subtitle: S.current.crmSaveSubtitle,
      onConfirm: () => CrmNavigationHelper.pop(
        context,
        <String, dynamic>{'action': 'save', 'discount': item},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.mode == 'edit';
    final bool isArabic = Directionality.of(context) == TextDirection.rtl;
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: S.current.crm,
        secondTitle: S.current.crmSectionControls,
        thirdTitle: S.current.crmControlDiscount,
        fourthTitle: isEdit ? S.current.crmEditRule : S.current.crmAddDiscount,
        onFirstTap: () => CrmNavigationHelper.popToDashboard(context),
        onSecondTap: () => CrmNavigationHelper.pop(context),
        onThirdTap: () => CrmNavigationHelper.pop(context),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Section 1: Rule Details
              CrmSectionCard(
                title: S.current.crmRuleDetails,
                child: Column(
                  children: <Widget>[
                    buildResponsiveFields(
                      context: context,
                      left: CustomTextField(
                        controller: _nameEn,
                        label: 'Rule Name',
                        hint: 'Text Here',
                        errorText: _nameEnError,
                        onChanged: _validateEn,
                      ),
                      right: Directionality(
                        textDirection: TextDirection.rtl,
                        child: CustomTextField(
                          controller: _nameAr,
                          label: 'اسم القاعدة',
                          hint: 'اكتب هنا',
                          textAlign: TextAlign.right,
                          errorText: _nameArError,
                          onChanged: _validateAr,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.sp),
                    buildResponsiveFields(
                      context: context,
                      left: CustomDropdown<String>(
                        label: S.current.crmType,
                        value: _type,
                        items: const <DropdownItem<String>>[
                          DropdownItem(value: 'Product', label: 'Product'),
                          DropdownItem(value: 'Service', label: 'Service'),
                          DropdownItem(value: 'Both', label: 'Both'),
                        ],
                        onChanged: (String? val) {
                          if (val != null) {
                            setState(() {
                              _type = val;
                              if (val == 'Service') {
                                _categoryId = null;
                                _productId = null;
                              }
                            });
                          }
                        },
                      ),
                      right: const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.sp),

              // Section 2: Discount Details
              CrmSectionCard(
                title: S.current.crmDiscountDetails,
                child: Column(
                  children: <Widget>[
                    buildResponsiveFields(
                      context: context,
                      left: CustomDropdown<String>(
                        label: S.current.crmProductsCategory,
                        value: _categoryId,
                        hint: _isServiceOnly
                            ? (isArabic
                                ? 'غير متاح للخدمات حالياً'
                                : 'Not available for services')
                            : S.current.crmChoose,
                        enabled:
                            !_isServiceOnly && widget.categories.isNotEmpty,
                        items: _isServiceOnly
                            ? const <DropdownItem<String>>[]
                            : widget.categories
                                .map((CrmProductCategoryModel c) =>
                                    DropdownItem<String>(
                                      value: c.id,
                                      label: c.localizedName(isArabic),
                                    ))
                                .toList(),
                        onChanged: (String? val) {
                          setState(() {
                            _categoryId = val;
                            _productId = null;
                          });
                        },
                      ),
                      right: CustomDropdown<String>(
                        label: S.current.crmSectionProducts,
                        value: _productId,
                        hint: _isServiceOnly
                            ? (isArabic
                                ? 'غير متاح للخدمات حالياً'
                                : 'Not available for services')
                            : S.current.crmChoose,
                        enabled:
                            !_isServiceOnly && _availableProducts.isNotEmpty,
                        items: _isServiceOnly
                            ? const <DropdownItem<String>>[]
                            : _availableProducts
                                .map((CrmProductItemModel p) =>
                                    DropdownItem<String>(
                                      value: p.id,
                                      label: p.localizedName(isArabic),
                                    ))
                                .toList(),
                        onChanged: (String? val) {
                          setState(() => _productId = val);
                        },
                      ),
                    ),
                    SizedBox(height: 12.sp),
                    buildResponsiveFields(
                      context: context,
                      left: CustomTextField(
                        controller: _minQuantity,
                        label: S.current.crmMinimumQuantity,
                        hint: S.current.crmTextHere,
                        keyboardType: TextInputType.number,
                      ),
                      right: CustomTextField(
                        controller: _maxQuantity,
                        label: S.current.crmMaximumQuantity,
                        hint: S.current.crmTextHere,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(height: 12.sp),
                    buildResponsiveFields(
                      context: context,
                      left: CustomTextField(
                        controller: _discountValue,
                        label: '${S.current.crmDiscountValue} (%)',
                        hint: S.current.crmTextHere,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        errorText: _discountValueError,
                        onChanged: _validateValue,
                      ),
                      right: CustomTextField(
                        controller: _applyOnTeam,
                        label: S.current.crmApplyOnTeam,
                        hint: S.current.crmChoose,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.sp),

              // Section 3: Client Details
              CrmSectionCard(
                title: S.current.crmClientDetails,
                child: buildResponsiveFields(
                  context: context,
                  left: CustomDropdown<String>(
                    label: S.current.crmClientType,
                    value: _clientTypeId,
                    hint: S.current.crmChoose,
                    items: widget.clientTypes
                        .map((CrmClientTypeModel t) => DropdownItem<String>(
                              value: t.id,
                              label: isArabic && t.nameAr.isNotEmpty
                                  ? t.nameAr
                                  : t.nameEn,
                            ))
                        .toList(),
                    onChanged: (String? val) {
                      setState(() => _clientTypeId = val);
                    },
                  ),
                  right: CustomMultiSelectDropdown<String>(
                    fillColor: AppColors.background,
                    label: S.current.crmTags,
                    hint: S.current.crmChoose,
                    values: _selectedTagNames,
                    items: widget.tags
                        .map((CrmTagModel t) => MultiSelectDropdownItem<String>(
                              value: t.nameEn,
                              label: t.localizedName(isArabic),
                            ))
                        .toList(),
                    onChanged: (List<String> selected) {
                      setState(() => _selectedTagNames = selected);
                    },
                  ),
                ),
              ),
              SizedBox(height: 24.sp),

              // Bottom Action Buttons: Discard / Save
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  customButton(
                    title: S.current.crmDiscard,
                    function: () => CrmNavigationHelper.pop(context),
                    color: AppColors.field,
                    textColor: AppColors.black,
                    width: isMobile ? 120.sp : 135.sp,
                  ),
                  customButton(
                    title: isEdit ? S.current.crmSave : S.current.crmAdd,
                    function: _canSubmit ? _onSave : () {},
                    color:
                        _canSubmit ? AppColors.primary : AppColors.disabledGrey,
                    textStyle: StyleText.fontSize14Weight500.copyWith(
                      color: _canSubmit ? AppColors.black : AppColors.darkGrey,
                    ),
                    width: isMobile ? 120.sp : 135.sp,
                  ),
                ],
              ),
              SizedBox(height: 32.sp),
            ],
          ),
        ),
      ),
    );
  }
}
