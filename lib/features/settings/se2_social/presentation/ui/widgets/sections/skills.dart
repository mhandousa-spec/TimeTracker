/// Module: settings/se2_social
///
///*************************** FILE INFO ****************************///
/// File Name: skills.dart
/// Purpose: The Skills card of the social settings page — one field per skill,
///          two per row on tablet, plus add and delete.
/// Author: Amr Mesbah
/// Created at: 13/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SE2-N04/N05/N07/N16/N17/N18: the blanket
///          `ignore_for_file` and the commented REMOVED_MODULE imports are
///          gone; the TextEditingControllers live here rather than on
///          SocialController; the widget no longer writes into three of the
///          controller's internal lists on every keystroke; raw colours and the
///          inline TextStyle route through the theme.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/ui/widgets/settings_header.dart';
import 'package:knowticed_plus/features/settings/se2_social/domain/entities/skill_entry.dart';
import 'package:knowticed_plus/features/settings/se2_social/presentation/ui/widgets/add_more_button.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class Skills extends StatefulWidget {
  const Skills({
    super.key,
    required this.skills,
    required this.onSkillChanged,
    required this.onAdd,
    required this.onRemove,
  });

  /// The current skills, straight from the cubit's draft.
  final List<SkillEntry> skills;

  final void Function(int index, SkillEntry entry) onSkillChanged;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  State<Skills> createState() => _SkillsState();
}

class _SkillsState extends State<Skills> {
  /// One controller per row, owned here (§16). Was
  /// `SocialController.skillsControllers` — one of three parallel structures
  /// the UI had to keep in step by hand.
  final List<TextEditingController> _controllers = <TextEditingController>[];

  @override
  void initState() {
    super.initState();
    _syncControllers();
  }

  @override
  void didUpdateWidget(covariant Skills oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncControllers();
  }

  /// Grows, shrinks and re-seeds the controller list to match the draft.
  /// Text is only overwritten when it actually differs, so typing is not
  /// interrupted by the rebuild an add or remove triggers.
  void _syncControllers() {
    while (_controllers.length < widget.skills.length) {
      _controllers.add(TextEditingController());
    }
    while (_controllers.length > widget.skills.length) {
      _controllers.removeLast().dispose();
    }
    for (int i = 0; i < widget.skills.length; i++) {
      final String value = widget.skills[i].name;
      if (_controllers[i].text != value) _controllers[i].text = value;
    }
  }

  @override
  void dispose() {
    for (final TextEditingController controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
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
                'assets/icons_assets/settings_assets/brain_lightbulb_skills.svg',
            text: FormatHelper.capitalize(S.of(context).skills),
          ),
          SizedBox(height: 10.sp),

          // Two per row on tablet/desktop, one per row on phones. The old
          // fixed 270.w column meant a single narrow list no matter how much
          // width was available.
          _skillsGrid(context, lightMode, isArabic),

          SizedBox(height: 10.sp),
          AddMoreButton(onPressed: widget.onAdd),
        ],
      ),
    );
  }

  Widget _skillsGrid(BuildContext context, bool lightMode, bool isArabic) {
    final int count = widget.skills.length;
    final bool isPhone = ContextExtension(context).isPhone;
    final double gap = 10.sp;

    if (isPhone) {
      return Column(
        children: <Widget>[
          for (int i = 0; i < count; i++) ...<Widget>[
            _skillRow(context, i, lightMode, isArabic),
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
            Expanded(child: _skillRow(context, i, lightMode, isArabic)),
            SizedBox(width: 20.sp),
            Expanded(
              child: hasSecond
                  ? _skillRow(context, i + 1, lightMode, isArabic)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      );
      if (i + 2 < count) rows.add(SizedBox(height: gap));
    }

    return Column(children: rows);
  }

  /// One skill field plus its delete button.
  Widget _skillRow(
      BuildContext context, int index, bool lightMode, bool isArabic) {
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: context.isPhone ?  15.sp : 0.sp),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: CustomTextField(
              // Keyed per row so a deletion above does not carry the wrong field
              // state down the list.
              key: ValueKey<String>('skill_$index'),
              hint: FormatHelper.capitalize(S.of(context).enterSkill),
              controller: _controllers[index],
              maxLines: 1,
              // Cap the length with a formatter rather than maxLength:
              // CustomTextField renders a "0 / 100" counter row under the box
              // whenever maxLength is set, which makes the field taller than the
              // box and pushes the centred delete icon below the box's midpoint.
              inputFormatters: <TextInputFormatter>[
                LengthLimitingTextInputFormatter(100),
              ],
              enabled: true,
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              textAlign: TextAlign.start,
              onChanged: (String value) => widget.onSkillChanged(
                index,
                widget.skills[index].copyWith(name: value.trim()),
              ),
              fillColor:
                  lightMode ? AppColors.fieldFillLight : AppColors.colorBlack,
            ),
          ),
          SizedBox(width: 8.sp),
          if (widget.skills.length > 1)
            InkWell(
              onTap: () => widget.onRemove(index),
              child: Container(
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
