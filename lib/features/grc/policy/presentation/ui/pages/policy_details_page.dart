/// Module: GRC Policy Management
/// Description: Details page for a single Policy — view its fields and
///              delete the Policy (soft-delete). Editing is a separate
///              full-page route, [PolicyEditPage].
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-18
/// Dependencies: flutter_bloc, PolicyCubit, PolicyEntity, GRCModuleEntity,
///               get_it
/// Revision History: 2026-07-15 - Initial creation (Policy view/edit/delete)
///                   2026-07-18 - Reworked view-mode layout to match the
///                                latest design mock: Policy Number / Last
///                                Edit on one row, Owner moved above the
///                                Weight/Start/End row, documents shown side
///                                by side, a search bar + "Control" dropdown
///                                (Add Control / Bulk Upload) above the
///                                controls list, a weight-mismatch banner,
///                                and a responsive 2-column controls grid.
///                   2026-07-18 - Split view/edit bodies into
///                                PolicyViewModeWidget / PolicyEditModeWidget
///                                (widgets/policy_details_widget/) so both
///                                modes are organized the same way; fixed
///                                _submitted not resetting on re-entering
///                                Edit, which made validation errors show up
///                                inconsistently depending on prior use.
///                   2026-07-18 - Moved editing out of this page entirely
///                                into its own route, [PolicyEditPage] —
///                                matching the AddEditControlPage pattern —
///                                so view and edit are fully independent
///                                pages instead of one page toggling modes.
library;

/// ************************* FILE INFO *************************** ///
/// File Name: policy_details_page.dart
/// Purpose: Contains PolicyDetailsPage, the read/delete details screen for a
///          single Policy, opened by tapping a policy card on the GRC
///          Module details page.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 15/7/2026

import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/11-custom_confirm_diaolog.dart' show showSuccessDialog;
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/control_champion/presentation/controller/champion_cubit.dart';
import 'package:knowticed_plus/features/grc/control_owner/presentation/controller/owner_cubit.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/controller/policy_cubit.dart';
import 'package:knowticed_plus/features/grc/control/presentation/controller/control_cubit.dart';
import 'package:knowticed_plus/features/grc/control/presentation/ui/pages/add_edit_control_page.dart';
import 'package:knowticed_plus/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_page.dart';
import 'package:knowticed_plus/features/grc/module/presentation/ui/widgets/grc_details_widget/grc_action_buttons.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/pages/policy_edit_page.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/widgets/policy_details_widget/policy_view_mode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_permissions.dart';

/// class name: [PolicyDetailsPage]
///
/// purpose: entry-point widget for the Policy Details screen. Provides a
///          [PolicyCubit] and fetches [policyId] fresh from Firestore so the
///          page always reflects the latest saved state.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 15/7/2026
class PolicyDetailsPage extends StatelessWidget {
  final String policyId;
  final String moduleId;
  final GRCModuleEntity module;

  const PolicyDetailsPage({
    super.key,
    required this.policyId,
    required this.moduleId,
    required this.module,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PolicyCubit>(
          create: (_) => GetIt.instance<PolicyCubit>(),
        ),
        BlocProvider<ControlCubit>(
          create: (_) => GetIt.instance<ControlCubit>(),
        ),
        // The module's Control Owners, fetched ONCE here for the whole page.
        //
        // A control's owner is not a field on ControlEntity -- it lives on
        // the other side of the relation, in OwnerEntity.assigningControls
        // -- so every ControlCardWidget in the list needs the owner list to
        // render its "Control Owner" row. Providing it here means one read
        // per page instead of one per card, and _openAddEditControl hands
        // this same instance down (BlocProvider.value) so an edit that
        // reassigns an owner is reflected back in the list.
        BlocProvider<OwnerCubit>(
          create: (_) => GetIt.instance<OwnerCubit>()
            ..getAllOwners(moduleId: moduleId),
        ),
      ],
      child: _PolicyDetailsBody(
        policyId: policyId,
        moduleId: moduleId,
        module: module,
      ),
    );
  }
}

class _PolicyDetailsBody extends StatefulWidget {
  final String policyId;
  final String moduleId;
  final GRCModuleEntity module;

  const _PolicyDetailsBody({
    required this.policyId,
    required this.moduleId,
    required this.module,
  });

  @override
  State<_PolicyDetailsBody> createState() => _PolicyDetailsBodyState();
}

class _PolicyDetailsBodyState extends State<_PolicyDetailsBody> {
  PolicyEntity? _policy;
  bool _pendingDelete = false;
  List<ControlEntity> _controls = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final cubit = context.read<PolicyCubit>();
    final controlCubit = context.read<ControlCubit>();
    await cubit.getPolicy(widget.policyId, moduleId: widget.moduleId);
    await controlCubit.getAllControls(
      moduleId: widget.moduleId,
      policyId: widget.policyId,
    );
  }

  void _onDelete(PolicyCubit cubit) {
    _pendingDelete = true;
    cubit.deletePolicy(
      id: _policy!.id,
      moduleId: widget.moduleId,
      moduleOwners: widget.module.moduleOwners,
    );
  }

  void _onStateChange(BuildContext context, PolicyState state) {
    if (state is PolicyLoading) {
      if (_policy != null) showLoadingIndicator();
      return;
    }
    if (_policy != null) hideLoadingIndicator();

    if (state is PolicySingleLoaded) {
      setState(() => _policy = state.policy);
      return;
    }

    if (state is PolicyActionSuccess) {
      if (_pendingDelete) {
        showSuccessDialog(
          context: context,
          title: S.of(context).policyDeleted,
          subtitle: S.of(context).youSuccessfullyDeletedThisPolicy,
        );
        Navigator.of(context).pop(true);
      }
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
    if (state is ControlLoading) {
      showLoadingIndicator();
      return;
    }
    hideLoadingIndicator();

    if (state is ControlsListLoaded) {
      setState(() => _controls = state.controls);
    }
  }

  Future<void> _openEditPolicy() async {
    // Hand this page's own PolicyCubit down to the edit page via
    // BlocProvider.value instead of letting it resolve a second, disconnected
    // instance from GetIt, so both pages act on ONE cubit. The cubit emits
    // PolicyActionSuccess (not a fresh PolicySingleLoaded) after a save, so the
    // policy is still explicitly re-fetched below once Edit pops true — that
    // refetch is what returns this page's local _policy to the latest state.
    final policyCubit = context.read<PolicyCubit>();
    final result = await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => BlocProvider<PolicyCubit>.value(
          value: policyCubit,
          child: PolicyEditPage(
            moduleId: widget.moduleId,
            policy: _policy!,
            module: widget.module,
          ),
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
    if (result == true && mounted) {
      policyCubit.getPolicy(
        widget.policyId,
        moduleId: widget.moduleId,
      );
    }
  }

  // Flow-start entry point (Add Control / edit-from-list). This page already
  // holds its own ControlCubit at the root (see build()), so it's shared via
  // BlocProvider.value rather than resolved fresh — matching the pattern
  // _openEditPolicy above uses for PolicyCubit, and for OwnerCubit since the
  // controls list now needs one at the root anyway (see build()) -- sharing
  // it is what makes an owner reassignment made in here show up on the card
  // that opened it. Only ChampionCubit has no ancestor, so only that one is
  // resolved fresh.
  Future<void> _openAddEditControl({ControlEntity? existing}) async {
    final controlCubit = context.read<ControlCubit>();
    final ownerCubit = context.read<OwnerCubit>();
    final result = await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => MultiBlocProvider(
          providers: [
            BlocProvider<ControlCubit>.value(value: controlCubit),
            BlocProvider<ChampionCubit>(
              create: (_) => GetIt.instance<ChampionCubit>()
                ..getAllChampions(moduleId: widget.moduleId),
            ),
            BlocProvider<OwnerCubit>.value(value: ownerCubit),
          ],
          child: AddEditControlPage(
            policy: _policy!,
            moduleId: widget.moduleId,
            policyId: widget.policyId,
            existingControl: existing,
            siblingControls: _controls,
            policyStartDate: _policy!.startDate,
            policyEndDate: _policy!.endDate,
            policyHasArabic: _policy!.policyNameAr.trim().isNotEmpty ||
                _policy!.policyNumberAr.trim().isNotEmpty ||
                _policy!.policyDescriptionAr.trim().isNotEmpty,
          ),
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
    if (result == true && mounted) {
      controlCubit.getAllControls(
        moduleId: widget.moduleId,
        policyId: widget.policyId,
      );
    }
  }

  Future<void> _onBulkUploadControls() async {
    final result = await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ControlBulkUploadPage(
          moduleId: widget.moduleId,
          policyId: widget.policyId,
          policyStartDate: _policy!.startDate,
          policyEndDate: _policy!.endDate,
          // Middle breadcrumb segment: Figma draws this screen as
          // "GRC > Module Name > Control Bulk Upload".
          moduleNameEn: widget.module.moduleNameEn,
          moduleNameAr: widget.module.moduleNameAr,
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
    if (result == true && mounted) {
      context.read<ControlCubit>().getAllControls(
            moduleId: widget.moduleId,
            policyId: widget.policyId,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PolicyCubit>();
    final isArabic = context.isArabic;
    final dateFormat = DateFormat('d MMM yyyy', isArabic ? 'ar' : 'en');

    return MultiBlocListener(
      listeners: [
        BlocListener<PolicyCubit, PolicyState>(listener: _onStateChange),
        BlocListener<ControlCubit, ControlState>(
          listener: _onControlStateChange,
        ),
      ],
      // The frame owns the Scaffold, SafeArea, breadcrumb and side padding.
      child: SideFrameMasterServices(
        titleText: S.of(context).grc,
        onFirstTap: () => popFrameRoutes(context, 2),
        secondTitle: isArabic
            ? widget.module.moduleNameAr
            : widget.module.moduleNameEn,
        onSecondTap: () => popFrameRoutes(context, 1),
        thirdTitle: _policy == null
            ? ''
            : (isArabic ? _policy!.policyNameAr : _policy!.policyNameEn),
        // Both branches want a height: the spinner centres in it, and the
        // loaded body is an Expanded scroll area. The frame's phone branch
        // passes an unbounded one.
        child: SideFrameBoundedBody(
          // CircleProgressMaster is the app's spinner (66-circle_progress),
          // and it centres itself -- so no Center wrapper, matching the swap
          // PolicyWeightIssuePage already made.
          child: _policy == null
              ? const CircleProgressMaster()
              : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            S.of(context).policyDetails,
                            style: context.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                          ),
                          Spacer(),
                          GrcActionButtons(
                            // Edit_Policy / Delete_Policy, independently --
                            // GrcActionButtons already draws just one when
                            // only one is granted.
                            showEdit: GrcPermission.canEditPolicy,
                            showDelete: GrcPermission.canDeletePolicy,
                            onEditTap: _openEditPolicy,
                            onDeleteTap: () => _onDelete(cubit),
                            deleteDialogTitle: 'Deleting Policy',
                            deleteDialogSubtitle:
                                'Are You Sure You Want To Delete This Policy ?',
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Expanded(
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context)
                              .copyWith(scrollbars: false),
                          child: SingleChildScrollView(
                            child: PolicyViewModeWidget(
                              policy: _policy!,
                              module: widget.module,
                              controls: _controls,
                              isArabic: isArabic,
                              dateFormat: dateFormat,
                              onControlTap: (existing) =>
                                  _openAddEditControl(existing: existing),
                              onBulkUpload: _onBulkUploadControls,
                              onControlsChanged: () =>
                                  context.read<ControlCubit>().getAllControls(
                                        moduleId: widget.moduleId,
                                        policyId: widget.policyId,
                                      ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
        ),
      ),
    );
  }
}
