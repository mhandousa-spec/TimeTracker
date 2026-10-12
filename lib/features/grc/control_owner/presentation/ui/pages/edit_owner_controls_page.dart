import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/custom/11-custom_confirm_diaolog.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/assigning_control.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/entities/owner_entity.dart';
import 'package:knowticed_plus/features/grc/control_owner/presentation/controller/owner_cubit.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:knowticed_plus/features/grc/shared/models/pending_assignment_row.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_edit_controls_layout.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_policy_control_picker_row.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';

class EditOwnerControlsPage extends StatefulWidget {
  final OwnerEntity owner;
  final GRCModuleEntity module;
  final List<PolicyEntity> allPolicies;
  final Map<String, List<ControlEntity>> policyControls;

  const EditOwnerControlsPage({
    super.key,
    required this.owner,
    required this.module,
    required this.allPolicies,
    required this.policyControls,
  });

  @override
  State<EditOwnerControlsPage> createState() => _EditOwnerControlsPageState();
}

class _EditOwnerControlsPageState extends State<EditOwnerControlsPage> {
  late List<AssigningControlEntity> _tempControls;

  // Each row is its own independent Policy + Controls picker. Selections
  // made here are staging only — they aren't added to _tempControls (and
  // so don't appear as chips under "Assigned Controls") until Save.
  final List<PendingAssignmentRow> _pendingRows = [PendingAssignmentRow()];

  @override
  void initState() {
    super.initState();
    _tempControls = List.from(widget.owner.assigningControls);
  }

  void _removeControl(int index) {
    setState(() {
      _tempControls.removeAt(index);
    });
  }

  void _addPolicyRow() {
    setState(() {
      _pendingRows.add(PendingAssignmentRow());
    });
  }

  void _confirmAndSave(BuildContext context) {
    showConfirmDialog(
      context: context,
      title: S.of(context).saveChanges,
      subtitle: S.of(context).areYouSureYouWantToSaveTheseChanges,
      cancelLabel: S.of(context).Cancel,
      confirmLabel: S.of(context).Save,
      onConfirm: () => _save(context),
    );
  }

  void _save(BuildContext context) {
    setState(() {
      commitPendingAssignmentRows(
          pendingRows: _pendingRows, target: _tempControls);
      _pendingRows
        ..clear()
        ..add(PendingAssignmentRow());
    });
    // Fire-and-forget: these touch each affected Control document directly
    // (not the Owner doc this page's own loading/success state tracks),
    // so they don't need to block the Save button.
    context.read<OwnerCubit>().recomputeControlStatuses(
          owner: widget.owner,
          newControls: _tempControls,
          moduleId: widget.module.moduleId,
          policyControls: widget.policyControls,
        );
    context.read<OwnerCubit>().updateOwner(
          ownerEmail: widget.owner.ownerEmail,
          moduleId: widget.module.moduleId,
          assigningControls: _tempControls,
        );
  }

  // GRC bug report p8 — full-page loader while saving, and Save disabled
  // until something changed.
  bool _loaderShown = false;
  bool _finished = false;

  bool get _hasChanges {
    final original = widget.owner.assigningControls
        .map((ac) => '${ac.policyId}|${ac.controlId}')
        .toSet();
    final current =
        _tempControls.map((ac) => '${ac.policyId}|${ac.controlId}').toSet();
    if (original.length != current.length ||
        !original.containsAll(current)) {
      return true;
    }
    return _pendingRows
        .any((r) => r.policyId != null && r.controlIds.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OwnerCubit, OwnerState>(
      listener: (context, state) {
        if (_finished) return;
        if (state is OwnerLoading) {
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
        if (state is OwnerActionSuccess) {
          _finished = true;
          showSuccessDialog(
            context: context,
            title: S.of(context).controlsUpdated,
            subtitle: S.of(context).controlsUpdatedSuccessfully,
          );
          Navigator.pop(context, state.owner);
        } else if (state is OwnerFailure) {
          CustomDialogManager.showMessage(
            context: context,
            lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
            title: S.of(context).unsuccessful,
            subtitle: state.message,
          );
        }
      },
      builder: (context, state) {
        // Dialog at 768 / 1024, "Editing Controls" page at 375 -- see
        // GrcEditControlsLayout. Nothing here touches "Assigned Controls"
        // until Save; each picker row is staging only.
        return GrcEditControlsLayout(
          isSaving: state is OwnerLoading,
          chips: [
            for (var index = 0; index < _tempControls.length; index++)
              GrcEditableChip(
                label: _controlName(_tempControls[index]),
                onRemove: () => _removeControl(index),
              ),
          ],
          pickerRows: _buildPendingRows(),
          onAddPolicy: _addPolicyRow,
          onSave: () => _confirmAndSave(context),
          canSave: _hasChanges,
        );
      },
    );
  }

  String _controlName(AssigningControlEntity ac) {
    final ctrl =
        findControlInPolicy(widget.policyControls, ac.policyId, ac.controlId);
    if (ctrl == null) return ac.controlId;
    return context.isArabic ? ctrl.controlsNameAr : ctrl.controlsNameEn;
  }

  List<Widget> _buildPendingRows() {
    return List.generate(_pendingRows.length, (i) {
      final row = _pendingRows[i];
      final availableControlsForPolicy = row.policyId != null
          ? (widget.policyControls[row.policyId] ?? [])
          : <ControlEntity>[];

      return Padding(
        padding: EdgeInsets.only(bottom: 12.h),
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
          controlsLabel: 'Add Controls',
          controlsHint: 'Choose Controls',
          spacing: 15.w,
          onRemoveRow:
              _pendingRows.length > 1 ? () => setState(() => _pendingRows.removeAt(i)) : null,
        ),
      );
    });
  }
}
