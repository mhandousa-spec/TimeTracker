import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/helper/role/validator.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/location_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/location_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/location_drop_down.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/text_required_widget.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/helper/main_helper/extensions.dart';

class LocationResultWidget extends StatelessWidget {
  const LocationResultWidget({
    super.key,
    this.fieldController,
    this.reviewModel,
    this.isValidated = false,
    this.isReadOnly = false,
    this.isWhiteFill = false,
  });
  final LocationFieldController? fieldController;
  final LocationFieldModel? reviewModel;
  final bool isValidated, isWhiteFill, isReadOnly;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FIXED: this used to be `if (title.isNotEmpty) TextRequiredWidget(…)`,
          // and THAT is why the lat/long boxes sat ABOVE every other field in
          // the row. An untitled field dropped the title line entirely, while
          // every sibling in `type_result_widgets/` renders TextRequiredWidget
          // unconditionally — an empty RichText still occupies one 14sp line.
          // The column below it therefore started a whole line early. Rendering
          // it unconditionally puts location back on the shared baseline.
          //
          // Reading the title through `_getTitle()` also drops two `!` bangs on
          // `fieldController`, which threw on the review and submission screens:
          // those pass `reviewModel` and leave `fieldController` null.
          TextRequiredWidget(
            isRequired: _getIsRequired(),
            text: _getTitle(),
          ),
          verticalSpace(4),
          _buildLocationInput(),
        ],
      ),
    );
  }

  /// Build location input based on location type
  Widget _buildLocationInput() {
    final locationType = _getLocationType();

    switch (locationType) {
      case LocationDropDown.latitudeAndLongitude:
        return _buildLatLongInputRow();
      case LocationDropDown.link:
        return _buildLinkInput();
      case null:
        return const SizedBox.shrink();
    }
  }

  /// Build row for latitude and longitude inputs
  Widget _buildLatLongInputRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildLatitudeInput()),
        horizontalSpace(15),
        Expanded(child: _buildLongitudeInput()),
      ],
    );
  }

  /// The content padding every field on these screens shares.
  ///
  /// `TextFieldResultWidget` and `DropDownResultWidget` both use exactly this,
  /// so the text inside a latitude box now sits where the text in the field
  /// beside it sits. Latitude and longitude previously passed none at all and
  /// fell back to `CustomTextField`'s default.
  static final EdgeInsetsGeometry _fieldPadding =
      EdgeInsets.symmetric(vertical: 12.sp, horizontal: 10.sp);

  /// Build latitude input field
  Widget _buildLatitudeInput() {
    return CustomTextField(
        height: 36,
        readOnly: isReadOnly,
        contentPadding: _fieldPadding,
        hint: _getLatitudeHint(),
        maxLines: 1,
        fillColor: isWhiteFill ? AppColors.white : AppColors.background,
        width: double.infinity,
      );
  }

  /// Build longitude input field
  Widget _buildLongitudeInput() {
    return CustomTextField(
        height: 36,
        readOnly: isReadOnly,
        contentPadding: _fieldPadding,
        hint: _getLongitudeHint(),
        maxLines: 1,
        fillColor: isWhiteFill ? AppColors.white : AppColors.background,
        width: double.infinity,
      );
  }

  /// Build link input field
  Widget _buildLinkInput() {
    return CustomTextField(
        height: 36,
        maxLines: 1,
        readOnly: isReadOnly,
        // CHANGED: was `horizontal: 14.sp, vertical: 4.sp`, its own values.
        contentPadding: _fieldPadding,
        hint: _getLinkHint(),
        prefixIcon: SvgPicture.asset(
        AppAssets.locationIcon,
        width: 16,
        height: 16,
      ),
        fillColor: isWhiteFill ? AppColors.white : AppColors.background,
        width: double.infinity,
      );
  }

  String _getTitle() {
    if (reviewModel != null) {
      return reviewModel?.title ?? '';
    }
    return fieldController?.title?.text ?? '';
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

  LocationDropDown? _getLocationType() {
    if (reviewModel != null) {
      return LocationDropDownExtension.fromName(reviewModel!.locationType);
    }
    return LocationDropDownExtension.fromName(fieldController!.locationType!);
  }

  String? _getLatitudeHint() {
    if (reviewModel != null) {
      return reviewModel!.hintLatitude;
    }
    return fieldController!.hintLatitude?.text;
  }

  String? _getLongitudeHint() {
    if (reviewModel != null) {
      return reviewModel!.hintLongitude;
    }
    return fieldController!.hintLongitude?.text;
  }

  String? _getLinkHint() {
    if (reviewModel != null) {
      return reviewModel!.hintLink;
    }
    return fieldController!.hintLink?.text;
  }

  _getLongValidate(String? value) {
    if (isValidated) {
      if (fieldController?.isRequired ?? false) {
        String? error = Validator.isEmpty(
            value, fieldController?.hintLongitude?.text ?? '');
        error = error ??
            Validator.isNumberWithNegative(
                value!.toEnglishNumber().toString());
        error = error ??
            Validator.isValidLongitude(value!.toEnglishNumberAsDouble());
        return error;
      } else {
        if (value?.isNotEmpty ?? false) {
          String? error = Validator.isNumberWithNegative(
              value!.toEnglishNumber().toString());
          error = error ??
              Validator.isValidLongitude(
                  value.toEnglishNumberAsDouble());
          return error;
        }
        return null;
      }
    } else {
      return null;
    }
  }

  _getLateValidate(String? value) {
    if (isValidated) {
      if (fieldController?.isRequired ?? false) {
        String? error = Validator.isEmpty(
            value, fieldController?.hintLatitude?.text ?? '');
        error = error ??
            Validator.isNumberWithNegative(
                value!.toEnglishNumber().toString());
        error = error ??
            Validator.isValidLatitude(value!.toEnglishNumberAsDouble());
        return error;
      } else {
        if (value?.isNotEmpty ?? false) {
          String? error = Validator.isNumberWithNegative(
              value!.toEnglishNumber().toString());
          error = error ??
              Validator.isValidLatitude(value.toEnglishNumberAsDouble());
          return error;
        }
        return null;
      }
    } else {
      return null;
    }
  }

  _getLinkValidate(String? value) {
    if (isValidated) {
      if (fieldController?.isRequired ?? false) {
        String? error = Validator.isEmpty(
            value, fieldController?.hintLink?.text ?? '');
        error = error ?? Validator.isGoogleMapsLink(value!);
        return error;
      } else {
        if (value?.isNotEmpty ?? false) {
          return Validator.isGoogleMapsLink(value!);
        }
        return null;
      }
    } else {
      return null;
    }
  }
}
