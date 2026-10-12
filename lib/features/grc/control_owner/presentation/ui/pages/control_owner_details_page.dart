/// Module: Control Owner Management
/// Description: Details screen for one Control Owner -- profile, actions
///              (Reassign / Edit / Remove), assigned Policies and
///              Controls, and the owner's Tasks.
/// Author: Mohamed Magdy Abdelkhalek
/// Revision History: 2026-09-15 - Body moved onto GrcAssigneeDetailsView so
///                   the 375 / 768 / 1024 MAGDY frames each get their own
///                   layout; Edit opens as a full page on phones.
library;

import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/11-custom_confirm_diaolog.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/entities/owner_entity.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/entities/owner_status.dart';
import 'package:knowticed_plus/features/grc/control_owner/presentation/controller/owner_cubit.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_assignee_details_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'edit_owner_controls_page.dart';
import 'reassign_owner_page.dart';

class ControlOwnerDetailsPage extends StatelessWidget {
  final OwnerEntity owner;
  final GRCModuleEntity module;

  const ControlOwnerDetailsPage({
    super.key,
    required this.owner,
    required this.module,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OwnerCubit>(
      create: (_) => GetIt.instance<OwnerCubit>(),
      child: _ControlOwnerDetailsBody(
        owner: owner,
        module: module,
      ),
    );
  }
}

class _ControlOwnerDetailsBody extends StatefulWidget {
  final OwnerEntity owner;
  final GRCModuleEntity module;

  const _ControlOwnerDetailsBody({
    required this.owner,
    required this.module,
  });

  @override
  State<_ControlOwnerDetailsBody> createState() =>
      _ControlOwnerDetailsBodyState();
}

class _ControlOwnerDetailsBodyState
    extends State<_ControlOwnerDetailsBody> {
  late OwnerEntity _currentOwner;
  bool _isLoadingData = true;
  bool _isReassignLoading = false;
  bool _isEditLoading = false;
  List<PolicyEntity> _allPolicies = [];
  final Map<String, List<ControlEntity>> _policyControls = {};

  @override
  void initState() {
    super.initState();
    _currentOwner = widget.owner;
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    final ownerCubit = context.read<OwnerCubit>();
    final polResult =
        await ownerCubit.getAllPolicies(moduleId: widget.module.moduleId);
    await polResult.fold(
      (failure) async {},
      (policies) async {
        _allPolicies = policies;
        for (final policy in policies) {
          final ctrlResult = await ownerCubit.getAllControlsForPolicy(
              moduleId: widget.module.moduleId, policyId: policy.id);
          ctrlResult.fold(
            (failure) {},
            (controls) {
              _policyControls[policy.id] = controls;
            },
          );
        }
      },
    );
    if (mounted) {
      setState(() => _isLoadingData = false);
    }
  }

  PolicyEntity? _getPolicyEntity(String policyId) {
    for (final p in _allPolicies) {
      if (p.id == policyId) return p;
    }
    return null;
  }

  void _showDeleteConfirmation(BuildContext context) {
    showConfirmDialog(
      context: context,
      title: S.of(context).removeControlOwner,
      subtitle: S.of(context).areYouSureYouWantToRemoveThisControlOwner,
      cancelLabel: S.of(context).Cancel,
      confirmLabel: S.of(context).remove,
      lottieAsset: 'assets/lottie_assets/main_lottie_assets/lottie_warning.json',
      onConfirm: () {
        context.read<OwnerCubit>().updateOwner(
              ownerEmail: _currentOwner.ownerEmail,
              moduleId: widget.module.moduleId,
              status: OwnerStatus.removed,
            );
      },
    );
  }

  Future<void> _handleReassignTap() async {
    setState(() => _isReassignLoading = true);
    await _loadAllData();
    if (mounted) {
      setState(() => _isReassignLoading = false);
    }
    if (!mounted) return;
    final result = await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => BlocProvider.value(
          value: context.read<OwnerCubit>(),
          child: ReassignOwnerPage(
            owner: _currentOwner,
            module: widget.module,
            allPolicies: _allPolicies,
            policyControls: _policyControls,
          ),
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
    if (result == true && mounted) {
      context
          .read<OwnerCubit>()
          .getAllOwners(moduleId: widget.module.moduleId);
      Navigator.pop(context, true);
    }
  }

  /// 768 / 1024 open "Edit Controls" as a dialog; the 375 frame draws it as
  /// its own "Editing Controls" page. The page widget picks its own layout
  /// from the width, so only the route differs here.
  Future<void> _handleEditTap() async {
    setState(() => _isEditLoading = true);
    await _loadAllData();
    if (mounted) {
      setState(() => _isEditLoading = false);
    }
    if (!mounted) return;
    final Widget page = BlocProvider.value(
      value: context.read<OwnerCubit>(),
      child: EditOwnerControlsPage(
        owner: _currentOwner,
        module: widget.module,
        allPolicies: _allPolicies,
        policyControls: _policyControls,
      ),
    );
    final OwnerEntity? result =
        screenSizeOf(context) == ScreenSize.mobile
            ? await Navigator.push<OwnerEntity>(
                context,
                MaterialPageRoute(builder: (_) => page),
              )
            : await showDialog<OwnerEntity>(
                context: context,
                builder: (_) => page,
              );
    if (result != null && mounted) {
      setState(() => _currentOwner = result);
    }
  }

  List<String> _policyNames(BuildContext context) {
    final ids = _currentOwner.assigningControls
        .map((ac) => ac.policyId)
        .toSet();
    return [
      for (final id in ids)
        () {
          final policy = _getPolicyEntity(id);
          if (policy == null) return id;
          return context.isArabic ? policy.policyNameAr : policy.policyNameEn;
        }(),
    ];
  }

  List<String> _controlNames(BuildContext context) {
    return [
      for (final ac in _currentOwner.assigningControls)
        () {
          final ctrl =
              findControlInPolicy(_policyControls, ac.policyId, ac.controlId);
          if (ctrl == null) return ac.controlId;
          return context.isArabic ? ctrl.controlsNameAr : ctrl.controlsNameEn;
        }(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OwnerCubit, OwnerState>(
      listener: (context, state) {
        if (state is OwnerActionSuccess) {
          if (state.owner.status == OwnerStatus.removed) {
            showSuccessDialog(
              context: context,
              title: S.of(context).controlOwnerRemoved,
              subtitle: S.of(context).controlOwnerRemovedSuccessfully,
            );
            Navigator.pop(context, true);
          } else {
            setState(() {
              _currentOwner = state.owner;
            });
          }
        } else if (state is OwnerFailure) {
          CustomDialogManager.showMessage(
            context: context,
            lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
            title: S.of(context).unsuccessful,
            subtitle: state.message,
          );
        }
      },
      child: SideFrameMasterServices(
      // The frame owns the Scaffold, SafeArea, breadcrumb and side padding.
      titleText: S.of(context).grc,
      onFirstTap: () => popFrameRoutes(context, 2),
      secondTitle: context.isArabic
                        ? widget.module.moduleNameAr
                        : widget.module.moduleNameEn,
      onSecondTap: () => popFrameRoutes(context, 1),
      thirdTitle: S.of(context).controlOwner,
      child: SideFrameScrollableBody(
        child: GrcAssigneeDetailsView(
                      kind: GrcAssigneeKind.owner,
                      moduleId: widget.module.moduleId,
                      email: _currentOwner.ownerEmail,
                      isLoadingNames: _isLoadingData,
                      policyNames: _policyNames(context),
                      controlNames: _controlNames(context),
                      onReassign: _handleReassignTap,
                      isReassignLoading: _isReassignLoading,
                      onEdit: _handleEditTap,
                      isEditLoading: _isEditLoading,
                      onRemove: () => _showDeleteConfirmation(context),
                    ),
      ),
    ),
    );
  }
}
