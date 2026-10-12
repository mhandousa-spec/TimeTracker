import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/alignment.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/text_required_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/description_field_model.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';

class DescriptionPdfResultWidget extends StatelessWidget {
  const DescriptionPdfResultWidget({
    super.key,
    required this.model,
    this.isExpand = false,
  });

  final isExpand;
  final DescriptionFieldModel model;

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: model.alignment.alignment,
        child: SizedBox(
          width: isExpand ? null : _calculateWidth(context, model),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextRequiredWidget(
                  isRequired: model.isRequired, text: model.title),
              verticalSpace(8),
              _buildDescriptionTextField(model),
            ],
          ),
        ));
  }

  /// Calculate widget width based on alignment and device type
  double _calculateWidth(
    BuildContext context,
    DescriptionFieldModel model,
  ) {
    return model.alignment != AlignmentEnum.expand.name
        ? (ContextExtension(context).isTablett ? 200.w : 365.w)
        : double.infinity;
  }

  /// Build description text input field
  Widget _buildDescriptionTextField(DescriptionFieldModel model) {
    return CustomTextField(
        maxLines: 3,
        fillColor: AppColors.background,
        hintStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack),
        valueStyle: StyleText.fontSize12Weight400,
        enabled: false,
        width: double.infinity,
      );
  }
}
