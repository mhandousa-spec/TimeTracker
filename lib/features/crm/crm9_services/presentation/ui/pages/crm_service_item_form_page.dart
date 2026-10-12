// ****************** FILE INFO ******************
// File Name: crm_service_item_form_page.dart
// Purpose: Service Item details, add, and edit UI for CRM Services with single localized inputs.
// Author: Mohand Adel
// Created At: 25/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/12-custom_delete_icon.dart';
import 'package:knowticed_plus/core/custom/13-custom_edit_icon.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';
import 'package:knowticed_plus/features/crm/crm7_products/domain/enums/crm_currency_enum.dart';
import 'package:knowticed_plus/features/crm/crm8_discounts/data/models/crm_discount_model.dart';
import 'package:knowticed_plus/features/crm/crm9_services/data/models/crm_service_category_model.dart';
import 'package:knowticed_plus/features/crm/crm9_services/data/models/crm_service_item_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmServiceItemFormPage extends StatefulWidget {
  final CrmServiceItemModel? service;
  final String mode;
  final List<CrmServiceCategoryModel> categories;
  final List<CrmServiceItemModel> existingServices;
  final List<CrmDiscountModel> discounts;

  const CrmServiceItemFormPage({
    super.key,
    this.service,
    required this.mode,
    required this.categories,
    this.existingServices = const <CrmServiceItemModel>[],
    this.discounts = const <CrmDiscountModel>[],
  });

  @override
  State<CrmServiceItemFormPage> createState() => _CrmServiceItemFormPageState();
}

class _CrmServiceItemFormPageState extends State<CrmServiceItemFormPage> {
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
  String? _priceError;
  String? _taxError;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _nameEn.addListener(_refreshSubmitState);
    _nameAr.addListener(_refreshSubmitState);
    _unitPrice.addListener(_refreshSubmitState);
    _tax.addListener(_refreshSubmitState);
    _mode = widget.mode;
    final CrmServiceItemModel? item = widget.service;
    if (item != null && item.code.isNotEmpty) {
      _code.text = item.code;
    } else {
      _code.text = CrmServiceItemModel.generateCode(widget.existingServices);
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
    final CrmServiceItemModel? orig = widget.service;
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
    final String currentId = widget.service?.id ?? '';
    final bool enValid = en.isNotEmpty &&
        !RegExp(r'[\u0600-\u06FF]').hasMatch(_nameEn.text) &&
        !widget.existingServices.any(
          (CrmServiceItemModel service) =>
              service.id != currentId &&
              service.nameEn.trim().toLowerCase() == en.toLowerCase(),
        );
    final bool arValid = ar.isNotEmpty &&
        !RegExp(r'[a-zA-Z]').hasMatch(_nameAr.text) &&
        !widget.existingServices.any(
          (CrmServiceItemModel service) =>
              service.id != currentId && service.nameAr.trim() == ar,
        );
    return _categoryId?.isNotEmpty == true && enValid && arValid && _hasChanges;
  }

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
      final String currentId = widget.service?.id ?? '';
      final bool exists = widget.existingServices.any(
        (CrmServiceItemModel item) =>
            item.id != currentId &&
            item.nameEn.trim().toLowerCase() == text.toLowerCase(),
      );
      setState(
          () => _nameEnError = exists ? S.current.crmNameAlreadyExists : null);
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
      final String currentId = widget.service?.id ?? '';
      final bool exists = widget.existingServices.any(
        (CrmServiceItemModel item) =>
            item.id != currentId && item.nameAr.trim() == text,
      );
      setState(
          () => _nameArError = exists ? S.current.crmNameAlreadyExists : null);
    }
  }

  void _validateCategory(String? val) {
    if (_view) return;
    if (val == null || val.isEmpty) {
      if (_submitted) {
        setState(() => _categoryError = S.current.crmFieldRequired);
      }
    } else {
      if (_categoryError != null) setState(() => _categoryError = null);
    }
  }

  void _validatePrice(String val) {
    if (_view) return;
    if (val.trim().isEmpty && _submitted) {
      setState(() => _priceError = S.current.crmFieldRequired);
    } else {
      if (_priceError != null) setState(() => _priceError = null);
    }
  }

  void _validateTax(String val) {
    if (_view) return;
    if (val.trim().isEmpty && _submitted) {
      setState(() => _taxError = S.current.crmFieldRequired);
    } else {
      if (_taxError != null) setState(() => _taxError = null);
    }
  }

  void _save() {
    _submitted = true;
    _validateEn(_nameEn.text);
    _validateAr(_nameAr.text);
    _validateCategory(_categoryId);
    _validatePrice(_unitPrice.text);
    _validateTax(_tax.text);
    if (!_canSubmit) return;

    final CrmServiceCategoryModel? category = widget.categories
        .where((CrmServiceCategoryModel c) => c.id == _categoryId)
        .firstOrNull;

    final CrmServiceItemModel service = CrmServiceItemModel(
      id: widget.service?.id ?? '',
      code: _code.text.trim(),
      categoryId: _categoryId ?? '',
      categoryNameEn: category?.nameEn ?? '',
      categoryNameAr: category?.nameAr ?? '',
      nameEn: _nameEn.text.trim(),
      nameAr: _nameAr.text.trim(),
      noteEn: _noteEn.text.trim(),
      noteAr: _noteAr.text.trim(),
      unitPrice: double.tryParse(_unitPrice.text.trim()) ?? 0.0,
      currency: _currency,
      tax: double.tryParse(_tax.text.trim()) ?? 0.0,
      discountRule: _selectedDiscountRule ?? '',
      status: _status,
      isActive: _status == 'active' || _status == 'Active',
    );

    CrmControlDialogs.showSaveDialog(
      context: context,
      title: S.current.crmSave,
      subtitle: S.current.crmSaveCategoryConfirm,
      onConfirm: () => CrmNavigationHelper.pop(
        context,
        <String, dynamic>{
          'action': 'save',
          'service': service,
        },
      ),
    );
  }

  void _delete() {
    CrmControlDialogs.showRemoveDialog(
      context: context,
      title: S.current.crmRemove,
      subtitle: S.current.crmDeleteCategoryConfirm,
      onConfirm: () => CrmNavigationHelper.pop(
        context,
        <String, dynamic>{'action': 'delete'},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final String thirdTitle = _view
        ? (widget.service?.localizedName(isArabic).isNotEmpty == true
            ? widget.service!.localizedName(isArabic)
            : S.current.crmDetails)
        : widget.service == null
            ? (isArabic ? 'إضافة خدمة' : 'Add Service')
            : (isArabic ? 'تعديل خدمة' : 'Edit Service');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: S.current.crm,
        secondTitle: S.current.crmSectionServices,
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
              _buildServiceDetailsSection(isArabic),
              SizedBox(height: 20.sp),
              _buildPricingDetailsSection(isArabic),
              SizedBox(height: 24.sp),
              if (!_view) _buildBottomActions(),
              SizedBox(height: 24.sp),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopActionBar() {
    final bool isActive = _status.toLowerCase() == 'active';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          height: 38.sp,
          padding: EdgeInsets.symmetric(horizontal: 12.sp),
          decoration: BoxDecoration(
            color: isActive ? AppColors.green : AppColors.orange,
            borderRadius: BorderRadius.circular(8.sp),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: isActive ? 'active' : 'inactive',
              dropdownColor: AppColors.white,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
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
                if (value == null) return;
                CrmControlDialogs.showSaveDialog(
                  context: context,
                  title: S.current.crmSave,
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
    );
  }

  Widget _buildServiceDetailsSection(bool isArabic) {
    return CrmSectionCard(
      title: S.current.serviceDetails,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          buildResponsiveFields(
            context: context,
            left: CustomTextField(
              controller: _code,
              label: 'Code',
              hint: 'CS-00001',
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
                value: _categoryId,
                label: 'Category',
                hint: 'Choose',
                enabled: true,
                errorText: _categoryError,
                items: widget.categories
                    .map((CrmServiceCategoryModel item) => DropdownItem<String>(
                          value: item.id,
                          label: item.localizedName(isArabic),
                        ))
                    .toList(),
                onChanged: (String? value) {
                  setState(() => _categoryId = value);
                  _validateCategory(value);
                },
              ),
            ),
          ),
          SizedBox(height: 16.sp),
          buildResponsiveFields(
            context: context,
            left: CustomTextField(
              controller: _nameEn,
              label: 'Name',
              hint: 'Text Here',
              readOnly: _view,
              errorText: _nameEnError,
              onChanged: (dynamic val) => _validateEn(val?.toString() ?? ''),
            ),
            right: Directionality(
              textDirection: TextDirection.rtl,
              child: CustomTextField(
                controller: _nameAr,
                label: 'الاسم',
                hint: 'اكتب هنا',
                textAlign: TextAlign.right,
                readOnly: _view,
                errorText: _nameArError,
                onChanged: (dynamic val) => _validateAr(val?.toString() ?? ''),
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
              textAlign: TextAlign.right,
              readOnly: _view,
              maxLines: 4,
              maxLength: 500,
              showCharCount: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingDetailsSection(bool isArabic) {
    return CrmSectionCard(
      title: isArabic ? 'تفاصيل التسعير' : 'Pricing Details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          buildResponsiveFields(
            context: context,
            left: CustomTextField(
              controller: _unitPrice,
              label: isArabic ? 'السعر' : 'Price',
              hint: 'Text Here',
              readOnly: _view,
              errorText: _priceError,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (dynamic val) {
                _validatePrice(val?.toString() ?? '');
                _refreshSubmitState();
              },
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
                value: _currency,
                label: isArabic ? 'العملة' : 'Currency',
                hint: 'Choose',
                enabled: true,
                items: CrmCurrencyEnum.values
                    .map((CrmCurrencyEnum c) => DropdownItem<String>(
                          value: c.code,
                          label: '${c.code} (${c.localizedSymbol(isArabic)})',
                        ))
                    .toList(),
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() => _currency = value);
                  }
                },
              ),
            ),
          ),
          SizedBox(height: 16.sp),
          buildResponsiveFields(
            context: context,
            left: CustomTextField(
              controller: _tax,
              label: isArabic ? 'الضريبة' : 'Tax',
              hint: 'Text Here',
              readOnly: _view,
              errorText: _taxError,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (dynamic val) {
                _validateTax(val?.toString() ?? '');
                _refreshSubmitState();
              },
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
                value: _selectedDiscountRule,
                label: isArabic ? 'قاعدة الخصم' : 'Discount Rule',
                hint: 'Choose',
                enabled: true,
                items: [
                  DropdownItem<String>(
                    value: '',
                    label: 'Choose',
                  ),
                  ...widget.discounts
                      .map((CrmDiscountModel d) => DropdownItem<String>(
                            value: d.nameEn,
                            label: d.localizedName(isArabic),
                          )),
                ],
                onChanged: (String? value) =>
                    setState(() => _selectedDiscountRule = value),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Padding(
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
            title: _mode == 'edit' ? S.current.crmSave : S.current.crmAdd,
            function: _canSubmit ? _save : () {},
            color: _canSubmit ? AppColors.primary : AppColors.disabledGrey,
            textStyle: StyleText.fontSize14Weight500.copyWith(
              color: _canSubmit ? AppColors.black : AppColors.darkGrey,
            ),
          ),
        ],
      ),
    );
  }
}
