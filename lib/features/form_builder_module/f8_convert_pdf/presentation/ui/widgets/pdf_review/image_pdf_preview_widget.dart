// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import  'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import  'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/text_required_widget.dart';
import  'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/image_field_model.dart';

import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/core/helper/main_helper/extensions.dart';

class ImagePdfPreviewWidget extends StatelessWidget {
  const ImagePdfPreviewWidget({
    super.key,
    required this.model,
  });
  final ImageFieldModel model;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextRequiredWidget(
          isRequired: model.isRequired,
          text: model.title,
        ),
        verticalSpace(8),
        SizedBox(
          width: double.infinity,
          child: Wrap(
            children: List.generate(model.limitation.toEnglishNumber(), (index) {
              return Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: Container(
                  height: 72,
                  width: 72,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: const BorderRadius.all(Radius.circular(4))
                  ),
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: 45,
                    width: 45,
                    child: SvgPicture.asset(AppAssets.image,
                      colorFilter: ColorFilter.mode(AppColors.text, BlendMode.srcIn),),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
