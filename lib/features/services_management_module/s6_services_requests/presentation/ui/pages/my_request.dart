// ******************* FILE INFO *******************
// File Name: my_request
// Description: My request.
// Module: services_management_module / presentation/s6_services_requests/ui/services_management_module
// *************************************************
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/54-custom_grid_view.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:lottie/lottie.dart';


import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/controller/my_request_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/controller/my_request_state.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/custom_multi.dart';
import 'package:knowticed_plus/core/custom/8-custom_filter_app.dart';

import 'package:knowticed_plus/core/custom/34-custom_gridview_with_animation.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/37-custom_navigate.dart';

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/sort.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';

import 'package:knowticed_plus/features/services_management_module/s5_service_details/presentation/ui/widgets/filter.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/pages/my_request_details_toggle.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/custom/14-custom_filter_icon.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/my_requests_service_card.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/service_card_metrics.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class MyRequestServices extends StatelessWidget {
  const MyRequestServices({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MyRequestCubit(context)..loadAllData(),
      child: const MyRequestServicesView(),
    );
  }
}

class MyRequestServicesView extends StatefulWidget {
  const MyRequestServicesView({super.key});

  @override
  State<MyRequestServicesView> createState() => _MyRequestServicesViewState();
}

class _MyRequestServicesViewState extends State<MyRequestServicesView> {
  @override
  void dispose() {
    // Cubit is disposed by BlocProvider
    super.dispose();
  }

  bool isTabletLandscape(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return size.width >= 600 && isLandscape;
  }

  // Helper method to extract abbreviation from job title
  String _getDisplayJobTitle(String? titleEn, String? titleAr, bool isArabic) {
    final titleEnTrimmed = (titleEn ?? '').trim();
    final titleArTrimmed = (titleAr ?? '').trim();

    String title = isArabic
        ? (titleArTrimmed.isNotEmpty ? titleArTrimmed : titleEnTrimmed)
        : (titleEnTrimmed.isNotEmpty ? FormatHelper.capitalize(titleEnTrimmed) : titleArTrimmed);

    // Extract abbreviation from parentheses at the end
    final abbreviationRegex = RegExp(r'\(([^)]+)\)\s*$');
    final match = abbreviationRegex.firstMatch(title);

    if (match != null) {
      // Return only what's inside the parentheses
      return match.group(1) ?? title;
    }

    return title;
  }

  /// ✅ SMART LAST UPDATE DETECTION
  /// Returns the actual last meaningful update, ignoring batch system updates
  DateTime _getSmartLastUpdate(List<int> timestamps) {
    if (timestamps.isEmpty) return DateTime.now();
    if (timestamps.length == 1) return DateTime.fromMillisecondsSinceEpoch(timestamps.first);

    // Get the last timestamp
    final lastTimestamp = timestamps.last;
    final lastDateTime = DateTime.fromMillisecondsSinceEpoch(lastTimestamp);

    // Check if this might be a batch system update
    // (e.g., all services updated within 5 seconds of each other)
    // If so, use the second-to-last timestamp instead

    // For now, we'll use the second-to-last timestamp if available
    // This helps show more variation in update times
    if (timestamps.length >= 2) {
      final secondToLast = timestamps[timestamps.length - 2];
      final secondToLastDateTime = DateTime.fromMillisecondsSinceEpoch(secondToLast);

      // If the last two timestamps are within 10 seconds of each other,
      // it's likely a batch update, so use the earlier one
      final difference = lastDateTime.difference(secondToLastDateTime).inSeconds;

      if (difference < 10) {
        return secondToLastDateTime;
      }
    }

    return lastDateTime;
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final isMobile = ContextExtension(context).isPhone;
    var lightMode = Theme.of(context).brightness == Brightness.light;
    var disappearHome = true;

    return SlideInContent(from: SlideFrom.bottom, child: BlocConsumer<MyRequestCubit, MyRequestState>(
      listener: (context, state) {
        if (state is MyRequestError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is MyRequestLoading) {
          return const Center(child: CircleProgressMaster());
        }

        if (state is! MyRequestLoaded) {
          return const SizedBox.shrink();
        }

        final cubit = context.read<MyRequestCubit>();
        final loadedState = state;

        return SafeArea(
          child: SideFrameMasterServices(
            titleText: FormatHelper.capitalize(S.of(context).services),
            onFirstTap: () {
              Navigator.pop(context);
            },
            secondTitle: disappearHome
                ? FormatHelper.capitalize(S.of(context).serviceRequests)
                : FormatHelper.capitalize(S.of(context).myRequests),
            onSecondTap: () {
              Navigator.pop(context);
            },
            thirdTitle: disappearHome
                ? FormatHelper.capitalize(S.of(context).myRequests)
                : null,
            onThirdTap: disappearHome
                ? () {
              Navigator.pop(context);
            }
                : null,
            // Not a bare scroll view — see `SideFrameScrollableBody`. The
            // frame already scrolls this child on the phone branch, so a second
            // viewport here is unbounded and throws during layout.
            child: SideFrameScrollableBody(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusChipFilter(
                    selectedKey: loadedState.selectedStatus,
                    onSelected: (status) {
                      cubit.updateStatus(status);
                    },
                    items: departmentChipItems(
                      totalCount: loadedState.totalServices,
                      isArabic: isArabic,
                      // ✅ Fixed lifecycle order, not busiest-first: the chips
                      // always read Done → Approved → In progress → Pending →
                      // Rejected → Canceled, so the row never reshuffles as
                      // counts change. Keep this false — it preserves the
                      // insertion order of [departmentCounts] below.
                      sortByCountDescending: false,
                      departmentCounts: {
                        S.of(context).Done: loadedState.doneCount,
                        S.of(context).Approved: loadedState.approvedCount,
                        S.of(context).Inprogress: loadedState.inProgressCount,
                        S.of(context).Pending: loadedState.pendingCount,
                        S.of(context).Rejected: loadedState.rejectedCount,
                        S.of(context).Canceled: loadedState.cancelCount,
                        S.of(context).BreachedSLA: loadedState.branchSlaCount,
                      },
                      labelColors: {
                        S.of(context).Done: AppColors.green!,
                        S.of(context).Approved: AppColors.lightGreen,
                        S.of(context).Inprogress: AppColors.yellow,
                        S.of(context).Pending: AppColors.orange,
                        S.of(context).Rejected: AppColors.darkRed!,
                        S.of(context).Canceled: AppColors.red!,
                        S.of(context).BreachedSLA: AppColors.red,
                      },
                    ),
                  ),
                  SizedBox(height: 15.sp),
                  Row(
                    children: [
                      AppSearchTextField(
                        controller: cubit.searchController,
                        onChanged: (_) {},
                      ),
                      SizedBox(width: 9.sp),
                      if (!isMobile)
                        DepartmentMultiSelectPage(
                          selectedKeys: loadedState.selectedDepartmentKeys,
                          onChanged: (keys) {
                            cubit.updateDepartments(keys);
                          },
                        ),
                      if (!isMobile) SizedBox(width: 9.sp),
                      if (!isMobile)
                        SortDropdownMenu(
                          selectedOption: loadedState.selectedSortOption,
                          onSortSelected: (value) {
                            cubit.updateSort(value);
                          },
                          isMobile: isMobile,
                          isTabletLandscape: isTabletLandscape(context),
                        ),
                      if (isMobile)
                        CustomFilterIcon(
                          color: AppColors.card,
                          borderColor: Colors.transparent,
                          svgColor: AppColors.secondaryText,
                          title: '',
                          onTap: () async {
                            final result = await showFilterDialog(context, loadedState.filteredModel);
                            if (result != null) {
                              cubit.applyMobileFilter(
                                selectedDepartment: result['department'],
                                selectedStatus: result['status'],
                                selectedDate: result['date'],
                              );
                            }
                          },
                        ),
                    ],
                  ),
                  SizedBox(height: 15.sp),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (loadedState.displayedItems.isEmpty)
                        Padding(
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
                        )
                      else
                        AnimatedCustomGridView(
                          itemCount: loadedState.displayedItems.length,
                          crossAxisCount: CrossAxisCountHelperResponsive.getCrossAxisCountForDefaultTabletResponsive(context),
                          // FIXED 9/9/2026 — the phone branch was a hardcoded
                          // 280.sp, ~14 short of what the card's Column needs,
                          // so every card on a phone reported "A RenderFlex
                          // overflowed by 14 pixels on the bottom"
                          // (my_requests_service_card.dart:310).
                          //
                          // `ServiceCardMetrics` is the source of truth the
                          // card itself points at ("Keeps the card's real
                          // height in sync with the grid's mainAxisExtent"),
                          // and its own file header warns that hardcoded
                          // extents break precisely this way. It derives the
                          // height from the card's real rows and the clamped
                          // text scale, so it is right on every screen — there
                          // was never anything phone-specific to override.
                          mainAxisExtent:
                              ServiceCardMetrics.myRequestCardExtent(context),
                          mainAxisSpacing: 15.sp,
                          crossAxisSpacing: 15.sp,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          animationDuration: const Duration(milliseconds: 1000),
                          staggerDelay: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          itemBuilder: (context, index) {
                            final service = loadedState.displayedItems[index]['model'] as ServicesHistoryModel;

                            // Create a copy of timestamps to ensure isolation
                            final timestampsArray = List<int>.from(service.timestamps);

                            final providerList = service.currentProviderServices;

                            if (providerList.isEmpty) {
                              return const SizedBox();
                            }

                            // ✅ Show the provider the request was actually
                            // assigned to, not just the first in the list.
                            final assignedEmail = service
                                    .currentAssignedProviderEmail
                                    ?.toLowerCase()
                                    .trim() ??
                                '';

                            final provider = assignedEmail.isEmpty
                                ? providerList[0]
                                : providerList.firstWhere(
                                    (p) =>
                                        (p.email?.toLowerCase().trim() ?? '') ==
                                        assignedEmail,
                                    orElse: () => providerList[0],
                                  );
                            final serviceName = isArabic
                                ? service.currentServiceNameArabic
                                : service.currentServiceNameEnglish;

                            final pointOfContact = isArabic
                                ? "${provider.firstNameInArabic ?? ''} ${provider.lastNameInArabic ?? ''}"
                                : "${provider.firstName ?? ''} ${provider.lastName ?? ''}";

                            final jobTitle = _getDisplayJobTitle(
                              provider.title,
                              provider.titleInArabic,
                              isArabic,
                            );

                            final durationValue = double.tryParse(service.currentDurationOfServices) ?? 1.0;
                            final durationUnit = cubit.getLocalizedDurationUnit(
                              context,
                              service.currentSelectedDurationUnit,
                              quantity: durationValue,
                            );

                            // Request Date: FIRST timestamp
                            final requestDate = timestampsArray.isNotEmpty
                                ? DateTime.fromMillisecondsSinceEpoch(timestampsArray.first)
                                : DateTime.now();

                            // ✅ FIX: `.first` on an empty list throws a
                            // StateError, which would take the whole grid down
                            // for one request doc written without a timestamps
                            // array. Fall back to requestDate instead.
                            final lastUpdate = timestampsArray.isEmpty
                                ? requestDate
                                : DateTime.fromMillisecondsSinceEpoch(timestampsArray.last);

                            return GestureDetector(
                              onTap: () {
                                navigateTo(
                                  context,
                                  MyRequestDetailsServicesToggle(myRequestDetailsModel: service),
                                );
                              },
                              child: CustomServiceCardMyRequest(
                                provider: service,
                                title: serviceName,
                                jobTitle: jobTitle,
                                status: cubit.getFinalStateFromModel(service),
                                dateRequest: DateFormat('dd MMM yyyy').format(requestDate),
                                lastUpdate: DateFormat('dd MMM yyyy h:mm a').format(lastUpdate),
                                pointOfContact: pointOfContact,
                              ),
                            );
                          },
                        ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    ));
  }
}
