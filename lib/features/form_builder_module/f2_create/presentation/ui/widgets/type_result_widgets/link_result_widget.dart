import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/helper/role/validator.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/link_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/link_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/alignment.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/text_required_widget.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/helper/main_helper/extensions.dart' hide ContextExtension;

class LinkResultWidget extends StatelessWidget {
  const LinkResultWidget({
    super.key,
    this.fieldController,
    this.reviewModel,
    this.isValidated = false,
    this.isReadOnly = false,
    this.onChanged,
    this.isExpand = false,
    this.isWhiteFill = false,
  });
  final bool isExpand; // Not used in this widget, can be removed
  final LinkFieldController? fieldController;
  final LinkFieldModel? reviewModel;
  final bool isValidated, isWhiteFill, isReadOnly;
  final void Function(String)? onChanged;
  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: _getAlignment(),
        child: SizedBox(
          width: isExpand ? null : _calculateWidth(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextRequiredWidget(
                isRequired: _getIsRequired(),
                text: _getTitle(),
              ),
              verticalSpace(4),
              _buildLinkTextField(),
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

  Alignment _getAlignment() {
    if (reviewModel == null) {
      return fieldController!.alignment!.alignment;
    }
    return reviewModel!.alignment.alignment;
  }

  /// Build link text input field
  Widget _buildLinkTextField() {
    return CustomTextField(
        height: 36,
        contentPadding: EdgeInsets.symmetric(vertical: 12.sp, horizontal: 10.sp), // form bug report #23
        hint: _getHint(),
        readOnly: isReadOnly,
        initialValue: fieldController?.answer,
        onChanged: onChanged,
        maxLines: 1,
        prefixIcon: SvgPicture.asset(AppAssets.link),
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

  _getValidate(String? value) {
    if (isValidated) {
      if (fieldController?.isRequired ?? false) {
        String? error =
            Validator.isEmpty(value, fieldController?.title?.text ?? '');
        error = error ?? Validator.isLink(value!);
        return error;
      } else {
        if (value?.isNotEmpty ?? false) {
          return Validator.isLink(value!);
        }
        return null;
      }
    } else {
      return null;
    }
  }
}
