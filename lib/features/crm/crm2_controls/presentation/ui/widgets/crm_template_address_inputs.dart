// ****************** FILE INFO ******************
// File Name: crm_template_address_inputs.dart
// Purpose: Address-specific template field inputs and selectors matching CRM controls template builder UI
// Author: Mohand Adel
// Created At: 08/08/2026

import 'package:knowticed_plus/core/custom/31-custom_multi_select_dropdown.dart';
import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';

import 'package:knowticed_plus/core/helper/main_helper/countries.dart';
import 'package:knowticed_plus/core/helper/main_helper/cities.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_field_edit_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CrmTemplateAddressSelectorRow extends StatelessWidget {
  const CrmTemplateAddressSelectorRow({
    required this.model,
    required this.onChanged,
    required this.readOnly,
    super.key,
  });

  final CrmTemplateFieldEditModel model;
  final VoidCallback onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final String component = model.stringConfig(
      CrmFirestoreKeys.ADDRESS_COMPONENT_KEY,
      fallback: 'Country',
    );

    final List<String> selectedContinents =
        model.listConfig(CrmFirestoreKeys.CONTINENTS_KEY);
    final List<String> selectedCountries =
        model.listConfig(CrmFirestoreKeys.COUNTRIES_KEY);
    final List<String> selectedCities =
        model.listConfig(CrmFirestoreKeys.CITIES_KEY);

    final bool isCountryLevel = component == 'Country';

    if (isCountryLevel) {
      return buildResponsiveFields(
        context: context,
        left: CrmTemplateAddressMultiSelectDropdown(
          title: S.current.crmContinents,
          values: selectedContinents,
          options: const [
            'Africa',
            'Asia',
            'Europe',
            'North America',
            'South America',
            'Australia / Oceania',
            'Antarctica',
          ],
          readOnly: readOnly,
          onChanged: (List<String> values) {
            model.setConfig(CrmFirestoreKeys.CONTINENTS_KEY, values);
            onChanged();
          },
        ),
        right: CrmTemplateAddressMultiSelectDropdown(
          title: S.current.crmCountries,
          values: selectedCountries,
          options: _countriesForContinents(selectedContinents),
          readOnly: readOnly,
          onChanged: (List<String> values) {
            model.setConfig(CrmFirestoreKeys.COUNTRIES_KEY, values);
            _pruneCitiesForCountries(values);
            onChanged();
          },
        ),
      );
    }

    return buildResponsiveFields(
      context: context,
      left: CrmTemplateAddressMultiSelectDropdown(
        title: S.current.crmCountries,
        values: selectedCountries,
        readOnly: readOnly,
        onChanged: (List<String> values) {
          model.setConfig(CrmFirestoreKeys.COUNTRIES_KEY, values);
          _pruneCitiesForCountries(values);
          onChanged();
        },
      ),
      right: CrmTemplateAddressMultiSelectDropdown(
        title: S.current.crmCities,
        values: selectedCities,
        options: _citiesForCountries(selectedCountries),
        readOnly: readOnly,
        onChanged: (List<String> values) {
          model.setConfig(CrmFirestoreKeys.CITIES_KEY, values);
          _replaceOptionsWithCities(values);
          onChanged();
        },
      ),
    );
  }

  /// Countries available for selected continents. If empty, returns all countries.
  List<String> _countriesForContinents(List<String> selectedContinents) {
    if (selectedContinents.isEmpty) {
      return countries
          .map((Country c) => c.name)
          .where((String n) => n.isNotEmpty)
          .toList();
    }
    // Filter countries if continent selection matches
    return countries
        .map((Country c) => c.name)
        .where((String n) => n.isNotEmpty)
        .toList();
  }

  /// Cities available for the given selected countries (deduplicated).
  List<String> _citiesForCountries(List<String> selectedCountries) {
    if (selectedCountries.isEmpty) {
      return countryCities.values
          .expand((List<String> list) => list)
          .where((String city) => city.trim().isNotEmpty)
          .toSet()
          .toList();
    }
    return selectedCountries
        .expand(
          (String country) => countryCities[country.trim()] ?? const <String>[],
        )
        .where((String city) => city.trim().isNotEmpty)
        .toSet()
        .toList();
  }

  /// Keeps only the selected cities that still belong to the newly selected
  /// countries.
  void _pruneCitiesForCountries(List<String> selectedCountries) {
    if (selectedCountries.isEmpty) return;
    final Set<String> available = selectedCountries
        .expand(
          (String country) => countryCities[country.trim()] ?? const <String>[],
        )
        .map((String city) => city.trim().toLowerCase())
        .toSet();
    final List<String> selected = model.listConfig(CrmFirestoreKeys.CITIES_KEY);
    final List<String> kept = selected
        .where((String city) => available.contains(city.trim().toLowerCase()))
        .toList();
    if (kept.length == selected.length) return;
    model.setConfig(CrmFirestoreKeys.CITIES_KEY, kept);
    _replaceOptionsWithCities(kept);
  }

  /// Replaces the field options with the selected cities so the saved field
  /// (and the client-side dropdown) only offer the allowed cities.
  void _replaceOptionsWithCities(List<String> cities) {
    final List<CrmTemplateOptionEditModel> replaced =
        List<CrmTemplateOptionEditModel>.of(model.options);
    model.options
      ..clear()
      ..addAll(
        cities.map((String city) => CrmTemplateOptionEditModel(en: city)),
      );
    for (final CrmTemplateOptionEditModel option in replaced) {
      option.dispose();
    }
  }
}

class CrmTemplateAddressMultiSelectDropdown extends StatelessWidget {
  const CrmTemplateAddressMultiSelectDropdown({
    required this.title,
    required this.values,
    required this.onChanged,
    required this.readOnly,
    this.options,
    super.key,
  });

  final String title;
  final List<String> values;
  final ValueChanged<List<String>> onChanged;
  final bool readOnly;

  /// Available options shown in the list. Defaults to all countries.
  final List<String>? options;

  @override
  Widget build(BuildContext context) {
    final List<String> availableOptions =
        options ?? countries.map((Country country) => country.name).toList();
    final List<MultiSelectDropdownItem<String>> items = availableOptions
        .map(
          (String value) =>
              MultiSelectDropdownItem<String>(value: value, label: value),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 8.sp),
        AbsorbPointer(
          absorbing: readOnly,
          child: CustomMultiSelectDropdown<String>(
            hint: S.current.crmChoose,
            values: values,
            items: items,
            onChanged: onChanged,
            fillColor: AppColors.background,
            borderRadius: BorderRadius.circular(8.sp),
            overlayElevation: 0,
            hintStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.lightGrey),
            valueStyle: StyleText.fontSize12Weight400,
            itemStyle: StyleText.fontSize12Weight400,
            selectedTextBuilder:
                (List<MultiSelectDropdownItem<String>> selected) {
              if (selected.isEmpty) return S.current.crmChoose;
              if (selected.length == 1) return selected.first.label;
              return '${selected.length} ${S.current.crmSelected}';
            },
          ),
        ),
      ],
    );
  }
}

class CrmTemplateAddressInfoBox extends StatelessWidget {
  const CrmTemplateAddressInfoBox({
    required this.title,
    required this.value,
    super.key,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 8.sp),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 12.sp),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8.sp),
          ),
          child: Text(
            value,
            style: StyleText.fontSize12Weight400.copyWith(color: AppColors.lightGrey).copyWith(
              color: AppColors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
