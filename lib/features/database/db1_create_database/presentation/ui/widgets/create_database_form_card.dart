/// Module: database / db1_create_database / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: create_database_form_card.dart
/// Purpose: Declares `CreateDatabaseFormCard`.
/// Author: Knowticed Plus team
/// Created at: 15/8/2026
///
/// The white card: cover picker, bilingual title row, bilingual description
/// blocks, access dropdown. Figma `Rectangle 34625249` — node 7398:6138
/// (landscape) / 7398:6215 (portrait).
///
/// Both orientations share this file. The only thing that moves between them
/// is [CreateDatabaseMetrics]; the two-column title row splits itself via
/// `buildResponsiveFields`, which is the same helper the HR and settings
/// forms use.
///
/// EACH SIDE ACCEPTS ITS OWN SCRIPT ONLY
/// -------------------------------------
/// The card captures both languages at once, so "Arabic Title" and "Title" are
/// two different values rather than a field and its translation. Typing English
/// into the Arabic box therefore does not produce a bilingual record — it
/// produces a record whose Arabic name is in English, which nothing downstream
/// can detect and no reader is served by.
///
/// `restrictByDirection: true` is what enforces it, and it reads the field's
/// `textDirection`: RTL refuses Latin letters, LTR refuses Arabic ones. So the
/// rule is symmetric and the four fields pass no extra argument — the same
/// `direction` that already decides the layout decides the script.
///
/// The two sides are not mirror images in what they catch. The Arabic box
/// refuses Latin LETTERS only — ASCII digits, spaces and punctuation are shared
/// by both scripts, and "قسم المبيعات 2026" is not an English name. The English
/// box refuses the whole Arabic Unicode block, which also takes in Arabic-Indic
/// digits (`٢٠٢٦`); that is intended, since `LocalizedNumber` renders those from
/// ASCII digits at display time, so typing them into stored text is how one
/// record ends up counting in a different script from every other.
///
/// The filter runs on paste as well as on keystrokes, and it refuses the whole
/// paste rather than silently dropping half of it.
///
/// What it does NOT do is lock a field that already holds the wrong script — a
/// draft resumed from before this rule, say. The formatter refuses edits that
/// ADD a foreign letter, not edits that merely leave one there, so such a value
/// can always be corrected or deleted. See `_ScriptInputFormatter` in
/// `core/custom/2-custom_textfield.dart`.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/constants/create_database_constants.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_access_type.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/controller/create_database_cubit.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/create_database_cover_picker.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/create_database_metrics.dart';

class CreateDatabaseFormCard extends StatelessWidget {
  const CreateDatabaseFormCard({
    super.key,
    required this.metrics,
    required this.state,
    required this.cubit,
    required this.titleEnController,
    required this.titleArController,
    required this.descriptionEnController,
    required this.descriptionArController,
  });

  final CreateDatabaseMetrics metrics;
  final CreateDatabaseState state;
  final CreateDatabaseCubit cubit;

  final TextEditingController titleEnController;
  final TextEditingController titleArController;
  final TextEditingController descriptionEnController;
  final TextEditingController descriptionArController;

  /// The grey fill behind every field on the card.
  ///
  /// Not `AppColors.field` — that is white in light mode, which would make
  /// the fields disappear into the white card. This is the light/dark pair
  /// `AppColors` documents for exactly this case: a fill sitting on a card.
  Color get _fieldFill =>
      AppTheme.isDark ? AppColors.colorBlack : AppColors.fieldFillLight;

  /// Figma labels are the small 12/500 token, not CustomTextField's 14/500
  /// default.
  TextStyle get _labelStyle =>
      StyleText.fontSize14Weight500.copyWith(color: AppColors.text);

  TextStyle get _hintStyle =>
      StyleText.fontSize14Weight400.copyWith(color: AppColors.secondaryText);

  @override
  Widget build(BuildContext context) {
    final CreateDatabaseStrings strings = CreateDatabaseStrings.of(context);

    return Container(
      width: double.infinity,
      padding: metrics.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(metrics.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // ── Cover image ───────────────────────────────────────────────────
          CreateDatabaseCoverPicker(
            metrics: metrics,
            imageFile: state.coverImage,
            onPicked: cubit.coverImagePicked,
          ),
          SizedBox(height: metrics.blockGap),

          // ── Title: English | Arabic ───────────────────────────────────────
          // `buildResponsiveFields` puts these side by side above 600px and
          // stacks them below it. Both iPad sizes are above, so both get the
          // row — which is what the Figma shows.
          buildResponsiveFields(
            context: context,
            left: _titleField(
              controller: titleEnController,
              label: strings.databaseTitleEn,
              hint: strings.hintEn,
              direction: TextDirection.ltr,
              errorText: state.visibleTitleEnError,
              onChanged: cubit.titleEnChanged,
            ),
            right: _titleField(
              controller: titleArController,
              label: strings.databaseTitleAr,
              hint: strings.hintAr,
              direction: TextDirection.rtl,
              errorText: state.visibleTitleArError,
              onChanged: cubit.titleArChanged,
            ),
          ),
          SizedBox(height: metrics.blockGap),

          // ── Description: English ──────────────────────────────────────────
          // Stacked rather than side by side because the Figma gives each
          // description the card's full width (835 landscape / 635 portrait).
          _descriptionField(
            controller: descriptionEnController,
            label: strings.descriptionEn,
            hint: strings.hintEn,
            direction: TextDirection.ltr,
            onChanged: cubit.descriptionEnChanged,
          ),
          SizedBox(height: metrics.blockGap),

          // ── Description: Arabic ───────────────────────────────────────────
          _descriptionField(
            controller: descriptionArController,
            label: strings.descriptionAr,
            hint: strings.hintAr,
            direction: TextDirection.rtl,
            onChanged: cubit.descriptionArChanged,
          ),
          SizedBox(height: metrics.blockGap),

          // ── Access management ─────────────────────────────────────────────
          _accessDropdown(context, strings),
        ],
      ),
    );
  }

  // ── Builders ───────────────────────────────────────────────────────────────

  /// One title field. The Arabic side is wrapped in an RTL [Directionality] so
  /// its label right-aligns and its counter mirrors — the same trick the
  /// bilingual settings forms use, rather than hand-placing each piece.
  ///
  /// [direction] decides the script the box accepts as well as its layout —
  /// see the note at the top of this file.
  Widget _titleField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required TextDirection direction,
    required String? errorText,
    required ValueChanged<String> onChanged,
  }) {
    return Directionality(
      textDirection: direction,
      child: CustomTextField(
        controller: controller,
        label: label,
        labelStyle: _labelStyle,
        hint: hint,
        hintStyle: _hintStyle,
        errorText: errorText,
        onChanged: onChanged,
        textDirection: direction,
        // Arabic box takes no Latin letters, English box takes no Arabic ones.
        // Driven by `textDirection` above, so the pair cannot drift apart.
        restrictByDirection: true,
        // The Figma shows no counter under the titles — only under the two
        // descriptions. CustomTextField switches its counter on whenever
        // `maxLength` is set (`showCharCount || maxLength != null`), so
        // `showCharCount: false` alone is not enough: the limit has to be
        // enforced by a formatter instead of by maxLength.
        inputFormatters: <TextInputFormatter>[
          LengthLimitingTextInputFormatter(CreateDatabaseLimits.titleMaxLength),
        ],
        // Raw Figma value, NOT metrics.fieldHeight: CustomTextField documents
        // `height` as "interpreted in .h" and applies `.h` itself, so passing
        // an already-scaled value scales it twice.
        height: CreateDatabaseMetrics.figmaFieldHeight,
        fillColor: _fieldFill,
        showCharCount: false,
        enabled: !state.isSubmitting,
      ),
    );
  }

  /// One description block: label, 72pt box, and the `0 / 500` counter
  /// underneath. The counter, its numerals and its side are all handled by
  /// CustomTextField once `textDirection` is set — an RTL field counts in
  /// Arabic-Indic digits, which is what `٥٠٠/٠` in the Figma is.
  Widget _descriptionField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required TextDirection direction,
    required ValueChanged<String> onChanged,
  }) {
    return Directionality(
      textDirection: direction,
      child: CustomTextField(
        controller: controller,
        label: label,
        labelStyle: _labelStyle,
        hint: hint,
        hintStyle: _hintStyle,
        onChanged: onChanged,
        textDirection: direction,
        // Same script rule as the titles: the Arabic description is an Arabic
        // description, not a second English one.
        restrictByDirection: true,
        maxLines: null,
        minLines: 3,
        maxLength: CreateDatabaseLimits.descriptionMaxLength,
        showCharCount: true,
        height: CreateDatabaseMetrics.figmaDescriptionHeight,
        fillColor: _fieldFill,
        enabled: !state.isSubmitting,
      ),
    );
  }

  /// Access Management. Half-width on both orientations (410 landscape / 310
  /// portrait) — the same width as one title column, so it lines up with the
  /// field above it. `buildResponsiveFields` with an empty right slot is what
  /// produces that without a magic number.
  Widget _accessDropdown(BuildContext context, CreateDatabaseStrings strings) {
    return buildResponsiveFields(
      context: context,
      left: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(strings.accessManagement, style: _labelStyle),
          SizedBox(height: 6.h),
          CustomDropdown<DatabaseAccessType>(
            // Null until the user picks, so the field shows the hint rather
            // than a value nobody chose. The label above already says "Access
            // Management"; repeating it as the hint said nothing, and the old
            // pre-selected "Restricted Access" looked like an answer.
            value: state.accessType,
            hint: strings.selectAccess,
            errorText: state.visibleAccessTypeError,
            fillColor: _fieldFill,
            enabled: !state.isSubmitting,
            valueStyle:
                StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
            itemStyle:
                StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
            hintStyle: _hintStyle,
            items: DatabaseAccessType.values
                .map(
                  (DatabaseAccessType type) => DropdownItem<DatabaseAccessType>(
                    value: type,
                    label: context.isArabic ? type.labelAr : type.labelEn,
                  ),
                )
                .toList(),
            onChanged: cubit.accessTypeChanged,
          ),
        ],
      ),
      // Empty second column keeps the dropdown at half width on tablet and
      // lets it go full width on a narrow window, matching the title row's
      // behaviour instead of contradicting it.
      right: const SizedBox.shrink(),
    );
  }
}
