
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/23-custom_check_box.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/helper/role/validator.dart';
import 'package:knowticed_plus/features/form_builder_module/f4_fillout/presentation/controller/fill_out_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f4_fillout/presentation/controller/fill_out_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/check_box_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/check_box_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/alignment.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/arrangement.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/text_required_widget.dart';

class CheckBoxResultWidget extends StatefulWidget {
  const CheckBoxResultWidget({
    super.key,
    this.fieldController,
    this.reviewModel,
    this.isValidated = false,
    this.isWhiteFill = false,
    this.isReadOnly = false,
    this.isShownError = false,
  });

  final CheckBoxFieldController? fieldController;
  final CheckBoxFieldModel? reviewModel;
  final bool isValidated, isWhiteFill, isShownError, isReadOnly;

  @override
  State<CheckBoxResultWidget> createState() => _CheckBoxResultWidgetState();
}

class _CheckBoxResultWidgetState extends State<CheckBoxResultWidget> {
  @override
  Widget build(BuildContext context) {
    final shouldBeInteractive = widget.isValidated && !widget.isReadOnly && widget.fieldController != null;

    return Align(
      alignment: _getAlignment(),
      child: SizedBox(
        width: _calculateWidth(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextRequiredWidget(isRequired: _getIsRequired(), text: _getTitle()),
            verticalSpace(4),

            // ✅ Simplified BlocBuilder - always rebuilds on state changes
            shouldBeInteractive
                ? BlocBuilder<FillOutCubit, FillOutState>(
              builder: (context, state) {
                return _buildCheckBoxOptions(context);
              },
            )
                : _buildCheckBoxOptions(context),

            verticalSpace(2),
            if (widget.isShownError && _isErrorNull(widget.fieldController?.options) == null)
              Text(
                _getError() ?? '',
                style: StyleText.fontSize12Weight500,
              )
          ],
        ),
      ),
    );
  }

  /// Calculate widget width based on alignment and device type
  double _calculateWidth(BuildContext context) {
    String? alignment = widget.fieldController != null
        ? widget.fieldController!.alignment
        : widget.reviewModel!.alignment;
    return alignment != AlignmentEnum.expand.name
        ? (ContextExtension(context).isTablett ? 200.w : 365.w)
        : double.infinity;
  }

  /// Build checkbox options based on arrangement
  Widget _buildCheckBoxOptions(BuildContext context) {
    return _getArrangement() == Arrangement.vertical.name
        ? _buildVerticalCheckBoxes(context)
        : _buildHorizontalCheckBoxes(context);
  }

  /// Build vertical checkbox options
  Column _buildVerticalCheckBoxes(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _buildCheckBoxRows(context),
    );
  }

  /// Build horizontal checkbox options
  Wrap _buildHorizontalCheckBoxes(BuildContext context) {
    return Wrap(
      children: _buildCheckBoxRows(context),
    );
  }

  /// Generate checkbox rows with options
  List<Widget> _buildCheckBoxRows(BuildContext context) {
    if (widget.fieldController != null) {
      return widget.fieldController!.options.asMap().entries.map<Widget>((entry) {
        var option = entry.value;
        // ✅ Pass only the object, not the boolean value
        return _buildCheckBoxRow(
          context,
          option.option.text,
          option,
        );
      }).toList();
    } else {
      return widget.reviewModel!.options.asMap().entries.map<Widget>((entry) {
        var optionText = entry.value;
        return _buildCheckBoxRow(
          context,
          optionText,
          null,
        );
      }).toList();
    }
  }

  /// Build individual checkbox row
  Widget _buildCheckBoxRow(
      BuildContext context,
      String option,
      CheckboxOptions? checkboxOption,
      ) {
    // ✅ Read value reactively inside the widget - updates on every rebuild
    final isSelected = checkboxOption?.value ?? false;

    // ✅ Determine if this checkbox is interactive
    final isInteractive = !widget.isReadOnly &&
        widget.isValidated &&
        widget.fieldController != null &&
        checkboxOption != null;

    return Container(
      margin: EdgeInsetsDirectional.only(bottom: 8.h, end: 8.w),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: isInteractive
                ? () {
           setState(() {
             
             context.read<FillOutCubit>().changeCheckBoxValue(
               checkboxOption!,
               widget.fieldController!,

             );
           });
            }
                : null,
            child: CustomCheckBox(
              isSelected: isSelected, // ✅ Now reactive to state changes
              borderColor: isInteractive ? AppColors.text : AppColors.grey,
            ),
          ),
          horizontalSpace(5),
          Flexible(
            child: Text(
              option,
              style: StyleText.fontSize14Weight500,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Get arrangement type (vertical or horizontal)
  String _getArrangement() {
    String? arrangement = widget.fieldController != null
        ? widget.fieldController!.arrangement
        : widget.reviewModel!.arrangement;
    return arrangement ?? Arrangement.vertical.name;
  }

  /// Get alignment for the widget
  Alignment _getAlignment() {
    if (widget.reviewModel == null) {
      return widget.fieldController!.alignment!.alignment;
    }
    return widget.reviewModel!.alignment.alignment;
  }

  /// Check if field is required
  bool _getIsRequired() {
    if (widget.reviewModel != null) {
      return widget.reviewModel?.isRequired ?? false;
    }
    return widget.fieldController?.isRequired ?? false;
  }

  /// Get field title
  String _getTitle() {
    if (widget.reviewModel != null) {
      return widget.reviewModel?.title ?? '';
    }
    return widget.fieldController?.title?.text ?? '';
  }

  /// Check if any checkbox option is selected (for required validation)
  String? _isErrorNull(List<CheckboxOptions>? options) {
    bool flagIsNull = false;
    if (widget.fieldController?.isRequired ?? false) {
      flagIsNull = true;
      options?.forEach(
            (element) {
          if (element.value) {
            flagIsNull = false;
            return;
          }
        },
      );
    }

    return flagIsNull ? null : 'valid';
  }

  /// Get validation error message
  String? _getError() {
    if (widget.isValidated) {
      if (widget.fieldController?.isRequired ?? false) {
        String? error = Validator.isEmpty(
          _isErrorNull(widget.fieldController?.options),
          widget.fieldController?.title?.text ?? '',
        );
        return error ?? '';
      }
    }
    return null;
  }
}