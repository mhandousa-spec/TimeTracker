import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart'; // Keep for .tr translations
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/image_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/actions_row_widget.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
/// Widget for creating an image field in a dynamic form
class ImageFieldWidget extends StatelessWidget {
  const ImageFieldWidget({
    super.key,
    required this.columnIndex,
    required this.rowIndex,
    required this.pageIndex,
    this.isReadOnly = false,
  });

  final int columnIndex, rowIndex, pageIndex;
  final bool isReadOnly;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateFormDataCubit, CreateFormDataState>(
      builder: (context, state) {
        if (state is! CreateFormDataLoaded) {
          return const SizedBox.shrink();
        }

        final ImageFieldController controllers = state
            .pages[pageIndex]
            .rows[rowIndex]
            .controllers[columnIndex] as ImageFieldController;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title input field
            _buildTitleField(context, controllers),
            verticalSpace(15),

            // Limitation input field
            _buildLimitationField(context, controllers),
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
      ImageFieldController controllers,
      ) {
    return CustomTextField(
        height: 36,
        readOnly: isReadOnly,
        label: 'Add Title',
        onChanged: (p0) {
        // State updates automatically through text controller
      },
        controller: controllers.title!,
      );
  }

  /// Builds limitation input field
  Widget _buildLimitationField(
      BuildContext context,
      ImageFieldController controllers,
      ) {
    return CustomTextField(
        height: 36,
        readOnly: isReadOnly,
        label: 'Limitation',
        keyboardType: TextInputType.number,
        controller: controllers.limitation!,
        onChanged: (value) {
        controllers.insertImagesList(value);
        // State updates automatically through text controller
      },
      );
  }

  /// Builds action row for form management
  Widget _buildActionRow() {
    if (isReadOnly) {
      return const SizedBox.shrink();
    }
    return ActionsRowWidget(
      pageIndex: pageIndex,
      columnIndex: columnIndex,
      rowIndex: rowIndex,
    );
  }
}