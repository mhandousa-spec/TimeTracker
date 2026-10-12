import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart'; // Keep for .tr translations

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/radio_text_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/actions_row_widget.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/field_controller.dart';
class RadioTextFieldWidget extends StatelessWidget {
  final int columnIndex;
  final int rowIndex;
  final int pageIndex;
  final bool isReadOnly;

  const RadioTextFieldWidget({
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
            verticalSpace(15),
            _buildActionsRow()
          ],
        );
      },
    );
  }

  // Title field method
  Widget _buildTitleField(BuildContext context, CreateFormDataLoaded state) {
    final RadioTextFieldController controllers = state
        .pages[pageIndex]
        .rows[rowIndex]
        .controllers[columnIndex] as RadioTextFieldController;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Options',
          style: StyleText.fontSize14Weight400,
        ),
        // Generate option fields dynamically
        ...List.generate(
          controllers.hints.length,
              (i) => _buildOptionField(context, state, i),
        ),
        verticalSpace(8),
        _buildAddOptionButton(context)
      ],
    );
  }

  // Individual option field method
  Widget _buildOptionField(
      BuildContext context,
      CreateFormDataLoaded state,
      int i,
      ) {
    final RadioTextFieldController controllers = state
        .pages[pageIndex]
        .rows[rowIndex]
        .controllers[columnIndex] as RadioTextFieldController;

    return Column(
      children: [
        i != 0 ? verticalSpace(10) : verticalSpace(8),
        CustomTextField(
        readOnly: isReadOnly,
        height: 36,
        hint: 'Text Here',
        maxLines: 1,
        onChanged: (value) {
            // ✅ Trigger live update in A4 container
            context.read<CreateFormDataCubit>().updateFieldText(
              pageIndex: pageIndex,
              rowIndex: rowIndex,
              columnIndex: columnIndex,
            );
          },
        fillColor: AppColors.background,
        width: double.infinity,
        controller: controllers.hints[i],
        prefixIcon: Container(
            width: 15.w,
            height: 15.h,
            margin: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.borderGrey,
                width: 2,
              ),
              color: AppColors.background,
            ),
          ),
        suffixIcon: (controllers.hints.length > 2 && !isReadOnly)
              ? _buildRemoveOptionIcon(context, i)
              : const SizedBox.shrink(),
      ),
      ],
    );
  }

  // Remove option icon method
  Widget _buildRemoveOptionIcon(BuildContext context, int i) {
    return InkWell(
      onTap: () => context.read<CreateFormDataCubit>().removeOption(
        rowIndex: rowIndex,
        columnIndex: columnIndex,
        optionIndex: i,
        pageIndex: pageIndex,
      ),
      child: SvgPicture.asset(
        AppAssets.cancel,
        // Bug report #2: was drawn at the svg's natural size.
        width: 18.sp,
        height: 18.sp,
      ),
    );
  }

  // Add option button method
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
          _buildAddOptionText()
        ],
      ),
    );
  }

  // Add option text method
  Widget _buildAddOptionText() {
    return RichText(
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
    );
  }

  // Actions row method
  Widget _buildActionsRow() {
    return ActionsRowWidget(
      pageIndex: pageIndex,
      columnIndex: columnIndex,
      rowIndex: rowIndex,
      showIsRequired: false,
    );
  }
}