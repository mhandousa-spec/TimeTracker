/// Module: database / db2_database_details / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: edit_database_page.dart
/// Purpose: Declares `EditDatabasePage`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
///
/// "Editing Database Name" — Figma 7398:6461 (iPad V, 1024 x 782) /
/// 7398:16968 (iPad H, 768 x 782).
///
/// The create card minus the access dropdown, plus a Discard/Save footer and
/// the confirm → success pair the Figma attaches to every edit path
/// (Frames 1597883137 "Are You Sure You Want To Edit This Database?" and
/// 1597883138 "You Successfully Edited This Database").
///
/// WHY THE CARD IS REBUILT HERE INSTEAD OF REUSING db1's
/// ----------------------------------------------------
/// `CreateDatabaseFormCard` is bound to `CreateDatabaseCubit` — it reads
/// `state.visibleAccessTypeError`, calls `cubit.accessTypeChanged`, and draws
/// the access dropdown this screen must not have. Making it serve both would
/// mean a flags-and-nullable-callbacks widget where every field is optional,
/// and the create screen would start carrying the edit screen's branches.
///
/// What IS shared is everything that decides how it looks:
/// `CreateDatabaseMetrics` (padding, field heights, button width),
/// `buildResponsiveFields` (the two-column title row that stacks below 600px)
/// and `CustomTextField`. So the two cards cannot drift on spacing or on
/// typography — only on which fields they contain, which is the actual
/// difference.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/11-custom_confirm_diaolog.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/constants/create_database_constants.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/create_database_actions.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/create_database_metrics.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/constants/database_details_constants.dart';
import 'package:knowticed_plus/features/database/db2_database_details/presentation/controller/edit_database_cubit.dart';

class EditDatabasePage extends StatefulWidget {
  const EditDatabasePage({super.key, required this.database});

  final DatabaseEntity database;

  /// Opens the screen and resolves with the SAVED record, or null when the
  /// user left without saving. The details page swaps its copy for whatever
  /// comes back, so a rename is on screen the instant this closes.
  static Future<DatabaseEntity?> open(
    BuildContext context, {
    required DatabaseEntity database,
  }) {
    return Navigator.of(context).push<DatabaseEntity>(
      MaterialPageRoute<DatabaseEntity>(
        builder: (_) => EditDatabasePage(database: database),
      ),
    );
  }

  @override
  State<EditDatabasePage> createState() => _EditDatabasePageState();
}

class _EditDatabasePageState extends State<EditDatabasePage> {
  late final EditDatabaseCubit _cubit =
      EditDatabaseCubit(database: widget.database);

  // Seeded from the record, not empty. `CustomTextField` is uncontrolled once
  // it is built, so "Discard Changes" has to push the original text back into
  // these as well as into the cubit — see [_onDiscard].
  late final TextEditingController _titleEn =
      TextEditingController(text: widget.database.titleEn);
  late final TextEditingController _titleAr =
      TextEditingController(text: widget.database.titleAr);
  late final TextEditingController _descriptionEn =
      TextEditingController(text: widget.database.descriptionEn);
  late final TextEditingController _descriptionAr =
      TextEditingController(text: widget.database.descriptionAr);

  @override
  void dispose() {
    _titleEn.dispose();
    _titleAr.dispose();
    _descriptionEn.dispose();
    _descriptionAr.dispose();
    _cubit.close();
    super.dispose();
  }

  // ── Leaving ──────────────────────────────────────────────────────────────

  /// Back / breadcrumb. Warns only when something was actually changed —
  /// `EditDatabaseState.isDirty` compares against the record as LOADED, so a
  /// form that was opened and closed does not accuse the user of losing work
  /// they never did.
  Future<void> _onLeave() async {
    if (!_cubit.state.isDirty) {
      Navigator.of(context).pop();
      return;
    }

    final DatabaseDetailsStrings strings = DatabaseDetailsStrings.of(context);

    bool confirmed = false;
    await showConfirmDialog(
      context: context,
      title: strings.discardConfirmTitle,
      subtitle: strings.discardConfirmSubtitle,
      confirmLabel: strings.yes,
      cancelLabel: strings.no,
      onConfirm: () => confirmed = true,
    );
    if (!confirmed || !mounted) return;

    Navigator.of(context).pop();
  }

  /// "Discard Changes" — put the form back to the loaded record and stay.
  ///
  /// It does NOT leave the screen. The Figma pairs it with Save on the same
  /// row, which makes it the undo for this form; a button that quietly
  /// navigated away would be a second Back with a different name.
  void _onDiscard() {
    _cubit.discard();

    final DatabaseEntity original = _cubit.state.original;
    _titleEn.text = original.titleEn;
    _titleAr.text = original.titleAr;
    _descriptionEn.text = original.descriptionEn;
    _descriptionAr.text = original.descriptionAr;
  }

  // ── Saving ───────────────────────────────────────────────────────────────

  Future<void> _onSave() async {
    final DatabaseDetailsStrings strings = DatabaseDetailsStrings.of(context);

    // Saving a form nobody touched would write `updated_at` and put a "Last
    // Edit" date on a record that was not edited — a false audit trail
    // produced by tapping the wrong button.
    if (!_cubit.state.isDirty) {
      await showWarningDialog(
        context: context,
        title: strings.nothingChangedTitle,
        subtitle: strings.nothingChanged,
        closeLabel: strings.close,
      );
      return;
    }

    await showConfirmDialog(
      context: context,
      title: strings.editConfirmTitle,
      subtitle: strings.editConfirmSubtitle,
      confirmLabel: strings.yes,
      cancelLabel: strings.no,
      onConfirm: () {
        _cubit.save(
          requiredEnMessage: strings.titleEnRequired,
          requiredArMessage: strings.titleArRequired,
          tooShortMessage:
              strings.titleTooShort(CreateDatabaseLimits.titleMinLength),
          duplicateMessage: strings.duplicateTitle,
        );
      },
    );
  }

  /// Reports the write once and then clears the flag, so a rebuild cannot
  /// re-open either dialog.
  Future<void> _onStateChanged(
    BuildContext context,
    EditDatabaseState state,
  ) async {
    final DatabaseDetailsStrings strings = DatabaseDetailsStrings.of(context);

    if (state.status == EditDatabaseStatus.failure &&
        state.errorMessage != null) {
      // Cleared BEFORE the await: leaving the failure live while the dialog is
      // open re-opens it on the next emission.
      final String message = state.errorMessage!;
      _cubit.clearMessages();
      await showErrorDialog(
        context: context,
        title: strings.errorTitle,
        subtitle: message,
        closeLabel: strings.close,
      );
      return;
    }

    if (state.status == EditDatabaseStatus.success) {
      await showSuccessDialog(
        context: context,
        title: strings.editConfirmTitle,
        subtitle: strings.editSuccessSubtitle,
        closeLabel: strings.close,
      );
      if (!mounted) return;
      Navigator.of(context).pop(state.savedDatabase);
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final DatabaseDetailsStrings strings = DatabaseDetailsStrings.of(context);
    final CreateDatabaseMetrics metrics = CreateDatabaseMetrics.of(context);
    final String title =
        FormatHelper.capitalize(
            widget.database.localizedTitle(isArabic: context.isArabic));

    return BlocConsumer<EditDatabaseCubit, EditDatabaseState>(
      bloc: _cubit,
      listener: _onStateChanged,
      builder: (BuildContext context, EditDatabaseState state) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, Object? result) {
            if (didPop) return;
            _onLeave();
          },
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: SideFrameMasterServices(
              titleText: strings.database,
              secondTitle: strings.editingCrumb(title),
              onFirstTap: _onLeave,
              // SideFrameMasterServices hands its child a BOUNDED height on
              // tablet, so a fixed Column overflows the moment the two
              // description boxes grow. `pageScroll` is the shared fix — and
              // on a phone it hands the child straight through, because that
              // shell is already a scroll view. See its doc comment.
              child: CreateDatabaseMetrics.pageScroll(
                context,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: metrics.extraHorizontalInset,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _card(state, strings, metrics),
                      SizedBox(height: metrics.cardToActions),
                      CreateDatabaseActions(
                        metrics: metrics,
                        discardLabel: strings.discardChanges,
                        primaryLabel: strings.save,
                        onDiscard: _onDiscard,
                        onPrimary: _onSave,
                        isSubmitting: state.isSubmitting,
                        // SAVE STAYS GREY UNTIL SOMETHING IS EDITED
                        // (17/8/2026). `EditDatabaseState.isDirty` compares
                        // against the record as LOADED, not "is anything
                        // typed" — this form opens full, so the second rule
                        // would report it dirty the moment it appeared.
                        //
                        // `_onSave` already refused an untouched save with the
                        // "Nothing Changed" dialog; the grey button is that
                        // rule made visible BEFORE the tap instead of after
                        // it. It still fires, so the dialog is still the
                        // explanation.
                        isPrimaryEnabled: state.isDirty,
                      ),
                      SizedBox(height: metrics.blockGap),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _card(
    EditDatabaseState state,
    DatabaseDetailsStrings strings,
    CreateDatabaseMetrics metrics,
  ) {
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
          // `CustomImagePicker` directly rather than db1's
          // `CreateDatabaseCoverPicker`: that wrapper takes only a local File,
          // which is all a create screen can have. An EDIT screen opens on a
          // record that may already have a cover, and it has to show it —
          // otherwise the picker looks empty and the user re-uploads a picture
          // that was never missing. `imageUrl` is the parameter for that.
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: CustomImagePicker(
              imageFile: state.coverImage,
              imageUrl: state.original.coverImageUrl,
              onImagePicked: _cubit.coverImagePicked,
              radius: metrics.avatarRadius,
              badgeRadius: metrics.badgeRadius,
              placeholderSvg:
                  'assets/icons_assets/main_icons_assets/image_photo_rounded.svg',
              badgeSvg: 'assets/icons_assets/messaging_assets/camera.svg',
            ),
          ),
          SizedBox(height: metrics.blockGap),

          // English | Arabic side by side above 600px, stacked below it — the
          // shared helper, so this row behaves exactly like the create card's.
          buildResponsiveFields(
            context: context,
            left: _titleField(
              controller: _titleEn,
              label: strings.databaseTitleEn,
              hint: strings.hintEn,
              direction: TextDirection.ltr,
              errorText: state.visibleTitleEnError,
              onChanged: _cubit.titleEnChanged,
              enabled: !state.isSubmitting,
            ),
            right: _titleField(
              controller: _titleAr,
              label: strings.databaseTitleAr,
              hint: strings.hintAr,
              direction: TextDirection.rtl,
              errorText: state.visibleTitleArError,
              onChanged: _cubit.titleArChanged,
              enabled: !state.isSubmitting,
            ),
          ),
          SizedBox(height: metrics.blockGap),

          _descriptionField(
            controller: _descriptionEn,
            label: strings.descriptionEn,
            hint: strings.hintEn,
            direction: TextDirection.ltr,
            onChanged: _cubit.descriptionEnChanged,
            enabled: !state.isSubmitting,
          ),
          SizedBox(height: metrics.blockGap),

          _descriptionField(
            controller: _descriptionAr,
            label: strings.descriptionAr,
            hint: strings.hintAr,
            direction: TextDirection.rtl,
            onChanged: _cubit.descriptionArChanged,
            enabled: !state.isSubmitting,
          ),
        ],
      ),
    );
  }

  /// The grey fill behind every field.
  ///
  /// Not `AppColors.field` — that is white in light mode, which would make the
  /// fields disappear into the white card. This is the light/dark pair
  /// `AppColors` documents for a fill sitting on a card.
  Color get _fieldFill =>
      AppTheme.isDark ? AppColors.colorBlack : AppColors.fieldFillLight;

  TextStyle get _labelStyle =>
      StyleText.fontSize14Weight500.copyWith(color: AppColors.text);

  TextStyle get _hintStyle =>
      StyleText.fontSize14Weight400.copyWith(color: AppColors.secondaryText);

  Widget _titleField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required TextDirection direction,
    required String? errorText,
    required ValueChanged<String> onChanged,
    required bool enabled,
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
        // The Figma shows no counter under the titles, only under the
        // descriptions. `CustomTextField` switches its counter on whenever
        // `maxLength` is set, so the limit is enforced by a formatter instead.
        inputFormatters: <TextInputFormatter>[
          LengthLimitingTextInputFormatter(CreateDatabaseLimits.titleMaxLength),
        ],
        // RAW Figma value: CustomTextField documents `height` as "interpreted
        // in .h" and applies `.h` itself, so a pre-scaled value scales twice.
        height: CreateDatabaseMetrics.figmaFieldHeight,
        fillColor: _fieldFill,
        showCharCount: false,
        enabled: enabled,
      ),
    );
  }

  Widget _descriptionField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required TextDirection direction,
    required ValueChanged<String> onChanged,
    required bool enabled,
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
        maxLines: null,
        minLines: 3,
        maxLength: CreateDatabaseLimits.descriptionMaxLength,
        showCharCount: true,
        height: CreateDatabaseMetrics.figmaDescriptionHeight,
        fillColor: _fieldFill,
        enabled: enabled,
      ),
    );
  }
}
