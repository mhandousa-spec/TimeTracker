/// Module: settings/se2_social
///
///*************************** FILE INFO ****************************///
/// File Name: bio.dart
/// Purpose: The Bio card of the social settings page.
/// Author: Amr Mesbah
/// Created at: 13/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SE2-N05/N07/N19: the TextEditingController is
///          owned by this State instead of by SocialController, which also
///          fixes the listener that was attached to a controller-owned field
///          and never removed; the unused `isDesktop` / `isPortrait` /
///          `lightMode` locals and the commented REMOVED_MODULE imports are
///          gone.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/ui/widgets/settings_header.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class Bio extends StatefulWidget {
  const Bio({
    super.key,
    required this.bio,
    required this.onChanged,
  });

  /// The stored bio. Comes down from the page's `BlocBuilder`, so a reload
  /// after saving re-seeds the field; it is not read from a global.
  final String bio;

  final ValueChanged<String> onChanged;

  @override
  State<Bio> createState() => _BioState();
}

class _BioState extends State<Bio> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // Capitalized once, at seed time. The old widget did this in a post-frame
    // callback and then called setState, so every open cost an extra rebuild.
    _controller = TextEditingController(text: _seed(widget.bio));
  }

  static String _seed(String value) =>
      value.isEmpty ? '' : FormatHelper.capitalize(value);

  @override
  void didUpdateWidget(covariant Bio oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only re-seed when the *stored* value changed — i.e. after a save. Doing
    // it on every rebuild would fight the user's cursor.
    if (oldWidget.bio != widget.bio && _controller.text.trim() != widget.bio.trim()) {
      _controller.text = _seed(widget.bio);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final bool isTablet = MediaQuery.of(context).size.width > 600;
    final bool isMobile = ContextExtension(context).isPhone;

    return Container(
      decoration: !isTablet
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: AppColors.card,
            )
          : null,
      // Mobile only: no horizontal padding on the CARD, because SettingsHeader
      // already applies 15.sp of its own on phone — the two stacked, so the
      // Bio icon sat at 30.sp while its field sat at 15.sp. Each child is
      // padded instead, which is what academic_history.dart does.
      padding: EdgeInsets.only(
        top: 15.sp,
        right: isMobile ? 0.sp : 15.sp,
        left: isMobile ? 0.sp : 15.sp,
        bottom: isMobile ? 15.sp : 0.sp,
      ),
      child: Column(
        children: <Widget>[
          SettingsHeader(
            imagePath:
                'assets/icons_assets/settings_assets/bio_person_spotlight.svg',
            text: FormatHelper.capitalize(S.of(context).bio),
          ),
          SizedBox(height: isMobile ? 15.sp : 15.h),
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: isMobile ? 15.sp : 0.sp),
            child: CustomTextField(
              hint: FormatHelper.capitalize(
                  S.of(context).shareSomethingAboutYourself),
              controller: _controller,
              maxLines: 3,
              maxLength: 500,
              enabled: true,
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              textAlign: TextAlign.start,
              onChanged: widget.onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
