/// Module: time_tracker / tt8_request_types / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: request_types_tab.dart
/// Purpose: Declares `RequestTypesTab` — the "Request Types" tab: Search ·
///          Filter · Export · + Request Type, the list / grid toggle, then
///          the request-type cards (or the table). A card / row opens the
///          type's details.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Figma `661:35833` (cards) / `661:36293` (table). Gates: the tab needs
/// `View_Request_Types`; Export `Export_Request_Types` (CSV, like phase
/// 2); + Request Type `Create_Request_Type`. Nothing is seeded — a company
/// with no types sees the core empty state. List ↔ grid bounces
/// (`BounceSwitcher`); sections slide in; the table resizes.
/// Updated: 9/10/2026 - UI fix round 1: icon-only Filter / Export (Figma
/// iPad portrait `661:35361`) and the centred search (`time_tracker_controls`).
/// Updated: 9/10/2026 - code review: Material icons → the app's SVG line
/// icons (`TtAssets` / `TtGlyph`) where an equivalent asset exists.
/// Updated: 9/10/2026 - owner review: the unselected LIST toggle uses the
/// card colour like the unselected GRID toggle (it used the page colour).
/// Updated: 9/10/2026 - UI quality pass (owner 13:45 #1): `TtCardGrid` —
/// compact cards that hug their content (Figma 661:35833), 10 padding.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/39-custom_grid_button.dart';
import 'package:knowticed_plus/core/custom/40-custom_table_button.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_card_grid.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_csv_export.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_formatters.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_table.dart';
import 'package:knowticed_plus/features/time_tracker/tt8_request_types/presentation/controller/request_types_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt8_request_types/presentation/ui/pages/request_type_details_page.dart';
import 'package:knowticed_plus/features/time_tracker/tt8_request_types/presentation/ui/pages/request_type_form_page.dart';
import 'package:knowticed_plus/features/time_tracker/tt8_request_types/presentation/ui/widgets/request_type_filter_dialog.dart';
import 'package:knowticed_plus/features/time_tracker/tt8_request_types/presentation/ui/widgets/request_type_text.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class RequestTypesTab extends StatefulWidget {
  const RequestTypesTab({super.key});

  @override
  State<RequestTypesTab> createState() => _RequestTypesTabState();
}

class _RequestTypesTabState extends State<RequestTypesTab> {
  final TextEditingController _search = TextEditingController();

  TimeTrackerAccess get _access => GetIt.instance<TimeTrackerAccess>();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _push(Widget page) =>
      Navigator.of(context).push<void>(MaterialPageRoute<void>(builder: (_) => page));

  Future<void> _export(RequestTypesState state, List<RequestType> rows) async {
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
      defaultFileName: s.timeTrackerRequestTypesExportName,
      header: <String>[s.timeTrackerColumnNo, ...RequestTypeText.headers(context)],
      rows: <List<String>>[
        for (int i = 0; i < rows.length; i++)
          <String>['${i + 1}', ...RequestTypeText.cells(context, rows[i], state)],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RequestTypesCubit, RequestTypesState>(
      builder: (BuildContext context, RequestTypesState state) {
        final List<RequestType> rows = state.visible;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SlideInContent(child: _toolbar(state, rows)),
            // iPhone rule (owner 9/10/2026): no List / Grid toggle, no table.
            if (!context.isPhone) ...<Widget>[
              SizedBox(height: 10.h),
              SlideInContent(delay: const Duration(milliseconds: 60), child: _viewToggle(state)),
            ],
            SizedBox(height: 10.h),
            SlideInContent(
              delay: const Duration(milliseconds: 120),
              child: BounceSwitcher(triggerValue: state.isGrid, child: _body(state, rows)),
            ),
            SizedBox(height: 15.h),
          ],
        );
      },
    );
  }

  Widget _toolbar(RequestTypesState state, List<RequestType> rows) {
    final S s = S.of(context);
    final RequestTypesCubit cubit = context.read<RequestTypesCubit>();
    return Row(
      children: <Widget>[
        TtSearchField(
          controller: _search,
          onChanged: cubit.searchChanged,
        ),
        SizedBox(width: 15.w),
        TtFilterButton(
          key: const ValueKey<String>('requestTypesFilterButton'),
          active: state.statusFilter != null,
          onTap: () async {
            final RequestTypeStatusChoice? picked =
                await CustomDialogManager.showContent<RequestTypeStatusChoice>(
              context: context,
              // 12/10/2026 (owner): the Approvals filter's width.
              width: 520,
              child: RequestTypeFilterDialog(initial: state.statusFilter),
            );
            if (picked != null) cubit.filterStatus(picked.status);
          },
        ),
        if (_access.canExportRequestTypes) ...<Widget>[
          SizedBox(width: 15.w),
          TtExportButton(
            key: const ValueKey<String>('requestTypesExportButton'),
            onTap: () => _export(state, rows),
          ),
        ],
        if (_access.canCreateRequestType) ...<Widget>[
          SizedBox(width: 15.w),
          TtToolbarButton(
            key: const ValueKey<String>('requestTypesAddButton'),
            title: s.timeTrackerRequestType,
            icon: TtAssets.add,
            onTap: () => _push(const RequestTypeFormPage()),
          ),
        ],
      ],
    );
  }

  Widget _viewToggle(RequestTypesState state) {
    final RequestTypesCubit cubit = context.read<RequestTypesCubit>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        KeyedSubtree(
          key: const ValueKey<String>('requestTypesTableToggle'),
          child: customTableButton(
            function: () => cubit.setGrid(false),
            isSelected: !state.isGrid,
            // Owner (9/10/2026): unselected = the grid button's look.
            color: AppColors.card,
          ),
        ),
        SizedBox(width: 10.w),
        KeyedSubtree(
          key: const ValueKey<String>('requestTypesGridToggle'),
          child: customGridButton(function: () => cubit.setGrid(true), isSelected: state.isGrid),
        ),
      ],
    );
  }

  Widget _body(RequestTypesState state, List<RequestType> rows) {
    if (state.isLoading) {
      return Padding(
        padding: EdgeInsetsDirectional.symmetric(vertical: 60.h),
        child: const Center(child: CircleProgressMaster()),
      );
    }
    if (state.status == RequestTypesLoadStatus.failure) {
      return Padding(
        padding: EdgeInsetsDirectional.symmetric(vertical: 60.h),
        child: Text(S.of(context).timeTrackerLoadError,
            textAlign: TextAlign.center,
            style: StyleText.fontSize14Weight400.copyWith(color: AppColors.red)),
      );
    }
    if (rows.isEmpty) return const CustomEmptyState(key: ValueKey<String>('requestTypesEmpty'));
    void open(RequestType t) => _push(RequestTypeDetailsPage(typeId: t.id));
    if (!state.isGrid && !context.isPhone) {
      return TimeTrackerTable(
        key: const ValueKey<String>('requestTypesTable'),
        columns: RequestTypeText.columns(context),
        rowKeys: <Key>[for (final RequestType t in rows) ValueKey<String>('requestTypeRow_${t.id}')],
        rows: <List<TtCell>>[
          for (int i = 0; i < rows.length; i++) RequestTypeText.tableCells(context, i, rows[i], state),
        ],
        onRowTap: (int i) => open(rows[i]),
      );
    }
    // UI quality pass (9/10/2026, owner 13:45 #1): cards hug their content
    // (the fixed 236.h extent left a large empty bottom on the iPad).
    return TtCardGrid(
      key: const ValueKey<String>('requestTypesGrid'),
      children: <Widget>[
        for (final RequestType t in rows) _RequestTypeCard(type: t, onTap: () => open(t)),
      ],
    );
  }
}

class _RequestTypeCard extends StatelessWidget {
  const _RequestTypeCard({required this.type, required this.onTap});

  final RequestType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final TextStyle label = StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText);
    final TextStyle value = StyleText.fontSize12Weight500.copyWith(color: AppColors.text);
    Widget line(TtGlyph icon, String l, Widget v) => Padding(
          padding: EdgeInsetsDirectional.only(top: 6.h),
          child: Row(
            children: <Widget>[
              TtIcon(icon, size: 14.r, color: AppColors.secondaryText),
              SizedBox(width: 6.w),
              Flexible(child: Text('$l: ', maxLines: 1, overflow: TextOverflow.ellipsis, style: label)),
              Flexible(child: v),
            ],
          ),
        );
    Text text(String v) => Text(v, maxLines: 1, overflow: TextOverflow.ellipsis, style: value);
    return GestureDetector(
      key: ValueKey<String>('requestTypeCard_${type.id}'),
      onTap: () {
        HapticController.low();
        onTap();
      },
      // Figma 661:35833: 10 padding, Last Update on top, the type, four
      // lines, then Status + Created Date — no empty space below.
      child: Container(
        padding: EdgeInsetsDirectional.all(10.r),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: CardStyles.radius()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Text(s.timeTrackerLastUpdateValue(TimeTrackerFormat.date(context, type.audit.updatedAt)),
                  style: StyleText.fontSize10Weight400.copyWith(color: AppColors.secondaryText)),
            ),
            SizedBox(height: 2.h),
            Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsetsDirectional.all(5.r),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadiusDirectional.circular(8.r),
                  ),
                  child: TtIcon(const TtGlyph.svg(TtAssets.edit), size: 16.r, color: AppColors.text),
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text('${s.timeTrackerRequestType}: ',
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: label),
                ),
                // Owner (9/10/2026): the type name may take two lines.
                Expanded(
                  child: Text(RequestTypeText.name(context, type),
                      key: ValueKey<String>('requestTypeName_${type.id}'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: value),
                ),
              ],
            ),
            line(const TtGlyph.svg(TtAssets.group), s.timeTrackerHrApproval,
                text(RequestTypeText.required(context, type.isHrApprovalRequired))),
            line(const TtGlyph.icon(Icons.work_outline), s.timeTrackerManagerApproval,
                text(RequestTypeText.required(context, type.isManagerApprovalRequired))),
            line(const TtGlyph.svg(TtAssets.description), s.timeTrackerDescription,
                text(RequestTypeText.optional(context, type.isDescriptionRequired))),
            line(const TtGlyph.svg(TtAssets.attachment), s.timeTrackerAttachments,
                text(RequestTypeText.optional(context, type.isAttachmentRequired))),
            // Fills only when a neighbour in the row is taller (TtCardGrid).
            const Spacer(),
            Row(
              children: <Widget>[
                Expanded(child: line(const TtGlyph.svg(TtAssets.status), s.timeTrackerStatus,
                    RequestTypeStatusText(status: type.status, maxLines: 1, small: true))),
                // 9/10/2026: the date shares the row (it squeezed the status
                // into a tall column on a phone).
                Flexible(
                  child: Text(s.timeTrackerCreatedDateValue(TimeTrackerFormat.date(context, type.audit.createdAt)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: StyleText.fontSize10Weight400.copyWith(color: AppColors.secondaryText)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
