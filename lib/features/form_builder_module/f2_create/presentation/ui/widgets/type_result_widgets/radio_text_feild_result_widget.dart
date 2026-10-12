import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/form_builder_module/f4_fillout/presentation/controller/fill_out_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/radio_text_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/radio_text_field_model.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/helper/role/validator.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
class RadioTextFieldResultWidget extends StatelessWidget {
  /// Constructor for RadioTextFieldResultWidget
  /// [index] represents the specific controller index
  /// [rowIndex] represents the row in the form
  /// [pageIndex] represents the page in the form
  const RadioTextFieldResultWidget({
    super.key,
    this.fieldController,
    this.reviewModel,
    this.isValidated = false,
    this.isWhiteFill = false,
    this.isReadOnly=false,
    this.onTapRadio,
    this.isShownError = false,
  });

  final RadioTextFieldController? fieldController;
  final RadioTextFieldModel? reviewModel;
  final bool isValidated, isWhiteFill, isShownError,isReadOnly;
  final void Function(String)? onTapRadio;

  @override
  Widget build(BuildContext context) {
    // Build the main widget container
    return _buildContainer(context);
  }

  /// Build the container with alignment and sizing
  Widget _buildContainer(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _getWidgets(),
        ),
        verticalSpace(4),
        if (isShownError &&
            _isErrorNull(fieldController?.selectedRadio) == null)
          Text(
            _getError() ?? '',
            style: StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
          )
      ],
    );
  }

  /// Build the radio button with text field
  Widget _buildRadioTextField(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  if (onTapRadio != null) {
                    onTapRadio!(text);
                  }
                  else if (!isReadOnly||isValidated) {
                    Get.find<FillOutCubit>().changeRadioTextValue(
                        controller: fieldController!, value: text);
                  }
                },
                child: SvgPicture.asset(_setImage(text),colorFilter: ColorFilter.mode(AppColors.text,  BlendMode.srcIn )),
              ),
              horizontalSpace(5),
              Container(
                color: isWhiteFill
                    ? AppColors.white
                    : AppColors.background,
                height: 36.sp, // form bug report #23
                child: Flexible(
                  // Allows content to shrink if needed
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      textAlign: TextAlign.center,
                      text,
                      style: StyleText.fontSize14Weight500,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _getWidgets() {
    List<Widget> widgets = [];
    if (reviewModel != null) {
      for (int i = 0; i < reviewModel!.hints.length; i++) {
        widgets.add(Expanded(
            child: Container(
          margin: const EdgeInsetsDirectional.only(bottom: 8.0, end: 8),
          child: _buildRadioTextField(reviewModel!.hints[i]),
        )));
      }
      return widgets;
    }
    for (int i = 0; i < fieldController!.hints.length; i++) {
      widgets.add(Expanded(
          child: Container(
        margin: EdgeInsetsDirectional.only(
            end: i == (fieldController!.hints.length - 1) ? 0 : 8),
        child: _buildRadioTextField(fieldController!.hints[i].text),
      )));
    }
    return widgets;
  }

  String _setImage(String text) {
    if (fieldController != null) {
      return fieldController!.selectedRadio == text
          ? AppAssets.radioSelected
          : AppAssets.radio;
    } else {
      return reviewModel!.selectedRadio == text
          ? AppAssets.radioSelected
          : AppAssets.radio;
    }
  }

  _isErrorNull(String? selectedRadio) {
    return selectedRadio == null || selectedRadio.isEmpty ? null : 'dasx';
  }

  String? _getError() {
    if (isValidated) {
      String? error = Validator.isEmpty(
          _isErrorNull(fieldController?.selectedRadio),
          'Radio - Text Field');
      return error ?? '';
    }
    return null;
  }
}
