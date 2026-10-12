import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/alignment.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/text_required_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/text_field_model.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';

class TextFieldPdfResultWidget extends StatelessWidget {
  const TextFieldPdfResultWidget({
    super.key,
    required this.model,
    this.isExpand = false,
  });
  final bool isExpand; // Not used in this widget, can be removed
  final TextFieldModel model;
  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: model.alignment.alignment,
        child: _buildFieldContainer(context, model));
  }

  // Build the container with field details
  Widget _buildFieldContainer(BuildContext context, TextFieldModel model) {
    return SizedBox(
      width: isExpand ? null : _calculateWidth(context, model),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show required indicator
          TextRequiredWidget(isRequired: model.isRequired, text: model.title),
          verticalSpace(8),
          _buildTextField(model),
        ],
      ),
    );
  }

  // Calculate width based on alignment
  double _calculateWidth(BuildContext context, TextFieldModel model) {
    return model.alignment != AlignmentEnum.expand.name
        ? (ContextExtension(context).isTablett ? 200.w : 365.w)
        : double.infinity;
  }

  // Build the text form field
  Widget _buildTextField(TextFieldModel model) {
    return CustomTextField(
        height: 36,
        contentPadding: EdgeInsets.symmetric(vertical: 12.sp, horizontal: 10.sp), // form bug report #40
        hint: '',
        enabled: false,
        maxLines: 1,
        hintStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack),
        valueStyle: StyleText.fontSize12Weight400,
        fillColor: AppColors.background,
        width: double.infinity,
        // Note: This creates a new controller each time,
      );
  }
}
