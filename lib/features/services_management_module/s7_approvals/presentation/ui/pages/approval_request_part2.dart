part of 'approval_request.dart';

// Split from approval_request.dart to keep files <700 LOC.

class _ApprovalServicesState extends State<ApprovalServices> {
  late final ApprovalRequestCubit _approvalRequestCubit;
  bool isGridViewChoose = true;
  TextEditingController searchController = TextEditingController();
  String? selectedStatus;
  List<String> selectedDepartmentKeys = [];
  bool showFilter = false;
  String selectStatus = "All";
  List<ServicesHistoryModel> filteredModel = [];
  List<ServicesHistoryModel> unsortedCurrent = [];
  List<ServicesHistoryModel> visibleApprovals = [];
/////////////////////////////// My Action ///////////////////////////
  int myTotal = 0;
  int myPending = 0;
  int myApproved = 0;
  int myRejected = 0;
  int myCanceled = 0;
  late final MainCoreEmployeeController employeeController;
  late final MainCoreDepartmentCubit departmentController;

  String _sanitizeEmail(String email) {
    return email
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[\u200e\u200f\u202a\u202b\u202c\u202d\u202e\u2066\u2067\u2068\u2069]'), '');
  }

  bool _isMyTurn(List<EmployeeEntityModell> approvalList, String myEmail) {
    final idx = approvalList.indexWhere((e) => _sanitizeEmail(e.email ?? '') == _sanitizeEmail(myEmail)
    );

    if (idx == -1) {
      return false;
    }

    for (int i = 0; i < idx; i++) {
      final s = (approvalList[i].state ?? '').toLowerCase();

      if (['rejected', 'cancel'].contains(s)) {
        return false;
      }
      if (['pending', 'normal', ''].contains(s)) {
        return false;
      }
      if (s != 'approved') {
        return false;
      }
    }

    final myState = (approvalList[idx].state ?? '').toLowerCase();
    final result = ['pending', 'normal', ''].contains(myState);
    return result;
  }
  String _myEntryState(List<EmployeeEntityModell> approvalList, String myEmail) {
    final idx = approvalList.indexWhere((e) => _sanitizeEmail(e.email ?? '') == _sanitizeEmail(myEmail)
    );
    if (idx == -1) return '';
    final state = (approvalList[idx].state ?? '').toLowerCase();
    return state;
  }
  void _recountMyActionCounts() {
    final list = ServicesManagerCubit.get(context).myApproval;

    final myEmail = (employeeEntity.email ?? '').toLowerCase();

    int pending = 0, approved = 0, rejected = 0, canceled = 0;

    for (int i = 0; i < list.length; i++) {
      final service = list[i];

      final cycle = service.currentApprovalCycle;

      final hasMe = cycle.any((e) => _sanitizeEmail(e.email ?? '') == _sanitizeEmail(myEmail)
      );

      if (!hasMe) {
        continue;
      }

      final overallState = (service.currentState ?? '').toLowerCase();

      final myState = _myEntryState(cycle, myEmail);

      if (overallState == 'cancel') {
        canceled++;
        continue;
      }

      if (myState == 'approved') {
        approved++;
        continue;
      }
      if (myState == 'rejected') {
        rejected++;
        continue;
      }

      if (_isMyTurn(cycle, myEmail)) {
        pending++;
        continue;
      }

      final hasRejectionBeforeMe = () {
        final myIdx = cycle.indexWhere((e) => _sanitizeEmail(e.email ?? '') == _sanitizeEmail(myEmail)
        );
        if (myIdx == -1) return false;

        for (int i = 0; i < myIdx; i++) {
          if ((cycle[i].state ?? '').toLowerCase() == 'rejected') {
            return true;
          }
        }
        return false;
      }();

      if (hasRejectionBeforeMe && ['pending', 'normal', ''].contains(myState)) {
        continue;
      }

    }

    setState(() {
      myPending = pending;
      myApproved = approved;
      myRejected = rejected;
      myCanceled = canceled;
      myTotal = myPending + myApproved + myRejected + myCanceled;
    });
  }
  String _statusKey = 'all';
  String _statusKeyForLabel(BuildContext ctx, String label) {
    final s = S.of(ctx);
    final l = label.trim().toLowerCase();
    String result;
    if (l == 'all' || l == (s.all).trim().toLowerCase()) result = 'all';
    else if (l == 'approved' || l == (s.Approved).trim().toLowerCase()) result = 'approved';
    else if (l == 'pending' || l == (s.Pending).trim().toLowerCase()) result = 'pending';
    else if (l == 'rejected' || l == (s.Rejected).trim().toLowerCase()) result = 'rejected';
    else if (l == 'canceled' || l == 'cancelled' || l == (s.Canceled).trim().toLowerCase()) result = 'cancel';
    else result = 'all';

    return result;
  }
  void _filterServices() {
    final model = ServicesManagerCubit.get(context).myApproval;

    final currentUserEmail = (employeeEntity.email ?? '').toLowerCase();

    final query = searchController.text.toLowerCase().trim();

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

// ✅ Get department labels from controller
    final selectedDeptLabels = selectedDepartmentKeys.map((deptId) {
      final label = isArabic
          ? departmentController.getArabicDepartmentNameFromDepartmentId(departmentId: deptId)
          : departmentController.getEnglishDepartmentNameFromDepartmentId(departmentId: deptId);
      return (label ?? deptId).toLowerCase().trim();
    }).toSet();

    int passedCount = 0;
    int failedInCycle = 0;
    int failedStatus = 0;
    int failedDepartment = 0;
    int failedSearch = 0;

    final filtered = model.where((service) {
      final serviceId = service.currentId ?? 'no-id';
      final serviceName = service.currentServiceNameEnglish ?? service.currentServiceNameArabic ?? 'no-name';

      final approvalList = service.currentApprovalCycle;

      final myIndex = approvalList.indexWhere(
              (e) => (e.email ?? '').toLowerCase() == currentUserEmail
      );

      if (myIndex == -1) {
        failedInCycle++;
        return false;
      }

      final myState = _myEntryState(approvalList, currentUserEmail);
      final finalState = getFinalStateFromModel(service).toLowerCase();

      bool hasRejectionBeforeMe = false;
      for (int i = 0; i < myIndex; i++) {
        if ((approvalList[i].state ?? '').toLowerCase() == 'rejected') {
          hasRejectionBeforeMe = true;
          break;
        }
      }

      // ✅ FIX 26/8/2026 — cancelled requests were showing under Pending.
      //
      // Cancelling a request does NOT touch the approval cycle: the requester
      // withdraws it, and every approver's entry is left exactly as it was —
      // still `''` or `'pending'`, still untouched. So for a cancelled request
      // `myState` is pending and `_isMyTurn` is true, and the `pending` case
      // below — which asked only about the cycle and never about the request —
      // matched it. The card then rendered with its "Canceled" button, which is
      // how it ended up visible in the screenshot: a Canceled card sitting in
      // the Pending tab.
      //
      // `_recountMyActionCounts` already had this right. It tests
      // `overallState == 'cancel'` FIRST and `continue`s, so cancelled requests
      // were excluded from the pending COUNT while still appearing in the
      // pending LIST — the count said 8 and the grid disagreed. Two functions,
      // two different rules, one of them wrong.
      //
      // The precedence below now mirrors that counter exactly: cancelled wins
      // over everything, because a withdrawn request is nobody's outstanding
      // work — not mine to act on, and not mine to have approved or rejected
      // either, whatever my cycle entry still says.
      final bool isCanceled = finalState == 'cancel';

      bool matchesChip;
      switch (_statusKey) {
        case 'all':
          matchesChip = (myState == 'approved' ||
              myState == 'rejected' ||
              _isMyTurn(approvalList, currentUserEmail) ||
              ['done', 'cancel', 'inprogress', 'branchsla', 'breached sla'].contains(finalState));
          break;

        case 'approved':
          matchesChip = !isCanceled && (myState == 'approved');
          break;

        case 'rejected':
          matchesChip = !isCanceled && (myState == 'rejected');
          break;

        case 'pending':
          matchesChip = !isCanceled &&
              _isMyTurn(approvalList, currentUserEmail) &&
              !hasRejectionBeforeMe &&
              ['pending', 'normal', ''].contains(myState);
          break;

        case 'cancel':
          matchesChip = isCanceled;
          break;

        default:
          matchesChip = (finalState == _statusKey);
      }

      if (!matchesChip) {
        failedStatus++;
        return false;
      }

      // ✅ Get department from employee entity using email
      final requesterEmail = service.currentEmailRequester ?? '';
      String? departmentId;

      if (requesterEmail.isNotEmpty) {
        final employee = employeeController.getLocaleEmployee(requesterEmail);
        if (employee != null) {
          departmentId = employee.departmentId;
        }
      }

      bool matchesDepartment = true;

      if (selectedDeptLabels.isNotEmpty && departmentId != null && departmentId.isNotEmpty) {
        final deptLabel = isArabic
            ? departmentController.getArabicDepartmentNameFromDepartmentId(departmentId: departmentId)
            : departmentController.getEnglishDepartmentNameFromDepartmentId(departmentId: departmentId);

        final normalizedDeptLabel = (deptLabel ?? '').toLowerCase().trim();
        matchesDepartment = selectedDeptLabels.contains(normalizedDeptLabel);

      }

      if (!matchesDepartment) {
        failedDepartment++;
        return false;
      }

      final serviceNameEn = (service.currentServiceNameEnglish ?? '').toLowerCase().trim();
      final serviceNameAr = (service.currentServiceNameArabic ?? '').toLowerCase().trim();
      final matchesSearch = query.isEmpty ||
          serviceNameEn.contains(query) ||
          serviceNameAr.contains(query);

      if (!matchesSearch) {
        failedSearch++;
        return false;
      }

      passedCount++;
      return true;
    }).toList();

    setState(() {
      filteredModel = filtered;
      unsortedCurrent = List<ServicesHistoryModel>.from(filteredModel);

      // ✅ Single source of truth for ordering — this used to carry its own
      // copy of the sort switch, so fixing the order in one place left the
      // other stale.
      visibleApprovals = _applySortOption(unsortedCurrent);
    });

  }
  /// Delegates to ApprovalRequestCubit — the per-state counts scan (audit
  /// fix item 2) no longer touches Firestore directly from this page. The
  /// resulting counts are exposed via the cubit's state stream; this page
  /// doesn't currently render them (see `myTotal`/`myPending`/... below,
  /// populated by `_recountMyActionCounts()` instead), so no local fields
  /// mirror them here.
  Future<void> _fetchServiceStateCounts(String currentUserEmail) async {
    await _approvalRequestCubit.fetchServiceStateCounts(currentUserEmail);
  }
  @override
  void initState() {
    super.initState();
    _approvalRequestCubit = ApprovalRequestCubit(
      repository: ServicesManagerCubit.get(context).repository,
    );
// ✅ Initialize controllers
    employeeEntity = AppControllers.employee.employeeEntity!;
    employeeController = AppControllers.employee;
    departmentController = context.read<MainCoreDepartmentCubit>();

    searchController.addListener(() {
      _filterServices();
    });

    ServicesManagerCubit.get(context).getMyApprovalServices(employeeEntity.email).then((_) {
      final count = ServicesManagerCubit.get(context).myApproval.length;

      WidgetsBinding.instance.addPostFrameCallback((_) {

        final model = ServicesManagerCubit.get(context).myApproval;

        if (model.isEmpty) {
        } else {
          for (int i = 0; i < model.length; i++) {
            final s = model[i];
            final id = s.currentId;
            final name = s.currentServiceNameEnglish ?? s.currentServiceNameArabic ?? 'no-name';
            final raw = getFinalStateFromModel(s);
            final loc = getLocalizedStatus(raw);
          }
        }

        _recountMyActionCounts();
        _filterServices();
      });
    }).catchError((error, stackTrace) {
    });
  }
  String getLocalizedStatus(String status) {
    final result = switch (status.toLowerCase()) {
      'done' => S.of(context).Done,
      'approved' => S.of(context).Approved,
      'pending' => S.of(context).Pending,
      'rejected' => S.of(context).Rejected,
      'cancel' => S.of(context).Canceled,
      'inprogress' => S.of(context).Inprogress,
      'branchsla' || 'breached sla' => S.of(context).BreachedSLA,
      _ => S.of(context).Pending,
    };
    return result;
  }
  int totalServices = 0;
  int doneCount = 0;
  int pendingCount = 0;
  int approvedCount = 0;
  int cancelCount = 0;
  int rejectedCount = 0;
  int inProgressCount = 0;
  int branchSlaCount = 0;
  String getFinalStateFromModel(ServicesHistoryModel service) {
    final stateField = (service.currentState ?? '').toString().toLowerCase();
    if (stateField == 'done') {
      return 'done';
    }

    if (stateField == 'cancel') {
      return 'cancel';
    }

    if (['inprogress', 'branchsla', 'breached sla'].contains(stateField)) {
      return stateField;
    }

    final cycle = service.currentApprovalCycle;
    final states = cycle
        .map((e) => (e.state ?? '').toLowerCase())
        .where((s) => s.isNotEmpty && s != 'normal')
        .toList();

    if (states.contains('cancel')) return 'cancel';
    if (states.contains('rejected')) return 'rejected';
    if (states.isNotEmpty && states.every((s) => s == 'approved')) return 'approved';
    if (states.contains('pending')) return 'pending';

    return stateField.isNotEmpty ? stateField : 'pending';
  }
  String? selectedDurationUnit;
  bool isTabletLandscape(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return size.width >= 600 && isLandscape;
  }
  int _ms(int? timestamp) => timestamp ?? 0;
  DateTime _dateRequestedOf(ServicesHistoryModel m) {
    if (m.timestamps.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);
    return DateTime.fromMillisecondsSinceEpoch(m.timestamps.first);
  }
  DateTime _lastUpdateOf(ServicesHistoryModel m) {
    if (m.timestamps.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);
    return DateTime.fromMillisecondsSinceEpoch(m.timestamps.last);
  }
  double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
  int _modelDurationSeconds(ServicesHistoryModel m) {
    final value = _toDouble(m.currentDurationOfServices);
    final unit = (m.currentSelectedDurationUnit ?? '').toLowerCase().trim();
    if (unit.startsWith('s')) return (value).round();
    if (unit.startsWith('min')) return (value * 60).round();
    if (unit == 'm') return (value * 60).round();
    if (unit.startsWith('h')) return (value * 3600).round();
    if (unit.startsWith('d')) return (value * 86400).round();
    if (unit.startsWith('w')) return (value * 604800).round();

    return (value * 60).round();
  }
  List<ServicesHistoryModel> originalList = [];

  /// Orders the cards for display.
  ///
  /// ✅ FIX: the grid opened oldest-first. The date comparisons were
  /// `a.compareTo(b)` — ascending — so with the default 'Date Requested'
  /// option the oldest approval request sat at the top of the grid and the
  /// newest one was buried at the bottom. Both date sorts are now newest →
  /// oldest (`b.compareTo(a)`), which is what you want on a queue you work
  /// through.
  ///
  /// Falling back to the raw Firestore order when no option is picked left the
  /// same impression of "random" ordering, so that case sorts by date too.
  ///
  /// Duration is deliberately left ascending — shortest first — since that is
  /// about length, not recency.
  List<ServicesHistoryModel> _applySortOption(
    List<ServicesHistoryModel> source,
  ) {
    final toDisplay = List<ServicesHistoryModel>.from(source);

    switch (selectedSortOption) {
      case 'Duration':
        toDisplay.sort(
          (a, b) => _modelDurationSeconds(a).compareTo(_modelDurationSeconds(b)),
        );
        break;
      case 'Last Update':
        toDisplay.sort((a, b) => _lastUpdateOf(b).compareTo(_lastUpdateOf(a)));
        break;
      case 'Date Requested':
      default:
        toDisplay.sort(
          (a, b) => _dateRequestedOf(b).compareTo(_dateRequestedOf(a)),
        );
        break;
    }

    return toDisplay;
  }

  void sortServices() {
    setState(() {
      visibleApprovals = _applySortOption(unsortedCurrent);
    });
  }
  String getLocalizedDurationUnit(BuildContext context, String key) {
    final localizer = S.of(context);
    switch (key.toLowerCase()) {
      case "hours":
        return localizer.hours;
      case "minutes":
        return localizer.minutes;
      case "week":
        return localizer.week;
      case "seconds":
        return localizer.seconds;
      default:
        return key;
    }
  }
  String? idSelect;
  String? selectServicesName;
  bool isApproved = false;
  bool isRejected = false;
  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 2)),
    );
  }
  String selectedSortOption = 'Date Requested';
  String userEmail = '';
  String userDepartment = '';
  List<ServicesHistoryModel> filteredServices = [];
  bool isFilterDialogOpen = false;
  String selectDepartment = "";
  final Map<String, String> approvalStateMap = {};
  String? selectedDepartmentKey;
  var employeeEntity = AppControllers.employee.employeeEntity!;
  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final brightness = Theme.of(context).brightness;
    var lightMode = Theme.of(context).brightness == Brightness.light;
    final isTablet = ContextExtension(context).isTablet;
    final isMobile = ContextExtension(context).isPhone;
    final isLandscape = ContextExtension(context).isLandscape;

    return SlideInContent(from: SlideFrom.bottom, child: Scaffold(
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).services,
          onFirstTap: () {
            navigateTo(context, LayoutScreenServices());
          },
          secondTitle: S.of(context).approvals,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               isMobile ? SingleChildScrollView(
                 scrollDirection: Axis.horizontal,
                 child: StatusChipFilter(
                   selectedKey: selectStatus,
                   onSelected: (status) {
                     setState(() {
                       selectStatus = status.trim();
                       _statusKey = _statusKeyForLabel(context, status);
                     });
                     _filterServices();
                     _recountMyActionCounts();
                   },
                   items: departmentChipItems(
                     totalCount: myTotal,
                     isArabic: isArabic,
                     departmentCounts: {
                       S.of(context).Approved: myApproved,
                       S.of(context).Pending: myPending,
                       S.of(context).Rejected: myRejected,
                       S.of(context).Canceled: myCanceled,
                     },
                     labelColors: {
                       S.of(context).Approved: AppColors.lightGreen,
                       S.of(context).Pending: AppColors.orange,
                       S.of(context).Rejected: AppColors.red,
                       S.of(context).Canceled: AppColors.darkRed!,
                     },
                   ),
                 ),
               ):
               StatusChipFilter(
                  selectedKey: selectStatus,
                  onSelected: (status) {
                    setState(() {
                      selectStatus = status.trim();
                      _statusKey = _statusKeyForLabel(context, status);
                    });
                    _filterServices();
                    _recountMyActionCounts();
                  },
                  items: departmentChipItems(
                    totalCount: myTotal,
                    isArabic: isArabic,
                    departmentCounts: {
                      S.of(context).Approved: myApproved,
                      S.of(context).Pending: myPending,
                      S.of(context).Rejected: myRejected,
                      S.of(context).Canceled: myCanceled,
                    },
                    labelColors: {
                      S.of(context).Approved: AppColors.lightGreen,
                      S.of(context).Pending: AppColors.orange,
                      S.of(context).Rejected: AppColors.red,
                      S.of(context).Canceled: AppColors.darkRed!,
                    },
                  ),
                ),

                SizedBox(height: 15.h),

                // ✅ FIX (bug report p31/p37): the three controls in this row
                // each sized themselves — the search field from its content
                // padding, the department dropdown at 34/36.h and the sort
                // control at 38.sp. Constraining the row pins all of them to
                // one height so they line up.
                SizedBox(
                  child: Row(
                  children: [
                    AppSearchTextField(
                        controller: searchController,
                        onChanged: (text) {
                          _filterServices();
                        }
                    ),

                    SizedBox(width: 9.sp),

                    // The department multi-select stays wide-screen only —
                    // there is no room for it beside the search box on a phone.
                    if (!isMobile) ...[
                      DepartmentMultiSelectPage(
                        selectedKeys: selectedDepartmentKeys,
                        onChanged: (keys) {
                          setState(() => selectedDepartmentKeys = keys);
                          _filterServices();
                        },
                      ),
                      SizedBox(width: 9.sp),
                    ],
                    // Services mobile QA p.28: the phone had no department
                    // filter. Icon button → department dialog, writing the
                    // same selectedDepartmentKeys as the dropdown above.
                    if (isMobile) ...[
                      ApprovalsDepartmentFilterButton(
                        selectedKeys: selectedDepartmentKeys,
                        onChanged: (keys) {
                          setState(() => selectedDepartmentKeys = keys);
                          _filterServices();
                        },
                      ),
                      SizedBox(width: 9.sp),
                    ],

                    // FIXED 9/9/2026 — the phone had a `CustomFilterIcon` with
                    // `onTap: () {}`. It looked exactly like a working control
                    // and did nothing, so on a phone there was no way to order
                    // the queue at all: whatever `selectedSortOption` happened
                    // to hold was what you got, and Date Requested could not be
                    // chosen or re-chosen.
                    //
                    // The sort menu is now rendered on BOTH breakpoints, the
                    // same control the wide layout already used. It needs no
                    // phone variant of its own — it takes `isMobile` and draws
                    // itself as the 38.sp icon-only square there, which is what
                    // the dead button was imitating. Same three options
                    // (Date Requested / Duration / Last Update), same localized
                    // labels, and re-picking the active one clears back to the
                    // Date Requested default, exactly as on desktop.
                    SortDropdownMenu(
                      selectedOption: selectedSortOption,
                      onSortSelected: (value) {
                        setState(() => selectedSortOption = value);
                        sortServices();
                      },
                      isMobile: isMobile,
                      isTabletLandscape: isTabletLandscape(context),
                    ),
                  ],
                  ),
                ),

                SizedBox(height: 15.h),

                visibleApprovals.isEmpty
                    ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          'assets/lottie_assets/main_lottie_assets/lottie_empty.json',
                          width: 260.sp,
                          height: 260.sp,
                          fit: BoxFit.contain,
                          repeat: true,
                          animate: true,
                        ),
                      ],
                    ))
                    : AnimatedCustomGridView(
                  itemCount: visibleApprovals.length,
                  crossAxisCount: CrossAxisCountHelperResponsive.getCrossAxisCountForDefaultTabletResponsive(context),
                  mainAxisExtent: ContextExtension(context).isPhone ? 265.sp :  275.sp,
                  mainAxisSpacing: 15.sp,
                  crossAxisSpacing: 15.sp,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  margin: EdgeInsets.only(bottom: 16.sp),
                  animationDuration: const Duration(milliseconds: 800),
                  staggerDelay: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  itemBuilder: (context, index) {
                    final service = visibleApprovals[index];
                    final raw = getFinalStateFromModel(service);
                    final loc = getLocalizedStatus(raw);

                    return ApprovalRequestCard(
                      key: ValueKey(service.currentId),
                      service: service,
                      cubit: _approvalRequestCubit,
                      onRefresh: () async {

                        await ServicesManagerCubit.get(context)
                            .getMyApprovalServices(employeeEntity.email!);

                        await _fetchServiceStateCounts(employeeEntity.email!);

                        _filterServices();

                        _recountMyActionCounts();

                      },
                      isMobile: isMobile,
                      isTablet: isTablet,
                      isLandscape: isLandscape,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
  @override
  void dispose() {
    searchController.dispose();
    _approvalRequestCubit.close();
    super.dispose();
  }
}
