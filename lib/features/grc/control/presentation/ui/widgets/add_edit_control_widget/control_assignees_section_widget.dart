/// Module: GRC Policy Management
/// Description: Control Champions + Control Owner picker section for the
///              Add/Edit Control form (Edit mode only), extracted from
///              AddEditControlPage.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-15
/// Dependencies: flutter_bloc, ChampionCubit, OwnerCubit, GrcOwnerSection
/// Revision History: 2026-07-15 - Initial creation (inline in
///                                add_edit_control_page.dart)
///                   2026-07-27 - Split out into its own widget file
library;

/// ************************* FILE INFO *************************** ///
/// File Name: control_assignees_section_widget.dart
/// Purpose: Contains ControlAssigneesSectionWidget, the "Control Champions"
///          and "Control Owner" pickers. Edit mode only — a new Control has
///          no id to assign against yet. Each picker starts pre-selected
///          with whoever is already assigned to this exact
///          {Policy, Control} pair, filtered live by the Control's
///          currently-selected departments, and reports every toggle back
///          via its callbacks — nothing is persisted here; that happens
///          once the Control itself saves (see AddEditControlPage's
///          `_applyAssigneeChanges`).
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 27/7/2026

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/grc/control_champion/presentation/controller/champion_cubit.dart';
import 'package:knowticed_plus/features/grc/control_owner/presentation/controller/owner_cubit.dart';
import 'package:knowticed_plus/features/grc/module/presentation/controller/cubit/grc_owner_cubit.dart';
import 'package:knowticed_plus/features/grc/module/presentation/ui/widgets/grc_details_widget/grc_owner_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// class name: [ControlAssigneesSectionWidget]
///
/// purpose: renders the Champion/Owner picker sections below the
///          Departments section.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 27/7/2026
class ControlAssigneesSectionWidget extends StatelessWidget {
  final String policyId;
  final String controlId;
  final List<String> realSelectedDepartments;
  final void Function(List<OwnerData> selected) onChampionsChanged;
  final void Function(List<OwnerData> selected) onOwnersChanged;

  /// Shown below the Control Owner picker when a Champion is assigned but no
  /// Owner is — a Control's Champion always requires an Owner too. Null/empty
  /// renders nothing.
  final String? ownerErrorText;

  /// The currently selected Champion/Owner emails (live selection if
  /// touched, otherwise whoever is already assigned) — each is hidden from
  /// the *other* picker so the same person can never be both this Control's
  /// Champion and its Owner at once.
  final List<String> selectedChampionEmails;
  final List<String> selectedOwnerEmails;

  const ControlAssigneesSectionWidget({
    super.key,
    required this.policyId,
    required this.controlId,
    required this.realSelectedDepartments,
    required this.onChampionsChanged,
    required this.onOwnersChanged,
    required this.selectedChampionEmails,
    required this.selectedOwnerEmails,
    this.ownerErrorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15.h),
        BlocBuilder<ChampionCubit, ChampionState>(
          builder: (context, state) {
            if (state is! ChampionListLoaded) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            return GrcOwnerSection(
              sectionTitle: 'Control Champions',
              initialOwnerEmails: context.read<ChampionCubit>().alreadyAssignedEmails(
                    state.champions,
                    policyId: policyId,
                    controlId: controlId,
                  ),
              selectedDepartmentNames: realSelectedDepartments,
              showRemoveIconWhenSelected: true,
              singleSelect: true,
              excludeEmails: selectedOwnerEmails,
              onOwnersChanged: onChampionsChanged,
            );
          },
        ),
        SizedBox(height: 15.h),
        BlocBuilder<OwnerCubit, OwnerState>(
          builder: (context, state) {
            if (state is! OwnerListLoaded) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            return GrcOwnerSection(
              sectionTitle: 'Control Owner',
              initialOwnerEmails: context.read<OwnerCubit>().alreadyAssignedEmails(
                    state.owners,
                    policyId: policyId,
                    controlId: controlId,
                  ),
              selectedDepartmentNames: realSelectedDepartments,
              showRemoveIconWhenSelected: true,
              singleSelect: true,
              errorText: ownerErrorText,
              excludeEmails: selectedChampionEmails,
              onOwnersChanged: onOwnersChanged,
            );
          },
        ),
      ],
    );
  }
}
