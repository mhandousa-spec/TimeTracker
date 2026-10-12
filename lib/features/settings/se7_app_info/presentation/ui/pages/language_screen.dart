// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api
/// Module: Settings · App Info · Language picker
/// Description: Two-column grid of languages. Shipped languages are selectable
///              radio tiles; the rest are dimmed and carry a "SOON!" badge
///              (soon_light.svg / soon_dark.svg depending on the theme).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/app_locale.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/theme/theme_controller.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/ui/widgets/settings_header.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/domain/enums/languages.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// One row in the picker.
class _LanguageOption {
  final Languages language;
  final String label;

  /// false → dimmed tile with the SOON badge, tap does nothing.
  final bool isAvailable;

  const _LanguageOption({
    required this.language,
    required this.label,
    required this.isAvailable,
  });
}

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({Key? key});

  @override
  _LanguageScreenState createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  Languages? selectedLanguage = Languages.english;
  final HapticController hapticController = Get.put(HapticController());

  @override
  void initState() {
    super.initState();
    // CHANGED: was an inline `box.read<String>('LocaleData')`. AppLocale owns
    // that key now, and it applies the device-language fallback the inline
    // read did not: on a fresh install `box.read` returns null, and
    // `null.toString()` is the literal string "null", which does not contain
    // "ar" — so the tile showed English even when the app had booted into
    // Arabic from the device locale.
    selectedLanguage =
        AppLocale.isArabic ? Languages.arabic : Languages.english;
  }

  /// English and Arabic ship today. Flip `isAvailable` here when a new
  /// localisation lands — the tile becomes selectable and loses the badge.
  List<_LanguageOption> _options(BuildContext context) => [
        _LanguageOption(
          language: Languages.english,
          label: S.of(context).english,
          isAvailable: true,
        ),
        _LanguageOption(
          language: Languages.arabic,
          label: S.of(context).arabic,
          isAvailable: true,
        ),
        _LanguageOption(
          language: Languages.hindi,
          label: S.of(context).hindi,
          isAvailable: false,
        ),
        _LanguageOption(
          language: Languages.turkish,
          label: S.of(context).turkish,
          isAvailable: false,
        ),
        _LanguageOption(
          language: Languages.mandarin,
          label: S.of(context).mandarinChinese,
          isAvailable: false,
        ),
      ];

  void toggleLangSwitch(Languages language) {
    setState(() {
      selectedLanguage = language;
    });
    // CHANGED: this used to call `Get.updateLocale` and write the storage key
    // itself, but never `S.load` or `Intl.defaultLocale`. Those got updated
    // only as a side effect of the S delegate reloading, and with a DIFFERENT
    // tag than the one main() used at boot ('ar_SA' here vs 'ar_EG' from
    // MyApp) — so date and number formatting depended on whether you had
    // switched into Arabic or started up in it. AppLocale.apply does all four
    // in one place, with one tag.
    AppLocale.apply(
      language == Languages.arabic ? AppLocale.arabic : AppLocale.english,
    );
    themeController.updateFonts();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    final bool lightMode = Theme.of(context).brightness == Brightness.light;

    return isTablet
        ? _buildTabletView(context, lightMode)
        : _buildMobileView(context, lightMode);
  }

  Widget _buildMobileView(BuildContext context, bool lightMode) {
    // SideFrameMasterServices supplies the mobile Scaffold, the breadcrumb
    // header (back chevron + page title), the scroll view and the 15.sp
    // horizontal padding, so this method only provides the page body.
    return SideFrameMasterServices(
      titleText: S.of(context).settings,
      onFirstTap: () => Navigator.of(context).maybePop(),
      secondTitle: S.of(context).language,
      child: _languageCard(context, lightMode),
    );
  }

  Widget _buildTabletView(BuildContext context, bool lightMode) {
    return SingleChildScrollView(
      child: _languageCard(context, lightMode),
    );
  }

  // ── Card ───────────────────────────────────────────────────────────────────

  Widget _languageCard(BuildContext context, bool lightMode) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 15.sp),

          Padding(
            padding:  EdgeInsets.symmetric(horizontal: 14.sp),
            child: SettingsHeader(
              imagePath:
                  'assets/icons_assets/settings_assets/language_translate_bubbles.svg',
              text: S.of(context).language,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(15.sp),
            child: _optionsGrid(context, lightMode),
          ),
        ],
      ),
    );
  }

  /// Two tiles per row on tablet/desktop, one per row on phones. An odd last
  /// tile keeps its half width rather than stretching across the row.
  Widget _optionsGrid(BuildContext context, bool lightMode) {
    final options = _options(context);
    final isPhone = ContextExtension(context).isPhone;
    final gap = 12.w;

    if (isPhone) {
      return Column(
        children: [
          for (int i = 0; i < options.length; i++) ...[
            _langTile(context, options[i], lightMode),
            if (i != options.length - 1) SizedBox(height: gap),
          ],
        ],
      );
    }

    final rows = <Widget>[];
    for (int i = 0; i < options.length; i += 2) {
      final hasSecond = i + 1 < options.length;
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _langTile(context, options[i], lightMode)),
            SizedBox(width: gap),
            Expanded(
              child: hasSecond
                  ? _langTile(context, options[i + 1], lightMode)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      );
      if (i + 2 < options.length) rows.add(SizedBox(height: gap));
    }

    return Column(children: rows);
  }

  // ── Tile ───────────────────────────────────────────────────────────────────

  Widget _langTile(
    BuildContext context,
    _LanguageOption option,
    bool lightMode,
  ) {
    final bool selected =
        option.isAvailable && selectedLanguage == option.language;

    return GestureDetector(
      onTap: option.isAvailable ? () => toggleLangSwitch(option.language) : null,
      child: MouseRegion(
        cursor: option.isAvailable
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: Container(
          height: 52.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Row(
            children: [
              _radio(selected: selected, enabled: option.isAvailable),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  option.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: StyleText.fontSize16Weight400.copyWith(
                    color: option.isAvailable
                        ? AppColors.text
                        : AppColors.secondaryText,
                  ),
                ),
              ),
              if (!option.isAvailable) ...[
                SizedBox(width: 8.w),
                SvgPicture.asset(
                  lightMode
                      ? 'assets/icons_assets/settings_assets/soon_light.svg'
                      : 'assets/icons_assets/settings_assets/soon_dark.svg',
                  height: 30.sp,
                  width: 30.sp,
                  fit: BoxFit.contain,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _radio({required bool selected, required bool enabled}) {
    final Color ringColor = selected
        ? AppColors.primary
        : AppColors.secondaryText.withOpacity(enabled ? 0.6 : 0.35);

    return Container(
      width: 18.sp,
      height: 18.sp,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ringColor, width: 1.5),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 9.sp,
                height: 9.sp,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
              ),
            )
          : null,
    );
  }
}
