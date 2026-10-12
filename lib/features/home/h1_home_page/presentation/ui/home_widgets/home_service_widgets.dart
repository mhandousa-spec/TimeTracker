/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: home_service_widgets.dart
/// Purpose: The seven Services-module cards on the Adding Widget picker —
///          `RequestService`, `ServicesActions`, `ServicesStatus`,
///          `MyServices`, `NearBreachedSLA`, `ServiceOverview` and
///          `MyRequestServices`.
/// Author: Knowticed Plus team
/// Created at: 23/8/2026
///
/// These seven names were already referenced by `HomeComponents.widget()`, but
/// the cases were commented out because the widget files went away with the
/// old services module. Rebuilt here against Figma file BuJXLizpGcK5eHVBqQomXc,
/// Settings > Home Layout > Adding Widget, iPad Horizontal View (node
/// 4717:68984), so the commented cases could be restored as-is.
///
/// Updated: 30/8/2026 - WIRED TO REAL DATA. Every figure below used to be the
/// placeholder its Figma frame drew — 32 / 12 / 08, six bars all reading 84,
/// four tiles all reading 10, "Total 100", and two rows both named "Market
/// Research Service". They now come from [ServicesHomeStatsCubit], which reads
/// the services module's own repository; see that file for why a home card
/// cannot simply read `ServicesManagerCubit`.
///
/// While the figures are in the air — and for any source that failed — the
/// cards show an em dash rather than a zero. "No pending requests" and "we
/// could not read the requests" are different facts, and a card must not state
/// the first when it means the second.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/services_home_stats_cubit.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/services_home_stats_state.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/home_widgets/home_widget_shell.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Shared scaffolding for every Services card that shows live figures.
///
/// ADDED 30/8/2026. Each card is the same three things — kick the lazy load,
/// rebuild on the cubit, render an em dash until the figures land — so the
/// `ensureLoaded` call, the BlocBuilder and the placeholder rule live here once
/// rather than seven times. Mirrors `_RolesStatCard` in
/// `home_roles_widgets.dart`.
///
/// [builder] receives:
///   * the cubit, for the counts;
///   * `format`, which renders an int in the reader's numerals, or `—` when
///     the figures are not ready.
class _ServicesStatsBuilder extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    ServicesHomeStatsCubit stats,
    String Function(int) format,
    bool ready,
  ) builder;

  const _ServicesStatsBuilder({required this.builder});

  @override
  Widget build(BuildContext context) {
    // Lazy by design: BlocProvider builds the cubit on this first read, and the
    // cubit fetches on this first ensureLoaded. An account that never opens
    // Home or the picker never triggers either.
    context.read<ServicesHomeStatsCubit>().ensureLoaded();

    return BlocBuilder<ServicesHomeStatsCubit, ServicesHomeStatsState>(
      builder: (BuildContext context, ServicesHomeStatsState state) {
        final bool ready = state is ServicesHomeStatsLoaded;
        final ServicesHomeStatsCubit stats =
            context.read<ServicesHomeStatsCubit>();

        String format(int value) =>
            ready ? LocalizedNumber.of(context, value) : '—';

        return builder(context, stats, format, ready);
      },
    );
  }
}

/// Figma: "Requested Service" — the most recent requests, each with a View
/// action.
class RequestService extends StatelessWidget {
  /// Carried for parity with every other component widget; the card itself
  /// renders the same preview regardless of its position.
  final HomeComponentModel model;

  const RequestService({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    final bool isArabic = context.isArabic;

    return _ServicesStatsBuilder(
      builder: (BuildContext context, ServicesHomeStatsCubit stats,
          String Function(int) format, bool ready) {
        return HomeWidgetCard(
          title: l.requestedService,
          icon: HomeWidgetSvg.service,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // An empty queue and an unread queue both render as placeholder
              // rows, so the card keeps its height either way and the grid does
              // not reflow when the figures land.
              for (final ServiceRequestSummary request
                  in _rowsOrPlaceholders(stats.recentRequests, ready))
                HomeEntityRow(
                  icon: HomeWidgetSvg.serviceRequest,
                  name: request.name(isArabic),
                  subtitle: request.department(isArabic).trim().isEmpty
                      ? l.department
                      : request.department(isArabic),
                  trailing: SizedBox(
                    width: 46.w,
                    child: HomeCardButton(label: l.view),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Figma: "Service" — the three service actions, stacked.
///
/// No figures: this card is three buttons. It is the one Services card that
/// needs no data, so it does not go through [_ServicesStatsBuilder] and does
/// not trigger a load.
class ServicesActions extends StatelessWidget {
  final HomeComponentModel model;

  const ServicesActions({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    return HomeWidgetCard(
      title: l.service,
      icon: HomeWidgetSvg.service,
      width: kHomeWidgetNarrowWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HomeCardButton(
            label: l.createService,
            icon: HomeWidgetSvg.serviceTap,
          ),
          SizedBox(height: 4.h),
          HomeCardButton(label: l.myRequests),
          SizedBox(height: 4.h),
          HomeCardButton(label: l.viewApproval),
        ],
      ),
    );
  }
}

/// Figma: "Services Status" — six status bars, the tall 200-high card.
class ServicesStatus extends StatelessWidget {
  final HomeComponentModel model;

  const ServicesStatus({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);

    return _ServicesStatsBuilder(
      builder: (BuildContext context, ServicesHomeStatsCubit stats,
          String Function(int) format, bool ready) {
        // (label, bucket key, colour) in the order Figma lists them. The
        // fractions used to be six hardcoded decimals; they are computed below.
        final List<(String, String, Color)> rows = <(String, String, Color)>[
          (l.BreachedSLA, ServiceStatusKey.breachedSla, AppColors.darkRed),
          (l.canceled, ServiceStatusKey.cancel, AppColors.lightRed),
          (l.rejected, ServiceStatusKey.rejected, AppColors.red),
          (l.Inprogress, ServiceStatusKey.inProgress, AppColors.primary),
          (l.approved, ServiceStatusKey.approved, AppColors.green),
          (l.done, ServiceStatusKey.done, AppColors.lightGreen),
        ];

        // Bars are scaled to the LARGEST bucket, not to the total — see
        // `ServicesHomeStatsCubit.statusPeak`. Flat while unread, so the card
        // does not animate six bars up from nothing on every rebuild.
        final int peak = stats.statusPeak;

        return HomeWidgetCard(
          title: l.servicesStatus,
          icon: HomeWidgetSvg.service,
          minHeight: kHomeWidgetTallHeight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (final (String label, String key, Color color) in rows)
                HomeProgressRow(
                  label: label,
                  value: format(stats.statusCounts[key] ?? 0),
                  fraction:
                      ready ? (stats.statusCounts[key] ?? 0) / peak : 0,
                  color: color,
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Figma: "Services" — Approved / Pending / Rejected counts.
class MyServices extends StatelessWidget {
  final HomeComponentModel model;

  const MyServices({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);

    return _ServicesStatsBuilder(
      builder: (BuildContext context, ServicesHomeStatsCubit stats,
          String Function(int) format, bool ready) {
        return HomeWidgetCard(
          title: l.services,
          icon: HomeWidgetSvg.service,
          child: HomeStatTileRow(
            tiles: <HomeStatTile>[
              HomeStatTile(
                icon: HomeWidgetSvg.approved,
                label: l.approved,
                value:
                    format(stats.statusCounts[ServiceStatusKey.approved] ?? 0),
              ),
              HomeStatTile(
                icon: HomeWidgetSvg.pending,
                label: l.pending,
                value:
                    format(stats.statusCounts[ServiceStatusKey.pending] ?? 0),
              ),
              HomeStatTile(
                icon: HomeWidgetSvg.rejected,
                label: l.rejected,
                value:
                    format(stats.statusCounts[ServiceStatusKey.rejected] ?? 0),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Figma: "Near Breached SLA" — the breach percentage sits where the module
/// glyph normally does, with a chat shortcut on each row.
///
/// ⚠️ The rows are requests that HAVE breached, not ones approaching a breach —
/// see `ServicesHomeStatsCubit.breachedRequests` for why.
class NearBreachedSLA extends StatelessWidget {
  final HomeComponentModel model;

  const NearBreachedSLA({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    final bool isArabic = context.isArabic;

    return _ServicesStatsBuilder(
      builder: (BuildContext context, ServicesHomeStatsCubit stats,
          String Function(int) format, bool ready) {
        final String percent = ready
            ? '${LocalizedNumber.of(context, (stats.breachedSlaRatio * 100).round())}%'
            : '—';

        return HomeWidgetCard(
          title: l.nearBreachedSLA,
          trailing: Text(
            percent,
            style: CardStyles.value(11).copyWith(color: AppColors.text),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (final ServiceRequestSummary request
                  in _rowsOrPlaceholders(stats.breachedRequests, ready))
                HomeEntityRow(
                  icon: HomeWidgetSvg.serviceRequest,
                  name: request.name(isArabic),
                  subtitle: request.department(isArabic).trim().isEmpty
                      ? l.department
                      : request.department(isArabic),
                  trailing: Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: CustomSvgImage(
                      assetPath: HomeWidgetSvg.chat,
                      width: 12.r,
                      height: 12.r,
                      color: AppColors.textButton,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Figma: "Services" totals — four tiles across three grid columns.
class ServiceOverview extends StatelessWidget {
  final HomeComponentModel model;

  const ServiceOverview({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);

    return _ServicesStatsBuilder(
      builder: (BuildContext context, ServicesHomeStatsCubit stats,
          String Function(int) format, bool ready) {
        return HomeWidgetCard(
          title: l.services,
          icon: HomeWidgetSvg.service,
          width: kHomeWidgetWideWidth,
          child: HomeStatTileRow(
            tiles: <HomeStatTile>[
              HomeStatTile(
                icon: HomeWidgetSvg.serviceTap,
                label: l.totalServices,
                // The CATALOGUE — how many services exist to be requested.
                value: format(stats.totalServices),
                iconColor: AppColors.primary,
              ),
              HomeStatTile(
                icon: HomeWidgetSvg.serviceRequest,
                label: l.totalRequests,
                value: format(stats.totalRequests),
                iconColor: AppColors.primary,
              ),
              HomeStatTile(
                icon: HomeWidgetSvg.sla,
                label: l.totalSLA,
                // ⚠️ ASSUMPTION: "Total SLA" is read as the number of requests
                // that have BREACHED their SLA — the only SLA figure a request
                // document actually carries. If the tile is meant to count
                // requests that HAVE an SLA defined, that is a different read
                // (the SLA fields on the service, not the request's state) and
                // this line is where it changes.
                value: format(
                    stats.statusCounts[ServiceStatusKey.breachedSla] ?? 0),
                iconColor: AppColors.primary,
              ),
              HomeStatTile(
                icon: HomeWidgetSvg.done,
                label: l.totalDone,
                value: format(stats.statusCounts[ServiceStatusKey.done] ?? 0),
                iconColor: AppColors.green,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Figma: "My Request" — the one-column request summary.
///
/// The only Services card scoped to the reader rather than to the whole queue,
/// which is what its title claims — see
/// `ServicesHomeStatsCubit.myRequestCounts`.
class MyRequestServices extends StatelessWidget {
  final HomeComponentModel model;

  const MyRequestServices({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);

    return _ServicesStatsBuilder(
      builder: (BuildContext context, ServicesHomeStatsCubit stats,
          String Function(int) format, bool ready) {
        return HomeWidgetCard(
          title: l.myRequest,
          icon: HomeWidgetSvg.service,
          width: kHomeWidgetNarrowWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('${l.total} ${format(stats.myRequestTotal)}',
                  style: CardStyles.label(10)),
              SizedBox(height: 4.h),
              // The three glyphs, in the order Figma draws them: rejected,
              // approved, still waiting.
              HomeCountLine(
                icon: HomeWidgetSvg.rejectedStamp,
                value: format(
                    stats.myRequestCounts[ServiceStatusKey.rejected] ?? 0),
              ),
              HomeCountLine(
                icon: HomeWidgetSvg.checkGreen,
                value: format(
                    stats.myRequestCounts[ServiceStatusKey.approved] ?? 0),
              ),
              HomeCountLine(
                icon: HomeWidgetSvg.hourglass,
                value: format(
                    stats.myRequestCounts[ServiceStatusKey.pending] ?? 0),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Function Name: [_rowsOrPlaceholders]
///
/// Purpose: Exactly two rows for the list cards, whatever the data says.
///
/// ADDED 30/8/2026. Both list cards draw two rows in Figma, and the picker
/// lays its cards out in a `Wrap` — a card that grew or shrank when its figures
/// landed would reflow the whole grid under the user's cursor. So an empty or
/// unread list is padded to two blank-named rows: same height, no invented
/// content.
List<ServiceRequestSummary> _rowsOrPlaceholders(
  List<ServiceRequestSummary> rows,
  bool ready,
) {
  const int wanted = 2;
  if (ready && rows.length >= wanted) return rows.take(wanted).toList();

  return <ServiceRequestSummary>[
    ...rows.take(wanted),
    for (int i = rows.length; i < wanted; i++)
      const ServiceRequestSummary(
        nameEnglish: '—',
        nameArabic: '—',
        departmentEnglish: '',
        departmentArabic: '',
      ),
  ];
}
