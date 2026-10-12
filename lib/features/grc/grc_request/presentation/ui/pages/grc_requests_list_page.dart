/// Module: GRC Request Management
/// Description: Module-scoped list of GRC approval requests — All/Approved/
///              Pending/Rejected count tabs, search, and a card grid that
///              navigates to GrcRequestDetailsPage.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-25
/// Dependencies: flutter_bloc, get_it, GrcRequestCubit, GRCModuleEntity
library;

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_permissions.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/custom/47-custom_sort_button.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_l10n.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_person_profile_card.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/domain/enums/approval_status.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_approval_status_style.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/8-custom_filter_app.dart';
import 'package:knowticed_plus/core/custom/11-custom_confirm_diaolog.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/entities/grc_request_entity.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/entities/grc_request_type.dart';
import 'package:knowticed_plus/features/grc/grc_request/presentation/controller/grc_request_cubit.dart';
import 'package:knowticed_plus/features/grc/grc_request/presentation/ui/pages/grc_request_details_page.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_request_status_pill.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class GrcRequestsListPage extends StatelessWidget {
  final GRCModuleEntity module;

  /// When set, the list only shows requests whose `requestedBy` matches
  /// this email (the "My Requests" view) instead of every request in the
  /// module, and eligible pending requests get a Cancel action.
  final String? onlyRequestedBy;

  /// When set, the list only shows requests of this type — e.g. opening
  /// "Requests" from the Control Owners tab should only show Reassign
  /// Control Owner requests, not Champion ones sharing the same module.
  final GrcRequestType? typeFilter;

  /// ADDED 28/9/2026 (GRC bug report p3): render just the list — no page
  /// frame / breadcrumb — so it can sit inside Approvals as the "Reassign"
  /// tab.
  final bool embedded;

  const GrcRequestsListPage({
    super.key,
    required this.module,
    this.onlyRequestedBy,
    this.typeFilter,
    this.embedded = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GrcRequestCubit>(
      create: (_) => GetIt.instance<GrcRequestCubit>()
        ..getRequestsForModule(module.moduleId),
      child: _GrcRequestsListBody(
        module: module,
        onlyRequestedBy: onlyRequestedBy,
        typeFilter: typeFilter,
        embedded: embedded,
      ),
    );
  }
}

class _GrcRequestsListBody extends StatefulWidget {
  final GRCModuleEntity module;
  final String? onlyRequestedBy;
  final GrcRequestType? typeFilter;
  final bool embedded;

  const _GrcRequestsListBody({
    required this.module,
    this.onlyRequestedBy,
    this.typeFilter,
    this.embedded = false,
  });

  @override
  State<_GrcRequestsListBody> createState() => _GrcRequestsListBodyState();
}

class _GrcRequestsListBodyState extends State<_GrcRequestsListBody> {
  ApprovalStatus _selectedFilter = ApprovalStatus.all;
  String _searchQuery = '';

  /// Filter button (sliders): one request type, or null for every type.
  GrcRequestType? _typeFilter;

  /// Sort button (768 / 1024 only): newest first unless changed.
  _RequestSort? _sort;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<GrcRequestEntity> _scopeRequests(List<GrcRequestEntity> requests) {
    var scoped = requests;
    if (widget.typeFilter != null) {
      scoped = scoped.where((r) => r.type == widget.typeFilter).toList();
    }
    if (widget.onlyRequestedBy != null) {
      scoped =
          scoped.where((r) => r.requestedBy == widget.onlyRequestedBy).toList();
    } else {
      // Business rule (hide canceled requests from the module-wide view)
      // lives on GrcRequestCubit's GrcRequestListScopeX extension.
      scoped = scoped.visibleForModuleScope;
    }
    return scoped;
  }

  bool _canCancel(GrcRequestEntity request) {
    // Cancel_Service (GRC > Dashboards) gates cancelling a request.
    return GrcPermission.canCancelService &&
        widget.onlyRequestedBy != null &&
        request.status == ApprovalStatus.pending &&
        request.startDate != null &&
        request.startDate!.isAfter(DateTime.now());
  }

  void _onCancel(BuildContext context, GrcRequestEntity request) {
    showConfirmDialog(
      context: context,
      title: S.of(context).CancelRequest,
      subtitle: S.of(context).AreYousureYouWanttoCancelThisRequest,
      cancelLabel: S.of(context).no,
      confirmLabel: S.of(context).yes,
      onConfirm: () {
        context.read<GrcRequestCubit>().cancelRequest(
              moduleId: widget.module.moduleId,
              requestId: request.id,
            );
      },
    );
  }

  List<GrcRequestEntity> _applyFilters(List<GrcRequestEntity> requests) {
    var filtered = requests;
    if (_selectedFilter != ApprovalStatus.all) {
      filtered = filtered.where((r) => r.status == _selectedFilter).toList();
    }
    if (_typeFilter != null) {
      filtered = filtered.where((r) => r.type == _typeFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered
          .where((r) =>
              (r.newChampionEmail ?? '').toLowerCase().contains(q) ||
              (r.currentChampionEmail ?? '').toLowerCase().contains(q) ||
              (r.newOwnerEmail ?? '').toLowerCase().contains(q) ||
              (r.currentOwnerEmail ?? '').toLowerCase().contains(q) ||
              r.requestedBy.toLowerCase().contains(q))
          .toList();
    }
    filtered = [...filtered]..sort((a, b) => _sort == _RequestSort.oldest
        ? a.requestDate.compareTo(b.requestDate)
        : b.requestDate.compareTo(a.requestDate));
    return filtered;
  }

  /// Outlined status pill -- shared with the Request Details page so both
  /// screens show the same status UI.
  Widget _statusPill(ApprovalStatus status) =>
      GrcRequestStatusPill(status: status);

  /// Per-status counts (All/Approved/Pending/Rejected, plus Canceled in the
  /// "My Requests" view) shown on the filter chips, computed from the
  /// scoped (but not search/status-filtered) request list.
  Map<ApprovalStatus, int> _buildStatusCounts(List<GrcRequestEntity> requests) {
    return {
      for (final s in [
        ApprovalStatus.all,
        ApprovalStatus.approved,
        ApprovalStatus.pending,
        ApprovalStatus.rejected,
        if (widget.onlyRequestedBy != null) ApprovalStatus.canceled,
      ])
        s: s == ApprovalStatus.all
            ? requests.length
            : requests.where((r) => r.status == s).length,
    };
  }

  void _openDetails(BuildContext context, GrcRequestEntity request) {
    if (!request.type.isReassignment) return;
    final requestCubit = context.read<GrcRequestCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider<GrcRequestCubit>.value(
          value: requestCubit,
          child: GrcRequestDetailsPage(
            module: widget.module,
            request: request,
            isMyRequest: widget.onlyRequestedBy != null,
          ),
        ),
      ),
    );
    // No refetch needed: the details page shares this GrcRequestCubit, and
    // the BlocConsumer below refetches on its action-success states.
  }

  /// The person the request is about -- the new champion / owner.
  String _subjectEmail(GrcRequestEntity r) =>
      r.type == GrcRequestType.reassignOwner
          ? (r.newOwnerEmail ?? r.currentOwnerEmail ?? '')
          : (r.newChampionEmail ?? r.currentChampionEmail ?? '');

  String get _managerEmail => widget.module.moduleOwners.isEmpty
      ? ''
      : widget.module.moduleOwners.first;

  Widget _labelValue(String label, String value, {int maxLines = 1}) =>
      Text.rich(
        TextSpan(
          text: '$label: ',
          style: CardStyles.label(10),
          children: [
            TextSpan(
              text: FormatHelper.capitalize(value),
              style: CardStyles.value(10),
            ),
          ],
        ),
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );

  Widget _labelPerson(String label, String email) => Row(
        children: [
          Text('$label:', style: CardStyles.label(10)),
          SizedBox(width: 5.w),
          Flexible(
            child: GrcAvatarName(
              email: email,
              style: CardStyles.value(10),
            ),
          ),
        ],
      );

  /// function name: [_buildRequestCard]
  ///
  /// purpose: one request card, per MAGDY width --
  ///   * 1024: type / manager / department / note, then date + status on
  ///     the last line.
  ///   * 768:  same, with the date in the top trailing corner.
  ///   * 375:  type + date, the champion / owner the request is about,
  ///     their department and the department manager, status at the foot.
  Widget _buildRequestCard(
    BuildContext context,
    GrcRequestEntity request,
    DateFormat dateFormat,
  ) {
    final S s = S.of(context);
    final ScreenSize size = screenSizeOf(context);
    final String date = LocalizedNumber.digits(
        context, dateFormat.format(request.requestDate));
    final String type = grcTr(context, request.type.value);
    final String managerDepartment =
        findEmployeeByEmail(_managerEmail).localizedDepartment(context);

    final Widget dateText = _labelValue(s.RequestDate, date);

    final List<Widget> body = switch (size) {
      ScreenSize.mobile => [
          Row(
            children: [
              Expanded(child: _labelValue(s.requestType, type)),
              SizedBox(width: 5.w),
              dateText,
            ],
          ),
          SizedBox(height: 6.h),
          _labelPerson(
            request.type == GrcRequestType.reassignOwner
                ? s.controlOwner
                : s.controlChampion,
            _subjectEmail(request),
          ),
          SizedBox(height: 6.h),
          _labelValue(
            s.department,
            findEmployeeByEmail(_subjectEmail(request))
                .localizedDepartment(context),
          ),
          SizedBox(height: 4.h),
          _labelValue(
              s.departmentManager, employeeDisplayName(context, _managerEmail)),
          SizedBox(height: 8.h),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: _statusPill(request.status),
          ),
        ],
      _ => [
          Row(
            children: [
              Expanded(child: _labelValue(s.requestType, type)),
              if (size == ScreenSize.tablet) ...[
                SizedBox(width: 5.w),
                dateText,
              ],
            ],
          ),
          SizedBox(height: 8.h),
          _labelPerson(s.departmentManager, _managerEmail),
          SizedBox(height: 8.h),
          _labelValue(s.department, managerDepartment),
          SizedBox(height: 4.h),
          _labelValue(s.request_note, request.note, maxLines: 2),
          SizedBox(height: 8.h),
          Row(
            children: [
              if (size == ScreenSize.desktop) dateText,
              const Spacer(),
              _statusPill(request.status),
            ],
          ),
        ],
    };

    // GestureDetector, not InkWell: no hover / splash overlay on the card.
    return GestureDetector(
      onTap: () => _openDetails(context, request),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: CardStyles.radius(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: body,
        ),
      ),
    );
  }

  /// 1 / 2 / 3 cards per row at 375 / 768 / 1024, equal height per row.
  Widget _buildGrid(
      BuildContext context, List<GrcRequestEntity> requests, DateFormat df) {
    final int columns =
        responsiveValue(context, mobile: 1, tablet: 2, desktop: 3);
    final int rows = (requests.length / columns).ceil();
    return ListView.separated(
      itemCount: rows,
      separatorBuilder: (_, __) => SizedBox(height: 15.h),
      itemBuilder: (_, row) => IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List<Widget>.generate(columns * 2 - 1, (slot) {
            if (slot.isOdd) return SizedBox(width: 15.w);
            final int index = row * columns + slot ~/ 2;
            if (index >= requests.length) {
              return const Expanded(child: SizedBox());
            }
            return Expanded(
              child: _buildRequestCard(context, requests[index], df),
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM yyyy', context.isArabic ? 'ar' : 'en');
    final bool isMobile = screenSizeOf(context) == ScreenSize.mobile;
    final Widget list = BlocConsumer<GrcRequestCubit, GrcRequestState>(
          listener: (context, state) {
            // cancel / approve / reject emit GrcRequestActionSuccess, not
            // GrcRequestListLoaded -- refetch so the grid shows the new
            // status instead of going blank.
            if (state is GrcRequestActionSuccess) {
              context
                  .read<GrcRequestCubit>()
                  .getRequestsForModule(widget.module.moduleId);
            }
          },
          builder: (context, state) {
            final requests = _scopeRequests(state is GrcRequestListLoaded
                ? state.requests
                : <GrcRequestEntity>[]);
            final counts = _buildStatusCounts(requests);
            final filtered = _applyFilters(requests);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusChipFilter(
                  selectedKey: _selectedFilter.name,
                  onSelected: (key) => setState(() =>
                      _selectedFilter = ApprovalStatus.values.byName(key)),
                  items: [
                    StatusChipItem(
                      key: ApprovalStatus.all.name,
                      label: S.of(context).all,
                      count: counts[ApprovalStatus.all]!,
                    ),
                    StatusChipItem(
                      key: ApprovalStatus.approved.name,
                      label: S.of(context).status_approved,
                      count: counts[ApprovalStatus.approved]!,
                      labelColor: ApprovalStatus.approved.color,
                    ),
                    StatusChipItem(
                      key: ApprovalStatus.pending.name,
                      label: S.of(context).status_pending,
                      count: counts[ApprovalStatus.pending]!,
                      labelColor: ApprovalStatus.pending.color,
                    ),
                    StatusChipItem(
                      key: ApprovalStatus.rejected.name,
                      label: S.of(context).status_rejected,
                      count: counts[ApprovalStatus.rejected]!,
                      labelColor: ApprovalStatus.rejected.color,
                    ),
                    if (widget.onlyRequestedBy != null)
                      StatusChipItem(
                        key: ApprovalStatus.canceled.name,
                        label: S.of(context).status_cancel,
                        count: counts[ApprovalStatus.canceled]!,
                        labelColor: ApprovalStatus.canceled.color,
                      ),
                  ],
                ),
                SizedBox(height: 15.h),
                Row(
                  spacing: 10.w,
                  children: [
                    AppSearchTextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      hintText: S.of(context).search,
                      controller: _searchController,
                    ),
                    CustomSortButton<GrcRequestType>(
                      value: _typeFilter,
                      items: widget.typeFilter != null
                          ? [widget.typeFilter!]
                          : GrcRequestType.values,
                      labelBuilder: (t) => grcTr(context, t.value),
                      onChanged: (t) => setState(() => _typeFilter = t),
                      title: S.of(context).filter,
                      showTitle: !isMobile,
                      svgPath: AppAssets.filter,
                      menuWidth: 220.w,
                    ),
                    // The 375 frame has no Sort button.
                    if (!isMobile)
                      CustomSortButton<_RequestSort>(
                        value: _sort,
                        items: _RequestSort.values,
                        labelBuilder: (o) => o == _RequestSort.newest
                            ? S.of(context).newestFirst
                            : S.of(context).oldestFirst,
                        onChanged: (o) => setState(() => _sort = o),
                        menuWidth: 180.w,
                      ),
                  ],
                ),
                SizedBox(height: 15.h),
                Expanded(
                  child: state is GrcRequestLoading
                      ? Center(
                          child: const CircleProgressMaster(),
                        )
                      : filtered.isEmpty
                          ? const Center(child: CustomEmptyState())
                          : _buildGrid(context, filtered, dateFormat),
                ),
              ],
            );
          },
        );

    // Embedded as the Approvals "Reassign" tab: the host page owns the frame.
    if (widget.embedded) return list;

    // The frame owns the Scaffold, SafeArea, breadcrumb and side padding.
    return SideFrameMasterServices(
      titleText: S.of(context).grc,
      onFirstTap: () => popFrameRoutes(context, 2),
      secondTitle: widget.module.localizedName(isArabic: context.isArabic),
      onSecondTap: () => popFrameRoutes(context, 1),
      thirdTitle: widget.onlyRequestedBy != null
          ? S.of(context).myRequests
          : S.of(context).requests,
      // The request list is an Expanded, which needs a bounded height.
      child: SideFrameBoundedBody(child: list),
    );
  }
}

enum _RequestSort { newest, oldest }
