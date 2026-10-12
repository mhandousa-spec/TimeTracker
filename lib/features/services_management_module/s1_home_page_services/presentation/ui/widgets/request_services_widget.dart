// ******************* FILE INFO *******************
// File Name: request_services_widget
// Description: Request services widget.
// Module: services_management_module / presentation/s1_home_page_services/ui/widgets
// *************************************************
import 'package:get/get.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/core/custom/54-custom_grid_view.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart'; // ✅ ADD THIS IMPORT
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/8-custom_filter_app.dart';

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/core/theme/app_font_size.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/core/custom/37-custom_navigate.dart';
import 'package:knowticed_plus/features/services_management_module/s10_services_provider/presentation/ui/pages/employee_services_toggle.dart';

import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/ui/pages/dashboard_admin_toggle.dart';
import 'package:knowticed_plus/features/services_management_module/s5_service_details/presentation/ui/pages/details_services_toggle.dart';
import 'package:knowticed_plus/features/services_management_module/s5_service_details/presentation/ui/widgets/info_text.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/pages/my_request_toggle.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/pages/request_services_details_toggle.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/show_requests_service_card.dart';
import 'package:knowticed_plus/features/services_management_module/s7_approvals/presentation/ui/pages/approval_request_toggle.dart';
import 'package:knowticed_plus/features/services_management_module/s8_dashboard/presentation/ui/pages/dashboard_management_toggle.dart';
import 'package:knowticed_plus/features/services_management_module/s4_bulk_upload_services/presentation/ui/pages/create_new_services_toggle.dart';
import 'package:knowticed_plus/features/services_management_module/s4_bulk_upload_services/presentation/ui/pages/upload_file_toggle.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RequestServicesWidget extends StatefulWidget {
  final List<ServicesHistoryModel> filteredServices;
  final String selectStatus;
  final Function(String) onStatusSelected;
  final int totalServices;
  final Map<String, int> sortedMap;
  final String userDepartment;
  final bool isArabic;
  final TextEditingController searchController;
  final Function(BuildContext, String?) getLocalizedDurationUnit;
  final Future<Map<String, dynamic>?> Function(String) selectServiceProvider;

  const RequestServicesWidget({
    Key? key,
    required this.filteredServices,
    required this.selectStatus,
    required this.onStatusSelected,
    required this.totalServices,
    required this.sortedMap,
    required this.userDepartment,
    required this.isArabic,
    required this.searchController,
    required this.getLocalizedDurationUnit,
    required this.selectServiceProvider,
  }) : super(key: key);

  @override
  State<RequestServicesWidget> createState() => _RequestServicesWidgetState();
}

class _RequestServicesWidgetState extends State<RequestServicesWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildActionButtonsRow(context),
        SizedBox(height: 15.h),
        Column(
          children: [
            StatusChipFilter(
              selectedKey: widget.selectStatus,
              onSelected: widget.onStatusSelected,
              items: departmentChipItems(
                totalCount: widget.totalServices,
                departmentCounts: widget.sortedMap,
                isArabic: widget.isArabic,
              ),
            ),
            SizedBox(height: 15.h),
            Row(
              children: [
                AppSearchTextField(
                  controller: widget.searchController,
                  onChanged: (_) {},
                ),
              ],
            ),
            SizedBox(height: 15.h),
            _buildServicesGrid(context),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtonsRow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            Spacer(),
            customButton(
              title: FormatHelper.capitalize(S.of(context).adminDashboard),
              function: () {
                navigateTo(context, AdminDashBordLayout());
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
        Row(
          children: [
            customButton(
              title: FormatHelper.capitalize(S.of(context).requestedServices),
              function: () {
                navigateTo(context, EmployeeLayoutScreenServices());
              },
              textStyle: StyleText.fontSize16Weight500.copyWith(
                color: AppColors.textButton,
              ),
              width: 155.sp,
              height: 36.sp,
              radius: 8.r,
              color: AppColors.primary,
            ),
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
            Spacer(),
            customButton(
              title: FormatHelper.capitalize(S.of(context).approvals),
              function: () {
                navigateTo(context, ApprovalToggle());
              },
              textStyle: StyleText.fontSize16Weight500.copyWith(
                color: AppColors.textButton,
              ),
              width: 135.sp,
              height: 36.sp,
              radius: 8.r,
              color: AppColors.primary,
            ),
            SizedBox(width: 15.w),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                customButton(
                  title: FormatHelper.capitalize(S.of(context).dashboard),
                  function: () {
                    navigateTo(context, DashBordLayout());
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
          ],
        ),
      ],
    );
  }

  Widget _buildServicesGrid(BuildContext context) {

    if (widget.filteredServices.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: 40.sp),
        child: Column(
          children: [
            Lottie.asset(
              'assets/lottie_assets/main_lottie_assets/lottie_empty.json',
              width: 400.sp,
              height: 400.sp,
              fit: BoxFit.fill,
              repeat: true,
              animate: true,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: CrossAxisCountHelperResponsive.getCrossAxisCountForDefaultTabletResponsive(context),
        mainAxisExtent: 250.sp,
        mainAxisSpacing: 15.sp,
        crossAxisSpacing: 15.sp,
      ),
      itemCount: widget.filteredServices.length,
      itemBuilder: (context, index) {
        return _buildServiceCard(context, index);
      },
    );
  }

  Widget _buildServiceCard(BuildContext context, int index) {
    final model = widget.filteredServices[index];

    final serviceName = widget.isArabic
        ? model.currentServiceNameArabic
        : model.currentServiceNameEnglish;

    final durationText =
        '${model.currentDurationOfServices} ${widget.getLocalizedDurationUnit(context, model.currentSelectedDurationUnit)}';

    final approvalCycle = model.currentApprovalCycle;
    final approvalText = approvalCycle.isEmpty
        ? (S.of(context).sm_doesnTNeedApproval)
        : (S.of(context).sm_needApproval);

    // W24: no try/catch in a widget build helper (§11.2). The empty-id guard is
    // enough; resolving/guarding a bad id is the controller's responsibility.
    final departmentController = context.read<MainCoreDepartmentCubit>();
    final departmentId = model.currentDepartmentRequester;
    final owningDepartment = departmentId.isNotEmpty
        ? departmentController.getDepartmentName(
            departmentId,
            !widget.isArabic, // true for English, false for Arabic
          )
        : S.of(context).sm_unspecified;

    return GestureDetector(
      onTap: () {
        navigateTo(
          context,
          RequestServicesDetailsToggle(requestModel: model),
        );
      },
      child: FutureBuilder<Map<String, dynamic>?>(
        future: widget.selectServiceProvider(model.currentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CustomServiceCard(
              owningDepartment: owningDepartment, // ✅ FIXED: Pass actual department
              serviceName: serviceName,
              serviceProvider: "...",
              jobTitle: "...",
              durationOfServices: durationText,
              approval: approvalText,
              model: model,
            );
          }

          final provider = snapshot.data;
          final providerName = provider != null
              ? '${provider['firstName${widget.isArabic ? 'InArabic' : ''}'] ?? ''} '
              '${provider['lastName${widget.isArabic ? 'InArabic' : ''}'] ?? ''}'
              : '-';

          final providerTitle = provider != null
              ? (provider[widget.isArabic ? 'titleInArabic' : 'title'] ?? '-')
              : '-';

          return CustomServiceCard(
            owningDepartment: owningDepartment, // ✅ FIXED: Pass actual department
            serviceName: serviceName,
            serviceProvider: providerName.trim(),
            jobTitle: providerTitle,
            durationOfServices: durationText,
            approval: approvalText,
            model: model,
          );
        },
      ),
    );
  }
}
