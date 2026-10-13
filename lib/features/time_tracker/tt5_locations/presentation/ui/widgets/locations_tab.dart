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

import 'package:knowticed_plus/features/time_tracker/domain/enums/setup_status.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_card_grid.dart';
import 'package:knowticed_plus/core/custom/40-custom_table_button.dart';
import 'package:knowticed_plus/core/custom/39-custom_grid_button.dart';
import 'package:knowticed_plus/core/custom/8-custom_filter_app.dart';
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
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_formatters.dart';
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
      width: TtDialogWidth.standard,
      child: LocationFilterDialog(initial: cubit.state.filter),
    );
    if (picked != null) cubit.applyFilter(picked);
  }

  Future<void> _export(List<WorkLocation> rows) async {
    final S s = S.of(context);
    if (rows.isEmpty) {
      await CustomDialogManager.showMessage(
        width: TtDialogWidth.status,
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

  void _open(Widget page) => Navigator.of(context).push<void>(MaterialPageRoute<void>(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationsCubit, LocationsState>(
      builder: (BuildContext context, LocationsState state) {
        final List<WorkLocation> rows = state.visible;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // 13/10/2026 (owner): All · Active · Inactive counters (like
            // Approvals / Request Types), then the toolbar, then List / Grid.
            SlideInContent(child: _counters(context, state)),
            SizedBox(height: 15.h),
            SlideInContent(child: _toolbar(context, state, rows)),
            if (!context.isPhone) ...<Widget>[
              SizedBox(height: 10.h),
              SlideInContent(delay: const Duration(milliseconds: 60), child: _viewToggle(context, state)),
            ],
            SizedBox(height: 10.h),
            SlideInContent(
              delay: const Duration(milliseconds: 80),
              child: BounceSwitcher(triggerValue: state.isGrid, child: _body(context, state, rows)),
            ),
            SizedBox(height: 15.h),
          ],
        );
      },
    );
  }

  Widget _counters(BuildContext context, LocationsState state) {
    final S s = S.of(context);
    final LocationsCubit cubit = context.read<LocationsCubit>();
    final List<WorkLocation> all = state.listed;
    const List<LocationStatus> shown = <LocationStatus>[LocationStatus.active, LocationStatus.inactive];
    return StatusChipFilter(
      key: const ValueKey<String>('locationCounters'),
      items: <StatusChipItem>[
        StatusChipItem(key: 'all', label: s.timeTrackerAll, count: all.length),
        for (final LocationStatus st in shown)
          StatusChipItem(
            key: st.storageKey,
            label: LocationText.status(context, st),
            count: all.where((WorkLocation l) => l.status == st).length,
            labelColor: LocationStatusText.colorOf(st),
          ),
      ],
      selectedKey: state.filter.status?.storageKey ?? 'all',
      onSelected: (String key) {
        HapticController.low();
        cubit.filterStatus(key == 'all' ? null : shown.firstWhere((LocationStatus st) => st.storageKey == key));
      },
    );
  }

  Widget _viewToggle(BuildContext context, LocationsState state) {
    final LocationsCubit cubit = context.read<LocationsCubit>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        KeyedSubtree(
          key: const ValueKey<String>('locationsTableToggle'),
          child: customTableButton(
            function: () => cubit.setGrid(false),
            isSelected: !state.isGrid,
            color: AppColors.card,
          ),
        ),
        SizedBox(width: 10.w),
        KeyedSubtree(
          key: const ValueKey<String>('locationsGridToggle'),
          child: customGridButton(function: () => cubit.setGrid(true), isSelected: state.isGrid),
        ),
      ],
    );
  }

  Widget _toolbar(BuildContext context, LocationsState state, List<WorkLocation> rows) {
    final S s = S.of(context);
    final bool hasHr = state.companyHasHr;
    // 13/10/2026 (owner S1, Figma): Search · Filter · Export · Import in one
    // row; "+ Location" full width under it on a phone.
    return TtToolbarWithPrimary(
      tools: <Widget>[
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
      ],
      primary: _access.canCreateLocation(companyHasHr: hasHr)
          ? TtToolbarButton(
              key: const ValueKey<String>('locationsAddButton'),
              title: s.timeTrackerLocation,
              icon: TtAssets.add,
              wide: context.isPhone,
              onTap: () => _open(const LocationFormPage()),
            )
          : null,
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
            textAlign: TextAlign.center, style: StyleText.fontSize14Weight400.copyWith(color: AppColors.red)),
      );
    }
    if (rows.isEmpty) return const CustomEmptyState();
    void open(WorkLocation l) => _open(LocationDetailsPage(locationId: l.id));
    if (context.isPhone) return _cards(context, rows, open);
    // 13/10/2026 (owner): tablet Grid = the phone card in the house grid.
    if (state.isGrid) {
      return TtCardGrid(
        key: const ValueKey<String>('locationsGrid'),
        children: <Widget>[for (final WorkLocation l in rows) LocationCard(location: l, inGrid: true, onTap: () => open(l))],
      );
    }
    return TimeTrackerTable(
      key: const ValueKey<String>('locationsTable'),
      columns: LocationText.columns(context),
      rowKeys: <Key>[for (final WorkLocation l in rows) ValueKey<String>('locationRow_${l.id}')],
      rows: <List<TtCell>>[for (final WorkLocation l in rows) LocationText.tableCells(context, l)],
      onRowTap: (int i) => open(rows[i]),
    );
  }

  Widget _cards(BuildContext context, List<WorkLocation> rows, ValueChanged<WorkLocation> open) {
    return AnimatedSizeWrap(
      child: Column(
        children: <Widget>[
          for (final WorkLocation l in rows)
            Padding(
              padding: EdgeInsetsDirectional.only(bottom: 10.h),
              child: LocationCard(location: l, onTap: () => open(l)),
            ),
        ],
      ),
    );
  }
}

/// 13/10/2026 (owner S2, Figma `661:117634`): the phone location card —
/// Last Update on top, the building icon box + name, then Geofencing,
/// Country, City, Allow Breaks, Allow Pause with their Figma icons, and
/// Created Date at the end of the last line.
class LocationCard extends StatelessWidget {
  const LocationCard({super.key, required this.location, required this.onTap, this.inGrid = false});

  final WorkLocation location;
  final VoidCallback onTap;

  /// In the tablet grid (equal-height rows): the last line sits at the
  /// bottom. On a phone list the card hugs its content.
  final bool inGrid;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final WorkLocation l = location;
    final TextStyle label = StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText);
    final TextStyle value = StyleText.fontSize12Weight500.copyWith(color: AppColors.text);
    String onOff(bool v) => v ? s.timeTrackerOn : s.timeTrackerOff;
    Widget line(String icon, String l, Widget v) => Padding(
          padding: EdgeInsetsDirectional.only(top: 6.h),
          child: Row(
            children: <Widget>[
              TtIcon(TtGlyph.svg(icon), size: 14.r, color: AppColors.secondaryText),
              SizedBox(width: 6.w),
              Flexible(child: Text('$l: ', maxLines: 1, overflow: TextOverflow.ellipsis, style: label)),
              Flexible(child: v),
            ],
          ),
        );
    Text text(String v) => Text(v, maxLines: 1, overflow: TextOverflow.ellipsis, style: value);
    final TextStyle small = StyleText.fontSize10Weight400.copyWith(color: AppColors.secondaryText);
    return GestureDetector(
      key: ValueKey<String>('locationRow_${l.id}'),
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticController.low();
        onTap();
      },
      child: Container(
        padding: EdgeInsetsDirectional.all(10.r),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: CardStyles.radius()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child:
                  Text(s.timeTrackerLastUpdateValue(TimeTrackerFormat.date(context, l.audit.updatedAt)), style: small),
            ),
            SizedBox(height: 2.h),
            Row(
              children: <Widget>[
                Container(
                  width: 36.r,
                  height: 36.r,
                  padding: EdgeInsetsDirectional.all(7.r),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadiusDirectional.circular(8.r),
                  ),
                  child: TtIcon(const TtGlyph.svg(TtAssets.locBuilding), size: 22.r, color: AppColors.text),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(LocationText.name(context, l),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
                ),
              ],
            ),
            line(TtAssets.locGeofence, s.timeTrackerGeofencing, text(onOff(l.isGeofenceEnabled))),
            line(TtAssets.locCountry, s.timeTrackerCountry, text(LocationText.country(context, l))),
            line(TtAssets.locCity, s.timeTrackerCity, text(LocationText.city(context, l))),
            line(TtAssets.dayBreak, s.timeTrackerAllowBreaks, text(onOff(l.isBreakAllowed))),
            line(TtAssets.locPause, s.timeTrackerAllowPause, text(onOff(l.isPauseAllowed))),
            // Fills only when a neighbour in the grid row is taller.
            if (inGrid) const Spacer() else SizedBox(height: 6.h),
            // 13/10/2026 (owner): the Status line (Active green / Inactive
            // red), with Created Date at the end edge.
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  child: line(
                    TtAssets.rtStatus,
                    s.timeTrackerStatus,
                    Text(LocationText.status(context, l.status),
                        style: StyleText.fontSize12Weight500.copyWith(color: LocationStatusText.colorOf(l.status))),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(s.timeTrackerCreatedDateValue(TimeTrackerFormat.date(context, l.audit.createdAt)), style: small),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
