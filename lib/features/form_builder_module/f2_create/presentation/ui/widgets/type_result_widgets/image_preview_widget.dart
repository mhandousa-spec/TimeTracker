// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/helper/role/validator.dart';
import 'package:knowticed_plus/features/form_builder_module/f4_fillout/presentation/controller/fill_out_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/image_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/image_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/text_required_widget.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/helper/main_helper/extensions.dart';
class ImagePreviewWidget extends StatelessWidget {
  const ImagePreviewWidget(
      {super.key,
      this.reviewModel,
      this.fieldController,
      this.isReadOnly = false,
      this.isValidated = false,
      this.isShownError = false});
  final ImageFieldController? fieldController;
  final ImageFieldModel? reviewModel;
  final bool isValidated, isShownError, isReadOnly;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextRequiredWidget(isRequired: _getIsRequired(), text: _getTitle()),
        verticalSpace(4),
        Wrap(
          spacing: 5.w,
          runSpacing: 10.h,
          children: _getImages(context),
        ),
        verticalSpace(4),
        if (isShownError && _isErrorNull(fieldController?.images) == null)
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

  List<Widget> _getImages(BuildContext context) {
    List<Widget> images = [];
    if (reviewModel == null) {
      while (fieldController!.imagesLink.length <
          fieldController!.limitation!.text.toEnglishNumber()) {
        fieldController!.imagesLink.add(null);
      }
      images = fieldController!.imagesLink.asMap().entries.map<Widget>((entry) {
        int indexImage = entry.key;
        var image = entry.value;

        
        return InkWell(
            onTap: () async {
              if (!isReadOnly && isValidated) {
                await Get.find<FillOutCubit>().changeImage(
                    controller: fieldController!, imageIndex: indexImage);

              }
            },
            child: Container(
              height: 89.w,
              width: 89.w,
              decoration: BoxDecoration(
                image: image == null || image.isEmpty || image == 'null'
                    ? null
                    : DecorationImage(
                        image: (image.contains('http'))
                            ? NetworkImage(image)
                            : FileImage(File(image))),
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: image == null || image.isEmpty || image == 'null'
                  ? Center(
                      // Add Center widget
                      child: SvgPicture.asset(
                        AppAssets.image,
                        height: 52,
                        width: 52,
                        color: AppColors.secondaryText,
                        fit: BoxFit.contain, // Change to contain
                      ),
                    )
                  : null,
            ));
      }).toList();

      return images;
    }
    for (int i = 0; i < reviewModel!.limitation.toEnglishNumber(); i++) {
      images.add(InkWell(
        onTap: () {
        },
        child: Container(
          height: 89.w,
          width: 89.w,
          padding: const EdgeInsets.symmetric(horizontal: 40),
          decoration: ShapeDecoration(
            color: AppColors.disabledGrey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Center(
            // Add Center widget
            child: SvgPicture.asset(
              AppAssets.image,
              height: 52,
              width: 52,
              fit: BoxFit.contain, // Change to contain
            ),
          ),
        ),
      ));
    }
    return images;
  }

  String? _getError() {
    if (isValidated) {
      if (fieldController?.isRequired ?? false) {
        String? error = Validator.isEmpty(
            _isErrorNull(fieldController?.images), 'Image');
        return error ?? '';
      }
    }
    return null;
  }

  String? _isErrorNull(List<File?>? images) {
    bool flagIsNull = false;
    if (fieldController?.isRequired ?? false) {
      images?.forEach(
        (element) {
          if (element == null) {
            flagIsNull = true;
            return;
          }
        },
      );
    }

    return flagIsNull ? null : 'text';
  }
}
