import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart'; // Keep for .tr translations
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/controller/forms_group_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/controller/share_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/controller/share_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/ui/pages/group_screen.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/helper/form_builder/app_routes.dart';
import 'package:knowticed_plus/core/custom/45-custom_app_dropdown.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
class SearchBarShareWidget extends StatelessWidget {
  const SearchBarShareWidget({super.key, required this.form});
  final FormEntity form;

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    bool showText = widthScreen > 1200 ? true : false;

    return BlocBuilder<ShareCubit, ShareState>(
      builder: (context, state) {
        if (state is! ShareLoaded) {
          return const SizedBox.shrink();
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildSearchBar(context, state, widthScreen),
            if (ContextExtension(context).isTablett) ...[
              _buildSpace(context),
              _buildDropDown(context, state),
            ],
            _buildSpace(context),
            _buildIconWidget(
              context: context,
              asset: AppAssets.group,
              text: S.of(context).group,
              onTap: () {
                context.read<FormsGroupCubit>().resetGroupController();
                context.read<FormsGroupCubit>().getGroups();

                Navigator.push(context, MaterialPageRoute(builder: (_){
                  return GroupScreen(form: form);
                }));

              },
              showText: showText,
            ),
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
      ShareLoaded state,
      double widthScreen,
      ) {
    return AppSearchTextField(
      controller: state.searchController,
      onChanged: (value) {
        context.read<ShareCubit>().search();
      },
    );
  }

  Widget _buildIconWidget({
    required BuildContext context,
    required String asset,
    required String text,
    Function()? onTap,
    required bool showText,
    bool isPrime = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        width: showText ? (isPrime ? 150.w : 100.w) : 36.h,
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
                  style: StyleText.fontSize16Weight500.copyWith(color: AppColors.secondaryText)
                      .copyWith(color: isPrime ? AppColors.black : null),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropDown(BuildContext context, ShareLoaded state) {
    List<DropdownMenuItem<String>> items = [
      DropdownMenuItem<String>(
        value: "All", // ✅ Don't translate the value
        child: Text(
          S.of(context).all,
          style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack),
        ),
      ),
    ];

    items.addAll(
      Get.find<MainCoreDepartmentCubit>()
          .departmentModels
          .map((e) {
        final deptName = !context.isArabic
            ? FormatHelper.capitalize(e.departmentName!)
            : e.departmentNameInArabic!;

        return DropdownMenuItem<String>(
          value: deptName,
          child: Text(
            deptName,
            style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack),
          ),
        );
      })
          .toList(),
    );

    return SizedBox(
      height: 36,
      width: 150.w,
      child: AppDropdown(
        borderRadius: 8.r, // form bug report #8/#35: 8.r dropdowns
        menuItemHeight: 35.sp,
        width: 150.w,
        showErrorBorder: false,
        value: state.department ?? "All", // ✅ Default to "All"
        items: items,
        onChanged: (value) {
          context.read<ShareCubit>().updateDepartment(value);
          context.read<ShareCubit>().search();
        },
        textButton: S.of(context).department,
      ),
    );
  }
}