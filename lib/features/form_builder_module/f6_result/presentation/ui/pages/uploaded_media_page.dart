import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart'; // Keep for .tr
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/ui/widgets/selected_person_avatar.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/controller/result_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/controller/result_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/controller/upload_media_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/controller/upload_media_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/data/utils/result_constants.dart';

import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/69-cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/custom/45-custom_app_dropdown.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/ui/widgets/dropdown/multi_drop_down_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/ui/widgets/dropdown/small_drop_down.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/features/form_builder_module/form_builder_breadcrumb_nav.dart';
import 'package:knowticed_plus/core/helper/form_builder/person_state_view.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/drop_down_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_head_data.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/features/form_builder_module/form_builder_title_padding.dart';
class UploadedMediaPage extends StatefulWidget {
  const UploadedMediaPage({super.key});

  @override
  State<UploadedMediaPage> createState() => _UploadedMediaPageState();
}

class _UploadedMediaPageState extends State<UploadedMediaPage> {
  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    // CHANGED 19/8/2026 — header is SideFrameMasterServices now, not
    // PaginationAppBar. The form title crumb still needs ResultLoaded, so it
    // resolves through `_getTitle`, which now falls back to an empty string
    // instead of the whole header disappearing while the state loads.
    return Scaffold(
      body: SideFrameMasterServices(
        titlePadding: formBuilderTitlePadding,
        titleText: S.of(context).services_app,
        secondTitle: S.of(context).detailsOfTitle(_getTitleOrEmpty(context)),
        thirdTitle: S.of(context).result,
        fourthTitle: S.of(context).uploadedMedia,
        onFirstTap: breadcrumbPop(context, 3),
        onSecondTap: breadcrumbPop(context, 2),
        onThirdTap: breadcrumbPop(context, 1),
        child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsetsDirectional.only(start: 16.w, end: 16.w),
              child: BlocBuilder<UploadMediaCubit, UploadMediaState>(
                builder: (context, state) {
                  if (state is! UploadMediaLoaded) {
                    return const CircleProgressMaster();
                  }

                  final cubit = context.read<UploadMediaCubit>();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      verticalSpace(isTablet ? 30 : 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 10.h,
                        children: [
                          Text(
                            S.of(context).documentDetails,
                            style: StyleText.fontSize16Weight500,
                          ),
                          Container(
                            width: double.infinity,
                            height: isPortrait ? 550.h : 500.h,
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.sp,
                              vertical: 20.sp,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isTablet)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _mediaDropDown(context, cubit, state),
                                      horizontalSpace(10),
                                      _employeeDropDown(context, cubit, state),
                                    ],
                                  ),
                                if (!isTablet)
                                  _mediaDropDown(context, cubit, state),
                                if (!isTablet) verticalSpace(10),
                                if (!isTablet)
                                  _employeeDropDown(context, cubit, state),
                                if (!isTablet) verticalSpace(10),
                                verticalSpace(15.sp),
                                Row(
                                  children: [
                                    AppSearchTextField(
                                      fillColor: AppColors.background,
                                      controller: state.searchController,
                                      onChanged: (value) {
                                        cubit.applyFilter();
                                      },
                                    ),
                                    horizontalSpace(10),
                                    _departmentDropDown(context, cubit, state),
                                  ],
                                ),
                                verticalSpace(16),
                                Wrap(
                                  children: [
                                    for (int i = 0;
                                    i < state.filteredUserGridItems.length;
                                    i++)
                                      if (state.filteredUserGridItems[i].person
                                          .isSelected)
                                        SelectedPersonAvatar(
                                          personEntity: state
                                              .filteredUserGridItems[i].person,
                                          onTap: () {
                                            cubit.togglePersonSelection(state
                                                .filteredUserGridItems[i]);
                                          },
                                        )
                                  ],
                                ),
                                verticalSpace(16),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: CrossAxisCountHelper
                                        .getCrossAxisCountForDefaultTablet2(
                                        context),
                                    mainAxisSpacing: 16.sp,
                                    crossAxisSpacing: 16.sp,
                                    mainAxisExtent: 75.h,
                                  ),
                                  itemCount:
                                  state.filteredUserGridItems.length,
                                  itemBuilder: (_, index) {
                                    return FormPersonStateView(
                                      color: AppColors.background,
                                      person: state
                                          .filteredUserGridItems[index].person,
                                      onTap: () {
                                        cubit.togglePersonSelection(
                                            state.filteredUserGridItems[index]);
                                      },
                                    );
                                  },
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      verticalSpace(20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          customButtonWithSvg(
                            title: 'Download',
                            image: AppAssets.downloadPdf,
                            function: () {
                              cubit.downloadMedia();
                            },
                            textStyle: StyleText.fontSize14Weight500
                                .copyWith(color: AppColors.textButton),
                            color: AppColors.primary,
                            colorBorder: AppColors.primary,
                            svgColor: AppColors.textButton,
                            widthImage: 16,
                            heightImage: 16,
                          ),
                        ],
                      )
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  /// The form title for the breadcrumb.
  ///
  /// ADDED 19/8/2026 with the SideFrameMasterServices conversion. The header
  /// is built outside the `BlocBuilder`, so it can run before `ResultCubit`
  /// has emitted `ResultLoaded`. Returning '' then is what keeps the crumb
  /// row (and its back navigation) on screen during the load — previously the
  /// whole `PaginationAppBar` collapsed to a `SizedBox.shrink()`.
  String _getTitleOrEmpty(BuildContext context) {
    final state = context.read<ResultCubit>().state;
    if (state is! ResultLoaded || state.formEntity == null) return '';
    return _getTitle(context, state);
  }

  String _getTitle(BuildContext context, ResultLoaded state) {
    FormHeadData formHeadModel = state.formEntity!.formHeadModel;
    if (context.isArabic) {
      if (formHeadModel.arTitle != null && formHeadModel.arTitle!.isNotEmpty) {
        return formHeadModel.arTitle ?? '';
      }
    }
    return formHeadModel.title ?? '';
  }

  Widget _mediaDropDown(
      BuildContext context, UploadMediaCubit cubit, UploadMediaLoaded state) {
    List<String> items = [];
    items.addAll(ResultConstants.mediaTypeFilter);

    if (!cubit.hasSignature()) {
      items.remove(ResultConstants.mediaTypeFilter[2]);
    }
    if (!cubit.hasAttachment()) {
      items.remove(ResultConstants.mediaTypeFilter[1]);
    }
    if (!cubit.hasImage()) {
      items.remove(ResultConstants.mediaTypeFilter[0]);
    }

    if (ContextExtension(context).isPhone) {
      return SizedBox(
        width: double.infinity,
        child: MultiDropDownWidget(
          isReadOnly: false,
          selectedItems: state.mediaType,
          onChanged: (value) {
            cubit.selectMediaType(value);
          },
          title: 'Type Of Document',
          hint: 'Select Document',
          items: items,
          currentValue: null,
        ),
      );
    }

    return Expanded(
      child: MultiDropDownWidget(
        isReadOnly: false,
        selectedItems: state.mediaType,
        onChanged: (value) {
          cubit.selectMediaType(value);
        },
        title: 'Type Of Document',
        hint: 'Select Document',
        items: items,
        currentValue: null,
      ),
    );
  }

  Widget _employeeDropDown(
      BuildContext context, UploadMediaCubit cubit, UploadMediaLoaded state)
  {
    List<DropdownMenuItem> items = [];
    items.addAll(ResultConstants.employeeFilter
        .map((e) => DropdownMenuItem(
      value: e,
      child: Text(e,
          style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack)),
    ))
        .toList());

    if (ContextExtension(context).isPhone) {
      return SizedBox(
        width: double.infinity,
        child: DropDownWidget(
          isReadOnly: false,
          onChanged: (value) {
            cubit.updateSelectedEmployeeType(value);
          },
          title: 'Employees',
          hint: 'Employees',
          items: items,
          currentValue: state.employeeType ?? items.first.value, // ✅ Provide default
        ),
      );
    }

    return Expanded(
      child: DropDownWidget(
        isReadOnly: false,
        onChanged: (value) {
          cubit.updateSelectedEmployeeType(value);
        },
        title: 'Employees',
        hint: 'Employees',
        items: items,
        currentValue: state.employeeType ?? items.first.value, // ✅ Provide default
      ),
    );
  }

  Widget _departmentDropDown(
      BuildContext context, UploadMediaCubit cubit, UploadMediaLoaded state)
  {
    List<DropdownMenuItem> items = [
      DropdownMenuItem(
        value: S.of(context).all,  // ✅ Translate the value too!
        child: Text(S.of(context).all,
            style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack)),
      ),
    ];

    items.addAll(Get.find<MainCoreDepartmentCubit>()
        .departmentModels
        .map((e) => DropdownMenuItem(
      value: (Get.locale?.languageCode == 'en')
          ? FormatHelper.capitalize(e.departmentName!)
          : e.departmentNameInArabic!,
      child: Text(
        (Get.locale?.languageCode == 'en')
            ? FormatHelper.capitalize(e.departmentName!)
            : e.departmentNameInArabic!,
        style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack),
      ),
    ))
        .toList());

    if (ContextExtension(context).isPhone) {
      return SizedBox(
        width: 36.sp,
        child: SmallDropdown(
          menuWidth: 300.sp,
          onChanged: (value) {
            cubit.updateDepartmentType(value);
          },
          textButton: 'Department',
          items: items,
        ),
      );
    }

    return SizedBox(
      height: 36,
      width: 150.w,
      child: AppDropdown(
        borderRadius: 8.r, // form bug report #8/#35: 8.r dropdowns
        width: 150.w,
        fillColor: AppColors.background,
        menuItemHeight: 35.sp,
        showErrorBorder: false,
        value: state.departmentType ?? S.of(context).all, // ✅ Provide default with .tr
        items: items,
        onChanged: (value) {
          cubit.updateDepartmentType(value);
        },
        hintText: 'Department',
        textButton: state.departmentType ?? 'Department', // ✅ Fallback
      ),
    );
  }
}