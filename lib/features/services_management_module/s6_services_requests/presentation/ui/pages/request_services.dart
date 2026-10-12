// ******************* FILE INFO *******************
// File Name: request_services
// Description: Request services.
// Module: services_management_module / presentation/s6_services_requests/ui/services_management_module
// *************************************************
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/controller/services_manager_cubit.dart' hide RequestServicesLoading, RequestServicesError, RequestServicesLoaded;
import 'package:knowticed_plus/features/services_management_module/s1_home_page_services/presentation/ui/pages/home_page_services_toggle.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/controller/request_services_state.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/department_filter_chips_widget.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/service_requests_filter_dialog.dart';
import 'package:knowticed_plus/core/custom/14-custom_filter_icon.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/empty_state_widget.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/services_grid_widget.dart';

import 'package:knowticed_plus/generated/l10n.dart';


import 'package:knowticed_plus/core/custom/37-custom_navigate.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/pages/my_request_toggle.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/controller/request_services_cubit.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';

class RequestServicesPage extends StatelessWidget {
  const RequestServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RequestServicesCubit(
        departmentCubit: context.read<MainCoreDepartmentCubit>(),
      )..initialize(context),
      child: RequestServicesView(),
    );
  }
}

class RequestServicesView extends StatefulWidget {
  const RequestServicesView({super.key});

  @override
  State<RequestServicesView> createState() => _RequestServicesViewState();
}

class _RequestServicesViewState extends State<RequestServicesView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = RequestServicesCubit.get(context);
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return SlideInContent(from: SlideFrom.bottom, child: Scaffold(
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: FormatHelper.capitalize(S.of(context).services),
          onFirstTap: () {
            navigateTo(context, LayoutScreenServices());
          },
          secondTitle: FormatHelper.capitalize(S.of(context).serviceRequests),
          child: BlocConsumer<RequestServicesCubit, RequestServicesState>(
            listener: (context, state) {
              // Handle state changes if needed
            },
            builder: (context, state) {
              return BlocListener<ServicesManagerCubit, ServicesManagerState>(
                listener: (context, servicesState) {
                  if (servicesState is GetServiceLoaded) {
                    final services = ServicesManagerCubit.get(context).servicesRequest;
                    cubit.loadServices(services);
                  }
                },
                // Not a bare scroll view — see `SideFrameScrollableBody`. The
                // frame already scrolls this child on the phone branch, so a
                // second viewport here is unbounded and throws during layout.
                child: SideFrameScrollableBody(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Action Bar
                      Row(
                        children: [
                          const Spacer(),
                          SizedBox(width: 15.w),
                          customButton(
                            title: FormatHelper.capitalize(S.of(context).myRequests),
                            function: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => MyRequestServicesToggle(),
                                ),
                              );
                            },
                            textStyle: StyleText.fontSize16Weight500.copyWith(
                              color: AppColors.textButton,
                            ),
                            width: 135.sp,
                            height: 36.sp,
                            radius: 8.r,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                      SizedBox(height: 15.sp),

                      // Department Filter Chips
                      if (state is RequestServicesLoaded)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DepartmentFilterChipsWidget(
                              selectedDepartment: cubit.filterModel.selectedDepartment,
                              departmentCounts: cubit.departmentCounts,
                              onDepartmentChanged: (dept) => cubit.changeDepartmentFilter(dept),
                            ),
                          ],
                        ),

                      SizedBox(height: 15.h),

                      // Search Bar
                      // Services mobile QA p.22: the filter button was
                      // missing beside the search. Same CustomFilterIcon as My
                      // Requests; it filters by owning department (the chips
                      // above run off a phone screen).
                      Row(
                        children: [
                          AppSearchTextField(
                            controller: _searchController,
                            onChanged: (val) => cubit.searchServices(val),
                          ),
                          if (state is RequestServicesLoaded) ...[
                            SizedBox(width: 9.sp),
                            CustomFilterIcon(
                              color: AppColors.card,
                              borderColor: AppColors.transparent,
                              svgColor: AppColors.secondaryText,
                              title: '',
                              onTap: () async {
                                final result =
                                    await showServiceRequestsFilterDialog(
                                  context: context,
                                  departments: cubit
                                      .departmentCounts.departmentCounts.keys
                                      .toList(),
                                  selectedDepartment:
                                      cubit.filterModel.selectedDepartment,
                                );
                                if (result != null) {
                                  cubit.changeDepartmentFilter(result);
                                }
                              },
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 15.h),

                      // Content
                      if (state is RequestServicesLoading)
                        Padding(
                          padding: EdgeInsets.only(top: 100.sp),
                          child: CircleProgressMaster(),
                        )
                      else if (state is RequestServicesError)
                        Center(
                          child: Text('Error: ${state.message}'),
                        )
                      else if (state is RequestServicesLoaded)
                          state.filteredServices.isEmpty
                              ? EmptyStateWidget()
                              : ServicesGridWidget(
                            services: state.filteredServices,
                            providerCache: cubit.providerCache,
                          ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ));
  }
}
