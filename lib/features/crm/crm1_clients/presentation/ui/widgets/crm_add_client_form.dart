// ****************** FILE INFO ******************
// File Name: crm_add_client_form.dart
// Purpose: Responsive CRM add-client form matching the approved Figma design
// Author: Mohand Adel
// Created At: 02/08/2026

import 'dart:io';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/31-custom_multi_select_dropdown.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';
import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/generated/l10n.dart';

class CrmAddClientControllers {
  // Person fields
  final TextEditingController firstName = TextEditingController();
  final TextEditingController arabicFirstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController arabicLastName = TextEditingController();
  final TextEditingController nationalId = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController email = TextEditingController();

  // Company fields
  final TextEditingController companyName = TextEditingController();
  final TextEditingController arabicCompanyName = TextEditingController();
  final TextEditingController crNumber = TextEditingController();
  final TextEditingController taxNumber = TextEditingController();

  // Government fields
  final TextEditingController entityName = TextEditingController();
  final TextEditingController arabicEntityName = TextEditingController();

  // Shared fields
  final TextEditingController website = TextEditingController();
  final TextEditingController businessInitiationDate = TextEditingController();
  final TextEditingController province = TextEditingController();
  final TextEditingController street = TextEditingController();

  void dispose() {
    firstName.dispose();
    arabicFirstName.dispose();
    lastName.dispose();
    arabicLastName.dispose();
    nationalId.dispose();
    phone.dispose();
    email.dispose();
    companyName.dispose();
    arabicCompanyName.dispose();
    crNumber.dispose();
    taxNumber.dispose();
    entityName.dispose();
    arabicEntityName.dispose();
    website.dispose();
    businessInitiationDate.dispose();
    province.dispose();
    street.dispose();
  }
}

class CrmAddClientForm extends StatelessWidget {
  final CrmAddClientControllers controllers;
  final String? preferredLanguage;
  final String? contactChannel;
  final String? country;
  final String? city;
  final List<String> tags;
  final File? clientImage;
  final bool showClientDetails;
  final bool showAddress;
  final ValueChanged<String> onPreferredLanguageChanged;
  final ValueChanged<String> onContactChannelChanged;
  final ValueChanged<String> onCountryChanged;
  final ValueChanged<String> onCityChanged;
  final ValueChanged<List<String>> onTagsChanged;
  final ValueChanged<File> onClientImagePicked;
  final VoidCallback onBusinessDateTap;
  final VoidCallback onToggleClientDetails;
  final VoidCallback onToggleAddress;
  final VoidCallback onDiscard;
  final VoidCallback onAdd;
  final VoidCallback onSaveForLater;
  final VoidCallback onViewClient;

  const CrmAddClientForm({
    super.key,
    required this.controllers,
    required this.preferredLanguage,
    required this.contactChannel,
    required this.country,
    required this.city,
    required this.tags,
    required this.clientImage,
    required this.showClientDetails,
    required this.showAddress,
    required this.onPreferredLanguageChanged,
    required this.onContactChannelChanged,
    required this.onCountryChanged,
    required this.onCityChanged,
    required this.onTagsChanged,
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
        _SectionHeader(
          title: S.current.crmClientDetails,
          isExpanded: showClientDetails,
          onTap: onToggleClientDetails,
        ),
        if (showClientDetails)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.sp),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8.sp),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatarPicker(),
                SizedBox(height: 16.sp),
                _buildClientFields(context),
              ],
            ),
          ),
        SizedBox(height: 8.sp),
        _SectionHeader(
          title: S.current.crmAddress,
          isExpanded: showAddress,
          onTap: onToggleAddress,
        ),
        if (showAddress) _buildAddressCard(context),
        SizedBox(height: 8.sp),
        customButtonWithSvg(
          title: S.current.crmAddAddress,
          function: () {},
          textStyle: StyleText.fontSize12Weight500.copyWith(color: AppColors.background),
          color: AppColors.blackButton,
          image: AppAssets.crmPlusBold,
          widthImage: 16.sp,
          heightImage: 16.sp,
          colorBorder: AppColors.transparent,
          svgColor: AppColors.white,
        ),
        SizedBox(height: 12.sp),
        _DuplicateClientNotice(onViewClient: onViewClient),
        SizedBox(height: 12.sp),
        _buildPrimaryActions(),
        SizedBox(height: 20.sp),
        customButton(
          title: S.current.crmSaveForLater,
          function: onSaveForLater,
          color: AppColors.darkGrey,
          textStyle: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarPicker() {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: CustomImagePicker(
        imageFile: clientImage,
        onImagePicked: onClientImagePicked,
        radius: 28.sp,
        badgeRadius: 12.sp,
        placeholderSvg: AppAssets.defaultIcon,
        badgeSvg: AppAssets.camera,
      ),
    );
  }

  Widget _buildClientFields(BuildContext context) {
    return Column(
      children: [
        _fieldPair(
          context,
          _requiredField(
            controller: controllers.firstName,
            label: 'Client First Name',
            hint: 'Text Here',
          ),
          _requiredField(
            controller: controllers.arabicFirstName,
            label: 'الاسم للعميل الأول',
            hint: 'اكتب هنا',
            isArabic: true,
          ),
        ),
        _fieldPair(
          context,
          _requiredField(
            controller: controllers.lastName,
            label: 'Client Last Name',
            hint: 'Text Here',
          ),
          _requiredField(
            controller: controllers.arabicLastName,
            label: 'اسم العميل الأخير',
            hint: 'اكتب هنا',
            isArabic: true,
          ),
        ),
        _fieldPair(
          context,
          _requiredField(
            controller: controllers.nationalId,
            label: 'National ID',
            hint: 'Text Here',
            onlyDigits: true,
          ),
          _dropdown(
            label: 'Preferred Language',
            value: preferredLanguage,
            items: const ['English', 'Arabic'],
            onChanged: onPreferredLanguageChanged,
          ),
        ),
        _fieldPair(
          context,
          _requiredField(
            controller: controllers.phone,
            label: 'Phone',
            hint: 'Text Here',
            onlyDigits: true,
            prefixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🇪🇬', style: StyleText.fontSize16Weight400),
                SizedBox(width: 4.sp),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16.sp,
                  color: AppColors.text,
                ),
              ],
            ),
          ),
          _requiredField(
            controller: controllers.email,
            label: 'Email',
            hint: 'Text Here',
            keyboardType: TextInputType.emailAddress,
          ),
        ),
        _fieldPair(
          context,
          _dropdown(
            label: 'Preferred Contact Channel',
            value: contactChannel,
            items: const ['Phone', 'Email', 'WhatsApp'],
            onChanged: onContactChannelChanged,
          ),
          _requiredField(
            controller: controllers.businessInitiationDate,
            label: 'Business Initiation Date',
            hint: 'Select Date',
            readOnly: true,
            onTap: onBusinessDateTap,
            suffixIcon: CustomSvgImage(
              assetPath: AppAssets.calendar,
              width: 16.sp,
              height: 16.sp,
              color: AppColors.text,
            ),
          ),
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: FractionallySizedBox(
            widthFactor: MediaQuery.sizeOf(context).width < 600 ? 1 : 0.5,
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                end: MediaQuery.sizeOf(context).width < 600 ? 0 : 7.5.sp,
              ),
              child: CustomMultiSelectDropdown<String>(
                label: 'Tags',
                hint: 'Choose',
                values: tags,
                items: const [
                  MultiSelectDropdownItem(value: 'VIP', label: 'VIP'),
                  MultiSelectDropdownItem(value: 'Prospect', label: 'Prospect'),
                  MultiSelectDropdownItem(value: 'Priority', label: 'Priority'),
                ],
                onChanged: onTagsChanged,
                fillColor: AppColors.background,
                borderRadius: BorderRadius.circular(4.sp),
                overlayElevation: 0,
                labelStyle: StyleText.fontSize14Weight400,
                hintStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.lightGrey),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.sp),
      ),
      child: Column(
        children: [
          _fieldPair(
            context,
            _dropdown(
              label: 'Country',
              value: country,
              items: const ['Egypt', 'Saudi Arabia', 'United Arab Emirates'],
              onChanged: onCountryChanged,
              errorText: 'Field Required',
            ),
            _dropdown(
              label: 'City',
              value: city,
              items: const ['Cairo', 'Giza', 'Alexandria'],
              onChanged: onCityChanged,
            ),
          ),
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
    bool onlyDigits = false,
    bool readOnly = false,
    TextInputType? keyboardType,
    Widget? prefixIcon,
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
      onlyDigits: onlyDigits,
      readOnly: readOnly,
      keyboardType: keyboardType,
      prefixIcon: prefixIcon,
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
      hint: 'Select',
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
        mobileSpacing: 12.sp,
      ),
    );
  }

  Widget _buildPrimaryActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        customButton(
          title: S.current.crmDiscard,
          function: onDiscard,
          color: AppColors.lightGrey,
          textStyle: StyleText.fontSize16Weight600,
        ),
        customButton(
          title: S.current.crmAdd,
          function: onAdd,
          color: AppColors.lightGrey,
          textStyle: StyleText.fontSize16Weight600.copyWith(
            color: AppColors.darkGrey,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isExpanded;
  final VoidCallback onTap;

  const _SectionHeader({
    required this.title,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
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
      ),
    );
  }
}

class _DuplicateClientNotice extends StatelessWidget {
  final VoidCallback onViewClient;

  const _DuplicateClientNotice({required this.onViewClient});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.sp),
      ),
      child: Row(
        children: [
          CustomSvgImage(
            assetPath: AppAssets.crmInfo,
            width: 40.sp,
            height: 40.sp,
          ),
          SizedBox(width: 12.sp),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.current.crmDuplicationFound,
                  style: StyleText.fontSize20Weight600,
                ),
                Text(
                  S.current.crmDuplicationSubtitle,
                  style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.sp),
          customButton(
            title: S.current.crmViewClient,
            function: onViewClient,
            color: AppColors.primary,
            textStyle: StyleText.fontSize16Weight600,
          ),
        ],
      ),
    );
  }
}
