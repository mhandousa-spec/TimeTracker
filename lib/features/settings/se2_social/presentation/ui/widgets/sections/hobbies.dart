/// Module: settings/se2_social
///
///*************************** FILE INFO ****************************///
/// File Name: hobbies.dart
/// Purpose: The Hobbies card of the social settings page.
/// Author: Amr Mesbah
/// Created at: 13/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SE2-N04/N05/N07/N16/N17: blanket
///          `ignore_for_file` and REMOVED_MODULE comments removed; the
///          TextEditingControllers live here rather than on SocialController;
///          the try/catch around the list-growing loop is gone with the loop it
///          guarded; the hardcoded Arabic hint now comes from the l10n bundle;
///          raw colours and the inline TextStyle route through the theme.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/ui/widgets/settings_header.dart';
import 'package:knowticed_plus/features/settings/se2_social/presentation/ui/widgets/add_more_button.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class Hobbies extends StatefulWidget {
  const Hobbies({
    super.key,
    required this.hobbies,
    required this.onHobbyChanged,
    required this.onAdd,
    required this.onRemove,
  });

  /// The current hobbies, straight from the cubit's draft.
  final List<String> hobbies;

  final void Function(int index, String value) onHobbyChanged;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  State<Hobbies> createState() => _HobbiesState();
}

class _HobbiesState extends State<Hobbies> {
  final HapticController _hapticController = Get.find<HapticController>();

  /// One controller per row, owned here (§16).
  final List<TextEditingController> _controllers = <TextEditingController>[];

  @override
  void initState() {
    super.initState();
    _syncControllers();
  }

  @override
  void didUpdateWidget(covariant Hobbies oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncControllers();
  }

  /// Grows, shrinks and re-seeds the controller list to match the draft. The
  /// old `while (hobbiess.length <= index) hobbiess.add('')` loop — and the
  /// try/catch wrapped around it — existed because the value list and the
  /// controller list could fall out of step; they cannot now.
  void _syncControllers() {
    while (_controllers.length < widget.hobbies.length) {
      _controllers.add(TextEditingController());
    }
    while (_controllers.length > widget.hobbies.length) {
      _controllers.removeLast().dispose();
    }
    for (int i = 0; i < widget.hobbies.length; i++) {
      if (_controllers[i].text != widget.hobbies[i]) {
        _controllers[i].text = widget.hobbies[i];
      }
    }
  }

  @override
  void dispose() {
    for (final TextEditingController controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addHobby() {
    _hapticController.triggerHapticFeedback(
      vibration: VibrateType.lightImpact,
      hapticFeedback: HapticFeedback.lightImpact,
    );
    widget.onAdd();
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final bool isTablet = MediaQuery.of(context).size.width > 600;
    final bool lightMode = Theme.of(context).brightness == Brightness.light;
    final bool isMobile = ContextExtension(context).isPhone;

    return Container(
      decoration: !isTablet
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.card,
            )
          : null,
      padding: EdgeInsets.only(
        top: 15.sp,
        right: 0.sp,
        left: 0.sp,
        bottom: isMobile ? 15.sp : 0.sp,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SettingsHeader(
            imagePath:
                'assets/icons_assets/settings_assets/hobbies_interests.svg',
            text: FormatHelper.capitalize(S.of(context).hobbies),
          ),
          SizedBox(height: 10.sp),

          // Two per row on tablet/desktop, one per row on phones.
          _hobbiesGrid(context, lightMode, isArabic),

          SizedBox(height: 10.sp),
          AddMoreButton(onPressed: _addHobby),
          SizedBox(height: ContextExtension(context).isPhone ? 0.sp : 10.sp),
        ],
      ),
    );
  }

  Widget _hobbiesGrid(BuildContext context, bool lightMode, bool isArabic) {
    final int count = widget.hobbies.length;
    final bool isPhone = ContextExtension(context).isPhone;
    final double gap = 10.sp;

    if (isPhone) {
      return Column(
        children: <Widget>[
          for (int i = 0; i < count; i++) ...<Widget>[
            _hobbyRow(context, i, lightMode, isArabic),
            if (i != count - 1) SizedBox(height: gap),
          ],
        ],
      );
    }

    final List<Widget> rows = <Widget>[];
    for (int i = 0; i < count; i += 2) {
      final bool hasSecond = i + 1 < count;
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(child: _hobbyRow(context, i, lightMode, isArabic)),
            SizedBox(width: 20.sp),
            Expanded(
              child: hasSecond
                  ? _hobbyRow(context, i + 1, lightMode, isArabic)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      );
      if (i + 2 < count) rows.add(SizedBox(height: gap));
    }

    return Column(children: rows);
  }

  /// One hobby field plus its delete button.
  Widget _hobbyRow(
      BuildContext context, int index, bool lightMode, bool isArabic) {
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: ContextExtension(context).isPhone ? 15.sp : 0.sp),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: CustomTextField(
              key: ValueKey<String>('hobby_$index'),
              hint: FormatHelper.capitalize(S.of(context).enterHobby),
              controller: _controllers[index],
              maxLines: 1,
              // Cap the length with a formatter rather than maxLength: the
              // counter row maxLength adds would push the centred delete icon
              // below the box's midpoint.
              inputFormatters: <TextInputFormatter>[
                LengthLimitingTextInputFormatter(100),
              ],
              enabled: true,
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              textAlign: TextAlign.start,
              onChanged: (String value) =>
                  widget.onHobbyChanged(index, value.trim()),
              fillColor:
                  lightMode ? AppColors.fieldFillLight : AppColors.colorBlack,
            ),
          ),
          SizedBox(width: 8.sp),
          if (widget.hobbies.length > 1)
            InkWell(
              onTap: () => widget.onRemove(index),
              child: Container(
                padding: EdgeInsets.all(6.sp),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: CustomSvgImage(
                  assetPath:
                      'assets/icons_assets/main_icons_assets/cancel_minus_circle.svg',
                  width: 15.sp,
                  fit: BoxFit.fill,
                  height: 15.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
