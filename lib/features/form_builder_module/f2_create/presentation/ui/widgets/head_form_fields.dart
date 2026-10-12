import 'package:flutter/material.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart'; // Keep for .tr translations and extensions
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/utils/helper_format.dart';

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart' hide FormatHelper;
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/helper/role/validator.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/access_management.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/orientation.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_head_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_head_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/add_image_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/drop_down_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/slider_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/watermark_widget.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
class HeadFormFields extends StatelessWidget {
  final CreateFormHeadLoaded state;
  final bool isReadOnly;

  const HeadFormFields({
    super.key,
    required this.state,
    required this.isReadOnly,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        verticalSpace(15),
        const AddImageWidget(),
        verticalSpace(15),
        _buildTitleFields(context, state, isReadOnly),
        verticalSpace(15),
        _buildDescriptionFields(context, state, isReadOnly),
        verticalSpace(15),
        _buildDropDownFields(context, state, isReadOnly),
        verticalSpace(15),
        _buildPaddingFields(context, state, isReadOnly),
        verticalSpace(15),
        const WatermarkWidget(),
        verticalSpace(40),
        _buildWatermarkSliders(context, state, isReadOnly),
        verticalSpace(15),
      ],
    );
  }

  Widget _buildTitleFields(
    BuildContext context,
    CreateFormHeadLoaded state,
    bool isReadOnly,
  ) {
    return ContextExtension(context).isTablett
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: context.isArabic
                    ? _buildTitleField(context, state, true, isReadOnly)
                    : _buildTitleField(context, state, false, isReadOnly),
              ),
              horizontalSpace(20),
              Expanded(
                child: context.isArabic
                    ? _buildTitleField(context, state, false, isReadOnly)
                    : _buildTitleField(context, state, true, isReadOnly),
              ),
            ],
          )
        : Column(
            children: [
              _buildTitleField(
                context,
                state,
                context.isArabic ? true : false,
                isReadOnly,
              ),
              verticalSpace(15),
              _buildTitleField(
                context,
                state,
                context.isArabic ? false : true,
                isReadOnly,
              ),
            ],
          );
  }

  Widget _buildTitleField(
    BuildContext context,
    CreateFormHeadLoaded state,
    bool isArabic,
    bool isReadOnly,
  ) {
    // FIXED 01/09/2026 — this used to wrap the field in
    // `Localizations.override(locale: Locale(isArabic ? 'ar' : 'en'))`.
    //
    // That override is NOT local. `Localizations.override` re-loads the
    // delegates it inherits from the parent — `S.delegate` among them — and
    // the generated `S.load` assigns the file-static `S._current` AND the
    // global `Intl.defaultLocale`. So every build of this screen fired one
    // load for 'ar' and one for 'en', and whichever finished last owned
    // `S.current` and `Intl.defaultLocale` for the WHOLE app: `S.of(context)`
    // widgets stayed in the chosen language while every `S.current` call site
    // (e.g. the `S.current.all` department comparisons in forms_group_cubit,
    // upload_media_cubit and result_cubit) flipped to the other one, and
    // `Intl.defaultLocale` lost its country code so dates reformatted. That is
    // the "Arabic and English at the same time after opening the form module"
    // bug, and it was reachable from no other module.
    //
    // Nothing here needed it: the label and hint deliberately follow the app
    // locale (see the note below), and the per-field script is carried by the
    // `Directionality` wrapper. Do not reintroduce it — there is no way to
    // exclude the inherited `S.delegate` from an override.
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: CustomTextField(
        height: 36,
        // FIXED 19/8/2026 — the hint and label were hard-coded per field
        // ('اكتب هنا' / 'Text Here'), so the Arabic-title input kept showing
        // Arabic chrome while the app was in English and vice versa. `isArabic`
        // here means "this input holds the ARABIC copy", not "the UI is
        // Arabic" — the two are independent, which is exactly what went wrong.
        // The wording now follows the app locale; which field is which is said
        // by the label (`titleInArabic`) rather than by the label's script.
        hint: S.of(context).textHere,
        readOnly: isReadOnly,
        // Bug report p.36: the Arabic-content field is labelled IN ARABIC,
        // the same way the Messages group editor labels its Arabic name /
        // description ("اسم المجموعة", "الوصف"). Only the label — the hint
        // still follows the app locale (see the note above).
        label: isArabic ? 'عنوان الاستمارة' : S.of(context).formTitle,
        controller: isArabic ? state.arTitleController : state.titleController,
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        inputFormatters: isArabic
            ? [InputFormattersHelper.arabicOnly()]
            : [InputFormattersHelper.englishOnly()],
        onChanged: !isArabic && !isReadOnly
            ? (value) {
                final controller = state.titleController;
                final capitalized = FormatHelper.capitalize(value);
                if (controller.text != capitalized) {
                  controller.value = controller.value.copyWith(
                    text: capitalized,
                    selection:
                        TextSelection.collapsed(offset: capitalized.length),
                  );
                }
              }
            : null,
      ),
    );
  }

  Widget _buildDescriptionFields(
    BuildContext context,
    CreateFormHeadLoaded state,
    bool isReadOnly,
  ) {
    return Column(
      children: [
        context.isArabic
            ? _buildDescriptionField(context, state, true, isReadOnly)
            : _buildDescriptionField(context, state, false, isReadOnly),
        verticalSpace(15),
        context.isArabic
            ? _buildDescriptionField(context, state, false, isReadOnly)
            : _buildDescriptionField(context, state, true, isReadOnly),
      ],
    );
  }

  Widget _buildDescriptionField(
    BuildContext context,
    CreateFormHeadLoaded state,
    bool isArabic,
    bool isReadOnly,
  ) {
    // FIXED 01/09/2026 — `Localizations.override` removed here for the same
    // reason as in `_buildTitleField` above: it rewrote the app-wide
    // `S.current` and `Intl.defaultLocale`. See that comment before touching
    // this.
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: CustomTextField(
        readOnly: isReadOnly,
        minLines: 3,
        maxLines: 10,
        maxLength: 500,
        showCharCount: true,
        textDirection: (isArabic) ? TextDirection.rtl : TextDirection.ltr,
        // Same fix as the title field above: chrome follows the app locale,
        // the label says which language the CONTENT should be in.
        hint: S.of(context).textHere,
        // Bug report p.36: Arabic label on the Arabic-content field, as in
        // the Messages group editor.
        label: isArabic ? 'الوصف' : S.of(context).description,
        controller: isArabic
            ? state.arDescriptionController
            : state.descriptionController,
        onChanged: (value) {
          if (isArabic) {
            state.arDescriptionController.text = FormatHelper.capitalize(value);
          } else {
            state.descriptionController.text = FormatHelper.capitalize(value);
          }
        },
      ),
    );
  }

  Widget _buildDropDownFields(
    BuildContext context,
    CreateFormHeadLoaded state,
    bool isReadOnly,
  ) {
    return ContextExtension(context).isTablett
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildAccessManagementDropdown(context, state, isReadOnly),
              ),
              horizontalSpace(20),
              Expanded(
                child: _buildOrientationDropdown(context, state, isReadOnly),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAccessManagementDropdown(context, state, isReadOnly),
              verticalSpace(15),
              _buildOrientationDropdown(context, state, isReadOnly),
            ],
          );
  }

  Widget _buildAccessManagementDropdown(
    BuildContext context,
    CreateFormHeadLoaded state,
    bool isReadOnly,
  ) {
    return DropDownWidget(
      isReadOnly: isReadOnly,
      validator: (value) => _validateRequiredDropdown(
        value,
        S.of(context).accessManagement,
      ),
      onChanged: (value) {
        context.read<CreateFormHeadCubit>().updateAccessManagement(value);
      },
      title: S.of(context).accessManagement,
      hint: S.of(context).chooseAccessManagement,
      items: AccessManagementExtension.dropDownItems(),
      currentValue: state.accessManagement,
    );
  }

  Widget _buildOrientationDropdown(
    BuildContext context,
    CreateFormHeadLoaded state,
    bool isReadOnly,
  ) {
    return DropDownWidget(
      isReadOnly: isReadOnly,
      validator: (value) => _validateRequiredDropdown(
        value,
        S.of(context).orientation,
      ),
      onChanged: (value) {
        context.read<CreateFormHeadCubit>().updateOrientation(value);
      },
      title: S.of(context).orientation,
      hint: S.of(context).chooseOrientation,
      items: OrientationExtension.dropDownItems,
      currentValue: state.orientation,
    );
  }

  /// Placeholder for the two padding inputs.
  ///
  /// ADDED 19/8/2026 — the "add hint in horizontal and vertical padding" item
  /// from the bug report. These two were the ONLY inputs on the screen
  /// rendering as an empty box, which is why they read as broken sitting under
  /// the title and description fields that do show a placeholder.
  ///
  /// Figma (MESBAH / node 7444-41775) shows "Text Here" in both, the same
  /// string the Form Title field uses — so the Arabic side reuses that field's
  /// "اكتب هنا" rather than inventing a second phrasing for the same idea.
  String _paddingHint(BuildContext context) => S.of(context).textHere;

  Widget _buildPaddingFields(
    BuildContext context,
    CreateFormHeadLoaded state,
    bool isReadOnly,
  ) {
    final hint = _paddingHint(context);

    return ContextExtension(context).isTablett
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomTextField(
        height: 36,
        readOnly: isReadOnly,
        keyboardType: TextInputType.number,
        label: S.of(context).horizontalPadding,
        hint: hint,
        controller: state.horizontalPaddingController,
      ),
              ),
              horizontalSpace(20),
              Expanded(
                child: CustomTextField(
        readOnly: isReadOnly,
        height: 36,
        keyboardType: TextInputType.number,
        label: S.of(context).verticalPadding,
        hint: hint,
        controller: state.verticalPaddingController,
      ),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
        readOnly: isReadOnly,
        height: 36,
        keyboardType: TextInputType.number,
        label: S.of(context).horizontalPadding,
        hint: hint,
        controller: state.horizontalPaddingController,
      ),
              verticalSpace(15),
              CustomTextField(
        readOnly: isReadOnly,
        height: 36,
        keyboardType: TextInputType.number,
        label: S.of(context).verticalPadding,
        hint: hint,
        controller: state.verticalPaddingController,
      ),
            ],
          );
  }

  Widget _buildWatermarkSliders(
    BuildContext context,
    CreateFormHeadLoaded state,
    bool isReadOnly,
  ) {
    final watermarkSize = state.watermarkSizeController.text.isEmpty
        ? 100.0
        : (double.tryParse(state.watermarkSizeController.text) ?? 100.0);

    final watermarkOpacity = state.watermarkOpacityController.text.isEmpty
        ? 50.0
        : (double.tryParse(state.watermarkOpacityController.text) ?? 50.0);

    return ContextExtension(context).isTablett
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SliderWidget(
                  title: S.of(context).watermarkSize,
                  currantValue: watermarkSize,
                  onChanged: isReadOnly
                      ? null
                      : (value) {
                          context
                              .read<CreateFormHeadCubit>()
                              .updateWatermarkSize(value.round().toString());
                        },
                ),
              ),
              horizontalSpace(20),
              Expanded(
                child: SliderWidget(
                  title: S.of(context).watermarkOpacity,
                  currantValue: watermarkOpacity,
                  onChanged: isReadOnly
                      ? null
                      : (value) {
                          context
                              .read<CreateFormHeadCubit>()
                              .updateWatermarkOpacity(value.round().toString());
                        },
                ),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SliderWidget(
                title: S.of(context).watermarkSize,
                currantValue: watermarkSize,
                onChanged: isReadOnly
                    ? null
                    : (value) {
                        context
                            .read<CreateFormHeadCubit>()
                            .updateWatermarkSize(value.round().toString());
                      },
              ),
              verticalSpace(15),
              SliderWidget(
                title: S.of(context).watermarkOpacity,
                currantValue: watermarkOpacity,
                onChanged: isReadOnly
                    ? null
                    : (value) {
                        context
                            .read<CreateFormHeadCubit>()
                            .updateWatermarkOpacity(value.round().toString());
                      },
              ),
            ],
          );
  }

  String? _validateEnglishField(
    String? value,
    String fieldName,
    BuildContext context,
  ) {
    String? error = context.isArabic
        ? null
        : Validator.isEmpty(value, fieldName);

    if (value != null && value.isNotEmpty && !context.isArabic) {
      final hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(value);
      if (hasArabic) {
        error = S.of(context).fieldMustContainOnlyEnglishCharacters;
      }

      final hasEnglish = RegExp(r'[a-zA-Z]').hasMatch(value);
      if (!hasEnglish && !hasArabic) {
        error = error ?? S.of(context).fieldMustContainEnglishCharacters;
      }
    }

    return error;
  }

  String? _validateArabicField(
    String? value,
    String fieldName,
    BuildContext context,
  ) {
    // FIXED 19/8/2026 — these three messages were hard-coded Arabic, so an
    // English UI failed validation with an Arabic sentence. The RULE still
    // only accepts Arabic input; only the message follows the app locale.
    if (value == null || value.trim().isEmpty) {
      return S.of(context).thisFieldIsRequired;
    }

    final hasEnglish = RegExp(r'[a-zA-Z]').hasMatch(value);
    if (hasEnglish) {
      return S.of(context).fieldMustContainOnlyArabicCharacters;
    }

    final hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(value);
    if (!hasArabic) {
      return S.of(context).fieldMustContainArabicCharacters;
    }

    return null;
  }

  String? _validateNumberField(String? value) {
    if (value == null || value.isEmpty) return null;
    return Validator.isNumber(value);
  }

  String? _validateRequiredDropdown(dynamic value, String fieldName) {
    return Validator.isEmpty(value, fieldName);
  }
}
