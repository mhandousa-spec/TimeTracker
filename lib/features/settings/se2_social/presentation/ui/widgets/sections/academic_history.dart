/// Module: settings/se2_social
///
///*************************** FILE INFO ****************************///
/// File Name: academic_history.dart
/// Purpose: The Academic History card — degree, university and graduation year
///          per record, stacked, with add and delete.
/// Author: Amr Mesbah
/// Created at: 13/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SE2-N04/N05/N07/N17: blanket `ignore_for_file`
///          and the five REMOVED_MODULE comments removed; the university
///          TextEditingControllers live here rather than on SocialController;
///          `MediaQuery.of(Get.context!)` — read once at field-initializer time,
///          so it never updated on rotation — replaced with the build context;
///          the dead `_updateAcademicField` (an empty if-body that pretended to
///          write) is gone; the hardcoded Arabic hint comes from l10n.
/// Updated: 8/9/2026 - the red trash button (and its tablet minus-circle
///          sibling) that sat on a row of its own above the fields is replaced
///          by one minus-circle icon on the "Graduation From" title line, the
///          way Skills and Hobbies remove a row.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/custom/3-custom_dropdwon_calander.dart';
import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/ui/widgets/settings_header.dart';
import 'package:knowticed_plus/features/settings/se2_social/domain/entities/academic_entry.dart';
import 'package:knowticed_plus/features/settings/se2_social/presentation/ui/widgets/add_more_button.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class AcademicHistory extends StatefulWidget {
  const AcademicHistory({
    super.key,
    required this.entries,
    required this.onEntryChanged,
    required this.onAdd,
    required this.onRemove,
  });

  /// The current records, straight from the cubit's draft.
  final List<AcademicEntry> entries;

  final void Function(int index, AcademicEntry entry) onEntryChanged;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  State<AcademicHistory> createState() => _AcademicHistoryState();
}

class _AcademicHistoryState extends State<AcademicHistory> {
  final HapticController _hapticController = Get.find<HapticController>();

  /// The degree keys as persisted. Kept untranslated on purpose — the label is
  /// looked up per locale in [_degreeItems].
  static const List<String> _degreeKeys = <String>[
    'bachelor',
    'master',
    'phd',
    'diploma',
    'certificate',
  ];

  /// One university controller per record, owned here (§16).
  final List<TextEditingController> _universityControllers =
      <TextEditingController>[];

  @override
  void initState() {
    super.initState();
    _syncControllers();
  }

  @override
  void didUpdateWidget(covariant AcademicHistory oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncControllers();
  }

  void _syncControllers() {
    while (_universityControllers.length < widget.entries.length) {
      _universityControllers.add(TextEditingController());
    }
    while (_universityControllers.length > widget.entries.length) {
      _universityControllers.removeLast().dispose();
    }
    for (int i = 0; i < widget.entries.length; i++) {
      // Capitalized at seed time. The old widget did this in a post-frame
      // callback that mutated the controller and called setState.
      final String value = widget.entries[i].university.isEmpty
          ? ''
          : FormatHelper.capitalize(widget.entries[i].university);
      if (_universityControllers[i].text.trim() !=
          widget.entries[i].university.trim()) {
        _universityControllers[i].text = value;
      }
    }
  }

  @override
  void dispose() {
    for (final TextEditingController controller in _universityControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addEntry() {
    _hapticController.triggerHapticFeedback(
      vibration: VibrateType.lightImpact,
      hapticFeedback: HapticFeedback.lightImpact,
    );
    widget.onAdd();
  }

  /// Degree options. Labels come from the l10n bundle rather than inline
  /// ternaries, so the strings live in intl_en.arb / intl_ar.arb like the rest
  /// of the app.
  List<DropdownItem<String>> _degreeItems(BuildContext context) {
    final Map<String, String> labels = <String, String>{
      'bachelor': S.of(context).bachelorDegree,
      'master': S.of(context).masterDegree,
      'phd': S.of(context).phdDegree,
      'diploma': S.of(context).diploma,
      'certificate': S.of(context).certificate,
    };

    return _degreeKeys
        .map((String key) => DropdownItem<String>(
              value: key,
              label: FormatHelper.capitalize(labels[key]!),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ContextExtension(context).isPhone;
    final bool isTablet = MediaQuery.of(context).size.width > 600;
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      decoration: !isTablet
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
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
                'assets/icons_assets/settings_assets/academic_history_graduation.svg',
            text: FormatHelper.capitalize(S.of(context).academicHistory),
          ),
          SizedBox(height: 10.sp),

          // Every entry, stacked. This used to render only the LAST entry,
          // which is why "More" looked like it wiped the form: it appended a
          // blank entry and the filled one it replaced stopped being drawn.
          for (int i = 0; i < widget.entries.length; i++) ...<Widget>[
            if (i != 0) SizedBox(height: 20.sp),
            _buildEntry(context, i, isArabic),
          ],

          SizedBox(height: 15.sp),
          AddMoreButton(onPressed: _addEntry),
        ],
      ),
    );
  }

  /// One academic record: degree + university on the first row, graduation
  /// year on the second.
  Widget _buildEntry(BuildContext context, int index, bool isArabic) {
    final AcademicEntry entry = widget.entries[index];
    final bool isValidDegree = _degreeKeys.contains(entry.degree);

    // The first record is the employee's primary one and is always present —
    // only the extra records added with "More" can be removed.
    final bool canDelete = index > 0;

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: ContextExtension(context).isPhone ? 15.sp : 0.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // CHANGED 8/9/2026 — the remove affordance used to be a right-aligned
          // row of its own above the fields: a red 38×38 trash button on
          // phones, a minus-circle InkWell elsewhere. It is now the same
          // minus-circle icon Skills and Hobbies use, sitting on the SAME LINE
          // as the "Graduation From" title, so an extra academic record is
          // removed exactly the way an extra skill or hobby is.
          //
          // The title therefore has to be drawn here rather than handed to
          // CustomDropdown's `label:` — it is a Row now, not a string. Same
          // 14.sp/weight-500 text and the same [kFieldLabelGap] the dropdown
          // and the text field apply to their own labels, so the two fields on
          // this row still start at the same height.
          SizedBox(height: ContextExtension(context).isPhone ? 0.sp : 12.sp),

          // First row: degree + university.
          buildResponsiveFields(
            context: context,
            left: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      FormatHelper.capitalize(S.of(context).graduationFrom),
                      style: StyleText.fontSize14Weight500
                          .copyWith(color: AppColors.text),
                    ),
                    Spacer(),
                    if (canDelete) ...<Widget>[
                      SizedBox(width: 8.sp),
                      InkWell(
                        onTap: () => widget.onRemove(index),
                        child: CustomSvgImage(
                          assetPath:
                              'assets/icons_assets/main_icons_assets/cancel_minus_circle.svg',
                          width: 15.sp,
                          fit: BoxFit.fill,
                          height: 15.sp,
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: kFieldLabelGap.sp),
                CustomDropdown<String>(
                  value: isValidDegree ? entry.degree : null,
                  items: _degreeItems(context),
                  onChanged: (String value) => widget.onEntryChanged(
                      index, entry.copyWith(degree: value)),
                  // HEIGHT 21/9/2026 (Settings bug report p.15): one height for the row.
                  height: 40,
                  hint: FormatHelper.capitalize(S.of(context).chooseDegree),
                  hintStyle: StyleText.fontSize10Weight500.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
            // CHANGED 21/9/2026 — the title is drawn here, the same way as
            // "Graduation From" on the left, instead of by CustomTextField's
            // `label:`. The field draws its label with RichText and the left
            // column uses Text; the two lay out a few px apart, which put the
            // university box visibly lower than the degree dropdown. Same
            // widget + same [kFieldLabelGap] on both sides = same top edge.
            right: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      FormatHelper.capitalize(
                          S.of(context).universityOrInstitute),
                      style: StyleText.fontSize14Weight500
                          .copyWith(color: AppColors.text),
                    ),
                    // Matches the remove icon's slot on the left so both
                    // title rows are exactly the same height.
                    SizedBox(height: 15.sp),
                  ],
                ),
                SizedBox(height: kFieldLabelGap.sp),
                CustomTextField(
              // Keyed per entry so each record keeps its own field state when
              // one is inserted or removed above it.
              key: ValueKey<String>('academic_university_$index'),
              // HEIGHT 21/9/2026 (Settings bug report p.15): one height for the row.
              height: 40,
              hint: FormatHelper.capitalize(S.of(context).textHere),
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              controller: _universityControllers[index],
              onChanged: (String value) => widget.onEntryChanged(
                index,
                entry.copyWith(university: value.trim()),
              ),
            ),
              ],
            ),
          ),

          SizedBox(height: 12.sp),

          // Second row: graduation year.
          buildResponsiveFields(
            context: context,
            left: CustomDropdownCalendar(
              value: entry.graduationYear.isEmpty
                  ? null
                  : DateTime(int.tryParse(entry.graduationYear) ??
                      DateTime.now().year),
              firstDate: DateTime(DateTime.now().year - 49),
              lastDate: DateTime(DateTime.now().year, 12, 31),
              dateFormatter: (DateTime d) => d.year.toString(),
              onChanged: (DateTime? value) => widget.onEntryChanged(
                index,
                entry.copyWith(graduationYear: value?.year.toString() ?? ''),
              ),
              label: FormatHelper.capitalize(S.of(context).graduationYear),
              // HEIGHT 21/9/2026 (Settings bug report p.15): one height for the row.
              height: 40,
              hint: FormatHelper.capitalize(S.of(context).selectdate),
              hintStyle: StyleText.fontSize10Weight500.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
            right: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
