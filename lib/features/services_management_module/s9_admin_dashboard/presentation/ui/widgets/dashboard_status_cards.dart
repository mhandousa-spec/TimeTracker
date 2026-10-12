// ******************* FILE INFO *******************
// File Name: dashboard_status_cards.dart
// Description: Service status count cards (Done, Inprogress, Pending, etc.)
// Module: services_management_module / presentation / s9_admin_dashboard / ui / widgets
// Created by: Amr Mesbah

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/services_management_module/s5_service_details/presentation/ui/widgets/services_dialog.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';


class DashboardStatusCards extends StatelessWidget {
  final Map<String, int> statusCounts;
  final bool isMobile;
  final bool lightMode;

  const DashboardStatusCards({
    super.key,
    required this.statusCounts,
    required this.isMobile,
    required this.lightMode,
  });

  @override
  Widget build(BuildContext context) {
    return isMobile ? _buildMobile(context) : _buildDesktop(context);
  }

  Widget _buildMobile(BuildContext context) {
    return Row(
      children: [
        Column(children: [
          _cardContainer(
            width: 168.sp,
            children: [
              OurServicesDialog(
                color: AppColors.green,
                title: S.of(context).Done,
                image: "assets/icons_assets/services_assets/status_done_badge_green.svg",
                number: "${statusCounts['done'] ?? 0}",
              ),
              SizedBox(height: 10.sp),
              OurServicesDialog(
                color: AppColors.secondaryPrimary,
                title: S.of(context).Inprogress,
                image: "assets/icons_assets/services_assets/work_in_progress_badge_yellow.svg",
                number: "${statusCounts['inprogress'] ?? 0}",
              ),
              SizedBox(height: 10.sp),
              OurServicesDialog(
                color: AppColors.orange,
                title: S.of(context).Pending,
                image: "assets/icons_assets/main_icons_assets/status_pending_hourglass_orange.svg",
                number: "${statusCounts['pending'] ?? 0}",
              ),
            ],
          ),
        ]),
        SizedBox(width: 9.sp),
        Column(children: [
          _cardContainer(
            width: 168.sp,
            children: [
              OurServicesDialog(
                color: AppColors.red,
                title: S.of(context).Rejected,
                image: "assets/icons_assets/main_icons_assets/status_rejected_stamp_red.svg",
                number: "${statusCounts['rejected'] ?? 0}",
              ),
              SizedBox(height: 10.sp),
              OurServicesDialog(
                color: AppColors.red,
                title: S.of(context).BreachedSLA,
                image: "assets/icons_assets/services_assets/sla_stopwatch_badge_red.svg",
                number: "${statusCounts['branchsla'] ?? 0}",
              ),
              SizedBox(height: 10.sp),
              OurServicesDialog(
                color: AppColors.red,
                title: S.of(context).Canceled,
                image: "assets/icons_assets/main_icons_assets/status_cancelled_stamp_red.svg",
                number: "${statusCounts['cancel'] ?? 0}",
              ),
            ],
          ),
        ]),
      ],
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _cardContainer(
            children: [
              OurServicesDialog(
                color: AppColors.green,
                title: S.of(context).Done,
                image: "assets/icons_assets/services_assets/status_done_badge_green.svg",
                number: "${statusCounts['done'] ?? 0}",
              ),
              SizedBox(height: 15.sp),
              OurServicesDialog(
                color: AppColors.secondaryPrimary,
                title: S.of(context).Inprogress,
                image: "assets/icons_assets/services_assets/work_in_progress_badge_yellow.svg",
                number: "${statusCounts['inprogress'] ?? 0}",
              ),
            ],
          ),
        ),
        SizedBox(width: 29.sp),
        Expanded(
          child: _cardContainer(
            children: [
              OurServicesDialog(
                color: AppColors.orange,
                title: S.of(context).Pending,
                image: "assets/icons_assets/main_icons_assets/status_pending_hourglass_orange.svg",
                number: "${statusCounts['pending'] ?? 0}",
              ),
              SizedBox(height: 15.sp),
              OurServicesDialog(
                color: AppColors.red,
                title: S.of(context).Rejected,
                image: "assets/icons_assets/main_icons_assets/status_rejected_stamp_red.svg",
                number: "${statusCounts['rejected'] ?? 0}",
              ),
            ],
          ),
        ),
        SizedBox(width: 29.sp),
        Expanded(
          child: _cardContainer(
            children: [
              OurServicesDialog(
                color: AppColors.red,
                title: S.of(context).Canceled,
                image: "assets/icons_assets/main_icons_assets/status_cancelled_stamp_red.svg",
                number: "${statusCounts['cancel'] ?? 0}",
              ),
              SizedBox(height: 15.sp),
              OurServicesDialog(
                color: AppColors.red,
                title: S.of(context).BreachedSLA,
                image: "assets/icons_assets/services_assets/sla_stopwatch_badge_red.svg",
                number: "${statusCounts['branchsla'] ?? 0}",
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _cardContainer({double? width, required List<Widget> children}) {
    Widget card = Container(
      width: width,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          right: 20.sp,
          left: 10.sp,
          top: 10.sp,
          bottom: 10.sp,
        ),
        child: Column(children: children),
      ),
    );
    return card;
  }
}
