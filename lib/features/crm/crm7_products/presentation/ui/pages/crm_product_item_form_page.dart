// ****************** FILE INFO ******************
// File Name: crm_product_item_form_page.dart
// Purpose: Product Item details, add, and edit UI for CRM Products matching Figma designs.
// Author: Mohand Adel
// Created At: 23/08/2026

import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/12-custom_delete_icon.dart';
import 'package:knowticed_plus/core/custom/13-custom_edit_icon.dart';
import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';
import 'package:knowticed_plus/features/crm/crm7_products/data/models/crm_product_category_model.dart';
import 'package:knowticed_plus/features/crm/crm7_products/data/models/crm_product_item_model.dart';
import 'package:knowticed_plus/features/crm/crm7_products/domain/enums/crm_currency_enum.dart';
import 'package:knowticed_plus/features/crm/crm8_discounts/data/models/crm_discount_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmProductItemFormPage extends StatefulWidget {
  final CrmProductItemModel? product;
  final String mode;
  final List<CrmProductCategoryModel> categories;
  final List<CrmProductItemModel> existingProducts;
  final List<CrmDiscountModel> discounts;

  const CrmProductItemFormPage({
    super.key,
    this.product,
    required this.mode,
    required this.categories,
    this.existingProducts = const <CrmProductItemModel>[],
    this.discounts = const <CrmDiscountModel>[],
  });

  @override
  State<CrmProductItemFormPage> createState() => _CrmProductItemFormPageState();
}

class _CrmProductItemFormPageState extends State<CrmProductItemFormPage> {
  final TextEditingController _code = TextEditingController();
  final TextEditingController _nameEn = TextEditingController();
  final TextEditingController _nameAr = TextEditingController();
  final TextEditingController _noteEn = TextEditingController();
  final TextEditingController _noteAr = TextEditingController();
  final TextEditingController _unitPrice = TextEditingController();
  final TextEditingController _tax = TextEditingController();

  late String _mode;
  String? _categoryId;
  String? _selectedDiscountRule;
  String _currency = CrmCurrencyEnum.defaultCurrency.code;
  String _status = 'active';

  String? _nameEnError;
  String? _nameArError;
  String? _categoryError;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _nameEn.addListener(_refreshSubmitState);
    _nameAr.addListener(_refreshSubmitState);
    _mode = widget.mode;
    final CrmProductItemModel? item = widget.product;
    if (item != null && item.code.isNotEmpty) {
      _code.text = item.code;
    } else {
      _code.text = CrmProductItemModel.generateCode(widget.existingProducts);
    }
    if (item != null) {
      _categoryId = item.categoryId.isNotEmpty ? item.categoryId : null;
      _nameEn.text = item.nameEn;
      _nameAr.text = item.nameAr;
      _noteEn.text = item.noteEn;
      _noteAr.text = item.noteAr;
      _unitPrice.text =
          item.unitPrice > 0 ? item.unitPrice.toStringAsFixed(0) : '';
      _currency = item.currency.isNotEmpty
          ? item.currency
          : CrmCurrencyEnum.defaultCurrency.code;
      _tax.text = item.tax > 0 ? item.tax.toStringAsFixed(0) : '';
      _selectedDiscountRule =
          item.discountRule.isNotEmpty ? item.discountRule : null;
      _status = item.status;
    } else {
      if (widget.categories.isNotEmpty) {
        _categoryId = widget.categories.first.id;
      }
    }
  }

  @override
  void dispose() {
    _code.dispose();
    _nameEn.dispose();
    _nameAr.dispose();
    _noteEn.dispose();
    _noteAr.dispose();
    _unitPrice.dispose();
    _tax.dispose();
    super.dispose();
  }

  bool get _view => _mode == 'view';

  void _refreshSubmitState() {
    if (mounted) setState(() {});
  }

  bool get _hasChanges {
    if (_mode != 'edit') return true;
    final CrmProductItemModel? orig = widget.product;
    if (orig == null) return true;
    if (_nameEn.text.trim() != orig.nameEn.trim()) return true;
    if (_nameAr.text.trim() != orig.nameAr.trim()) return true;
    if (_noteEn.text.trim() != orig.noteEn.trim()) return true;
    if (_noteAr.text.trim() != orig.noteAr.trim()) return true;
    if ((_categoryId ?? '') != orig.categoryId) return true;
    final double currentPrice = double.tryParse(_unitPrice.text.trim()) ?? 0.0;
    if (currentPrice != orig.unitPrice) return true;
    final double currentTax = double.tryParse(_tax.text.trim()) ?? 0.0;
    if (currentTax != orig.tax) return true;
    if (_currency != orig.currency) return true;
    final String origDiscount = orig.discountRule;
    if ((_selectedDiscountRule ?? '') != origDiscount) return true;
    if (_status != orig.status) return true;
    return false;
  }

  bool get _canSubmit {
    final String en = _nameEn.text.trim();
    final String ar = _nameAr.text.trim();
    final String currentId = widget.product?.id ?? '';
    return _categoryId?.isNotEmpty == true &&
        en.isNotEmpty &&
        ar.isNotEmpty &&
        !RegExp(r'[\u0600-\u06FF]').hasMatch(en) &&
        !RegExp(r'[a-zA-Z]').hasMatch(ar) &&
        !widget.existingProducts.any(
          (CrmProductItemModel product) =>
              product.id != currentId &&
              (product.nameEn.trim().toLowerCase() == en.toLowerCase() ||
                  product.nameAr.trim() == ar),
        ) &&
        _hasChanges;
  }

  List<CrmDiscountModel> get _applicableDiscounts {
    final CrmProductCategoryModel? selectedCat = widget.categories
        .where((CrmProductCategoryModel c) => c.id == _categoryId)
        .firstOrNull;
    final String catClientTypeId = selectedCat?.clientTypeId ?? '';

    return widget.discounts.where((CrmDiscountModel d) {
      if (!d.isActive || d.isDeleted || d.status.toLowerCase() != 'active') {
        return false;
      }
      if (d.type != 'Product' && d.type != 'Both') {
        return false;
      }
      if (d.clientTypeId.isNotEmpty && catClientTypeId.isNotEmpty) {
        if (d.clientTypeId != catClientTypeId) {
          return false;
        }
      }
      if (d.categoryId.isNotEmpty &&
          _categoryId != null &&
          _categoryId!.isNotEmpty) {
        if (d.categoryId != _categoryId) {
          return false;
        }
      }
      final String prodId = widget.product?.id ?? '';
      if (d.productId.isNotEmpty && prodId.isNotEmpty) {
        if (d.productId != prodId) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  String _discountLabel(CrmDiscountModel d, bool isArabic) =>
      d.localizedName(isArabic);

  String? get _currentDiscountValue {
    for (final CrmDiscountModel d in _applicableDiscounts) {
      if (d.id == _selectedDiscountRule || d.nameEn == _selectedDiscountRule) {
        return d.nameEn;
      }
    }
    return null;
  }

  String _categoryLabel(CrmProductCategoryModel cat, bool isArabic) =>
      isArabic && cat.nameAr.isNotEmpty ? cat.nameAr : cat.nameEn;

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
      final String currentId = widget.product?.id ?? '';
      final bool isDuplicate = widget.existingProducts.any(
        (CrmProductItemModel p) =>
            p.id != currentId &&
            p.nameEn.trim().toLowerCase() == text.toLowerCase(),
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
      final String currentId = widget.product?.id ?? '';
      final bool isDuplicate = widget.existingProducts.any(
        (CrmProductItemModel p) => p.id != currentId && p.nameAr.trim() == text,
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
    String? catErr;

    if (en.isEmpty) {
      enErr = S.current.crmFieldRequired;
    } else if (RegExp(r'[\u0600-\u06FF]').hasMatch(_nameEn.text)) {
      enErr = S.current.crmEnglishLettersOnlyTitle;
    } else {
      final String currentId = widget.product?.id ?? '';
      final bool isDuplicate = widget.existingProducts.any(
        (CrmProductItemModel p) =>
            p.id != currentId &&
            p.nameEn.trim().toLowerCase() == en.toLowerCase(),
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
      final String currentId = widget.product?.id ?? '';
      final bool isDuplicate = widget.existingProducts.any(
        (CrmProductItemModel p) => p.id != currentId && p.nameAr.trim() == ar,
      );
      if (isDuplicate) {
        arErr = S.current.crmNameAlreadyExists;
      }
    }

    if (_categoryId == null || _categoryId!.isEmpty) {
      catErr = S.current.crmFieldRequired;
    }

    setState(() {
      _nameEnError = enErr;
      _nameArError = arErr;
      _categoryError = catErr;
    });

    return enErr == null && arErr == null && catErr == null;
  }

  void _save() {
    setState(() => _submitted = true);
    if (!_validateForm()) {
      return;
    }

    final CrmProductCategoryModel? selectedCat = widget.categories
        .where((CrmProductCategoryModel c) => c.id == _categoryId)
        .firstOrNull;

    final CrmProductItemModel item =
        (widget.product ?? CrmProductItemModel.empty()).copyWith(
      code: _code.text.trim(),
      categoryId: _categoryId ?? '',
      categoryNameEn: selectedCat?.nameEn ?? '',
      categoryNameAr: selectedCat?.nameAr ?? '',
      nameEn: _nameEn.text.trim(),
      nameAr: _nameAr.text.trim(),
      noteEn: _noteEn.text.trim(),
      noteAr: _noteAr.text.trim(),
      unitPrice: double.tryParse(_unitPrice.text.trim()) ?? 0.0,
      currency: _currency,
      tax: double.tryParse(_tax.text.trim()) ?? 0.0,
      discountRule: _selectedDiscountRule ?? '',
      status: _status,
      isActive: _status.toLowerCase() == 'active',
    );

    CrmControlDialogs.showSaveDialog(
      context: context,
      title:
          widget.product == null ? S.current.crmAdd : S.current.crmSaveForLater,
      subtitle: S.current.crmSaveCategoryConfirm,
      onConfirm: () {
        Navigator.pop(context, <String, dynamic>{
          'action': 'save',
          'product': item,
        });
      },
    );
  }

  void _delete() {
    CrmControlDialogs.showRemoveDialog(
      context: context,
      title: S.current.crmCategory,
      subtitle: S.current.crmDeleteCategoryConfirm,
      onConfirm: () {
        Navigator.pop(context, <String, dynamic>{
          'action': 'delete',
        });
      },
    );
  }

  void _toggleStatus(String newStatus) {
    setState(() => _status = newStatus);
    if (_view && widget.product != null) {
      Navigator.pop(context, <String, dynamic>{
        'action': 'status',
        'isActive': newStatus.toLowerCase() == 'active',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final String thirdTitle = _view
        ? S.current.crmDetails
        : widget.product == null
            ? S.current.crmAdd
            : S.current.crmEdit;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: S.current.crm,
        secondTitle: S.current.crmSectionProducts,
        thirdTitle: thirdTitle,
        onFirstTap: () => CrmNavigationHelper.popToDashboard(context),
        onSecondTap: () => Navigator.pop(context),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (_view) ...[
                _buildTopActionBar(),
                SizedBox(height: 16.sp),
              ],
              _buildProductDetailsSection(isArabic),
              SizedBox(height: 20.sp),
              _buildPricingDetailsSection(isArabic),
              SizedBox(height: 24.sp),
              if (!_view) _buildBottomActions(),
              SizedBox(height: 32.sp),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopActionBar() {
    final bool isActive = _status.toLowerCase() == 'active';

    return Row(
      children: <Widget>[
        Container(
          height: 38.sp,
          padding: EdgeInsets.symmetric(horizontal: 10.sp),
          decoration: BoxDecoration(
            color: isActive ? AppColors.green : AppColors.darkGrey,
            borderRadius: BorderRadius.circular(8.sp),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: isActive ? 'active' : 'inactive',
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
              onChanged: (String? val) {
                if (val != null) _toggleStatus(val);
              },
            ),
          ),
        ),
        const Spacer(),
        CustomEditIcon(
          onTap: () => setState(() => _mode = 'edit'),
        ),
        SizedBox(width: 10.sp),
        CustomDeleteIcon(
          onTap: _delete,
          svgColor: AppColors.white,
          color: AppColors.red,
        ),
      ],
    );
  }

  Widget _buildProductDetailsSection(bool isArabic) {
    return CrmSectionCard(
      title: 'Product Details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          buildResponsiveFields(
            context: context,
            left: CustomTextField(
              controller: _code,
              label: 'Code',
              readOnly: true,
            ),
            right: IgnorePointer(
              ignoring: _view,
              child: CustomDropdown<String>(
                fillColor: AppColors.background,
                labelStyle: TextStyle(
                  color: AppColors.text,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
                hint: S.current.crmChoose,
                label: S.current.crmCategory,
                value: _categoryId,
                items: widget.categories
                    .map((CrmProductCategoryModel item) => DropdownItem<String>(
                          value: item.id,
                          label: _categoryLabel(item, isArabic),
                        ))
                    .toList(),
                onChanged: (String? val) {
                  setState(() {
                    _categoryId = val;
                    if (_categoryError != null && val != null) {
                      _categoryError = null;
                    }
                    final bool stillValid = _applicableDiscounts.any((d) =>
                        d.id == _selectedDiscountRule ||
                        d.nameEn == _selectedDiscountRule);
                    if (!stillValid) {
                      _selectedDiscountRule = null;
                    }
                  });
                },
                enabled: true,
                errorText: _categoryError,
              ),
            ),
          ),
          SizedBox(height: 14.sp),
          buildResponsiveFields(
            context: context,
            left: CustomTextField(
              controller: _nameEn,
              label: 'Product Name',
              hint: 'Text Here',
              readOnly: _view,
              errorText: _nameEnError,
              onChanged: (dynamic val) => _validateEn(val?.toString() ?? ''),
            ),
            right: Directionality(
              textDirection: TextDirection.rtl,
              child: CustomTextField(
                controller: _nameAr,
                label: 'اسم المنتج',
                hint: 'اكتب هنا',
                readOnly: _view,
                errorText: _nameArError,
                textAlign: TextAlign.right,
                onChanged: (dynamic val) => _validateAr(val?.toString() ?? ''),
              ),
            ),
          ),
          SizedBox(height: 14.sp),
          CustomTextField(
            controller: _noteEn,
            label: 'Description',
            hint: 'Text Here',
            maxLines: 3,
            maxLength: 500,
            showCharCount: true,
            readOnly: _view,
            onChanged: (_) => setState(() {}),
          ),
          SizedBox(height: 14.sp),
          Directionality(
            textDirection: TextDirection.rtl,
            child: CustomTextField(
              controller: _noteAr,
              label: 'التفاصيل',
              hint: 'اكتب هنا',
              maxLines: 3,
              maxLength: 500,
              showCharCount: true,
              textAlign: TextAlign.right,
              readOnly: _view,
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingDetailsSection(bool isArabic) {
    return CrmSectionCard(
      title: 'Pricing Details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          buildResponsiveFields(
            context: context,
            left: CustomTextField(
              controller: _unitPrice,
              label: 'Unit Price',
              hint: S.current.crmTextHere,
              readOnly: _view,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            right: IgnorePointer(
              ignoring: _view,
              child: CustomDropdown<String>(
                fillColor: AppColors.background,
                labelStyle: TextStyle(
                  color: AppColors.text,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
                hint: S.current.crmChoose,
                label: 'Currency',
                value: _currency,
                items: CrmCurrencyEnum.values
                    .map((CrmCurrencyEnum c) => DropdownItem<String>(
                          value: c.code,
                          label: c.displayName,
                        ))
                    .toList(),
                onChanged: (String? val) {
                  if (val != null) setState(() => _currency = val);
                },
                enabled: true,
              ),
            ),
          ),
          SizedBox(height: 14.sp),
          buildResponsiveFields(
            context: context,
            left: CustomTextField(
              controller: _tax,
              label: 'Tax (%)',
              hint: S.current.crmTextHere,
              readOnly: _view,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            right: IgnorePointer(
              ignoring: _view,
              child: CustomDropdown<String>(
                fillColor: AppColors.background,
                labelStyle: TextStyle(
                  color: AppColors.text,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
                hint: S.current.crmChoose,
                label: 'Discount Rule',
                value: _currentDiscountValue,
                items: _applicableDiscounts
                    .map((CrmDiscountModel d) => DropdownItem<String>(
                          value: d.nameEn,
                          label: _discountLabel(d, isArabic),
                        ))
                    .toList(),
                onChanged: (String? val) {
                  setState(() => _selectedDiscountRule = val);
                },
                enabled: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        customButton(
          title: S.current.crmDiscard,
          color: AppColors.grey,
          textColor: AppColors.text,
          function: () => Navigator.pop(context),
        ),
        customButton(
          title: widget.product == null ? S.current.crmAdd : S.current.crmSave,
          color: _canSubmit ? AppColors.primary : AppColors.disabledGrey,
          textStyle: StyleText.fontSize14Weight500.copyWith(
            color: _canSubmit ? AppColors.black : AppColors.darkGrey,
          ),
          function: _canSubmit ? _save : () {},
        ),
      ],
    );
  }
}
