/// Module: GRC Module Management
/// Description: Provides the Module Owner section for the GRC Module details
///              page. In view/restore mode shows only selected owners; in
///              create/edit mode shows all employees with a search field so
///              the user can toggle selection.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-06-29
/// Dependencies: GrcOwnerCubit, PersonChipCard, AppSearchTextField
/// Revision History: 2026-06-29 - Initial creation
///                    2026-06-30 - Added initialOwnerEmails for pre-selection (Mohamed Magdy Abdelkhalek)
library;

import 'package:knowticed_plus/core/custom/19-Custom_Employee_Card.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: grc_owner_section.dart
/// Purpose: Contains GrcOwnerSection, which renders the owner-selection grid
///          for a GRC Module in both view and edit modes.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 29/6/2026

import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/module/presentation/controller/cubit/grc_owner_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// class name: [GrcOwnerSection]
///
/// purpose: displays the Module Owner picker section inside the GRC Module
///          details page. Owns a private [GrcOwnerCubit] instance and passes
///          [initialOwnerEmails] to pre-select existing owners. In view/restore
///          mode only selected owners are shown; in create/edit mode all
///          employees appear with a search bar.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 29/6/2026
class GrcOwnerSection extends StatefulWidget {
  final bool isViewMode;

  /// Emails of owners already assigned to the module.
  /// - In view/restore mode  → only these owners are displayed.
  /// - In create/edit mode   → these owners are pre-selected.
  final List<String> initialOwnerEmails;

  /// The department currently selected on the form. When set, only
  /// employees belonging to this department are shown as owner candidates.
  final String? selectedDepartmentName;

  /// Same idea as [selectedDepartmentName] but for callers that can be
  /// scoped to several departments at once (e.g. a Control). When set,
  /// takes precedence over [selectedDepartmentName].
  final List<String>? selectedDepartmentNames;

  final void Function(List<OwnerData> selected)? onOwnersChanged;

  /// When true, selecting one person clears any previous selection so at
  /// most one [OwnerData] is selected at a time (used by the Add
  /// Champion/Add Owner pages, where exactly one person is being assigned).
  final bool singleSelect;

  /// When true, an already-selected person shows a red remove icon instead
  /// of a checked checkbox (used by the Control assignee pickers, where
  /// picking someone reads as "assign" and un-picking reads as "remove").
  /// Tapping the card still toggles selection either way.
  final bool showRemoveIconWhenSelected;

  /// The label shown above the picker. Defaults to the Module Owner
  /// picker's original hardcoded text so existing callers are unaffected.
  final String? sectionTitle;

  /// Inline validation message shown below the picker (e.g. "Please select
  /// a new Control Champion"). Null/empty renders nothing.
  final String? errorText;

  /// Emails hidden from the picker entirely — used so a person already
  /// picked in a related picker (e.g. this Control's Champion) can't also be
  /// picked here (e.g. as its Owner).
  final List<String> excludeEmails;

  const GrcOwnerSection({
    super.key,
    this.isViewMode = false,
    this.initialOwnerEmails = const [],
    this.selectedDepartmentName,
    this.selectedDepartmentNames,
    this.onOwnersChanged,
    this.singleSelect = false,
    this.showRemoveIconWhenSelected = false,
    this.sectionTitle,
    this.errorText,
    this.excludeEmails = const [],
  });

  @override
  State<GrcOwnerSection> createState() => _GrcOwnerSectionState();
}

class _GrcOwnerSectionState extends State<GrcOwnerSection> {
  late final GrcOwnerCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = GrcOwnerCubit();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _cubit.loadOwners(
        context,
        initialOwnerEmails: widget.initialOwnerEmails,
        selectedDepartmentName: widget.selectedDepartmentName,
        selectedDepartmentNames: widget.selectedDepartmentNames,
        excludeEmails: widget.excludeEmails,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant GrcOwnerSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDepartmentName != widget.selectedDepartmentName ||
        !_listEquals(oldWidget.selectedDepartmentNames,
            widget.selectedDepartmentNames)) {
      _cubit.filterByDepartments(
        widget.selectedDepartmentNames ??
            (widget.selectedDepartmentName == null
                ? null
                : [widget.selectedDepartmentName!]),
      );
    }
    if (!_listEquals(oldWidget.excludeEmails, widget.excludeEmails)) {
      _cubit.filterByExcludedEmails(widget.excludeEmails);
    }
  }

  bool _listEquals(List<String>? a, List<String>? b) {
    if (a == null || b == null) return a == b;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  ImageProvider _buildAvatar(String photo) {
    if (photo.startsWith('http')) return NetworkImage(photo);
    return AssetImage(photo);
  }

  void _onToggle(OwnerData owner) {
    _cubit.toggleOwnerData(owner, singleSelect: widget.singleSelect);
    widget.onOwnersChanged?.call(_cubit.selectedOwners);
  }

  /// GRC bug report p6: once the one person a single-select picker is for
  /// has been chosen, show only that person (tap them again to change) so
  /// the rest of the form isn't buried under the whole company.
  bool get _collapsed =>
      widget.singleSelect &&
      !widget.isViewMode &&
      _cubit.selectedOwners.isNotEmpty;

  /// Owner cards, laid out at the column count the design calls for:
  /// 1 up on phone (375: full-width cards), 2 up on tablet (768: 310-wide
  /// cards), 3 up on desktop (1024: 268-wide cards).
  ///
  /// One generic builder for all three. It used to be two hand-rolled
  /// branches — a 2-column Row and a 1-column Column — which is how the
  /// desktop 3-up row went missing and how `capitalize` ended up applied to
  /// the left card of each pair but not the right one.
  Widget _buildOwnerGrid(BuildContext context, List<OwnerData> owners) {
    final int columns = responsiveValue(
      context,
      mobile: 1,
      tablet: 2,
      desktop: 3,
    );

    final int rows = (owners.length / columns).ceil();

    return Column(
      children: List.generate(rows, (row) {
        // 10.h BETWEEN rows only — never after the last one.
        //
        // It used to be applied to every row, so the section ended with a
        // trailing 10.h that landed on top of the 15.sp the wrapping card
        // already pads with. The gap under the last owner card came out
        // roughly 1.8x the gap at the sides, which is the uneven bottom the
        // design flags. With the trailing pad gone, the inset below the grid
        // is exactly the card's own 15.sp — the same on all four sides.
        final bool isLastRow = row == rows - 1;

        return Padding(
          padding: EdgeInsets.only(bottom: isLastRow ? 0 : 10.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List<Widget>.generate(columns * 2 - 1, (slot) {
              // Odd slots are the gutters between cards.
              if (slot.isOdd) return SizedBox(width: 10.w);

              final int index = row * columns + slot ~/ 2;
              if (index >= owners.length) {
                return const Expanded(child: SizedBox());
              }
              return Expanded(child: _buildOwnerCard(owners[index]));
            }),
          ),
        );
      }),
    );
  }

  Widget _buildOwnerCard(OwnerData owner) {
    return PersonChipCard(
      name: owner.name.capitalize ?? owner.name,
      subtitle1: owner.department,
      subtitle2: owner.jobTitle,
      avatar: _buildAvatar(owner.photo),
      isSelected: owner.isSelected,
      showCheckBox: !widget.isViewMode,
      trailing: (widget.showRemoveIconWhenSelected && owner.isSelected)
          ? Icon(Icons.remove_circle, color: AppColors.red, size: 20.sp)
          : null,
      width: double.infinity,
      backgroundColor: AppColors.background,
      onTap: widget.isViewMode ? null : () => _onToggle(owner),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<GrcOwnerCubit, GrcOwnerState>(
        builder: (context, state) {
          // In view/restore mode show only the selected (assigned) owners.
          // In create/edit mode show all employees so the user can pick.
          final owners = widget.isViewMode
              ? _cubit.filteredOwners.where((o) => o.isSelected).toList()
              : _collapsed
                  ? _cubit.selectedOwners
                  : _cubit.filteredOwners;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.sectionTitle == null
                  ? SizedBox.shrink()
                  : Text(
                    widget.sectionTitle!,
                    style: StyleText.fontSize16Weight400
                        .copyWith(fontSize: 14.sp),
                  ),
              SizedBox(height: 8.h),
              if (!widget.isViewMode && !_collapsed) ...[
                Row(
                  children: [
                    AppSearchTextField(
                      controller: _cubit.searchController,
                      onChanged: _cubit.search,
                      hintText: S.of(context).search,
                      fillColor: AppColors.background,
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
              ],
              if (owners.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Center(
                    child: Text(
                      widget.isViewMode
                          ? S.of(context).noOwnersAssigned
                          : S.of(context).noPeopleFound,
                      style: StyleText.fontSize16Weight400.copyWith(
                        fontSize: 13.sp,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),
                )
              else
                _buildOwnerGrid(context, owners),
              if (widget.errorText != null && widget.errorText!.isNotEmpty) ...[
                SizedBox(height: 6.h),
                Text(
                  widget.errorText!,
                  style: StyleText.fontSize16Weight400
                      .copyWith(fontSize: 12.sp, color: AppColors.red),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
