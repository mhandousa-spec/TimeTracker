// lib/features/grc/control_owner/presentation/ui/pages/add_owner_page.dart
/// Module: Control Owner Management
/// Description: Single-page form for adding a new Control Owner — pick
///              exactly one employee, then assign one or more {Policy,
///              Control} pairs to them. Control_Owners_Permissions is left
///              empty per assigned control (no picker UI in this iteration —
///              see the design spec's scope decisions).
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: OwnerCubit, GrcOwnerSection, GetAllPoliciesUseCase,
///               GetAllControlsUseCase, PolicyEntity, ControlEntity
library;

import 'package:knowticed_plus/features/grc/shared/widgets/grc_labeled_switch.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/11-custom_confirm_diaolog.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/assigning_control.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_status_resolver.dart';
import 'package:knowticed_plus/features/grc/control/domain/use_cases/update_control_usecase.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/entities/owner_entity.dart';
import 'package:knowticed_plus/features/grc/control_owner/presentation/controller/owner_cubit.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_edit_controls_layout.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_policy_control_picker_row.dart';
import 'package:knowticed_plus/features/grc/module/presentation/controller/cubit/grc_owner_cubit.dart';
import 'package:knowticed_plus/features/grc/module/presentation/ui/widgets/grc_details_widget/grc_owner_section.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';

class _AssigningControlRow {
  String? policyId;
  List<String> controlIds;
  List<ControlEntity> availableControls;
  bool isLoadingControls;

  _AssigningControlRow({
    this.policyId,
    List<String>? controlIds,
    List<ControlEntity>? availableControls,
    this.isLoadingControls = false,
  })  : controlIds = controlIds ?? [],
        availableControls = availableControls ?? [];
}

class AddOwnerPage extends StatefulWidget {
  final String moduleId;
  final String moduleNameEn;
  final String moduleNameAr;

  const AddOwnerPage({
    super.key,
    required this.moduleId,
    required this.moduleNameEn,
    required this.moduleNameAr,
  });

  @override
  State<AddOwnerPage> createState() => _AddOwnerPageState();
}

class _AddOwnerPageState extends State<AddOwnerPage> {
  final List<_AssigningControlRow> _rows = [_AssigningControlRow()];
  List<OwnerData> _selectedEmployees = [];
  List<PolicyEntity> _policies = [];
  bool _loadingPolicies = true;
  bool _submitted = false;

  /// GRC bug report p2: may this owner score the control themselves? When
  /// off they only approve / reject, and the Module Owner gives the score.
  bool _canGiveScore = true;

  /// Every Owner currently assigned to any {Policy, Control} pair in this
  /// module — used to disable Controls that already have an Owner, since
  /// each Control now allows only one. Fetched once on open, same "snapshot,
  /// no re-fetch" approach the rest of this page uses for Policies/Controls.
  List<OwnerEntity> _existingOwners = [];

  // Resolved once up-front (instead of via BlocProvider's `create:`) so it's
  // available to _loadPolicies() from initState(), before this State's own
  // build() has run and created the BlocProvider below it in the tree.
  late final OwnerCubit _ownerCubit;

  @override
  void initState() {
    super.initState();
    _ownerCubit = GetIt.instance<OwnerCubit>();
    _loadPolicies();
    _loadExistingOwners();
  }

  @override
  void dispose() {
    _ownerCubit.close();
    super.dispose();
  }

  Future<void> _loadPolicies() async {
    final result = await _ownerCubit.getAllPolicies(moduleId: widget.moduleId);
    if (!mounted) return;
    result.fold(
      (failure) => setState(() => _loadingPolicies = false),
      (policies) => setState(() {
        _policies = policies;
        _loadingPolicies = false;
      }),
    );
  }

  Future<void> _loadExistingOwners() async {
    final result = await _ownerCubit.getAllOwnersRaw(moduleId: widget.moduleId);
    if (!mounted) return;
    result.fold(
      (failure) {},
      (owners) => setState(() => _existingOwners = owners),
    );
  }

  /// True if [controlId] under [policyId] already has any Owner assigned —
  /// such a Control is shown but disabled in the picker, since only one
  /// Owner per Control is allowed.
  bool _controlHasOwner(String policyId, String controlId) {
    return _existingOwners.any((o) => o.assigningControls
        .any((a) => a.policyId == policyId && a.controlId == controlId));
  }

  Future<void> _onPolicyChanged(
      _AssigningControlRow row, String? policyId) async {
    if (policyId == null) {
      setState(() {
        row.policyId = null;
        row.controlIds = [];
        row.availableControls = [];
      });
      return;
    }
    setState(() {
      row.policyId = policyId;
      row.controlIds = [];
      row.availableControls = [];
      row.isLoadingControls = true;
    });
    final result = await _ownerCubit.getAllControlsForPolicy(
        moduleId: widget.moduleId, policyId: policyId);
    if (!mounted) return;
    result.fold(
      (failure) => setState(() => row.isLoadingControls = false),
      (controls) => setState(() {
        row.availableControls = controls;
        row.isLoadingControls = false;
      }),
    );
  }

  void _addRow() => setState(() => _rows.add(_AssigningControlRow()));

  void _removeRow(int index) => setState(() => _rows.removeAt(index));

  bool get _rowsValid =>
      _rows.every((r) => r.policyId != null && r.controlIds.isNotEmpty);

  void _submit(BuildContext context) {
    setState(() => _submitted = true);
    if (_selectedEmployees.length != 1 || !_rowsValid) return;

    showConfirmDialog(
      context: context,
      title: S.of(context).addControlOwner,
      subtitle: S.of(context).areYouSureYouWantToAddThisControlOwner,
      confirmLabel: S.of(context).add,
      cancelLabel: S.of(context).Cancel,
      onConfirm: () {
        // Fire-and-forget: touches each affected Control document directly,
        // not the Owner doc this page's own submit/loading state tracks.
        _recomputeControlStatuses();
        context.read<OwnerCubit>().createOwner(
              moduleId: widget.moduleId,
              ownerEmail: _selectedEmployees.first.email,
              canGiveScore: _canGiveScore,
              // One row (one Policy) can carry several Controls — expand
              // each row into one {Policy, Control} pair per selected
              // Control.
              assigningControls: _rows
                  .expand((r) =>
                      r.controlIds.map((controlId) => AssigningControlEntity(
                            policyId: r.policyId!,
                            controlId: controlId,
                          )))
                  .toList(),
            );
      },
    );
  }

  ControlEntity? _findControl(_AssigningControlRow row, String controlId) {
    for (final c in row.availableControls) {
      if (c.id == controlId) return c;
    }
    return null;
  }

  /// function name: [_recomputeControlStatuses]
  ///
  /// purpose: every control just selected here has gained this brand-new
  ///          Owner as an assignee — flip any of them still sitting on
  ///          Unassigned to Scheduled/Active. Controls that are Draft/
  ///          Inactive/Expired, or already Scheduled/Active, are left
  ///          untouched (see [shouldRecomputeAssigneeBasedStatus]).
  Future<void> _recomputeControlStatuses() async {
    final editor = currentGrcUserEmail();
    for (final row in _rows) {
      for (final controlId in row.controlIds) {
        final control = _findControl(row, controlId);
        if (control == null) continue;
        if (!shouldRecomputeAssigneeBasedStatus(control.status)) continue;
        final newStatus = computeAssigneeBasedControlStatus(
          effectiveStartDate: control.startDate,
          hasAnyAssignee: true,
        );
        if (newStatus == control.status) continue;
        await _ownerCubit.updateControl(
          UpdateControlParams(
            id: control.id,
            moduleId: widget.moduleId,
            policyId: row.policyId!,
            editorId: editor,
            status: newStatus,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _ownerCubit,
      child: BlocConsumer<OwnerCubit, OwnerState>(
        listener: (context, state) {
          if (state is OwnerActionSuccess) {
            showSuccessDialog(
              context: context,
              title: S.of(context).controlOwnerAdded,
              subtitle: S.of(context).youSuccessfullyAddedThisControlOwner,
            );
            Navigator.pop(context, true);
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
          final isSubmitting = state is OwnerLoading;
          return SideFrameMasterServices(
      // The frame owns the Scaffold, SafeArea, breadcrumb and side padding.
      titleText: S.of(context).grc,
      onFirstTap: () => popFrameRoutes(context, 2),
      secondTitle: context.isArabic
                              ? widget.moduleNameAr
                              : widget.moduleNameEn,
      onSecondTap: () => popFrameRoutes(context, 1),
      thirdTitle: S.of(context).addingNewControlOwner,
      child: SideFrameScrollableBody(
        child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10.h),
                      _buildFormCard(context),
                      SizedBox(height: 15.h),
                      grcFormButtons(
                        context,
                        onDiscard: () => Navigator.pop(context, false),
                        primaryTitle: S.of(context).submit,
                        onPrimary: () => _submit(context),
                        isBusy: isSubmitting,
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
      ),
    );
        },
      ),
    );
  }

  /// One white card holding both halves of the form -- the person picker
  /// and the Policy / Control rows -- as all three MAGDY frames draw it.
  Widget _buildFormCard(BuildContext context) {
    final TextStyle sectionStyle =
        StyleText.fontSize16Weight400.copyWith(color: AppColors.text);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.of(context).controlOwner, style: sectionStyle),
          SizedBox(height: 8.h),
          GrcOwnerSection(
            singleSelect: true,
            onOwnersChanged: (selected) =>
                setState(() => _selectedEmployees = selected),
          ),
          if (_submitted && _selectedEmployees.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text(
                S.of(context).pleaseSelectAControlOwner,
                style: StyleText.fontSize12Weight500
                    .copyWith(color: AppColors.red),
              ),
            ),
          SizedBox(height: 20.h),
          GrcLabeledSwitch(
            label: context.isArabic ? 'منح الدرجة' : 'Give Score',
            description: _canGiveScore
                ? (context.isArabic
                    ? 'مالك الضابط يوافق أو يرفض ويمنح الدرجة.'
                    : 'The control owner approves or rejects and gives the score.')
                : (context.isArabic
                    ? 'مالك الضابط يوافق أو يرفض فقط، ومالك الوحدة يمنح الدرجة.'
                    : 'The control owner only approves or rejects; the Module Owner gives the score.'),
            value: _canGiveScore,
            onChanged: (v) => setState(() => _canGiveScore = v),
          ),
          SizedBox(height: 30.h),
          Text(S.of(context).assigningControl, style: sectionStyle),
          SizedBox(height: 10.h),
          for (var i = 0; i < _rows.length; i++) ...[
            GrcPolicyControlPickerRow(
              policies: _policies,
              policiesEnabled: !_loadingPolicies,
              policyId: _rows[i].policyId,
              onPolicyChanged: (v) => _onPolicyChanged(_rows[i], v),
              policyErrorText: _submitted && _rows[i].policyId == null
                  ? S.of(context).required
                  : null,
              availableControls: _rows[i].availableControls,
              controlsEnabled:
                  _rows[i].policyId != null && !_rows[i].isLoadingControls,
              controlIds: _rows[i].controlIds,
              onControlsChanged: (v) => setState(() => _rows[i].controlIds = v),
              controlsErrorText: _submitted && _rows[i].controlIds.isEmpty
                  ? S.of(context).required
                  : null,
              disabledControlIds: _rows[i].policyId == null
                  ? const []
                  : _rows[i]
                      .availableControls
                      .where((c) => _controlHasOwner(_rows[i].policyId!, c.id))
                      .map((c) => c.id)
                      .toList(),
              spacing: 15.w,
              onRemoveRow: _rows.length > 1 ? () => _removeRow(i) : null,
            ),
            SizedBox(height: 10.h),
          ],
          grcAddPolicyButton(context, onTap: _addRow),
        ],
      ),
    );
  }
}
