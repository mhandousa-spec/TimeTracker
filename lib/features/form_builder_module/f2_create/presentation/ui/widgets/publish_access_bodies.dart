import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/access_management.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/users_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/department.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/drop_down_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/publish_screen_widgets.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';

class PublishOpenAccessBody extends StatelessWidget {
  const PublishOpenAccessBody({super.key, required this.model});

  final FormEntity model;

  @override
  Widget build(BuildContext context) {
    final addDepartmentController = Get.find<MainCoreDepartmentCubit>();

    return BlocBuilder<CreateFormDataCubit, CreateFormDataState>(
      builder: (context, state) {
        if (state is! CreateFormDataLoaded) {
          return const CircleProgressMaster();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (ContextExtension(context).isTablett) ...[
              const PublishSummaryRow(),
              verticalSpace(15),
            ],
            PublishCardsRow(
              model: model,
              // stable identifier, not display text — PublishCardsRow
              // localizes it through AccessManagementExtension.labelFor
              accessManagement: AccessManagement.openAccess.name,
            ),
            verticalSpace(15),
            const PublishEditPermissionRow(),
            verticalSpace(18),
            const PublishDateRow(),
            verticalSpace(25),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                DropDownWidget(
                  fillColor: AppColors.card,
                  title: S.of(context).department,
                  hint: S.of(context).select_department,
                  items: addDepartmentController.departmentModels
                      .map((element) => DepartmentEntity(
                          name: addDepartmentController.containAbbreviation(
                              element.departmentName!.toLowerCase()),
                          nameAr: element.departmentNameInArabic!,
                          id: element.departmentID!))
                      .toList()
                      .toDropdownMenuItemList(),
                  currentValue: null,
                  onChanged: (value) =>
                      context.read<CreateFormDataCubit>().onDropDownOpenAccess(value),
                ),
                verticalSpace(8),
                Wrap(
                  spacing: 8,
                  runSpacing: 10,
                  children: List.generate(
                    state.departmentsShown.length,
                    (index) => Container(
                      height: 28,
                      decoration: ShapeDecoration(
                        color: AppColors.card,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                FormatHelper.capitalize(state.departmentsShown[index].name),
                                style: StyleText.fontSize14Weight400,
                              ),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional.topEnd,
                            child: InkWell(
                              onTap: () => context
                                  .read<CreateFormDataCubit>()
                                  .onCancelDepartmentOpenAccess(index),
                              child: Padding(
                                padding: EdgeInsetsDirectional.only(top: 7.h, end: 5.h),
                                child: SvgPicture.asset(
                                  AppAssets.cancel,
                                  height: 12.h,
                                  width: 12.w,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            verticalSpace(25),
            PublishActionRow(model: model),
          ],
        );
      },
    );
  }
}

class PublishRestrictedAccessBody extends StatelessWidget {
  const PublishRestrictedAccessBody({super.key, required this.model});

  final FormEntity model;

  @override
  Widget build(BuildContext context) {
    final addEmployeeController = Get.find<MainCoreEmployeeController>();
    final addDepartmentController = Get.find<MainCoreDepartmentCubit>();

    return BlocBuilder<CreateFormDataCubit, CreateFormDataState>(
      builder: (context, state) {
        if (state is! CreateFormDataLoaded) {
          return const CircleProgressMaster();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (ContextExtension(context).isTablett) ...[
              const PublishSummaryRow(),
              verticalSpace(15),
            ],
            PublishCardsRow(
              model: model,
              accessManagement: AccessManagement.restrictedAccess.name,
            ),
            verticalSpace(15),
            const PublishEditPermissionRow(),
            verticalSpace(18),
            const PublishDateRow(),
            verticalSpace(25),
            verticalSpace(20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
        height: 38,
        hint: 'Search',
        maxLines: 1,
        fillColor: AppColors.card,
        hintStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.secondaryBlack),
        prefixIcon: SvgPicture.asset(
                    AppAssets.search,
                    color: AppColors.secondaryBlack,
                  ),
        onChanged: (value) {
                    context.read<CreateFormDataCubit>().search(value);
                  },
      ),
                verticalSpace(15),
                Wrap(
                  children: List.generate(
                    state.selectedPersonList.length,
                    (index) {
                      return Container(
                        margin: const EdgeInsetsDirectional.only(end: 8),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: addEmployeeController
                                      .getEmployeePhoto(state.shownPersonList[index].id)
                                      .contains('assets')
                                  ? appImageProvider(addEmployeeController
                                      .getEmployeePhoto(state.shownPersonList[index].id))
                                  : NetworkImage(addEmployeeController
                                      .getEmployeePhoto(state.shownPersonList[index].id)),
                            ),
                            GestureDetector(
                              onTap: () {
                                context
                                    .read<CreateFormDataCubit>()
                                    .selectPerson(state.selectedPersonList[index]);
                              },
                              child: Transform.scale(
                                scale: 1.2,
                                child: ClipOval(
                                  child: SizedBox(
                                    height: 14,
                                    width: 14,
                                    child: SvgPicture.asset(
                                      AppAssets.close,
                                      width: 12,
                                      height: 12,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
                verticalSpace(15),
                SizedBox(
                  height: 250,
                  child: SingleChildScrollView(
                    child: Column(
                      children: List.generate(
                        state.shownPersonList.length,
                        (index) {
                          return Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                            ),
                            margin: const EdgeInsets.only(bottom: 10),
                            child: GestureDetector(
                              onTap: () => context
                                  .read<CreateFormDataCubit>()
                                  .selectPerson(state.shownPersonList[index]),
                              child: Container(
                                color: AppColors.card,
                                padding: const EdgeInsetsDirectional.only(
                                    start: 13, end: 7, top: 10, bottom: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            radius: 20,
                                            backgroundColor: AppColors.primary,
                                            child: SizedBox(
                                                child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(15.r),
                                                    child: CustomSvgImage(
                                                      assetPath: "assets/icons_assets/main_icons_assets/male_avatar.svg",
                                                      width: 30.w,
                                                      height: 30.h,
                                                      fit: BoxFit.fill,
                                                    ))),
                                          ),
                                          horizontalSpace(10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  addEmployeeController.getEmployeeName(
                                                      state.shownPersonList[index].id),
                                                  style:
                                                      StyleText.fontSize14Weight500,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  addDepartmentController.getDepartmentName(
                                                      state.shownPersonList[index]
                                                          .department,
                                                      null),
                                                  overflow: TextOverflow.ellipsis,
                                                  style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryBlack),
                                                ),
                                                Text(
                                                  addEmployeeController
                                                      .getEmployeeJobTitle(
                                                          state.shownPersonList[index].id),
                                                  overflow: TextOverflow.ellipsis,
                                                  style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryBlack),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SvgPicture.asset(
                                        state.shownPersonList[index].isSelected
                                            ? AppAssets.checkboxFill
                                            : AppAssets.checkbox),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            verticalSpace(25),
            PublishActionRow(model: model),
            verticalSpace(25),
          ],
        );
      },
    );
  }
}
