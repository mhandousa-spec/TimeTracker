import 'package:country_picker/country_picker.dart';
import 'package:knowticed_plus/core/custom/99-custom_country_flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/utils/country_parse_helper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/62-custom_date_time_helper.dart';
import 'package:knowticed_plus/features/form_builder_module/f4_fillout/presentation/controller/fill_out_cubit.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/helper/role/validator.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/phone_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/phone_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/alignment.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/text_required_widget.dart';

import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/60-custom_country_picker.dart' as core_countries;
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/helper/main_helper/extensions.dart' hide ContextExtension;

class PhoneResultWidget extends StatelessWidget {
  const PhoneResultWidget({
    super.key,
    this.reviewModel,
    this.fieldController,
    this.isValidated = false,
    this.isReadOnly = false,
    this.isWhiteFill = false,
    this.onChangePhone,
    this.isExpand = false,
    this.onSelectCountry,
  });

  final PhoneFieldController? fieldController;
  final PhoneFieldModel? reviewModel;
  final bool isValidated, isWhiteFill, isReadOnly;
  final void Function(Country)? onSelectCountry;
  final dynamic Function(String)? onChangePhone;
  final bool isExpand;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _getAlignment(),
      child: SizedBox(
        width: isExpand ? null : _calculateWidth(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleWidget(),
            verticalSpace(4),
            _buildPhoneInputRow(context),
          ],
        ),
      ),
    );
  }

  /// Calculate widget width based on alignment and device type
  double _calculateWidth(BuildContext context) {
    String? alignment = fieldController != null
        ? fieldController!.alignment
        : reviewModel!.alignment;
    return alignment != AlignmentEnum.expand.name
        ? (ContextExtension(context).isTablett ? 200.w : 365.w)
        : double.infinity;
  }

  /// Build title widget based on alignment
  Widget _buildTitleWidget() {
    return TextRequiredWidget(isRequired: _getIsRequired(), text: _getTitle());
  }

  /// Safe country parsing with fallback (no try/catch in UI, §11.2).
  Country _parseCountrySafely(String? countryCode) =>
      CountryParseHelper.parseCountrySafely(countryCode);

  /// Build phone input row with country code selector and phone number field
  Widget _buildPhoneInputRow(BuildContext context) {
    // ✅ Use safe parsing method
    Country country = _parseCountrySafely(fieldController?.currentCountry);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ Country code selector - responsive width based on content
        _buildCountryCodeSelector(context, country),
        horizontalSpace(8),
        // ✅ Phone number field - takes remaining space
        Expanded(
          child: _buildPhoneNumberField(country),
        ),
      ],
    );
  }

  /// The field metrics every input on these screens shares.
  ///
  /// `CustomTextField` applies its `height` as `SizedBox(height: height.sp)`,
  /// so the country box has to be `36.sp` — not `36.h` — to end up the same
  /// height as the phone field beside it.
  static const double _fieldHeight = 36;

  static final EdgeInsetsGeometry _fieldPadding =
      EdgeInsets.symmetric(vertical: 12.sp, horizontal: 10.sp);

  /// Build country code selector container - RESPONSIVE WIDTH
  Widget _buildCountryCodeSelector(BuildContext context, Country country) {
    return IntrinsicWidth(
      child: Container(
        // FIXED: was `30.h`. Two problems at once — 30 instead of 36, so the
        // country box was visibly shorter than every other field in the row,
        // and `.h` instead of `.sp`, so it scaled off a different axis than
        // the `CustomTextField` it sits next to and the gap changed with the
        // window.
        height: _fieldHeight.sp,
        constraints: BoxConstraints(
          minWidth: 80.w, // ✅ Minimum width for very short codes
        ),
        decoration: BoxDecoration(
          color: isWhiteFill ? AppColors.white : AppColors.background,
          // FIXED: was `circular(4)` — unscaled, so its corners did not match
          // the 4.r that CustomTextField rounds to.
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: InkWell(
          onTap: () => isReadOnly ? null : _showCountryPicker(context),
          child: Padding(
            // Horizontal only: the box is a fixed height with a centred child,
            // so vertical padding here would fight the height rather than set
            // it. 10.sp matches the horizontal half of [_fieldPadding].
            padding: EdgeInsets.symmetric(horizontal: 10.sp),
            child: Center(
              child: _buildCountryCodeRow(country),
            ),
          ),
        ),
      ),
    );
  }

  /// Show country picker dialog.
  ///
  /// Form bug report #14: uses the same picker as Settings > Personal
  /// Information (core `showCountryPickerDialog`, an opaque Dialog) instead of
  /// the country_picker bottom sheet, which rendered transparent. The picked
  /// ISO code is mapped back to a country_picker [Country] so every caller's
  /// `onSelectCountry` / FillOutCubit.selectCountry keeps working unchanged.
  Future<void> _showCountryPicker(BuildContext context) async {
    final picked = await core_countries.showCountryPickerDialog(context);
    if (picked == null) return;
    final country = _parseCountrySafely(picked.code);
    if (onSelectCountry != null) {
      onSelectCountry!(country);
    } else if (isValidated) {
      Get.find<FillOutCubit>().selectCountry(
        controller: fieldController!,
        country: country,
      );
    }
  }

  /// Build row with country flag, phone code, and dropdown arrow
  Row _buildCountryCodeRow(Country country) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ✅ Flag with error handling
        // Bug report p.4/p.38: the PNG flags this asked for were never
        // shipped, so every code showed a grey box. Bundled SVG flag instead.
        AppCountryFlag(isoCode: country.countryCode, width: 18, height: 13.5),
        horizontalSpace(4),
        // ✅ Phone code
        Text(
          '+${FormDateTimeHelper.formatInt(country.phoneCode.toEnglishNumber())}',
          style: StyleText.fontSize14Weight400,
        ),
        horizontalSpace(4),
        // ✅ Dropdown arrow
        SizedBox(
          height: 12,
          width: 12,
          child: SvgPicture.asset(
            AppAssets.arrowDown,
            colorFilter: ColorFilter.mode(AppColors.text, BlendMode.srcIn),
          ),
        ),
      ],
    );
  }

  /// Build phone number input field
  Widget _buildPhoneNumberField(Country country) {
    String hint = country.example.replaceAllDigitsWithZero();
    
    return CustomTextField(
        height: _fieldHeight,
        readOnly: isReadOnly,
        contentPadding: _fieldPadding,
        hint: hint,
        initialValue: fieldController?.phoneAnswer,
        onChanged: onChangePhone,
        // FIXED: this used to pass `maxLength: hint.length, showCharCount:
        // false`, which is why a "0 / 10" counter sat under the phone box.
        // `showCharCount` does not suppress anything — CustomTextField reads
        // `_showCounter => showCharCount || maxLength != null`, so ANY
        // maxLength draws the counter and the false was a no-op. The limit is
        // now enforced by a formatter instead, which caps typing exactly as
        // `maxLength` did but adds no counter row.
        inputFormatters: [LengthLimitingTextInputFormatter(hint.length)],
        maxLines: 1,
        fillColor: isWhiteFill ? AppColors.white : AppColors.background,
        width: double.infinity,
      );
  }

  Alignment _getAlignment() {
    if (reviewModel == null) {
      return fieldController!.alignment!.alignment;
    }
    return reviewModel!.alignment.alignment;
  }

  bool _getIsRequired() {
    bool flag = false;
    if (reviewModel != null) {
      flag = reviewModel?.isRequired ?? false;
      return flag;
    }
    flag = fieldController?.isRequired ?? false;
    return flag;
  }

  String _getTitle() {
    if (reviewModel != null) {
      return reviewModel?.title ?? '';
    }
    return fieldController?.title?.text ?? '';
  }

  String? _getValidate(String? value) {
    if (isValidated) {
      if (fieldController?.isRequired ?? false) {
        String? error = Validator.isEmpty(
          value,
          fieldController?.title?.text ?? '',
        );
        error = error ?? Validator.isNumber(value!);
        if (error == null) {
          // ✅ Use safe parsing for validation too
          Country country = _parseCountrySafely(fieldController?.currentCountry);
          String hint = country.example;
          if (hint.length != value?.length) {
            error = S.current.pleaseEnterTheValidPhoneNumber;
          }
        }

        return error;
      } else {
        if (value?.isNotEmpty ?? false) {
          String? error = Validator.isNumber(value!);
          if (error == null) {
            // ✅ Use safe parsing for validation too
            Country country = _parseCountrySafely(fieldController?.currentCountry);
            String hint = country.example;
            if (hint.length != value.length) {
              error = S.current.pleaseEnterTheValidPhoneNumber;
            }
          }
          return error;
        }
      }
    }
    return null;
  }
}