/// Module: settings/se1_profile
///
///*************************** FILE INFO ****************************///
/// File Name: personal_information_fields.dart
/// Purpose: Stacks the three read-only cards of the personal-information page.
/// Author: Amr Mesbah
/// Created at: 10/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SE1-N03/N06/N17: builds the [PersonalProfile]
///          once and passes it down, so no section widget reads the `employee`
///          global; the commented-out REMOVED_MODULE import and the unused
///          `isTablet` local are gone.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/features/settings/main_controller/presentation/controller/settings_controller.dart';
import 'package:knowticed_plus/features/settings/se1_profile/domain/entities/personal_profile.dart';
import 'package:knowticed_plus/features/settings/se1_profile/presentation/controller/personal_information_controller.dart';
import 'package:knowticed_plus/features/settings/se1_profile/presentation/ui/widgets/sections/contact_information.dart';
import 'package:knowticed_plus/features/settings/se1_profile/presentation/ui/widgets/sections/location_data.dart';
import 'package:knowticed_plus/features/settings/se1_profile/presentation/ui/widgets/sections/personal_data.dart';

class PersonalInformationFields extends StatelessWidget {
  const PersonalInformationFields({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController settingsController = Get.find<SettingsController>();

    // Rebuilds when the shell reloads the employee, so the cards follow the
    // data instead of holding whatever was there when they were first built.
    return BlocBuilder<SettingsController, SettingsState>(
      bloc: settingsController,
      builder: (BuildContext context, SettingsState state) {
        final PersonalInformationController controller =
            settingsController.personalInformationController;
        final PersonalProfile profile = controller.profile;

        final bool isPhone = context.isPhone;

        // Mobile only: three separate rounded cards, the vertical gap between
        // them matching the 15.sp horizontal inset the page frame applies,
        // matching edit_page_request.dart. On every other breakpoint the three
        // sections stay in the single flush slab they have always been.
        return Container(
          decoration: isPhone
              ? null
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(0.sp),
                  color: AppColors.card,
                ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              PersonalData(
                isReadOnly: true,
                profile: profile,
                controller: controller,
              ),
              if (isPhone) SizedBox(height: 15.sp),
              ContactInformation(isReadOnly: false, profile: profile),
              if (isPhone) SizedBox(height: 15.sp),
              LocationData(profile: profile),
            ],
          ),
        );
      },
    );
  }
}
