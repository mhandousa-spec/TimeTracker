import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/terms_conditions_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/alignment.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/actions_row_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/drop_down_widget.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/field_controller.dart';
/// Widget for creating a terms and conditions field
///
/// Features:
/// - Alignment selection dropdown
/// - Title input
/// - Arabic terms and conditions input
/// - English terms and conditions input
/// - Always required (no toggle)
class TermsAndConditionsFieldWidget extends StatelessWidget {
  /// Indices tracking widget's position in form
  final int columnIndex;
  final int rowIndex;
  final int pageIndex;
  final bool isReadOnly;

  const TermsAndConditionsFieldWidget({
    super.key,
    required this.columnIndex,
    required this.rowIndex,
    required this.pageIndex,
    this.isReadOnly = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateFormDataCubit, CreateFormDataState>(
      builder: (context, state) {
        if (state is! CreateFormDataLoaded) {
          return const SizedBox.shrink();
        }

        // Retrieve specific controller for terms and conditions field
        final TermsConditionsFieldController controller = state
            .pages[pageIndex]
            .rows[rowIndex]
            .controllers[columnIndex] as TermsConditionsFieldController;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Alignment dropdown
            _buildAlignmentDropdown(context, controller),
            verticalSpace(15),

            // Title input field
            _buildTitleField(context, controller),
            verticalSpace(15),

            // Arabic terms input
            _buildArabicTermsField(context, controller),
            verticalSpace(15),

            // English terms input
            _buildEnglishTermsField(context, controller),
            verticalSpace(15),

            // Actions row for form management
            _buildActionRow()
          ],
        );
      },
    );
  }

  /// Builds alignment dropdown
  Widget _buildAlignmentDropdown(
      BuildContext context,
      TermsConditionsFieldController controller,
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
      currentValue: controller.alignment,
    );
  }

  /// Builds title input field
  Widget _buildTitleField(
      BuildContext context,
      TermsConditionsFieldController controller,
      ) {
    return CustomTextField(
        height: 36,
        readOnly: isReadOnly,
        label: 'Add Title',
        controller: controller.title!,
        onChanged: (value) {
        // Trigger live update in A4 container
        context.read<CreateFormDataCubit>().updateFieldText(
          pageIndex: pageIndex,
          rowIndex: rowIndex,
          columnIndex: columnIndex,
        );
      },
      );
  }

  /// Builds Arabic terms and conditions input field
  Widget _buildArabicTermsField(
      BuildContext context,
      TermsConditionsFieldController controller,
      ) {
    return CustomTextField(
        height: 120,
        readOnly: isReadOnly,
        maxLines: 5,
        hint: "اكتب هنا",
        textDirection: TextDirection.rtl,
        label: "الشروط والاحكام",
        controller: controller.termsAr!,
        onChanged: (value) {
        // Trigger live update in A4 container
        context.read<CreateFormDataCubit>().updateFieldText(
          pageIndex: pageIndex,
          rowIndex: rowIndex,
          columnIndex: columnIndex,
        );
      },
      );
  }

  /// Builds English terms and conditions input field
  Widget _buildEnglishTermsField(
      BuildContext context,
      TermsConditionsFieldController controller,
      ) {
    return CustomTextField(
        height: 120,
        readOnly: isReadOnly,
        maxLines: 5,
        hint: "Text Here",
        textDirection: TextDirection.ltr,
        label: "Terms And Condition",
        controller: controller.termsEn!,
        onChanged: (value) {
        // Trigger live update in A4 container
        context.read<CreateFormDataCubit>().updateFieldText(
          pageIndex: pageIndex,
          rowIndex: rowIndex,
          columnIndex: columnIndex,
        );
      },
      );
  }

  /// Builds action row for form management
  Widget _buildActionRow() {
    if (isReadOnly) return const SizedBox.shrink();
    return ActionsRowWidget(
      pageIndex: pageIndex,
      rowIndex: rowIndex,
      columnIndex: columnIndex,
    );
  }
}