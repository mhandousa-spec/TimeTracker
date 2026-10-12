/// Module: Policy Management
/// Description: BLoC Cubit that manages Policy state for the presentation
///              layer. Delegates all operations to the corresponding use
///              cases and emits typed [PolicyState] subclasses. Still holds
///              a direct dependency on CreateControlUseCase/
///              UpdateControlUseCase/DeleteControlUseCase for
///              createPolicy/saveAsDraft/updatePolicyWithControls, which
///              treat "Policy + its bundled initial Controls" as one wizard
///              action — that's a Policy-workflow concern, not Control
///              state, so it stays here rather than moving to ControlCubit
///              (see docs/superpowers/specs/2026-07-28-control-cubit-extraction-design.md).
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-05
/// Dependencies: flutter_bloc, use cases, PolicyEntity, ControlEntity
/// Revision History: 2026-07-05 - Initial creation
///                   2026-07-06 - Added saveAsDraft and status-aware methods
///                   2026-07-14 - Reworked for the new schema: Policy
///                                creation no longer bundles Controls at the
///                                repository level (see
///                                _createPolicyWithControls for the
///                                orchestration), split single document
///                                fields into En/Ar
///                   2026-07-28 - Extracted the standalone Control methods
///                                (createControl/updateControl/
///                                deleteControl/getAllControls) and the
///                                two ControlStatus business-rule helpers
///                                into ControlCubit/ControlStatus
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/grc/policy/data/services/grc_policy_notification_service.dart';
import 'package:knowticed_plus/features/grc/shared/services/grc_notification_support.dart';

import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_status.dart';

import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_status.dart';
import 'package:knowticed_plus/features/grc/control/domain/use_cases/create_control_usecase.dart';
import 'package:knowticed_plus/features/grc/policy/domain/use_cases/create_policy_usecase.dart';
import 'package:knowticed_plus/features/grc/control/domain/use_cases/get_control_usecases.dart';
import 'package:knowticed_plus/features/grc/policy/domain/use_cases/get_policy_usecases.dart';
import 'package:knowticed_plus/features/grc/control/domain/use_cases/update_control_usecase.dart';
import 'package:knowticed_plus/features/grc/policy/domain/use_cases/update_policy_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

part 'policy_state.dart';

/// class name: [PendingControlInput]
///
/// purpose: groups the fields needed to create one Control alongside a new
///          Policy, before that Policy's id exists yet.
///          [PolicyCubit.createPolicy]/[PolicyCubit.saveAsDraft] resolve
///          moduleId/policyId/editorId for each of these once the Policy
///          itself has been created, then forward the rest to
///          [CreateControlUseCase].
class PendingControlInput {
  final String controlsNameEn;
  final String controlsNameAr;
  final String controlsNumberEn;
  final String controlsNumberAr;
  final String controlsDescriptionEn;
  final String controlsDescriptionAr;
  final double controlsWeight;
  final String frequency;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> departments;
  final bool equalWeights;
  final int score;
  final ControlStatus status;
  final File? controlsDocumentFileEn;
  final String? controlsDocumentUrlEn;
  final File? controlsDocumentFileAr;
  final String? controlsDocumentUrlAr;

  /// Non-null when this input represents a Control that already exists in
  /// Firestore — [PolicyCubit.updatePolicyWithControls] updates it in place
  /// via this id instead of creating a duplicate.
  final String? existingControlId;

  const PendingControlInput({
    required this.controlsNameEn,
    required this.controlsNameAr,
    required this.controlsNumberEn,
    required this.controlsNumberAr,
    required this.controlsDescriptionEn,
    required this.controlsDescriptionAr,
    required this.controlsWeight,
    required this.frequency,
    required this.startDate,
    required this.endDate,
    required this.departments,
    required this.equalWeights,
    required this.score,
    required this.status,
    this.controlsDocumentFileEn,
    this.controlsDocumentUrlEn,
    this.controlsDocumentFileAr,
    this.controlsDocumentUrlAr,
    this.existingControlId,
  });
}

/// class name: [PolicyCubit]
///
/// purpose: manage all Policy and Control UI state. Each public method maps
///          to one use case (or, for [createPolicy]/[saveAsDraft], two —
///          Policy then Controls) and follows the pattern: emit
///          [PolicyLoading] → call use case(s) → emit a success state or
///          [PolicyFailure].
class PolicyCubit extends Cubit<PolicyState> {
  PolicyCubit({
    required CreatePolicyUseCase createPolicyUseCase,
    required GetPolicyUseCase getPolicyUseCase,
    required GetAllPoliciesUseCase getAllPoliciesUseCase,
    required UpdatePolicyUseCase updatePolicyUseCase,
    required DeletePolicyUseCase deletePolicyUseCase,
    required RestorePolicyUseCase restorePolicyUseCase,
    required CreateControlUseCase createControlUseCase,
    required UpdateControlUseCase updateControlUseCase,
    required DeleteControlUseCase deleteControlUseCase,
    required GetAllControlsUseCase getAllControlsUseCase,
  })  : _createUseCase = createPolicyUseCase,
        _getUseCase = getPolicyUseCase,
        _getAllUseCase = getAllPoliciesUseCase,
        _updateUseCase = updatePolicyUseCase,
        _deleteUseCase = deletePolicyUseCase,
        _restoreUseCase = restorePolicyUseCase,
        _createControlUseCase = createControlUseCase,
        _updateControlUseCase = updateControlUseCase,
        _deleteControlUseCase = deleteControlUseCase,
        _getAllControlsUseCase = getAllControlsUseCase,
        super(PolicyInitial());

  final CreatePolicyUseCase _createUseCase;
  final GetPolicyUseCase _getUseCase;
  final GetAllPoliciesUseCase _getAllUseCase;
  final UpdatePolicyUseCase _updateUseCase;
  final DeletePolicyUseCase _deleteUseCase;
  final RestorePolicyUseCase _restoreUseCase;
  final CreateControlUseCase _createControlUseCase;
  final UpdateControlUseCase _updateControlUseCase;
  final DeleteControlUseCase _deleteControlUseCase;
  final GetAllControlsUseCase _getAllControlsUseCase;

  /// Resolves the currently logged-in user's email.
  String get _currentUserEmail {
    final fromConstant = Constant.emailUser;
    if (fromConstant != null && fromConstant.isNotEmpty) return fromConstant;
    if (Get.isRegistered<MainCoreEmployeeController>()) {
      final email = Get.find<MainCoreEmployeeController>().employeeEntity?.email;
      if (email != null && email.isNotEmpty) return email;
    }
    return '';
  }

  // ================================================================
  // NOTIFICATIONS
  // ================================================================

  bool get _isArabic => Get.locale?.languageCode == 'ar';

  /// Dates in notification bodies read the way the rest of GRC writes them.
  String _fmtDate(DateTime d) =>
      DateFormat('d MMM yyyy', _isArabic ? 'ar' : 'en').format(d);

  /// Who hears about a policy: the owners of the module it belongs to.
  ///
  /// A policy has no owners of its own, and the module owners are already the
  /// audience for module-level GRC notifications and for the GRC calendar, so
  /// this keeps GRC to one audience. The actor is removed — they just did the
  /// thing and do not need telling.
  ///
  /// The owners are passed IN rather than fetched: every caller already holds
  /// the GRCModuleEntity, so fetching here would be a second read of a
  /// document the UI has in hand. The cost is that a caller which forgets to
  /// pass them silently notifies nobody, which is exactly the failure the
  /// debugPrint below exists to name.
  Set<String> _policyAudience(Iterable<String> moduleOwners) {
    final Set<String> audience = <String>{
      ...moduleOwners.where((String e) => e.isNotEmpty),
    }..remove(_currentUserEmail);

    debugPrint('[grc-policy-notify] owners=${moduleOwners.toList()} '
        'actor="$_currentUserEmail" -> audience=$audience');

    return audience;
  }

  /// Runs a send without letting it affect the action that triggered it.
  ///
  /// A notification that fails must never turn a saved policy into a failed
  /// one, so this is fire-and-forget with its own error handling — the same
  /// shape GrcModuleCubit._notify uses.
  void _notify(Future<int> Function() send) {
    unawaited(
      send().then((int sent) {
        debugPrint('[grc-policy-notify] send resolved: $sent recipient(s). '
            'actor=$_currentUserEmail (the actor is never a recipient)');
        return sent;
      }).catchError((Object e, StackTrace st) {
        debugPrint('[grc-policy-notify] send failed - $e\n$st');
        return 0;
      }),
    );
  }

  /// Every notification a freshly saved policy should produce.
  ///
  /// Called from both create paths. [isDraft] suppresses the lot: a draft is
  /// not an announcement, and the spec's events all describe a policy that
  /// exists for other people.
  void _notifyPolicyCreated({
    required PolicyEntity policy,
    required String moduleName,
    required Iterable<String> moduleOwners,
    required bool isDraft,
  }) {
    if (isDraft) return;
    if (moduleName.isEmpty) {
      debugPrint('[grc-policy-notify] no moduleName passed - '
          'policyCreated not sent for "${policy.policyNameEn}".');
      return;
    }
    final Set<String> audience = _policyAudience(moduleOwners);
    if (audience.isEmpty) return;

    _notify(() => GrcPolicyNotificationService.policyCreated(
          actorEmail: _currentUserEmail,
          policyName: policy.policyNameEn,
          moduleName: moduleName,
          recipients: audience,
          isArabic: _isArabic,
        ));

    // Policy Scheduled for Activation - only when the start date is still
    // ahead. A policy that starts today is already active; announcing it as
    // "scheduled" would be wrong.
    final DateTime now = DateTime.now();
    final DateTime startOfToday = DateTime(now.year, now.month, now.day);
    if (policy.startDate.isAfter(startOfToday)) {
      _notify(() => GrcPolicyNotificationService.policyScheduledForActivation(
            actorEmail: _currentUserEmail,
            policyName: policy.policyNameEn,
            startDate: _fmtDate(policy.startDate),
            recipients: audience,
            isArabic: _isArabic,
          ));
    }
  }

  /// Every notification an edited policy should produce, by comparing the
  /// saved result against what it looked like before.
  ///
  /// [previous] null means the caller could not supply the old values, so
  /// nothing that needs a before/after is sent rather than guessing.
  void _notifyPolicyUpdated({
    required String moduleId,
    required PolicyEntity? previous,
    required PolicyEntity after,
    required Iterable<String> moduleOwners,
  }) {
    if (previous == null) return;
    // A draft is not an announcement (same rule as _notifyPolicyCreated).
    if (after.status == PolicyStatus.draft) return;
    final Set<String> audience = _policyAudience(moduleOwners);
    if (audience.isEmpty) return;

    // Publishing a draft is the moment the policy comes into existence for
    // everyone else, so it is announced as "created", not "updated".
    if (previous.status == PolicyStatus.draft) {
      final List<String> owners = moduleOwners.toList();
      GrcNotify.run('policy-published', () async {
        final module = await GrcNotify.module(moduleId);
        _notifyPolicyCreated(
          policy: after,
          moduleName: module?.moduleNameEn ?? '',
          moduleOwners: owners,
          isDraft: false,
        );
      });
      return;
    }

    // Policy Activated / Deactivated — the manual status switch.
    final bool wasInactive = previous.status == PolicyStatus.inactive;
    final bool isInactive = after.status == PolicyStatus.inactive;
    if (wasInactive != isInactive) {
      _notify(() => GrcPolicyNotificationService.policyStatusChanged(
            actorEmail: _currentUserEmail,
            policyName: after.policyNameEn,
            isNowActive: !isInactive,
            recipients: audience,
            isArabic: _isArabic,
          ));
    }

    // Policy Updated/Edited — any content change. Date / weight moves have
    // their own events below and are not double-announced here.
    final bool contentChanged = previous.policyNameEn != after.policyNameEn ||
        previous.policyNameAr != after.policyNameAr ||
        previous.policyNumberEn != after.policyNumberEn ||
        previous.policyDescriptionEn != after.policyDescriptionEn ||
        previous.policyDescriptionAr != after.policyDescriptionAr ||
        previous.policyDocumentEn != after.policyDocumentEn ||
        previous.policyDocumentAr != after.policyDocumentAr;
    if (contentChanged) {
      final String actor = _currentUserEmail;
      final bool isArabic = _isArabic;
      GrcNotify.run('policy-updated', () async {
        final module = await GrcNotify.module(moduleId);
        GrcNotify.fire(
          'policy-updated',
          () => GrcPolicyNotificationService.policyUpdated(
            actorEmail: actor,
            policyName: after.policyNameEn,
            moduleName: module?.moduleNameEn ?? '',
            recipients: audience,
            isArabic: isArabic,
          ),
        );
      });
    }

    if (!_isSameDay(previous.startDate, after.startDate)) {
      _notify(() => GrcPolicyNotificationService.activationDateUpdated(
            actorEmail: _currentUserEmail,
            policyName: after.policyNameEn,
            oldStartDate: _fmtDate(previous.startDate),
            newStartDate: _fmtDate(after.startDate),
            recipients: audience,
            isArabic: _isArabic,
          ));
    }

    if (!_isSameDay(previous.endDate, after.endDate)) {
      _notify(() => GrcPolicyNotificationService.expirationDateUpdated(
            actorEmail: _currentUserEmail,
            policyName: after.policyNameEn,
            oldEndDate: _fmtDate(previous.endDate),
            newEndDate: _fmtDate(after.endDate),
            recipients: audience,
            isArabic: _isArabic,
          ));
    }

    if (previous.policyWeight != after.policyWeight) {
      _notify(() => GrcPolicyNotificationService.policyWeightUpdated(
            actorEmail: _currentUserEmail,
            policyName: after.policyNameEn,
            recipients: audience,
            isArabic: _isArabic,
          ));
    }

    // Policy Expired - fired on the edit that first makes it expired.
    //
    // LIMITATION, deliberately left visible: a policy that expires while
    // nobody is editing it produces no notification, because no code runs at
    // that moment. The calendar covers that case
    // (GrcPolicyCalendarEvent.expiresToday); a true "it expired overnight"
    // push needs a scheduled job, which this app does not have yet.
    if (previous.status != PolicyStatus.expired &&
        after.status == PolicyStatus.expired) {
      _notify(() => GrcPolicyNotificationService.policyExpired(
            actorEmail: _currentUserEmail,
            policyName: after.policyNameEn,
            recipients: audience,
            isArabic: _isArabic,
          ));
    }
  }

  /// Control Added to Policy.
  void _notifyControlAdded({
    required String controlName,
    required String policyName,
    required Iterable<String> moduleOwners,
  }) {
    if (controlName.trim().isEmpty) return;
    final Set<String> audience = _policyAudience(moduleOwners);
    if (audience.isEmpty) return;
    _notify(() => GrcPolicyNotificationService.controlAddedToPolicy(
          actorEmail: _currentUserEmail,
          controlName: controlName,
          policyName: policyName,
          recipients: audience,
          isArabic: _isArabic,
        ));
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // ================================================================
  // GET ALL / GET SINGLE
  // ================================================================

  Future<void> getAllPolicies({
    required String moduleId,
    bool includeRemoved = false,
  }) async {
    emit(PolicyLoading());
    final result = await _getAllUseCase.call(
      moduleId: moduleId,
      includeRemoved: includeRemoved,
    );
    await result.fold(
      (failure) async => emit(PolicyFailure(failure.message)),
      (policies) async {
        // Emit the list first so the cards paint immediately; the Controls
        // pass below is one extra read per policy and must not hold up the
        // page.
        emit(PolicyListLoaded(policies));
        await _loadControlsSummaries(moduleId: moduleId, policies: policies);
      },
    );
  }

  /// function name: [_loadControlsSummaries]
  ///
  /// purpose: fill in the "No of Controls" and "Departments" the policy list
  ///          card draws. Neither lives on the policy document -- Controls
  ///          are a subcollection under each policy -- so this reads one
  ///          Controls collection per policy and re-emits [PolicyListLoaded]
  ///          with the result attached.
  ///
  /// Failures are swallowed on purpose: a policy whose Controls cannot be
  /// read keeps its card, minus those two lines. The list itself already
  /// loaded, and turning the whole page into an error over a secondary
  /// detail would be worse than showing "-".
  ///
  /// parameters:
  ///            [String] moduleId: the module the policies belong to
  ///            [List<PolicyEntity>] policies: the policies just loaded
  ///
  /// return type: [Future<void>]
  Future<void> _loadControlsSummaries({
    required String moduleId,
    required List<PolicyEntity> policies,
  }) async {
    if (policies.isEmpty) return;

    final summaries = <String, PolicyControlsSummary>{};

    // Nothing in here may escape. The policy list has ALREADY been emitted by
    // the time this runs, so anything thrown on this path would surface as an
    // unhandled async error over a page that had loaded fine -- two lines on a
    // card are not worth a red screen. (It is also the path a hot reload
    // breaks: an instance built before _getAllControlsUseCase existed carries
    // a null in that field until the app is fully restarted.)
    try {
      final results = await Future.wait(
        policies.map(
          (policy) => _getAllControlsUseCase.call(
            moduleId: moduleId,
            policyId: policy.id,
          ),
        ),
      );

      for (var i = 0; i < policies.length; i++) {
        results[i].fold(
          (_) {},
          (controls) {
            // First-seen order, de-duplicated: a department weighted on three
            // controls is one chip, not three.
            final departments = <String>[];
            for (final control in controls) {
              for (final entry in control.departments) {
                final name = entry.department.trim();
                if (name.isEmpty || departments.contains(name)) continue;
                departments.add(name);
              }
            }
            summaries[policies[i].id] = PolicyControlsSummary(
              controlCount: controls.length,
              departments: departments,
            );
          },
        );
      }
    } catch (error, stackTrace) {
      debugPrint('[grc-policy] controls summary skipped: $error');
      debugPrint('$stackTrace');
      return;
    }

    if (isClosed || summaries.isEmpty) return;
    // Only overwrite if the list on screen is still the one we counted for --
    // a filter or a reload may have replaced it while these reads were out.
    final current = state;
    if (current is! PolicyListLoaded || current.policies != policies) return;
    emit(PolicyListLoaded(policies, controlsSummary: summaries));
  }

  Future<void> getPolicy(String id, {required String moduleId}) async {
    emit(PolicyLoading());
    final result = await _getUseCase.call(id, moduleId: moduleId);
    result.fold(
      (failure) => emit(PolicyFailure(failure.message)),
      (policy) => emit(PolicySingleLoaded(policy)),
    );
  }

  // ================================================================
  // CREATE (Active / Publish) and SAVE AS DRAFT
  // ================================================================

  /// function name: [createPolicy]
  ///
  /// purpose: create a new Policy with [PolicyStatus.active] (Publish),
  ///          then create every [controls] entry against the new Policy's
  ///          id. See [_createPolicyWithControls] for state semantics.
  Future<void> createPolicy({
    /// Name of the module this policy lives under, and that module's owners.
    /// They are what the policy notifications address and who receives them;
    /// every caller already holds the GRCModuleEntity. Left optional so an
    /// older call site still compiles -- it just sends nothing, and says so
    /// in the debug console.
    String moduleName = '',
    Iterable<String> moduleOwners = const <String>[],
    required String policyNameEn,
    required String policyNameAr,
    required String policyNumberEn,
    required String policyNumberAr,
    required String policyDescriptionEn,
    required String policyDescriptionAr,
    required DateTime startDate,
    required DateTime endDate,
    required double policyWeight,
    required String moduleId,
    List<PendingControlInput> controls = const [],
    File? imageFile,
    String? imageUrl,
    File? policyDocumentFileEn,
    String? policyDocumentUrlEn,
    File? policyDocumentFileAr,
    String? policyDocumentUrlAr,
  }) async {
    await _createPolicyWithControls(
      status: PolicyStatus.active, // Publish = Active
      moduleName: moduleName,
      moduleOwners: moduleOwners,
      policyNameEn: policyNameEn,
      policyNameAr: policyNameAr,
      policyNumberEn: policyNumberEn,
      policyNumberAr: policyNumberAr,
      policyDescriptionEn: policyDescriptionEn,
      policyDescriptionAr: policyDescriptionAr,
      startDate: startDate,
      endDate: endDate,
      policyWeight: policyWeight,
      moduleId: moduleId,
      controls: controls,
      imageFile: imageFile,
      imageUrl: imageUrl,
      policyDocumentFileEn: policyDocumentFileEn,
      policyDocumentUrlEn: policyDocumentUrlEn,
      policyDocumentFileAr: policyDocumentFileAr,
      policyDocumentUrlAr: policyDocumentUrlAr,
    );
  }

  /// function name: [saveAsDraft]
  ///
  /// purpose: create a new Policy with [PolicyStatus.draft] (Save For
  ///          Later), then create every [controls] entry (may be empty).
  Future<void> saveAsDraft({
    /// Name of the module this policy lives under, and that module's owners.
    /// They are what the policy notifications address and who receives them;
    /// every caller already holds the GRCModuleEntity. Left optional so an
    /// older call site still compiles -- it just sends nothing, and says so
    /// in the debug console.
    String moduleName = '',
    Iterable<String> moduleOwners = const <String>[],
    required String policyNameEn,
    required String policyNameAr,
    required String policyNumberEn,
    required String policyNumberAr,
    required String policyDescriptionEn,
    required String policyDescriptionAr,
    required DateTime startDate,
    required DateTime endDate,
    required double policyWeight,
    required String moduleId,
    List<PendingControlInput> controls = const [],
    File? imageFile,
    String? imageUrl,
    File? policyDocumentFileEn,
    String? policyDocumentUrlEn,
    File? policyDocumentFileAr,
    String? policyDocumentUrlAr,
  }) async {
    await _createPolicyWithControls(
      status: PolicyStatus.draft, // Save For Later = Draft
      moduleName: moduleName,
      moduleOwners: moduleOwners,
      policyNameEn: policyNameEn,
      policyNameAr: policyNameAr,
      policyNumberEn: policyNumberEn,
      policyNumberAr: policyNumberAr,
      policyDescriptionEn: policyDescriptionEn,
      policyDescriptionAr: policyDescriptionAr,
      startDate: startDate,
      endDate: endDate,
      policyWeight: policyWeight,
      moduleId: moduleId,
      controls: controls,
      imageFile: imageFile,
      imageUrl: imageUrl,
      policyDocumentFileEn: policyDocumentFileEn,
      policyDocumentUrlEn: policyDocumentUrlEn,
      policyDocumentFileAr: policyDocumentFileAr,
      policyDocumentUrlAr: policyDocumentUrlAr,
    );
  }

  /// function name: [_createPolicyWithControls]
  ///
  /// purpose: shared orchestration for [createPolicy]/[saveAsDraft]. Creates
  ///          the Policy first (repository/use-case layer knows nothing
  ///          about Controls); if that fails, emits [PolicyFailure] and
  ///          stops — no Control is ever attempted without a persisted
  ///          Policy. On Policy success, creates every [controls] entry
  ///          against the new `policy.id`, collecting failures instead of
  ///          throwing, then emits [PolicyActionSuccess] if all controls
  ///          succeeded (or there were none) or
  ///          [PolicyActionPartialSuccess] if some failed.
  Future<void> _createPolicyWithControls({
    required PolicyStatus status,
    String moduleName = '',
    Iterable<String> moduleOwners = const <String>[],
    required String policyNameEn,
    required String policyNameAr,
    required String policyNumberEn,
    required String policyNumberAr,
    required String policyDescriptionEn,
    required String policyDescriptionAr,
    required DateTime startDate,
    required DateTime endDate,
    required double policyWeight,
    required String moduleId,
    required List<PendingControlInput> controls,
    File? imageFile,
    String? imageUrl,
    File? policyDocumentFileEn,
    String? policyDocumentUrlEn,
    File? policyDocumentFileAr,
    String? policyDocumentUrlAr,
  }) async {
    emit(PolicyLoading());
    final editorId = _currentUserEmail;
    final result = await _createUseCase.call(
      CreatePolicyParams(
        policyNameEn: policyNameEn,
        policyNameAr: policyNameAr,
        policyNumberEn: policyNumberEn,
        policyNumberAr: policyNumberAr,
        policyDescriptionEn: policyDescriptionEn,
        policyDescriptionAr: policyDescriptionAr,
        startDate: startDate,
        endDate: endDate,
        policyWeight: policyWeight,
        editorId: editorId,
        moduleId: moduleId,
        status: status,
        imageFile: imageFile,
        imageUrl: imageUrl,
        policyDocumentFileEn: policyDocumentFileEn,
        policyDocumentUrlEn: policyDocumentUrlEn,
        policyDocumentFileAr: policyDocumentFileAr,
        policyDocumentUrlAr: policyDocumentUrlAr,
      ),
    );

    await result.fold(
      (failure) async => emit(PolicyFailure(failure.message)),
      (policy) async {
        // Policy Created (+ Scheduled for Activation when the start date is
        // still ahead). Fired before the controls loop so it does not hang on
        // every control saving.
        _notifyPolicyCreated(
          policy: policy,
          moduleName: moduleName,
          moduleOwners: moduleOwners,
          isDraft: status == PolicyStatus.draft,
        );

        if (controls.isEmpty) {
          emit(PolicyActionSuccess(policy));
          return;
        }

        final failedControls = <({PendingControlInput input, String message})>[];
        for (final input in controls) {
          final controlResult = await _createControlUseCase.call(
            _buildCreateControlParams(
              moduleId: moduleId,
              policyId: policy.id,
              editorId: editorId,
              input: input,
              controlsDocumentUrlEn: input.controlsDocumentUrlEn,
              controlsDocumentUrlAr: input.controlsDocumentUrlAr,
            ),
          );
          controlResult.fold(
            (failure) =>
                failedControls.add((input: input, message: failure.message)),
            // Control Added to Policy -- one per control that actually saved,
            // and only for a published policy: a draft's controls are not an
            // announcement either.
            (_) {
              if (status != PolicyStatus.draft) {
                _notifyControlAdded(
                  controlName: input.controlsNameEn,
                  policyName: policy.policyNameEn,
                  moduleOwners: moduleOwners,
                );
              }
            },
          );
        }

        if (failedControls.isEmpty) {
          emit(PolicyActionSuccess(policy));
        } else {
          emit(PolicyActionPartialSuccess(policy, failedControls));
        }
      },
    );
  }

  // ================================================================
  // UPDATE / DELETE / RESTORE (Policy)
  // ================================================================

  Future<void> updatePolicy({
    required String id,
    required String moduleId,
    Iterable<String> moduleOwners = const <String>[],
    /// The policy as it was BEFORE this edit. Without it the date/weight
    /// notifications cannot say what changed, so they are skipped rather
    /// than guessed.
    PolicyEntity? previous,

    PolicyStatus? status,
    String? policyNameEn,
    String? policyNameAr,
    String? policyNumberEn,
    String? policyNumberAr,
    String? policyDescriptionEn,
    String? policyDescriptionAr,
    DateTime? startDate,
    DateTime? endDate,
    double? policyWeight,
    File? imageFile,
    String? imageUrl,
    File? policyDocumentFileEn,
    String? policyDocumentUrlEn,
    File? policyDocumentFileAr,
    String? policyDocumentUrlAr,
  }) async {
    emit(PolicyLoading());
    final result = await _updateUseCase.call(
      UpdatePolicyParams(
        id: id,
        editorId: _currentUserEmail,
        moduleId: moduleId,
        status: status,
        policyNameEn: policyNameEn,
        policyNameAr: policyNameAr,
        policyNumberEn: policyNumberEn,
        policyNumberAr: policyNumberAr,
        policyDescriptionEn: policyDescriptionEn,
        policyDescriptionAr: policyDescriptionAr,
        startDate: startDate,
        endDate: endDate,
        policyWeight: policyWeight,
        imageFile: imageFile,
        imageUrl: imageUrl,
        policyDocumentFileEn: policyDocumentFileEn,
        policyDocumentUrlEn: policyDocumentUrlEn,
        policyDocumentFileAr: policyDocumentFileAr,
        policyDocumentUrlAr: policyDocumentUrlAr,
      ),
    );
    result.fold(
      (failure) => emit(PolicyFailure(failure.message)),
      (policy) {
        // Activation Date Updated / End Date Updated / Weight Updated /
        // Expired -- whichever of them this edit actually changed.
        _notifyPolicyUpdated(
          moduleId: moduleId,
          previous: previous,
          after: policy,
          moduleOwners: moduleOwners,
        );
        emit(PolicyActionSuccess(policy));
      },
    );
  }

  /// function name: [updatePolicyWithControls]
  ///
  /// purpose: update an existing Policy (used when resuming a Draft from
  ///          the Create New Policy wizard) and reconcile its Controls in
  ///          the same call: [removedControlIds] are deleted, each
  ///          [controls] entry with an [PendingControlInput.existingControlId]
  ///          is updated in place, and each without one is created fresh.
  ///          Mirrors [_createPolicyWithControls]'s one-Loading/one-final-
  ///          state contract.
  ///
  /// parameters:
  ///            [String] id: the existing Policy's id
  ///            [String] moduleId: the parent GRC Module's id
  ///            [PolicyStatus] status: [PolicyStatus.draft] for Save For
  ///            Later, [PolicyStatus.active] for Publish
  ///            [List<PendingControlInput>] controls: every touched control
  ///            card from the wizard (existing or new)
  ///            [List<String>] removedControlIds: ids of previously-saved
  ///            controls no longer present/touched in the wizard
  ///
  /// return type: [Future<void>]
  Future<void> updatePolicyWithControls({
    required String id,
    required String moduleId,
    Iterable<String> moduleOwners = const <String>[],
    /// The policy as it was BEFORE this edit. Without it the date/weight
    /// notifications cannot say what changed, so they are skipped rather
    /// than guessed.
    PolicyEntity? previous,

    required PolicyStatus status,
    required String policyNameEn,
    required String policyNameAr,
    required String policyNumberEn,
    required String policyNumberAr,
    required String policyDescriptionEn,
    required String policyDescriptionAr,
    required DateTime startDate,
    required DateTime endDate,
    required double policyWeight,
    required List<PendingControlInput> controls,
    required List<String> removedControlIds,
    File? imageFile,
    String? imageUrl,
    File? policyDocumentFileEn,
    String? policyDocumentUrlEn,
    File? policyDocumentFileAr,
    String? policyDocumentUrlAr,
  }) async {
    emit(PolicyLoading());
    final editorId = _currentUserEmail;

    final result = await _updateUseCase.call(UpdatePolicyParams(
      id: id,
      editorId: editorId,
      moduleId: moduleId,
      status: status,
      policyNameEn: policyNameEn,
      policyNameAr: policyNameAr,
      policyNumberEn: policyNumberEn,
      policyNumberAr: policyNumberAr,
      policyDescriptionEn: policyDescriptionEn,
      policyDescriptionAr: policyDescriptionAr,
      startDate: startDate,
      endDate: endDate,
      policyWeight: policyWeight,
      imageFile: imageFile,
      imageUrl: imageUrl,
      policyDocumentFileEn: policyDocumentFileEn,
      policyDocumentUrlEn: policyDocumentUrlEn,
      policyDocumentFileAr: policyDocumentFileAr,
      policyDocumentUrlAr: policyDocumentUrlAr,
    ));

    await result.fold(
      (failure) async => emit(PolicyFailure(failure.message)),
      (policy) async {
        for (final controlId in removedControlIds) {
          final deleteResult = await _deleteControlUseCase.call(
            DeleteControlParams(id: controlId, moduleId: moduleId, policyId: id),
          );
          if (deleteResult.isLeft()) {
            emit(PolicyFailure(
              deleteResult.fold((failure) => failure.message, (_) => ''),
            ));
            return;
          }
        }

        final failedControls =
            <({PendingControlInput input, String message})>[];
        for (final input in controls) {
          final controlResult = await _upsertControlForUpdate(
            input: input,
            moduleId: moduleId,
            policyId: id,
            editorId: editorId,
          );
          controlResult.fold(
            (failure) =>
                failedControls.add((input: input, message: failure.message)),
            (_) {},
          );
        }

        // Same announcements as updatePolicy. Publishing a draft is announced
        // as Policy Created (see _notifyPolicyUpdated).
        _notifyPolicyUpdated(
          moduleId: moduleId,
          previous: previous,
          after: policy,
          moduleOwners: moduleOwners,
        );

        if (failedControls.isEmpty) {
          emit(PolicyActionSuccess(policy));
        } else {
          emit(PolicyActionPartialSuccess(policy, failedControls));
        }
      },
    );
  }

  /// function name: [_buildCreateControlParams]
  ///
  /// purpose: shared builder for the [CreateControlParams] assembled from a
  ///          [PendingControlInput] in both [_createPolicyWithControls] and
  ///          [updatePolicyWithControls]. Faithful DRY extraction of the two
  ///          previously copy-pasted field-mapping blocks: every control field
  ///          is taken from [input]; the ids ([moduleId]/[policyId]/[editorId])
  ///          and the two document URLs vary per call site and so are passed
  ///          in. The create-during-update path passes no URLs, preserving its
  ///          original behavior of leaving them null.
  CreateControlParams _buildCreateControlParams({
    required String moduleId,
    required String policyId,
    required String editorId,
    required PendingControlInput input,
    String? controlsDocumentUrlEn,
    String? controlsDocumentUrlAr,
  }) {
    return CreateControlParams(
      moduleId: moduleId,
      policyId: policyId,
      editorId: editorId,
      controlsNameEn: input.controlsNameEn,
      controlsNameAr: input.controlsNameAr,
      controlsNumberEn: input.controlsNumberEn,
      controlsNumberAr: input.controlsNumberAr,
      controlsDescriptionEn: input.controlsDescriptionEn,
      controlsDescriptionAr: input.controlsDescriptionAr,
      controlsWeight: input.controlsWeight,
      frequency: input.frequency,
      startDate: input.startDate,
      endDate: input.endDate,
      departments: input.departments,
      equalWeights: input.equalWeights,
      score: input.score,
      status: input.status,
      controlsDocumentFileEn: input.controlsDocumentFileEn,
      controlsDocumentUrlEn: controlsDocumentUrlEn,
      controlsDocumentFileAr: input.controlsDocumentFileAr,
      controlsDocumentUrlAr: controlsDocumentUrlAr,
    );
  }

  /// function name: [_upsertControlForUpdate]
  ///
  /// purpose: per-control decision for [updatePolicyWithControls] — update the
  ///          control in place when [PendingControlInput.existingControlId] is
  ///          set, otherwise create it fresh. Extracted from the loop's inline
  ///          ternary to reduce nesting; behavior is unchanged (the update
  ///          branch still omits departments/equalWeights/score/URLs and the
  ///          create branch still passes no document URLs).
  Future<Either<Failure, ControlEntity>> _upsertControlForUpdate({
    required PendingControlInput input,
    required String moduleId,
    required String policyId,
    required String editorId,
  }) {
    if (input.existingControlId != null) {
      return _updateControlUseCase.call(UpdateControlParams(
        id: input.existingControlId!,
        moduleId: moduleId,
        policyId: policyId,
        editorId: editorId,
        controlsNameEn: input.controlsNameEn,
        controlsNameAr: input.controlsNameAr,
        controlsNumberEn: input.controlsNumberEn,
        controlsNumberAr: input.controlsNumberAr,
        controlsDescriptionEn: input.controlsDescriptionEn,
        controlsDescriptionAr: input.controlsDescriptionAr,
        controlsWeight: input.controlsWeight,
        frequency: input.frequency,
        startDate: input.startDate,
        endDate: input.endDate,
        status: input.status,
        controlsDocumentFileEn: input.controlsDocumentFileEn,
        controlsDocumentFileAr: input.controlsDocumentFileAr,
      ));
    }
    return _createControlUseCase.call(_buildCreateControlParams(
      moduleId: moduleId,
      policyId: policyId,
      editorId: editorId,
      input: input,
    ));
  }

  Future<void> deletePolicy({
    required String id,
    required String moduleId,
    /// Who hears "Policy Removed". Empty means "look the module up".
    Iterable<String> moduleOwners = const <String>[],
  }) async {
    emit(PolicyLoading());
    final result = await _deleteUseCase.call(
      DeletePolicyParams(id: id, editorId: _currentUserEmail, moduleId: moduleId),
    );
    result.fold(
      (failure) => emit(PolicyFailure(failure.message)),
      (policy) {
        _notifyPolicyDeleted(
          moduleId: moduleId,
          policy: policy,
          moduleOwners: moduleOwners,
        );
        emit(PolicyActionSuccess(policy));
      },
    );
  }

  /// Policy Deleted → the module's owners.
  void _notifyPolicyDeleted({
    required String moduleId,
    required PolicyEntity policy,
    required Iterable<String> moduleOwners,
  }) {
    final String actor = _currentUserEmail;
    final bool isArabic = _isArabic;
    final List<String> known = moduleOwners.toList();
    GrcNotify.run('policy-deleted', () async {
      final List<String> owners = known.isNotEmpty
          ? known
          : ((await GrcNotify.module(moduleId))?.moduleOwners ??
              const <String>[]);
      final Set<String> audience = _policyAudience(owners);
      if (audience.isEmpty) return;
      GrcNotify.fire(
        'policy-deleted',
        () => GrcPolicyNotificationService.policyDeleted(
          actorEmail: actor,
          policyName: policy.policyNameEn,
          recipients: audience,
          isArabic: isArabic,
        ),
      );
    });
  }

  Future<void> restorePolicy({
    required String id,
    required String moduleId,
  }) async {
    emit(PolicyLoading());
    final result = await _restoreUseCase.call(
      RestorePolicyParams(id: id, editorId: _currentUserEmail, moduleId: moduleId),
    );
    result.fold(
      (failure) => emit(PolicyFailure(failure.message)),
      (policy) => emit(PolicyActionSuccess(policy)),
    );
  }

}
