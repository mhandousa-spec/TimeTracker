import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:get/get.dart'; // Keep for .tr translations

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/address_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/actions_row_widget.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/field_controller.dart';
/// Widget for creating dynamic address field inputs with multiple hints
///
/// This widget allows users to:
/// - Add a title for the address field
/// - Add multiple hint text fields
/// - Remove hint fields (if more than one exists)
/// - Trigger live view updates on changes
class AddressFieldWidget extends StatelessWidget {
  /// Indices to track the widget's position in the form
  final int columnIndex;
  final int rowIndex;
  final int pageIndex;
  final bool isReadOnly;

  /// Constructor with required positional parameters
  const AddressFieldWidget({
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

        // Initialize controllers for form data and address field
        final addressController = _getAddressController(state);

        // Construct the main column layout for the address field
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Build title input section
            _buildTitleSection(addressController, context),

            // Build list of hint text fields
            _buildHintList(addressController, context),
            verticalSpace(8),

            // Add button to create new hint fields
            _buildAddOptionButton(addressController, context),

            // Actions row for form management
            ActionsRowWidget(
              pageIndex: pageIndex,
              rowIndex: rowIndex,
              columnIndex: columnIndex,
            )
          ],
        );
      },
    );
  }

  /// Retrieve the specific address field controller based on indices
  AddressFieldController _getAddressController(CreateFormDataLoaded state) {
    return state.pages[pageIndex].rows[rowIndex].controllers[columnIndex]
    as AddressFieldController;
  }

  /// Build the title input section with validation
  Widget _buildTitleSection(
      AddressFieldController addressController,
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
        controller: addressController.title!,
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

  /// Generate list of hint text fields dynamically
  Widget _buildHintList(
      AddressFieldController addressController,
      BuildContext context,
      ) {
    return Column(
      children: List.generate(
        addressController.hints!.length,
            (index) => _buildHintTextField(addressController, context, index),
      ),
    );
  }

  /// Create individual hint text field with remove option
  Widget _buildHintTextField(
      AddressFieldController addressController,
      BuildContext context,
      int index,
      ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        index != 0 ? verticalSpace(10) : verticalSpace(8),
        SizedBox(
          child: CustomTextField(
        readOnly: isReadOnly,
        height: 36,
        onChanged: (value) {
              // ✅ Trigger live update in A4 container
              context.read<CreateFormDataCubit>().updateFieldText(
                pageIndex: pageIndex,
                rowIndex: rowIndex,
                columnIndex: columnIndex,
              );
            },
        hint: 'Text Here',
        maxLines: 1,
        fillColor: AppColors.background,
        width: double.infinity,
        controller: addressController.hints![index],
        // Optional remove icon for hint fields
            suffixIcon: _buildRemoveOptionIcon(
              addressController,
              context,
              index,
            ),
      ),
        ),
      ],
    );
  }

  /// Build remove icon for hint fields (hidden if only one hint exists)
  Widget _buildRemoveOptionIcon(
      AddressFieldController addressController,
      BuildContext context,
      int index,
      ) {
    // Don't show remove icon if only one hint exists
    if (addressController.hints!.length <= 1 || isReadOnly) {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: () => context.read<CreateFormDataCubit>().removeOption(
        rowIndex: rowIndex,
        columnIndex: columnIndex,
        optionIndex: index,
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

  /// Create button to dynamically add new hint fields
  Widget _buildAddOptionButton(
      AddressFieldController addressController,
      BuildContext context,
      ) {
    if (isReadOnly) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          // Add new text editing controller to hints
          context.read<CreateFormDataCubit>().addOption(
            columnIndex: columnIndex,
            pageIndex: pageIndex,
            rowIndex: rowIndex,
          );
        },
        child: Row(
          children: [
            SvgPicture.asset(
              width: 14.w,
              height: 14.h,
              AppAssets.addOption,
              colorFilter: ColorFilter.mode(AppColors.text, BlendMode.srcIn),
            ),
            const SizedBox(width: 6),
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
      ),
    );
  }
}