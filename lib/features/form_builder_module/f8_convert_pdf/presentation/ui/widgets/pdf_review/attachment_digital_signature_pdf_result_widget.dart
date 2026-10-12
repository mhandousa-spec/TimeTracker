// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/text_required_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/attachment_digital_signature_field_model.dart';

import 'package:knowticed_plus/core/constants/space_helper.dart';

class AttachmentDigitalSignaturePdfResultWidget extends StatelessWidget {
  const AttachmentDigitalSignaturePdfResultWidget(
      {super.key, required this.model});
  final AttachmentDigitalSignatureFieldModel model;
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
        Container(
          height: 72,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.all(Radius.circular(4))
          ),
        )
      ],
    );
  }
}
