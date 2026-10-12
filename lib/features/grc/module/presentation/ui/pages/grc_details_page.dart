/// Module: GRC Module Management
/// Description: Provides the details page UI for viewing, creating, editing,
///              and restoring GRC Module records.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-06-28
/// Dependencies: flutter_bloc, GRCModuleCubit, GRCModuleEntity, get_it
/// Revision History: 2026-06-28 - Initial creation
///                    2026-06-30 - Connected to GRCModuleCubit (Mohamed Magdy Abdelkhalek)
///                    2026-07-21 - Auto-activate status only on activation-date change (Mohamed Magdy Abdelkhalek)
library;

/// ************************* FILE INFO *************************** ///
/// File Name: grc_details_page.dart
/// Purpose: Contains the GovernanceRiskAndComplianceDetails page, which
///          handles view, create, edit, and restore modes for a GRC Module.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 28/6/2026

import 'dart:io';

import 'package:knowticed_plus/core/custom/11-custom_confirm_diaolog.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_status.dart';
import 'package:knowticed_plus/features/grc/module/presentation/controller/cubit/grc_module_cubit.dart';
import 'package:knowticed_plus/features/grc/module/presentation/ui/widgets/grc_details_widget/grc_action_buttons.dart';
import 'package:knowticed_plus/features/grc/module/presentation/ui/widgets/grc_details_widget/grc_bottom_buttons.dart';
import 'package:knowticed_plus/features/grc/module/presentation/ui/widgets/grc_details_widget/grc_form_fields.dart';
import 'package:knowticed_plus/features/grc/module/presentation/ui/widgets/grc_details_widget/grc_owner_section.dart';
import 'package:knowticed_plus/features/grc/module/presentation/ui/widgets/grc_details_widget/grc_status_switch.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_l10n.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_permissions.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// enum name: [GrcPageMode]
///
/// purpose: describes the active interaction mode of
///          [GovernanceRiskAndComplianceDetails] so the page can show the
///          correct widgets and route user actions to the right cubit call.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 28/6/2026
enum GrcPageMode { view, edit, create, restore }

/// class name: [GovernanceRiskAndComplianceDetails]
///
/// purpose: stateful page that handles all CRUD modes for a single GRC Module.
///          Receives an optional [entity] to pre-fill the form in view / edit /
///          restore modes, and delegates every action to [GRCModuleCubit].
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 28/6/2026
class GovernanceRiskAndComplianceDetails extends StatefulWidget {
  final GrcPageMode mode;

  /// Entity to pre-fill the form in view / edit / restore modes.
  /// Null when [mode] is [GrcPageMode.create].
  final GRCModuleEntity? entity;
  final bool autoDelete;

  const GovernanceRiskAndComplianceDetails({
    super.key,
    this.mode = GrcPageMode.create,
    this.entity,
    this.autoDelete = false,
  });

  @override
  State<GovernanceRiskAndComplianceDetails> createState() =>
      _GovernanceRiskAndComplianceDetailsState();
}

class _GovernanceRiskAndComplianceDetailsState
    extends State<GovernanceRiskAndComplianceDetails> {
  final _nameEnController = TextEditingController();
  final _nameArController = TextEditingController();
  final _descEnController = TextEditingController();
  final _descArController = TextEditingController();

  String? _selectedDepartment;
  DateTime? _activationDate;
  bool _statusValue = true;
  late GrcPageMode _currentMode;
  List<String> _selectedOwnerEmails = [];
  File? _imageFile;
  bool _submitted = false;
  bool _autoDeleteScheduled = false;

  @override
  void initState() {
    super.initState();
    _currentMode = widget.mode;
    _prefillFromEntity(widget.entity);

    // The Save/Publish button is greyed out until the form is complete, so the
    // page has to rebuild as the user types — otherwise the button would only
    // wake up on some unrelated setState.
    for (final TextEditingController c in <TextEditingController>[
      _nameEnController,
      _nameArController,
      _descEnController,
      _descArController,
    ]) {
      c.addListener(_onFormChanged);
    }
  }

  void _onFormChanged() {
    if (mounted) setState(() {});
  }

  /// Populate form fields from an existing entity (view / edit / restore modes).
  void _prefillFromEntity(GRCModuleEntity? entity) {
    if (entity == null) return;
    _nameEnController.text = entity.moduleNameEn;
    _nameArController.text = entity.moduleNameAr;
    _descEnController.text = entity.moduleDescriptionEn;
    _descArController.text = entity.moduleDescriptionAr;
    _selectedDepartment = entity.moduleOwningDepartment;
    _activationDate = entity.moduleActivationDate;
    _statusValue = _isEnabledStatus(entity.status);
    _selectedOwnerEmails = List.from(entity.moduleOwners);
  }

  /// Whether [status] should show the toggle ON.
  ///
  /// THE BUG THIS FIXES — and it caused both reported symptoms at once.
  ///
  /// This used to be `entity.status == 'Active'`, a two-state bool standing in
  /// for a FOUR-state status. GRCModuleModel.toEntity() DERIVES the status on
  /// every read: a module whose activation date has not arrived yet reads back
  /// as 'Scheduled', not 'Active'. So:
  ///
  ///   * Create a module dated today or later, reopen it, and the switch sat
  ///     OFF — the record was Scheduled, which `== 'Active'` calls false. That
  ///     is the "created module shows as inactive".
  ///
  ///   * Flip that switch ON and save, and the page sent 'Active' — which
  ///     _deriveStatus turned straight back into 'Scheduled' for a future
  ///     date, so it read as OFF again. The switch genuinely could not be
  ///     turned on. That is the "switch does not toggle".
  ///
  /// Scheduled is an ENABLED state — active, pending its date — so it belongs
  /// with Active. Only Inactive and Removed are off. With that, ON round-trips
  /// (send 'Active' → stored Active or Scheduled → reads ON) and OFF
  /// round-trips (send 'Inactive' → sticky in _deriveStatus → reads OFF).
  bool _isEnabledStatus(String status) {
    final GrcModuleStatus parsed = GrcModuleStatus.fromString(status);
    return parsed == GrcModuleStatus.active ||
        parsed == GrcModuleStatus.scheduled;
  }

  /// Localized name of the module being viewed/edited/restored, or '' in
  /// create mode (no entity yet). Capitalizes only the first character —
  /// display formatting, doesn't touch how the name is stored.
  String _moduleDisplayName(BuildContext context) {
    if (widget.entity == null) return '';
    final name = widget.entity!.localizedName(isArabic: context.isArabic);
    if (name.isEmpty) return name;
    return name[0].toUpperCase() + name.substring(1);
  }

  @override
  void dispose() {
    for (final TextEditingController c in <TextEditingController>[
      _nameEnController,
      _nameArController,
      _descEnController,
      _descArController,
    ]) {
      c.removeListener(_onFormChanged);
    }
    _nameEnController.dispose();
    _nameArController.dispose();
    _descEnController.dispose();
    _descArController.dispose();
    super.dispose();
  }

  /// Every rule [_validate] enforces, WITHOUT flipping [_submitted].
  ///
  /// [_validate] runs on tap and turns the red error text on as a side effect,
  /// so it cannot be called from build() — it would paint every field red
  /// before the user has typed anything. This is the same condition as a pure
  /// query, used to decide whether the Save/Publish button is live.
  ///
  /// It adds one rule [_validate] does not have: at least one Module Owner
  /// must be ticked. A module with no owner has nobody to notify and nobody
  /// responsible for it, and the owner list is a checkbox grid with no
  /// "required" affordance of its own.
  bool get _isFormComplete {
    return _nameEnController.text.trim().isNotEmpty &&
        _nameArController.text.trim().isNotEmpty &&
        _descEnController.text.trim().isNotEmpty &&
        _descArController.text.trim().isNotEmpty &&
        !containsArabicLetters(_nameEnController.text) &&
        !containsEnglishLetters(_nameArController.text) &&
        !containsArabicLetters(_descEnController.text) &&
        !containsEnglishLetters(_descArController.text) &&
        _selectedDepartment != null &&
        _activationDate != null &&
        _selectedOwnerEmails.isNotEmpty;
  }

  /// Whether anything on the form differs from what is actually saved.
  ///
  /// ADDED 13/9/2026. Complete is not the same as changed: opening an existing
  /// module in Edit prefills every field from the entity, so the form is
  /// already "complete" and Save lit up immediately — inviting a write that
  /// stores a new identical revision. GRCModuleModel keeps one entry per
  /// revision in a history list, so a no-op save is not free: it grows every
  /// field by one and shows up as a real edit in Previous Module Owners.
  ///
  /// Compared against `widget.entity` rather than a snapshot taken on entry:
  /// the entity IS the saved state, so this answers the exact question the
  /// button needs — "is there anything to write?".
  ///
  /// Create mode has nothing to compare against, so it is always "changed".
  bool get _hasChanges {
    final GRCModuleEntity? e = widget.entity;
    if (e == null) return true;

    // Dates: compared by day, because that is the granularity the picker
    // offers — an identical day with a different time is not an edit.
    final DateTime? d = _activationDate;
    final bool dateChanged = d == null ||
        d.year != e.moduleActivationDate.year ||
        d.month != e.moduleActivationDate.month ||
        d.day != e.moduleActivationDate.day;

    // Owners: order is a UI artefact of the grid, so membership is what counts.
    final Set<String> nowOwners = _selectedOwnerEmails.toSet();
    final Set<String> savedOwners = e.moduleOwners.toSet();
    final bool ownersChanged = nowOwners.length != savedOwners.length ||
        !nowOwners.containsAll(savedOwners);

    return _nameEnController.text.trim() != e.moduleNameEn.trim() ||
        _nameArController.text.trim() != e.moduleNameAr.trim() ||
        _descEnController.text.trim() != e.moduleDescriptionEn.trim() ||
        _descArController.text.trim() != e.moduleDescriptionAr.trim() ||
        _selectedDepartment != e.moduleOwningDepartment ||
        dateChanged ||
        ownersChanged ||
        _statusValue != _isEnabledStatus(e.status) ||
        // A picked file is a change by definition — there is nothing on the
        // entity to compare a local File against.
        _imageFile != null;
  }

  bool _validate() {
    setState(() => _submitted = true);

    return _nameEnController.text.trim().isNotEmpty &&
        _nameArController.text.trim().isNotEmpty &&
        _descEnController.text.trim().isNotEmpty &&
        _descArController.text.trim().isNotEmpty &&
        !containsArabicLetters(_nameEnController.text) &&
        !containsEnglishLetters(_nameArController.text) &&
        !containsArabicLetters(_descEnController.text) &&
        !containsEnglishLetters(_descArController.text) &&
        _selectedDepartment != null &&
        _activationDate != null;
  }

  // ── Cubit action helpers ──────────────────────────────────────────────────

  void _onCreate(GRCModuleCubit cubit) {
    cubit.createModule(
      grcModuleNameEnglish: _nameEnController.text.trim(),
      grcModuleNameArabic: _nameArController.text.trim(),
      descriptionEnglish: _descEnController.text.trim(),
      descriptionArabic: _descArController.text.trim(),
      owningDepartment: _selectedDepartment ?? '',
      activationDate: _activationDate ?? DateTime.now(),
      owners: _selectedOwnerEmails,
      status: _statusValue
          ? GrcModuleStatus.active.value
          : GrcModuleStatus.inactive.value,
      imageFile: _imageFile,
    );
  }

  void _onUpdate(GRCModuleCubit cubit) {
    cubit.updateModule(
      id: widget.entity!.moduleId,
      grcModuleNameEnglish: _nameEnController.text.trim(),
      grcModuleNameArabic: _nameArController.text.trim(),
      descriptionEnglish: _descEnController.text.trim(),
      descriptionArabic: _descArController.text.trim(),
      owningDepartment: _selectedDepartment,
      activationDate: _activationDate,
      owners: _selectedOwnerEmails,
      status: _statusValue
          ? GrcModuleStatus.active.value
          : GrcModuleStatus.inactive.value,
      imageFile: _imageFile,
    );
  }

  void _onDelete(GRCModuleCubit cubit) {
    cubit.deleteModule(id: widget.entity!.moduleId);
  }

  void _onRestore(GRCModuleCubit cubit) {
    cubit.restoreModule(id: widget.entity!.moduleId);
  }

  void _scheduleAutoDelete(BuildContext context, GRCModuleCubit cubit) {
    if (!widget.autoDelete || _autoDeleteScheduled || widget.entity == null) {
      return;
    }
    _autoDeleteScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      showConfirmDialog(
        context: context,
        title: S.of(context).deletingGrcModule,
        cancelLabel: S.of(context).no,
        confirmLabel: S.of(context).yes,
        // Same fix as GrcActionButtons: `iconWidget` suppresses the dialog's
        // Lottie, so this delete confirm — the one reached by picking Delete
        // from a card's "..." menu — showed a static icon.
        lottieAsset: AppAssets.trash,
        subtitle: S.of(context).areYouSureYouWantToDeleteThisGrcModule,
        onConfirm: () {
          _pendingAction = _PendingAction.delete;
          _onDelete(cubit);
        },
      );
    });
  }

  // ── State listener ────────────────────────────────────────────────────────

  /// Whether THIS page opened the loading overlay that is currently up.
  bool _loaderShown = false;

  /// Set once this page has handled its own action result and is popping.
  bool _finished = false;

  void _onStateChange(BuildContext context, GRCModuleState state) {
    // FIXED 28/9/2026 (GRC bug report p12 — "when make edit it pauses on this
    // view"). The cubit is shared with the list page. After a success this
    // page pops and the list immediately calls getAllModules(), which emits
    // GRCModuleLoading while this page is still mounted (its pop animation is
    // running). This listener used to answer that with showLoadingIndicator()
    // — a loader drawn over the success dialog that nobody ever hid, because
    // the page was disposed before GRCModuleListLoaded arrived. Once this
    // page has its result it ignores everything after it, and it only ever
    // hides a loader it opened itself (hideLoadingIndicator is a bare
    // Get.back() that would otherwise pop whatever is on top).
    if (_finished) return;

    if (state is GRCModuleLoading) {
      if (!_loaderShown) {
        _loaderShown = true;
        showLoadingIndicator();
      }
      return;
    }
    if (_loaderShown) {
      _loaderShown = false;
      hideLoadingIndicator();
    }

    if (state is GRCModuleActionSuccess) {
      _finished = true;
      final isDelete = _pendingAction == _PendingAction.delete;
      final isRestore = _pendingAction == _PendingAction.restore;
      final isCreate = _currentMode == GrcPageMode.create;

      showSuccessDialog(
        context: context,
        title: isDelete
            ? S.of(context).deletedGrcModule
            : isRestore
                ? S.of(context).restoredModules
                : isCreate
                    ? S.of(context).createdModules
                    : S.of(context).editedModules,
        subtitle: isDelete
            ? S.of(context).successfullyDeletedGrc
            : isRestore
                ? S.of(context).successfullyRestoredGrc
                : isCreate
                    ? S.of(context).successfullyCreatedGrc
                    : S.of(context).successfullyEditedGrc,
      );
      // pop with true so the list page knows to reload
      Navigator.of(context).pop(true);
      return;
    }

    if (state is GRCModuleFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  _PendingAction _pendingAction = _PendingAction.none;

  /// Called ONLY when the user changes the activation date.
  /// If the new date is today OR in the future, auto-flip status to Active.
  /// Does not run on submit / status toggle — keeps the two concerns separate.
  void _onActivationDateChanged(DateTime? newDate) {
    setState(() {
      _activationDate = newDate;

      if (newDate != null && !_isBeforeToday(newDate)) {
        _statusValue = true;
      }
    });
  }

  /// Called ONLY when the user manually toggles the status switch.
  /// Never re-checks the activation date — a manual choice always wins,
  /// even if today happens to be the activation date.
  void _onStatusChanged(bool newValue) {
    setState(() => _statusValue = newValue);
  }

  bool _isBeforeToday(DateTime date) {
    final today = DateTime.now();
    final d = DateTime(date.year, date.month, date.day);
    final t = DateTime(today.year, today.month, today.day);
    return d.isBefore(t);
  }

  @override
  Widget build(BuildContext context) {
    // The GRCModuleCubit is provided by the page that pushed this route
    // (GovernanceRiskAndCompliancePage hands its own instance down via
    // BlocProvider.value) so the list and this page share ONE cubit instance
    // and never diverge. This page reads that shared instance — it must NOT
    // create a second one from GetIt.
    return Builder(
      builder: (ctx) {
        final cubit = ctx.read<GRCModuleCubit>();
          _scheduleAutoDelete(ctx, cubit);
          // Second crumb: what this page is doing to the module right now.
          // Same three cases the PaginationAppBar spelled out, lifted to a
          // local because the frame takes it as one string rather than a list.
          final String modeCrumb = _currentMode == GrcPageMode.create
              ? S.of(ctx).createNewGrcModule
              : _currentMode == GrcPageMode.edit
                  ? '${S.of(ctx).Edit} ${_moduleDisplayName(context)}'
                  : _moduleDisplayName(context);

          return BlocListener<GRCModuleCubit, GRCModuleState>(
            listener: _onStateChange,
            // SideFrameMasterServices supplies the Scaffold (phone), the
            // breadcrumb and 15.sp of horizontal padding, so the Scaffold /
            // SafeArea / 16.w Padding / PaginationAppBar this page built by
            // hand are all gone.
            child: SideFrameMasterServices(
              titleText: S.of(ctx).grc,
              // Tapping "GRC" goes back to the list. Unlike PaginationAppBar,
              // which popped on any non-last crumb by itself, the frame hands
              // each crumb its own callback and does nothing without one.
              onFirstTap: () => Navigator.of(ctx).maybePop(),
              secondTitle: modeCrumb,
              child: SideFrameBoundedBody(
                // The form is an Expanded with a pinned button row under it,
                // and the frame's phone branch passes an unbounded height.
                // This bounds it there and is a no-op on tablet/desktop.
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Each button carries its own switch, so a user with
                      // only one of the two still gets that one.
                      if (_currentMode == GrcPageMode.view &&
                          (GrcPermission.canEditModule ||
                              GrcPermission.canDeleteModule))
                        GrcActionButtons(
                          showEdit: GrcPermission.canEditModule,
                          showDelete: GrcPermission.canDeleteModule,
                          onEditTap: () =>
                              setState(() => _currentMode = GrcPageMode.edit),
                          onDeleteTap: () {
                            _pendingAction = _PendingAction.delete;
                            _onDelete(cubit);
                          },
                        ),
                      SizedBox(height: 15.h),
                      if (_currentMode == GrcPageMode.edit &&
                          GrcPermission.canChangeModuleStatus)
                        GrcStatusSwitch(
                          value: _statusValue,
                          // The real four-state status, so an ON switch says
                          // whether it means Active or Scheduled.
                          statusLabel: widget.entity == null
                              ? null
                              : grcTr(context, widget.entity!.status),
                          onToggle: (v) {
                            showConfirmDialog(
                                context: context,
                                title: S.of(ctx).changingStatus,
                                cancelLabel: S.of(ctx).no,
                                confirmLabel: S.of(ctx).yes,
                                // Status change, not a deletion — the
                                // confirmation animation rather than the bin.
                                lottieAsset: AppAssets.lottieConfirmation,
                                subtitle:
                                    S.of(context).areYouSureYouWantToChangeTheStatusOfThisModule,
                                onConfirm: () => _onStatusChanged(v));
                          },
                        ),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(15.sp),
                          decoration: BoxDecoration(
                            color: AppColors.field,
                            borderRadius: BorderRadius.circular(8.sp),
                          ),
                          child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context)
                                .copyWith(scrollbars: false),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  IgnorePointer(
                                    ignoring:
                                        _currentMode == GrcPageMode.view ||
                                            _currentMode == GrcPageMode.restore,
                                    child: CustomImagePicker(
                                      imageUrl: widget.entity?.moduleImage,
                                      imageFile: _imageFile,
                                      onImagePicked: (file) =>
                                          setState(() => _imageFile = file),
                                    ),
                                  ),
                                  SizedBox(height: 15.h),
                                  GrcFormFields(
                                    nameEnController: _nameEnController,
                                    nameArController: _nameArController,
                                    descEnController: _descEnController,
                                    descArController: _descArController,
                                    selectedDepartment: _selectedDepartment,
                                    activationDate: _activationDate,
                                    onDateChanged: _onActivationDateChanged,
                                    submitted: _submitted,
                                    readOnly:
                                        _currentMode == GrcPageMode.view ||
                                            _currentMode == GrcPageMode.restore,
                                    onDepartmentChanged: (v) =>
                                        setState(() => _selectedDepartment = v),
                                  ),
                                  SizedBox(height: 20.h),
                                  GrcOwnerSection(
                                    isViewMode: (_currentMode ==
                                            GrcPageMode.view ||
                                        _currentMode == GrcPageMode.restore),
                                    initialOwnerEmails: _selectedOwnerEmails,
                                    selectedDepartmentName: _selectedDepartment,
                                    onOwnersChanged: (selected) {
                                      // setState, not a bare assignment: the
                                      // Save button's enabled state depends on
                                      // this list, so ticking an owner has to
                                      // repaint the button.
                                      setState(() {
                                        _selectedOwnerEmails = selected
                                            .map((o) => o.email)
                                            .toList();
                                      });
                                    },
                                    sectionTitle: S.of(ctx).moduleOwner,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      GrcBottomButtons(
                        mode: _currentMode,
                        // Complete AND changed. Restore has no form to fill,
                        // so it stays live.
                        isActionEnabled: (_currentMode == GrcPageMode.create ||
                                _currentMode == GrcPageMode.edit)
                            ? (_isFormComplete && _hasChanges)
                            : true,
                        validate: (_currentMode == GrcPageMode.create ||
                                _currentMode == GrcPageMode.edit)
                            ? _validate
                            : null,
                        onDiscard: _currentMode == GrcPageMode.create
                            ? () => Navigator.pop(context)
                            : () =>
                                setState(() => _currentMode = GrcPageMode.view),
                        onAction: () {
                          if (_currentMode == GrcPageMode.create) {
                            _pendingAction = _PendingAction.create;
                            _onCreate(cubit);
                          } else if (_currentMode == GrcPageMode.edit) {
                            _pendingAction = _PendingAction.update;
                            _onUpdate(cubit);
                          } else if (_currentMode == GrcPageMode.restore) {
                            _pendingAction = _PendingAction.restore;
                            _onRestore(cubit);
                          }
                        },
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
              ),
            ),
          );
        },
      );
  }
}

/// Tracks which cubit action was last dispatched so the success listener
/// can build the correct dialog title / subtitle.
enum _PendingAction { none, create, update, delete, restore }
