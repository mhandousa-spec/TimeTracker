import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/alignment.dart' show AlignmentEnum, AlignmentFromStringExtension;
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/text_required_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/phone_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/alignment.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/text_required_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/phone_field_model.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';

class PhonePdfResultWidget extends StatelessWidget {
  const PhonePdfResultWidget({
    super.key,
    required this.model,
    this.isExpand = false,
  });
  final bool isExpand;

  final PhoneFieldModel model;

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: _getAlignment(),
        child: SizedBox(
          width: isExpand ? null : _calculateWidth(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleWidget(),
              verticalSpace(8),
              _buildPhoneInputRow(context),
            ],
          ),
        ));
  }

  /// Calculate widget width based on alignment and device type
  double _calculateWidth(BuildContext context) {
    String? alignment = model.alignment;

    return alignment != AlignmentEnum.expand.name
        ? (ContextExtension(context).isTablett ? 200.w : 365.w)
        : double.infinity;
  }

  /// Build title widget based on alignment
  Widget _buildTitleWidget() {
    return TextRequiredWidget(isRequired: _getIsRequired(), text: _getTitle());
  }

  /// Build phone input row with country code selector and phone number field
  Widget _buildPhoneInputRow(BuildContext context) {
    return Row(
      children: [
        _buildCountryCodeSelector(context),
        horizontalSpace(8),
        _buildPhoneNumberField(),
      ],
    );
  }

  /// Build country code selector container
  Widget _buildCountryCodeSelector(BuildContext context) {
    return Container(
      height: 36.sp, // #40: same scale as CustomTextField
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: _buildCountryCodeRow(),
      ),
    );
  }

  /// Build row with country flag, phone code, and dropdown arrow
  Row _buildCountryCodeRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          color: AppColors.background,
          child: Text(
            '+',
            style: TextStyle(
              fontSize: 14,
              backgroundColor: AppColors.transparent,
              color: AppColors.text,
            ),
          ),
        ),
        horizontalSpace(5),
      ],
    );
  }

  /// Build phone number input field
  Widget _buildPhoneNumberField() {
    return Expanded(
      child: Container(
        height: 36.sp, // #40: same scale as CustomTextField
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            horizontalSpace(16),
            Expanded(
              child: CustomTextField(
                readOnly: true,
                keyboardType: TextInputType.phone,
                fillColor: AppColors.transparent,
                borderRadius: BorderRadius.zero,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 0, vertical: 6.h),
                valueStyle: StyleText.fontSize14Weight400,
                hintStyle: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Alignment _getAlignment() {
    return model.alignment.alignment;
  }

  bool _getIsRequired() {
    bool flag = false;

    flag = model.isRequired;
    return flag;
  }

  String _getTitle() {
    return model.title;
  }
}
