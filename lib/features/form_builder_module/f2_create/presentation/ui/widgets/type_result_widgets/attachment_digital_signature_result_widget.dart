// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/attachment_entity.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:get/get.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/helper/role/validator.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/attachment_uploaded_widget.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/features/form_builder_module/f4_fillout/presentation/controller/fill_out_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/attachment_digital_signature_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/attachment_digital_signature_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/text_required_widget.dart';
class AttachmentDigitalSignatureResultWidget extends StatelessWidget {
  const AttachmentDigitalSignatureResultWidget({
    super.key,
    this.fieldController,
    this.reviewModel,
    this.isValidated = false,
    this.isWhiteFill = false,
    this.isReadOnly = false,
    this.isShownError = false,
  });

  final AttachmentDigitalSignatureFieldController? fieldController;
  final AttachmentDigitalSignatureFieldModel? reviewModel;
  final bool isValidated, isWhiteFill, isShownError, isReadOnly;

  @override
  Widget build(BuildContext context) {
    // ✅ Simplified: Same layout for all screen sizes
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextRequiredWidget(
          isRequired: _getIsRequired(),
          text: _getTitle(),
        ),
        _getSignatureWidget(),
        _getErrorWidget(),
      ],
    );
  }

  Widget _getErrorWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        verticalSpace(4),
        if (isShownError &&
            _isErrorNull(fieldController?.attachmentEntity) == null)
          Text(
            _getError() ?? '',
            style: StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
          )
      ],
    );
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

  Widget _getSignatureWidget() {
    // ✅ If signature is uploaded, show it
    if (fieldController?.attachmentEntity != null) {
      return IntrinsicWidth(
        child: AttachmentUploadedWidget(
          isReadOnly: isReadOnly,
          onCloseTap: () {
            if (!isReadOnly) {
              Get.find<FillOutCubit>().removeSignature(
                controller: fieldController!,
              );
            }
          },
          attachmentEntity: fieldController!.attachmentEntity!,
        ),
      );
    }

    return customButtonWithSvg(
      title: 'Upload eSignature',
      function: () {
        if (isReadOnly) return;

        Get.find<FillOutCubit>().selectSignature(
          controller: fieldController!,
        );
      },
      textStyle: StyleText.fontSize14Weight500
                  .copyWith(color: AppColors.textButton),
      color: AppColors.primary,
      image: AppAssets.downloadLinear,
      widthImage: 20,
      heightImage: 20,
      colorBorder: AppColors.transparent,
      svgColor: AppColors.black,
    );
  }

  _isErrorNull(AttachmentEntity? file) {
    if (file == null) {
      return null;
    }
    return 'as';
  }

  String? _getError() {
    if (isValidated) {
      if (fieldController?.isRequired ?? false) {
        String? error = Validator.isEmpty(
          _isErrorNull(fieldController?.attachmentEntity),
          fieldController?.title?.text ?? '',
        );
        return error ?? '';
      }
    }
    return null;
  }
}