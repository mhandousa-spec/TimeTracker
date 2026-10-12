part of 'employee_details_services.dart';

// Split from employee_details_services.dart to keep files <700 LOC.

class _EmployeeDetailsServicesScreenTabletState extends State<EmployeeDetailsServicesScreenTablet> {
  final TextEditingController _controller = TextEditingController();
  bool isVisible = true;
  String? currentState;
  String? selectedState;
  Future<Map<String, dynamic>?>? _providerFuture;
  final EmployeeActionCubit _employeeActionCubit = EmployeeActionCubit();

  // Requester data from SharedPreferences
  String? globalEmailRequester;
  String? globalFirstNameRequester;
  String? globalLastNameRequester;
  String? globalGenderRequester;
  String? globalPhoneRequester;
  String? globalJobTitleRequester;
  String? globalDepartmentRequester;
// ✅ ADD THIS METHOD at the top of the class with other helper methods
  late final MainCoreDepartmentCubit departmentController;
  late final MainCoreEmployeeController employeeController;

  @override
  void initState() {
    super.initState();
    // TEMP DIAGNOSTIC 31/8/2026 — tracing why the details page does not open.
    debugPrint('SVCDIAG >>> EmployeeDetailsServicesScreenTablet.initState '
        'requestId=${widget.approvalModel.currentId} index=${widget.index}');

    // ✅ Initialize controllers
    departmentController = context.read<MainCoreDepartmentCubit>();
    employeeController = AppControllers.employee;

    _initializeState();
    _loadRequesterData();
    _ensureApprovalCycleExists();
  }

  @override
  void dispose() {
    _controller.dispose();
    _employeeActionCubit.close();
    super.dispose();
  }

// ✅ ADD THIS HELPER METHOD
  String _getDepartmentNameFromId(String departmentId) {
    if (departmentId.isEmpty || departmentId == '-') {
      return '-';
    }

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final departmentName = isArabic
        ? departmentController.getArabicDepartmentNameFromDepartmentId(departmentId: departmentId)
        : departmentController.getEnglishDepartmentNameFromDepartmentId(departmentId: departmentId);

    return departmentName ?? departmentId; // Fallback to ID if name not found
  }

  // ==================== INITIALIZATION ====================

  void _initializeState() {
    currentState = widget.approvalModel.currentState;

    final approvalCycle = widget.approvalModel.currentApprovalCycle;

    // Auto-approve if no approval cycle exists
    if (approvalCycle.isEmpty && _isEmptyOrPending(currentState)) {
      currentState = 'approved';
    }

    // Check if all approvers have approved
    if (approvalCycle.isNotEmpty) {
      final allApproved = approvalCycle.every((e) => e.state?.toLowerCase() == 'approved');
      if (allApproved && _isEmptyOrPending(currentState)) {
        currentState = 'approved';
      }
    }

  }

  bool _isEmptyOrPending(String? state) {
    return state == null || state == '' || state == 'pending';
  }

  // Helper method to get requester's language preference from Firestore.
  // Routed through EmployeeActionCubit, which itself delegates to
  // ServicesManagerCubit.repository (D02/D03/D01: no Firestore, no 'users'
  // literal, no try/catch in the page).
  Future<bool> _getRequesterLanguagePreference(String requesterEmail) async {
    return _employeeActionCubit.getRequesterLanguagePreferenceIsArabic(
      ServicesManagerCubit.get(context),
      requesterEmail,
    );
  }

  // Notification fan-out on status change now lives in
  // EmployeeActionCubit._sendStatusChangeNotification, invoked internally by
  // updateStateInFirestore() below — no direct Firestore/notification-service
  // calls remain in this page.

  Future<void> _loadRequesterData() async {
    final prefs = await SharedPreferences.getInstance();
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    setState(() {
      globalEmailRequester = prefs.getString("emailRequester") ?? '';
      globalGenderRequester = prefs.getString("genderRequester") ?? '';
      globalPhoneRequester = prefs.getString("phoneRequester") ?? '';
      globalDepartmentRequester = prefs.getString("departmentRequester") ?? '';

      globalFirstNameRequester = isArabic
          ? prefs.getString("firstNameRequesterArabic") ?? ''
          : prefs.getString("firstNameRequester") ?? '';

      globalLastNameRequester = isArabic
          ? prefs.getString("lastNameRequesterArabic") ?? ''
          : prefs.getString("lastNameRequester") ?? '';

      globalJobTitleRequester = isArabic
          ? prefs.getString("jobTitleRequesterArabic") ?? ''
          : prefs.getString("jobTitleRequester") ?? '';
    });
  }

  Future<void> _ensureApprovalCycleExists() async {
    final service = widget.approvalModel;
    final hasApprovalCycle = service.currentApprovalCycle.isNotEmpty;

    if (!hasApprovalCycle && _isApprovedOrEmpty(service.currentState)) {
      final requesterEmail = service.currentEmailRequester.isNotEmpty
          ? service.currentEmailRequester
          : globalEmailRequester ?? employeeFunctionHelper.email;
      if (requesterEmail == null) return;

      final newState = await _employeeActionCubit.ensureApprovalCycleExists(
        requestId: service.currentId,
        requesterEmail: requesterEmail,
      );

      if (newState != null && mounted) {
        setState(() => currentState = newState);
      }
    }
  }

  bool _isApprovedOrEmpty(String state) {
    final lower = state.toLowerCase();
    return lower == 'approved' || lower == '' || lower == 'pending';
  }

  // ==================== STATE MANAGEMENT ====================

  String _getOverallStatus() {
    final approvalCycle = widget.approvalModel.currentApprovalCycle;
    final docState = currentState?.toLowerCase();

    if (docState == 'inprogress' || docState == 'breached sla') {
      return docState!;
    }

    // Check for rejections/cancellations
    for (final approver in approvalCycle) {
      final state = approver.state?.toLowerCase();
      if (state == 'rejected' || state == 'cancel') return state!;
    }

    // Check for pending
    for (final approver in approvalCycle) {
      if (approver.state?.toLowerCase() == 'pending') return 'pending';
    }

    // All approved
    if (approvalCycle.every((e) => e.state?.toLowerCase() == 'approved')) {
      return 'approved';
    }

    return 'pending';
  }

  List<EmployeeEntityModell> _adjustCycleStates(List<EmployeeEntityModell> list) {
    final adjusted = List<EmployeeEntityModell>.from(list);
    bool foundPending = false;

    for (int i = 0; i < adjusted.length; i++) {
      final originalState = adjusted[i].state?.toLowerCase();

      if (originalState == 'approved' || originalState == 'rejected' || originalState == 'cancel') {
        continue;
      }

      if (!foundPending) {
        adjusted[i] = adjusted[i].copyWith(state: 'pending');
        foundPending = true;
      } else {
        adjusted[i] = adjusted[i].copyWith(state: 'normal');
      }
    }

    return adjusted;
  }

  Future<void> _fetchLatestStateFromFirestore() async {
    final requesterEmail = employeeFunctionHelper.email;
    if (requesterEmail == null) return;

    final latest = await _employeeActionCubit.fetchLatestState(
      requestId: widget.approvalModel.currentId,
      requesterEmail: requesterEmail,
    );

    if (latest != null) {
      currentState = latest;
    }
  }

  // ==================== UI HELPERS ====================

  String _getLabel(String state) {
    switch (state.toLowerCase()) {
      case 'approve':
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'cancel':
        return 'Canceled';
      case 'pending':
        return 'Pending';
      case 'inprogress':
        return 'Inprogress';
      case 'breached sla':
        return 'Breached SLA';
      default:
        return FormatHelper.capitalize(state);
    }
  }

  Color _getBorderColor(String state) {
    switch (state.toLowerCase()) {
      case 'pending':
        return AppColors.pending;
      case 'approve':
      case 'approved':
        return AppColors.lightGreen;
      case 'rejected':
      case 'cancel':
        return AppColors.block;
      case 'inprogress':
        return AppColors.secondaryPrimary;
      case 'breached sla':
        return AppColors.block;
      default:
        return AppColors.lightGrey!;
    }
  }

  String _getIconAsset(String state) {
    switch (state.toLowerCase()) {
      case 'approve':
      case 'approved':
        return 'assets/icons_assets/main_icons_assets/status_approved_check_green.svg';
      case 'rejected':
      case 'cancel':
        return 'assets/icons_assets/main_icons_assets/status_rejected_stamp_red.svg';
      case 'pending':
        return 'assets/icons_assets/main_icons_assets/status_pending_check_cross_orange.svg';
      case 'inprogress':
        return 'assets/icons_assets/services_assets/work_in_progress_badge_yellow.svg';
      case 'breached sla':
        return 'assets/icons_assets/services_assets/sla_breached_clock_white.svg';
      default:
        return 'assets/icons_assets/main_icons_assets/status_pending_check_cross_orange.svg';
    }
  }

  Color _getStateColor(String state) {
    switch (state.toLowerCase()) {
      case 'approve':
      case 'approved':
        return AppColors.lightGreen;
      case 'inprogress':
        return AppColors.pending;
      case 'done':
        return AppColors.lightGreen;
      default:
        return AppColors.black;
    }
  }

  Color _getArrowColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return AppColors.pending;
      case 'approved':
        return AppColors.lightGreen;
      case 'rejected':
        return AppColors.block;
      case 'inprogress':
        return AppColors.secondaryPrimary;
      default:
        return Theme.of(context).brightness == Brightness.light
            ? AppColors.blackButton
            : AppColors.whiteShadow;
    }
  }

  Map<String, String> _getLocalizedLabels(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return {
      'approved': S.of(context).status_approved,
      'inprogress': S.of(context).sm_inprogress,
      'done': S.of(context).sm_done,
    };
  }

  bool _isTabletLandscape(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return size.width >= 600 && isLandscape;
  }

  // ==================== DROPDOWN LOGIC ====================

  bool _shouldShowDropdown() {
    final state = currentState?.toLowerCase();

    if (state == 'cancel') {
      return false;
    }

    final approvalCycle = widget.approvalModel.currentApprovalCycle;

    if (approvalCycle.isEmpty) {
      final canProgress = state == 'approved' || state == 'inprogress' || state == 'done' || state == null || state == '';
      return canProgress;
    }

    final allApproved = approvalCycle.isNotEmpty && approvalCycle.every((e) => e.state?.toLowerCase() == 'approved');

    final shouldShow = state == 'approved' ||
        state == 'inprogress' ||
        state == 'done' ||
        allApproved ||
        (state == null && allApproved) ||
        (state == '' && allApproved) ||
        (state == 'pending' && allApproved);

    return shouldShow;
  }

  String get _effectiveState => (selectedState ?? currentState ?? '').toLowerCase();

  List<String> _getAvailableStates(String? _) {
    final c = _effectiveState;

    if (c == 'done') {
      return ['done'];
    }

    if (c == 'inprogress') {
      return ['done'];
    }

    if (c == 'approved') {
      return ['inprogress'];
    }

    final approvalCycle = widget.approvalModel.currentApprovalCycle;
    if (approvalCycle.isNotEmpty) {
      final allApproved = approvalCycle.every((e) => e.state?.toLowerCase() == 'approved');
      if (allApproved) {
        return ['inprogress'];
      }
    }

    if (approvalCycle.isEmpty) {
      return ['inprogress'];
    }

    return ['inprogress'];
  }

  // ==================== FIREBASE UPDATE ====================

  Future<void> _updateStateInFirestore(String newState) async {
    final requesterEmail = widget.approvalModel.currentEmailRequester.isNotEmpty
        ? widget.approvalModel.currentEmailRequester
        : globalEmailRequester ?? employeeFunctionHelper.email;

    if (requesterEmail == null || requesterEmail.isEmpty) {
      throw Exception('Requester email unavailable');
    }

    final isArabicRequester = Localizations.localeOf(context).languageCode == 'ar';
    final serviceName = isArabicRequester
        ? (widget.approvalModel.currentServiceNameArabic.isNotEmpty
            ? widget.approvalModel.currentServiceNameArabic
            : widget.approvalModel.currentServiceNameEnglish)
        : widget.approvalModel.currentServiceNameEnglish;

    final refreshed = await _employeeActionCubit.updateStateInFirestore(
      requestId: widget.approvalModel.currentId,
      requesterEmail: requesterEmail,
      newState: newState,
      serviceName: serviceName,
      isArabicRequester: isArabicRequester,
    );

    if (refreshed != null) {
      currentState = refreshed;
    }

    if (!mounted) return;
    setState(() {
      selectedState = currentState;
    });
  }

  /// Function Name: [_applyStateChange]
  ///
  /// Purpose: Confirm the status change, write it, then leave the page — after
  /// the dropdown's own overlay route has finished closing.
  ///
  /// ⚠️ WHY THIS IS NOT THE BODY OF `onChanged` (30/8/2026).
  ///
  /// `DropdownButton2.onChanged` fires while the menu route is being
  /// dismissed, and this code used to open a confirmation dialog on the very
  /// next line — inserting a fresh overlay full of hover targets while the
  /// overlay the menu lived in was still being torn down. Two overlays
  /// changing their mouse-sensitive contents in one frame is the shape of
  /// re-entrancy MouseTracker asserts on:
  ///
  ///     'package:flutter/src/rendering/mouse_tracker.dart':
  ///     Failed assertion: line 199: '!_debugDuringDeviceUpdate': is not true.
  ///
  /// The stack for that assertion contains no application frames at all — it
  /// is raised from a scheduler callback — so it cannot be traced back to a
  /// call site.
  ///
  /// ⚠️ CORRECTED 30/8/2026 (second attempt). The first fix deferred with
  /// `WidgetsBinding.instance.addPostFrameCallback`, which does NOT get the
  /// work out of the danger zone — it puts it INTO it.
  /// `RendererBinding._scheduleMouseTrackerUpdate` queues
  /// `MouseTracker.updateAllDevices` as a post-frame callback too, so both ran
  /// in the same `SchedulerPhase.postFrameCallbacks` pass, in list order, with
  /// a dialog being pushed from one of them. `Future.delayed(Duration.zero)`
  /// resumes on a fresh event-loop turn once the frame is completely finished,
  /// which is what "after the menu route closes" actually requires.
  ///
  /// It also closes four async gaps that were real bugs on their own. The old
  /// body used `context` after `await` four times — the confirmation dialog,
  /// the success dialog, the navigation and the SnackBar — with no `mounted`
  /// check anywhere, and `_updateStateInFirestore` ends in `setState`.
  /// Awaiting a dialog the user can dismiss, then a Firestore round trip, then
  /// navigating away, is ample time for this State to be gone.
  ///
  /// Parameters:
  /// - [value]: the status the user picked in the dropdown.
  Future<void> _applyStateChange(String value) async {
    if (!await showChangeStatusConfirmationDialog(context)) return;
    if (!mounted) return;

    setState(() {
      selectedState = value;
      if (value.toLowerCase() == 'done') {
        currentState = 'done';
      }
    });

    try {
      await _updateStateInFirestore(value);
      if (!mounted) return;
      await showChangeStatusSuccessDialog(context);
      if (!mounted) return;
      navigateTo(context, EmployeeLayoutScreenServices());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update status: $e"),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  // ==================== PROVIDER COMPUTATION ====================

  Future<Map<String, dynamic>?> _computeProvider() {
    final candidates = widget.approvalModel.currentProviderServices
        .map((e) => {
      'email': e.email,
      'firstName': e.firstName,
      'lastName': e.lastName,
      'firstNameInArabic': e.firstNameInArabic,
      'lastNameInArabic': e.lastNameInArabic,
      'title': e.title,
      'titleInArabic': e.titleInArabic,
      'mobilePhone': (e.mobilePhone == null)
          ? null
          : {
        'countryApp': e.mobilePhone?.countryApp,
        'countryCode': e.mobilePhone?.countryCode,
        'phone': e.mobilePhone?.phone,
      },
    })
        .where((m) => (m['email'] ?? '').toString().isNotEmpty)
        .toList();

    return selectServiceProviderLite(
      candidates: candidates,
      windowDays: 7,
      perDayCap: 2,
    );
  }

  // ==================== DIALOGS ====================
  // Moved to ui/widgets/employee_details_dialogs_and_sections.dart
  // (showChangeStatusConfirmationDialog / showChangeStatusSuccessDialog) to
  // bring this file under the 800-LOC guideline (audit fix item 4a).

  bool _isCommentExpanded = false;
  // ==================== BUILD METHOD ====================

  @override
  Widget build(BuildContext context) {
    final isMobile = ContextExtension(context).isPhone;
    final isTablet = ContextExtension(context).isTablet;
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final approvalCycle = widget.approvalModel.currentApprovalCycle;
    final displayCycle = _adjustCycleStates(approvalCycle);

    final docState = _getOverallStatus();
    String stateLabel = _getLabel(docState);
    Color borderColor = _getBorderColor(docState);
    String iconAsset = _getIconAsset(docState);

    bool hasRejection = displayCycle.any(
          (e) => e.state != null && (e.state!.toLowerCase() == 'rejected' || e.state!.toLowerCase() == 'cancel'),
    );

    if (hasRejection) {
      final rejected = displayCycle.firstWhere(
            (e) => e.state!.toLowerCase() == 'rejected' || e.state!.toLowerCase() == 'cancel',
      );
      final s = rejected.state!.toLowerCase();
      stateLabel = _getLabel(s);
      borderColor = _getBorderColor(s);
      iconAsset = _getIconAsset(s);
    } else if (docState != 'inprogress' && displayCycle.every((e) => e.state?.toLowerCase() == 'approved')) {
      stateLabel = 'Approved';
      borderColor = AppColors.lightGreen;
      iconAsset = "assets/icons_assets/main_icons_assets/status_approved_check_green.svg";
    }

    final localizedLabels = _getLocalizedLabels(context);
    final dropdownStates = _getAvailableStates(currentState);

    // TEMP DIAGNOSTIC 31/8/2026.
    debugPrint('SVCDIAG >>> EmployeeDetailsServicesScreenTablet.build '
        'returning Scaffold | currentState=$currentState '
        'selectedState=$selectedState');

    // CHANGED 31/8/2026 — the whole page was wrapped in
    // `SlideInContent(from: SlideFrom.bottom, ...)`. An entry animation that
    // does not run leaves its child translated off-screen, which is
    // indistinguishable from "the details page did not open": the route is
    // pushed, the State mounts, build returns a Scaffold, and nothing is
    // visible. Removed so the page is on screen the instant it is built.
    return Scaffold(
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).serviceRequests,
          onFirstTap: () {
            Navigator.pop(context);
          },
          secondTitle: S.of(context).requestedServices,
          onSecondTap: () {
            Navigator.pop(context);
          },
          thirdTitle: FormatHelper.capitalize(
            isArabic ? widget.approvalModel.currentServiceNameArabic : widget.approvalModel.currentServiceNameEnglish,
          ),
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              children: [
                // ✅ Hide all content when comments are expanded
                if (!_isCommentExpanded) ...[
                  _buildHeader(lightMode, dropdownStates, localizedLabels, isArabic),
                  SizedBox(height: 10.sp),
                  _buildMainContent(isMobile, lightMode, isArabic, displayCycle),
                  SizedBox(height: 20.sp),
                ],

                UniversalCommentSection(
                  collectionPath: getBaseUrl(FirestoreCollections.commentsRoot),
                  filterFields: {
                    'Request_Id': widget.approvalModel.currentId,
                  },
                  currentUserId: AppControllers.employee
                      .employeeEntity!
                      .email!,
                  isExpandable: true,
                  fixedHeight: _isCommentExpanded
                      ? MediaQuery.of(context).size.height * 0.85
                      : MediaQuery.of(context).size.height,
                  onExpandChanged: (expanded) {
                    setState(() {
                      _isCommentExpanded = expanded;
                    });
                  },
                  style: CommentSectionStyle(
                    hintStyle: StyleText.fontSize16Weight400.copyWith(
                        color: AppColors.secondaryText.withOpacity(.5)),
                    commentTextStyle: StyleText.fontSize18Weight500
                        .copyWith(color: AppColors.text),
                    fileChipDecoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    fileIconColor: AppColors.text,
                    fileNameStyle: StyleText.fontSize12Weight400
                        .copyWith(color: AppColors.text),
                    avatarColor: AppColors.background,
                    inputFillColor: AppColors.card,
                    containerDecoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    commentItemDecoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8.r)),
                    userNameStyle: StyleText.fontSize16Weight400.copyWith(
                      color: AppColors.text,
                    ),
                    sendButtonDecoration: BoxDecoration(
                      color: AppColors.secondaryPrimary,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    sendIconColor: AppColors.secondaryPrimaryText,
                  ),
                ),

                if (!_isCommentExpanded) SizedBox(height: 20.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool lightMode, List<String> dropdownStates, Map<String, String> localizedLabels, bool isArabic) {
    return SizedBox(
      height: 50.sp,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            S.of(context).serviceDetails,
            style: StyleText.fontSize18Weight500.copyWith(
              color: lightMode ? AppColors.blackButton : AppColors.white,
            ),
          ),
          Spacer(),
          if (_shouldShowDropdown()) ...[
            _buildStatusDropdown(lightMode, dropdownStates, localizedLabels, isArabic),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusDropdown(bool lightMode, List<String> dropdownStates, Map<String, String> localizedLabels, bool isArabic) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SvgPicture.asset(
          "assets/icons_assets/main_icons_assets/status_pulse_line.svg",
          width: 12.sp,
          height: 12.sp,
          color: lightMode ? AppColors.blackButton : AppColors.white,
          fit: BoxFit.fill,
        ),
        SizedBox(width: 5.sp),
        Text(
          "${S.of(context).status}: ",
          style: StyleText.fontSize14Weight500.copyWith(
            color: lightMode ? AppColors.blackButton : AppColors.white,
          ),
        ),
        SizedBox(width: 4.sp),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            width: 135.sp,
            height: 30.sp,
            decoration: BoxDecoration(
              color: lightMode ? AppColors.white : AppColors.chatBackground,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: FormField<String>(
              initialValue: selectedState,
              builder: (FormFieldState<String> field) {
                final safeSelected = dropdownStates.contains(selectedState) ? selectedState : null;
                final uniqueDropdownStates = dropdownStates.toSet().toList();
                final effective = (safeSelected ?? currentState ?? '').toLowerCase();
                final isReadOnlyDone = effective == 'done';

                if (isReadOnlyDone) {
                  return IgnorePointer(
                    ignoring: true,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(horizontal: 12.sp),
                      child: Text(
                        (localizedLabels['done'] ?? 'Done'),
                        overflow: TextOverflow.ellipsis,
                        style: StyleText.fontSize12Weight400.copyWith(
                          color: _getStateColor('done'),
                        ),
                      ),
                    ),
                  );
                }

                return DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    value: safeSelected,
                    isExpanded: true,
                    dropdownStyleData: DropdownStyleData(
                      decoration: BoxDecoration(
                        color: lightMode ? AppColors.white : AppColors.chatBackground,
                      ),
                      elevation: 2,
                      offset: const Offset(0, 0),
                    ),
                    items: uniqueDropdownStates.map((e) {
                      return DropdownMenuItem<String>(
                        value: e,
                        child: Text(
                          localizedLabels[e] ?? e,
                          style: StyleText.fontSize12Weight400.copyWith(
                            color: _getStateColor(e),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      if (value == null) return;
                      // ⚠️ NOT `addPostFrameCallback` — see [_applyStateChange].
                      // A zero-duration timer resumes on a fresh event-loop
                      // turn, AFTER the frame has fully finished, rather than
                      // inside the frame's post-frame callback list where the
                      // mouse tracker's own update is queued.
                      Future<void>.delayed(Duration.zero, () {
                        if (!mounted) return;
                        _applyStateChange(value);
                      });
                    },
                    hint: Padding(
                      padding: isArabic ? EdgeInsets.only(top: 4) : EdgeInsets.zero,
                      child: Text(
                            () {
                          final rawState = safeSelected ?? currentState ?? '';
                          final currentDisplayState = rawState.isEmpty ? 'approve' : rawState;
                          final lowerState = currentDisplayState.toLowerCase();

                          switch (lowerState) {
                            case 'approve':
                            case 'approved':
                              return S.of(context).status_approved;
                            case 'inprogress':
                              return S.of(context).sm_inprogress;
                            case 'done':
                              return S.of(context).sm_done;
                            default:
                              return localizedLabels[lowerState] ?? 'Approved';
                          }
                        }(),
                        style: StyleText.fontSize10Weight400.copyWith(
                          color: currentState == "inprogress"
                              ? AppColors.pending
                              : currentState == "done"
                              ? AppColors.green
                              : AppColors.green,
                        ),
                      ),
                    ),
                    iconStyleData: IconStyleData(
                      icon: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.sp),
                        child: SvgPicture.asset(
                          'assets/icons_assets/main_icons_assets/chevron_down.svg',
                          width: 20.sp,
                          height: 20.sp,
                          fit: BoxFit.fill,
                          color: lightMode ? AppColors.secondaryText : AppColors.whiteShadow,
                        ),
                      ),
                    ),
                    style: StyleText.fontSize12Weight400.copyWith(
                      color: lightMode ? AppColors.blackButton : AppColors.white,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(bool isMobile, bool lightMode, bool isArabic, List<EmployeeEntityModell> displayCycle) {
    return Container(
      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: lightMode ? AppColors.white : AppColors.chatBackground,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildServiceHeader(isMobile, lightMode, isArabic),
          SizedBox(height: 20.h),
          if (isMobile) ...[
            _buildDescriptionWidget(isMobile, lightMode, isArabic),
            SizedBox(height: 20.sp),
          ],
          _buildProviderSection(lightMode),
          SizedBox(height: 29.sp),
           _buildRequesterDetails(lightMode, isArabic),
          SizedBox(height: 20.h),
          if (widget.approvalModel.currentApprovalCycle.isNotEmpty) ...[
            _buildApprovalCycleHeader(lightMode),
            SizedBox(height: 15.h),
            _buildApprovalCycleContent(isMobile, displayCycle),
          ],
        ],
      ),
    );
  }

  Widget _buildServiceHeader(bool isMobile, bool lightMode, bool isArabic) {
    return Row(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Container(
          width: isMobile ? 40.sp : !_isTabletLandscape(context) ? 80.sp : 100.sp,
          height: isMobile ? 40.sp : !_isTabletLandscape(context) ? 80.sp : 100.sp,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: lightMode ? AppColors.background : AppColors.background,
          ),
          child: Center(
            child: SvgPicture.asset(
              color: lightMode ? AppColors.secondaryText : AppColors.grey,
              "assets/icons_assets/services_assets/headset_support.svg",
              width: isMobile ? 20.sp : !_isTabletLandscape(context) ? 40.sp : 48.sp,
              height: isMobile ? 20.sp : !_isTabletLandscape(context) ? 40.sp : 48.sp,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isMobile
                  ? Text(
                isArabic
                    ? widget.approvalModel.currentServiceNameArabic
                    : widget.approvalModel.currentServiceNameEnglish,
                style: StyleText.fontSize14Weight400.copyWith(
                  color: lightMode ? AppColors.blackButton : AppColors.white,
                ),
              )
                  : _buildDescriptionWidget(isMobile, lightMode, isArabic),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionWidget(bool isMobile, bool lightMode, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              // Services mobile QA p.32: the three-lines glyph read as a menu /
              // sort icon. Same document-description icon Knowledge Hub uses;
              // QA p.27: the label now ends with ":" like every other row.
              "assets/icons_assets/knowledge_hub_assets/document_description_icon.svg",
              width: isMobile ? 16.w : 14.sp,
              height: isMobile ? 16.h : 14.sp,
              color: AppColors.secondaryText,
              fit: isMobile ? BoxFit.scaleDown : BoxFit.fill,
            ),
            SizedBox(width: 3.sp),
            Text(
              "${S.of(context).serviceDescription}:",
              style: isMobile
                  ? StyleText.fontSize12Weight400.copyWith(
                color: AppColors.secondaryText,
              )
                  : StyleText.fontSize14Weight400.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
        SizedBox(height: 5.h),
        Text(
          FormatHelper.capitalize(
            isArabic
                ? widget.approvalModel.currentServiceDescriptionArabic
                : widget.approvalModel.currentServiceDescriptionEnglish,
          ),
          style: isMobile
              ? StyleText.fontSize10Weight400.copyWith(
            wordSpacing: -1.sp,
            color: lightMode ? AppColors.blackButton : AppColors.white,
          )
              : StyleText.fontSize13Weight500.copyWith(color: AppColors.secondaryBlack).copyWith(
            color: lightMode ? AppColors.blackButton : AppColors.white,
          ),
          textAlign: TextAlign.start,
          softWrap: true,
          overflow: isMobile ? TextOverflow.visible : TextOverflow.clip,
        ),
      ],
    );
  }

  Widget _buildProviderSection(bool lightMode) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _providerFuture ??= _computeProvider(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  shimmerPlaceholder(context, width: 200, height: 20),
                  SizedBox(height: 10.h),
                  shimmerPlaceholder(context, width: 150, height: 20),
                  SizedBox(height: 10.h),
                  shimmerPlaceholder(context, width: 180, height: 20),
                ],
              ),
              if (!ContextExtension(context).isPhone)
                SizedBox(
                  width: !_isTabletLandscape(context)
                      ? MediaQuery.sizeOf(context).width * .05
                      : MediaQuery.sizeOf(context).width * .1,
                ),
              if (!ContextExtension(context).isPhone)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    shimmerPlaceholder(context, width: 160, height: 20),
                    SizedBox(height: 10.h),
                    shimmerPlaceholder(context, width: 140, height: 20),
                    SizedBox(height: 10.h),
                    shimmerPlaceholder(context, width: 180, height: 20),
                  ],
                ),
            ],
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          final provider = snapshot.data!;
          return buildProviderDetailsSectionMaster(
            onTap: () {
              navigateTo(
                context,
                ServicesProviderLayout(
                  editingModel: widget.approvalModel,
                  docId: widget.approvalModel.currentId,
                  editProvider: widget.approvalModel,
                ),
              );
            },
            table: true,
            context: context,
            duration: widget.approvalModel.currentDurationOfServices,
            durationUnit: widget.approvalModel.currentSelectedDurationUnit,
            durationTimeStamp: widget.approvalModel.currentDurationOfServicesTimestamp,
            approvalCycle: widget.approvalModel.currentApprovalCycle,
            model: widget.approvalModel.currentProviderServices.first,
            state: currentState ?? 'pending', // 👈 Add this
          );
        } else {
          return Center(
            child: Text(S.of(context).Noproviderdatafound),
          );
        }
      },
    );
  }

  Widget _buildRequesterDetails(bool lightMode, bool isArabic) {
    return buildRequesterDetailsSection(
      context: context,
      lightMode: lightMode,
      isTabletLandscape: _isTabletLandscape(context),
      firstNameRequester: globalFirstNameRequester,
      lastNameRequester: globalLastNameRequester,
      jobTitleRequester: globalJobTitleRequester,
      departmentName: _getDepartmentNameFromId(
        widget.approvalModel.currentDepartmentRequester,
      ),
    );
  }

  Widget _buildApprovalCycleHeader(bool lightMode) {
    return buildApprovalCycleHeaderSection(context: context, lightMode: lightMode);
  }

  Widget _buildApprovalCycleContent(bool isMobile, List<EmployeeEntityModell> displayCycle) {
    return buildApprovalCycleContentSection(
      context: context,
      isMobile: isMobile,
      displayCycle: displayCycle,
    );
  }
}

// Extension for copyWith on EmployeeEntityModel
