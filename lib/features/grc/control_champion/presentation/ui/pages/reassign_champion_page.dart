import 'dart:async';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/custom/11-custom_confirm_diaolog.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/assigning_control.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/control_champion/domain/entities/champion_entity.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/use_cases/create_grc_request_usecase.dart';
import 'package:knowticed_plus/features/grc/grc_request/presentation/controller/grc_request_cubit.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:knowticed_plus/features/grc/module/presentation/controller/cubit/grc_owner_cubit.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:knowticed_plus/features/grc/shared/models/pending_assignment_row.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_edit_controls_layout.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_policy_control_picker_row.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_reassign_form.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';

class ReassignChampionPage extends StatefulWidget {
  final ChampionEntity champion;
  final GRCModuleEntity module;
  final List<PolicyEntity> allPolicies;
  final Map<String, List<ControlEntity>> policyControls;

  const ReassignChampionPage({
    super.key,
    required this.champion,
    required this.module,
    required this.allPolicies,
    required this.policyControls,
  });

  @override
  State<ReassignChampionPage> createState() => _ReassignChampionPageState();
}

class _ReassignChampionPageState extends State<ReassignChampionPage> {
  List<OwnerData> _newSelectedEmployees = [];
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _noteController = TextEditingController();

  // Controls being reassigned (transferred to the new champion)
  List<AssigningControlEntity> _reassignedControls = [];

  // Each row is its own independent Policy + Controls picker. Selections
  // made here are staging only — they aren't added to _reassignedControls
  // (and so don't appear as chips under "Assigned Controls") until Submit.
  final List<PendingAssignmentRow> _pendingRows = [PendingAssignmentRow()];
  bool _submitting = false;

  String? _championError;
  String? _controlsError;
  String? _startDateError;

  /// GRC bug report p4: Module Owners may reassign straight away, with no
  /// request to approve (and no Request Note).
  bool _withoutRequest = false;
  String? _noteError;

  bool get _isModuleOwner {
    final String me = currentGrcUserEmail().trim().toLowerCase();
    return widget.module.moduleOwners
        .any((e) => e.trim().toLowerCase() == me);
  }

  @override
  void initState() {
    super.initState();
    _reassignedControls = List.from(widget.champion.assigningControls);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _addPolicyRow() {
    setState(() {
      _pendingRows.add(PendingAssignmentRow());
    });
  }

  void _removeControl(int index) {
    setState(() {
      _reassignedControls.removeAt(index);
    });
  }

  Future<bool> _confirmReassign(BuildContext context) async {
    final completer = Completer<bool>();
    await showConfirmDialog(
      context: context,
      title: S.of(context).reassignChampion,
      subtitle: S.of(context).areYouSureYouWantToSubmitThisReassignmentRequest,
      confirmLabel: S.of(context).submit,
      cancelLabel: S.of(context).Cancel,
      onConfirm: () => completer.complete(true),
      onCancel: () => completer.complete(false),
    );
    return completer.future;
  }

  Future<void> _submit(BuildContext context) async {
    setState(() {
      commitPendingAssignmentRows(
          pendingRows: _pendingRows, target: _reassignedControls);
      _pendingRows
        ..clear()
        ..add(PendingAssignmentRow());
    });

    final newChampionEmail = _newSelectedEmployees.isNotEmpty
        ? _newSelectedEmployees.first.email
        : null;

    final championError = _newSelectedEmployees.isEmpty
        ? S.of(context).pleaseSelectANewControlChampion
        : newChampionEmail == widget.champion.championEmail
            ? S.of(context).newChampionCannotBeTheCurrentChampion
            : null;
    final controlsError = _reassignedControls.isEmpty
        ? S.of(context).pleaseAssignAtLeastOneControl
        : null;
    final startDateError =
        _startDate == null ? S.of(context).pleaseChooseAStartDate : null;

    setState(() {
      _championError = championError;
      _controlsError = controlsError;
      _startDateError = startDateError;
    });

    // GRC bug report p4: a request needs a note ("request note is
    // required"); a direct reassignment has none.
    final String? noteError =
        !_withoutRequest && _noteController.text.trim().isEmpty
            ? (context.isArabic
                ? 'ملاحظة الطلب مطلوبة'
                : 'Request note is required')
            : null;
    setState(() => _noteError = noteError);

    if (championError != null ||
        controlsError != null ||
        startDateError != null || noteError != null) {
      return;
    }

    final confirmed = await _confirmReassign(context);
    if (!confirmed) return;
    if (!context.mounted) return;

    setState(() => _submitting = true);

    final requestCubit = context.read<GrcRequestCubit>();
    await requestCubit.createRequest(
      CreateGrcRequestParams(
        moduleId: widget.module.moduleId,
        requestedBy: currentGrcUserEmail(),
        note: _noteController.text,
        currentChampionEmail: widget.champion.championEmail,
        newChampionEmail: newChampionEmail!,
        controls: _reassignedControls,
        startDate: _startDate!,
        endDate: _endDate,
      ),
    );

    // GRC bug report p4 — "without request": approve it on the spot through
    // the normal approval path, so the reassignment is applied (on its start
    // date) exactly as if a Module Owner had approved the request.
    final created = requestCubit.state;
    if (_withoutRequest && created is GrcRequestActionSuccess) {
      await requestCubit.approveRequest(
        moduleId: widget.module.moduleId,
        requestId: created.request.id,
      );
    }

    if (mounted) {
      setState(() => _submitting = false);
    }
    if (!context.mounted) return;

    final state = requestCubit.state;
    if (state is GrcRequestActionSuccess) {
      showSuccessDialog(
        context: context,
        title: S.of(context).requestSubmitted,
        subtitle: _withoutRequest
            ? (context.isArabic
                ? 'تمت إعادة التعيين بنجاح'
                : 'The reassignment was applied successfully')
            : S.of(context).yourReassignChampionRequestHasBeenSubmitted,
      );
      Navigator.pop(context, true);
    } else if (state is GrcRequestFailure) {
      CustomDialogManager.showMessage(
        context: context,
        lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
        title: S.of(context).unsuccessful,
        subtitle: 'Failed to submit request: ${state.message}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GrcRequestCubit>(
      create: (_) => GetIt.instance<GrcRequestCubit>(),
      child: Builder(builder: (context) => _buildPage(context)),
    );
  }

  Widget _buildPage(BuildContext context) {
    return GrcReassignForm(
      moduleName: context.isArabic
          ? widget.module.moduleNameAr
          : widget.module.moduleNameEn,
      pageTitle: S.of(context).reassignControlChampionRequest,
      currentLabel: S.of(context).currentControlChampion,
      currentEmail: widget.champion.championEmail,
      newLabel: S.of(context).newControlChampion,
      newPersonError: _championError,
      onNewPersonChanged: (selected) => setState(() {
        _newSelectedEmployees = selected;
        _championError = null;
      }),
      startDate: _startDate,
      startDateError: _startDateError,
      onStartDateChanged: (d) => setState(() {
        _startDate = d;
        _startDateError = null;
      }),
      endDate: _endDate,
      onEndDateChanged: (d) => setState(() => _endDate = d),
      noteController: _noteController,
      onNoteChanged: () => setState(() {}),
      assignedChips: [
        for (var index = 0; index < _reassignedControls.length; index++)
          GrcEditableChip(
            label: _controlName(_reassignedControls[index]),
            onRemove: () => _removeControl(index),
          ),
      ],
      controlsError: _controlsError,
      pickerRows: _buildPickerRows(),
      onAddPolicy: _addPolicyRow,
      onDiscard: () => Navigator.pop(context, false),
      onSubmit: () => _submit(context),
      isSubmitting: _submitting,
      withoutRequest: _isModuleOwner ? _withoutRequest : null,
      onWithoutRequestChanged: (v) => setState(() {
        _withoutRequest = v;
        _noteError = null;
      }),
      withoutRequestLabel: context.isArabic
          ? 'إعادة تعيين بطل الضابط بدون طلب'
          : 'Reassign Control Champion Without Request',
      noteError: _noteError,
    );
  }

  String _controlName(AssigningControlEntity ac) {
    final ctrl =
        findControlInPolicy(widget.policyControls, ac.policyId, ac.controlId);
    if (ctrl == null) return ac.controlId;
    return context.isArabic ? ctrl.controlsNameAr : ctrl.controlsNameEn;
  }

  /// One Policy + Controls picker per pending assignment. "+ Policy" adds
  /// another; nothing here reaches "Assigned Controls" until Submit.
  List<Widget> _buildPickerRows() {
    return List.generate(_pendingRows.length, (i) {
      final row = _pendingRows[i];
      final availableControlsForPolicy = row.policyId != null
          ? (widget.policyControls[row.policyId] ?? [])
          : <ControlEntity>[];

      return Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: GrcPolicyControlPickerRow(
          policies: widget.allPolicies,
          policyId: row.policyId,
          onPolicyChanged: (v) {
            setState(() {
              row.policyId = v;
              row.controlIds = [];
            });
          },
          availableControls: availableControlsForPolicy,
          controlsEnabled: row.policyId != null,
          controlIds: row.controlIds,
          onControlsChanged: (v) => setState(() => row.controlIds = v),
          spacing: 15.w,
          onRemoveRow: _pendingRows.length > 1
              ? () => setState(() => _pendingRows.removeAt(i))
              : null,
        ),
      );
    });
  }
}
