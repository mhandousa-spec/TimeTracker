// ****************** FILE INFO ******************
// File Name: crm_add_government_form.dart
// Purpose: Form widget for adding Government-type CRM clients matching approved Figma design
// Author: Mohand Adel
// Created At: 03/08/2026

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';
import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_add_client_form.dart';

import 'package:knowticed_plus/generated/l10n.dart';

class CrmAddGovernmentForm extends StatelessWidget {
  final CrmAddClientControllers controllers;
  final String? sector;
  final String? tag;
  final String? country;
  final String? city;
  final File? clientImage;
  final bool showClientDetails;
  final bool showAddress;
  final ValueChanged<String> onSectorChanged;
  final ValueChanged<String> onTagChanged;
  final ValueChanged<String> onCountryChanged;
  final ValueChanged<String> onCityChanged;
  final ValueChanged<File> onClientImagePicked;
  final VoidCallback onBusinessDateTap;
  final VoidCallback onToggleClientDetails;
  final VoidCallback onToggleAddress;
  final VoidCallback onDiscard;
  final VoidCallback onAdd;
  final VoidCallback onSaveForLater;
  final VoidCallback onViewClient;

  const CrmAddGovernmentForm({
    super.key,
    required this.controllers,
    required this.sector,
    required this.tag,
    required this.country,
    required this.city,
    required this.clientImage,
    required this.showClientDetails,
    required this.showAddress,
    required this.onSectorChanged,
    required this.onTagChanged,
    required this.onCountryChanged,
    required this.onCityChanged,
    required this.onClientImagePicked,
    required this.onBusinessDateTap,
    required this.onToggleClientDetails,
    required this.onToggleAddress,
    required this.onDiscard,
    required this.onAdd,
    required this.onSaveForLater,
    required this.onViewClient,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Client Details Section Header (Title & Hide outside container)
        _buildSectionHeader(
          title: S.current.crmClientDetails,
          isExpanded: showClientDetails,
          onTap: onToggleClientDetails,
        ),
        SizedBox(height: 8.h),

        // Client Details Container Box
        if (showClientDetails) _buildClientDetailsCard(context),
        SizedBox(height: 16.h),

        // 2. Address Section Header (Title & Hide outside container)
        _buildSectionHeader(
          title: S.current.crmAddress,
          isExpanded: showAddress,
          onTap: onToggleAddress,
        ),
        SizedBox(height: 8.h),

        // Address Container Box
        if (showAddress) _buildAddressCard(context),
        SizedBox(height: 16.h),

        // 3. Add Address Action Button
        _buildAddAddressButton(),
        SizedBox(height: 16.h),

        // 4. Duplication Alert Banner
        _buildDuplicationAlertCard(),
        SizedBox(height: 24.h),

        // 5. Bottom Action Buttons (Discard / Next / Save for Later)
        _buildBottomActions(),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: StyleText.fontSize16Weight600.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            isExpanded ? S.current.crmHide : S.current.crmShow,
            style: StyleText.fontSize12Weight400.copyWith(color: AppColors.mediumGrey).copyWith(
              color: AppColors.blue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClientDetailsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.all(20.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Picker
          CustomImagePicker(
            imageFile: clientImage,
            onImagePicked: onClientImagePicked,
          ),
          SizedBox(height: 20.h),

          // Row 1: Entity Name (EN) & Entity Name (AR)
          _fieldPair(
            context,
            _requiredField(
              controller: controllers.entityName,
              label: 'Entity Name',
              hint: 'Text Here',
            ),
            _requiredField(
              controller: controllers.arabicEntityName,
              label: 'اسم الكيان',
              hint: 'اكتب هنا',
              isArabic: true,
            ),
          ),

          // Row 2: Sector & Tags
          _fieldPair(
            context,
            _dropdown(
              label: 'Sector',
              value: sector,
              items: const [
                'Ministry',
                'Authority',
                'Municipality',
                'Commission',
                'Public Service'
              ],
              onChanged: onSectorChanged,
              errorText: 'Field Required',
            ),
            _dropdown(
              label: 'Tags',
              value: tag,
              items: const ['Priority', 'VIP', 'Federal', 'Local', 'Strategic'],
              onChanged: onTagChanged,
            ),
          ),

          // Row 3: Business Initiation Date & Website
          _fieldPair(
            context,
            _requiredField(
              controller: controllers.businessInitiationDate,
              label: 'Business Initiation Date',
              hint: 'Select Date',
              readOnly: true,
              onTap: onBusinessDateTap,
              suffixIcon: CustomSvgImage(
                assetPath: AppAssets.calendar,
                width: 18.sp,
                height: 18.sp,
                color: AppColors.grey,
              ),
            ),
            CustomTextField(
              controller: controllers.website,
              label: 'Website',
              hint: 'Text Here',
              height: 36.sp,
              fillColor: AppColors.background,
              labelStyle: StyleText.fontSize14Weight400,
              hintStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.lightGrey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.all(20.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Country & City
          _fieldPair(
            context,
            _dropdown(
              label: 'Country',
              value: country,
              items: const [
                'Saudi Arabia',
                'UAE',
                'Kuwait',
                'Bahrain',
                'Qatar',
                'Oman'
              ],
              onChanged: onCountryChanged,
              errorText: 'Field Required',
            ),
            _dropdown(
              label: 'City',
              value: city,
              items: const [
                'Riyadh',
                'Jeddah',
                'Dammam',
                'Khobar',
                'Mecca',
                'Medina'
              ],
              onChanged: onCityChanged,
            ),
          ),

          // Row 2: Province & Street
          _fieldPair(
            context,
            CustomTextField(
              controller: controllers.province,
              label: 'Province',
              hint: 'Text Here',
              height: 36.sp,
              fillColor: AppColors.background,
              labelStyle: StyleText.fontSize14Weight400,
              hintStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.lightGrey),
            ),
            CustomTextField(
              controller: controllers.street,
              label: 'Street',
              hint: 'Text Here',
              height: 36.sp,
              fillColor: AppColors.background,
              labelStyle: StyleText.fontSize14Weight400,
              hintStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.lightGrey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _requiredField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isArabic = false,
    bool readOnly = false,
    Widget? suffixIcon,
    VoidCallback? onTap,
  }) {
    final Widget field = CustomTextField(
      controller: controller,
      label: label,
      hint: hint,
      height: 36.sp,
      errorText: S.current.crmFieldRequired,
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      textAlign: isArabic ? TextAlign.right : TextAlign.left,
      readOnly: readOnly,
      suffixIcon: suffixIcon,
      onTap: onTap,
      fillColor: AppColors.background,
      borderRadius: BorderRadius.circular(4.sp),
      labelStyle: StyleText.fontSize14Weight400,
      hintStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.lightGrey),
      errorStyle: StyleText.fontSize10Weight400.copyWith(
        color: AppColors.red,
      ),
    );

    if (!isArabic) return field;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: field,
    );
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String> onChanged,
    String? errorText,
  }) {
    return CustomDropdown<String>(
      label: label,
      hint: 'Choose',
      value: value,
      items: items
          .map((String item) => DropdownItem<String>(value: item, label: item))
          .toList(),
      onChanged: onChanged,
      errorText: errorText,
      fillColor: AppColors.background,
      borderRadius: BorderRadius.circular(4.sp),
      overlayElevation: 0,
      labelStyle: StyleText.fontSize14Weight400,
      hintStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.lightGrey),
      errorStyle: StyleText.fontSize10Weight400.copyWith(
        color: AppColors.red,
      ),
    );
  }

  Widget _fieldPair(BuildContext context, Widget left, Widget right) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.sp),
      child: buildResponsiveFields(
        context: context,
        left: left,
        right: right,
      ),
    );
  }

  Widget _buildAddAddressButton() {
    return customButtonWithSvg(
      title: S.current.crmAddAddress,
      function: () {},
      textStyle: StyleText.fontSize12Weight500.copyWith(color: AppColors.background),
      color: AppColors.blackButton,
      image: AppAssets.crmPlusBold,
      widthImage: 16.sp,
      heightImage: 16.sp,
      colorBorder: AppColors.transparent,
      svgColor: AppColors.white,
    );
  }

  Widget _buildDuplicationAlertCard() {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: AppColors.orange,
              shape: BoxShape.circle,
            ),
            child: CustomSvgImage(
              assetPath: AppAssets.crmInfo,
              width: 20.sp,
              height: 20.sp,
              color: AppColors.white,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.current.crmDuplicationFound,
                  style: StyleText.fontSize16Weight600.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  S.current.crmDuplicationSubtitle,
                  style: StyleText.fontSize12Weight400.copyWith(color: AppColors.mediumGrey).copyWith(
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          customButton(
            title: S.current.crmViewClient,
            function: onViewClient,
            textStyle: StyleText.fontSize14Weight500.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.bold,
            ),
            color: AppColors.primary,
            borderColor: AppColors.transparent,
            width: 120.w,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            customButton(
              title: S.current.crmDiscard,
              function: onDiscard,
              textStyle: StyleText.fontSize14Weight500.copyWith(
                color: AppColors.black,
              ),
              color: AppColors.lightGrey,
              borderColor: AppColors.transparent,
              width: 100.w,
            ),
            customButton(
              title: S.current.crmNext,
              function: onAdd,
              textStyle: StyleText.fontSize14Weight500.copyWith(
                color: AppColors.grey,
              ),
              color: AppColors.lightGrey,
              borderColor: AppColors.transparent,
              width: 100.w,
            ),
          ],
        ),
        SizedBox(height: 12.h),
        customButton(
          title: S.current.crmSaveForLater,
          function: onSaveForLater,
          textStyle: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.white,
          ),
          color: AppColors.darkGrey,
          borderColor: AppColors.transparent,
          width: 140.w,
        ),
      ],
    );
  }
}
