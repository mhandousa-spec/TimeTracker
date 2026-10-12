part of 'employee_services.dart';

// Split from employee_services.dart to keep files <700 LOC.

class _EmployeeServicesScreenTabletState
    extends State<EmployeeServicesScreenTablet> {
  // ─── UI State ────────────────────────────────────────────────────────────────
  bool isGridViewChoose = true;
  bool showFilter = false;

  // ✅ FIX 1: Stable key — never a localized string, works in any language
  String selectStatus = "all";

  // ✅ FIX 2: Loading flag — shows spinner while first Firestore fetch runs
  bool _isLoadingCache = true;

  // ─── Cache ───────────────────────────────────────────────────────────────────
  // ✅ FIX 3: Firestore is fetched ONCE and stored here.
  //           All filtering/searching/counting works from this list instantly.
  List<ServicesHistoryModel> _cachedAllServices = [];
  bool _isCacheLoaded = false;

  // ─── Displayed list ──────────────────────────────────────────────────────────
  List<ServicesHistoryModel> filteredModel = [];

  // ─── Counts (recalculated from cache — zero extra Firestore reads) ────────────
  int totalServices = 0;
  int pendingCount = 0;
  int approvedCount = 0;
  int cancelCount = 0;
  int rejectedCount = 0;
  int doneCount = 0;
  int inProgressCount = 0;
  int branchSlaCount = 0;

  // ─── Controllers ─────────────────────────────────────────────────────────────
  var employeeEntity = AppControllers.employee.employeeEntity!;
  late final MainCoreDepartmentCubit departmentController;
  late final MainCoreEmployeeController employeeController;
  late final EmployeeServicesCubit _employeeServicesCubit;
  TextEditingController searchController = TextEditingController();
  Map<String, Map<String, dynamic>> selectedProviders = {};
  List<String> selectedDepartmentKeys = [];

  String get currentProviderEmail =>
      (employeeEntity.email ?? '').trim().toLowerCase();

  String extractValue(dynamic value) {
    if (value == null) return '';
    if (value is List) {
      if (value.isEmpty) return '';
      return value[0]?.toString() ?? '';
    }
    return value.toString();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PHASE 1 — Fetch via EmployeeServicesCubit ONCE, mirror into local cache
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _loadAndCacheServices() async {
    await _employeeServicesCubit.loadAndCacheServices(currentProviderEmail);
  }

  /// Mirrors the cubit's emitted state into this screen's local cache
  /// fields, which the rest of the (unchanged) filter/search/count logic
  /// below reads synchronously.
  void _onEmployeeServicesState(EmployeeServicesState state) {
    if (state is EmployeeServicesLoaded) {
      _cachedAllServices = state.services;
      _isCacheLoaded = true;
      _recalculateCounts();
      _applyFilterFromCache();
      if (mounted) setState(() => _isLoadingCache = false);
    } else if (state is EmployeeServicesError) {
      if (mounted) setState(() => _isLoadingCache = false);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PHASE 2 — Filter instantly from cache (no Firestore, no async)
  // ═══════════════════════════════════════════════════════════════════════════
  void _filterServices() {
    if (!_isCacheLoaded) return;
    _applyFilterFromCache();
  }

  void _applyFilterFromCache() {
    final searchQuery = searchController.text.trim().toLowerCase();
    final selectedDeptKeys = selectedDepartmentKeys
        .map((k) => k.trim().toLowerCase())
        .where((k) => k.isNotEmpty)
        .toSet();

    const allowedStatuses = {
      'done', 'approved', 'inprogress', 'branchsla',
      'breached sla', 'cancel', 'pending', 'rejected',
    };

    final result = _cachedAllServices.where((service) {
      final nameEn = service.currentServiceNameEnglish.toLowerCase();
      final nameAr = service.currentServiceNameArabic.toLowerCase();
      final matchesQuery = searchQuery.isEmpty ||
          nameEn.contains(searchQuery) ||
          nameAr.contains(searchQuery);

      final internalStatus = getFinalStateFromModel(service);
      final isAllowed =
      allowedStatuses.contains(internalStatus.toLowerCase());
      final matchesStatus = _isStatusMatch(
        internalStatus: internalStatus,
        selectedKey: selectStatus,
      );

      bool matchesDept = true;
      if (selectedDeptKeys.isNotEmpty) {
        final serviceDeptKeys =
        service.currentSelectDepartment
            .map((d) => d.toLowerCase().trim())
            .toSet();
        matchesDept =
            serviceDeptKeys.intersection(selectedDeptKeys).isNotEmpty;
      }

      return matchesQuery && isAllowed && matchesStatus && matchesDept;
    }).toList();

    _sortByCustomStatus(result);
    if (mounted) setState(() => filteredModel = result);
  }

  // ── Recalculate counts from cache — instant ──────────────────────────────────
  void _recalculateCounts() {
    doneCount = 0;
    approvedCount = 0;
    inProgressCount = 0;
    branchSlaCount = 0;
    cancelCount = 0;
    pendingCount = 0;
    rejectedCount = 0;

    for (final s in _cachedAllServices) {
      switch (getFinalStateFromModel(s).toLowerCase()) {
        case 'done':          doneCount++;         break;
        case 'approved':      approvedCount++;     break;
        case 'inprogress':    inProgressCount++;   break;
        case 'branchsla':
        case 'breached sla':  branchSlaCount++;    break;
        case 'cancel':        cancelCount++;       break;
        case 'pending':       pendingCount++;      break;
        case 'rejected':      rejectedCount++;     break;
      }
    }
    totalServices = doneCount + approvedCount + inProgressCount + cancelCount;
    if (mounted) setState(() {});
  }

  // ─── Status helpers ───────────────────────────────────────────────────────────
  // ✅ FIX 1: Compare using stable key — not localized label
  bool _isStatusMatch({
    required String internalStatus,
    required String selectedKey,
  }) {
    if (selectedKey == "all") return true;
    return internalStatus.toLowerCase().trim() ==
        selectedKey.toLowerCase().trim();
  }

  String getFinalStateFromModel(ServicesHistoryModel service) {
    final stateField = service.currentState.toLowerCase();
    if (['cancel', 'inprogress', 'done', 'branchsla', 'breached sla']
        .contains(stateField)) return stateField;

    final approvalCycle = service.currentApprovalCycle;
    if (approvalCycle.isEmpty) {
      if (stateField.isEmpty || stateField == 'pending') return 'approved';
      return stateField.isEmpty ? 'approved' : stateField;
    }

    final states = approvalCycle
        .where((e) => e.state != null && e.state!.isNotEmpty)
        .map((e) => e.state!.toLowerCase())
        .toList();

    if (states.contains('cancel')) return 'cancel';
    if (states.contains('rejected')) return 'rejected';
    if (states.every((s) => s == 'approved') && states.isNotEmpty)
      return 'approved';
    if (states.contains('pending')) return 'pending';
    if (stateField.isNotEmpty) return stateField;
    return 'approved';
  }

  int _statusRank(String status) {
    switch (status.toLowerCase()) {
      case 'done':          return 0;
      case 'approved':      return 1;
      case 'inprogress':    return 2;
      case 'branchsla':
      case 'breached sla':  return 3;
      case 'cancel':        return 4;
      default:              return 999;
    }
  }

  void _sortByCustomStatus(List<ServicesHistoryModel> list) {
    list.sort((a, b) {
      final ra = _statusRank(getFinalStateFromModel(a));
      final rb = _statusRank(getFinalStateFromModel(b));
      if (ra != rb) return ra.compareTo(rb);
      final ta = a.currentDurationOfServicesTimestamp.toDate();
      final tb = b.currentDurationOfServicesTimestamp.toDate();
      return tb.compareTo(ta);
    });
  }

  String getLocalizedStatus(BuildContext context, String status) {
    final s = S.of(context);
    switch (status.toLowerCase()) {
      case 'done':           return s.Done;
      case 'approved':      return s.Approved;
      case 'inprogress':    return s.Inprogress;
      case 'branchsla':
      case 'breached sla':  return s.BreachedSLA;
      case 'cancel':        return s.Canceled;
      case 'pending':       return s.status_pending;
      case 'rejected':      return s.status_rejected;
      default:              return status;
    }
  }

  String getLocalizedTimeUnit(String unit, BuildContext context) {
    final s = S.of(context);
    switch (unit.toLowerCase()) {
      case 'minutes': return s.minutes;
      case 'hours':   return s.hours;
      case 'days':    return s.days;
      case 'weeks':   return s.week;
      default:        return unit;
    }
  }

  bool isTabletLandscape(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width >= 600 &&
        MediaQuery.of(context).orientation == Orientation.landscape;
  }

  String formatStartDate(dynamic v) {
    if (v == null) return '-';
    DateTime date;
    if (v is Timestamp) {
      date = v.toDate();
    } else if (v is DateTime) {
      date = v;
    } else {
      return '-';
    }
    return DateFormat('dd MMM yyyy').format(date);
  }

  // ─── Init / Dispose ───────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    employeeController = AppControllers.employee;
    departmentController = context.read<MainCoreDepartmentCubit>();
    _employeeServicesCubit =
        EmployeeServicesCubit(
          employeeController: employeeController,
          departmentCubit: context.read<MainCoreDepartmentCubit>(),
        )
          ..stream.listen(_onEmployeeServicesState);
    searchController.addListener(_filterServices);

    // ✅ Single Firestore call (via the cubit) — everything else is instant
    // from cache.
    _loadAndCacheServices();
  }

  @override
  void dispose() {
    searchController.dispose();
    _employeeServicesCubit.close();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final visible =
    filteredModel.where((m) => m.currentProviderServices.isNotEmpty).toList();
    final gridViewVisible = filteredModel.where((m) {
      if (m.currentProviderServices.isEmpty) return false;
      final state = getFinalStateFromModel(m).toLowerCase();
      return state == 'approved' || state == 'inprogress' || state == 'done' || state == 'cancel' ;
    }).toList();

    final lightMode = Theme.of(context).brightness == Brightness.light;
    final isMobile = ContextExtension(context).isPhone;

    return Scaffold(
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).service,
          onFirstTap: () => navigateTo(context, LayoutScreenServices()),
          secondTitle: S.of(context).requestedServices,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                filterSection(),
                SizedBox(height: 15.sp),
                Row(
                  children: [
                    // ✅ NO Expanded here: AppSearchTextField already returns an
                    // Expanded internally (35-custom_search_widget_custom.dart).
                    // Wrapping it in a second one puts two Expanded widgets on
                    // the same RenderObject and throws:
                    //   "Incorrect use of ParentDataWidget. Competing
                    //    ParentDataWidgets are providing parent data to the
                    //    same RenderObject."
                    AppSearchTextField(
                      controller: searchController,
                      onChanged: (_) => _filterServices(),
                    ),
                    SizedBox(width: 15.sp),
                    if (!isMobile)
                      Row(
                        children: [
                          // ── Export ────────────────────────────────────────────
                          if (ServicesModuleAccess
                              .canExportRequestedServices) ...[
                          GestureDetector(
                            onTap: () => showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (_) => ExportDialog(
                                filteredModel: visible,
                                selectedProviders: selectedProviders,
                                formatStartDate: formatStartDate,
                              ),
                            ),
                            child: Container(
                              width: isTabletLandscape(context) ? 100.sp : 38.sp,
                              height: 38.sp,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    "assets/icons_assets/main_icons_assets/export_arrow.svg",
                                    width: 18.sp, height: 18.sp,
                                    fit: BoxFit.fill,
                                    color: AppColors.textButton,
                                    semanticsLabel: 'Export',
                                  ),
                                  if (isTabletLandscape(context)) ...[
                                    SizedBox(width: 8.sp),
                                    Text(S.of(context).export,
                                        style: StyleText.fontSize18Weight500
                                            .copyWith(color: AppColors.textButton)),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 10.sp),
                          ],
                          // ── Table view ────────────────────────────────────────
                          GestureDetector(
                            onTap: () => setState(() => isGridViewChoose = false),
                            child: Container(
                              width: 38.sp, height: 38.sp,
                              decoration: BoxDecoration(
                                // ✅ FIX (bug report p23/p30): the unselected state
                                // used AppColors.white, which is invisible against
                                // the light page background — the toolbar looked
                                // like it had a gap between Export and the grid
                                // button. AppColors.card is the surface tone the
                                // services-list toolbar already uses here.
                                color: isGridViewChoose
                                    ? AppColors.card
                                    : AppColors.primary,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  "assets/icons_assets/main_icons_assets/bullet_list.svg",
                                  width: 18.sp, height: 18.sp, fit: BoxFit.fill,
                                  color: !isGridViewChoose
                                      ? AppColors.textButton
                                      : (lightMode ? AppColors.secondaryText : AppColors.grey),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 15.sp),
                          // ── Grid view ─────────────────────────────────────────
                          GestureDetector(
                            onTap: () => setState(() => isGridViewChoose = true),
                            child: Container(
                              width: 38.sp, height: 38.sp,
                              decoration: BoxDecoration(
                                // ✅ FIX (bug report p23/p30): see the table-view
                                // button above — unselected must be a visible
                                // surface, not white-on-white.
                                color: isGridViewChoose
                                    ? AppColors.primary
                                    : AppColors.card,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  "assets/icons_assets/main_icons_assets/grid_four_squares.svg",
                                  width: 18.sp, height: 18.sp, fit: BoxFit.fill,
                                  color: isGridViewChoose
                                      ? AppColors.textButton
                                      : (lightMode ? AppColors.secondaryText : AppColors.grey),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                SizedBox(height: 10.sp),
                // ── Content area ───────────────────────────────────────────
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ✅ Loading spinner while cache is building
                    // Services mobile QA p.19: the spinner sat 80pt under the
                    // search bar, high on the page. It is now centred in the
                    // space left under the header.
                    if (_isLoadingCache)
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.55,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    // ✅ FIX 26/8/2026 — the two empty states did different
                    // things, and one of them did nothing.
                    //
                    // GRID drew the animation at `isMobile ? 200.w : 400.w`
                    // wide by `isMobile ? 200.w : 400.h` tall — note the `.w`
                    // paired with the `.h`, so the box was scaled on two
                    // different axes and `BoxFit.fill` stretched the artwork to
                    // match it. Now a square 200.sp at its natural ratio.
                    //
                    // LIST rendered `const SizedBox()` — nothing at all. Switch
                    // to the table view with no results and the page simply
                    // went blank, with nothing to tell an empty result apart
                    // from a load that had failed.
                    //
                    // Both branches now call the same builder, so they cannot
                    // drift apart again.
                    else if (isGridViewChoose && filteredModel.isEmpty)
                      _buildEmptyState()
                    else if (!isGridViewChoose && visible.isEmpty)
                        _buildEmptyState()
                      else
                        isGridViewChoose
                        // CHANGED 31/8/2026 — a plain GridView.builder, not
                        // AnimatedCustomGridView.
                        //
                        // The staggered entry animation (600ms, 100ms per
                        // tile, easeOutCubic) delayed the last tile of a full
                        // grid by well over a second, replayed on every
                        // filter change and every rebuild, and animated
                        // widgets that carry MouseRegion/InkWell — the same
                        // hover machinery behind the MouseTracker re-entrancy
                        // documented on [_openServiceDetails] below. The grid
                        // geometry is unchanged: same cross-axis count, same
                        // 267.sp extent, same 15.sp gaps.
                            ? GridView.builder(
                          itemCount: gridViewVisible.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: CrossAxisCountHelperResponsive
                                .getCrossAxisCountForDefaultTabletResponsive(
                                    context),
                            mainAxisExtent: 267.sp,
                            mainAxisSpacing: 15.sp,
                            crossAxisSpacing: 15.sp,
                          ),
                          itemBuilder: (context, index) {
                            final service = gridViewVisible[index];
                            final internalStatus = getFinalStateFromModel(service);
                            final localizedStatus =
                            getLocalizedStatus(context, internalStatus);

                            // Department from controller — no Firestore
                            final requesterEmail =
                                service.currentEmailRequester ?? '';
                            String departmentName = '-';
                            if (requesterEmail.isNotEmpty) {
                              final emp = employeeController
                                  .getLocaleEmployee(requesterEmail);
                              if (emp != null &&
                                  emp.departmentId != null &&
                                  emp.departmentId!.isNotEmpty) {
                                final isAr = Localizations.localeOf(context)
                                    .languageCode == 'ar';
                                departmentName = isAr
                                    ? (departmentController
                                    .getArabicDepartmentNameFromDepartmentId(
                                    departmentId: emp.departmentId!) ?? '-')
                                    : (departmentController
                                    .getEnglishDepartmentNameFromDepartmentId(
                                    departmentId: emp.departmentId!) ?? '-');
                              }
                            }

                            final isAr = Localizations.localeOf(context)
                                .languageCode == 'ar';

                            return GestureDetector(
                              onTap: () => _openServiceDetails(service),
                              child: ServiceCard(
                                department: departmentName,
                                jobTitle: isAr
                                    ? service.currentJobTitleRequesterArabic
                                    : service.currentJobTitleRequester,
                                title: isAr
                                    ? service.currentServiceNameArabic
                                    : service.currentServiceNameEnglish,
                                serviceRequestor: isAr
                                    ? "${service.currentFirstNameRequesterArabic} ${service.currentLastNameRequesterArabic}"
                                    : "${service.currentFirstNameRequester} ${service.currentLastNameRequester}",
                                requestedDate: DateFormat('dd MMM yyyy').format(
                                    service.currentDurationOfServicesTimestamp
                                        .toDate()),
                                durationServices:
                                "${service.currentDurationOfServices} ${getLocalizedTimeUnit(service.currentSelectedDurationUnit, context)}",
                                status: internalStatus,
                                localizedStatus: localizedStatus,
                              ),
                            );
                          },
                        )
                            :   ServicesTableWidget(
                          services: visible,
                          locale: Localizations.localeOf(context).languageCode,
                          onRowTap: (service) => _openServiceDetails(
                            service as ServicesHistoryModel,
                          ),
                        ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Function Name: [_openServiceDetails]
  ///
  /// Purpose: Open a request's details, one frame after the tap.
  ///
  /// ✅ FIX 26/8/2026 — this is the
  /// `'!_debugDuringDeviceUpdate': is not true` assertion from
  /// `MouseTracker`, thrown on every card tap on macOS.
  ///
  /// Both tap handlers used to call `navigateTo(...)` inline, so the route was
  /// pushed SYNCHRONOUSLY from inside the pointer callback. Pushing a route
  /// adds and removes `MouseRegion`s — the departing page's go away, the
  /// arriving page's appear — and Flutter answers a changed set of regions by
  /// running `MouseTracker.updateAllDevices`. Inside that pass it calls the
  /// enter/exit callbacks of the regions involved, and `InkWell`'s exit
  /// handler calls `setState` to drop its hover highlight. That is a tree
  /// mutation raised DURING a device update, which re-enters
  /// `_deviceUpdatePhase` — and the assertion exists to catch exactly that
  /// re-entry.
  ///
  /// The table rows make it easy to hit: `ServicesTableWidget` wraps each row
  /// in `MouseRegion` → `Material` → `InkWell`, so a hovered row has two
  /// overlapping hover regions to unwind at the moment it is navigated away
  /// from. (The outer `MouseRegion` is redundant, incidentally — `InkWell`
  /// already picks its own cursor from whether `onTap` is null — but removing
  /// it would only reduce the churn, not stop the re-entry.)
  ///
  /// Deferring to the end of the frame takes the tree mutation out of the
  /// pointer-dispatch and mouse-update path entirely: by the time the route is
  /// pushed, the device update has finished. Nothing is visible to the user —
  /// the navigation still happens on the same tap.
  ///
  /// ⚠️ Debug-only in its symptom: assertions are compiled out of release
  /// builds, so this never crashed a shipped app. It did flood the console and
  /// break the debugger on every tap.
  ///
  /// Parameters:
  /// - [service]: the request whose details to open.
  void _openServiceDetails(ServicesHistoryModel service) {
    // TEMP DIAGNOSTIC 31/8/2026 — tracing why the details page does not open.
    // If the first line prints but the second does not, the widget was
    // unmounted between the tap and the end of the frame. If both print and
    // no page appears, the push happened and the problem is inside
    // EmployeeDetailsServicesToggle / …ScreenTablet — look for their SVCDIAG
    // lines next.
    debugPrint('SVCDIAG >>> _openServiceDetails tapped '
        'requestId=${service.currentId} index=${filteredModel.indexOf(service)}');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        debugPrint('SVCDIAG >>> _openServiceDetails ABORTED — not mounted');
        return;
      }
      debugPrint('SVCDIAG >>> _openServiceDetails pushing route');
      navigateTo(
        context,
        EmployeeDetailsServicesToggle(
          index: filteredModel.indexOf(service),
          approvalModel: service,
        ),
      );
    });
  }

  /// Function Name: [_buildEmptyState]
  ///
  /// Purpose: What the content area shows when there is nothing to list.
  ///
  /// ADDED 26/8/2026 so the grid and the table say the same thing — the table
  /// used to say nothing at all.
  ///
  /// Square 200.sp, and `.sp` on BOTH axes on purpose: the previous grid-only
  /// version mixed `.w` and `.h`, which scale independently, so the animation
  /// was drawn into a non-square box and `BoxFit.fill` distorted it. `.sp`
  /// keeps one scale factor for both, and [BoxFit.contain] leaves the artwork
  /// alone even if the box ever stops being square.
  ///
  /// Returns: [Widget] a horizontally centred empty-state animation.
  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.sp),
      child: Center(
        child: Lottie.asset(
          'assets/lottie_assets/main_lottie_assets/lottie_empty.json',
          width: 300.sp,
          height: 300.sp,
          fit: BoxFit.fill,
          repeat: true,
          animate: true,
        ),
      ),
    );
  }

  // ─── Filter chips ─────────────────────────────────────────────────────────────
  Widget filterSection() {
    final s = S.of(context);
    final doneLabel = s.Done;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _statusChip("$totalServices", s.all,
              statusKey: "all",
              isSelected: selectStatus == "all",
              labelColor: Theme.of(context).brightness == Brightness.light
                  ? AppColors.secondaryText
                  : AppColors.grey),
          _statusChip("$doneCount", doneLabel,
              statusKey: "done",
              isSelected: selectStatus == "done",
              labelColor: AppColors.lightGreen),
          _statusChip("$approvedCount", s.Approved,
              statusKey: "approved",
              isSelected: selectStatus == "approved",
              labelColor: AppColors.lightGreen),
          _statusChip("$inProgressCount", s.Inprogress,
              statusKey: "inprogress",
              isSelected: selectStatus == "inprogress",
              labelColor: AppColors.yellow),
          _statusChip("$branchSlaCount", s.BreachedSLA,
              statusKey: "breached sla",
              isSelected: selectStatus == "breached sla",
              labelColor: AppColors.darkRed!),
          _statusChip("$cancelCount", s.Canceled,
              statusKey: "cancel",
              isSelected: selectStatus == "cancel",
              labelColor: AppColors.red!),
        ],
      ),
    );
  }

  // ✅ statusKey is saved to selectStatus — display label is separate
  Widget _statusChip(
      String count,
      String label, {
        required String statusKey,
        required bool isSelected,
        required Color labelColor,
      }) {
    final light = Theme.of(context).brightness == Brightness.light;
    final isMobile = ContextExtension(context).isPhone;

    return GestureDetector(
      onTap: () {
        setState(() => selectStatus = statusKey); // ✅ stable key
        _filterServices();                        // ✅ instant from cache
      },
      child: Row(
        children: [
          Container(
            width: isMobile ? 35.sp : 45.sp,
            height: isMobile ? 35.sp : 45.sp,
            decoration: BoxDecoration(
              color: light
                  ? (isSelected ? AppColors.primary : AppColors.white)
                  : (isSelected ? AppColors.primary : AppColors.chatBackground),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Center(
              child: Text(
                count,
                style: (isMobile
                    ? StyleText.fontSize14Weight400
                    : StyleText.fontSize20Weight500)
                    .copyWith(
                  color: light
                      ? (isSelected ? AppColors.textButton : AppColors.secondaryText)
                      : (isSelected ? AppColors.textButton : AppColors.grey),
                ),
              ),
            ),
          ),
          SizedBox(width: 16.sp),
          Text(
            label,
            style: (isMobile
                ? StyleText.fontSize14Weight600
                : StyleText.fontSize16Weight600)
                .copyWith(color: labelColor),
          ),
          SizedBox(width: 30.sp),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ServiceCard
// ═══════════════════════════════════════════════════════════════════════════════
