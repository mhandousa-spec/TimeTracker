import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart'; // Keep for .tr translations
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/controller/forms_group_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/ui/pages/create_group_screen.dart';

import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/form/form_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/form/results_permissions.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/form/form_permissions.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/helper/form_builder/app_routes.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/47-custom_sort_button.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/controller/forms_group_state.dart';
import 'package:knowticed_plus/generated/l10n.dart';
class SearchFormGroupTablet extends StatelessWidget {
  const SearchFormGroupTablet({super.key, required this.form});
  final FormEntity form;

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    bool showText = widthScreen > 1200 ? true : false;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildSearchBar(context, widthScreen),
        _buildSpace(context),
        // #36: Sort, same component as the Form Builder home toolbar.
        BlocBuilder<FormsGroupCubit, FormsGroupState>(
          builder: (context, _) {
            final cubit = context.read<FormsGroupCubit>();
            final bool isTablet = ContextExtension(context).isTablett;
            return CustomSortButton<String>(
              value: cubit.groupSort,
              items: FormsGroupCubit.groupSortOptions,
              labelBuilder: FormsGroupCubit.groupSortLabel,
              showTitle: isTablet,
              width: isTablet ? 100.w : 38.sp,
              // Bug report p.9: same 38.sp box as the search field.
              height: 38.sp,
              onChanged: cubit.sortGroups,
            );
          },
        ),
        _buildSpace(context),
        // Bug report p.9: "Create Group" was missing. It was gated on the
        // section-level `Create_Group_Permissions_Module` key ONLY, which the
        // company's admin template does not grant yet — so nobody saw the
        // button. Anyone allowed to Share the form may also save the people
        // they share with as a group; the dedicated key still works on its own.
        if (_canCreateGroup())
        _buildIconWidget(
          context: context,
          asset: AppAssets.add,
          text: S.of(context).createGroup,
          onTap: () {
            context.read<FormsGroupCubit>().initCreateGroup();

            Navigator.push(context, MaterialPageRoute(builder: (_){
              return CreateGroupScreen(form: form);
            }));

          },
          showIcon: ContextExtension(context).isPhone ? true : false,
          showText: ContextExtension(context).isPhone ? false : true,
          isPrime: true,
        ),
      ],
    );
  }

  bool _canCreateGroup() {
    final MainCoreEmployeeController employee =
        Get.find<MainCoreEmployeeController>();
    return employee.isHasPermission(
          module: Modules.formBuilder,
          section: FormPermissionsSections.createGroupPermissions,
          permission: null,
        ) ||
        employee.isHasPermission(
          module: Modules.formBuilder,
          section: FormPermissionsSections.formPermissions,
          permission: FormPermissions.share,
        );
  }

  Widget _buildSpace(BuildContext context) {
    double space = ContextExtension(context).isPhone ? 10 : 15;
    return horizontalSpace(space);
  }

  Widget _buildSearchBar(BuildContext context, double widthScreen) {
    return Expanded(
      child: CustomTextField(
        height: 38,
        // Bug report p.9: same 8.r corners as Sort and Create Group.
        borderRadius: BorderRadius.circular(8.r),
        hint: S.of(context).search,
        maxLines: 1,
        fillColor: AppColors.card,
        hintStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.secondaryText),
        prefixIcon: SvgPicture.asset(
          AppAssets.search,
          colorFilter:
          ColorFilter.mode(AppColors.secondaryBlack, BlendMode.srcIn),
        ),
        // #36: search was a no-op stub.
        onChanged: (value) =>
            context.read<FormsGroupCubit>().searchGroups(value),
      ),
    );
  }

  Widget _buildIconWidget({
    required BuildContext context,
    required String asset,
    required String text,
    Function()? onTap,
    required bool showText,
    bool isPrime = false,
    bool showIcon = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38.sp,
        width: showText ? (isPrime ? 150.w : 100.w) : 38.sp,
        decoration: BoxDecoration(
          color: isPrime ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.all(Radius.circular(8.r)),
          shape: BoxShape.rectangle,
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (showIcon)
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
                      .copyWith(color: isPrime ? AppColors.textButton : null),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}