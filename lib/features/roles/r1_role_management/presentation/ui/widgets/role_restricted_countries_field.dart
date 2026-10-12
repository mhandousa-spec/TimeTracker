/// Module: roles / r1_role_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: role_restricted_countries_field.dart
/// Purpose: The country picker shown under the Restricted Location switch on
///          the role editor's third page (Edit Role Settings Permissions).
/// Author: Knowticed Plus team
/// Created at: 28/9/2026
///
/// MOVED FROM SETTINGS. Restricted Location used to be an employee setting —
/// a switch plus `RestrictedLocationCountries` on the Settings page, stored in
/// that device's local storage and never enforced. It is a ROLE policy now:
/// the admin ticks the countries here while creating or editing the role, the
/// list is saved with the role (`RoleRepository.ROLE_RESTRICTED_LOCATIONS`),
/// and `RestrictedLocationGuard` applies it to every employee holding the role.
///
/// No Save button of its own: ticks go straight into
/// [RoleCubit.restrictedCountryCodes] and are written with the rest of the
/// role when the page's Save / Create is pressed.
///
/// Selections are ISO country CODES, not names — names are localised, and a
/// stored name would stop matching the moment the language changed.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/49-custom_view_multi_select_dropdown.dart';
import 'package:knowticed_plus/core/helper/main_helper/countries.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class RoleRestrictedCountriesField extends StatelessWidget {
  const RoleRestrictedCountriesField({super.key, required this.controller});

  final RoleCubit controller;

  @override
  Widget build(BuildContext context) {
    final String language = Localizations.localeOf(context).languageCode;
    final List<_CountryOption> options = _options(language);

    // The dropdown speaks in labels; the cubit speaks in codes.
    final Map<String, String> codeForLabel = <String, String>{
      for (final _CountryOption option in options) option.label: option.code,
    };
    final List<String> selectedLabels = options
        .where((_CountryOption option) =>
            controller.restrictedCountryCodes.contains(option.code))
        .map((_CountryOption option) => option.label)
        .toList();

    return Padding(
      padding: EdgeInsetsDirectional.only(top: 6.sp, bottom: 4.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            S.of(context).restrictedLocationCountriesHint,
            style: StyleText.fontSize12Weight400
                .copyWith(color: AppColors.secondaryBlack),
          ),
          SizedBox(height: 8.sp),
          AppMultiSelectDropdownMaster(
            width: double.infinity,
            items:
                options.map((_CountryOption option) => option.label).toList(),
            selectedItems: selectedLabels,
            // Null keeps the hint visible; a summary replaces it once at least
            // one country is ticked.
            textButton:
                selectedLabels.isEmpty ? null : selectedLabels.join(', '),
            hintText: S.of(context).selectCountry,
            fillColor: AppColors.background,
            onChanged: (dynamic item) {
              final String? code = codeForLabel[item.toString()];
              if (code == null) return;
              controller.toggleRestrictedCountry(code);
            },
          ),
        ],
      ),
    );
  }

  /// The country list as the dropdown wants it — localised labels,
  /// alphabetical, with duplicate names disambiguated by ISO code so two
  /// countries can never collapse onto one row.
  List<_CountryOption> _options(String language) {
    final Map<String, int> seen = <String, int>{};
    final List<_CountryOption> options = <_CountryOption>[];

    for (final Country country in countries) {
      final String name = country.localizedName(language);
      final int count = (seen[name] ?? 0) + 1;
      seen[name] = count;
      options.add(
        _CountryOption(
          code: country.code,
          label: count == 1 ? name : '$name (${country.code})',
        ),
      );
    }

    options.sort((_CountryOption a, _CountryOption b) =>
        a.label.toLowerCase().compareTo(b.label.toLowerCase()));
    return options;
  }
}

/// One row of the dropdown: what the admin reads, and what gets stored.
class _CountryOption {
  const _CountryOption({required this.code, required this.label});

  final String code;
  final String label;
}
