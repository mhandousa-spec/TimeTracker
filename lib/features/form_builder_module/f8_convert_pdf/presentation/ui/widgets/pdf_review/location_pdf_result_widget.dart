import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/location_drop_down.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/text_required_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/location_field_model.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
class LocationPdfResultWidget extends StatelessWidget {
  const LocationPdfResultWidget({
    super.key,
    required this.model,
    this.isExpand = false,
  });
  final bool isExpand;
  final LocationFieldModel model;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextRequiredWidget(
              isRequired: model.isRequired, text: 'Location'),
          verticalSpace(8),
          _buildLocationInput(model),
        ],
      ),
    );
  }

  /// Build location input based on location type
  Widget _buildLocationInput(LocationFieldModel model) {
    final locationType = LocationDropDownExtension.fromName(model.locationType);

    switch (locationType) {
      case LocationDropDown.latitudeAndLongitude:
        return _buildLatLongInputRow(model);
      case LocationDropDown.link:
        return _buildLinkInput();
      case null:
        return const SizedBox.shrink();
    }
  }

  /// Build row for latitude and longitude inputs
  Widget _buildLatLongInputRow(LocationFieldModel model) {
    return Row(
      children: [
        Expanded(child: _buildLatitudeInput()),
        horizontalSpace(15),
        Expanded(child: _buildLongitudeInput()),
      ],
    );
  }

  /// Build latitude input field
  Widget _buildLatitudeInput() {
    return CustomTextField(
        height: 36,
        contentPadding: EdgeInsets.symmetric(vertical: 12.sp, horizontal: 10.sp), // form bug report #40
        hint: 'lat:',
        maxLines: 1,
        hintStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack),
        valueStyle: StyleText.fontSize12Weight400,
        fillColor: AppColors.background,
        enabled: false,
        width: double.infinity,
      );
  }

  /// Build longitude input field
  Widget _buildLongitudeInput() {
    return CustomTextField(
        height: 36,
        contentPadding: EdgeInsets.symmetric(vertical: 12.sp, horizontal: 10.sp), // form bug report #40
        hint: 'long:',
        maxLines: 1,
        hintStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack),
        valueStyle: StyleText.fontSize12Weight400,
        fillColor: AppColors.background,
        enabled: false,
        width: double.infinity,
      );
  }

  /// Build link input field
  Widget _buildLinkInput() {
    return CustomTextField(
        height: 36,
        contentPadding: EdgeInsets.symmetric(vertical: 12.sp, horizontal: 10.sp), // form bug report #40
        hint: '',
        maxLines: 1,
        enabled: false,
        prefixIcon: SvgPicture.asset(
        AppAssets.link,
        colorFilter: ColorFilter.mode(AppColors.text, BlendMode.srcIn),
        width: 16,
        height: 16,
      ),
        hintStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack),
        valueStyle: StyleText.fontSize12Weight400,
        fillColor: AppColors.background,
        width: double.infinity,
      );
  }
}
