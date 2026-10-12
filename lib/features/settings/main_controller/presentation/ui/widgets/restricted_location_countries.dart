/// Module: settings/main_controller
///
///*************************** FILE INFO ****************************///
/// File Name: restricted_location_countries.dart
/// Purpose: The country picker that appears under the Restricted Location
///          switch — which countries the app may be opened from.
/// Author: Knowticed Plus team
/// Created at: 26/8/2026
///
/// Shown only while Restricted Location is on. The employee ticks countries in
/// the shared multi-select dropdown, and nothing is written until they press
/// Save: that runs the standard confirm -> success flow through
/// [CustomDialogManager], and only the confirmed list reaches
/// [DevicePolicyController].
///
/// Selections are held as ISO country CODES, not names. Names are localised
/// (and the employee can switch language mid-session), so a stored name would
/// stop matching the list the moment the locale changed.
///
/// SCOPE: this screen chooses the allowed countries and persists them. It does
/// NOT yet block anything — the geofence check that reads
/// `DevicePolicyController.allowedCountryCodes` and refuses to open the app
/// outside them still has to be written, the same way the screen-capture block
/// was wired to the other two switches.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/49-custom_view_multi_select_dropdown.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/helper/main_helper/countries.dart';
import 'package:knowticed_plus/core/helper/main_helper/device_policy_controller.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class RestrictedLocationCountries extends StatefulWidget {
  const RestrictedLocationCountries({super.key, required this.controller});

  final DevicePolicyController controller;

  @override
  State<RestrictedLocationCountries> createState() =>
      _RestrictedLocationCountriesState();
}

class _RestrictedLocationCountriesState
    extends State<RestrictedLocationCountries> {
  /// The unsaved selection. Seeded from what is stored, replaced only when the
  /// employee confirms — so backing out of the dialog changes nothing.
  late List<String> _draft =
      List<String>.of(widget.controller.allowedCountryCodes);

  @override
  Widget build(BuildContext context) {
    final String language = Localizations.localeOf(context).languageCode;
    final List<_CountryOption> options = _options(language);

    // The dropdown speaks in labels; everything else here speaks in codes.
    final Map<String, String> codeForLabel = <String, String>{
      for (final _CountryOption option in options) option.label: option.code,
    };
    final List<String> selectedLabels = options
        .where((_CountryOption option) => _draft.contains(option.code))
        .map((_CountryOption option) => option.label)
        .toList();

    final bool isDirty = !_sameSelection(
      _draft,
      widget.controller.allowedCountryCodes,
    );

    return Container(
      color: AppColors.card,
      padding: EdgeInsetsDirectional.only(
        start: 16.w,
        end: 16.w,
        bottom: 12.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            S.of(context).restrictedLocationCountriesHint,
            style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack),
          ),
          SizedBox(height: 8.h),
          AppMultiSelectDropdownMaster(
            width: double.infinity,
            items: options.map((_CountryOption option) => option.label).toList(),
            selectedItems: selectedLabels,
            // Null keeps the hint visible; a summary replaces it once at least
            // one country is ticked.
            textButton: selectedLabels.isEmpty ? null : selectedLabels.join(', '),
            hintText: S.of(context).selectCountry,
            fillColor: AppColors.background,
            onChanged: (dynamic item) {
              final String? code = codeForLabel[item.toString()];
              if (code == null) return;
              setState(() {
                if (_draft.contains(code)) {
                  _draft.remove(code);
                } else {
                  _draft.add(code);
                }
              });
            },
          ),
          if (isDirty) ...<Widget>[
            SizedBox(height: 10.h),
            Row(
              children: <Widget>[
                customButton(
                  title: S.of(context).save,
                  wrapContent: true,
                  function: _confirmAndSave,
                ),
                SizedBox(width: 10.w),
                customButton(
                  title: S.of(context).cancel,
                  wrapContent: true,
                  color: Colors.transparent,
                  borderColor: AppColors.secondaryBlack,
                  textColor: AppColors.text,
                  function: () => setState(() {
                    _draft =
                        List<String>.of(widget.controller.allowedCountryCodes);
                  }),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Function Name: [_confirmAndSave]
  ///
  /// Purpose: Run the standard confirm -> success dialog flow and persist the
  ///          draft only if the employee confirms.
  Future<void> _confirmAndSave() async {
    // Snapshot the draft: the dialog is async and the list is mutable.
    final List<String> pending = List<String>.of(_draft);

    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie: AppAssets.lottieConfirmation,
      confirmTitle: S.of(context).restrictedLocation,
      confirmSubtitle: S.of(context).restrictedLocationConfirmSubtitle,
      confirmYesText: S.of(context).confirm,
      confirmNoText: S.of(context).cancel,
      onConfirm: () async {
        await widget.controller.saveAllowedCountryCodes(pending);
        return true;
      },
      successLottie: AppAssets.successful,
      successTitle: S.of(context).success,
      successSubtitle: S.of(context).restrictedLocationSuccessSubtitle,
    );

    // Redraw so the Save/Cancel row disappears once the draft and the stored
    // list agree again. Guarded: the flow awaits two dialogs, and the settings
    // page can be left in between.
    if (mounted) setState(() {});
  }

  /// Function Name: [_options]
  ///
  /// Purpose: The country list as the dropdown wants it — localised labels,
  ///          alphabetical, with duplicates disambiguated by ISO code so two
  ///          countries can never collapse onto one row.
  ///
  /// Parameters:
  /// - [language]: the active language code, e.g. 'en' or 'ar'.
  ///
  /// Returns: [List<_CountryOption>] sorted by label.
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

  /// Function Name: [_sameSelection]
  ///
  /// Purpose: Order-insensitive comparison — ticking A then B must not read as
  ///          a change against a stored [B, A].
  bool _sameSelection(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    return a.toSet().containsAll(b);
  }
}

/// One row of the dropdown: what the employee reads, and what gets stored.
class _CountryOption {
  const _CountryOption({required this.code, required this.label});

  final String code;
  final String label;
}
