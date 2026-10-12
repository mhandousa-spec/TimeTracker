import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:get/get.dart'; // Keep for .tr translations and locale
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/helper/main_helper/arabic_number_format.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/title_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/alignment.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/actions_row_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/drop_down_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/type_field_widgets/title_field_sections.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/helper/main_helper/extensions.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/field_controller.dart';
class TitleFieldWidget extends StatelessWidget {
  final int columnIndex;
  final int rowIndex;
  final int pageIndex;
  final bool isReadOnly;

  const TitleFieldWidget({
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleField(context, state),

            // Only show alignment dropdown when there's exactly 1 column
            if (numColumns == 1) ...[
              verticalSpace(15),
              _buildAlignmentDropdown(context, state),
            ],

            verticalSpace(15),
            TitleTextFormattingSection(
              pageIndex: pageIndex,
              rowIndex: rowIndex,
              columnIndex: columnIndex,
              isReadOnly: isReadOnly,
              state: state,
            ),
            verticalSpace(15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TitleColorSection(
                  pageIndex: pageIndex,
                  rowIndex: rowIndex,
                  columnIndex: columnIndex,
                  isReadOnly: isReadOnly,
                  state: state,
                ),
                TitleTextSizeSection(
                  pageIndex: pageIndex,
                  rowIndex: rowIndex,
                  columnIndex: columnIndex,
                  isReadOnly: isReadOnly,
                  state: state,
                ),
              ],
            ),
            verticalSpace(18),
            _buildActionsRow()
          ],
        );
      },
    );
  }

  Widget _buildTitleField(BuildContext context, CreateFormDataLoaded state) {
    final TitleFieldController controllers = state
        .pages[pageIndex]
        .rows[rowIndex]
        .controllers[columnIndex] as TitleFieldController;

    return CustomTextField(
        height: 36,
        readOnly: isReadOnly,
        label: 'Title',
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
  Widget _buildAlignmentDropdown(
      BuildContext context,
      CreateFormDataLoaded state,
      ) {
    final TitleFieldController controllers = state
        .pages[pageIndex]
        .rows[rowIndex]
        .controllers[columnIndex] as TitleFieldController;
    List<DropdownMenuItem> items = AlignmentEnumExtension.dropDownItems;
    items.removeAt(AlignmentEnum.expand.index);
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
      items: items,
      currentValue: controllers.alignment,
    );
  }

  Widget _buildActionsRow() {
    if (isReadOnly) return const SizedBox.shrink();
    return ActionsRowWidget(
      pageIndex: pageIndex,
      showIsRequired: false,
      columnIndex: columnIndex,
      rowIndex: rowIndex,
    );
  }

  Future<void> pickColor(BuildContext context, Color titleColor) async {
    Color currentColor = titleColor;
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocBuilder<CreateFormDataCubit, CreateFormDataState>(
          builder: (context, state) {
            if (state is! CreateFormDataLoaded) {
              return const SizedBox.shrink();
            }

            return AlertDialog(
              backgroundColor: AppColors.background,
              title: const Text('Pick a color'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ColorPicker(
                      pickerColor: currentColor,
                      onColorChanged: (Color color) {
                        currentColor = color;
                        titleColor = color;
                      },
                    ),
                    verticalSpace(8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          S.of(dialogContext).savedColors,
                          style: StyleText.fontSize16Weight500,
                        ),
                        GestureDetector(
                          onTap: () {
                            context
                                .read<CreateFormDataCubit>()
                                .addToSavedColors(currentColor);
                          },
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                AppAssets.add,
                                colorFilter: ColorFilter.mode(
                                  AppColors.text,
                                  BlendMode.srcIn,
                                ),
                                height: 8,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                S.of(dialogContext).add,
                                style: StyleText.fontSize16Weight500,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    verticalSpace(8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      runAlignment: WrapAlignment.start,
                      alignment: WrapAlignment.start,
                      children: List.generate(
                        state.savedColors.length,
                            (index) {
                          return GestureDetector(
                            onTap: () {
                              currentColor = state.savedColors[index];
                              // Trigger rebuild by calling cubit method
                              context
                                  .read<CreateFormDataCubit>()
                                  .addToSavedColors(currentColor);
                            },
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: state.savedColors[index],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    verticalSpace(8),
                  ],
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: customButtonWithSvg(
                    title: 'Apply',
                    function: () {
                      Navigator.of(dialogContext).pop();
                      context.read<CreateFormDataCubit>().setTitleColor(
                        pageIndex: pageIndex,
                        columnIndex: columnIndex,
                        rowIndex: rowIndex,
                        color: titleColor,
                      );
                    },
                    textStyle: StyleText.fontSize16Weight500
                        .copyWith(color: AppColors.black),
                    color: AppColors.primary,
                    image: '',
                    widthImage: 0,
                    heightImage: 0,
                    colorBorder: AppColors.transparent,
                  ),
                )
              ],
            );
          },
        );
      },
    );
  }
}