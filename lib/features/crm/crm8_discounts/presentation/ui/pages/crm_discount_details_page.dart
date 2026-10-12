// ****************** FILE INFO ******************
// File Name: crm_discount_details_page.dart
// Purpose: View Discount Details page matching Figma node 95:70204 with full system metadata
// Author: Mohand Adel
// Created At: 23/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/12-custom_delete_icon.dart';
import 'package:knowticed_plus/core/custom/13-custom_edit_icon.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
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

class CrmDiscountDetailsPage extends StatefulWidget {
  final CrmDiscountModel discount;
  final List<CrmDiscountModel> existingDiscounts;
  final List<CrmProductCategoryModel> categories;
  final List<CrmProductItemModel> products;
  final List<CrmClientTypeModel> clientTypes;
  final List<CrmTagModel> tags;

  const CrmDiscountDetailsPage({
    super.key,
    required this.discount,
    this.existingDiscounts = const <CrmDiscountModel>[],
    this.categories = const <CrmProductCategoryModel>[],
    this.products = const <CrmProductItemModel>[],
    this.clientTypes = const <CrmClientTypeModel>[],
    this.tags = const <CrmTagModel>[],
  });

  @override
  State<CrmDiscountDetailsPage> createState() => _CrmDiscountDetailsPageState();
}

class _CrmDiscountDetailsPageState extends State<CrmDiscountDetailsPage> {
  late CrmDiscountModel _currentDiscount;
  late String _status;

  @override
  void initState() {
    super.initState();
    _currentDiscount = widget.discount;
    _status = widget.discount.status;
  }

  Future<void> _onEdit() async {
    final dynamic result =
        await CrmNavigationHelper.navigateToControlDiscountForm(
      context,
      arguments: <String, dynamic>{
        'discount': _currentDiscount,
        'mode': 'edit',
        'existingDiscounts': widget.existingDiscounts,
        'categories': widget.categories,
        'products': widget.products,
        'clientTypes': widget.clientTypes,
        'tags': widget.tags,
      },
    );

    if (!mounted || result is! Map<String, dynamic>) return;
    final String action = (result['action'] ?? '').toString();

    if (action == 'save') {
      final CrmDiscountModel? updated = result['discount'] as CrmDiscountModel?;
      if (updated != null) {
        setState(() {
          _currentDiscount = updated;
          _status = updated.status;
        });
        CrmNavigationHelper.pop(
          context,
          <String, dynamic>{'action': 'save', 'discount': updated},
        );
      }
    }
  }

  void _onDelete() {
    CrmControlDialogs.showRemoveDialog(
      context: context,
      title: S.current.crmDeleteDiscountConfirm,
      subtitle: S.current.crmRemoveFieldSubtitle,
      onConfirm: () => CrmNavigationHelper.pop(
        context,
        <String, dynamic>{'action': 'delete'},
      ),
    );
  }

  String _getCategoryDisplay(bool isArabic) {
    if (_currentDiscount.categoryNameEn.isNotEmpty ||
        _currentDiscount.categoryNameAr.isNotEmpty) {
      return _currentDiscount.localizedCategoryName(isArabic);
    }
    if (_currentDiscount.categoryId.isNotEmpty) {
      try {
        final CrmProductCategoryModel cat = widget.categories
            .firstWhere((c) => c.id == _currentDiscount.categoryId);
        return cat.localizedName(isArabic);
      } catch (_) {}
    }
    return '-';
  }

  String _getProductDisplay(bool isArabic) {
    if (_currentDiscount.productNameEn.isNotEmpty ||
        _currentDiscount.productNameAr.isNotEmpty) {
      return _currentDiscount.localizedProductName(isArabic);
    }
    if (_currentDiscount.productId.isNotEmpty) {
      try {
        final CrmProductItemModel prod = widget.products
            .firstWhere((p) => p.id == _currentDiscount.productId);
        return prod.localizedName(isArabic);
      } catch (_) {}
    }
    return '-';
  }

  String _getClientTypeDisplay(bool isArabic) {
    if (_currentDiscount.clientTypeName.isNotEmpty) {
      return _currentDiscount.clientTypeName;
    }
    if (_currentDiscount.clientTypeId.isNotEmpty) {
      try {
        final CrmClientTypeModel type = widget.clientTypes
            .firstWhere((t) => t.id == _currentDiscount.clientTypeId);
        return isArabic && type.nameAr.isNotEmpty ? type.nameAr : type.nameEn;
      } catch (_) {}
    }
    return '-';
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: S.current.crm,
        secondTitle: S.current.crmSectionControls,
        thirdTitle: S.current.crmControlDiscount,
        fourthTitle: _currentDiscount.localizedName(isArabic),
        onFirstTap: () => CrmNavigationHelper.popToDashboard(context),
        onSecondTap: () => CrmNavigationHelper.pop(context),
        onThirdTap: () => CrmNavigationHelper.pop(context),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Top Action Controls: Status switch & Edit / Delete Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  // Status Dropdown
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
                        onChanged: (String? val) {
                          if (val != null && val != _status) {
                            setState(() => _status = val);
                            final CrmDiscountModel updated =
                                _currentDiscount.copyWith(
                              status: val,
                              isActive: val == 'active',
                            );
                            _currentDiscount = updated;
                          }
                        },
                      ),
                    ),
                  ),

                  // Actions: Edit and Delete
                  Row(
                    children: <Widget>[
                      CustomEditIcon(onTap: _onEdit),
                      SizedBox(width: 12.sp),
                      CustomDeleteIcon(
                        onTap: _onDelete,
                        color: AppColors.red,
                        svgColor: AppColors.black,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20.sp),

              // Section 1: Rule Details (Read-only)
              CrmSectionCard(
                title: S.current.crmRuleDetails,
                child: Column(
                  children: <Widget>[
                    buildResponsiveFields(
                      context: context,
                      left: CustomTextField(
                        controller: TextEditingController(
                            text: _currentDiscount.nameEn),
                        label: 'Rule Name',
                        readOnly: true,
                      ),
                      right: Directionality(
                        textDirection: TextDirection.rtl,
                        child: CustomTextField(
                          controller: TextEditingController(
                              text: _currentDiscount.nameAr),
                          label: 'اسم القاعدة',
                          textAlign: TextAlign.right,
                          readOnly: true,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.sp),
                    buildResponsiveFields(
                      context: context,
                      left: CustomTextField(
                        controller: TextEditingController(
                            text: _currentDiscount.displayType),
                        label: S.current.crmType,
                        readOnly: true,
                      ),
                      right: const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.sp),

              // Section 2: Discount Details (Read-only)
              CrmSectionCard(
                title: S.current.crmDiscountDetails,
                child: Column(
                  children: <Widget>[
                    buildResponsiveFields(
                      context: context,
                      left: CustomTextField(
                        controller: TextEditingController(
                          text: _getCategoryDisplay(isArabic),
                        ),
                        label: S.current.crmProductsCategory,
                        readOnly: true,
                      ),
                      right: CustomTextField(
                        controller: TextEditingController(
                          text: _getProductDisplay(isArabic),
                        ),
                        label: S.current.crmSectionProducts,
                        readOnly: true,
                      ),
                    ),
                    SizedBox(height: 12.sp),
                    buildResponsiveFields(
                      context: context,
                      left: CustomTextField(
                        controller: TextEditingController(
                          text: _currentDiscount.minQuantity > 0
                              ? _currentDiscount.minQuantity.toString()
                              : '-',
                        ),
                        label: S.current.crmMinimumQuantity,
                        readOnly: true,
                      ),
                      right: CustomTextField(
                        controller: TextEditingController(
                          text: _currentDiscount.maxQuantity > 0
                              ? _currentDiscount.maxQuantity.toString()
                              : '-',
                        ),
                        label: S.current.crmMaximumQuantity,
                        readOnly: true,
                      ),
                    ),
                    SizedBox(height: 12.sp),
                    buildResponsiveFields(
                      context: context,
                      left: CustomTextField(
                        controller: TextEditingController(
                          text: _currentDiscount.formattedDiscountValue,
                        ),
                        label: S.current.crmDiscountValue,
                        readOnly: true,
                      ),
                      right: CustomTextField(
                        controller: TextEditingController(
                          text: _currentDiscount.displayTeam,
                        ),
                        label: S.current.crmApplyOnTeam,
                        readOnly: true,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.sp),

              // Section 3: Client Details (Read-only)
              CrmSectionCard(
                title: S.current.crmClientDetails,
                child: buildResponsiveFields(
                  context: context,
                  left: CustomTextField(
                    controller: TextEditingController(
                      text: _getClientTypeDisplay(isArabic),
                    ),
                    label: S.current.crmClientType,
                    readOnly: true,
                  ),
                  right: CustomTextField(
                    controller: TextEditingController(
                      text: _currentDiscount.tags.isNotEmpty
                          ? _currentDiscount.tags.join(', ')
                          : '-',
                    ),
                    label: S.current.crmTags,
                    readOnly: true,
                  ),
                ),
              ),
              SizedBox(height: 32.sp),
            ],
          ),
        ),
      ),
    );
  }
}
