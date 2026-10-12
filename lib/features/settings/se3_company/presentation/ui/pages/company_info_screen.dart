/// Module: settings/se3_company
///
///*************************** FILE INFO ****************************///
/// File Name: company_info_screen.dart
/// Purpose: Responsive company information / branding screen (phone + tablet in
///          one page).
/// Author: Amr Mesbah
/// Created at: 11/12/2024
/// Updated: 11/8/2026 - CR-SKEL-SE3-N14: the file-scope
///          `Get.put(HapticController())` — which registered a global singleton
///          as a side effect of importing this page — replaced with the lazy
///          `hapticController` accessor from core/custom/misc/custom_haptic.dart.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/theme_controller.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/settings/se3_company/presentation/controller/company_cubit.dart';
import 'package:knowticed_plus/features/settings/se3_company/presentation/controller/company_state.dart';
import 'package:knowticed_plus/features/settings/se3_company/presentation/ui/widgets/sections/company_branding_section.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';

import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/33-custom_haptic.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CompanyInfoScreen extends StatefulWidget {
  final bool? isBranding;

  CompanyInfoScreen({super.key, this.isBranding = false});

  @override
  // ignore: library_private_types_in_public_api
  _CompanyInfoScreenState createState() => _CompanyInfoScreenState();
}

class _CompanyInfoScreenState extends State<CompanyInfoScreen> {
  bool isEnglish = Get.locale.toString().contains('en');
  CompanyCubit get companyController => context.read<CompanyCubit>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ContextExtension(context).isPhone
        ? _buildPhone(context)
        : _buildTablet(context);
  }

  /// Apply = confirm dialog -> save -> success dialog.
  ///
  /// Both the phone and the tablet Apply buttons route through here so the two
  /// layouts can't drift apart. CustomDialogManager only shows the success step
  /// when [onConfirm] returns true, so a failed save no longer reports success:
  /// CompanyCubit.updateCompanyModel() doesn't throw, it emits
  /// CompanyStatus.failure, which is what the return value is read from.
  Future<void> _applyChanges(BuildContext context) async {
    await CustomDialogManager.showDialogFlow(
      context: context,
      // CHANGED 8/9/2026 — was `lottie_warning.json`, the red exclamation mark.
      //
      // This is the branding page's other action, sitting right beside Reset,
      // and Reset's dialog uses `reset_brand.json`
      // (company_branding_section.dart, _resetBranding). The two now match, so
      // the page does not alarm the user with a red warning for saving their
      // own edits while the genuinely destructive action gets the calmer icon.
      confirmLottie: 'assets/lottie_assets/main_lottie_assets/reset_brand.json',
      confirmTitle: S.of(context).applyChanges,
      confirmSubtitle: S.of(context).areYouSureYouWantToSaveTheseChanges,
      confirmYesText: S.of(context).yes,
      confirmNoText: S.of(context).no,
      onConfirm: () async {
        hapticController.triggerHapticFeedback(
          vibration: VibrateType.mediumImpact,
          hapticFeedback: HapticFeedback.mediumImpact,
        );

        await companyController.updateCompanyModel();

        return companyController.state.status != CompanyStatus.failure;
      },
      successLottie: 'assets/lottie_assets/main_lottie_assets/correct.json',
      successTitle: S.of(context).Successful,
      successSubtitle: S.of(context).dataHasBeenSavedSuccessfully,
      onSuccessComplete: () {
        if (mounted) setState(() {});
      },
    );
  }

  /// Apply, greyed out and untappable until [CompanyState.hasBrandingChanges].
  ///
  /// Opacity + IgnorePointer + a grey fill — the same disabled treatment used
  /// by the request preview pages, the health edit page and the social screen,
  /// so a dead action looks the same everywhere in Settings.
  ///
  /// Also disabled mid-save: `updateCompanyModel()` emits
  /// `CompanyStatus.loading` first, and a second tap during the write would
  /// stack a second confirm dialog on top of the first.
  Widget _buildApplyButton(
    BuildContext context,
    CompanyState state, {
    double? width,
  }) {
    final bool enabled =
        state.hasBrandingChanges && state.status != CompanyStatus.loading;

    // FIXED 8/9/2026 — the disabled label was unreadable, same as Submit on the
    // health request preview page. `AppColors.textButton` is
    // `AppTheme.contrastColor()`, so in light mode it resolves to (near) black
    // on the grey disabled fill, and the `Opacity(0.5)` wrapper washed out what
    // was left of it. The label is pinned to white while disabled and the
    // opacity layer is gone, since it faded the white back to grey. The FILL is
    // unchanged: primary when enabled, AppColors.grey when not.
    return IgnorePointer(
      ignoring: !enabled,
      child: customButton(
        title: S.of(context).Apply,
        fullWidth: true,
        width: width,
        function: () async {
          await _applyChanges(context);
        },
        color: enabled ? AppColors.primary : AppColors.darkGrey,
        textStyle: StyleText.fontSize16Weight500
            .copyWith(color: enabled ? AppColors.textButton : AppColors.white),
      ),
    );
  }

  /// Phone design.
  ///
  /// CHANGED: this used to open on a `CustomTabs` pair — "Company Information"
  /// and "Branding" — so tapping Settings > Branding and Theme on a phone
  /// landed on the COMPANY INFO tab, showing a different screen from the one
  /// the same menu entry opens on desktop. It was also a duplicate route in:
  /// Settings > Company Information already opens CompanyScreenInfo, and only
  /// the Branding tab here had a working action (the info tab's "Update"
  /// opened a dialog whose form widgets were deleted).
  ///
  /// The phone now shows exactly what _buildTablet shows — the branding
  /// editor and Apply — wrapped in the breadcrumb frame every other pushed
  /// settings page uses, since this one is reached with Navigator.push.
  Widget _buildPhone(BuildContext context) {
    return BlocBuilder<CompanyCubit, CompanyState>(
      builder: (context, state) => SideFrameMasterServices(
        titleText: S.of(context).settings,
        onFirstTap: () => Navigator.of(context).maybePop(),
        secondTitle: S.of(context).brandingAndTheme,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: CompanyBrandingScreen(
                onChangedImageUrl: (value) {},
                onChangedPrimaryColor: (Color value) {},
                onChangedSecondaryColor: (Color value) {},
                onChangedFontArabic: (String value) {},
                onChangedFontEnglish: (String value) {},
              ),
            ),
            SizedBox(height: 15.sp),
            // Routes through _applyChanges, exactly like the tablet button.
            //
            // `width` is passed explicitly because customButton IGNORES its
            // `fullWidth` flag (see the SCOPE note in 5-custom_button.dart) and
            // falls back to the fixed 135.sp phone width — which is why Apply
            // was a small button floating under a full-width card. `width` is
            // the one lever that widget still honours.
            _buildApplyButton(context, state, width: double.infinity),
            SizedBox(height: 15.sp),
          ],
        ),
      ),
    );
  }

  /// Tablet design (formerly tablet_company_info_screen.dart)
  Widget _buildTablet(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    return Expanded(
      child: SingleChildScrollView(
        // ADDED 24/8/2026: this layout read nothing from the cubit, so the
        // Apply button below could not know whether anything had been picked.
        // The phone layout was already inside a BlocBuilder.
        child: BlocBuilder<CompanyCubit, CompanyState>(
          builder: (context, state) => Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color:
                    lightMode ? AppColors.background : AppColors.chatBackground,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: SingleChildScrollView(
                child: CompanyBrandingScreen(
                  onChangedImageUrl: (value) {},
                  onChangedPrimaryColor: (Color value) {},
                  onChangedSecondaryColor: (Color value) {},
                  onChangedFontArabic: (String value) {},
                  onChangedFontEnglish: (String value) {},
                ),
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: 220.w,
              // Haptics + setState live inside _applyChanges, so both layouts
              // behave identically.
              child: _buildApplyButton(context, state, width: 220.w),
            ),
          ],
          ),
        ),
      ),
    );
  }
}
