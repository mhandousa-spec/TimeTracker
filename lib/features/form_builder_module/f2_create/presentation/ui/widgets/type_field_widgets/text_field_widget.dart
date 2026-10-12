import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart'; // Keep for .tr translations and locale
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/helper/role/validator.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/text_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/alignment.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/actions_row_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/drop_down_widget.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/helper/main_helper/extensions.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/field_controller.dart';
class TextFieldWidget extends StatelessWidget {
  final int columnIndex;
  final int rowIndex;
  final int pageIndex;
  final bool isReadOnly;

  const TextFieldWidget({
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

        // Get the number of columns for this row
        final numColumnsText = state
            .pages[pageIndex]
            .rows[rowIndex]
            .numOfColumn!
            .text
            .toEnglishNumber();
        final numColumns = numColumnsText ?? 0;

        

        

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTitleField(context, state),
            verticalSpace(15),
            _buildHintField(context, state),
            // Only show alignment dropdown when there's exactly 1 column
            if (numColumns == 1) ...[
              verticalSpace(15),
              _buildAlignmentDropdown(context, state),
            ],

            verticalSpace(18),
            _buildActionsRow()
          ],
        );
      },
    );
  }

  // Validate language-specific input
  String? _validateLanguageInput(String? value, String fieldName) {
    // First check if empty
    final emptyError = Validator.isEmpty(value?.trim(), fieldName);
    if (emptyError != null) return emptyError;

    final isArabic = Get.locale?.languageCode == 'ar';
    final trimmedValue = value?.trim() ?? '';

    if (isArabic) {
      // Check if contains any English letters
      final hasEnglish = RegExp(r'[a-zA-Z]').hasMatch(trimmedValue);
      if (hasEnglish) {
        return 'يجب إدخال النص بالعربية فقط'; // Must enter text in Arabic only
      }
    } else {
      // Check if contains any Arabic letters
      final hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(trimmedValue);
      if (hasArabic) {
        return 'Must enter text in English only';
      }
    }

    return null;
  }

// Updated Title field with capitalization AND live preview
  Widget _buildTitleField(BuildContext context, CreateFormDataLoaded state) {
    final TextFieldController controllers = state
        .pages[pageIndex]
        .rows[rowIndex]
        .controllers[columnIndex] as TextFieldController;

    return CustomTextField(
        height: 36,
        label: 'Add Title',
        readOnly: isReadOnly,
        onChanged: (value) {
        // Apply capitalization
        final cursorPosition = controllers.title!.selection.base.offset;
        final capitalizedText = FormatHelper.capitalize(value);

        controllers.title!.value = TextEditingValue(
          text: capitalizedText,
          selection: TextSelection.collapsed(
            offset: cursorPosition.clamp(0, capitalizedText.length),
          ),
        );

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

// Updated Hint field with capitalization AND live preview
  Widget _buildHintField(BuildContext context, CreateFormDataLoaded state) {
    final TextFieldController controllers = state
        .pages[pageIndex]
        .rows[rowIndex]
        .controllers[columnIndex] as TextFieldController;

    return CustomTextField(
        height: 36,
        label: 'Add Hint',
        readOnly: isReadOnly,
        onChanged: (value) {
        // Apply capitalization
        final cursorPosition = controllers.hint!.selection.base.offset;
        final capitalizedText = FormatHelper.capitalize(value);

        controllers.hint!.value = TextEditingValue(
          text: capitalizedText,
          selection: TextSelection.collapsed(
            offset: cursorPosition.clamp(0, capitalizedText.length),
          ),
        );

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

  // Alignment dropdown method
  Widget _buildAlignmentDropdown(
      BuildContext context,
      CreateFormDataLoaded state,
      ) {
    final TextFieldController controllers = state
        .pages[pageIndex]
        .rows[rowIndex]
        .controllers[columnIndex] as TextFieldController;

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