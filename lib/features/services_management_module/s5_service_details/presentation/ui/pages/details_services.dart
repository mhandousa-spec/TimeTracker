// ******************* FILE INFO *******************
// File Name: details_services
// Description: Details services.
// Module: services_management_module / presentation/s5_service_details/ui/services_management_module
// *************************************************
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';

import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/s1_home_page_services/presentation/ui/pages/home_page_services_toggle.dart';
import 'package:knowticed_plus/features/services_management_module/s5_service_details/presentation/ui/widgets/employees_tab_widget.dart';
import 'package:knowticed_plus/features/services_management_module/s5_service_details/presentation/ui/widgets/export.dart';
import 'package:knowticed_plus/features/services_management_module/s5_service_details/presentation/ui/widgets/filter.dart';
import 'package:knowticed_plus/features/services_management_module/s5_service_details/presentation/ui/widgets/helper_method.dart';
import 'package:knowticed_plus/features/services_management_module/s5_service_details/presentation/ui/widgets/info_text.dart';
import 'package:knowticed_plus/features/services_management_module/s5_service_details/presentation/ui/widgets/requested_services_tab_widget.dart';
import 'package:knowticed_plus/features/services_management_module/s5_service_details/presentation/ui/widgets/service_header_widget.dart';
import 'package:knowticed_plus/features/services_management_module/s5_service_details/presentation/ui/widgets/service_info_card_widget.dart';
import 'package:knowticed_plus/features/services_management_module/s5_service_details/presentation/ui/widgets/service_stats_widget.dart';
import 'package:knowticed_plus/features/services_management_module/s5_service_details/presentation/ui/widgets/success_dialog.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/helper/main_helper/csv_helper.dart';


import 'package:knowticed_plus/core/custom/37-custom_navigate.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/custom/14-custom_filter_icon.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/helper/role/services_module_access.dart';

import 'package:knowticed_plus/core/theme/app_font_size.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';


import 'package:knowticed_plus/features/services_management_module/s5_service_details/presentation/controller/details_services_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/s5_service_details/presentation/controller/details_services_state.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class DetailsServicesPage extends StatelessWidget {
  final ServicesHistoryModel createServicesModel;

  const DetailsServicesPage({
    required this.createServicesModel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DetailsServicesCubit()
        ..initialize(createServicesModel.currentId, createServicesModel, context),
      child: DetailsServicesView(createServicesModel: createServicesModel),
    );
  }
}

class DetailsServicesView extends StatefulWidget {
  final ServicesHistoryModel createServicesModel;

  const DetailsServicesView({required this.createServicesModel, super.key});

  @override
  State<DetailsServicesView> createState() => _DetailsServicesViewState();
}

class _DetailsServicesViewState extends State<DetailsServicesView> {
  final TextEditingController _searchController = TextEditingController();

  Map<String, String> get enToArDepartments =>
      context.read<MainCoreDepartmentCubit>().enToAr;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = DetailsServicesCubit.get(context);
    final isMobile = ContextExtension(context).isPhone;
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return SlideInContent(from: SlideFrom.bottom, child: Scaffold(
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).service,
          onFirstTap: () {
            navigateTo(context, LayoutScreenServices());
          },
          secondTitle: FormatHelper.capitalize(
            Localizations.localeOf(context).languageCode == 'ar'
                ? widget.createServicesModel.currentServiceNameArabic ?? ''
                : widget.createServicesModel.currentServiceNameEnglish ?? '',
          ),
          child: BlocBuilder<DetailsServicesCubit, DetailsServicesState>(
            builder: (context, state) {
              if (state is DetailsServicesLoading) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(
                    child: CircleProgressMaster(),
                  ),
                );
              }

              if (state is DetailsServicesError) {
                return Center(
                  child: Text('Error: ${state.message}'),
                );
              }

              // NOT a bare `SingleChildScrollView` (10/9/2026). This is the
              // direct child of `SideFrameMasterServices`, which already wraps
              // it in a scroll view on the PHONE branch — so on a phone this
              // was a vertical viewport inside a vertical viewport with an
              // unbounded height, and layout threw "Vertical viewport was given
              // unbounded height" before the body painted. What reached the
              // console was the downstream
              // `'!semantics.parentDataDirty': is not true`, once per frame.
              //
              // On tablet and desktop the frame gives an `Expanded` instead and
              // a scroll view here is required, so it cannot simply be deleted.
              // `SideFrameScrollableBody` adds one only on that branch.
              return SideFrameScrollableBody(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    // Header with Edit/Delete buttons
                    ServiceHeaderWidget(
                      createServicesModel: widget.createServicesModel,
                    ),
                    SizedBox(height: 8.sp),

                    // Service Info Card
                    ServiceInfoCardWidget(
                      createServicesModel: widget.createServicesModel,
                    ),
                    SizedBox(height: 20.sp),

                    // Stats Widget
                    ServiceStatsWidget(stats: cubit.stats),
                    SizedBox(height: 20.sp),

                    // Tabs Section
                    _buildTabsSection(context, cubit),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    ));
  }

  Widget _buildTabsSection(BuildContext context, DetailsServicesCubit cubit) {
    return Column(
      children: [
        _buildTabHeaders(context, cubit),
        SizedBox(height: 20.sp),
        _buildSearchAndFilters(context, cubit),
        SizedBox(height: 15.sp),
        BlocBuilder<DetailsServicesCubit, DetailsServicesState>(
          builder: (context, state) {
            // View Requesters is off → the Requested Services tab does not
            // exist, and its content must not be what the page opens on.
            // `isEmployeesTab` starts false, so gate the content too rather
            // than only hiding the tab header.
            if (cubit.isEmployeesTab ||
                !ServicesModuleAccess.canViewRequesters) {
              return EmployeesTabWidget(
                searchController: _searchController,
                createServicesModel: widget.createServicesModel,
              );
            } else {
              return RequestedServicesTabWidget(
                createServicesModel: widget.createServicesModel,
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildTabHeaders(BuildContext context, DetailsServicesCubit cubit) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    var isMobile = ContextExtension(context).isPhone;
    return Row(
      children: [
        // Requested Services Tab
        if (ServicesModuleAccess.canViewRequesters) ...[
        GestureDetector(
            onTap: () => cubit.changeTab(false),
            child: IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    S.of(context).RequestedServices,
                    style: isMobile ?StyleText.fontSize20Weight600.copyWith(
                      fontSize: 18.sp,
                      color: !cubit.isEmployeesTab
                          ? AppColors.secondaryPrimary
                          : lightMode
                          ? AppColors.inverseBase
                          : AppColors.grey,
                    ):
                    StyleText.fontSize20Weight600.copyWith(
                      color: !cubit.isEmployeesTab
                          ? AppColors.secondaryPrimary
                          : lightMode
                          ? AppColors.inverseBase
                          : AppColors.grey,
                    ),
                  ),
                  if (!cubit.isEmployeesTab)
                    Container(
                      margin: EdgeInsets.only(top: 4.h),
                      height: 2.h,
                      width: double.infinity,
                      color: AppColors.secondaryPrimary,
                    ),
                ],
              ),
            ),
          ),

        // Spacing
        SizedBox(width: 47.w),
        ],

        // Employees Tab
        GestureDetector(
          onTap: () => cubit.changeTab(true),
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  S.of(context).Employees,
                  style: StyleText.fontSize20Weight600.copyWith(
                    color: cubit.isEmployeesTab
                        ? AppColors.secondaryPrimary
                        : lightMode
                        ? AppColors.inverseBase
                        : AppColors.grey,
                  ),
                ),
                if (cubit.isEmployeesTab)
                  Container(
                    margin: EdgeInsets.only(top: 4.h),
                    height: 2.h,
                    width: double.infinity,
                    color: AppColors.secondaryPrimary,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(BuildContext context, DetailsServicesCubit cubit) {
    final isMobile = ContextExtension(context).isPhone;
    final isTablet = ContextExtension(context).isTablet;
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final isFilterActive = cubit.hasActiveFilters;

    return Row(
      children: [
        // Search Field
        AppSearchTextField(
          controller: _searchController,
          onChanged: (val) => cubit.applySearch(val),
        ),

        SizedBox(width: 15.sp),

        // Filter Button
        CustomFilterIcon(
          color: isFilterActive ? AppColors.primary : AppColors.card,
          borderColor: AppColors.transparent,
          svgColor: isFilterActive
              ? AppColors.textButton
              : (lightMode ? AppColors.secondaryText : AppColors.grey),
          title: S.of(context).Filter,
          textStyle: StyleText.fontSize16Weight500.copyWith(
            color: isFilterActive ? AppColors.textButton : AppColors.secondaryText,
          ),
          onTap: () async {
              if (mounted) {
                // P01: no try/catch in a widget onTap callback (§11.2).
                final result = await showFilterDialog(
                  context,
                  cubit.filteredItems
                      .map((item) => item["model"] as ServicesHistoryModel)
                      .toList(),
                  initialDepartments: cubit.selectedDepartments, // ✅ List
                  initialStatuses: cubit.selectedStatuses, // ✅ List
                  initialDate: cubit.selectedDate,
                  initialSortBy: cubit.selectedSortBy, // ✅ NEW: For employees tab
                  isEmployeesTab: cubit.isEmployeesTab, // ✅ NEW: Determine which fields to show
                );

                if (result != null && mounted) {
                  cubit.applyFilter(
                    departments: result['departments'] as List<String>?,
                    statuses: result['statuses'] as List<String>?,
                    date: result['date'] as DateTime?,
                    sortBy: result['sortBy'] as String?, // ✅ NEW: For employees sorting
                  );
                }
              }
            },
        ),

        // Export Button (Only for Requested Services Tab)
        if (!cubit.isEmployeesTab &&
            ServicesModuleAccess.canExportRequestedServices) ...[
          SizedBox(width: 15.sp),
          GestureDetector(
            onTap: () async {
              final fileName = await showFileNameDialog(context);
              if (fileName != null && fileName.isNotEmpty) {
                await _exportToCSV(context, cubit, fileName);
              }
            },
            child: !isTabletLandscape(context)
                ? Container(
              width: 38.sp,
              height: 38.h,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: SvgPicture.asset(
                  width: 24.sp,
                  height: 24.sp,
                  color: AppColors.textButton,
                  fit: BoxFit.fill,
                  "assets/icons_assets/main_icons_assets/export_arrow.svg",
                ),
              ),
            )
                : Container(
              width: 100.sp,
              height: 38.h,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    width: 24.sp,
                    height: 24.sp,
                    color: AppColors.textButton,
                    fit: BoxFit.scaleDown,
                    "assets/icons_assets/main_icons_assets/export_arrow.svg",
                  ),
                  SizedBox(width: 8.sp),
                  Text(
                    S.of(context).export,
                    style: StyleText.fontSize16Weight500.copyWith(
                      color: AppColors.textButton,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
  Future<void> _exportToCSV(BuildContext context, DetailsServicesCubit cubit, String fileName) async {
    CircleProgressMaster();

    List<List<dynamic>> rows = [];

    // Add headers
    rows.add([
      S.of(context).NO,
      S.of(context).serviceRequester,
      S.of(context).department,
      S.of(context).jobTitle,
      S.of(context).RequestedDate,
      S.of(context).status,
      S.of(context).serviceProvider,
    ]);

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final displayedItems = cubit.displayedItems;

    for (int i = 0; i < displayedItems.length; i++) {
      final item = displayedItems[i];
      final model = item["model"] as ServicesHistoryModel;

      final requestor = isArabic
          ? "${model.departmentRequesterArabic ?? ''} ${model.lastNameRequesterArabic ?? ''}"
          : "${model.departmentRequester ?? ''} ${model.lastNameRequester ?? ''}"
          .trim();
      final rawDepartment = model.departmentRequester ?? "-";
      final department = isArabic ? enToArDepartments[rawDepartment] ?? rawDepartment : rawDepartment;

      final jobTitle = item["jobtitle"] ?? "_";

      final requestDate = model.currentDurationOfServicesTimestamp != null
          ? DateFormat.yMMMMd(Localizations.localeOf(context).languageCode)
          .format(model.currentDurationOfServicesTimestamp.toDate())
          : "-";

      final status = () {
        final status = (item["status"] ?? "").toString().toLowerCase();
        if (isArabic) {
          if (status == "active") return "نشط";
          if (status == "inactive") return "غير نشط";
          return "غير معروف";
        } else {
          return status.isNotEmpty ? status : "-";
        }
      }();

      final provider = item["provider"] ?? "-";

      rows.add([
        i + 1,
        requestor,
        department,
        jobTitle,
        requestDate,
        status,
        provider,
      ]);
    }

    await CSVHelper().exportToCSV(rows, fileName);
    CircleProgressMaster();
    await showDownloadSuccessDialog(context);
  }
}
