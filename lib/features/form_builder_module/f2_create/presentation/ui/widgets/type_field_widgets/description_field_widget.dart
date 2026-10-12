import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart'; // Keep for .tr translations
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/description_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/alignment.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/actions_row_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/drop_down_widget.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/field_controller.dart';
/// Widget for creating a description field in dynamic form
class DescriptionFieldWidget extends StatelessWidget {
  final int columnIndex, rowIndex, pageIndex;
  final bool isReadOnly;

  const DescriptionFieldWidget({
    super.key,
    required this.columnIndex,
    required this.rowIndex,
    required this.pageIndex,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateFormDataCubit, CreateFormDataState>(
      builder: (context, state) {
        if (state is! CreateFormDataLoaded) {
          return const SizedBox.shrink();
        }

        final DescriptionFieldController controllers = state
            .pages[pageIndex]
            .rows[rowIndex]
            .controllers[columnIndex] as DescriptionFieldController;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title input field
            _buildTitleField(context, controllers),
            verticalSpace(15),

            // Hint input field
            _buildHintField(context, controllers),
            verticalSpace(15),

            // Limitation input field
            _buildLimitationField(context, controllers),
            verticalSpace(15),

            // Alignment dropdown
            _buildAlignmentDropdown(context, controllers),
            verticalSpace(18),

            // Actions row for form management
            _buildActionRow()
          ],
        );
      },
    );
  }

  /// Builds title input field
  Widget _buildTitleField(
      BuildContext context,
      DescriptionFieldController controllers,
      ) {
    return CustomTextField(
        height: 36,
        readOnly: isReadOnly,
        label: 'Add Title',
        onChanged: (value) {
        // ✅ Trigger live update in A4 container
        context.read<CreateFormDataCubit>().updateFieldText(
          pageIndex: pageIndex,
          rowIndex: rowIndex,
          columnIndex: columnIndex,
        );
      },
        controller: controllers.title!,
      );
  }

  /// Builds hint input field
  Widget _buildHintField(
      BuildContext context,
      DescriptionFieldController controllers,
      ) {
    return CustomTextField(
        height: 36,
        readOnly: isReadOnly,
        label: 'Add Hint',
        onChanged: (value) {
        // ✅ Trigger live update in A4 container
        context.read<CreateFormDataCubit>().updateFieldText(
          pageIndex: pageIndex,
          rowIndex: rowIndex,
          columnIndex: columnIndex,
        );
      },
        controller: controllers.hint!,
      );
  }

  /// Builds limitation input field
  Widget _buildLimitationField(
      BuildContext context,
      DescriptionFieldController controllers,
      ) {
    return CustomTextField(
        height: 36,
        readOnly: isReadOnly,
        label: 'Limitation',
        onChanged: (value) {
        // ✅ Trigger live update in A4 container
        context.read<CreateFormDataCubit>().updateFieldText(
          pageIndex: pageIndex,
          rowIndex: rowIndex,
          columnIndex: columnIndex,
        );
      },
        keyboardType: TextInputType.number,
        // ✅ ALLOW BOTH ENGLISH AND ARABIC NUMERALS
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9\u0660-\u0669]')),
      ],
        controller: controllers.limitation!,
      );
  }

  /// Builds alignment dropdown
  Widget _buildAlignmentDropdown(
      BuildContext context,
      DescriptionFieldController controllers,
      ) {
    return DropDownWidget(
      onChanged: (value) {
        if (isReadOnly) return;
        context.read<CreateFormDataCubit>().changeAlignmentValue(
          pageIndex: pageIndex,
          value: value,
          rowIndex: rowIndex,
          columnIndex: columnIndex,
        );
      },
      title: 'Choose Alignment',
      hint: 'Choose Alignment',
      items: AlignmentEnumExtension.dropDownItems,
      currentValue: controllers.alignment,
    );
  }

  /// Builds action row for form management
  Widget _buildActionRow() {
    if (isReadOnly) return const SizedBox.shrink();
    return ActionsRowWidget(
      pageIndex: pageIndex,
      columnIndex: columnIndex,
      rowIndex: rowIndex,
    );
  }
}