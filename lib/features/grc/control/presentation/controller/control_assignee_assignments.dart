/// Module: GRC Policy Management
/// Description: Champion/Owner assignment diffing for the Add/Edit Control
///              form, extracted from AddEditControlPage so the page itself
///              only holds UI-orchestration state.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-15
/// Dependencies: flutter_bloc, ChampionCubit, OwnerCubit
/// Revision History: 2026-07-15 - Initial creation (inline in
///                                add_edit_control_page.dart)
///                   2026-07-27 - Split out into its own controller class
library;

/// ************************* FILE INFO *************************** ///
/// File Name: control_assignee_assignments.dart
/// Purpose: Contains ControlAssigneeAssignments, which tracks the user's
///          live Champion/Owner picker selections and, once the Control
///          itself has saved, diffs them against whoever was already
///          assigned and persists the difference via ChampionCubit/
///          OwnerCubit. Reports failures back to the caller instead of
///          touching the UI directly, so the page decides how to surface
///          them.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 27/7/2026

import 'package:knowticed_plus/features/grc/control_champion/presentation/controller/champion_cubit.dart';
import 'package:knowticed_plus/features/grc/control_owner/presentation/controller/owner_cubit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// class name: [ControlAssigneeAssignments]
///
/// purpose: owns [currentChampionEmails]/[currentOwnerEmails] — the live
///          picker selections reported by ControlAssigneesSectionWidget —
///          and the logic to check whether any assignee is currently
///          selected, and to persist whatever changed once the Control
///          itself has saved successfully.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 27/7/2026
class ControlAssigneeAssignments {
  List<String>? currentChampionEmails;
  List<String>? currentOwnerEmails;

  /// The live Champion picker selection if the user touched it, otherwise
  /// whoever was already assigned when the page opened.
  List<String> resolvedChampionEmails({
    required BuildContext context,
    required bool isEdit,
    required String policyId,
    required String controlId,
  }) {
    final championCubit = context.read<ChampionCubit>();
    final championState = championCubit.state;
    return currentChampionEmails ??
        (isEdit && championState is ChampionListLoaded
            ? championCubit.alreadyAssignedEmails(
                championState.champions,
                policyId: policyId,
                controlId: controlId,
              )
            : const <String>[]);
  }

  /// The live Owner picker selection if the user touched it, otherwise
  /// whoever was already assigned when the page opened.
  List<String> resolvedOwnerEmails({
    required BuildContext context,
    required bool isEdit,
    required String policyId,
    required String controlId,
  }) {
    final ownerCubit = context.read<OwnerCubit>();
    final ownerState = ownerCubit.state;
    return currentOwnerEmails ??
        (isEdit && ownerState is OwnerListLoaded
            ? ownerCubit.alreadyAssignedEmails(
                ownerState.owners,
                policyId: policyId,
                controlId: controlId,
              )
            : const <String>[]);
  }

  /// True if at least one Champion or Owner is currently assigned: the live
  /// picker selection if the user touched it, otherwise whoever was already
  /// assigned when the page opened. A brand-new Control has no assignees
  /// section at all (Create mode hides it), so this is always false there.
  bool hasAnyAssignee({
    required BuildContext context,
    required bool isEdit,
    required String policyId,
    required String controlId,
  }) {
    final championEmails = resolvedChampionEmails(
      context: context,
      isEdit: isEdit,
      policyId: policyId,
      controlId: controlId,
    );
    final ownerEmails = resolvedOwnerEmails(
      context: context,
      isEdit: isEdit,
      policyId: policyId,
      controlId: controlId,
    );
    return championEmails.isNotEmpty || ownerEmails.isNotEmpty;
  }

  /// True only when a Champion is currently assigned but no Owner is — a
  /// Control's Champion always requires an Owner to also be assigned, while
  /// an Owner alone (no Champion) is valid on its own.
  bool isChampionWithoutOwner({
    required BuildContext context,
    required bool isEdit,
    required String policyId,
    required String controlId,
  }) {
    final championEmails = resolvedChampionEmails(
      context: context,
      isEdit: isEdit,
      policyId: policyId,
      controlId: controlId,
    );
    if (championEmails.isEmpty) return false;
    final ownerEmails = resolvedOwnerEmails(
      context: context,
      isEdit: isEdit,
      policyId: policyId,
      controlId: controlId,
    );
    return ownerEmails.isEmpty;
  }

  /// function name: [applyAssigneeChanges]
  ///
  /// purpose: called once the Control itself has already saved
  ///          successfully. Reads each Cubit's already-loaded state as it
  ///          stood when the page opened, recomputes "already assigned" the
  ///          same way ControlAssigneesSectionWidget did, and diffs it
  ///          against whatever the user last toggled. If a Cubit never
  ///          finished loading, that side is skipped entirely rather than
  ///          guessed at. The per-cubit "already assigned" resolution and
  ///          the actual create/update diffing live in ChampionCubit/
  ///          OwnerCubit (`alreadyAssignedEmails`/`applyAssignmentDiff`);
  ///          this method is the remaining orchestration that wires them
  ///          together. Each side that was diffed is re-fetched afterward so
  ///          the Cubit lands back on ChampionListLoaded/OwnerListLoaded
  ///          instead of staying on ChampionActionSuccess/OwnerActionSuccess
  ///          — both Cubits are shared with ControlDetailsPage via
  ///          BlocProvider.value, so leaving them there would make
  ///          ControlAssigneesSectionWidget's pickers spin forever on every
  ///          subsequent visit.
  ///
  /// return type: [Future<bool>] - true if at least one side failed to save
  Future<bool> applyAssigneeChanges({
    required BuildContext context,
    required String moduleId,
    required String policyId,
    required String controlId,
  }) async {
    final championCubit = context.read<ChampionCubit>();
    final ownerCubit = context.read<OwnerCubit>();
    var hadFailure = false;

    final championState = championCubit.state;
    if (championState is ChampionListLoaded) {
      final alreadyAssigned = championCubit.alreadyAssignedEmails(
        championState.champions,
        policyId: policyId,
        controlId: controlId,
      );
      final selected = currentChampionEmails ?? alreadyAssigned;
      final ok = await championCubit.applyAssignmentDiff(
        allChampions: championState.champions,
        alreadyAssigned: alreadyAssigned,
        selected: selected,
        moduleId: moduleId,
        policyId: policyId,
        controlId: controlId,
      );
      if (!ok) hadFailure = true;
      // applyAssignmentDiff leaves the Cubit on ChampionActionSuccess/
      // ChampionFailure, not ChampionListLoaded — refetch so it's back in the
      // list state ControlAssigneesSectionWidget's BlocBuilder expects,
      // otherwise that picker spins forever for the rest of this Cubit's
      // lifetime (it's shared with ControlDetailsPage via BlocProvider.value).
      await championCubit.getAllChampions(moduleId: moduleId);
    }

    final ownerState = ownerCubit.state;
    if (ownerState is OwnerListLoaded) {
      final alreadyAssigned = ownerCubit.alreadyAssignedEmails(
        ownerState.owners,
        policyId: policyId,
        controlId: controlId,
      );
      final selected = currentOwnerEmails ?? alreadyAssigned;
      final ok = await ownerCubit.applyAssignmentDiff(
        allOwners: ownerState.owners,
        alreadyAssigned: alreadyAssigned,
        selected: selected,
        moduleId: moduleId,
        policyId: policyId,
        controlId: controlId,
      );
      if (!ok) hadFailure = true;
      // Same reasoning as the Champion side above: restore OwnerListLoaded
      // so the Owner picker doesn't spin forever after this save.
      await ownerCubit.getAllOwners(moduleId: moduleId);
    }

    return hadFailure;
  }
}
