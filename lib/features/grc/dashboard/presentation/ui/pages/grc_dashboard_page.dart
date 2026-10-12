/// Module: GRC — Dashboard
///
///*************************** FILE INFO ****************************///
/// File Name: grc_dashboard_page.dart
/// Purpose: Declares `GrcDashboardPage` — the one page behind both GRC
///          dashboards:
///            * `GrcDashboardPage(module: m)` — "Dashboard", opened from
///              GrcModuleDetailsPage (Policies / Champions / Owners tabs).
///              Breadcrumb: GRC > <module> > Dashboard.
///            * `GrcDashboardPage()` — "Main Dashboard", opened from the GRC
///              root page. Breadcrumb: GRC > Dashboard.
/// Author: Amr Mesbah
/// Created: 16/9/2026
/// Updated: 16/9/2026 — body follows the Figma frame (see charts section).
///
/// Structure follows DashBoardMasterMobile: the page owns its cubit,
/// SideFrameMasterServices supplies the scaffold / breadcrumb / padding, and
/// a single charts-section widget draws everything.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/dashboard/presentation/controller/grc_dashboard_cubit.dart';
import 'package:knowticed_plus/features/grc/dashboard/presentation/controller/grc_dashboard_state.dart';
import 'package:knowticed_plus/features/grc/dashboard/presentation/ui/widgets/grc_dashboard_charts_section.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class GrcDashboardPage extends StatelessWidget {
  /// Null = Main Dashboard (all modules).
  final GRCModuleEntity? module;

  const GrcDashboardPage({super.key, this.module});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GrcDashboardCubit>(
      create: (_) =>
          GetIt.instance<GrcDashboardCubit>()..load(module: module),
      child: _GrcDashboardBody(module: module),
    );
  }
}

class _GrcDashboardBody extends StatelessWidget {
  final GRCModuleEntity? module;

  const _GrcDashboardBody({required this.module});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final m = module;

    // Same root title rule as grc_page.dart: "GRC" on a phone, the full name
    // where it fits.
    final rootTitle = screenSizeOf(context) == ScreenSize.mobile
        ? s.grc
        : s.governanceRiskCompliance;

    // Each crumb pops back to its own page: from the module dashboard, GRC is
    // two routes up and the module name is one.
    final navigator = Navigator.of(context);
    final frame = m == null
        ? SideFrameMasterServices(
            titleText: rootTitle,
            onFirstTap: () => navigator.maybePop(),
            secondTitle: s.dashboard,
            child: _content(context),
          )
        : SideFrameMasterServices(
            titleText: s.grc,
            onFirstTap: () => popFrameRoutes(context, 2),
            secondTitle: m.localizedName(isArabic: context.isArabic),
            onSecondTap: () => navigator.maybePop(),
            thirdTitle: s.dashboard,
            child: _content(context),
          );

    return frame;
  }

  Widget _content(BuildContext context) {
    // The frame gives an unbounded height on phone and a bounded one on
    // tablet/desktop; SideFrameScrollableBody handles both.
    return SideFrameScrollableBody(
      child: BlocBuilder<GrcDashboardCubit, GrcDashboardState>(
        builder: (context, state) {
          switch (state) {
            case GrcDashboardInitial():
            case GrcDashboardLoading():
              return SizedBox(
                height: 300.sp,
                child: const Center(child: CircleProgressMaster()),
              );
            case GrcDashboardFailure(:final message):
              return _failure(context, message);
            case final GrcDashboardLoaded loaded:
              return Padding(
                padding: EdgeInsets.only(top: 5.sp, bottom: 20.sp),
                child: GrcDashboardChartsSection(state: loaded),
              );
          }
        },
      ),
    );
  }

  Widget _failure(BuildContext context, String message) {
    final s = S.of(context);
    return SizedBox(
      height: 300.sp,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              s.errorLoadingDashboard,
              style: StyleText.fontSize16Weight500
                  .copyWith(color: AppColors.text),
            ),
            SizedBox(height: 6.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: StyleText.fontSize14Weight500
                  .copyWith(color: AppColors.red),
            ),
            SizedBox(height: 16.h),
            TextButton(
              onPressed: () => context.read<GrcDashboardCubit>().reload(),
              child: Text(s.retry),
            ),
          ],
        ),
      ),
    );
  }
}
