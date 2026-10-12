import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart'; // Keep for .tr and Get.back()
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/controller/result_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/controller/result_state.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/data/utils/picker_helper.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/helper/form_builder/app_dialogs.dart';
import 'package:knowticed_plus/core/custom/45-custom_app_dropdown.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
class SearchBarSubmissionsWidget extends StatelessWidget {
  const SearchBarSubmissionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    bool showText = widthScreen > 1200;

    return BlocBuilder<ResultCubit, ResultState>(
      builder: (context, state) {
        if (state is! ResultLoaded) {
          return const SizedBox.shrink();
        }

        final cubit = context.read<ResultCubit>();

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildSearchBar(context, widthScreen, cubit, state),
            if (ContextExtension(context).isTablett) ...[
              _buildSpace(context),
              _buildDropDown(cubit, state),
            ],
            if (!ContextExtension(context).isTablett) ...[
              _buildSpace(context),
              _buildIconWidget(
                asset: AppAssets.export,
                text: '',
                onTap: () {
                  AppDialogs.downloadFile(
                    state.textEditingController,
                    context,
                        () {
                      cubit.exportToCSV(
                          state.textEditingController.text.trim());
                      Get.back();
                    },
                  );
                },
                showText: showText,
                isPrime: true,
              ),
            ]
          ],
        );
      },
    );
  }

  Widget _buildSpace(BuildContext context) {
    double space = ContextExtension(context).isPhone ? 10 : 15;
    return horizontalSpace(space);
  }

  Widget _buildSearchBar(
      BuildContext context,
      double widthScreen,
      ResultCubit cubit,
      ResultLoaded state,
      ) {
    return Expanded(
      child: CustomTextField(
        height: 38,
        hint: 'Search',
        maxLines: 1,
        fillColor: AppColors.card,
        hintStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.secondaryBlack),
        prefixIcon: SvgPicture.asset(
          AppAssets.search,
          colorFilter:
          ColorFilter.mode(AppColors.secondaryBlack, BlendMode.srcIn),
        ),
        controller: state.searchController,
        onChanged: (value) {
          cubit.search();
        },
      ),
    );
  }

  Widget _buildIconWidget({
    required String asset,
    required String text,
    Function()? onTap,
    required bool showText,
    bool isPrime = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        width: showText ? (isPrime ? 150 : 100) : 38,
        decoration: BoxDecoration(
          color: isPrime ? AppColors.primary : AppColors.card,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          shape: BoxShape.rectangle,
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: SvgPicture.asset(
                  asset,
                  colorFilter: ColorFilter.mode(
                    isPrime ? AppColors.black : AppColors.secondaryText,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              if (showText) ...[
                horizontalSpace(8),
                Text(
                  text,
                  style: StyleText.fontSize16Weight500.copyWith(color: AppColors.secondaryText).copyWith(
                    color: isPrime ? AppColors.black : null,
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropDown(ResultCubit cubit, ResultLoaded state) {
    return Container(
      height: 38,
      width: 150,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        shape: BoxShape.rectangle,
      ),
      child: Center(
        child: AppDropdown(
          borderRadius: 8.r, // form bug report #8/#35: 8.r dropdowns
          fillColor: AppColors.card,
          width: double.infinity,
          textButton: 'Department',
          value: state.selectedDepartmentFilter,
          items: PickerHelper.departments.map((String department) {
            return DropdownMenuItem<String>(
              value: department,
              child: Text(
                FormatHelper.capitalize(department),
                style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack),
              ),
            );
          }).toList(),
          onChanged: (p0) {
            cubit.updateSelectedDepartmentFilter(p0);
          },
        ),
      ),
    );
  }
}