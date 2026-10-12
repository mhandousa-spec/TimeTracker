/// Module: services_management_module
/// Description: Business logic for the SLA notification screen. Requires a
///              CreateServicesRepository via constructor injection (no
///              default/fallback instantiation) and never imports
///              cloud_firestore directly — all persistence goes through the
///              injected repository. TextEditingController lifecycle lives
///              on SlaNotificationModel, not here.
/// Author: Amr Mesbah
/// Date: 30/8/2025
/// Dependencies: flutter_bloc, sla_notification_state.dart,
///              sla_notification_model.dart, CreateServicesRepository
/// Revision History:
///   - 30/8/2025 (Amr Mesbah): Initial version.
///   - 02/07/2026 (Knowticed Team): Removed default repo instantiation
///     (now constructor-required); removed cloud_firestore import; moved
///     TextEditingController add/remove/dispose into SlaNotificationModel.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/services_management_module/s2_create_single_services/presentation/ui/pages/details_switch_screen_toggle.dart';
import 'package:knowticed_plus/features/services_management_module/s2_create_single_services/presentation/controller/sla_notification_state.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/utils/shared.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/domain/base_repository/service_repository.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/data_source/local_data_source/services_prefs_employee.dart';

import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/model_employee.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/domain/enums/service_display_status.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/data_source/local_data_source/shared_prefs_service_master.dart';
import 'package:knowticed_plus/features/services_management_module/s2_create_single_services/data/sla_notification_model.dart';

class SlaNotificationCubit extends Cubit<SlaNotificationState> {
  // B5 FIX: guard against emit-after-close (StateError) when the user
  // navigates away mid-await. Applies to every emit in this cubit.
  @override
  void emit(state) {
    if (isClosed) return;
    super.emit(state);
  }

  // Function types for dependencies
  final Future<void> Function({
  required String slaOne,
  required String slaTwo,
  required bool notifyRequesterChecked,
  required bool notifyProviderChecked,
  required bool notifyManagerChecked,
  required bool notifyRequesterSwitch0,
  required bool notifyManagerSwitch1,
  required List<String> extraSlaList,
  required List<String> extraSlaTwoList,
  required Map<String, Map<int, bool>> notificationSwitches,

  }) submitSlaData;

  final Future<void> Function(ServicesHistoryModel)? saveDraft;

  // 006: repository is required — no default instantiation. Callers must
  // inject a real CreateServicesRepository (see ServicesManagerCubit.repository).
  final CreateServicesRepository _repository;

  SlaNotificationCubit({
    required this.submitSlaData,
    required CreateServicesRepository repository,
    this.saveDraft,
  })  : _repository = repository,
        super(SlaNotificationInitial());

  // Model instance
  final SlaNotificationModel model = SlaNotificationModel();

  // Firestore related
  ServicesHistoryModel? currentModel;
  String? currentDocId;
  bool creatingDraftDoc = false;

  Future<void> initialize(ServicesHistoryModel? editingModel) async {
    emit(SlaNotificationLoading());

    model.notifyRequesterChecked = false;
    model.notifyProviderChecked = false;
    model.notifyManagerChecked = false;

    final dateTime = DateTime.now();
    model.formatDate = DateFormat("MMMdd_yyyy").format(dateTime);

    currentDocId = editingModel?.currentId;
    _sfl('initialize: editingModel='
        '${editingModel == null ? 'null (new service)' : 'id=${editingModel.currentId} state=${editingModel.currentState}'} '
        '→ currentDocId=$currentDocId');

    if (editingModel != null) {
      await _loadExistingData(editingModel);
    } else {
      _clearFormForNewService();
      if (currentDocId == null || currentDocId!.isEmpty) {
        await _ensureDraftDoc();
      }
    }
    _sfl('initialize: done currentDocId=$currentDocId '
        'currentModel=${currentModel == null ? 'null' : 'present'}');

    emit(SlaNotificationLoaded(
      currentDocId: currentDocId,
      notifyRequesterChecked: model.notifyRequesterChecked,
      notifyProviderChecked: model.notifyProviderChecked,
      notifyManagerChecked: model.notifyManagerChecked,
      notifyRequesterSwitch0: model.notifyRequesterSwitch0,
      notifyManagerSwitch1: model.notifyManagerSwitch1,
      extraSlaList: model.extraSlaControllers.map((c) => c.text).toList(),
      extraSlaTwoList: model.extraSlaTwoControllers.map((c) => c.text).toList(),
      notificationSwitches: model.notificationSwitches,
    ));
  }

  /// Tag every line of the Save For Later trace so it can be pulled out of the
  /// app's very chatty log with `grep SFL`.
  ///
  /// TEMPORARY (26/8/2026) — added to diagnose "Save For Later reports success
  /// and nothing appears in Firestore". Remove the [_sfl] calls once the cause
  /// is found; the two `catch` blocks they replaced were EMPTY, which is why
  /// the failure was invisible in the first place, so those keep their logging
  /// whatever happens to the rest.
  static void _sfl(String message) => debugPrint('[SFL] $message');

  Future<void> _ensureDraftDoc() async {
    _sfl('_ensureDraftDoc: entry currentDocId=$currentDocId '
        'currentModel=${currentModel == null ? 'null' : 'present'}');

    if (currentDocId != null && currentDocId!.isNotEmpty) {
      _sfl('_ensureDraftDoc: reusing existing docId=$currentDocId');
      if (currentModel == null) {
        await _loadModelFromFirestore(currentDocId!);
      }
      _sfl('_ensureDraftDoc: after reuse currentModel='
          '${currentModel == null ? 'STILL NULL' : 'present'}');
      return;
    }

    final restored = await SharedPrefsHelper.getString('current_service_docId');
    _sfl('_ensureDraftDoc: prefs current_service_docId=$restored');
    if (restored != null && restored.isNotEmpty) {
      currentDocId = restored;
      await _loadModelFromFirestore(currentDocId!);
      _sfl('_ensureDraftDoc: after restore currentModel='
          '${currentModel == null ? 'STILL NULL' : 'present'}');
      return;
    }

    if (creatingDraftDoc) {
      _sfl('_ensureDraftDoc: already creating, bailing out');
      return;
    }
    creatingDraftDoc = true;

    try {
      final now = DateTime.now();
      final formatted = DateFormat("MMMdd_yyyy").format(now);
      final randomId = DateTime.now().millisecondsSinceEpoch % 100000;
      currentDocId = "User${randomId}$formatted";
      _sfl('_ensureDraftDoc: minting new docId=$currentDocId');

      currentModel = ServicesHistoryModel.createNew(
        id: currentDocId!,
        state: 'draft',
        status: 'draft',
      );

      await _repository.setServicesDoc(currentDocId!, currentModel!.toJson());
      _sfl('_ensureDraftDoc: setServicesDoc OK for $currentDocId');

      await SharedPrefsHelper.setString('current_service_docId', currentDocId!);
    } catch (e, st) {
      // Was an EMPTY catch. A failure to create the draft document left
      // currentModel null and said nothing, which is exactly how a save can
      // "succeed" against a document that was never created.
      _sfl('_ensureDraftDoc: FAILED — $e');
      debugPrint('$st');
    } finally {
      creatingDraftDoc = false;
    }
  }

  Future<void> _loadModelFromFirestore(String docId) async {
    _sfl('_loadModelFromFirestore: reading $docId');
    try {
      final data = await _repository.getServicesDoc(docId);

      if (data != null) {
        currentModel = ServicesHistoryModel.fromJson(data, docId);
        _sfl('_loadModelFromFirestore: loaded $docId '
            'state=${currentModel!.currentState} status=${currentModel!.currentStatus}');
        _populateUIFromModel();
      } else {
        _sfl('_loadModelFromFirestore: NO DOCUMENT at $docId — currentModel stays null');
      }
    } catch (e, st) {
      // Was an EMPTY catch — the single most likely place for this bug to hide.
      _sfl('_loadModelFromFirestore: FAILED for $docId — $e');
      debugPrint('$st');
    }
  }

  void _populateUIFromModel() {
    if (currentModel == null) return;

    model.slaOneController.text = currentModel!.currentSlaOneControllerEnglish;
    model.slaTwoController.text = currentModel!.currentSlaTwoControllerEnglish;
    model.notifyRequesterChecked = currentModel!.currentNotifyRequesterChecked;
    model.notifyProviderChecked = currentModel!.currentNotifyProviderChecked;
    model.notifyManagerChecked = currentModel!.currentNotifyManagerChecked;
    model.notifyRequesterSwitch0 = currentModel!.currentNotifyRequesterSwitch0;
    model.notifyManagerSwitch1 = currentModel!.currentNotifyManagerSwitch1;
  }

  Future<void> _loadExistingData(ServicesHistoryModel editingModel) async {

    currentModel = editingModel;
    currentDocId = editingModel.currentId;

    model.slaOneController.text = editingModel.currentSlaOneControllerEnglish;
    model.slaTwoController.text = editingModel.currentSlaTwoControllerEnglish;
    model.notifyRequesterChecked = editingModel.currentNotifyRequesterChecked;
    model.notifyProviderChecked = editingModel.currentNotifyProviderChecked;
    model.notifyManagerChecked = editingModel.currentNotifyManagerChecked;
    model.notifyRequesterSwitch0 = editingModel.currentNotifyRequesterSwitch0;
    model.notifyManagerSwitch1 = editingModel.currentNotifyManagerSwitch1;

  }

  void _clearFormForNewService() {

    model.slaOneController.clear();
    model.slaTwoController.clear();

    model.notifyRequesterChecked = false;
    model.notifyProviderChecked = false;
    model.notifyManagerChecked = false;
    model.notifyRequesterSwitch0 = false;
    model.notifyManagerSwitch1 = false;

    model.notificationSwitches.clear();
    model.isInvalidNumber = false;
    model.isInvalidNumberTwo = false;

    for (var controller in model.extraSlaControllers) {
      controller.dispose();
    }
    for (var controller in model.extraSlaTwoControllers) {
      controller.dispose();
    }
    model.extraSlaControllers.clear();
    model.extraSlaTwoControllers.clear();

    _clearSlaSharedPreferences();
  }

  Future<void> _clearSlaSharedPreferences() async {
    await SharedPrefsHelper.setString('sla_one', '');
    await SharedPrefsHelper.setString('sla_two', '');
    await SharedPrefsHelper.setBool('Notify Service Requester_checked', false);
    await SharedPrefsHelper.setBool('Notify Service Provider_checked', false);
    await SharedPrefsHelper.setBool('Notify Provider Manager_checked', false);
    await SharedPrefsHelper.setBool('notifyRequesterSwitch0', false);
    await SharedPrefsHelper.setBool('notifyManagerSwitch1', false);
    await SharedPrefsHelper.setStringList('extra_sla_list', []);
    await SharedPrefsHelper.setStringList('extra_sla_two_list', []);

  }

  /// Returns true when the model was persisted (or there was nothing to
  /// persist), false when the write failed — callers that go on to report
  /// success must abort on false.
  ///
  /// [keepAsDraft] pins the lifecycle `state` to 'draft' for this write.
  ///
  /// ADDED 26/8/2026. This method writes `status` and never touched `state`, so
  /// the lifecycle was whatever the loaded document happened to be holding. On
  /// the Save For Later path that is the one thing that must not be left to
  /// chance — the entire meaning of the button is "this is not finished" — and
  /// leaving it implicit is how a draft can quietly stop being one after an
  /// unrelated write. Submit deliberately does not pass it: publishing is what
  /// moves a service out of draft.
  Future<bool> updateAndSaveModel({bool keepAsDraft = false}) async {
    _sfl('updateAndSaveModel: entry keepAsDraft=$keepAsDraft '
        'currentDocId=$currentDocId');
    try {
      await _ensureDraftDoc();

      // ✅ FIX 26/8/2026 — this used to `return true` here, i.e. report SUCCESS
      // for a call that wrote nothing at all.
      //
      // `currentModel` is null whenever `_loadModelFromFirestore` came back
      // empty — the document was missing, or the read threw into its bare
      // `catch (e, st) {}`. Nothing downstream could tell that apart from a
      // real save, so Save For Later showed its success dialog over a document
      // that was never written. That is the "it says saved and there is
      // nothing in Firebase" report.
      //
      // Returning false lets the caller say so. `handleSubmit` already aborts
      // on false; `handleSaveForLater` now does too.
      if (currentModel == null || currentDocId == null) {
        _sfl('updateAndSaveModel: NOTHING TO PERSIST — '
            'currentDocId=$currentDocId '
            'currentModel=${currentModel == null ? 'null' : 'present'} '
            '→ returning false, nothing was written');
        return false;
      }

      // ✅ Read toggled status from SharedPrefs (set by page 1)
      final isActive = await SharedPrefsHelper.getBool('service_status') ?? true;
      final status = isActive ? 'active' : 'inactive';

      // ✅ FIX (bug report p1/p10): carry the approval cycle through the edit
      // path.
      //
      // This copyWith only ever touched the SLA / notification / status fields,
      // so editing an existing service re-saved the approval cycle that was
      // loaded from Firestore. Changing an approver silently did nothing, and
      // because the doc kept the old approver the new approver's Approvals
      // screen stayed empty.
      //
      // The approvals step stages its selection via
      // SharedPrefsApprovalHelper.saveApprovalCycle(); read it back here and
      // only append when it actually differs, since ServicesHistoryModel is an
      // append-only history model and copyWith pushes a new revision.
      final stagedCycle = await SharedPrefsApprovalHelper.getApprovalCycle();
      final cycleChanged =
          !_isSameApprovalCycle(stagedCycle, currentModel!.currentApprovalCycle);

      currentModel = currentModel!.copyWith(
        slaOneControllerEnglish: model.slaOneController.text.trim(),
        slaTwoControllerEnglish: model.slaTwoController.text.trim(),
        notifyRequesterChecked: model.notifyRequesterChecked,
        notifyProviderChecked: model.notifyProviderChecked,
        notifyManagerChecked: model.notifyManagerChecked,
        notifyRequesterSwitch0: model.notifyRequesterSwitch0,
        notifyManagerSwitch1: model.notifyManagerSwitch1,
        status: status, // ✅ Apply correct status
        // Only ever set, never cleared: passing null leaves the existing
        // lifecycle alone, which is what the submit path wants.
        state: keepAsDraft ? ServiceDisplayStatus.draftState : null,
        approvalCycle: cycleChanged ? stagedCycle : null,
        requireApproval: cycleChanged ? stagedCycle.isNotEmpty : null,
      );

      _sfl('updateAndSaveModel: writing $currentDocId '
          'state=${currentModel!.currentState} status=${currentModel!.currentStatus}');
      await _repository.setServicesDoc(currentDocId!, currentModel!.toJson());
      _sfl('updateAndSaveModel: setServicesDoc OK for $currentDocId');
      return true;
    } catch (e, st) {
      // ✅ FIX: this was a bare `catch (e, st) {}`. Every failure of the final
      // save — including the status write — was swallowed, so a service that
      // never persisted its inactive status looked like it saved fine and then
      // showed up under Active on the home page with no error anywhere.
      //
      // Surface it as an error state; the SLA page already listens for
      // SlaNotificationValidationError and shows the message.
      _sfl('updateAndSaveModel: THREW — $e');
      debugPrint('$st');
      emit(SlaNotificationValidationError('Failed to save service: $e'));
      return false;
    }
  }

  /// Order-sensitive comparison of two approval cycles by email.
  ///
  /// Order matters: the cycle is sequential, so swapping two approvers is a
  /// real change even though the set of emails is identical.
  bool _isSameApprovalCycle(
    List<EmployeeEntityModell> a,
    List<EmployeeEntityModell> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      final left = (a[i].email ?? '').trim().toLowerCase();
      final right = (b[i].email ?? '').trim().toLowerCase();
      if (left != right) return false;
    }
    return true;
  }

  void updateCheckbox(String type, bool value) {
    switch (type) {
      case 'requester':
        model.notifyRequesterChecked = value;
        break;
      case 'provider':
        model.notifyProviderChecked = value;
        break;
      case 'manager':
        model.notifyManagerChecked = value;
        break;
    }
    _emitLoadedState();
  }

  void updateSwitch(String type, bool value) {
    switch (type) {
      case 'requester0':
        model.notifyRequesterSwitch0 = value;
        break;
      case 'manager1':
        model.notifyManagerSwitch1 = value;
        break;
    }
    _emitLoadedState();
  }

  void updateNotificationSwitches(String title, Map<int, bool> switches) {
    model.notificationSwitches[title] = Map<int, bool>.from(switches);
    _emitLoadedState();
  }

  void updateSlaOne(String value) {
    if (value.trim().isNotEmpty) {
      if (value.contains('.') || value.contains(',')) {
        model.isInvalidNumber = true;
      } else if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
        model.isInvalidNumber = true;
      } else {
        model.isInvalidNumber = false;
      }
    } else {
      model.isInvalidNumber = false;
    }
    _emitLoadedState();
  }

  void updateSlaTwo(String value) {
    if (value.trim().isNotEmpty) {
      if (value.contains('.') || value.contains(',')) {
        model.isInvalidNumberTwo = true;
      } else if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
        model.isInvalidNumberTwo = true;
      } else {
        model.isInvalidNumberTwo = false;
      }
    } else {
      model.isInvalidNumberTwo = false;
    }
    _emitLoadedState();
  }

  // 007: controller creation/disposal lives on SlaNotificationModel now —
  // the cubit just triggers it and reacts to changes (no TextEditingController
  // instantiation/lifecycle code in the cubit itself).
  void addExtraSlaController() {
    if (model.addExtraSlaController(_onExtraControllerChanged)) {
      _emitLoadedState();
    }
  }

  void addExtraSlaTwoController() {
    if (model.addExtraSlaTwoController(_onExtraControllerChanged)) {
      _emitLoadedState();
    }
  }

  void removeExtraSlaController(int index) {
    if (model.removeExtraSlaController(index)) {
      _saveExtraControllersToSharedPrefs();
      _emitLoadedState();
    }
  }

  void removeExtraSlaTwoController(int index) {
    if (model.removeExtraSlaTwoController(index)) {
      _saveExtraControllersToSharedPrefs();
      _emitLoadedState();
    }
  }

  void _onExtraControllerChanged() {
    updateAndSaveModel();
    _saveExtraControllersToSharedPrefs();
  }

  Future<void> _saveExtraControllersToSharedPrefs() async {
    final extraSlaValues = model.extraSlaControllers.map((c) => c.text).toList();
    final extraSlaTwoValues = model.extraSlaTwoControllers.map((c) => c.text).toList();

    await SharedPrefsHelper.setStringList('extra_sla_list', extraSlaValues);
    await SharedPrefsHelper.setStringList('extra_sla_two_list', extraSlaTwoValues);
  }

  bool hasProviderSlaData() {
    bool hasSlaOneText = model.slaOneController.text.trim().isNotEmpty;
    bool hasExtraSlaText = model.extraSlaControllers.any((controller) => controller.text.trim().isNotEmpty);
    return hasSlaOneText || hasExtraSlaText;
  }

  bool hasManagerSlaData() {
    bool hasSlaTwoText = model.slaTwoController.text.trim().isNotEmpty;
    bool hasExtraSlaTwoText = model.extraSlaTwoControllers.any((controller) => controller.text.trim().isNotEmpty);
    return hasSlaTwoText || hasExtraSlaTwoText;
  }

  String? validateNotificationSettings(BuildContext context, String requesterTitle, String providerTitle, String managerTitle) {
    List<String> errors = [];

    final requesterSwitches = model.notificationSwitches[requesterTitle] ?? {};
    bool hasRequesterSwitchEnabled = requesterSwitches.values.any((enabled) => enabled == true);

    if (hasRequesterSwitchEnabled && !model.notifyRequesterChecked) {
      errors.add("Please enable '$requesterTitle' checkbox when using its notification options");
    }

    final providerSwitches = model.notificationSwitches[providerTitle] ?? {};
    bool hasProviderSwitchEnabled = providerSwitches.values.any((enabled) => enabled == true);
    bool providerSlaDataExists = this.hasProviderSlaData();

    if ((hasProviderSwitchEnabled || providerSlaDataExists) && !model.notifyProviderChecked) {
      errors.add("Please enable '$providerTitle' checkbox when using notification options or entering SLA percentages");
    }

    final managerSwitches = model.notificationSwitches[managerTitle] ?? {};
    bool hasManagerSwitchEnabled = managerSwitches.values.any((enabled) => enabled == true);
    bool managerSlaDataExists = this.hasManagerSlaData();

    if ((hasManagerSwitchEnabled || managerSlaDataExists) && !model.notifyManagerChecked) {
      errors.add("Please enable '$managerTitle' checkbox when using notification options or entering SLA percentages");
    }

    return errors.isNotEmpty ? errors.first : null;
  }

  bool validateNumericInputs() {
    if (model.slaOneController.text.trim().isNotEmpty) {
      if (model.slaOneController.text.contains('.') || model.slaOneController.text.contains(',') ||
          !RegExp(r'^\d+$').hasMatch(model.slaOneController.text.trim())) {
        return false;
      }
    }

    if (model.slaTwoController.text.trim().isNotEmpty) {
      if (model.slaTwoController.text.contains('.') || model.slaTwoController.text.contains(',') ||
          !RegExp(r'^\d+$').hasMatch(model.slaTwoController.text.trim())) {
        return false;
      }
    }

    for (var controller in model.extraSlaControllers) {
      if (controller.text.trim().isNotEmpty) {
        if (controller.text.contains('.') || controller.text.contains(',') ||
            !RegExp(r'^\d+$').hasMatch(controller.text.trim())) {
          return false;
        }
      }
    }

    for (var controller in model.extraSlaTwoControllers) {
      if (controller.text.trim().isNotEmpty) {
        if (controller.text.contains('.') || controller.text.contains(',') ||
            !RegExp(r'^\d+$').hasMatch(controller.text.trim())) {
          return false;
        }
      }
    }

    return true;
  }

  bool hasAnyNotificationData() {
    bool hasAnySwitchEnabled = model.notificationSwitches.values
        .any((switchMap) => switchMap.values.any((enabled) => enabled == true));

    bool hasAnySlaData = model.slaOneController.text.trim().isNotEmpty ||
        model.slaTwoController.text.trim().isNotEmpty ||
        model.extraSlaControllers.any((c) => c.text.trim().isNotEmpty) ||
        model.extraSlaTwoControllers.any((c) => c.text.trim().isNotEmpty);

    return hasAnySwitchEnabled || hasAnySlaData;
  }

  Future<void> handleSubmit(BuildContext context, String requesterTitle, String providerTitle, String managerTitle) async {
    if (!validateNumericInputs()) {
      emit(const SlaNotificationValidationError("Please enter only whole numbers in percentage fields. Decimals are not allowed."));
      return;
    }

    if (hasAnyNotificationData()) {
      String? validationError = validateNotificationSettings(context, requesterTitle, providerTitle, managerTitle);
      if (validationError != null) {
        emit(SlaNotificationValidationError(validationError));
        return;
      }
    }

    // ✅ FIX: abort on a failed save. updateAndSaveModel used to swallow its
    // errors, so submit carried on and emitted SlaNotificationSaved — the
    // success dialog appeared for a service that was never written.
    final saved = await updateAndSaveModel();
    if (!saved) return;

    final extraSlaList = model.extraSlaControllers.map((c) => c.text).toList();
    final extraSlaTwoList = model.extraSlaTwoControllers.map((c) => c.text).toList();

    await submitSlaData(
      slaOne: model.slaOneController.text,
      slaTwo: model.slaTwoController.text,
      notifyRequesterChecked: model.notifyRequesterChecked,
      notifyProviderChecked: model.notifyProviderChecked,
      notifyManagerChecked: model.notifyManagerChecked,
      notifyRequesterSwitch0: model.notifyRequesterSwitch0,
      notifyManagerSwitch1: model.notifyManagerSwitch1,
      extraSlaList: extraSlaList,
      extraSlaTwoList: extraSlaTwoList,
      notificationSwitches: model.notificationSwitches,
    );

    await _saveAllToSharedPrefs(context);

    // ✅ FIX: Ensure currentModel is populated before emitting
    if (currentModel == null && currentDocId != null) {
      await _loadModelFromFirestore(currentDocId!);
    }

    emit(SlaNotificationSaved());
  }

  Future<void> handleSaveForLater(BuildContext context, ServicesHistoryModel? editingModel, VoidCallback onNavigate) async {
    _sfl('=========== SAVE FOR LATER PRESSED ===========');
    _sfl('handleSaveForLater: editingModel='
        '${editingModel == null ? 'null (new service)' : 'id=${editingModel.currentId} state=${editingModel.currentState}'}');
    _sfl('handleSaveForLater: cubit currentDocId=$currentDocId '
        'currentModel=${currentModel == null ? 'null' : 'present'}');

    final isEditingSubmittedService = editingModel != null &&
        editingModel.currentState == "submitted";

    if (isEditingSubmittedService) {
      _sfl('handleSaveForLater: DISCARD path (already submitted) — navigating, saving nothing');
      onNavigate();
      return;
    }

    if (!validateNumericInputs()) {
      _sfl('handleSaveForLater: BLOCKED by numeric validation');
      emit(const SlaNotificationValidationError("Please enter only numbers in percentage fields"));
      return;
    }

    emit(SlaNotificationSaving());

    final bool saved = await _saveDraftData();
    _sfl('handleSaveForLater: _saveDraftData returned $saved');

    // ✅ FIX 26/8/2026 — this used to emit `SlaNotificationSaved()`, which is
    // the SUBMIT state.
    //
    // `sla_screen_page_part2`'s listener keeps the two apart, and says so in
    // its own comments:
    //
    //     } else if (state is SlaNotificationDraftSaved) {
    //       // ✅ Only shows for Save For Later
    //       showDraftSavedSuccessDialog(context);
    //     } else if (state is SlaNotificationSaved) {
    //       // ✅ Only shows for Submit
    //       showCreateServiceDialog(...);
    //
    // Save For Later emitted the submit state, so it took the submit branch:
    // the user was shown the "service created" dialog — the one that reports a
    // finished, published service and offers what to do with it next — for a
    // draft they had explicitly chosen NOT to finish. `SlaNotificationDraftSaved`
    // existed the whole time with nothing emitting it.
    //
    // The `if (isDraft || editingModel != null) … else …` this replaces had
    // identical bodies in both branches, so `isDraft` was computed, never used,
    // and goes with it.
    //
    // ✅ FIX 26/8/2026 — and this emit is now CONDITIONAL. It used to fire
    // whatever `_saveDraftData` did, and `_saveDraftData` returned void, so a
    // save that wrote nothing still produced the success dialog. Reporting a
    // draft that does not exist is worse than reporting the failure: the user
    // closes the app believing their work is safe.
    if (!saved) {
      _sfl('handleSaveForLater: RESULT = FAILED (no success dialog)');
      _sfl('==============================================');
      emit(const SlaNotificationValidationError(
        'Could not save the draft. Please check your connection and try again.',
      ));
      return;
    }

    _sfl('handleSaveForLater: RESULT = SAVED');
    _sfl('==============================================');
    emit(const SlaNotificationDraftSaved());
  }

  /// Returns true when the draft actually reached storage.
  Future<bool> _saveDraftData() async {
    _sfl('_saveDraftData: entry');

    await SharedPrefsHelper.setString('sla_one', model.slaOneController.text.trim());
    await SharedPrefsHelper.setString('sla_two', model.slaTwoController.text.trim());
    await SharedPrefsHelper.setBool('Notify Service Requester_checked', model.notifyRequesterChecked);
    await SharedPrefsHelper.setBool('Notify Service Provider_checked', model.notifyProviderChecked);
    await SharedPrefsHelper.setBool('Notify Provider Manager_checked', model.notifyManagerChecked);

    final reqMap = model.notificationSwitches['notifyServiceRequester'] ?? {};
    final mgrMap = model.notificationSwitches['notifyProviderManager'] ?? {};
    model.notifyRequesterSwitch0 = reqMap[0] ?? false;
    model.notifyManagerSwitch1 = mgrMap[0] ?? false;

    await SharedPrefsHelper.setBool('notifyRequesterSwitch0', model.notifyRequesterSwitch0);
    await SharedPrefsHelper.setBool('notifyManagerSwitch1', model.notifyManagerSwitch1);
    await _saveExtraControllersToSharedPrefs();

    final extraSlaList = model.extraSlaControllers.map((c) => c.text).toList();
    final extraSlaTwoList = model.extraSlaTwoControllers.map((c) => c.text).toList();

    // Call submitSlaData for draft saving too
    await submitSlaData(
      slaOne: model.slaOneController.text,
      slaTwo: model.slaTwoController.text,
      notifyRequesterChecked: model.notifyRequesterChecked,
      notifyProviderChecked: model.notifyProviderChecked,
      notifyManagerChecked: model.notifyManagerChecked,
      notifyRequesterSwitch0: model.notifyRequesterSwitch0,
      notifyManagerSwitch1: model.notifyManagerSwitch1,
      extraSlaList: extraSlaList,
      extraSlaTwoList: extraSlaTwoList,
      notificationSwitches: model.notificationSwitches,
    );

    await Future.delayed(Duration(milliseconds: 100));

    final isEditingExisting = currentDocId != null && !currentDocId!.startsWith('draft_');
    _sfl('_saveDraftData: currentDocId=$currentDocId '
        'isEditingExisting=$isEditingExisting '
        '(services/ doc ${isEditingExisting ? 'will also be updated' : 'not touched'})');

    // ✅ FIX 26/8/2026 — THE DRAFT WAS SAVING EMPTY.
    //
    // The branch below used to decide WHICH DATA got saved, and for the wizard
    // flow it chose the wrong one.
    //
    // PATH A (`updateAndSaveModel`) copies the SLA and notification fields onto
    // `currentModel` and writes that. But on a new service `currentModel` is the
    // skeleton `_ensureDraftDoc` created — `createNew(id:, state:, status:)`,
    // with an empty name, description and duration. The wizard's page-1 data
    // never travels into that document: `CreateServiceCubit.submitForm` hands it
    // to `saveServiceDraft`, which is `repository.saveServiceToPrefs` — prefs,
    // not Firestore. So PATH A faithfully saved a blank service, which is why
    // the draft reopened with every field empty.
    //
    // PATH B is the code that knows better: it reads the staged wizard values
    // back out of SharedPrefs and assembles a complete model. It was only ever
    // reached for `draft_`-prefixed ids, which this screen never mints.
    //
    // So the assembly now runs for BOTH, and the branch decides only whether the
    // `services/` document also needs updating.
    if (isEditingExisting) {
      // Keep `services/{docId}` in step — the submit path reads it back. It is
      // NOT what the home page lists (different collection, see
      // [_stampDraftRecord]), so it cannot stand in for the draft record.
      final bool written = await updateAndSaveModel(keepAsDraft: true);
      if (!written) return false;
    }

    final ServicesHistoryModel draftModel = await _buildDraftModelFromStagedData();
    _sfl('_saveDraftData: draft model id=${draftModel.currentId} '
        'nameEn="${draftModel.currentServiceNameEnglish}" '
        'duration="${draftModel.currentDurationOfServices}" '
        'state=${draftModel.currentState}');

    return await _stampDraftRecord(draftModel);
  }

  /// Function Name: [_buildDraftModelFromStagedData]
  ///
  /// Purpose: Assemble the model a draft should be saved as, from everything the
  /// wizard has staged so far.
  ///
  /// ADDED 26/8/2026, generalising what was PATH B of [_saveDraftData].
  ///
  /// The wizard spreads one service across three places by the time the user
  /// reaches this screen: page 1's fields sit in SharedPrefs, the provider /
  /// department / approver selections sit in their own prefs helpers, and the
  /// SLA and notification values are live on this screen's controllers. Only the
  /// combination is a complete service, which is why saving `currentModel`
  /// alone produced an empty draft.
  ///
  /// Every staged value falls back to the one already on [currentModel] when it
  /// is empty, so this is safe for the other case too: resuming a real service
  /// keeps its stored fields wherever the wizard has not staged a replacement.
  ///
  /// Returns: [ServicesHistoryModel] carrying [currentDocId] as its id, so the
  /// draft record lands against the document this flow is already using.
  Future<ServicesHistoryModel> _buildDraftModelFromStagedData() async {
    final ServicesHistoryModel? base = currentModel;

    /// Staged value wins when it has content; otherwise keep what is stored.
    String prefer(String staged, String stored) =>
        staged.trim().isNotEmpty ? staged : stored;

    final nameEn = prefer(
        await SharedPrefsHelper.getString('service_name_en') ?? '',
        base?.currentServiceNameEnglish ?? '');
    final nameAr = prefer(
        await SharedPrefsHelper.getString('service_name_ar') ?? '',
        base?.currentServiceNameArabic ?? '');
    final descEn = prefer(
        await SharedPrefsHelper.getString('service_description_en') ?? '',
        base?.currentServiceDescriptionEnglish ?? '');
    final descAr = prefer(
        await SharedPrefsHelper.getString('service_description_ar') ?? '',
        base?.currentServiceDescriptionArabic ?? '');
    final durationVal = prefer(
        await SharedPrefsHelper.getString('duration_value') ?? '',
        base?.currentDurationOfServices ?? '');
    final durationUnit = prefer(
        await SharedPrefsHelper.getString('duration_unit') ?? '',
        base?.currentSelectedDurationUnit ?? '');
    final imageUrl = prefer(
        await SharedPrefsHelper.getString('service_image_url') ?? '',
        base?.currentImageUrl ?? '');

    // ✅ FIX (draft bug #1): `== true` made a missing pref mean "inactive".
    // Default to active, same as updateAndSaveModel and the create form.
    final status = (await SharedPrefsHelper.getBool('service_status') ?? true)
        ? 'active'
        : 'inactive';

    // These three helpers all return non-nullable lists, so an empty one means
    // "nothing staged" rather than "not asked yet" — hence the isNotEmpty test
    // rather than a null check.
    final List<EmployeeEntityModell> stagedProviders =
        await SharedPrefsEmployeeHelper.getSelectedEmployees();
    final List<EmployeeEntityModell> providers = stagedProviders.isNotEmpty
        ? stagedProviders
        : (base?.currentProviderServices ?? const <EmployeeEntityModell>[]);

    final List<String> stagedDepartments =
        await SharedPrefsDepartmentsHelper.getDepartments();
    final List<String> departments = stagedDepartments.isNotEmpty
        ? stagedDepartments
        : (base?.currentSelectDepartment ?? const <String>[]);

    final List<EmployeeEntityModell> stagedCycle =
        await SharedPrefsApprovalHelper.getApprovalCycle();
    final List<EmployeeEntityModell> approvalCycle = stagedCycle.isNotEmpty
        ? stagedCycle
        : (base?.currentApprovalCycle ?? const <EmployeeEntityModell>[]);

    // SLA and notification values come from this screen's own controllers
    // rather than from prefs: they are the live edit, and the prefs copy was
    // only written moments ago from these same fields.
    return ServicesHistoryModel.createNew(
      id: currentDocId ?? 'draft_${DateTime.now().millisecondsSinceEpoch}',
      state: ServiceDisplayStatus.draftState,
      status: status,
      serviceNameEnglish: nameEn,
      serviceNameArabic: nameAr,
      serviceDescriptionEnglish: descEn,
      serviceDescriptionArabic: descAr,
      durationOfServices: durationVal,
      selectedDurationUnit: durationUnit,
      imageUrl: imageUrl,
      providerServices: providers,
      selectDepartment: departments,
      approvalCycle: approvalCycle,
      limitAvailability: departments.isNotEmpty,
      requireApproval: approvalCycle.isNotEmpty,
      slaOneControllerEnglish: model.slaOneController.text.trim(),
      slaTwoControllerEnglish: model.slaTwoController.text.trim(),
      notifyRequesterChecked: model.notifyRequesterChecked,
      notifyProviderChecked: model.notifyProviderChecked,
      notifyManagerChecked: model.notifyManagerChecked,
      notifyRequesterSwitch0: model.notifyRequesterSwitch0,
      notifyManagerSwitch1: model.notifyManagerSwitch1,
    );
  }

  /// Function Name: [_stampDraftRecord]
  ///
  /// Purpose: Record [draftModel] as a DRAFT the current user owns.
  ///
  /// ADDED 26/8/2026. This is the step the SLA screen was missing entirely.
  /// Writing the service document is not enough to produce a draft: a draft is
  /// a document that also carries `draftMetadata` — `createdBy`, `draftState`,
  /// `currentPage`, `intendedStatus` — because that is what
  /// `FirebaseDraftRepository.getUserDrafts()` queries on and what the home
  /// page's ownership checks read. Without it the document exists and nothing
  /// can attribute it to anyone.
  ///
  /// The injected [saveDraft] is the Firebase write (see the page's
  /// `initState`); the SharedPrefs fallback is only reached when no callback
  /// was supplied, and is local-only — it cannot make a draft visible on the
  /// home page, so it is logged as such rather than passing quietly for a real
  /// save.
  ///
  /// Parameters:
  /// - [draftModel]: the model to record, carrying the id of the document that
  ///   has already been written so the draft record lands on the same one.
  ///
  /// Returns: [Future<bool>] false when the write threw — never swallowed, or
  /// the caller would report a success it cannot back up.
  Future<bool> _stampDraftRecord(ServicesHistoryModel draftModel) async {
    _sfl('_stampDraftRecord: id=${draftModel.currentId} '
        'saveDraftInjected=${saveDraft != null}');
    try {
      if (saveDraft != null) {
        await saveDraft!(draftModel);
        _sfl('_stampDraftRecord: OK');
      } else {
        await SharedPrefsServiceMaster.saveDraft(draftModel);
        _sfl('_stampDraftRecord: prefs-only fallback — NOT visible on the home page');
      }
      return true;
    } catch (e, stackTrace) {
      _sfl('_stampDraftRecord: THREW — $e');
      debugPrint('$stackTrace');
      return false;
    }
  }

  Future<void> _saveAllToSharedPrefs(BuildContext context) async {
    await SharedPrefsHelper.setString('sla_one', model.slaOneController.text.trim());
    await SharedPrefsHelper.setString('sla_two', model.slaTwoController.text.trim());
    await SharedPrefsHelper.setBool('Notify Service Requester_checked', model.notifyRequesterChecked);
    await SharedPrefsHelper.setBool('Notify Service Provider_checked', model.notifyProviderChecked);
    await SharedPrefsHelper.setBool('Notify Provider Manager_checked', model.notifyManagerChecked);

    final reqMap = model.notificationSwitches['notifyServiceRequester'] ?? {};
    final mgrMap = model.notificationSwitches['notifyProviderManager'] ?? {};
    model.notifyRequesterSwitch0 = reqMap[0] ?? false;
    model.notifyManagerSwitch1 = mgrMap[0] ?? false;

    await SharedPrefsHelper.setBool('notifyRequesterSwitch0', model.notifyRequesterSwitch0);
    await SharedPrefsHelper.setBool('notifyManagerSwitch1', model.notifyManagerSwitch1);

    await _saveExtraControllersToSharedPrefs();
  }

  String slug(String s) {
    return s
        .replaceAll(RegExp(r"[^\w]+"), "_")
        .replaceAll(RegExp(r"_+"), "_")
        .trim()
        .toLowerCase();
  }

  String getSubmitButtonText(BuildContext context, ServicesHistoryModel? editingModel, String submitText, String saveText) {
    if (editingModel == null) {
      return submitText;
    }

    final isDraft = editingModel.currentState == "draft" ||
        editingModel.currentDurationOfServices.isEmpty ||
        editingModel.currentDurationOfServices == "-";

    return isDraft ? submitText : saveText;
  }

  String getSaveForLaterText(BuildContext context, ServicesHistoryModel? editingModel, String submitText, String saveText) {
    if (editingModel == null) {
      return submitText;
    }

    final isDraft = editingModel.currentState == "draft" ||
        editingModel.currentDurationOfServices.isEmpty ||
        editingModel.currentDurationOfServices == "-";

    final isEditingSubmittedService = editingModel.currentState != "submitted";

    if (isEditingSubmittedService) {
      return saveText;
    } else if (isDraft) {
      return saveText;
    } else {
      return saveText;
    }
  }

  void _emitLoadedState() {
    emit(SlaNotificationLoaded(
      currentDocId: currentDocId,
      notifyRequesterChecked: model.notifyRequesterChecked,
      notifyProviderChecked: model.notifyProviderChecked,
      notifyManagerChecked: model.notifyManagerChecked,
      notifyRequesterSwitch0: model.notifyRequesterSwitch0,
      notifyManagerSwitch1: model.notifyManagerSwitch1,
      extraSlaList: model.extraSlaControllers.map((c) => c.text).toList(),
      extraSlaTwoList: model.extraSlaTwoControllers.map((c) => c.text).toList(),
      notificationSwitches: model.notificationSwitches,
    ));
  }

  @override
  Future<void> close() {
    model.dispose();
    return super.close();
  }
}
