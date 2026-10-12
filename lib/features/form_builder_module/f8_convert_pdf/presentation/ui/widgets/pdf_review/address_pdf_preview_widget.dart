import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/text_required_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/address_field_model.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
class AddressPdfPreviewWidget extends StatelessWidget {
  const AddressPdfPreviewWidget({
    super.key,
    required this.model,
  });

  final AddressFieldModel model;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextRequiredWidget(
            isRequired: model.isRequired, text: 'Address'),
        _buildAddressInputFields(model),
      ],
    );
  }

  /// Build address input fields in a wrap layout
  Widget _buildAddressInputFields(AddressFieldModel model) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _generateAddressInputRows(model),
    );
  }

  /// Generate rows of address input fields
  List<Widget> _generateAddressInputRows(AddressFieldModel model) {
    List<Widget> rows = [];
    for (int i = 0; i < model.hints.length; i += 2) {
      String? sec;
      if (i + 1 < model.hints.length) {
        sec = model.hints[i + 1];
      } else {
        sec = null;
      }
      rows.add(_buildAddressInputRow(
          firstAddress: model.hints[i], secondAddress: sec));
    }
    return rows;
  }

  /// Build a row with two address input fields
  Widget _buildAddressInputRow(
      {required String firstAddress, String? secondAddress}) {
    return Row(
      children: [
        Expanded(
          child: _buildSingleAddressInput(firstAddress),
        ),
        if (secondAddress != null) ...[
          horizontalSpace(15),
          Expanded(
            child: _buildSingleAddressInput(secondAddress),
          ),
        ],
      ],
    );
  }

  /// Build single address input field
  Widget _buildSingleAddressInput(String hintText) {
    return CustomTextField(
        height: 36,
        contentPadding: EdgeInsets.symmetric(vertical: 12.sp, horizontal: 10.sp), // form bug report #40
        hint: hintText + ': ',
        maxLines: 1,
        readOnly: true,
        hintStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack),
        valueStyle: StyleText.fontSize12Weight400,
        fillColor: AppColors.background,
        width: double.infinity,
        obscureText: true,
      );
  }
}
