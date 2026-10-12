/// Module: settings/se3_company
///
///*************************** FILE INFO ****************************///
/// File Name: company_branding_section.dart
/// Purpose: The company branding section — logo, colours, fonts and the reset.
/// Author: Amr Mesbah
/// Created at: 11/04/2025
/// Updated: 11/8/2026 - CR-SKEL-SE3-N05/N11/N15: renamed from
///          `company_branding_screen.dart` (a widget named `_screen`, which
///          collided conceptually with the real page); the reset's model
///          mutation and Firestore write moved into `CompanyCubit`, so this
///          widget holds no `try`; the malformed `Color(0xffCCCCCCCC)` — 10 hex
///          digits, alpha silently masked off — is now `AppColors.disabledButton`.
/// Earlier: Fixed cross-device branding sync; reset applies immediately without
///          needing an Apply click; colours update in the UI after a reset.
/// Updated: 23/8/2026 - the colour fields and the font dropdowns now show the
///          value that is actually in force instead of falling back to their
///          hints every time the section is rebuilt. Two causes, both fixed
///          here: (1) `initState` called `clearBrandingSelections()`, so a pick
///          the user had not applied yet was wiped the moment they left the tab
///          and came back; (2) the colour fields were bound to
///          `state.primaryColor` / `state.secondaryColor` only — the *unsaved*
///          slice of state — with no fallback to the saved company document, so
///          even an applied brand rendered as "Primary Color" / "Secondary
///          Color" hints on re-entry. The fonts already had that fallback
///          (`_getInitialEnglishFont`); the colours now read the same way via
///          `BrandingColor.parse`. Both then fall through to the theme default
///          the app is actually rendering with, so no branding field ever shows
///          a hint — matching how `employee_branding_screen.dart` already seeds
///          its own pickers.
import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:knowticed_plus/core/custom/61-custom_color_picker.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart' hide storage;


import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/settings/se3_company/data/utils/branding_color.dart';
import 'package:knowticed_plus/features/settings/se3_company/presentation/controller/company_cubit.dart';
import 'package:knowticed_plus/features/settings/se3_company/presentation/controller/company_state.dart';
import 'package:knowticed_plus/core/custom/33-custom_haptic.dart';
import 'package:knowticed_plus/features/settings/se3_company/presentation/ui/widgets/shared/company_image.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';

import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
class CompanyBrandingScreen extends StatefulWidget {
  const CompanyBrandingScreen({
    super.key,
    required this.onChangedImageUrl,
    required this.onChangedPrimaryColor,
    required this.onChangedSecondaryColor,
    required this.onChangedFontEnglish,
    required this.onChangedFontArabic,
  });

  final ValueChanged<String> onChangedImageUrl;
  final ValueChanged<Color> onChangedPrimaryColor;
  final ValueChanged<Color> onChangedSecondaryColor;
  final ValueChanged<String> onChangedFontEnglish;
  final ValueChanged<String> onChangedFontArabic;

  @override
  State<CompanyBrandingScreen> createState() => _CompanyBrandingScreenState();
}

class _CompanyBrandingScreenState extends State<CompanyBrandingScreen> {
  CompanyCubit get _cubit => context.read<CompanyCubit>();

  final TextEditingController _companyNameController = TextEditingController();

  // FIXED 23/8/2026: initState used to clear the branding selections here.
  //
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     if (mounted) _cubit.clearBrandingSelections();
  //   });
  //
  // CompanyCubit lives at the app root (BlocProvider.value in main()), so the
  // selections survive navigation on their own — this callback was the only
  // thing throwing them away. Switching to the Company Information tab and back
  // remounts this widget, which meant a colour or font the user had picked but
  // not applied yet silently reverted to a hint. The selections are still
  // cleared where that is actually correct: `CompanyCubit.resetCompanyBranding`
  // calls `clearBrandingSelections()` as part of the reset.

  @override
  void dispose() {
    _companyNameController.dispose();
    super.dispose();
  }

  List<DropdownItem<String>> _convertToDropdownItems(List<String> items) {
    return items
        .map((item) => DropdownItem<String>(
              value: item.toLowerCase(),
              label: item,
            ))
        .toList();
  }

  // ── Effective branding values ───────────────────────────────────────────────
  //
  // Each field resolves in the same three steps: the unsaved selection first
  // (what the user just picked, still waiting on Apply), then the saved company
  // document, then the theme default the app is actually rendering with. So the
  // fields always show the value in force and never fall back to a hint.
  //
  // These take the state from the BlocBuilder rather than reading `_cubit.state`
  // themselves, so what they return is always the state the surrounding build
  // was given.

  /// The families `ThemeController.updateFonts()` falls back to when neither
  /// storage nor the company document has a font — so a cleared brand shows the
  /// family the app is actually rendering with, exactly like the colours below.
  /// Lower-cased because that is the shape `CustomDropdown` matches on
  /// (`_convertToDropdownItems` lower-cases every item value).
  static const String _defaultEnglishFont = 'cairo';
  static const String _defaultArabicFont = 'vazirmatn';

  String _effectiveEnglishFont(CompanyState state) {
    if (state.selectedEnglishFont != null) {
      return state.selectedEnglishFont!.toLowerCase();
    }
    if (state.isCompanyActive) {
      final String? saved = state.company?.englishFont?.englishFont?.lastOrNull;
      if (saved != null) return saved.toLowerCase();
    }
    return _defaultEnglishFont;
  }

  String _effectiveArabicFont(CompanyState state) {
    if (state.selectedArabicFont != null) {
      return state.selectedArabicFont!.toLowerCase();
    }
    if (state.isCompanyActive) {
      final String? saved = state.company?.arabicFont?.arabicFont?.lastOrNull;
      if (saved != null) return saved.toLowerCase();
    }
    return _defaultArabicFont;
  }

  /// FIXED 23/8/2026: this fallback did not exist. `CustomColorPickerSection`
  /// was handed `state.primaryColor` straight, and that field only ever holds an
  /// unsaved pick — the saved colour lives on the company document, as an
  /// `0xAARRGGBB` string. So an applied brand still rendered as a hint the next
  /// time the section was built. `BrandingColor.parse` is the same reader the
  /// employee branding screen uses, and returns null on a malformed value rather
  /// than throwing.
  ///
  /// The third step is `AppColors.primary` / `AppColors.secondaryPrimary`, so
  /// the return type is non-nullable and the colour fields never render their
  /// hint. A cleared brand is not "no colour" — the app is painting the default
  /// (#FFDE59 / #E5B800) and the field should say so, which is the question the
  /// user is actually asking of it. `employee_branding_screen.dart` already
  /// seeds its pickers this way (`selectedPrimaryColor ?? AppColors.primary`);
  /// the two branding screens agree now.
  ///
  /// This replaces the earlier "after a reset both are null and the fields fall
  /// back to their hints" behaviour deliberately — the hint state was reachable
  /// on an ACTIVE company whose colours had been cleared but whose fonts had
  /// since been re-applied, which read as a bug rather than as a design.
  Color _effectivePrimaryColor(CompanyState state) {
    if (state.primaryColor != null) return state.primaryColor!;
    if (state.isCompanyActive) {
      final Color? saved = BrandingColor.parse(
        state.company?.primaryColor?.primaryColor?.lastOrNull,
      );
      if (saved != null) return saved;
    }
    return AppColors.primary;
  }

  Color _effectiveSecondaryColor(CompanyState state) {
    if (state.secondaryColor != null) return state.secondaryColor!;
    if (state.isCompanyActive) {
      final Color? saved = BrandingColor.parse(
        state.company?.secondaryColor?.secondaryColor?.lastOrNull,
      );
      if (saved != null) return saved;
    }
    return AppColors.secondaryPrimary;
  }

  /// Shows an error dialog instead of failing silently.
  ///
  /// Every abort path in the reset flow used to just return (or throw into
  /// CustomDialogManager's catch, which swallows it and returns false), so a
  /// failed reset looked exactly like a dead button.
  Future<void> _showResetError(String subtitle) async {
    if (!mounted) return;
    await CustomDialogManager.showMessage(
      context: context,
      lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
      title: S.of(context).unsuccessful,
      subtitle: subtitle,
    );
  }

  /// Drives the reset dialog flow. The model mutation and the Firestore write
  /// moved into `CompanyCubit.resetCompanyBranding()` — this widget no longer
  /// holds a `try` (§20/§21, CR-SKEL-SE3-N11).
  Future<void> _resetBranding() async {
    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie: "assets/lottie_assets/main_lottie_assets/reset_brand.json",
      confirmTitle: S.of(context).resetBranding,
      confirmSubtitle: S.of(context).areYouSureYouWantToResetTheCompanyBranding,
      confirmYesText: S.of(context).yes,
      confirmNoText: S.of(context).no,
      onConfirm: () async {
        hapticController.triggerHapticFeedback(
          vibration: VibrateType.mediumImpact,
          hapticFeedback: HapticFeedback.mediumImpact,
        );

        final bool reset = await _cubit.resetCompanyBranding();

        if (!reset) {
          // Every abort path used to just return, so a failed reset looked
          // exactly like a dead button.
          await _showResetError(S.of(context).errorOccurred);
          return false;
        }

        // CHANGED 23/8/2026: the reload lived in `onSuccessComplete`, so the
        // brand only actually changed once the user had dismissed the success
        // dialog — up to then the app was still painted in the old colours and
        // it looked as though Apply was still required. `resetCompanyBranding`
        // has already written the cleared document at this point; this reload
        // is what clears the branding storage keys and re-runs
        // `themeController.updatePrimaryColor/updateSecondaryColor/updateFonts`,
        // which repaint through `Get.forceAppUpdate()`. Doing it here means
        // pressing Yes is the whole action — no Apply click, and the success
        // dialog opens over an already-reset app.
        //
        // `shouldRestart: false` on purpose. It only sets `restartRequested`,
        // which is consumed by a `RestartWidget.restartApp(context)` call — and
        // there is no `RestartWidget` anywhere in this app's tree, so that is a
        // no-op that would leave a one-shot flag set in state with nothing to
        // clear it. The repaint comes from `Get.forceAppUpdate()` instead.
        await _cubit.getCompany(shouldRestart: false);

        // Rebuild this screen immediately so CustomColorPickerSection shows
        // the defaults without the user navigating away and back.
        if (mounted) setState(() {});
        return true;
      },
      successLottie: "assets/lottie_assets/main_lottie_assets/correct.json",
      successTitle: S.of(context).Successful,
      successSubtitle: S.of(context).dataHasBeenSavedSuccessfully,
      // No onSuccessComplete: the reload it used to hold now runs in onConfirm,
      // so the reset is already in force behind this dialog.
    );
  }

  @override
  Widget build(BuildContext context) {
    var isMobile = ContextExtension(context).isPhone;
    final bool lightMode = Theme.of(context).brightness == Brightness.light;
    final bool isVertical = MediaQuery.of(context).orientation == Orientation.portrait;
    final bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    return BlocBuilder<CompanyCubit, CompanyState>(
      builder: (context, state) => Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                // ── Company Image + Reset Button ──────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CompanyImage(onChangedImageUrl: widget.onChangedImageUrl),
                    customButton(
                      title: S.of(context).Reset,
                      function: _resetBranding,
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.text,
                      ),
                      width: 100.w,
                      height: 38,
                      radius: 8.r,
                      // Was a malformed `const Color(0xffCCCCCCCC)` — 10 hex digits, so
                      // the leading alpha byte overflowed and was masked off
                      // (CR-SKEL-SE3-N15).
                      color: AppColors.darkGrey,
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                // ── Color Display Section ─────────────────────────────────
                // Always a real colour — unsaved pick, else the saved company
                // colour, else the theme default the app is currently painting.
                // These were passed through as nullable so a cleared brand fell
                // back to the "Primary Color" / "Secondary Color" hints; that
                // was also reachable on an active company whose colours had been
                // cleared but whose fonts had since been re-applied, where an
                // empty field read as a bug (23/8/2026).
                CustomColorPickerSection(
                  primaryColor: _effectivePrimaryColor(state),
                  secondaryColor: _effectiveSecondaryColor(state),
                  onPrimaryColorSelected: (Color color) {
                    _cubit.setPrimaryColor(color);
                    widget.onChangedPrimaryColor(color);
                  },
                  onSecondaryColorSelected: (Color color) {
                    _cubit.setSecondaryColor(color);
                    widget.onChangedSecondaryColor(color);
                  },
                ),

                SizedBox(height: 20.h),

                // ── Fonts Section ─────────────────────────────────────────
                Text(
                  S.of(context).fonts,
                  style: StyleText.fontSize16Weight500.copyWith(
                    color: AppColors.text,
                  ),
                ),

                SizedBox(height: 12.h),

                buildResponsiveFields(
                  context: context,
                  mobileSpacing: 10,
                  left: CustomDropdown<String>(
                    value: _effectiveEnglishFont(state),
                    items: _convertToDropdownItems(CompanyConstants.englishList),
                    // Pinned to the colour fields' 40 (10 + 20 + 10, all .sp) so
                    // the Fonts and Colors rows are the same height (Settings p.13).
                    height: 40,
                    borderRadius: BorderRadius.circular(4.r),
                    hint: S.of(context).selectEnglishFont,
                    // Same hint treatment CustomTextField uses, so the colour
                    // fields and the font dropdowns read as one set.
                    hintStyle: StyleText.fontSize14Weight400.copyWith(
                      color: AppColors.text.withOpacity(0.4),
                    ),
                    onChanged: (value) {
                      _cubit.setSelectedEnglishFont(value);
                      widget.onChangedFontEnglish(value);
                    },
                  ),
                  right: CustomDropdown<String>(

                    value: _effectiveArabicFont(state),
                    items: _convertToDropdownItems(CompanyConstants.arabicList),
                    // Pinned to the colour fields' 40 (10 + 20 + 10, all .sp) so
                    // the Fonts and Colors rows are the same height (Settings p.13).
                    height: 40,
                    borderRadius: BorderRadius.circular(4.r),
                    hint: S.of(context).selectArabicFont,
                    // Same hint treatment CustomTextField uses, so the colour
                    // fields and the font dropdowns read as one set.
                    hintStyle: StyleText.fontSize14Weight400.copyWith(
                      color: AppColors.text.withOpacity(0.4),
                    ),
                    onChanged: (value) {
                      _cubit.setSelectedArabicFont(value);
                      widget.onChangedFontArabic(value);
                    },
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
