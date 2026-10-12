// ignore_for_file: deprecated_member_use

import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/attachment_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f4_fillout/presentation/controller/fill_out_state.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/helper/role/validator.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/attachment_uploaded_widget.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/features/form_builder_module/f4_fillout/presentation/controller/fill_out_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/attachment_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/attachment_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/text_required_widget.dart';
class AttachmentPreviewWidget extends StatelessWidget {
  const AttachmentPreviewWidget({
    super.key,
    this.fieldController,
    this.reviewModel,
    this.isValidated = false,
    this.isWhiteFill = false,
    this.isReadOnly = false,
    this.isShownError = false,
  });

  final AttachmentFieldController? fieldController;
  final AttachmentFieldModel? reviewModel;
  final bool isValidated, isWhiteFill, isShownError, isReadOnly;

  @override
  Widget build(BuildContext context) {
    // Wrap with BlocBuilder to listen to state changes
    return BlocBuilder<FillOutCubit, FillOutState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextRequiredWidget(
              isRequired: _getIsRequired(),
              text: _getTitle(),
            ),

            _getAttachmentWidget(context),

            // ✅ Error message
            _getErrorWidget(),
          ],
        );
      },
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

  Widget _getAttachmentWidget(BuildContext context) {
    // Check if attachment exists
    if (fieldController?.attachmentEntity != null) {
      // ✅ Use IntrinsicWidth to fit content naturally
      return IntrinsicWidth(
        child: AttachmentUploadedWidget(
          isReadOnly: isReadOnly,
          onCloseTap: () {
            if (!isReadOnly) {
              context.read<FillOutCubit>().removeAttachment(
                controller: fieldController!,
              );
            }
          },
          attachmentEntity: fieldController!.attachmentEntity!,
        ),
      );
    }

    return customButtonWithSvg(
      title: 'Upload Attachment',
      function: () async {
        if (isReadOnly) return;

         // Debug
        await context.read<FillOutCubit>().selectAttachment(
          controller: fieldController!,
        );
         // Debug
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

  _getError() {
    if (isValidated) {
      if (fieldController?.isRequired ?? false) {
        String? error = Validator.isEmpty(
            _isErrorNull(fieldController?.attachmentEntity),
            fieldController?.title?.text ?? '');
        return error ?? '';
      }
    }
  }
}