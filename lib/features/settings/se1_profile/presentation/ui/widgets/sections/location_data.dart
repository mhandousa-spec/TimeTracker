/// Module: settings/se1_profile
///
///*************************** FILE INFO ****************************///
/// File Name: location_data.dart
/// Purpose: The Location card of the personal-information page — country,
///          province, city and street, all read-only.
/// Author: Amr Mesbah
/// Created at: 10/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SE1-N06/N15/N17/N18: takes a [PersonalProfile]
///          instead of force-unwrapping the `employee` global, the commented
///          REMOVED_MODULE import and the unused `lightMode` / `isTablet`
///          locals are gone, and Colors.transparent is routed through
///          AppColors.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/ui/widgets/settings_header.dart';
import 'package:knowticed_plus/features/settings/se1_profile/domain/entities/personal_profile.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class LocationData extends StatefulWidget {
  const LocationData({super.key, required this.profile});

  /// The address values. Previously read as `employee!.country?.lastOrNull` and
  /// friends — a force-unwrap of a mutable global (CR-SKEL-SE1-N17).
  final PersonalProfile profile;

  @override
  State<LocationData> createState() => _LocationDataState();
}

class _LocationDataState extends State<LocationData> {
  late final TextEditingController _countryController;
  late final TextEditingController _provinceController;
  late final TextEditingController _cityController;
  late final TextEditingController _streetController;

  @override
  void initState() {
    super.initState();
    _countryController =
        TextEditingController(text: _display(widget.profile.country));
    _provinceController =
        TextEditingController(text: _display(widget.profile.province));
    _cityController = TextEditingController(text: _display(widget.profile.city));
    _streetController =
        TextEditingController(text: _display(widget.profile.street));
  }

  @override
  void didUpdateWidget(covariant LocationData oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile) {
      _countryController.text = _display(widget.profile.country);
      _provinceController.text = _display(widget.profile.province);
      _cityController.text = _display(widget.profile.city);
      _streetController.text = _display(widget.profile.street);
    }
  }

  static String _display(String value) =>
      value.isEmpty ? '' : FormatHelper.capitalize(value);

  @override
  void dispose() {
    _countryController.dispose();
    _provinceController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isPhone = ContextExtension(context).isPhone;
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Container(
      decoration: isPhone
          // Mobile only: rounded like each card on the edit page.
          ? BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
        color:  AppColors.card,
      )
          : BoxDecoration(
        borderRadius: BorderRadius.circular(0),
        color:  AppColors.card,
      ),
      child: Column(
        children: [
          SizedBox(height: 12.sp),
          SettingsHeader(
              imagePath: 'assets/icons_assets/settings_assets/location_city_pin.svg',
              text: S.of(context).location),
          Padding(
            padding: EdgeInsets.only(top: 0.sp,right: 15.sp,left: 15.sp, bottom: 15.sp),
            child: Column(
              children: [



                // Mobile only: 15.sp after a section title. Others keep 10.sp.
                SizedBox(height: isPhone ? 15.sp : 10.sp),

                // Country, Province, City in one row
                isPortrait
                    ? Column(
                  children: [
                    // Country Field
                    CustomTextField(
                          label: S.of(context).country,
                          hint: S.of(context).enterYourCountry,
                          controller: _countryController,
                          enabled: false,
                        ),
                    // Mobile only: matches the 16.h the edit page uses between fields.
                    isPhone ? SizedBox(height: 10.sp) : SizedBox(height: 16.h),

                    // Province Field
                    CustomTextField(
                          label: S.of(context).stateOrProvince,
                          hint: S.of(context).enterYourStateOrProvince,
                          controller: _provinceController,
                          enabled: false,
                        ),
                    // Mobile only: matches the 16.h the edit page uses between fields.
                    isPhone ? SizedBox(height: 10.sp) : SizedBox(height: 16.h),

                    // City Field
                    CustomTextField(
                          label: S.of(context).city,
                          hint: S.of(context).enterYourCity,
                          controller: _cityController,
                          enabled: false,
                        ),
                    isPhone ? SizedBox() : SizedBox(height: 16.h),
                  ],
                )
                // Three equal columns separated by a 12.w gap — the same grid the
                // Name and Contact rows use, so every field lines up vertically.
                    : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Country Field
                    Expanded(
                      child: CustomTextField(
                            label: S.of(context).country,
                            hint: S.of(context).enterYourCountry,
                            controller: _countryController,
                            enabled: false,
                          ),
                    ),

                    SizedBox(width: 12.w),

                    // Province Field
                    Expanded(
                      child: CustomTextField(
                            label: S.of(context).stateOrProvince,
                            hint: '_',
                            controller: _provinceController,
                            enabled: false,
                          ),
                    ),

                    SizedBox(width: 12.w),

                    // City Field
                    Expanded(
                      child: CustomTextField(
                            label: S.of(context).city,
                            hint: S.of(context).enterYourCity,
                            controller: _cityController,
                            enabled: false,
                          ),
                    ),
                  ],
                ),

                // Mobile only: matches the 16.h the edit page uses between fields.
                SizedBox(height: isPhone ? 10.sp : 16.h),

                // Street Field (Full Width)
                CustomTextField(
                  label: S.of(context).streetName,
                  hint: '-',
                  controller: _streetController,
                  enabled: false,
                ),

               // isPhone ? SizedBox() : SizedBox(height: 16.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}