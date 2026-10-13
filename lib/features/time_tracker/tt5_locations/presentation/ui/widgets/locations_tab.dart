/// Module: time_tracker / tt5_locations / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: locations_tab.dart
/// Purpose: Declares `LocationsTab` — the "Locations" tab: Search · Filter ·
///          Export · Import · + Location, then the locations table (cards on
///          phone). A row opens the location's details.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Figma `661:37368`. Only for companies WITHOUT HR (owner decision 12 —
/// the tab is hidden with HR). Gates: the tab needs `View_Locations`;
/// Export `Export_Locations` (CSV, like phase 2); Import `Import_Locations`;
/// + Location `Create_Location`. Columns (inventory §H4, Area replaced by
/// the radius): Location Name · Google Map · Latitude · Longitude ·
/// Geofencing · Geofencing Radius · Country · State or Province · City ·
/// Postal Code · Work Hours · Working Days · Allow Breaks · Allow Pause ·
/// Break · Status. Sections slide in; the table resizes (Size).
/// Updated: 9/10/2026 - UI fix round 1: icon-only Filter / Export (Figma
/// iPad portrait `661:37139`) and the centred search
/// (`time_tracker_controls`). Import keeps its label (not in Figma).
/// Updated: 9/10/2026 - phase 5: the Import label is the module's
/// `timeTrackerImport` (the core `import` key reads "تصدير" = Export in
/// Arabic).

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_csv_export.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_table.dart';
import 'package:knowticed_plus/features/time_tracker/tt5_locations/presentation/controller/locations_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt5_locations/presentation/ui/pages/location_details_page.dart';
import 'package:knowticed_plus/features/time_tracker/tt5_locations/presentation/ui/pages/location_form_page.dart';
import 'package:knowticed_plus/features/time_tracker/tt5_locations/presentation/ui/widgets/location_filter_dialog.dart';
import 'package:knowticed_plus/features/time_tracker/tt5_locations/presentation/ui/widgets/location_import_dialog.dart';
import 'package:knowticed_plus/features/time_tracker/tt5_locations/presentation/ui/widgets/location_text.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class LocationsTab extends StatefulWidget {
  const LocationsTab({super.key});

  @override
  State<LocationsTab> createState() => _LocationsTabState();
}

class _LocationsTabState extends State<LocationsTab> {
  final TextEditingController _search = TextEditingController();

  TimeTrackerAccess get _access => GetIt.instance<TimeTrackerAccess>();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _openFilter() async {
    final LocationsCubit cubit = context.read<LocationsCubit>();
    final LocationsFilter? picked = await CustomDialogManager.showContent<LocationsFilter>(
      context: context,
      width: 520,
      child: LocationFilterDialog(initial: cubit.state.filter),
    );
    if (picked != null) cubit.applyFilter(picked);
  }

  Future<void> _export(List<WorkLocation> rows) async {
    final S s = S.of(context);
    if (rows.isEmpty) {
      await CustomDialogManager.showMessage(
        context: context,
        lottiePath: AppAssets.lottieWarning,
        title: s.export,
        subtitle: s.timeTrackerExportEmpty,
      );
      return;
    }
    await exportTimeTrackerCsv(
      context: context,
      defaultFileName: s.timeTrackerLocationsExportName,
      header: LocationText.headers(context),
      rows: <List<String>>[for (final WorkLocation l in rows) LocationText.cells(context, l)],
    );
  }

  void _open(Widget page) =>
      Navigator.of(context).push<void>(MaterialPageRoute<void>(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationsCubit, LocationsState>(
      builder: (BuildContext context, LocationsState state) {
        final List<WorkLocation> rows = state.visible;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SlideInContent(child: _toolbar(context, state, rows)),
            SizedBox(height: 15.h),
            SlideInContent(
              delay: const Duration(milliseconds: 80),
              child: _body(context, state, rows),
            ),
            SizedBox(height: 15.h),
          ],
        );
      },
    );
  }

  Widget _toolbar(BuildContext context, LocationsState state, List<WorkLocation> rows) {
    final S s = S.of(context);
    final bool hasHr = state.companyHasHr;
    return Row(
      children: <Widget>[
        TtSearchField(
          controller: _search,
          onChanged: context.read<LocationsCubit>().searchChanged,
        ),
        SizedBox(width: 15.w),
        TtFilterButton(
          key: const ValueKey<String>('locationsFilterButton'),
          active: state.filter.isActive,
          onTap: _openFilter,
        ),
        if (_access.canExportLocations(companyHasHr: hasHr)) ...<Widget>[
          SizedBox(width: 15.w),
          TtExportButton(
            key: const ValueKey<String>('locationsExportButton'),
            onTap: () => _export(rows),
          ),
        ],
        if (_access.canImportLocations(companyHasHr: hasHr)) ...<Widget>[
          SizedBox(width: 15.w),
          TtToolbarButton(
            key: const ValueKey<String>('locationsImportButton'),
            title: s.timeTrackerImport,
            icon: TtAssets.import,
            onTap: () => showLocationImportDialog(context),
          ),
        ],
        if (_access.canCreateLocation(companyHasHr: hasHr)) ...<Widget>[
          SizedBox(width: 15.w),
          TtToolbarButton(
            key: const ValueKey<String>('locationsAddButton'),
            title: s.timeTrackerLocation,
            icon: TtAssets.add,
            onTap: () => _open(const LocationFormPage()),
          ),
        ],
      ],
    );
  }

  Widget _body(BuildContext context, LocationsState state, List<WorkLocation> rows) {
    if (state.isLoading) {
      return Padding(
        padding: EdgeInsetsDirectional.symmetric(vertical: 60.h),
        child: const Center(child: CircleProgressMaster()),
      );
    }
    if (state.status == LocationsLoadStatus.failure) {
      return Padding(
        padding: EdgeInsetsDirectional.symmetric(vertical: 60.h),
        child: Text(S.of(context).timeTrackerLoadError,
            textAlign: TextAlign.center,
            style: StyleText.fontSize14Weight400.copyWith(color: AppColors.red)),
      );
    }
    if (rows.isEmpty) return const CustomEmptyState();
    void open(WorkLocation l) => _open(LocationDetailsPage(locationId: l.id));
    if (context.isPhone) return _cards(context, rows, open);
    return TimeTrackerTable(
      key: const ValueKey<String>('locationsTable'),
      columns: LocationText.columns(context),
      rowKeys: <Key>[for (final WorkLocation l in rows) ValueKey<String>('locationRow_${l.id}')],
      rows: <List<TtCell>>[for (final WorkLocation l in rows) LocationText.tableCells(context, l)],
      onRowTap: (int i) => open(rows[i]),
    );
  }

  Widget _cards(BuildContext context, List<WorkLocation> rows, ValueChanged<WorkLocation> open) {
    final S s = S.of(context);
    return AnimatedSizeWrap(
      child: Column(
        children: <Widget>[
          for (final WorkLocation l in rows)
            GestureDetector(
              key: ValueKey<String>('locationRow_${l.id}'),
              onTap: () {
                HapticController.low();
                open(l);
              },
              child: Container(
                margin: EdgeInsetsDirectional.only(bottom: 10.h),
                padding: EdgeInsetsDirectional.all(12.r),
                decoration: BoxDecoration(color: AppColors.card, borderRadius: CardStyles.radius()),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(children: <Widget>[
                      Expanded(
                        child: Text(LocationText.name(context, l),
                            style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
                      ),
                      LocationStatusText(status: l.status),
                    ]),
                    SizedBox(height: 6.h),
                    Text(LocationText.hours(context, l),
                        style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText)),
                    Text('${s.timeTrackerGeofencing}: ${LocationText.yesNo(context, l.isGeofenceEnabled)}',
                        style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
