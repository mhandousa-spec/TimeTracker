import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/helper/role/validator.dart';
import 'package:knowticed_plus/features/form_builder_module/f4_fillout/presentation/controller/fill_out_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/radio_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/radio_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/alignment.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/arrangement.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/text_required_widget.dart';

class RadioResultWidget extends StatelessWidget {
  const RadioResultWidget(
      {super.key,
      this.reviewModel,
      this.fieldController,
      this.isValidated = false,
      this.isWhiteFill = false,
      this.isReadOnly = false,
      this.onTapRadio,
      this.isShownError = false});
  final RadioFieldController? fieldController;
  final RadioFieldModel? reviewModel;
  final bool isValidated, isWhiteFill, isShownError, isReadOnly;
  final void Function(String)? onTapRadio;
  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: _getAlignment(),
        child: SizedBox(
          width: _calculateWidth(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextRequiredWidget(
                  isRequired: _getIsRequired(), text: _getTitle()),
              verticalSpace(4),
              _buildRadioOptions(),
              verticalSpace(2),
              if (isShownError &&
                  _isErrorNull(fieldController?.selectedRadio) == null)
                Text(
                  _getError() ?? '',
                  style: StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
                )
            ],
          ),
        ));
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

  /// Build radio options based on arrangement (vertical or horizontal)
  Widget _buildRadioOptions() {
    return _getArrangement() == Arrangement.vertical.name
        ? _buildVerticalRadios()
        : _buildHorizontalRadios();
  }

  /// Build vertical radio options
  Column _buildVerticalRadios() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: _getWidgets(),
    );
  }

  /// Build horizontal radio options
  Wrap _buildHorizontalRadios() {
    return Wrap(
      children: _getWidgets(),
    );
  }

  /// Build individual radio row with radio button and text
  Widget _buildRadioRow(String option) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 8.0, end: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
              onTap: () {
                if (onTapRadio != null) {
                  onTapRadio!(option);
                } else if (!isReadOnly && isValidated) {
                  Get.find<FillOutCubit>().changeRadioValue(
                      controller: fieldController!, value: option);
                }
              },
              child: SvgPicture.asset(_setImage(option),
                  colorFilter:
                      ColorFilter.mode(AppColors.text, BlendMode.srcIn))),
          horizontalSpace(5),
          Flexible(
            child: Text(
              option,
              style: StyleText.fontSize14Weight500,
            ),
          ),
        ],
      ),
    );
  }

  _getArrangement() {
    String? arrangement = fieldController != null
        ? fieldController!.arrangement
        : reviewModel!.arrangement;
    return arrangement;
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

  _getWidgets() {
    List<Widget> widgets = [];
    if (fieldController != null) {
      for (int i = 0; i < fieldController!.hints.length; i++) {
        widgets.add(_buildRadioRow(fieldController!.hints[i].text));
      }
    } else {
      for (int i = 0; i < reviewModel!.hints.length; i++) {
        widgets.add(_buildRadioRow(reviewModel!.hints[i]));
      }
    }
    return widgets;
  }

  String _setImage(String option) {
    if (fieldController != null) {
      return fieldController!.selectedRadio == option
          ? AppAssets.radioSelected
          : AppAssets.radio;
    } else {
      return reviewModel!.selectedRadio == option
          ? AppAssets.radioSelected
          : AppAssets.radio;
    }
  }

  _isErrorNull(String? selectedRadio) {
    return selectedRadio == null || selectedRadio.isEmpty ? null : 'dasx';
  }

  String? _getError() {
    if (isValidated) {
      if (fieldController?.isRequired ?? false) {
        String? error = Validator.isEmpty(
            _isErrorNull(fieldController?.selectedRadio),
            fieldController?.title?.text ?? '');
        return error ?? 'asd';
      }
    }
    return null;
  }
}
