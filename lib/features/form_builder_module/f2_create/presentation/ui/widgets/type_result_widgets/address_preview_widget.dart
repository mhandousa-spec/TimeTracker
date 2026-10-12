import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/address_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/address_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/text_required_widget.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';

class AddressPreviewWidget extends StatelessWidget {
  const AddressPreviewWidget({
    super.key,
    this.fieldController,
    this.reviewModel,
    this.isValidated = false,
    this.isReadOnly = false,
    this.isWhiteFill = false,
    this.onChanged,
  });

  final AddressFieldController? fieldController;
  final AddressFieldModel? reviewModel;
  final bool isValidated, isWhiteFill, isReadOnly;
  final dynamic Function(String, int)? onChanged;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextRequiredWidget(
          isRequired: _getIsRequired(),
          text: _getTitle(),
        ),
        // FIXED: was verticalSpace(8), the same 4.h drift the dropdown had.
        // Every other widget in `type_result_widgets/` uses 4 between the title
        // and the input, so this one sat low beside a text field in a row.
        verticalSpace(4),
        _buildAddressInputFields(),
      ],
    );
  }

  /// Build address input fields in a wrap layout
  Widget _buildAddressInputFields() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _generateAddressInputRows(),
    );
  }

  /// Generate rows of address input fields
  List<Widget> _generateAddressInputRows() {
    List<Widget> rows = _getWidget();
    return rows;
  }

  List<Widget> _getWidget() {
    List<Widget> rows = [];
    if (reviewModel != null) {
      for (int i = 0; i < reviewModel!.hints.length; i += 2) {
        String? sec;
        if (i + 1 < reviewModel!.hints.length) {
          sec = reviewModel!.hints[i + 1];
        } else {
          sec = null;
        }
        rows.add(_buildAddressInputRow(
            firstAddress: reviewModel!.hints[i], secondAddress: sec, index: i));
      }
      return rows;
    } else {
      for (int i = 0; i < fieldController!.hints!.length; i += 2) {
        String? sec;
        if (i + 1 < fieldController!.hints!.length) {
          sec = fieldController!.hints?[i + 1].text;
        } else {
          sec = null;
        }
        rows.add(_buildAddressInputRow(
          firstAddress: fieldController!.hints![i].text,
          secondAddress: sec,
          index: i,
        ));
      }
      return rows;
    }
  }

  /// Build a row with two address input fields
  Widget _buildAddressInputRow(
      {required String firstAddress,
      String? secondAddress,
      required int index}) {
    return Row(
      children: [
        Expanded(
          child: _buildSingleAddressInput(firstAddress, index: index),
        ),
        if (secondAddress != null) ...[
          horizontalSpace(15),
          Expanded(
            child: _buildSingleAddressInput(secondAddress, index: (index + 1)),
          ),
        ],
      ],
    );
  }

  /// Build single address input field
  Widget _buildSingleAddressInput(String hintText, {required int index}) {
    return CustomTextField(
        height: 36,
        contentPadding: EdgeInsets.symmetric(vertical: 12.sp, horizontal: 10.sp), // form bug report #23
        hint: hintText,
        readOnly: isReadOnly,
        maxLines: 1,
        initialValue: getInitialValue(index),
        onChanged: onChanged != null ? (value) => onChanged!(value, index) : null,
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

  String? getInitialValue(int index) {
    if (fieldController?.answers == null) return null;
    if (fieldController!.answers!.isEmpty) return null;
    if (index >= fieldController!.answers!.length) return null;
    return fieldController!.answers![index];
  }
}
