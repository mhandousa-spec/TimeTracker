import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart'; // Keep for .tr translations

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/drop_down_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/alignment.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/actions_row_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/drop_down_widget.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/field_controller.dart';
/// Widget for creating a dropdown field in dynamic form
class DropDownFieldWidget extends StatelessWidget {
  final int columnIndex, rowIndex, pageIndex;
  final bool isReadOnly;

  const DropDownFieldWidget({
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

        final DropDownFieldController controllers = state
            .pages[pageIndex]
            .rows[rowIndex]
            .controllers[columnIndex] as DropDownFieldController;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title input field
            _buildTitleField(context, controllers),
            verticalSpace(15),

            // Options section header
            _buildOptionsSectionHeader(),

            // Dynamic options list
            ..._buildOptionsList(context, controllers),

            verticalSpace(8),

            // Add option button
            _buildAddOptionButton(context),
            verticalSpace(18),

            // Alignment dropdown
            _buildAlignmentDropdown(context, controllers),
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
      DropDownFieldController controllers,
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

  /// Builds title input field
  Widget _buildTitleField(
      BuildContext context,
      DropDownFieldController controllers,
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

  /// Builds options section header
  Widget _buildOptionsSectionHeader() {
    return Text(
      'Add Options',
      style: StyleText.fontSize14Weight400,
    );
  }

  /// Builds dynamic options list
  List<Widget> _buildOptionsList(
      BuildContext context,
      DropDownFieldController controllers,
      ) {
    return List.generate(
      controllers.hints.length,
          (i) => [
        i != 0 ? verticalSpace(10) : verticalSpace(8),
        CustomTextField(
        readOnly: isReadOnly,
        height: 36,
        hint: 'Text Here',
        maxLines: 1,
        fillColor: AppColors.background,
        width: double.infinity,
        controller: controllers.hints[i],
        onChanged: (value) {
            // ✅ Trigger live update in A4 container
            context.read<CreateFormDataCubit>().updateFieldText(
              pageIndex: pageIndex,
              rowIndex: rowIndex,
              columnIndex: columnIndex,
            );
          },
        suffixIcon: (controllers.hints.length > 2)
              ? InkWell(
            onTap: () {
              if (isReadOnly) return;
              context.read<CreateFormDataCubit>().removeOption(
                rowIndex: rowIndex,
                columnIndex: columnIndex,
                optionIndex: i,
                pageIndex: pageIndex,
              );
            },
            child: SvgPicture.asset(
              AppAssets.cancel,
              // Bug report #2: was drawn at the svg's natural size.
              width: 18.sp,
              height: 18.sp,
            ),
          )
              : const SizedBox.shrink(),
      )
      ],
    ).expand((element) => element).toList();
  }

  /// Builds add option button
  Widget _buildAddOptionButton(BuildContext context) {
    if (isReadOnly) return const SizedBox.shrink();
    return InkWell(
      onTap: () => context.read<CreateFormDataCubit>().addOption(
        pageIndex: pageIndex,
        columnIndex: columnIndex,
        rowIndex: rowIndex,
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            AppAssets.addOption,
            colorFilter: ColorFilter.mode(AppColors.text, BlendMode.srcIn),
          ),
          horizontalSpace(6),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${'Add Option Or'} ',
                  style: StyleText.fontSize12Weight400,
                ),
                TextSpan(
                  text: 'Add "other"',
                  style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack),
                ),
              ],
            ),
          ),
        ],
      ),
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