// ******************* FILE INFO *******************
// File Name: service_stats_widget
// Description: Service stats widget.
// Module: services_management_module / presentation/s5_service_details/ui/widgets
// *************************************************
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/services_management_module/s5_service_details/presentation/ui/widgets/dialog.dart';
import 'package:knowticed_plus/features/services_management_module/s5_service_details/presentation/ui/widgets/services_dialog.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/services_management_module/s5_service_details/data/service_stats_model.dart';
import 'package:knowticed_plus/features/services_management_module/s5_service_details/presentation/ui/widgets/info_text.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class ServiceStatsWidget extends StatelessWidget {
  final ServiceStatsModel stats;

  const ServiceStatsWidget({
    required this.stats,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ContextExtension(context).isPhone;
    final isTablet = ContextExtension(context).isTablet;
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return isMobile ? _buildMobileLayout(context, lightMode) : _buildTabletLayout(context, lightMode, isTablet);
  }

  Widget _buildMobileLayout(BuildContext context, bool lightMode) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: lightMode ? AppColors.white : AppColors.chatBackground,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(10.sp),
              child: Column(
                children: [
                  // Services mobile QA p.11: Approved removed from the service
                  // stats (as on tablet), Pending moved into its slot in this
                  // column and Breached SLA added to the right column.
                  OurServicesDialog(
                    color: AppColors.lightGreen,
                    title: S.of(context).Done,
                    image: "assets/icons_assets/services_assets/status_done_badge_green.svg",
                    number: "${stats.done}",
                  ),
                  SizedBox(height: 15.sp),
                  OurServicesDialog(
                    color: AppColors.secondaryPrimary,
                    title: S.of(context).Inprogress,
                    image: "assets/icons_assets/services_assets/work_in_progress_badge_yellow.svg",
                    number: "${stats.inprogress}",
                  ),
                  SizedBox(height: 15.sp),
                  OurServicesDialog(
                    color: AppColors.orange,
                    title: S.of(context).Pending,
                    image: "assets/icons_assets/main_icons_assets/status_pending_hourglass_orange.svg",
                    number: "${stats.pending}",
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 10.sp),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: lightMode ? AppColors.white : AppColors.chatBackground,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(10.sp),
              child: Column(
                children: [
                  OurServicesDialog(
                    color: AppColors.red,
                    title: S.of(context).Rejected,
                    image: "assets/icons_assets/main_icons_assets/status_rejected_stamp_red.svg",
                    number: "${stats.rejected}",
                  ),
                  SizedBox(height: 15.sp),
                  OurServicesDialog(
                    color: AppColors.red,
                    title: S.of(context).Canceled,
                    image: "assets/icons_assets/main_icons_assets/status_cancelled_stamp_red.svg",
                    number: "${stats.cancel}",
                  ),
                  SizedBox(height: 15.sp),
                  OurServicesDialog(
                    color: AppColors.red,
                    title: S.of(context).BreachedSLA,
                    image: "assets/icons_assets/services_assets/sla_stopwatch_badge_red.svg",
                    number: "${stats.branchsla}",
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context, bool lightMode, bool isTablet) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(15.sp),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                OurServicesDialog(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  color: AppColors.green,
                  title: S.of(context).Done,
                  image: "assets/icons_assets/services_assets/status_done_badge_green.svg",
                  number: "${stats.done}",
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(15.sp),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OurServicesDialog(
                        color: AppColors.lightGreen,
                        title: S.of(context).approved,
                        image: "assets/icons_assets/main_icons_assets/approve_icon.svg",
                        number: "${stats.approved}",
                      ),
                      SizedBox(height: 13.sp),
                      OurServicesDialog(
                        color: AppColors.secondaryPrimary,
                        title: S.of(context).Inprogress,
                        image: "assets/icons_assets/services_assets/work_in_progress_badge_yellow.svg",
                        number: "${stats.inprogress}",
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: !isTabletLandscape(context) ? 10.sp : 65.sp),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: lightMode ? AppColors.white : AppColors.chatBackground,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(15.sp),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OurServicesDialog(
                        color: AppColors.orange,
                        title: S.of(context).Pending,
                        image: "assets/icons_assets/main_icons_assets/status_pending_hourglass_orange.svg",
                        number: "${stats.pending}",
                      ),
                      SizedBox(height: 13.sp),
                      OurServicesDialog(
                        color: AppColors.red,
                        title: S.of(context).Rejected,
                        image: "assets/icons_assets/main_icons_assets/status_rejected_stamp_red.svg",
                        number: "${stats.rejected}",
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: !isTabletLandscape(context) ? 10.sp : 65.sp),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: lightMode ? AppColors.white : AppColors.chatBackground,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(15.sp),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OurServicesDialog(
                        color: AppColors.red,
                        title: S.of(context).Canceled,
                        image: "assets/icons_assets/main_icons_assets/status_cancelled_stamp_red.svg",
                        number: "${stats.cancel}",
                      ),
                      SizedBox(height: 13.sp),
                      OurServicesDialog(
                        color: AppColors.red,
                        title: S.of(context).BreachedSLA,
                        image: "assets/icons_assets/services_assets/sla_stopwatch_badge_red.svg",
                        number: "${stats.branchsla}",
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }



  Widget _buildTabletLayoutNew (BuildContext context, bool lightMode, bool isTablet) {
    return Column(
      children: [



        Container(
          height: 70.h,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Expanded(
                  child: OurServicesDialog(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    color: AppColors.green,
                    title: S.of(context).Done,
                    image: "assets/icons_assets/services_assets/status_done_badge_green.svg",
                    number: "${stats.done}",
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 15.sp),

        Container(
          height: 70.h,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Expanded(
                  child: OurServicesDialog(
                    color: AppColors.lightGreen,
                    title: S.of(context).approved,
                    image: "assets/icons_assets/main_icons_assets/approval_badge_check.svg",
                    number: "${stats.approved}",
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: OurServicesDialog(
                    color: AppColors.secondaryPrimary,
                    title: S.of(context).Inprogress,
                    image: "assets/icons_assets/services_assets/work_in_progress_badge_yellow.svg",
                    number: "${stats.inprogress}",
                  ),
                ),
                Expanded(
                  child: OurServicesDialog(
                    color: AppColors.red,
                    title: S.of(context).Canceled,
                    image: "assets/icons_assets/main_icons_assets/status_cancelled_stamp_red.svg",
                    number: "${stats.cancel}",
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 15.sp),

        Container(
          height: 70.h,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Expanded(
                  child: OurServicesDialog(
                    color: AppColors.red,
                    title: S.of(context).BreachedSLA,
                    image: "assets/icons_assets/services_assets/sla_stopwatch_badge_red.svg",
                    number: "${stats.branchsla}",
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: OurServicesDialog(
                    color: AppColors.orange,
                    title: S.of(context).Pending,
                    image: "assets/icons_assets/main_icons_assets/status_pending_hourglass_orange.svg",
                    number: "${stats.pending}",
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: OurServicesDialog(
                    color: AppColors.red,
                    title: S.of(context).Rejected,
                    image: "assets/icons_assets/main_icons_assets/status_rejected_stamp_red.svg",
                    number: "${stats.rejected}",
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
