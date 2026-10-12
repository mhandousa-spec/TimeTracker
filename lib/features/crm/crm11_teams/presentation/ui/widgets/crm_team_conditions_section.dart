// ****************** FILE INFO ******************
// File Name: crm_team_conditions_section.dart
// Purpose: Conditions Details section with 4 condition pairs inside CrmSectionCard.
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/data/models/crm_team_condition_model.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';

class CrmTeamConditionsSection extends StatelessWidget {
  final bool isReadOnly;
  final String selectedCountry;
  final String countryPriority;
  final ValueChanged<String?>? onCountryChanged;
  final ValueChanged<String?>? onCountryPriorityChanged;

  final String selectedLanguage;
  final String languagePriority;
  final ValueChanged<String?>? onLanguageChanged;
  final ValueChanged<String?>? onLanguagePriorityChanged;

  final String selectedIndustry;
  final String industryPriority;
  final ValueChanged<String?>? onIndustryChanged;
  final ValueChanged<String?>? onIndustryPriorityChanged;

  final String selectedSector;
  final String sectorPriority;
  final ValueChanged<String?>? onSectorChanged;
  final ValueChanged<String?>? onSectorPriorityChanged;

  const CrmTeamConditionsSection({
    super.key,
    this.isReadOnly = false,
    required this.selectedCountry,
    required this.countryPriority,
    this.onCountryChanged,
    this.onCountryPriorityChanged,
    required this.selectedLanguage,
    required this.languagePriority,
    this.onLanguageChanged,
    this.onLanguagePriorityChanged,
    required this.selectedIndustry,
    required this.industryPriority,
    this.onIndustryChanged,
    this.onIndustryPriorityChanged,
    required this.selectedSector,
    required this.sectorPriority,
    this.onSectorChanged,
    this.onSectorPriorityChanged,
  });

  static const List<String> countryOptions = <String>[
    'Choose',
    'Egypt',
    'Saudi Arabia',
    'UAE',
    'Kuwait',
    'Qatar',
    'Oman',
    'Bahrain',
  ];

  static const List<String> languageOptions = <String>[
    'Choose',
    'Arabic',
    'English',
    'French',
    'German',
  ];

  static const List<String> industryOptions = <String>[
    'Choose',
    'Technology',
    'Retail',
    'Healthcare',
    'Finance',
    'Education',
    'Real Estate',
  ];

  static const List<String> sectorOptions = <String>[
    'Choose',
    'Private',
    'Public',
    'Semi-Government',
  ];

  static const List<String> priorityOptions = <String>[
    'Choose',
    '1',
    '2',
    '3',
    '4',
  ];

  static const List<String> allPriorityOptions = <String>[
    '1',
    '2',
    '3',
    '4',
  ];

  /// Returns available priority numbers for a specific condition row.
  /// Automatically filters out priority numbers chosen by other rows.
  List<String> getAvailablePriorities(String currentFieldValue) {
    final List<String> used = <String>[
      if (countryPriority != 'Choose' && countryPriority.isNotEmpty) countryPriority,
      if (languagePriority != 'Choose' && languagePriority.isNotEmpty) languagePriority,
      if (industryPriority != 'Choose' && industryPriority.isNotEmpty) industryPriority,
      if (sectorPriority != 'Choose' && sectorPriority.isNotEmpty) sectorPriority,
    ];

    // Exclude current row's value from "used" so it remains valid in this dropdown
    used.remove(currentFieldValue);

    final List<String> available = allPriorityOptions
        .where((String p) => !used.contains(p))
        .toList();

    // Preserve the current value in the list if selected
    if (currentFieldValue.isNotEmpty &&
        currentFieldValue != 'Choose' &&
        !available.contains(currentFieldValue)) {
      available.insert(0, currentFieldValue);
    }

    return <String>['Choose', ...available];
  }

  List<CrmTeamConditionModel> toConditionsList() {
    return <CrmTeamConditionModel>[
      CrmTeamConditionModel(
        category: 'Countries',
        value: selectedCountry,
        priority: countryPriority,
      ),
      CrmTeamConditionModel(
        category: 'Preferred Language',
        value: selectedLanguage,
        priority: languagePriority,
      ),
      CrmTeamConditionModel(
        category: 'Industry',
        value: selectedIndustry,
        priority: industryPriority,
      ),
      CrmTeamConditionModel(
        category: 'Sector',
        value: selectedSector,
        priority: sectorPriority,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return CrmSectionCard(
      title: FormatHelper.localizedString(
        englishName: 'Conditions Details',
        arabicName: 'تفاصيل الشروط',
      ),
      titleWidget: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            FormatHelper.localizedString(
              englishName: 'Conditions Details',
              arabicName: 'تفاصيل الشروط',
            ),
            style: StyleText.fontSize16Weight500.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(width: 8.sp),
          Icon(
            Icons.info,
            size: 16.sp,
            color: AppColors.primary,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Row 1: Countries & Priority
          buildResponsiveFields(
            context: context,
            left: _buildDropdownField(
              titleEn: 'Countries',
              titleAr: 'الدول',
              value: selectedCountry,
              items: countryOptions,
              onChanged: onCountryChanged,
            ),
            right: _buildDropdownField(
              titleEn: 'Priority',
              titleAr: 'الأولوية',
              value: countryPriority,
              items: getAvailablePriorities(countryPriority),
              onChanged: onCountryPriorityChanged,
            ),
          ),
          SizedBox(height: 16.sp),

          // Row 2: Preferred Language & Priority
          buildResponsiveFields(
            context: context,
            left: _buildDropdownField(
              titleEn: 'Preferred Language',
              titleAr: 'اللغة المفضلة',
              value: selectedLanguage,
              items: languageOptions,
              onChanged: onLanguageChanged,
            ),
            right: _buildDropdownField(
              titleEn: 'Priority',
              titleAr: 'الأولوية',
              value: languagePriority,
              items: getAvailablePriorities(languagePriority),
              onChanged: onLanguagePriorityChanged,
            ),
          ),
          SizedBox(height: 16.sp),

          // Row 3: Industry & Priority
          buildResponsiveFields(
            context: context,
            left: _buildDropdownField(
              titleEn: 'Industry',
              titleAr: 'مجال العمل',
              value: selectedIndustry,
              items: industryOptions,
              onChanged: onIndustryChanged,
            ),
            right: _buildDropdownField(
              titleEn: 'Priority',
              titleAr: 'الأولوية',
              value: industryPriority,
              items: getAvailablePriorities(industryPriority),
              onChanged: onIndustryPriorityChanged,
            ),
          ),
          SizedBox(height: 16.sp),

          // Row 4: Sector & Priority
          buildResponsiveFields(
            context: context,
            left: _buildDropdownField(
              titleEn: 'Sector',
              titleAr: 'القطاع',
              value: selectedSector,
              items: sectorOptions,
              onChanged: onSectorChanged,
            ),
            right: _buildDropdownField(
              titleEn: 'Priority',
              titleAr: 'الأولوية',
              value: sectorPriority,
              items: getAvailablePriorities(sectorPriority),
              onChanged: onSectorPriorityChanged,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildDropdownField({
    required String titleEn,
    required String titleAr,
    required String value,
    required List<String> items,
    ValueChanged<String?>? onChanged,
  }) {
    final String label = FormatHelper.localizedString(
      englishName: titleEn,
      arabicName: titleAr,
    );

    return CustomDropdown<String>(
      label: label,
      hint: 'Choose',
      value: items.contains(value) && value != 'Choose' ? value : null,
      items: items
          .where((item) => item != 'Choose')
          .map((item) => DropdownItem<String>(value: item, label: item))
          .toList(),
      enabled: !isReadOnly,
      onChanged: isReadOnly ? null : (String? val) => onChanged?.call(val ?? 'Choose'),
    );
  }
}

