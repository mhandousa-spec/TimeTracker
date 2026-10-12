/// Module: settings/se6_requests
///
///*************************** FILE INFO ****************************///
/// File Name: request_page.dart
/// Purpose: The employee's own list of change requests.
/// Author: Amr Mesbah
/// Created at: 13/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SE6-N01/N02/N04/N06/N12: the Firestore query, the document parsing
///          and the try/catch moved into RequestsCubit/ChangeRequestMapper;
///          Get.snackbar replaced with a themed SnackBar; raw colours route
///          through AppColors; `Get.locale` replaced with
///          `Localizations.localeOf(context)`.

import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/features/settings/se6_requests/presentation/ui/pages/request_section_label.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/47-custom_sort_button.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
// navigate helpers (inlined from removed inventory_module)
import 'package:knowticed_plus/core/theme/app_colors.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/Category/presentation/ui/service_department_manager/tablet/s2_details_service/details_service/widget/info_text.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/core/custom/69-cross_axis_count_helper.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/entities/change_request.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/entities/field_change.dart';
import 'package:knowticed_plus/features/settings/se6_requests/presentation/controller/requests_cubit.dart';
import './details_request.dart';

import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

/// Returns the route's Future so callers can await the pop and refresh. The
/// details screen can change a request's status, and this list groups and
/// counts by status — without re-fetching on return it keeps showing whatever
/// initState loaded.
Future<T?> navigateTo<T>(BuildContext context, Widget widget) =>
    Navigator.push<T>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => widget,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );

class MyRequestPage extends StatefulWidget {
  const MyRequestPage({super.key});

  @override
  State<MyRequestPage> createState() => _MyRequestPageState();
}

/// Sort order for the requests list, applied to `dateRequested`.
///
/// Null (nothing selected) leaves the list in the order the cubit returned it,
/// which is what CustomSortButton's toggle produces when the active option is
/// tapped a second time.
enum RequestDateSort { ascending, descending }

class _MyRequestPageState extends State<MyRequestPage> {
  /// Canonical status key (see kAll / kApproved / … below), not a display label.
  String selectStatus = kAll;

  // Counts are derived from allRequests, never cached in fields. Cached copies
  // only updated inside _fetchRequests, so any code path that
  // changed the list without re-fetching (or a hot reload, which keeps the
  // State object and its stale field values) left the chips disagreeing with
  // the cards they sit above.
  int get totalRequests => allRequests.length;
  int get pendingCount => _countOf(kPending);
  int get approvedCount => _countOf(kApproved);
  int get rejectedCount => _countOf(kRejected);
  int get cancelledCount => _countOf(kCancelled);

  List<Map<String, dynamic>> allRequests = [];
  List<Map<String, dynamic>> filteredRequests = [];

  /// Active sort, or null for "unsorted" (see [RequestDateSort]).
  RequestDateSort? _sortOrder;

  /// Owned by this page; the requests list is its whole reason to exist.
  final RequestsCubit _requestsCubit = RequestsCubit();

  TextEditingController searchController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    _requestsCubit.close();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterRequests();
  }

  /// Icon for a request card, chosen from the request's `section`.
  /// Health Insurance requests get the health icon; everything else falls back
  /// to the generic employee-record icon.
  String _sectionIconPath(String? section) {
    switch (section?.trim()) {
      case 'Health Insurance':
      case 'Emergency Contact':
        return 'assets/icons_assets/settings_assets/health_insurance.svg';
      default:
        return 'assets/icons_assets/settings_assets/employee_id_card.svg';
    }
  }

  /// FIXED 13/8/2026: this local copy was missing the 'Personal Information'
  /// case, so that chip rendered in English beside a translated
  /// 'التأمين الصحي'. It also hardcoded the Arabic instead of using the
  /// l10n keys that already existed. Both copies now defer to
  /// [RequestSectionLabel].
  String _translateTitle(String englishTitle) =>
      RequestSectionLabel.of(context, englishTitle);

  /// Function Name: [_fetchRequests]
  ///
  /// Purpose: Load the signed-in employee's requests through the cubit.
  ///
  /// The Firestore query, the document parsing and the `try/catch` moved into
  /// `RequestsRepository` / `ChangeRequestMapper` (CR-SKEL-SE6-N01, N02). The
  /// rows are still rendered as maps: this page reads ~15 keys off them across
  /// two layouts, and converting those call sites is the separate decomposition
  /// work N05 asks for.
  Future<void> _fetchRequests() async {
    setState(() => isLoading = true);

    final String employeeId =
        Get.find<MainCoreEmployeeController>().employeeEntity?.id ?? '';

    await _requestsCubit.loadForEmployee(employeeId);
    if (!mounted) return;

    final RequestsState state = _requestsCubit.state;

    if (state.status == RequestsStatus.failure) {
      _requestsCubit.clearMessages();
      setState(() => isLoading = false);
      _showError();
      return;
    }

    setState(() {
      allRequests = state.requests.map(_asRow).toList();
      _filterRequests();
      isLoading = false;
    });
  }

  /// Adapts one entity to the map shape the list rows read.
  Map<String, dynamic> _asRow(ChangeRequest request) {
    final FieldChange? first =
        request.changes.isEmpty ? null : request.changes.first;

    return <String, dynamic>{
      'id': request.id,
      'title': request.section,
      'dateRequested': request.requestDate?.millisecondsSinceEpoch ?? 0,
      'status': request.status.wireValue,
      'requestNote': request.requestNote,
      'employeeId': request.employeeId,
      'employeeEmail': request.employeeEmail,
      'section': request.section,
      'changes': request.changes.map((FieldChange c) => c.toMap()).toList(),
      'numberOfChanges': request.numberOfChanges,
      'whatChanged': first?.fieldName ?? '',
      'oldValue': first?.oldValue ?? '',
      'newValue': first?.newValue ?? '',
    };
  }

  /// Was `Get.snackbar` with raw AppColors.signOut/white and the interpolated
  /// exception text (CR-SKEL-SE6-N04, N06).
  void _showError() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            S.of(context).errorOccurred,
            style: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.textButton),
          ),
          backgroundColor: AppColors.signOut,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  /// Canonical status keys. Firestore holds both spellings of cancelled
  /// depending on which screen wrote the record, so everything funnels through
  /// here before being compared or counted.
  static const String kAll = 'All';
  static const String kApproved = 'approved';
  static const String kPending = 'pending';
  static const String kRejected = 'rejected';
  static const String kCancelled = 'cancelled';

  String _normalizeStatus(dynamic raw) {
    final value = (raw ?? '').toString().toLowerCase().trim();
    return value == 'canceled' ? kCancelled : value;
  }

  int _countOf(String status) =>
      allRequests.where((r) => _normalizeStatus(r['status']) == status).length;

  void _filterRequests() {
    List<Map<String, dynamic>> filtered = List.from(allRequests);

    // Filter by status. selectStatus holds a canonical key, not a display
    // label — comparing against localized labels meant the Pending / Rejected
    // chips silently matched nothing under an Arabic locale.
    if (selectStatus != kAll) {
      filtered = filtered
          .where(
              (request) => _normalizeStatus(request['status']) == selectStatus)
          .toList();
    }

    // Filter by search text (search in title)
    if (searchController.text.isNotEmpty) {
      final searchText = searchController.text.toLowerCase();
      filtered = filtered.where((request) {
        final title = request['title'].toString().toLowerCase();
        final translatedTitle = _translateTitle(request['title']).toLowerCase();
        return title.contains(searchText) ||
            translatedTitle.contains(searchText);
      }).toList();
    }

    // Sort by request date. `dateRequested` is stored as epoch millis by
    // _asRow, so this is an int compare — no date parsing, and requests with a
    // missing date (0) sort to the far end rather than throwing.
    if (_sortOrder != null) {
      filtered.sort((Map<String, dynamic> a, Map<String, dynamic> b) {
        final int dateA = (a['dateRequested'] as int?) ?? 0;
        final int dateB = (b['dateRequested'] as int?) ?? 0;
        return _sortOrder == RequestDateSort.ascending
            ? dateA.compareTo(dateB) // oldest request first
            : dateB.compareTo(dateA); // newest request first
      });
    }

    setState(() {
      filteredRequests = filtered;
    });
  }

  /// Menu label for one sort option.
  ///
  /// CHANGED 8/9/2026 — was "Ascending" / "Descending".
  ///
  /// This sort only ever applies to `dateRequested`, and ascending/descending
  /// says nothing about which end of a DATE it means: a reader has to decide
  /// for themselves whether "ascending" counts up towards today or up towards
  /// the newest request. "Oldest First" / "Newest First" name the outcome, so
  /// there is nothing left to work out before tapping.
  ///
  /// The mapping matches the comparator in [_applyFilters]: ascending compares
  /// `dateA.compareTo(dateB)`, which puts the smallest epoch — the oldest
  /// request — at the top.
  ///
  /// Both keys already existed in `intl_en.arb` and `intl_ar.arb`
  /// ("الأقدم أولاً" / "الأحدث أولاً"), so this needs no regeneration.
  String _sortLabel(BuildContext context, RequestDateSort order) =>
      order == RequestDateSort.ascending
          ? S.of(context).oldestFirst
          : S.of(context).newestFirst;

  String _formatDate(int timestamp) {
    if (timestamp == 0) return '-';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd MMM yyyy').format(date);
  }

  Color _getStatusColor(String status) {
    switch (_normalizeStatus(status)) {
      case kApproved:
        return AppColors.lightGreen;
      case kPending:
        // statusPending (0xFFFF814A), not AppColors.yellow — Pending is the
        // orange in the status palette, and yellow reads too close to the
        // brand primary used elsewhere on this screen.
        return AppColors.statusPending;
      case kRejected:
        // NOT AppColors.signOut: that getter returns currentThemeColors
        // ['primary'] — the brand yellow — so Rejected was rendering in the
        // same family as Pending (bug report p.15, "wrong color").
        return AppColors.red;
      case kCancelled:
        return AppColors.darkRed;
      default:
        return AppColors.secondaryText;
    }
  }

  String _getStatusLabel(String status) {
    switch (_normalizeStatus(status)) {
      case kApproved:
        return S.of(context).Approved;
      case kPending:
        return S.of(context).pending;
      case kRejected:
        return S.of(context).rejected;
      case kCancelled:
        return S.of(context).canceled;
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    var isMobile = ContextExtension(context).isPhone;
    var lightMode = Theme.of(context).brightness == Brightness.light;

    return !isMobile
        ? SizedBox(
            // No fixed height — this page is rendered inside an Expanded in
            // settings_layout.dart, so it inherits the exact height available.
            // The old 550.h resolved ~6px taller than that space and overflowed.
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // filter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      filterSection(),
                    ],
                  ),
                  // //space
                  // SizedBox(height: 20.h),
                  // // search and sort
                  // Row(
                  //   children: [
                  //     AppSearchTextField(
                  //       controller: searchController,
                  //       onChanged: (val) {
                  //         // Search is handled by listener
                  //       },
                  //     ),
                  //   ],
                  // ),

                  SizedBox(height: 20.h),

                  // While the first load is still in flight neither the grid nor
                  // the "no requests" animation is the truth yet — an empty list at
                  // that point only means the fetch has not returned. Show the
                  // spinner until it does, then decide between empty and grid.
                  isLoading
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 150.h),
                            const CircleProgressMaster(),
                          ],
                        )
                      : filteredRequests.isEmpty
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 150.h),
                                Lottie.asset(
                                    "assets/lottie_assets/notification_lottie_assets/empty.json",
                                    width: 250.w,
                                    height: 250.h,
                                    repeat: true),
                              ],
                            )
                          : SizedBox(
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: isMobile
                                      ? 1
                                      : !ContextExtension(context)
                                              .isTabletLandscape
                                          ? 2
                                          : 2,
                                  mainAxisSpacing: 10.sp,
                                  crossAxisSpacing: 10.sp,
                                  // 160.sp overflowed by ~4px once a request title wrapped to
                                  // its second line.
                                  mainAxisExtent: 145.sp,
                                ),
                                itemCount: filteredRequests.length,
                                itemBuilder: (context, index) {
                                  final request = filteredRequests[index];
                                  final status = request['status'] ?? 'pending';
                                  final statusColor = _getStatusColor(status);

                                  return GestureDetector(
                                      onTap: () async {
                                        await navigateTo(
                                          context,
                                          DetailsRequestSettings(
                                            requestId: request[
                                                'id'], // ✅ Add requestId
                                            requestData: {
                                              'employeeId':
                                                  request['employeeId'],
                                              'employeeEmail': request[
                                                  'employeeEmail'], // ✅ Add
                                              'status': request['status'],
                                              'requestDate': request[
                                                  'dateRequested'], // ✅ Fix field name
                                              'requestNote':
                                                  request['requestNote'],
                                              'section':
                                                  request['section'], // ✅ Add
                                              'changes': request[
                                                  'changes'], // full change set
                                              'whatChanged': request[
                                                  'whatChanged'], // ✅ Add
                                              'oldValue':
                                                  request['oldValue'], // ✅ Add
                                              'newValue':
                                                  request['newValue'], // ✅ Add
                                            },
                                          ),
                                        );

                                        if (!mounted) return;
                                        await _fetchRequests();
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8.r),
                                            color: lightMode
                                                ? AppColors.white
                                                : AppColors.chatBackground),
                                        child: Padding(
                                          padding: EdgeInsets.all(15.sp),
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.vertical,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                        width: 50.sp,
                                                        height: 50.sp,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4.r),
                                                            color: lightMode
                                                                ? AppColors
                                                                    .background
                                                                : AppColors
                                                                    .background),
                                                        child: Center(
                                                          child: CustomSvgImage(
                                                            assetPath:
                                                                _sectionIconPath(
                                                                    request[
                                                                        'section']),
                                                            width: 28.sp,
                                                            height: 28.sp,
                                                            fit: BoxFit.fill,
                                                            color: lightMode
                                                                ? AppColors
                                                                    .blackButton
                                                                : AppColors
                                                                    .white,
                                                          ),
                                                        )),
                                                    SizedBox(width: 5.w),
                                                    Expanded(
                                                      child: Text(
                                                        // ✅ FIXED: Translate title based on locale
                                                        _translateTitle(
                                                            request['title'] ??
                                                                'Request'),
                                                        style: StyleText
                                                            .fontSize14Weight500
                                                            .copyWith(
                                                                color: lightMode
                                                                    ? AppColors
                                                                        .blackButton
                                                                    : AppColors
                                                                        .white),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 2,
                                                      ),
                                                    )
                                                  ],
                                                ),

                                                // space
                                                SizedBox(height: 12.h),
                                                // Date Requested
                                                Row(
                                                  children: [
                                                    // Bug report (Settings mobile p.7):
                                                    // the date and status icons used
                                                    // different boxes (14.w×14.h vs
                                                    // 12.w×12.h, stretched), so they
                                                    // did not line up. One square box.
                                                    CustomSvgImage(
                                                      assetPath:
                                                          "assets/icons_assets/roles_assets/calendar.svg",
                                                      width: 14.sp,
                                                      height: 14.sp,
                                                      fit: BoxFit.contain,
                                                    ),
                                                    SizedBox(width: 4.sp),
                                                    Text(
                                                      "${S.of(context).dateRequested}: ",
                                                      style: StyleText
                                                          .fontSize12Weight400
                                                          .copyWith(
                                                              color: lightMode
                                                                  ? AppColors
                                                                      .secondaryText
                                                                  : AppColors
                                                                      .grey),
                                                    ),
                                                    Text(
                                                      _formatDate(request[
                                                          'dateRequested']),
                                                      style: StyleText
                                                          .fontSize12Weight400
                                                          .copyWith(
                                                              color: lightMode
                                                                  ? AppColors
                                                                      .blackButton
                                                                  : AppColors
                                                                      .white),
                                                    ),
                                                  ],
                                                ),
                                                // space
                                                SizedBox(height: 12.h),
                                                // Status
                                                Row(
                                                  children: [
                                                    CustomSvgImage(
                                                      assetPath:
                                                          "assets/icons_assets/main_icons_assets/status_pulse_line.svg",
                                                      width: 14.sp,
                                                      height: 14.sp,
                                                      fit: BoxFit.contain,
                                                    ),
                                                    SizedBox(width: 4.sp),
                                                    Text(
                                                      "${S.of(context).status}: ",
                                                      style: StyleText
                                                          .fontSize12Weight400
                                                          .copyWith(
                                                              color: lightMode
                                                                  ? AppColors
                                                                      .secondaryText
                                                                  : AppColors
                                                                      .grey),
                                                    ),
                                                    Text(
                                                      _getStatusLabel(status),
                                                      style: StyleText
                                                          .fontSize12Weight400
                                                          .copyWith(
                                                              color:
                                                                  statusColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ));
                                },
                              ),
                            ),
                ],
              ),
            ),
          )
        : SideFrameMasterServices(
            titleText: S.of(context).settings,
            secondTitle: S.of(context).requests,
            onFirstTap: () {
              Navigator.pop(context);
            },
            onSecondTap: () {
              Navigator.pop(context);
            },
            child: Column(
              children: [
                // filter
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    filterSection(),
                  ],
                ),
                //space
                SizedBox(height: 20.h),
                // search and sort
                Row(
                  children: [
                    AppSearchTextField(
                      controller: searchController,
                      onChanged: (val) {
                        // Search is handled by listener
                      },
                    ),
                    SizedBox(width: 15.w),
                    // WAS a decorative Container: an icon, the word "Sort",
                    // and no gesture detector or menu anywhere — the control
                    // looked live but sorted nothing. CustomSortButton is the
                    // app's real sort control; it owns the dropdown, paints
                    // itself primary while a sort is active, and toggles the
                    // active option off when it is tapped again.
                    CustomSortButton<RequestDateSort>(
                      value: _sortOrder,
                      items: RequestDateSort.values,
                      labelBuilder: (RequestDateSort order) =>
                          _sortLabel(context, order),
                      title: S.of(context).sort,
                      // Icon-only in the 38.w square on phone, icon + label on
                      // wider screens — the same split the old Container made.
                      showTitle: !isMobile,
                      // Bug report (Settings mobile p.7 "same height"):
                      // 38.h / 38.w against the search field's 38.sp — two
                      // different scales. Same unit as the search box now.
                      width: isMobile ? 38.sp : 100.w,
                      height: 38.sp,
                      onChanged: (RequestDateSort? order) {
                        _sortOrder = order;
                        // _filterRequests calls setState itself.
                        _filterRequests();
                      },
                    )
                  ],
                ),

                SizedBox(height: 20.h),

                // Same as the wide layout: spinner first, empty state only once
                // the fetch has actually finished.
                isLoading
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 150.h),
                          const CircleProgressMaster(),
                        ],
                      )
                    : filteredRequests.isEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 150.h),
                              Lottie.asset(
                                  "assets/lottie_assets/notification_lottie_assets/empty.json",
                                  width: 250.w,
                                  height: 250.h,
                                  repeat: true),
                            ],
                          )
                        : SizedBox(
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isMobile
                                    ? 1
                                    : !ContextExtension(context)
                                            .isTabletLandscape
                                        ? 2
                                        : 2,
                                mainAxisSpacing: 15.sp,
                                crossAxisSpacing: 15.sp,
                                mainAxisExtent: 139.sp,
                              ),
                              itemCount: filteredRequests.length,
                              itemBuilder: (context, index) {
                                final request = filteredRequests[index];
                                final status = request['status'] ?? 'pending';
                                final statusColor = _getStatusColor(status);

                                return GestureDetector(
                                    onTap: () async {
// ✅ Check status here

                                      await navigateTo(
                                        context,
                                        DetailsRequestSettings(
                                          requestId: request['id'],
                                          requestData: {
                                            'employeeId': request['employeeId'],
                                            'employeeEmail':
                                                request['employeeEmail'],
                                            'status': request[
                                                'status'], // ✅ Make sure this is passed
                                            'requestDate':
                                                request['dateRequested'],
                                            'requestNote':
                                                request['requestNote'],
                                            'section': request['section'],
                                            'changes': request[
                                                'changes'], // full change set
                                            'whatChanged':
                                                request['whatChanged'],
                                            'oldValue': request['oldValue'],
                                            'newValue': request['newValue'],
                                          },
                                        ),
                                      );

                                      if (!mounted) return;
                                      await _fetchRequests();
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8.r),
                                          color: AppColors.card),
                                      child: Padding(
                                        padding: EdgeInsets.all(15.sp),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                    width: 50.w,
                                                    height: 50.h,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4.r),
                                                      color:
                                                          AppColors.background,
                                                    ),
                                                    child: Center(
                                                      child: CustomSvgImage(
                                                          assetPath:
                                                              _sectionIconPath(
                                                                  request[
                                                                      'section']),
                                                          width: 28.w,
                                                          height: 28.h,
                                                          fit: BoxFit.scaleDown,
                                                          color:
                                                              AppColors.text),
                                                    )),
                                                SizedBox(width: 5.w),
                                                Expanded(
                                                  child: Text(
                                                    // ✅ FIXED: Translate title based on locale
                                                    _translateTitle(
                                                        request['title'] ??
                                                            'Request'),
                                                    style: StyleText
                                                        .fontSize14Weight500
                                                        .copyWith(
                                                            color:
                                                                AppColors.text),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                  ),
                                                )
                                              ],
                                            ),

                                            // space
                                            SizedBox(height: 12.h),
                                            // Date Requested
                                            Row(
                                              children: [
                                                CustomSvgImage(
                                                  assetPath:
                                                      "assets/icons_assets/roles_assets/calendar.svg",
                                                  width: 14.w,
                                                  height: 14.h,
                                                  fit: BoxFit.scaleDown,
                                                ),
                                                SizedBox(width: 4.w),
                                                Text(
                                                  "${S.of(context).dateRequested}: ",
                                                  style: StyleText
                                                      .fontSize12Weight400
                                                      .copyWith(
                                                          color: AppColors
                                                              .secondaryText),
                                                ),
                                                Text(
                                                  _formatDate(
                                                      request['dateRequested']),
                                                  style: StyleText
                                                      .fontSize12Weight400
                                                      .copyWith(
                                                          color:
                                                              AppColors.text),
                                                ),
                                              ],
                                            ),
                                            // space
                                            SizedBox(height: 12.h),
                                            // Status
                                            Row(
                                              children: [
                                                CustomSvgImage(
                                                  assetPath:
                                                      "assets/icons_assets/main_icons_assets/status_pulse_line.svg",
                                                  width: 12.w,
                                                  height: 12.h,
                                                  fit: BoxFit.fill,
                                                ),
                                                SizedBox(width: 4.w),
                                                Text(
                                                  "${S.of(context).status}: ",
                                                  style: StyleText
                                                      .fontSize12Weight400
                                                      .copyWith(
                                                          color: AppColors
                                                              .secondaryText),
                                                ),
                                                Text(
                                                  _getStatusLabel(status),
                                                  style: StyleText
                                                      .fontSize12Weight400
                                                      .copyWith(
                                                          color: statusColor,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ));
                              },
                            ),
                          ),
              ],
            ),
          );
  }

  Widget filterSection() {
    final s = S.of(context);

    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _statusChip("$totalRequests", s.all,
                isSelected: selectStatus == kAll, onTap: () {
              setState(() {
                selectStatus = kAll;
                _filterRequests();
              });
            },
                labelColor: Theme.of(context).brightness == Brightness.light
                    ? AppColors.secondaryText
                    : AppColors.grey),
            _statusChip("$approvedCount", s.Approved,
                isSelected: selectStatus == kApproved, onTap: () {
              setState(() {
                selectStatus = kApproved;
                _filterRequests();
              });
            }, labelColor: AppColors.lightGreen),
            _statusChip("$pendingCount", s.pending,
                isSelected: selectStatus == kPending, onTap: () {
              setState(() {
                selectStatus = kPending;
                _filterRequests();
              });
            }, labelColor: AppColors.statusPending),
            _statusChip("$rejectedCount", s.rejected,
                isSelected: selectStatus == kRejected, onTap: () {
              setState(() {
                selectStatus = kRejected;
                _filterRequests();
              });
            }, labelColor: AppColors.red),
            _statusChip("$cancelledCount", s.canceled,
                isSelected: selectStatus == kCancelled, onTap: () {
              setState(() {
                selectStatus = kCancelled;
                _filterRequests();
              });
            }, labelColor: AppColors.darkRed),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String count, String label,
      {required bool isSelected,
      required Color labelColor,
      required VoidCallback onTap}) {
    var light = Theme.of(context).brightness == Brightness.light;
    var isMobile = ContextExtension(context).isPhone;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: isMobile ? 35.sp : 45.sp,
            height: isMobile ? 35.sp : 45.sp,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.card,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Center(
              child: Text(
                count,
                style: isMobile
                    ? StyleText.fontSize14Weight400.copyWith(
                        color: light
                            ? isSelected
                                ? AppColors.textButton
                                : AppColors.secondaryText
                            : isSelected
                                ? AppColors.textButton
                                : AppColors.grey,
                      )
                    : StyleText.fontSize20Weight500.copyWith(
                        color: light
                            ? isSelected
                                ? AppColors.textButton
                                : AppColors.secondaryText
                            : isSelected
                                ? AppColors.textButton
                                : AppColors.grey,
                      ),
              ),
            ),
          ),
          SizedBox(width: 16.sp),
          SizedBox(
            child: Text(
              label,
              style: isMobile
                  ? StyleText.fontSize14Weight600.copyWith(color: labelColor)
                  : StyleText.fontSize16Weight600.copyWith(color: labelColor),
            ),
          ),
          SizedBox(width: 30.sp),
        ],
      ),
    );
  }
}
