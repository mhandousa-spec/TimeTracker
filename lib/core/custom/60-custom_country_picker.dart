/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: country_picker_dialog.dart
/// Purpose: Declares `CountryPickerDialog`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

///*************************** FILE INFO ****************************///
/// Purpose: Country picker dialog for selecting country and dial code.
/// Author: Claude AI Assistant
/// Created At: 27/10/2025
/// Moved: from features/settings/.../dialogs/country_bicker.dart into
///        core/custom, because 59-custom_intl_phone_field.dart depends on it
///        and core must not import from features.

import 'package:knowticed_plus/core/custom/99-custom_country_flag.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/helper/main_helper/countries.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/core/new_theme.dart';

/// Shows a dialog to select a country with search functionality
Future<Country?> showCountryPickerDialog(BuildContext context) async {
  return await showDialog<Country?>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) => const CountryPickerDialog(),
  );
}

class CountryPickerDialog extends StatefulWidget {
  const CountryPickerDialog({super.key});

  @override
  State<CountryPickerDialog> createState() => _CountryPickerDialogState();
}

class _CountryPickerDialogState extends State<CountryPickerDialog> {
  final TextEditingController searchController = TextEditingController();
  List<Country> filteredCountries = [];

  @override
  void initState() {
    super.initState();
    filteredCountries = countries;
    searchController.addListener(_filterCountries);
  }

  @override
  void dispose() {
    searchController.removeListener(_filterCountries);
    searchController.dispose();
    super.dispose();
  }

  void _filterCountries() {
    final query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredCountries = countries;
      } else {
        filteredCountries = countries.where((country) {
          return country.name.toLowerCase().contains(query) ||
              country.dialCode.contains(query) ||
              country.code.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: lightMode ? Colors.white : AppColors.chatBackground,
      child: Container(
        width: isTablet ? 500 : MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // REMOVED 8/9/2026 — the "Select Country" title row and its close
            // button. The search field's hint already says what the dialog is
            // for, and the dialog is `barrierDismissible: true`, so tapping
            // outside still closes it; the X was a second way to do the same
            // thing at the cost of a whole row of height.

            // Search Field — the shared AppSearchTextField, so the dialog
            // matches every other search in the app (radius, hint, icon).
            // CHANGED 16/8/2026: was a hand-rolled CustomTextField.
            // AppSearchTextField's root IS an Expanded, which would eat the
            // dialog's height inside this Column — hence the Row wrapper, where
            // Expanded means "fill the width" instead.
            //
            // `fillColor` CHANGED 8/9/2026: the widget defaults to
            // AppColors.card, which is the same surface the dialog itself sits
            // on, so the field disappeared into its own background. It now
            // takes AppColors.background, one step back from the card, so the
            // search box reads as an input.
            Row(
              children: [
                AppSearchTextField(
                  controller: searchController,
                  hintText: S.of(context).searchCountry,
                  fillColor: AppColors.background,
                ),
              ],
            ),

            SizedBox(height: 16.sp),

            // Results count.
            // FIXED 13/8/2026: was the literal '${…length} countries', which
            // rendered as "countries 243" once the RTL layout flipped it.
            Text(
              '${filteredCountries.length} ${S.of(context).countries}',
              style: StyleText.fontSize12Weight400.copyWith(
                color: lightMode
                    ? AppColors.secondaryText
                    : AppColors.grey,
              ),
            ),

            SizedBox(height: 8.sp),

            // Country List
            Expanded(
              child: filteredCountries.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 48.sp,
                      color: lightMode
                          ? AppColors.secondaryText
                          : AppColors.grey,
                    ),
                    SizedBox(height: 16.sp),
                    Text(
                      S.of(context).noCountriesFound,
                      style: StyleText.fontSize14Weight400.copyWith(
                        color: lightMode
                            ? AppColors.blackButton
                            : AppColors.white,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: filteredCountries.length,
                itemBuilder: (context, index) {
                  final country = filteredCountries[index];
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).pop(country);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.sp,
                        vertical: 12.sp,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: lightMode
                                ? Colors.grey.shade200
                                : Colors.grey.shade800,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Flag
                          // Bug report p.38: real flag image — the emoji
                          // rendered as its two letters on Windows.
                          AppCountryFlag(
                            isoCode: country.code,
                            width: 28.sp,
                            height: 21.sp,
                          ),

                          SizedBox(width: 12.sp),

                          // Country Name
                          Expanded(
                            child: Text(
                              country.name,
                              style: StyleText.fontSize14Weight500.copyWith(
                                color: lightMode
                                    ? AppColors.blackButton
                                    : AppColors.white,
                              ),
                            ),
                          ),

                          // Dial Code
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.sp,
                              vertical: 4.sp,
                            ),
                            decoration: BoxDecoration(

                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '+${country.dialCode}',
                              style: StyleText.fontSize12Weight500.copyWith(
                                color: lightMode ? AppColors.blackButton : AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}