// ****************** FILE INFO ******************
// File Name: crm_client_overview_tab.dart
// Purpose: Overview tab content for the CRM client profile showing details metadata,
//          edit trigger button, and form sections in read-only mode with bilingual field pairs.
// Author: Mohand Adel
// Created At: 26/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_record_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_client_overview_details_card.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_client_type_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_field_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_section_model.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';

class CrmClientOverviewTab extends StatelessWidget {
  final CrmClientRecordModel record;
  final CrmTemplateModel? template;
  final CrmClientTypeModel? clientType;
  final List<CrmTemplateFieldModel> fields;
  final List<CrmTemplateSectionModel> sections;

  const CrmClientOverviewTab({
    super.key,
    required this.record,
    this.template,
    this.clientType,
    this.fields = const [],
    this.sections = const [],
  });

  void _onEditPressed(BuildContext context) {
    CrmNavigationHelper.navigateToAddClient(
      context,
      templateName: FormatHelper.localizedString(
        englishName: 'Edit Client',
        arabicName: 'تعديل العميل',
      ),
      clientType: clientType?.nameEn,
      clientTypeId: record.clientTypeId,
      templateId:
          record.templateId.isNotEmpty ? record.templateId : template?.id,
      editingRecord: record,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Details Metadata Card (Template Name, Adding Date, By, Last Update)
        CrmClientOverviewDetailsCard(
          record: record,
          template: template,
        ),
        SizedBox(height: 12.sp),

        // 2. Edit Action Button Row (aligned to trailing end)
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            customButtonWithSvg(
              title: FormatHelper.localizedString(
                englishName: 'Edit',
                arabicName: 'تعديل',
              ),
              function: () => _onEditPressed(context),
              textStyle: StyleText.fontSize14Weight600.copyWith(
                color: AppColors.black,
                fontSize: 13.sp,
              ),
              color: AppColors.primary,
              colorBorder: AppColors.transparent,
              image: AppAssets.edit,
              widthImage: 16.sp,
              heightImage: 16.sp,
              svgColor: AppColors.black,
            ),
          ],
        ),
        SizedBox(height: 14.sp),

        // 3. Dynamic Form Sections & Fields
        if (sections.isNotEmpty && fields.isNotEmpty)
          ..._buildDynamicSections(context)
        else
          ..._buildDefaultSections(context),
      ],
    );
  }

  List<Widget> _buildDynamicSections(BuildContext context) {
    final List<CrmTemplateSectionModel> orderedSections =
        List<CrmTemplateSectionModel>.from(sections)
          ..sort((a, b) => a.order.compareTo(b.order));

    return orderedSections.map((section) {
      final List<CrmTemplateFieldModel> sectionFields = fields
          .where((f) => f.sectionId == section.id && !f.isDeleted)
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));

      return Padding(
        padding: EdgeInsets.only(bottom: 16.sp),
        child: CrmSectionCard(
          title: FormatHelper.localizedString(
            englishName: section.nameEn,
            arabicName: section.nameAr,
          ),
          child: _buildFieldsGrid(context, sectionFields),
        ),
      );
    }).toList();
  }

  Widget _buildFieldsGrid(
    BuildContext context,
    List<CrmTemplateFieldModel> sectionFields,
  ) {
    final List<CrmTemplateFieldModel> ordered =
        List<CrmTemplateFieldModel>.from(sectionFields)
          ..sort((a, b) => a.order.compareTo(b.order));

    final List<Widget> rows = <Widget>[];

    for (int index = 0; index < ordered.length; index++) {
      final CrmTemplateFieldModel currentField = ordered[index];

      // 1. Bilingual pair (showBothLanguages active) -> full responsive row (EN left, AR right)
      if (_isBothLanguageField(currentField)) {
        rows.add(
          Padding(
            padding: EdgeInsets.only(bottom: 14.sp),
            child: _buildBilingualPairField(context, currentField),
          ),
        );
        continue;
      }

      // 2. Non-bilingual field -> pair with next non-bilingual field
      final CrmTemplateFieldModel? nextField =
          (index + 1 < ordered.length) ? ordered[index + 1] : null;
      final bool canPairWithNext =
          nextField != null && !_isBothLanguageField(nextField);

      final Widget left = _buildSingleFieldWidget(context, currentField);
      final Widget right = canPairWithNext
          ? _buildSingleFieldWidget(context, nextField)
          : const SizedBox.shrink();

      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: 14.sp),
          child: buildResponsiveFields(
            context: context,
            left: left,
            right: right,
            mobileSpacing: 12.sp,
          ),
        ),
      );

      if (canPairWithNext) index++;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }

  Widget _buildBilingualPairField(
    BuildContext context,
    CrmTemplateFieldModel field,
  ) {
    final dynamic val = record.valueFor(field.id, field.systemKey);
    final Map<String, String> langValues = _readLanguageValues(val);
    final String enVal = langValues['en'] ?? '';
    final String arVal = langValues['ar'] ?? '';

    final bool isMultiline = field.fieldTypeId.toLowerCase() == 'description';

    final Widget leftField = CustomTextField(
      label: field.nameEn.isNotEmpty ? field.nameEn : field.nameAr,
      initialValue: enVal.isNotEmpty ? enVal : null,
      hint: enVal.isNotEmpty ? enVal : 'Text Here',
      readOnly: true,
      maxLines: isMultiline ? 4 : 1,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );

    final Widget rightField = Directionality(
      textDirection: TextDirection.rtl,
      child: CustomTextField(
        label: field.nameAr.isNotEmpty ? field.nameAr : field.nameEn,
        initialValue: arVal.isNotEmpty ? arVal : null,
        hint: arVal.isNotEmpty ? arVal : 'اكتب هنا',
        readOnly: true,
        maxLines: isMultiline ? 4 : 1,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
      ),
    );

    return buildResponsiveFields(
      context: context,
      left: leftField,
      right: rightField,
      mobileSpacing: 12.sp,
    );
  }

  Widget _buildSingleFieldWidget(
    BuildContext context,
    CrmTemplateFieldModel field,
  ) {
    final dynamic val = record.valueFor(field.id, field.systemKey);
    final String type = field.fieldTypeId.toLowerCase();

    // If single field value is a map/bilingual string, resolve localized string cleanly
    final Map<String, String> langValues = _readLanguageValues(val);
    final String strVal;
    if (val is Map ||
        (val != null &&
            val.toString().trim().startsWith('{') &&
            val.toString().trim().endsWith('}'))) {
      strVal = FormatHelper.localizedString(
        englishName: langValues['en'] ?? '',
        arabicName: langValues['ar'] ?? '',
      );
    } else {
      strVal = val != null ? val.toString() : '';
    }

    Widget? suffix;
    if (type.contains('drop') ||
        type.contains('select') ||
        type == 'industry' ||
        type == 'sector' ||
        type == 'size' ||
        type == 'tag') {
      suffix = CustomSvgImage(
        assetPath: AppAssets.dropDownIcon,
        width: 12.sp,
        height: 12.sp,
        color: AppColors.darkGrey,
      );
    } else if (type.contains('date') || type.contains('time')) {
      suffix = CustomSvgImage(
        assetPath: AppAssets.calendar,
        width: 14.sp,
        height: 14.sp,
        color: AppColors.primary,
      );
    }

    final bool isArabicField = field.nameAr.isNotEmpty &&
        (field.nameEn.isEmpty || field.systemKey.toLowerCase().contains('_ar'));

    final Widget textField = CustomTextField(
      label: FormatHelper.localizedString(
        englishName: field.nameEn.isNotEmpty ? field.nameEn : field.nameAr,
        arabicName: field.nameAr.isNotEmpty ? field.nameAr : field.nameEn,
      ),
      initialValue: strVal.isNotEmpty ? strVal : null,
      hint: strVal.isNotEmpty
          ? strVal
          : (isArabicField ? 'اكتب هنا' : 'Text Here'),
      readOnly: true,
      suffixIcon: suffix,
      textAlign: isArabicField ? TextAlign.right : TextAlign.left,
      textDirection: isArabicField ? TextDirection.rtl : null,
    );

    if (isArabicField) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: textField,
      );
    }

    return textField;
  }

  bool _isBothLanguageField(CrmTemplateFieldModel field) {
    if (!field.showBothLanguages) return false;
    final String type = field.fieldTypeId.toLowerCase();
    final String validationType = field.validationType.toLowerCase();
    if (type == 'address' ||
        type == 'email' ||
        type == 'phone' ||
        type == 'link' ||
        type == 'website' ||
        type == 'purchasing_value' ||
        type == 'number' ||
        type == 'dropdown' ||
        type == 'select' ||
        type == 'multiselect' ||
        type == 'date' ||
        type == 'time' ||
        type == 'checkbox' ||
        type == 'switch' ||
        validationType == 'email' ||
        validationType == 'phone' ||
        validationType == 'url' ||
        validationType == 'number') {
      return false;
    }
    return true;
  }

  Map<String, String> _readLanguageValues(dynamic value) {
    if (value == null) return <String, String>{'en': '', 'ar': ''};
    if (value is Map) {
      return <String, String>{
        'en': (value['en'] ??
                value['EN'] ??
                value['Name_En'] ??
                value['nameEn'] ??
                '')
            .toString(),
        'ar': (value['ar'] ??
                value['AR'] ??
                value['Name_Ar'] ??
                value['nameAr'] ??
                '')
            .toString(),
      };
    }
    final String text = value.toString().trim();
    if (text.startsWith('{') && text.endsWith('}')) {
      String en = '';
      String ar = '';
      final RegExp enReg = RegExp(r'en:\s*([^,}]+)');
      final RegExp arReg = RegExp(r'ar:\s*([^,}]+)');
      final matchEn = enReg.firstMatch(text);
      if (matchEn != null) en = matchEn.group(1)?.trim() ?? '';
      final matchAr = arReg.firstMatch(text);
      if (matchAr != null) ar = matchAr.group(1)?.trim() ?? '';
      if (en.isNotEmpty || ar.isNotEmpty) {
        return <String, String>{'en': en, 'ar': ar};
      }
    }
    return <String, String>{'en': text, 'ar': ''};
  }

  List<Widget> _buildDefaultSections(BuildContext context) {
    final Map<String, String> companyNameValues = _readLanguageValues(
      record.valueFor(null, 'company_name') ??
          record.valueFor(null, 'first_name'),
    );

    return [
      // 1. Client Details Section Card
      CrmSectionCard(
        title: FormatHelper.localizedString(
          englishName: 'Client Details',
          arabicName: 'تفاصيل العميل',
        ),
        child: Column(
          children: [
            // Row 1: Company Name (English / Arabic)
            buildResponsiveFields(
              context: context,
              left: CustomTextField(
                label: 'Company name',
                initialValue: companyNameValues['en']!.isNotEmpty
                    ? companyNameValues['en']
                    : (record.valueFor(null, 'company_name')?.toString()),
                hint: 'Text Here',
                readOnly: true,
              ),
              right: Directionality(
                textDirection: TextDirection.rtl,
                child: CustomTextField(
                  label: 'اسم الشركة',
                  initialValue: companyNameValues['ar']!.isNotEmpty
                      ? companyNameValues['ar']
                      : (record.valueFor(null, 'company_name_ar')?.toString()),
                  hint: 'اكتب هنا',
                  readOnly: true,
                  textAlign: TextAlign.right,
                ),
              ),
            ),
            SizedBox(height: 14.sp),

            // Row 2: Commercial Registration No. / Tax No.
            buildResponsiveFields(
              context: context,
              left: CustomTextField(
                label: 'Commercial Registration No. (CR No.)',
                initialValue: (record.valueFor(null, 'cr_number') ??
                        record.valueFor(null, 'cr_no'))
                    ?.toString(),
                hint: 'Text Here',
                readOnly: true,
              ),
              right: CustomTextField(
                label: 'Tax No. (Tax Number )',
                initialValue: (record.valueFor(null, 'tax_number') ??
                        record.valueFor(null, 'tax_no'))
                    ?.toString(),
                hint: 'Text Here',
                readOnly: true,
              ),
            ),
            SizedBox(height: 14.sp),

            // Row 3: Industry / Size
            buildResponsiveFields(
              context: context,
              left: CustomTextField(
                label: 'Industry',
                initialValue: (record.valueFor(null, 'industry') ??
                        record.valueFor(null, 'sector'))
                    ?.toString(),
                hint: 'Choose',
                readOnly: true,
                suffixIcon: CustomSvgImage(
                  assetPath: AppAssets.dropDownIcon,
                  width: 12.sp,
                  height: 12.sp,
                  color: AppColors.darkGrey,
                ),
              ),
              right: CustomTextField(
                label: 'Size',
                initialValue: (record.valueFor(null, 'company_size') ??
                        record.valueFor(null, 'size'))
                    ?.toString(),
                hint: 'Choose',
                readOnly: true,
                suffixIcon: CustomSvgImage(
                  assetPath: AppAssets.dropDownIcon,
                  width: 12.sp,
                  height: 12.sp,
                  color: AppColors.darkGrey,
                ),
              ),
            ),
            SizedBox(height: 14.sp),

            // Row 4: Website / Business Initiation Date
            buildResponsiveFields(
              context: context,
              left: CustomTextField(
                label: 'Website',
                initialValue: record.valueFor(null, 'website')?.toString(),
                hint: 'Text Here',
                readOnly: true,
              ),
              right: CustomTextField(
                label: 'Business Initiation Date',
                initialValue:
                    (record.valueFor(null, 'business_initiation_date') ??
                            record.valueFor(null, 'initiation_date'))
                        ?.toString(),
                hint: 'Select Date',
                readOnly: true,
                suffixIcon: CustomSvgImage(
                  assetPath: AppAssets.calendar,
                  width: 14.sp,
                  height: 14.sp,
                  color: AppColors.primary,
                ),
              ),
            ),
            SizedBox(height: 14.sp),

            // Row 5: Tags / Purchasing Value
            buildResponsiveFields(
              context: context,
              left: CustomTextField(
                label: 'Tags',
                initialValue: record.valueFor(null, 'tag')?.toString(),
                hint: 'Choose',
                readOnly: true,
                suffixIcon: CustomSvgImage(
                  assetPath: AppAssets.dropDownIcon,
                  width: 12.sp,
                  height: 12.sp,
                  color: AppColors.darkGrey,
                ),
              ),
              right: CustomTextField(
                label: 'Purchasing Value',
                initialValue: (record.valueFor(null, 'purchasing_value') ??
                        record.valueFor(null, 'purchase_value'))
                    ?.toString(),
                hint: 'Text Here',
                readOnly: true,
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: 16.sp),

      // 2. Address Section Card
      CrmSectionCard(
        title: FormatHelper.localizedString(
          englishName: 'Address',
          arabicName: 'العنوان',
        ),
        child: Column(
          children: [
            // Row 1: Country / City
            buildResponsiveFields(
              context: context,
              left: CustomTextField(
                label: 'Country',
                initialValue: record.valueFor(null, 'country')?.toString(),
                hint: 'Choose',
                readOnly: true,
                suffixIcon: CustomSvgImage(
                  assetPath: AppAssets.dropDownIcon,
                  width: 12.sp,
                  height: 12.sp,
                  color: AppColors.darkGrey,
                ),
              ),
              right: CustomTextField(
                label: 'City',
                initialValue: record.valueFor(null, 'city')?.toString(),
                hint: 'Choose',
                readOnly: true,
                suffixIcon: CustomSvgImage(
                  assetPath: AppAssets.dropDownIcon,
                  width: 12.sp,
                  height: 12.sp,
                  color: AppColors.darkGrey,
                ),
              ),
            ),
            SizedBox(height: 14.sp),

            // Row 2: Province / Street
            buildResponsiveFields(
              context: context,
              left: CustomTextField(
                label: 'Province',
                initialValue: record.valueFor(null, 'province')?.toString(),
                hint: 'Text Here',
                readOnly: true,
              ),
              right: CustomTextField(
                label: 'Street',
                initialValue: record.valueFor(null, 'street')?.toString(),
                hint: 'Text Here',
                readOnly: true,
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: 32.sp),
    ];
  }
}
