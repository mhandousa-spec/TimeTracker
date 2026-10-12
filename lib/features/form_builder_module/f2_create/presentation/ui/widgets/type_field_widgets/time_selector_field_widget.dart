import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart'; // Keep for .tr translations
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/time_selector_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/actions_row_widget.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
class TimeSelectorFieldWidget extends StatelessWidget {
  final int columnIndex;
  final int rowIndex;
  final int pageIndex;
  final bool isReadOnly;

  const TimeSelectorFieldWidget({
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

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleField(context, state),
            verticalSpace(18),
            _buildActionsRow()
          ],
        );
      },
    );
  }

  // Title field method
  Widget _buildTitleField(BuildContext context, CreateFormDataLoaded state) {
    final TimeSelectorFieldController controllers = state
        .pages[pageIndex]
        .rows[rowIndex]
        .controllers[columnIndex] as TimeSelectorFieldController;

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

  // Actions row method
  Widget _buildActionsRow() {
    if (isReadOnly) return const SizedBox.shrink();
    return ActionsRowWidget(
      pageIndex: pageIndex,
      columnIndex: columnIndex,
      rowIndex: rowIndex,
    );
  }
}