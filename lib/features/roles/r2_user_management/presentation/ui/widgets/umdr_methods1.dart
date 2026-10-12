/// Module: roles / r2_user_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: umdr_methods1.dart
/// Purpose: Declares `UmdrMethods1`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 25/8/2026 - Approve confirm dialog opens on approved.json.

part of '../pages/user_management_details_request.dart';

extension UmdrMethods1 on _UserManagementDetailsRequestSettingsState {
  Future<void> _fetchCompleteRequestData() async {
    try {
      if (widget.requestId == null || widget.requestId!.isEmpty) {
        setState(() => isLoading = false);
        return;
      }

      final String basePath = getBaseUrl('Modules');
      final docSnapshot = await FirebaseFirestore.instance
          .doc('$basePath/roles')
          .collection(FirebaseCollections.employeesRequest)
          .doc(widget.requestId)
          .get();

      if (!docSnapshot.exists) {
        setState(() => isLoading = false);
        return;
      }

      completeRequestData = docSnapshot.data();
      _initializeWithCompleteData();
    } catch (e) {
      setState(() => isLoading = false);
    }
  }
  void _initializeWithCompleteData() {
    if (completeRequestData == null) {
      setState(() => isLoading = false);
      return;
    }

    createdByEmail = completeRequestData!['employeeEmail'] ?? '';
    createdByID = completeRequestData!['employeeId'] ?? '';
    status = completeRequestData!['status'] ?? 'pending';
    section = completeRequestData!['section'] ?? 'Personal Information';

    final requestDate = completeRequestData!['requestDate'];
    if (requestDate != null) {
      if (requestDate is int) {
        requestTime = requestDate;
      } else if (requestDate is Timestamp) {
        requestTime = requestDate.millisecondsSinceEpoch;
      }
    }

    requestNoteController.text = FormatHelper.capitalize(
        completeRequestData!['requestNote']?.toString() ?? '');

    _parseChanges();
    setState(() => isLoading = false);
  }
  void _parseChanges() {
    try {
      final changesData = completeRequestData!['changes'];

      if (changesData is List && changesData.isNotEmpty) {
        changes = changesData.map((change) {
          if (change is Map) {
            return {
              'fieldName': change['fieldName']?.toString() ?? '',
              'oldValue': change['oldValue']?.toString() ?? '',
              'newValue': change['newValue']?.toString() ?? '',
            };
          }
          return <String, String>{};
        }).where((c) => c['fieldName']?.isNotEmpty == true).toList();
      } else {
        final whatChanged =
            completeRequestData!['whatChanged']?.toString().trim() ?? '';
        final oldValue = completeRequestData!['oldValue']?.toString() ?? '';
        final newValue = completeRequestData!['newValue']?.toString() ?? '';

        if (whatChanged.isNotEmpty) {
          changes = [
            {'fieldName': whatChanged, 'oldValue': oldValue, 'newValue': newValue}
          ];
        } else {
          changes = [];
        }
      }
    } catch (e) {
      changes = [];
    }
  }
  String _mapFieldName(String requestFieldName) =>
      userManagementController.mapFieldName(requestFieldName);

  // REMOVED 24/8/2026: `_updateEmployeeData` and `_mergedMobilePhone`.
  //
  // This screen carried its own copy of the approval write — read the employee
  // document, fold every change into `NewEmployeeModelHistory`, merge the
  // phone members, write it back. `RequestsRemoteDataSource
  // .applyChangesToEmployee` is the same routine, and the two had already
  // drifted: the data source skips a field the model cannot store and reports
  // it, while this copy let the first `ArgumentError` abort the loop and lose
  // every other change in the batch.
  //
  // The decision now goes through `RequestsCubit.approve`, which runs that one
  // shared routine, so the profile write and the notification happen in the
  // same place for both approval screens. See [_updateRequestStatus].

  // REMOVED 12/8/2026: dead code (analyzer: unused member, 0 call sites).

  /// Function Name: [_updateRequestStatus]
  ///
  /// Purpose: Record the reviewer's decision on this request.
  ///
  /// REWRITTEN 24/8/2026 — this is the fix for "approving from User Management
  /// notifies nobody".
  ///
  /// This method used to apply the employee profile itself and then write
  /// `status` straight onto the request document. It never touched
  /// `RequestsCubit`, so it could not reach `SettingsNotificationService`: the
  /// employee heard nothing when their request was approved or rejected, while
  /// the same decision taken from `settings/se6_requests/details_request.dart`
  /// did notify. Two decision paths, one of them silent.
  ///
  /// It now dispatches to the cubit, which is the single choke point every
  /// decision passes through — `_finishDecision` → `_notifyEmployee`. That also
  /// buys the profile write that skips an unwritable field instead of throwing
  /// away the rest of the batch, and the guard that leaves a request pending
  /// when nothing could be applied.
  ///
  /// Parameters:
  /// - [newStatus]: the wire value of the decision, `'approved'` or
  ///   `'rejected'`.
  ///
  /// Returns: [Future<bool>] whether the decision was actually recorded, so
  ///          `CustomDialogManager` only shows its success dialog on a real
  ///          success.
  Future<bool> _updateRequestStatus(String newStatus) async {
    if (widget.requestId == null || widget.requestId!.isEmpty) return false;

    final Map<String, dynamic>? data = completeRequestData;
    if (data == null) return false;

    setState(() => isProcessing = true);

    // Read before the first await — `context` must not be touched afterwards.
    final bool isArabic = context.isArabic;
    final MainCoreEmployeeController employeeController =
        AppControllers.employee;

    // Who is acting. The cubit sends this as the notification's sender; with
    // no email it skips the notification rather than sending from nobody.
    // 9/10/2026: the same email + id also feed the repository's
    // self-approval check — no email means the decision is refused.
    final String approverEmail = employeeController.employeeEntity?.email ?? '';
    final String approverEmployeeId =
        employeeController.employeeEntity?.id ?? '';
    // Read before the first await, like isArabic (9/10/2026).
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final ChangeRequest request =
        ChangeRequestMapper.fromDocument(widget.requestId!, data);
    final RequestStatus decision = RequestStatus.fromWire(newStatus);

    final bool ok;
    if (decision == RequestStatus.approved) {
      // The request stores the submitter's employee id, but older documents
      // may not; fall back to the directory lookup this screen already does
      // for the creator's name and photo.
      final String employeeId = request.employeeId.isNotEmpty
          ? request.employeeId
          : (employeeController.getLocaleEmployee(createdByEmail)?.id ?? '');

      ok = await _requestsCubit.approve(
        request: request,
        employeeId: employeeId,
        approverEmail: approverEmail,
        approverEmployeeId: approverEmployeeId,
        isArabic: isArabic,
        approvalReason: rejectionReasonController.text.trim(),
      );
    } else {
      ok = await _requestsCubit.setStatus(
        request,
        decision,
        approverEmail: approverEmail,
        approverEmployeeId: approverEmployeeId,
        isArabic: isArabic,
        rejectionReason: rejectionReasonController.text.trim(),
      );
    }

    // ADDED 9/10/2026 — a blocked self-approval says why (EN/AR). Other
    // failures keep the old behaviour (the dialog flow simply stops).
    final String? blockedMessage = _requestsCubit.state.userMessage;
    if (!ok && blockedMessage != null && blockedMessage.isNotEmpty) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(blockedMessage),
            backgroundColor: AppColors.signOut,
            behavior: SnackBarBehavior.floating,
          ),
        );
    }

    if (ok && decision == RequestStatus.approved) {
      // Firestore now holds the new values, but the profile screens are served
      // from MainCoreEmployeeController's in-memory mapOfEmployeesWithEmailKey
      // — without this refresh the employee keeps seeing the old data until the
      // app restarts. Same refresh social_screen.dart performs after it saves.
      await employeeController.getAllNewEmployees();
      employeeController.update(<String>['employee_profile']);
    }

    if (!mounted) return ok;

    setState(() {
      isProcessing = false;
      if (ok) status = decision.wireValue;
    });

    // No snackbar either way: CustomDialogManager shows a success dialog on
    // true and stops before its success step on false, which is the
    // user-facing signal.
    _requestsCubit.clearMessages();
    return ok;
  }
  // ─── Confirmation dialog via CustomDialogManager ─────────────────────────
  //
  // UPDATED 24/8/2026: rejecting now asks why, and the hardcoded English
  // strings became l10n keys — an Arabic reviewer was reading "Approve
  // Request" and "Are you sure you want to approve this request?" in English.
  // Every key used below already existed in `l10n.dart`.
  //
  // The reason is collected by the flow's own comment step, which runs BEFORE
  // `onConfirm`, so `rejectionReasonController` is filled by the time
  // [_updateRequestStatus] reads it. `commentRequired` disables the submit
  // button until something is typed, so the employee can never be told their
  // request was rejected for an empty reason. Discarding that step aborts the
  // rejection entirely — nothing is written.
  Future<void> _showConfirmDialog({required String action}) async {
    final isApprove = action == 'approved';

    // A stale reason from a dialog the reviewer opened and dismissed must not
    // attach itself to the next rejection.
    // (Since 30/9/2026 the same controller also carries the approval reason.)
    rejectionReasonController.clear();

    await CustomDialogManager.showDialogFlow(
      context: context,

      // ── Confirm step ──────────────────────────────────────────────────────
      //
      // CHANGED 25/8/2026: approving now opens on `approved.json` instead of
      // the amber `lottie_warning.json`. Rejecting keeps the warning — that
      // one IS the cautionary action, and an approval tick over "are you sure
      // you want to reject this request?" would read as the wrong answer.
      confirmLottie: isApprove
          ? 'assets/lottie_assets/main_lottie_assets/approved.json'
          : 'assets/lottie_assets/main_lottie_assets/lottie_warning.json',
      confirmTitle: isApprove
          ? S.of(context).approveRequest
          : S.of(context).rejectRequest,
      confirmSubtitle: isApprove
          ? S.of(context).areYouSureYouWantToApproveThisRequest
          : S.of(context).areYouSureYouWantToRejectThisRequest,
      confirmYesText: S.of(context).yes,
      confirmNoText: S.of(context).no,

      // ── Reason step ───────────────────────────────────────────────────────
      // Role QA p.34: approving asked for no reason at all. Both decisions now
      // open the reason dialog; it is required for a rejection and optional
      // for an approval.
      comment: true,
      commentRequired: !isApprove,
      commentController: rejectionReasonController,
      commentSubmitText: S.of(context).submit,
      commentDiscardText: S.of(context).discard,
      customReasonTitle: isApprove
          ? S.of(context).reasonOfApproval
          : S.of(context).reasonOfRejection,

      // ── What happens once the reviewer has confirmed (and given a reason) ─
      onConfirm: () => _updateRequestStatus(action),

      // ── Success step ──────────────────────────────────────────────────────
      successLottie: 'assets/lottie_assets/main_lottie_assets/approved.json',
      successTitle: isApprove
          ? S.of(context).requestApproved
          : S.of(context).requestRejected,
      successSubtitle: isApprove
          ? S.of(context).theRequestHasBeenApprovedSuccessfully
          : S.of(context).theRequestHasBeenRejectedSuccessfully,
    );
  }
  String _translateSectionTitle(String englishTitle) =>
      userManagementController.translateSectionTitle(englishTitle,
          isArabic: context.isArabic);

  String _formatDate(int timestamp) =>
      userManagementController.formatDate(timestamp);

  Color _getStatusColor(String status) =>
      userManagementController.getStatusColor(status);

  String _getStatusIcon(String status) =>
      userManagementController.getStatusIcon(status);

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return S.of(context).Approved;
      case 'pending':
        return S.of(context).Pending;
      case 'rejected':
        return S.of(context).Rejected;
      default:
        return status;
    }
  }
  String _getFieldLabel(String fieldKey) {
    final labelMap = {
      'first_name': S.of(context).firstName,
      'middle_name': S.of(context).middleName,
      'last_name': S.of(context).lastName,
      'street': S.of(context).streetName,
      'city': S.of(context).city,
      'province': S.of(context).stateOrProvince,
      'country': S.of(context).country,
      'email': S.of(context).email,
      'phone': S.of(context).phoneNumber,
      'gender': S.of(context).gender,
      'date_of_birth': S.of(context).birthday,
      'marital_status': S.of(context).maritalStatus,
      'relationship': S.of(context).relationship,
      'language': S.of(context).language,
      'insurance_name': 'Insurance Name',
      'insurance_policy_number': 'Insurance Policy Number',
    };

    // The emergency-contact fields arrive as firstContact* / secondContact*.
    // The contact they belong to is already obvious from the section, so the
    // prefix is dropped for EVERY field rather than spelled out in the label
    // ("Secondcontact Street" → "Street").
    final String bareKey = _toSnakeCase(_stripContactPrefix(fieldKey));

    return labelMap[bareKey] ?? _formatFieldName(bareKey);
  }

  /// Removes a leading firstContact / secondContact marker in any of the
  /// spellings the data uses: `secondContact_street`, `secondContactStreet`,
  /// `second_contact_street`.
  String _stripContactPrefix(String fieldKey) {
    final match = RegExp(
      r'^(first|second)_?contact_?',
      caseSensitive: false,
    ).firstMatch(fieldKey);

    if (match == null) return fieldKey;

    final stripped = fieldKey.substring(match.end);
    // Guard against a key that is nothing but the prefix.
    return stripped.isEmpty ? fieldKey : stripped;
  }

  /// `InsurancePolicyNumber` / `insurancePolicyNumber` → `insurance_policy_number`
  /// so camelCase and snake_case keys hit the same map entry.
  String _toSnakeCase(String value) => value
      .replaceAllMapped(
        RegExp(r'([a-z0-9])([A-Z])'),
        (m) => '${m[1]}_${m[2]}',
      )
      .toLowerCase();

  String _formatFieldName(String fieldKey) =>
      userManagementController.formatFieldName(fieldKey);
}
