// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/text_required_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/attachment_field_model.dart';

import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

class AttachmentPdfPreviewWidget extends StatelessWidget {
  const AttachmentPdfPreviewWidget({super.key, required this.model});
  final AttachmentFieldModel model;
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
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 8),
          child: Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: const BorderRadius.all(Radius.circular(8))
            ),
            alignment: Alignment.center,
            child: SizedBox(
              height: 45,
              width: 45,
              child: SvgPicture.asset(AppAssets.attachmentPdf,
                  colorFilter: ColorFilter.mode(AppColors.text, BlendMode.srcIn)),
            ),
          ),
        )
      ],
    );
  }
}
