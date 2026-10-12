import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart'; // Keep for .tr translations

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/location_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/location_drop_down.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/actions_row_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/drop_down_widget.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
/// Widget for creating a location field in a dynamic form configuration
class LocationFieldWidget extends StatelessWidget {
  const LocationFieldWidget({
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

        final LocationFieldController controllers = state
            .pages[pageIndex]
            .rows[rowIndex]
            .controllers[columnIndex] as LocationFieldController;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleSection(controllers, context),

            // Location type dropdown
            _buildLocationTypeDropdown(context, controllers),
            verticalSpace(15),

            // Dynamic location fields based on selected type
            _buildLocationFields(context, controllers, rowIndex, columnIndex),
            verticalSpace(18),

            // Actions row for form management
            _buildActionRow()
          ],
        );
      },
    );
  }

  /// Builds location type dropdown
  Widget _buildLocationTypeDropdown(
      BuildContext context,
      LocationFieldController controllers,
      ) {
    return DropDownWidget(
      onChanged: (value) {
        if (isReadOnly) return;
        context.read<CreateFormDataCubit>().changeLocationTypeValue(
          value: value,
          rowIndex: rowIndex,
          columnIndex: columnIndex,
          pageIndex: pageIndex,
        );
      },
      title: 'Location Type',
      hint: 'Location Type',
      items: LocationDropDownExtension.dropDownItems,
      currentValue: controllers.locationType,
    );
  }

  /// Builds location fields based on selected location type
  Widget _buildLocationFields(
      BuildContext context,
      LocationFieldController controllers,
      int rowIndex,
      int index,
      ) {
    switch (LocationDropDownExtension.fromName(controllers.locationType!)) {
      case LocationDropDown.latitudeAndLongitude:
        return _buildLatitudeLongitudeFields(context, controllers);
      case LocationDropDown.link:
        return _buildLinkField(context, controllers);
      case null:
        return const SizedBox.shrink();
    }
  }

  /// Builds latitude and longitude input fields
  Widget _buildLatitudeLongitudeFields(
      BuildContext context,
      LocationFieldController controllers,
      ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomTextField(
        height: 36,
        readOnly: true,
        label: 'Location',
        hint: 'Latitude',
        onChanged: (value) {
            // ✅ Trigger live update in A4 container
            context.read<CreateFormDataCubit>().updateFieldText(
              pageIndex: pageIndex,
              rowIndex: rowIndex,
              columnIndex: columnIndex,
            );
          },
        controller: controllers.hintLatitude!,
      ),
        verticalSpace(10),
        CustomTextField(
        height: 36,
        readOnly: true,
        label: 'Location',
        hint: 'Longitude',
        onChanged: (value) {
            // ✅ Trigger live update in A4 container
            context.read<CreateFormDataCubit>().updateFieldText(
              pageIndex: pageIndex,
              rowIndex: rowIndex,
              columnIndex: columnIndex,
            );
          },
        controller: controllers.hintLongitude!,
      ),
      ],
    );
  }

  /// Builds link input field
  Widget _buildLinkField(
      BuildContext context,
      LocationFieldController controllers,
      ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
        height: 36,
        readOnly: isReadOnly,
        label: 'Add Hint',
        controller: controllers.hintLink!,
        onChanged: (value) {
            // ✅ Trigger live update in A4 container
            context.read<CreateFormDataCubit>().updateFieldText(
              pageIndex: pageIndex,
              rowIndex: rowIndex,
              columnIndex: columnIndex,
            );
          },
      ),
      ],
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

  Widget _buildTitleSection(
      LocationFieldController fieldController,
      BuildContext context,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title input field with validation
        CustomTextField(
        height: 36,
        readOnly: isReadOnly,
        label: 'Add Title',
        controller: fieldController.title,
        onChanged: (value) {
            // ✅ Trigger live update in A4 container
            context.read<CreateFormDataCubit>().updateFieldText(
              pageIndex: pageIndex,
              rowIndex: rowIndex,
              columnIndex: columnIndex,
            );
          },
      ),
        verticalSpace(15),

        // Hint label
        Text(
          'Add Hint',
          style: StyleText.fontSize14Weight400,
        ),
        verticalSpace(8),
      ],
    );
  }
}