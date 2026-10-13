/// Module: time_tracker / tt7_groups / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: groups_view.dart
/// Purpose: Declares `GroupsView` — the Employees tab's "Groups" segment:
///          "Group Information" · Search · Sort · + Group, then the group
///          cards (picture · name · member avatars "+N"); a card opens the
///          group's details — and `GroupPicture`, the round group image.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Figma `661:94406`. Gates: the segment needs `View_Groups`; + Group
/// `Create_Group`. The Figma tick boxes + "Review" button are not built:
/// tapping a card opens its details (Review), where Edit / Delete live.
/// Grid columns from `CrossAxisCountHelperResponsive`; no hover / splash;
/// cards slide in.
/// Updated: 9/10/2026 - UI fix round 1: centred search (`TtSearchField`).
/// Updated: 9/10/2026 - code review: Material icons → the app's SVG line
/// icons (`TtAssets` / `TtGlyph`) where an equivalent asset exists.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/47-custom_sort_button.dart';
import 'package:knowticed_plus/core/custom/88-stacked_avatars.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_card_grid.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/features/time_tracker/tt6_employees/presentation/controller/employees_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt7_groups/presentation/ui/pages/group_details_page.dart';
import 'package:knowticed_plus/features/time_tracker/tt7_groups/presentation/ui/pages/group_form_page.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class GroupsView extends StatefulWidget {
  const GroupsView({super.key});

  @override
  State<GroupsView> createState() => _GroupsViewState();
}

class _GroupsViewState extends State<GroupsView> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  String _sortLabel(S s, GroupSort sort) {
    switch (sort) {
      case GroupSort.nameAsc:
        return s.timeTrackerSortNameAsc;
      case GroupSort.nameDesc:
        return s.timeTrackerSortNameDesc;
      case GroupSort.newest:
        return s.timeTrackerSortNewest;
    }
  }

  void _push(Widget page) =>
      Navigator.of(context).push<void>(MaterialPageRoute<void>(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final TimeTrackerAccess access = GetIt.instance<TimeTrackerAccess>();
    return BlocBuilder<EmployeesCubit, EmployeesState>(
      builder: (BuildContext context, EmployeesState state) {
        final EmployeesCubit cubit = context.read<EmployeesCubit>();
        final List<EmployeeGroup> groups = state.visibleGroups;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(s.timeTrackerGroupInformation,
                style: StyleText.fontSize16Weight500.copyWith(color: AppColors.text)),
            SizedBox(height: 10.h),
            SlideInContent(
              child: Row(
                children: <Widget>[
                  TtSearchField(
                    controller: _search,
                    onChanged: cubit.groupSearchChanged,
                  ),
                  SizedBox(width: 15.w),
                  CustomSortButton<GroupSort>(
                    key: const ValueKey<String>('groupsSortButton'),
                    value: state.groupSort,
                    items: GroupSort.values,
                    showTitle: !context.isPhone,
                    labelBuilder: (GroupSort g) => _sortLabel(s, g),
                    onChanged: (GroupSort? g) {
                      HapticController.low();
                      cubit.groupSortChanged(g);
                    },
                  ),
                  if (access.canCreateGroup && !state.companyHasHr) ...<Widget>[
                    SizedBox(width: 15.w),
                    TtToolbarButton(
                      key: const ValueKey<String>('groupsAddButton'),
                      title: s.timeTrackerGroupButton,
                      icon: TtAssets.add,
                      onTap: () => _push(const GroupFormPage()),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 15.h),
            if (groups.isEmpty)
              const CustomEmptyState()
            else
              SlideInContent(
                delay: const Duration(milliseconds: 80),
                // UI quality pass (QA KP-TT-010): cards hug their content —
                // the fixed 98.h row clipped the member avatars.
                child: TtCardGrid(
                  children: <Widget>[
                    for (final EmployeeGroup g in groups)
                      _GroupCard(
                        group: g,
                        photos: <String>[
                          for (final String e in g.memberEmails) state.employeeByEmail(e)?.photo ?? '',
                        ],
                        onTap: () => _push(GroupDetailsPage(groupId: g.id)),
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.group, required this.photos, required this.onTap});

  final EmployeeGroup group;
  final List<String> photos;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final List<String> shown = <String>[
      for (final String p in photos)
        p.isEmpty ? 'assets/icons_assets/main_icons_assets/male_avatar.png' : p,
    ];
    return GestureDetector(
      key: ValueKey<String>('groupCard_${group.id}'),
      onTap: () {
        HapticController.low();
        onTap();
      },
      child: Container(
        padding: EdgeInsetsDirectional.all(10.r),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: CardStyles.radius()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                GroupPicture(url: group.imageUrl, size: 48.r),
                SizedBox(width: 10.w),
                Expanded(
                  // Decision 32 (9/10/2026): the app-language name.
                  child: Text(
                      FormatHelper.capitalize(
                        group.label(isArabic: Localizations.localeOf(context).languageCode == 'ar'),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: StyleText.fontSize16Weight500.copyWith(color: AppColors.text)),
                ),
              ],
            ),
            if (shown.isNotEmpty) ...<Widget>[
              SizedBox(height: 8.h),
              const Spacer(),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: StackedAvatars(images: shown, height: 28.r, width: 28.r * (1 + 0.6 * (shown.length.clamp(1, 5) - 1))),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The group picture (network) or the grey image placeholder.
class GroupPicture extends StatelessWidget {
  const GroupPicture({super.key, required this.url, this.size});

  final String url;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final double s = size ?? 48.r;
    // Owner review (9/10/2026): a CIRCLE, like the image picker of the
    // Create / Edit Group form (core `CustomImagePicker`).
    final Widget placeholder = Container(
      width: s,
      height: s,
      decoration: BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
      child: Center(child: TtIcon(const TtGlyph.svg(TtAssets.image), size: s * 0.5, color: AppColors.secondaryText)),
    );
    if (!url.startsWith('http')) return placeholder;
    return ClipOval(
      child: Image.network(url, width: s, height: s, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => placeholder),
    );
  }
}
