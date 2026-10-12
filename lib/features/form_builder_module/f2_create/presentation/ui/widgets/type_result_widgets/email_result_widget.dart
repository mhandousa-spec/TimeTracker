import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/helper/role/validator.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/email_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/email_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/alignment.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/text_required_widget.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';

class EmailResultWidget extends StatelessWidget {
  const EmailResultWidget(
      {super.key,
      this.reviewModel,
      this.fieldController,
      this.isValidated = false,
      this.isReadOnly = false,
      this.isExpand = false,
      this.onChanged,
      this.isWhiteFill = false});
  final bool isExpand;
  final EmailFieldController? fieldController;
  final EmailFieldModel? reviewModel;
  final bool isValidated, isWhiteFill, isReadOnly;
  final Function(String)? onChanged;
  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: _getAlignment(), child: _buildFieldContainer(context));
  }

  // Build the container with field details
  Widget _buildFieldContainer(BuildContext context) {
    return SizedBox(
      width: isExpand ? null : _calculateWidth(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show required indicator
          TextRequiredWidget(
            isRequired: _getIsRequired(),
            text: _getTitle(),
          ),
          verticalSpace(4),
          _buildTextField(),
        ],
      ),
    );
  }

  // Calculate width based on alignment
  double _calculateWidth(BuildContext context) {
    String? alignment = fieldController != null
        ? fieldController!.alignment
        : reviewModel!.alignment;

    return alignment != AlignmentEnum.expand.name
        ? (ContextExtension(context).isTablett ? 200.w : 365.w)
        : double.infinity;
  }

  // Build the text form field
  Widget _buildTextField() {
    return CustomTextField(
        height: 36,
        maxLines: 1,
        contentPadding: EdgeInsets.symmetric(vertical: 12.sp, horizontal: 10.sp),
        initialValue: fieldController?.answer,
        onChanged: onChanged,
        readOnly: isReadOnly,
        hint: _getHint(),
        keyboardType: TextInputType.emailAddress,
        fillColor: isWhiteFill ? AppColors.white : AppColors.background,
        width: double.infinity,
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

  String _getHint() {
    if (reviewModel != null) {
      return reviewModel?.hint ?? '';
    }
    return fieldController?.hint?.text ?? '';
  }

  Alignment _getAlignment() {
    if (reviewModel == null) {
      return fieldController!.alignment!.alignment;
    }
    return reviewModel!.alignment.alignment;
  }

  _getValidate(String? value) {
    if (isValidated) {
      if (fieldController?.isRequired ?? false) {
        String? error =
            Validator.isEmpty(value, fieldController?.title?.text ?? '');
        error = error ?? Validator.isEmailValid(value!);
        return error;
      } else {
        if (value?.isNotEmpty ?? false) {
          return Validator.isEmailValid(value!);
        }
        return null;
      }
    } else {
      return null;
    }
  }
}
