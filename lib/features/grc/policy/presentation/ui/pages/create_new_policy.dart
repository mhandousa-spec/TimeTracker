/// Module: GRC Policy Management
/// Description: Three-step page for creating a new GRC policy.
///              Step 0: Policy info form.
///              Step 1: Add / edit controls.
///              Step 2: Full preview with controls table, weight validation,
///                      Equal Weight, and Publish action.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-06
/// Dependencies: Flutter SDK, AppColors, AppTheme, PolicyCubit,
///               PolicyControlsTableWidget
/// Revision History: 2026-07-01 - Initial creation
///                   2026-07-06 - Added step 2 preview, Draft/Publish status,
///                                Equal Weight, weight validation (Mohamed Elrashidy)
///                   2026-07-16 - Split step content and button rows into
///                                their own widget files (Mohamed Magdy Abdelkhalek)
library;

/// ************************* FILE INFO *************************** ///
/// File Name: create_new_policy.dart
/// Purpose: Contains CreateNewPolicyPage, the three-step form for policy
///          creation — step 0: policy info, step 1: controls, step 2: preview.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 1/7/2026

import 'package:knowticed_plus/features/grc/shared/helpers/grc_document_picker.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'dart:io';

// 11's own showUploadDialog is a near-duplicate of 10's — hidden here to
// avoid an ambiguous-import error; section 10 already demos the dedicated one.
import 'package:knowticed_plus/core/custom/11-custom_confirm_diaolog.dart'
    hide showUploadDialog;
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_status.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_status.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/controller/policy_cubit.dart';
import 'package:knowticed_plus/features/grc/control/presentation/controller/control_cubit.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/pages/add_policy_controls.dart';
import 'package:knowticed_plus/features/grc/module/presentation/ui/widgets/grc_details_widget/grc_form_fields.dart'
    show containsEnglishLetters, containsArabicLetters;
import 'package:knowticed_plus/features/grc/policy/presentation/ui/widgets/create_new_policy_widget/create_policy_step0.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/widgets/create_new_policy_widget/create_policy_step0_buttons.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/widgets/create_new_policy_widget/create_policy_buttons.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/widgets/create_new_policy_widget/create_policy_step2_preview.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/widgets/grc_policy_widget/policy_control_completeness.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/widgets/grc_policy_widget/policy_control_model.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_document_info.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import '../../../../../../core/custom/52-custom_upload_document.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_permissions.dart';
part '../widgets/create_new_policy_widget/create_new_policy_actions.dart';

/// class name: [CreateNewPolicyPage]
///
/// purpose: three-step page that collects policy info (step 0), manages
///          controls (step 1), then shows a full preview with the controls
///          table (step 2). The body switches in-place via [_step]; no new
///          routes are pushed.
///
///          Supported actions:
///           - Save For Later  → persists as [PolicyStatus.draft]
///           - Preview         → advances from step 1 to step 2
///           - Equal Weight    → distributes 100 equally across all controls
///           - Publish         → persists as [PolicyStatus.active] (requires
///                               total weight == 100)
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 1/7/2026
class CreateNewPolicyPage extends StatefulWidget {
  final String moduleId;
  final String moduleNameEn;
  final String moduleNameAr;

  /// Owners of the module this policy belongs to — the audience for every
  /// policy notification this page's saves produce. Passed in rather than
  /// fetched because the list screen already holds the GRCModuleEntity.
  final List<String> moduleOwners;

  /// When set, the wizard resumes this already-saved Draft instead of
  /// starting blank: Step 0 is prefilled from it and its saved Controls
  /// are fetched and prefilled into Step 1. Save For Later/Publish then
  /// update this same Policy instead of creating a new one.
  final PolicyEntity? existingPolicy;

  const CreateNewPolicyPage({
    super.key,
    required this.moduleId,
    required this.moduleNameEn,
    required this.moduleNameAr,
    this.moduleOwners = const <String>[],
    this.existingPolicy,
  });

  @override
  State<CreateNewPolicyPage> createState() => _CreateNewPolicyPageState();
}

class _CreateNewPolicyPageState extends State<CreateNewPolicyPage> {
  // ----------------------------------------------------------------
  // State
  // ----------------------------------------------------------------
  int _step = 0; // 0 = info, 1 = controls, 2 = preview

  /// Snapshot of every step 0 value as the page opened, used only when
  /// resuming a saved Draft: Next stays disabled until the user actually
  /// changes something, so "Next" on an untouched Draft is not a no-op.
  String? _initialStep0Signature;

  /// Lets the wizard leave the page for real while [_step] is still 1 or 2.
  /// The PopScope below turns a back gesture into "go back one step" on
  /// those steps, which would otherwise also swallow the programmatic pop
  /// that runs after a successful save.
  bool _allowPop = false;
  bool _isArabicEnabled = true;
  bool _step0Submitted = false;
  bool _controlsSubmitted = false;

  // Step 0 controllers
  final _nameController = TextEditingController();
  final _nameArController = TextEditingController();
  final _numberController = TextEditingController();
  final _numberArController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _descriptionArController = TextEditingController();
  final _weightController = TextEditingController();

  List<PolicyControlModel> _controls = [PolicyControlModel()];

  DateTime? _startDate;
  DateTime? _endDate;
  File? _imageFile;
  String? _imageUrl;
  PolicyDocumentInfo? _documentEn;
  PolicyDocumentInfo? _documentAr;

  /// Snapshot of the ids of controls already saved under [widget.existingPolicy]
  /// at the moment they were loaded — diffed against what's still touched
  /// in [_controls] at save time to know which ones the user removed.
  Set<String> _originalControlIds = {};

  // ----------------------------------------------------------------
  // Lifecycle
  // ----------------------------------------------------------------
  /// Every step 0 text controller, in one list so the change listener and
  /// the dispose loop cannot drift apart.
  List<TextEditingController> get _step0Controllers => [
        _nameController,
        _nameArController,
        _numberController,
        _numberArController,
        _descriptionController,
        _descriptionArController,
        _weightController,
      ];

  /// Rebuild on every keystroke so the Next button's enabled state tracks
  /// the form live instead of waiting for an unrelated setState.
  void _onStep0FieldChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    final existing = widget.existingPolicy;
    if (existing != null) {
      _nameController.text = existing.policyNameEn;
      _nameArController.text = existing.policyNameAr;
      _numberController.text = existing.policyNumberEn;
      _numberArController.text = existing.policyNumberAr;
      _descriptionController.text = existing.policyDescriptionEn;
      _descriptionArController.text = existing.policyDescriptionAr;
      _weightController.text = existing.policyWeight.toStringAsFixed(0);
      _startDate = existing.startDate;
      _endDate = existing.endDate;
      _imageUrl = existing.policyImage;
      _documentEn = existing.policyDocumentEn != null
          ? PolicyDocumentInfo.fromUrl(existing.policyDocumentEn!)
          : null;
      _documentAr = existing.policyDocumentAr != null
          ? PolicyDocumentInfo.fromUrl(existing.policyDocumentAr!)
          : null;
      // No stored toggle for this — infer it from whether any Arabic field
      // was ever filled in, the same way the fields themselves imply it.
      _isArabicEnabled = existing.policyNameAr.trim().isNotEmpty ||
          existing.policyNumberAr.trim().isNotEmpty ||
          existing.policyDescriptionAr.trim().isNotEmpty;
    }

    // Listeners go on AFTER the prefill above, so seeding the controllers
    // does not fire setState from inside initState, and the baseline below
    // describes the Draft exactly as it was saved.
    for (final c in _step0Controllers) {
      c.addListener(_onStep0FieldChanged);
    }
    _initialStep0Signature = _step0Signature();
  }

  @override
  void dispose() {
    for (final c in _step0Controllers) {
      c.removeListener(_onStep0FieldChanged);
    }
    _nameController.dispose();
    _nameArController.dispose();
    _numberController.dispose();
    _numberArController.dispose();
    _descriptionController.dispose();
    _descriptionArController.dispose();
    _weightController.dispose();
    for (final c in _controls) c.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------------
  // Helpers
  // ----------------------------------------------------------------

  /// function name: [_totalControlWeight]
  ///
  /// purpose: sum up the weight values entered for all controls.
  ///
  /// parameters: none
  ///
  /// return type: [double] - the current total control weight
  double get _totalControlWeight => _controls.fold(
        0,
        (sum, c) =>
            sum + (double.tryParse(c.weightController.text.trim()) ?? 0),
      );

  /// function name: [_touchedControls]
  ///
  /// purpose: the subset of [_controls] the user has actually entered data
  ///          into — see [controlIsTouched]. An untouched default control
  ///          card is not a "real" control.
  ///
  /// parameters: none
  ///
  /// return type: [List<PolicyControlModel>]
  List<PolicyControlModel> get _touchedControls =>
      _controls.where(controlIsTouched).toList();

  /// function name: [_hasIncompleteTouchedControl]
  ///
  /// purpose: true if any touched control is missing a required field —
  ///          see [controlIsComplete]. Used to block Preview until every
  ///          control the user started filling in is finished.
  ///
  /// parameters: none
  ///
  /// return type: [bool]
  bool get _hasIncompleteTouchedControl => _touchedControls.any(
      (c) => !controlIsComplete(c, isArabicEnabled: _isArabicEnabled));

  bool get _isWeightValid =>
      _touchedControls.isEmpty ||
      (_totalControlWeight - 100).abs() < 0.001;

  /// function name: [_canPreview]
  ///
  /// purpose: same conditions [_handlePreviewPressed] already checks before
  ///          allowing the step transition — reused here so the Preview
  ///          button itself is disabled/greyed while any of them fail,
  ///          instead of the button always being clickable and only then
  ///          surfacing per-field required errors (which fired the moment
  ///          any field anywhere was touched, not just the one being
  ///          edited).
  ///
  /// parameters: none
  ///
  /// return type: [bool]
  // CHANGED 28/9/2026 (GRC bug report p15): a policy may be created without
  // any control — the user can skip the control form and go straight to
  // Preview. Untouched blank control cards are ignored (they are also
  // skipped on publish, and the 100% weight rule only applies once a control
  // exists); only a control the user STARTED must be completed.
  bool get _canPreview =>
      !_hasPolicyLanguageErrors &&
      !_hasControlErrors &&
      !_hasIncompleteTouchedControl;

  void _onUploadDocumentEn() {
    // GRC bug report p16: straight to the file picker — the old
    // upload dialog's Document Title was never used.
    pickGrcDocument(context, (file) {
        setState(() => _documentEn = PolicyDocumentInfo.fromPlatformFile(file));
    });
  }

  void _onUploadDocumentAr() {
    // GRC bug report p16: straight to the file picker — the old
    // upload dialog's Document Title was never used.
    pickGrcDocument(context, (file) {
        setState(() => _documentAr = PolicyDocumentInfo.fromPlatformFile(file));
    });
  }

  /// function name: [_onStartDateChanged]
  ///
  /// purpose: update the start date and, if the previously selected end
  ///          date now falls before it, clear the end date so the user must
  ///          pick a new one.
  ///
  /// parameters:
  ///            [DateTime?] date: the newly selected start date
  ///
  /// return type: void
  void _onStartDateChanged(DateTime? date) {
    setState(() {
      _startDate = date;
      if (_endDate != null && date != null && _endDate!.isBefore(date)) {
        _endDate = null;
      }
    });
  }

  /// function name: [_step0Signature]
  ///
  /// purpose: a stable string describing every step 0 value, so resuming a
  ///          Draft can tell "nothing touched yet" from "edited".
  ///
  /// parameters: none
  ///
  /// return type: [String]
  String _step0Signature() {
    String doc(PolicyDocumentInfo? d) =>
        d == null ? '' : (d.url ?? d.file?.path ?? d.name);
    return [
      _nameController.text.trim(),
      _nameArController.text.trim(),
      _numberController.text.trim(),
      _numberArController.text.trim(),
      _descriptionController.text.trim(),
      _descriptionArController.text.trim(),
      _weightController.text.trim(),
      _startDate?.toIso8601String() ?? '',
      _endDate?.toIso8601String() ?? '',
      doc(_documentEn),
      doc(_documentAr),
      _imageFile?.path ?? _imageUrl ?? '',
      '$_isArabicEnabled',
    ].join('|');
  }

  /// function name: [_isWeightEntryValid]
  ///
  /// purpose: mirrors the Policy Weight field's own live validation -- a
  ///          positive number no greater than 100 -- so the Next button is
  ///          not enabled over a value the field itself is flagging red.
  ///
  /// parameters: none
  ///
  /// return type: [bool]
  bool get _isWeightEntryValid {
    final value = double.tryParse(_weightController.text.trim());
    return value != null && value > 0 && value <= 100;
  }

  /// function name: [_isStep0Complete]
  ///
  /// purpose: true once every required step 0 input is present -- the three
  ///          English fields, both dates in a valid order, a valid weight,
  ///          and (when the Arabic version is switched on) the three Arabic
  ///          fields.
  ///
  ///          The policy IMAGE and the policy DOCUMENTS (ENG and AR) are
  ///          deliberately NOT required: a policy can be drafted before its
  ///          PDF exists, and blocking Next on an upload stranded anyone who
  ///          had the text but not the file yet. They stay uploadable here
  ///          and are still shown on the preview step.
  ///
  /// parameters: none
  ///
  /// return type: [bool]
  bool get _isStep0Complete {
    if (_nameController.text.trim().isEmpty) return false;
    if (_numberController.text.trim().isEmpty) return false;
    if (_descriptionController.text.trim().isEmpty) return false;
    if (_startDate == null || _endDate == null) return false;
    if (_endDate!.isBefore(_startDate!)) return false;
    if (!_isWeightEntryValid) return false;
    if (_isArabicEnabled) {
      if (_nameArController.text.trim().isEmpty) return false;
      if (_numberArController.text.trim().isEmpty) return false;
      if (_descriptionArController.text.trim().isEmpty) return false;
    }
    return !_hasPolicyLanguageErrors;
  }

  /// function name: [_step0HasChanges]
  ///
  /// purpose: for a brand new policy, always true. For a Draft reopened
  ///          through [CreateNewPolicyPage.existingPolicy], true only once
  ///          the user has changed one of the step 0 values.
  ///
  /// parameters: none
  ///
  /// return type: [bool]
  bool get _step0HasChanges {
    if (widget.existingPolicy == null) return true;
    if (_initialStep0Signature == null) return true;
    return _step0Signature() != _initialStep0Signature;
  }

  /// function name: [_canGoNext]
  ///
  /// purpose: the enabled state of step 0's Next button.
  ///
  /// parameters: none
  ///
  /// return type: [bool]
  bool get _canGoNext => _isStep0Complete && _step0HasChanges;

  /// function name: [_hasPolicyLanguageErrors]
  ///
  /// purpose: true if any policy-level EN/AR field currently shows a
  ///          language-mismatch error (English field containing Arabic
  ///          letters, or vice versa). Used to block Publish/Save For Later
  ///          until the user fixes highlighted errors.
  bool get _hasPolicyLanguageErrors {
    if (containsArabicLetters(_nameController.text)) return true;
    if (containsArabicLetters(_numberController.text)) return true;
    if (containsArabicLetters(_descriptionController.text)) return true;
    if (_isArabicEnabled) {
      if (containsEnglishLetters(_nameArController.text)) return true;
      if (containsEnglishLetters(_numberArController.text)) return true;
      if (containsEnglishLetters(_descriptionArController.text)) return true;
    }
    return false;
  }

  /// function name: [_controlHasErrors]
  ///
  /// purpose: true if [control] currently shows a language-mismatch error
  ///          on Name/Number/Description, or a date-range error (its own
  ///          End Date before its Start Date, or either date falling
  ///          outside the parent Policy's own Start/End Date range).
  bool _controlHasErrors(PolicyControlModel control) {
    if (containsArabicLetters(control.nameController.text)) return true;
    if (containsArabicLetters(control.numberController.text)) return true;
    if (containsArabicLetters(control.descriptionController.text)) return true;
    if (_isArabicEnabled) {
      if (containsEnglishLetters(control.nameArController.text)) return true;
      if (containsEnglishLetters(control.numberArController.text)) return true;
      if (containsEnglishLetters(control.descriptionArController.text))
        return true;
    }
    final start = control.startDate;
    final end = control.endDate;
    if (start != null && end != null && end.isBefore(start)) return true;
    for (final date in [start, end]) {
      if (date == null) continue;
      if (_startDate != null && date.isBefore(_startDate!)) return true;
      if (_endDate != null && date.isAfter(_endDate!)) return true;
    }
    return false;
  }

  /// function name: [_hasControlErrors]
  ///
  /// purpose: true if any filled-in control (non-empty English name — the
  ///          same filter [_buildPendingControls] uses to decide which
  ///          controls are actually sent to the cubit) currently has a
  ///          language or date-range error.
  bool get _hasControlErrors => _controls.any(
      (c) => c.nameController.text.trim().isNotEmpty && _controlHasErrors(c));

  /// function name: [_showBlockingErrorsDialog]
  ///
  /// purpose: show the shared error dialog used whenever Save For Later or
  ///          Publish is blocked by an unresolved validation error.
  void _showBlockingErrorsDialog() {
    CustomDialogManager.showMessage(
      context: context,
      lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
      title: S.of(context).unsuccessful,
      subtitle: S.of(context).pleaseFixTheHighlightedErrorsBeforeContinuing,
    );
  }

  // ----------------------------------------------------------------
  // Button-row press handlers
  // ----------------------------------------------------------------

  void _handleDiscardPressed() {
    showConfirmDialog(
      context: context,
      title: S.of(context).discardPolicy,
      subtitle:
          S.of(context).areYouSureYouWantToDiscardThisPolicy,
      confirmLabel: S.of(context).discard,
      cancelLabel: S.of(context).Cancel,
      onConfirm: () => Navigator.of(context).pop(),
    );
  }

  /// function name: [_handleNextPressed]
  ///
  /// purpose: step 0's Next action. The button is already greyed out while
  ///          [_canGoNext] is false, so this can only ever advance on a
  ///          complete (and, for a resumed Draft, changed) form. Tapping it
  ///          while it is greyed does not move the wizard -- it marks the
  ///          form as submitted so the required-field errors light up, and
  ///          says which of the two reasons is blocking, so the user is not
  ///          left guessing at a dead button.
  ///
  /// parameters: none
  ///
  /// return type: void
  void _handleNextPressed() {
    setState(() => _step0Submitted = true);
    if (!_isStep0Complete) {
      CustomDialogManager.showMessage(
        context: context,
        lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
        title: S.of(context).unsuccessful,
        subtitle: S.of(context).fillAllRequiredFields,
      );
      return;
    }
    if (!_step0HasChanges) {
      CustomDialogManager.showMessage(
        context: context,
        lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
        title: S.of(context).unsuccessful,
        subtitle: S.of(context).makeAChangeBeforeContinuing,
      );
      return;
    }
    setState(() => _step = 1);
  }

  void _handleSaveForLaterPressed(PolicyCubit cubit) {
    if (_hasPolicyLanguageErrors || _hasControlErrors) {
      _showBlockingErrorsDialog();
      return;
    }
    showConfirmDialog(
      context: context,
      title: S.of(context).saveAsDraft,
      subtitle: S.of(context).areYouSureYouWantToSaveThisPolicyAsADraft,
      confirmLabel: S.of(context).Save,
      cancelLabel: S.of(context).Cancel,
      onConfirm: () => _onSaveForLater(cubit),
    );
  }

  /// function name: [_handlePreviewPressed]
  ///
  /// purpose: step 1's Preview action. The button is greyed while
  ///          [_canPreview] is false; tapping it there does not advance, but
  ///          it does mark the controls submitted so the required-field
  ///          errors light up and says what is missing, rather than being a
  ///          silent dead button.
  ///
  /// parameters: none
  ///
  /// return type: void
  void _handlePreviewPressed() {
    // Policy-level errors live on step 0, out of sight from here, so they
    // still need the dialog to explain why nothing happens.
    if (_hasPolicyLanguageErrors) {
      setState(() => _controlsSubmitted = true);
      _showBlockingErrorsDialog();
      return;
    }
    // CHANGED 28/9/2026 (GRC bug report p14/p15): control errors are on this
    // screen, so no "Unsuccessful" dialog — just turn the red borders on.
    // And no controls at all is allowed (see [_canPreview]).
    if (_hasControlErrors || _hasIncompleteTouchedControl) {
      setState(() => _controlsSubmitted = true);
      return;
    }
    setState(() => _step = 2);
  }

  void _handlePublishPressed(PolicyCubit cubit) {
    if (!_isWeightValid) {
      CustomDialogManager.showMessage(
        context: context,
        lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
        title: S.of(context).unsuccessful,
        subtitle: S.of(context).totalWeightShouldBe100,
      );
      return;
    }
    if (_hasPolicyLanguageErrors || _hasControlErrors) {
      _showBlockingErrorsDialog();
      return;
    }
    showConfirmDialog(
      context: context,
      title: S.of(context).publishPolicy,
      subtitle:
          S.of(context).areYouSureYouWantToPublishThisPolicy,
      confirmLabel: S.of(context).publish,
      cancelLabel: S.of(context).Cancel,
      onConfirm: () => _onPublish(cubit),
    );
  }

  // ----------------------------------------------------------------
  // BlocListener callback
  // ----------------------------------------------------------------

  /// function name: [_onStateChange]
  ///
  /// purpose: react to [PolicyState] changes emitted by [PolicyCubit]:
  ///          show / hide the loading indicator, display success dialogs,
  ///          and show error snackbars.
  ///
  /// parameters:
  ///            [BuildContext] context: the current build context
  ///            [PolicyState] state: the newly emitted state
  ///
  /// return type: void
  /// function name: [_leavePage]
  ///
  /// purpose: pop the wizard regardless of which step it is on -- opens the
  ///          PopScope gate first, then pops on the next frame so the gate
  ///          is actually in effect by the time the pop is dispatched.
  ///
  /// parameters:
  ///            [Object?] result: value handed back to the pushing route
  ///
  /// return type: void
  void _leavePage([Object? result]) {
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop(result);
    });
  }

  void _onStateChange(BuildContext context, PolicyState state) {
    if (state is PolicyLoading) {
      showLoadingIndicator();
      return;
    }
    hideLoadingIndicator();

    if (state is PolicyActionSuccess) {
      final isDraft = state.policy.status == PolicyStatus.draft;
      showSuccessDialog(
        context: context,
        title: isDraft ? S.of(context).savedAsDraft : S.of(context).policyCreated,
        subtitle: isDraft
            ? S.of(context).policySavedAsDraftSuccessfully
            : S.of(context).youSuccessfullyCreatedThisPolicy,
      );
      _leavePage(true);
      return;
    }

    if (state is PolicyActionPartialSuccess) {
      // The Policy itself was saved/updated successfully at this point —
      // only one or more of its Controls failed. Surface that instead of
      // staying silent, and still leave: the list needs to reflect the
      // Policy's new state either way.
      final reasons =
          state.failedControls.map((f) => f.message).toSet().join('; ');
      CustomDialogManager.showMessage(
        context: context,
        lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
        title: S.of(context).unsuccessful,
        subtitle: '${S.of(context).policySavedButOneOrMoreControlsFailedToSave} $reasons',
      );
      _leavePage(true);
      return;
    }

    if (state is PolicyFailure) {
      CustomDialogManager.showMessage(
        context: context,
        lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
        title: S.of(context).unsuccessful,
        subtitle: state.message,
      );
    }
  }

  void _onControlStateChange(BuildContext context, ControlState state) {
    if (state is ControlsListLoaded) {
      if (widget.existingPolicy == null) return;
      _originalControlIds = state.controls.map((c) => c.id).toSet();
      setState(() {
        for (final c in _controls) c.dispose();
        _controls = state.controls.isEmpty
            ? [PolicyControlModel()]
            : state.controls.map(_controlModelFromEntity).toList();
      });
    }
  }

  // ----------------------------------------------------------------
  // Build
  // ----------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PolicyCubit>(create: (_) => GetIt.instance<PolicyCubit>()),
        BlocProvider<ControlCubit>(
          create: (_) {
            final cubit = GetIt.instance<ControlCubit>();
            final existing = widget.existingPolicy;
            if (existing != null) {
              cubit.getAllControls(
                moduleId: widget.moduleId,
                policyId: existing.id,
              );
            }
            return cubit;
          },
        ),
      ],
      child: Builder(
        builder: (ctx) {
          final cubit = ctx.read<PolicyCubit>();
          return MultiBlocListener(
            listeners: [
              BlocListener<PolicyCubit, PolicyState>(listener: _onStateChange),
              BlocListener<ControlCubit, ControlState>(
                listener: _onControlStateChange,
              ),
            ],
            child: PopScope(
              // Steps 1 and 2 have no Back button of their own on phone and
              // iPad (the design puts a single Save For Later / primary
              // action row there), so the app bar's back arrow -- and the
              // system back gesture -- walk back through the wizard first
              // and only leave the page from step 0.
              canPop: _step == 0 || _allowPop,
              onPopInvokedWithResult: (bool didPop, Object? result) {
                if (didPop || _step == 0) return;
                setState(() => _step -= 1);
              },
              // The frame owns the Scaffold, the breadcrumb and the side
              // padding this page used to build by hand. Crumb taps pop the
              // same number of routes PaginationAppBar popped for them.
              child: SideFrameMasterServices(
                titleText: S.of(ctx).grc,
                onFirstTap: () => popFrameRoutes(ctx, 2),
                secondTitle:
                    ctx.isArabic ? widget.moduleNameAr : widget.moduleNameEn,
                onSecondTap: () => popFrameRoutes(ctx, 1),
                thirdTitle: S.of(ctx).createNewPolicy,
                // The step body is an Expanded with a pinned button row under
                // it, and the frame's phone branch hands down an unbounded
                // height. This bounds it there, and is a no-op on tablet.
                child: SideFrameBoundedBody(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildCurrentStep()),
                      SizedBox(height: 16.h),
                      _buildButtons(cubit),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case 0:
        return _buildStep0();
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      default:
        return _buildStep0();
    }
  }

  // ----------------------------------------------------------------
  // Step 0: Policy Info
  // ----------------------------------------------------------------
  Widget _buildStep0() {
    return CreatePolicyStep0(
      isArabicEnabled: _isArabicEnabled,
      onArabicToggle: (v) => setState(() => _isArabicEnabled = v),
      imageFile: _imageFile,
      onImagePicked: (file) => setState(() => _imageFile = file),
      submitted: _step0Submitted,
      nameController: _nameController,
      nameArController: _nameArController,
      numberController: _numberController,
      numberArController: _numberArController,
      descriptionController: _descriptionController,
      descriptionArController: _descriptionArController,
      weightController: _weightController,
      startDate: _startDate,
      endDate: _endDate,
      onStartDateChanged: _onStartDateChanged,
      onEndDateChanged: (d) => setState(() => _endDate = d),
      documentEn: _documentEn,
      documentAr: _documentAr,
      onUploadDocumentEn: _onUploadDocumentEn,
      onUploadDocumentAr: _onUploadDocumentAr,
      onRemoveDocumentEn: () => setState(() => _documentEn = null),
      onRemoveDocumentAr: () => setState(() => _documentAr = null),
    );
  }

  // ----------------------------------------------------------------
  // Step 1: Controls
  // ----------------------------------------------------------------
  Widget _buildStep1() {
    return AddPolicyControlsPage(
      isArabicEnabled: _isArabicEnabled,
      controls: _controls,
      policyStartDate: _startDate,
      policyEndDate: _endDate,
      controlsSubmitted: _controlsSubmitted,
      // Rebuilds on every keystroke in any control card so the Preview
      // button's grey/enabled state (_canPreview) updates live instead of
      // only refreshing on the next unrelated setState.
      onChanged: () => setState(() {}),
    );
  }

  // ----------------------------------------------------------------
  // Step 2: Preview — policy summary + controls table
  // ----------------------------------------------------------------
  Widget _buildStep2() {
    return CreatePolicyStep2Preview(
      onUploadDocumentEn: _onUploadDocumentEn,
      onUploadDocumentAr: _onUploadDocumentAr,
      onRemoveDocumentEn: () => setState(() => _documentEn = null),
      onRemoveDocumentAr: () => setState(() => _documentAr = null),
      isArabicEnabled: _isArabicEnabled,
      nameController: _nameController,
      nameArController: _nameArController,
      numberController: _numberController,
      numberArController: _numberArController,
      descriptionController: _descriptionController,
      descriptionArController: _descriptionArController,
      weightController: _weightController,
      startDate: _startDate,
      endDate: _endDate,
      imageFile: _imageFile,
      imageUrl: _imageUrl,
      documentEn: _documentEn,
      documentAr: _documentAr,
      touchedControls: _touchedControls,
      onControlsChanged: () => setState(() {}),
    );
  }

  // ----------------------------------------------------------------
  // Buttons row per step
  // ----------------------------------------------------------------

  /// function name: [_buildButtons]
  ///
  /// purpose: render the correct bottom-action buttons depending on the
  ///          current step.
  ///
  /// parameters:
  ///            [PolicyCubit] cubit: the cubit instance from the BlocProvider
  ///
  /// return type: [Widget]
  Widget _buildButtons(PolicyCubit cubit) {
    switch (_step) {
      case 0:
        return CreatePolicyStep0Buttons(
          onDiscard: _handleDiscardPressed,
          onNext: _handleNextPressed,
          nextEnabled: _canGoNext,
        );
      case 1:
        return CreatePolicyBackSaveButtons(
          showSaveForLater: GrcPermission.canDraftPolicy,
          onBack: () => setState(() => _step = 0),
          onSaveForLater: () => _handleSaveForLaterPressed(cubit),
          trailingButton: customButton(
            title: S.of(context).preview,
            // Always wired: the greyed state comes from the colour below,
            // and the handler is what explains WHY it is greyed.
            function: _handlePreviewPressed,
            height: 38.h,
            width: 150.w,
            color: _canPreview ? AppColors.primary : AppColors.colorGrey,
            textStyle: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.textButton),
          ),
        );
      case 2:
        return CreatePolicyBackSaveButtons(
          showSaveForLater: GrcPermission.canDraftPolicy,
          onBack: () => setState(() => _step = 1),
          onSaveForLater: () => _handleSaveForLaterPressed(cubit),
          trailingButton: customButton(
            title: S.of(context).publish,
            function: () => _handlePublishPressed(cubit),
            height: 38.h,
            width: 150.w,
            color: AppColors.primary,
            textStyle: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.textButton),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
