// ****************** FILE INFO ******************
// File Name: crm_dynamic_address_field.dart
// Purpose: Runtime address field rendering driven by CRM template config
// Author: Mohand Adel
// Created At: 08/08/2026

import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/helper/main_helper/cities.dart';
import 'package:knowticed_plus/core/helper/main_helper/countries.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_field_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CrmDynamicAddressField extends StatelessWidget {
  const CrmDynamicAddressField({
    required this.field,
    required this.value,
    required this.error,
    required this.formValues,
    required this.allFields,
    required this.onChanged,
    super.key,
  });

  final CrmTemplateFieldModel field;
  final dynamic value;
  final String? error;
  final Map<String, dynamic> formValues;
  final List<CrmTemplateFieldModel> allFields;
  final ValueChanged<dynamic> onChanged;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> config = Map<String, dynamic>.from(
      field.configuration,
    );
    final String entryType = _configString(
      config,
      CrmFirestoreKeys.ENTRY_TYPE_KEY,
      fallback: 'Text Field',
    );
    if (entryType != 'Dropdown') {
      return CustomTextField(
        controller: TextEditingController(text: value?.toString() ?? ''),
        label: _fieldLabel(field),
        hint: _textHint(),
        height: 36.sp,
        errorText: error,
        required: field.isRequired,
        onChanged: onChanged,
        fillColor: AppColors.background,
        borderRadius: BorderRadius.circular(4.sp),
        labelStyle: StyleText.fontSize14Weight400,
        hintStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.lightGrey),
        errorStyle: StyleText.fontSize10Weight400.copyWith(
          color: AppColors.red,
        ),
      );
    }

    final List<DropdownItem<String>> items = _resolveOptions(config)
        .map(
          (String option) => DropdownItem<String>(value: option, label: option),
        )
        .toList();

    return CustomDropdown<String>(
      label: _fieldLabel(field),
      hint: _chooseHint(),
      value: value?.toString().isEmpty == true ? null : value?.toString(),
      items: items,
      required: field.isRequired,
      errorText: error,
      onChanged: (String? selected) => onChanged(selected),
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

  List<String> _resolveOptions(Map<String, dynamic> config) {
    final String component = _configString(
      config,
      CrmFirestoreKeys.ADDRESS_COMPONENT_KEY,
    );
    if (component == 'Country') {
      final List<String> selectedCountries = _configList(
        config,
        CrmFirestoreKeys.COUNTRIES_KEY,
      );
      if (selectedCountries.isNotEmpty) return selectedCountries;
      return countries
          .map((Country country) => country.name)
          .where((String name) => name.isNotEmpty)
          .toList();
    }

    final List<String> allowedCountries = _configList(
      config,
      CrmFirestoreKeys.COUNTRIES_KEY,
    );
    final String? selectedCountry = _selectedCountryValue();

    final List<String> sectionAllowedCountries = allowedCountries.isNotEmpty
        ? allowedCountries
        : _sectionAllowedCountries();

    final List<String> activeCountries =
        (selectedCountry != null && selectedCountry.isNotEmpty)
            ? <String>[selectedCountry]
            : sectionAllowedCountries;

    final List<String> configuredCities = <String>{
      ..._configList(config, CrmFirestoreKeys.CITIES_KEY),
      ...field.options,
      ..._configOptions(config),
    }.toList();

    // Case 1: Template explicitly defined allowed cities in Controls
    if (configuredCities.isNotEmpty) {
      if (activeCountries.isNotEmpty) {
        final List<String> matching = configuredCities.where((String city) {
          for (final String country in activeCountries) {
            final List<String> countryAllCities = _getCitiesForCountry(country);
            if (_containsNormalized(countryAllCities, city)) return true;
          }
          return false;
        }).toList();
        if (matching.isNotEmpty) return matching;
      }
      return configuredCities;
    }

    // Case 2: Country is selected in form or template, return cities for active country/countries ONLY
    if (activeCountries.isNotEmpty) {
      final List<String> citiesForActiveCountries = activeCountries
          .expand((String c) => _getCitiesForCountry(c))
          .toSet()
          .toList();
      return citiesForActiveCountries;
    }

    return const <String>[];
  }

  List<String> _sectionAllowedCountries() {
    for (final CrmTemplateFieldModel candidate in allFields) {
      if (candidate.sectionId != field.sectionId) continue;
      if (candidate.fieldTypeId.toLowerCase() != 'address') continue;
      final String component = _configString(
        candidate.configuration,
        CrmFirestoreKeys.ADDRESS_COMPONENT_KEY,
      );
      if (component.toLowerCase().contains('country')) {
        final List<String> countries = _configList(
          candidate.configuration,
          CrmFirestoreKeys.COUNTRIES_KEY,
        );
        if (countries.isNotEmpty) return countries;
      }
    }
    return const <String>[];
  }

  List<String> _getCitiesForCountry(String countryName) {
    final String target = countryName.trim().toLowerCase();
    for (final MapEntry<String, List<String>> entry in countryCities.entries) {
      if (entry.key.trim().toLowerCase() == target) {
        return entry.value;
      }
    }
    return const <String>[];
  }

  String? _selectedCountryValue() {
    for (final CrmTemplateFieldModel candidate in allFields) {
      if (candidate.sectionId != field.sectionId) continue;
      if (candidate.fieldTypeId.toLowerCase() != 'address') continue;
      final String component = _configString(
        candidate.configuration,
        CrmFirestoreKeys.ADDRESS_COMPONENT_KEY,
      );
      if (component != 'Country') continue;
      final dynamic selected = formValues[candidate.id];
      final String text = selected?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    return null;
  }
}

String _fieldLabel(CrmTemplateFieldModel field) {
  return FormatHelper.localizedString(
    englishName: field.nameEn,
    arabicName: field.nameAr,
  );
}

String _textHint() {
  return Get.locale.toString().contains('en')
      ? S.current.crmTextHere
      : S.current.crmWriteHere;
}

String _chooseHint() {
  return Get.locale.toString().contains('en')
      ? S.current.crmChoose
      : S.current.crmSelect;
}

String _configString(
  Map<String, dynamic> config,
  String key, {
  String fallback = '',
}) {
  return (config[key] ?? fallback).toString().trim();
}

List<String> _configList(Map<String, dynamic> config, String key) {
  final dynamic stored = config[key];
  if (stored is List) {
    return stored
        .map((dynamic value) => value.toString().trim())
        .where((String value) => value.isNotEmpty)
        .toList();
  }
  if (stored is String && stored.trim().isNotEmpty) {
    return stored
        .split(',')
        .map((String value) => value.trim())
        .where((String value) => value.isNotEmpty)
        .toList();
  }
  return const <String>[];
}

List<String> _configOptions(Map<String, dynamic> config) {
  final dynamic stored = config[CrmFirestoreKeys.DEFAULT_OPTIONS_KEY];
  if (stored is! List) return const <String>[];
  return stored
      .map((dynamic option) {
        if (option is Map<String, dynamic>) {
          return (option[CrmFirestoreKeys.OPTION_LABEL_EN_KEY] ?? '')
              .toString()
              .trim();
        }
        if (option is Map) {
          return (option[CrmFirestoreKeys.OPTION_LABEL_EN_KEY] ?? '')
              .toString()
              .trim();
        }
        return option.toString().trim();
      })
      .where((String value) => value.isNotEmpty)
      .toList();
}

bool _containsNormalized(List<String> values, String? candidate) {
  final String normalizedCandidate = candidate?.trim().toLowerCase() ?? '';
  if (normalizedCandidate.isEmpty) return false;
  return values.any(
    (String value) => value.trim().toLowerCase() == normalizedCandidate,
  );
}
