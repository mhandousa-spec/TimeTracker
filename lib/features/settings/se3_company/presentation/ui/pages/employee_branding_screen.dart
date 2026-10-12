/// Module: settings/se3_company
///
///*************************** FILE INFO ****************************///
/// File Name: employee_branding_screen.dart
/// Purpose: Lets an employee override the company logo, colours and fonts.
/// Author: Amr Mesbah
/// Created at: 2026-01-25
/// Updated: 11/8/2026 - CR-SKEL-SE3-N11/N12/N13: the four try/catch blocks left
///          presentation/ui/ (colour parsing is `BrandingColor.parse` now);
///          `Get.snackbar` with raw Colors.red/white replaced by a themed,
///          localized SnackBar driven from the cubit's state; the remaining raw
///          `Colors.blue` / `Colors.black87` / `Colors.white70` route through
///          AppColors; the commented REMOVED_MODULE imports and the unused
///          `cloud_firestore` import are gone.
///
/// PORTED into services_app under features/settings.
/// Source: services_app features/employees/employee_branding/presentation/ui/…

import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';


import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/settings/se3_company/data/models/company_model/company_model.dart';
import 'package:knowticed_plus/features/settings/se3_company/domain/entities/employee_branding_entity.dart';
import 'package:knowticed_plus/features/settings/se3_company/presentation/controller/company_cubit.dart';
import 'package:knowticed_plus/features/settings/se3_company/presentation/controller/company_state.dart';
import 'package:knowticed_plus/core/custom/61-custom_color_picker.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/ui/pages/settings_screen.dart';
import 'package:knowticed_plus/features/settings/se3_company/presentation/ui/widgets/shared/company_image.dart';
import 'package:knowticed_plus/features/settings/se3_company/data/utils/branding_color.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/ui/widgets/restart_widget.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/custom/33-custom_haptic.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class EmployeeBrandingScreen extends StatefulWidget {
  const EmployeeBrandingScreen({super.key});

  @override
  State<EmployeeBrandingScreen> createState() => _EmployeeBrandingScreenState();
}

class _EmployeeBrandingScreenState extends State<EmployeeBrandingScreen> {
  // The single CompanyCubit is provided at the app root, so there's no
  // register-on-first-use dance here any more.
  CompanyCubit get companyController => context.read<CompanyCubit>();

  Color? selectedPrimaryColor;
  Color? selectedSecondaryColor;
  String? selectedEnglishFont;
  String? selectedArabicFont;
  String? selectedLogoUrl;

  @override
  void initState() {
    super.initState();
    _loadCurrentBranding();
  }

  /// Seeds the pickers from the employee's own branding, falling back to the
  /// company's. Colour parsing goes through [BrandingColor] so this page holds
  /// no try/catch (§20/§21, CR-SKEL-SE3-N11).
  void _loadCurrentBranding() {
    final EmployeeBrandingEntity? branding =
        companyController.state.employeeBranding;

    if (branding != null) {
      selectedLogoUrl = branding.logo;
      selectedPrimaryColor = BrandingColor.parse(branding.primaryColor);
      selectedSecondaryColor = BrandingColor.parse(branding.secondaryColor);
      selectedEnglishFont = branding.fontEnglish;
      selectedArabicFont = branding.fontArabic;
      return;
    }

    final CompanyModel? company = companyController.state.company;
    if (company == null) return;

    selectedLogoUrl = company.companyLogo?.companyLogo?.lastOrNull;
    selectedPrimaryColor =
        BrandingColor.parse(company.primaryColor?.primaryColor?.lastOrNull);
    selectedSecondaryColor = BrandingColor.parse(
        company.secondaryColor?.secondaryColor?.lastOrNull);
    selectedEnglishFont = company.englishFont?.englishFont?.lastOrNull;
    selectedArabicFont = company.arabicFont?.arabicFont?.lastOrNull;
  }

  List<DropdownItem<String>> _convertToDropdownItems(List<String> items) {
    return items
        .map((item) => DropdownItem<String>(
              value: item.toLowerCase(),
              label: item,
            ))
        .toList();
  }

  void _saveBranding() {
    final String? employeeId = employee?.id;

    if (employeeId == null) {
      // Was Get.snackbar('Error', 'Employee ID not found') with raw
      // Colors.red/white and no translation (CR-SKEL-SE3-N12).
      _showMessage(S.of(context).error, AppColors.signOut);
      return;
    }

    companyController.saveEmployeeBranding(
      employeeId: employeeId,
      logo: selectedLogoUrl,
      primaryColor: BrandingColor.format(selectedPrimaryColor),
      secondaryColor: BrandingColor.format(selectedSecondaryColor),
      fontEnglish: selectedEnglishFont?.toLowerCase(),
      fontArabic: selectedArabicFont?.toLowerCase(),
    );
  }

  void _showMessage(String message, Color background) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.textButton),
          ),
          backgroundColor: background,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  /// Consumes the cubit's one-shot feedback: the messages it used to raise
  /// itself with `Get.snackbar`, and the remount it used to perform with
  /// `RestartWidget.restartApp(Get.context!)` after a `Future.delayed`
  /// (CR-SKEL-SE3-N08, N09, N12).
  void _onCompanyState(BuildContext context, CompanyState state) {
    if (state.errorMessage != null) {
      _showMessage(S.of(context).error, AppColors.signOut);
    } else if (state.successMessage != null) {
      _showMessage(S.of(context).successMessage, AppColors.primary);
    }

    final bool restart = state.restartRequested;
    if (state.errorMessage != null ||
        state.successMessage != null ||
        restart) {
      companyController.clearMessages();
    }

    // Fonts are resolved when the tree is built, so the subtree is remounted
    // with this page's context — not with whatever `Get.context!` pointed at.
    if (restart) RestartWidget.restartApp(context);
  }

  void _resetToCompanyDefaults() {

    // Was DeleteDialog(isDeleteDialog: false) + a follow-up ResponseDialog.
    // CustomDialogManager.showDialogFlow covers both: it closes the confirm
    // dialog itself, runs onConfirm, and only shows the success dialog when
    // onConfirm returns true.
    CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie: "assets/lottie_assets/main_lottie_assets/reset_brand.json",
      confirmTitle: S.of(context).resetPersonalBranding,
      confirmSubtitle:
          S.of(context).areYouSureYouWantToResetYourPersonalBrandingToCo,
      confirmYesText: S.of(context).yes,
      confirmNoText: S.of(context).no,
      onConfirm: () async {

        hapticController.triggerHapticFeedback(
          vibration: VibrateType.mediumImpact,
          hapticFeedback: HapticFeedback.mediumImpact,
        );

        // Original skipped the success dialog when there was no employee id;
        // returning false reproduces that.
        if (employee?.id == null) return false;

        await companyController.resetEmployeeBrandingToCompany(employee!.id!);
        return true;
      },
      successLottie: "assets/lottie_assets/main_lottie_assets/correct.json",
      successTitle: "Successful",
      successSubtitle: "Personal Branding Has Been Reset To Company Defaults",
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ContextExtension(context).isPhone;
    final bool lightMode = Theme.of(context).brightness == Brightness.light;

    // BlocListener, not a bare build: the cubit reports success, failure and
    // "the fonts changed, remount" through state now (CR-SKEL-SE3-N12).
    return BlocListener<CompanyCubit, CompanyState>(
      listener: _onCompanyState,
      child: isMobile
          // MOBILE: full Scaffold with AppBar.
          ? Scaffold(
              appBar: AppBar(
                title: Text(S.of(context).personalBranding),
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.restore),
                    onPressed: _resetToCompanyDefaults,
                    tooltip: S.of(context).resetToCompanyDefaults,
                  ),
                ],
              ),
              body: _buildBrandingContent(isMobile, lightMode),
            )
          // TABLET: content only, it is hosted inside the settings pane.
          : _buildBrandingContent(isMobile, lightMode),
    );
  }

  // ✅ Extracted content builder
  Widget _buildBrandingContent(bool isMobile, bool lightMode) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info card
          Container(
            padding: EdgeInsets.all(12.sp),
            decoration: BoxDecoration(
              color: AppColors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.blue),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.blue),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    S.of(context).customizeYourPersonalBrandingTheseSettingsWillOv,
                    style: StyleText.fontSize14Weight400.copyWith(
                      color: lightMode
                          ? AppColors.colorBlack
                          : AppColors.colorWhiteDark,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // Main branding container
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: AppColors.card,
            ),
            child: Padding(
              padding: EdgeInsets.all(15.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo section
                  Text(
                    S.of(context).personalLogo,
                    style: StyleText.fontSize16Weight500.copyWith(
                      color: AppColors.text,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  CompanyImage(
                    onChangedImageUrl: (url) {
                      setState(() {
                        selectedLogoUrl = url;
                      });
                    },
                  ),

                  SizedBox(height: 24.h),

                  // Colors section
                  Text(
                    S.of(context).colors,
                    style: StyleText.fontSize16Weight500.copyWith(
                      color: AppColors.text,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  CustomColorPickerSection(
                    primaryColor: selectedPrimaryColor ?? AppColors.primary,
                    secondaryColor:
                        selectedSecondaryColor ?? AppColors.secondaryPrimary,
                    onPrimaryColorSelected: (Color color) {
                      setState(() {
                        selectedPrimaryColor = color;
                      });
                    },
                    onSecondaryColorSelected: (Color color) {
                      setState(() {
                        selectedSecondaryColor = color;
                      });
                    },
                  ),

                  SizedBox(height: 24.h),

                  // Fonts section
                  Text(
                    S.of(context).fonts,
                    style: StyleText.fontSize16Weight500.copyWith(
                      color: AppColors.text,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  buildResponsiveFields(
                    context: context,
                    mobileSpacing: 0,
                    left: CustomDropdown<String>(
                      value: selectedEnglishFont?.toLowerCase(),
                      items: _convertToDropdownItems(CompanyConstants.englishList),
                      // Pinned to the colour fields' 40 (10 + 20 + 10, all .sp) so
                      // the Fonts and Colors rows are the same height (Settings p.13).
                      height: 40,
                      hint: S.of(context).selectEnglishFont,
                      hintStyle: StyleText.fontSize12Weight400.copyWith(
                        color: AppColors.secondaryText,
                      ),
                      onChanged: (value) {
                        setState(() {
                          selectedEnglishFont = value;
                        });
                      },
                    ),
                    right: CustomDropdown<String>(
                      value: selectedArabicFont?.toLowerCase(),
                      items: _convertToDropdownItems(CompanyConstants.arabicList),
                      // Pinned to the colour fields' 40 (10 + 20 + 10, all .sp) so
                      // the Fonts and Colors rows are the same height (Settings p.13).
                      height: 40,
                      hint: S.of(context).selectArabicFont,
                      hintStyle: StyleText.fontSize12Weight400.copyWith(
                        color: AppColors.secondaryText,
                      ),
                      onChanged: (value) {
                        setState(() {
                          selectedArabicFont = value;
                        });
                      },
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: customButton(
                      title: S.of(context).savePersonalBranding,
                      function: _saveBranding,
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.textButton,
                      ),
                      height: 48.h,
                      radius: 8.r,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Moved here from core/helper/settings/utils/company_constants.dart, which was
// removed. This file is one of two independent consumers, so it keeps a local
// copy rather than sharing a dependency.
abstract class CompanyConstants {
  static const List<String> englishList = [
    'Cairo',
    'Tajawal',
    'Open Sans',
    'Muli',
    'Montserrat',
    'M Plus',
    'Lato',
    'Exo',
    'Calibri',
    'Arial',
  ];

  static List<String> arabicList = [
    'Tajawal',
    'Vazirmatn',
    'Rubik',
    'Noto Sans',
    'Harmattan',
    'Changa',
    'Amiri',
    'Almarai',
    'Alexandria',
    'Ibm Plex',
  ];
}
