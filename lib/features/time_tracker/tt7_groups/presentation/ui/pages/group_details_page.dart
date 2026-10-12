/// Module: time_tracker / tt7_groups / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: group_details_page.dart
/// Purpose: Declares `GroupDetailsPage` — "Tracking Time › {Group}":
///          picture · name · description · location · start date · rules,
///          Edit · Delete, and "Employee Information" (search + member
///          cards).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Figma `661:95396`. Gates: Edit `Edit_Group`, Delete `Delete_Group`
/// (soft; members keep their location). Dialogs: `661:95367` "Deleting
/// Groups" → `661:95380` "You Successfully Deleted This Group". Live from
/// `EmployeesCubit`; a deleted group closes the page.
/// Updated: 9/10/2026 - UI fix round 1: centred search (`TtSearchField`).
/// Updated: 9/10/2026 - owner decisions 32–33: name / description in the
/// app language; a group following its location shows the location's
/// break / pause rules with a "From location" / "Custom" tag; member cards
/// show each member's effective rules.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/13-custom_edit_icon.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/effective_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_action_failure.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/location_rules_panel.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_formatters.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/features/time_tracker/tt6_employees/presentation/controller/employees_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt6_employees/presentation/ui/widgets/employee_card.dart';
import 'package:knowticed_plus/features/time_tracker/tt7_groups/presentation/ui/pages/group_form_page.dart';
import 'package:knowticed_plus/features/time_tracker/tt7_groups/presentation/ui/widgets/groups_view.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class GroupDetailsPage extends StatefulWidget {
  const GroupDetailsPage({super.key, required this.groupId});

  final String groupId;

  @override
  State<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  TimeTrackerAccess get _access => GetIt.instance<TimeTrackerAccess>();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _delete(EmployeeGroup group) async {
    final S s = S.of(context);
    final EmployeesCubit cubit = context.read<EmployeesCubit>();
    final NavigatorState nav = Navigator.of(context);
    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmWidth: 411,
      destructive: true,
      confirmLottie: AppAssets.lottieWarning,
      confirmTitle: s.timeTrackerDeletingGroups,
      confirmSubtitle: s.timeTrackerDeleteGroupConfirm,
      confirmYesText: s.yes,
      confirmNoText: s.no,
      onConfirm: refreshingCheckIn(context, () => cubit.deleteGroup(group)),
      successLottie: AppAssets.successful,
      successTitle: s.timeTrackerDeletedGroupTitle,
      successSubtitle: s.timeTrackerGroupDeleted,
      onSuccessComplete: () => nav.maybePop(),
    );
    if (!mounted || cubit.state.failure == TimeTrackerActionFailure.none) return;
    final bool denied = cubit.state.failure == TimeTrackerActionFailure.denied;
    cubit.acknowledgeFailure();
    await showTimeTrackerFailure(context, denied: denied);
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return BlocBuilder<EmployeesCubit, EmployeesState>(
      builder: (BuildContext context, EmployeesState state) {
        final EmployeeGroup? group = state.groupById(widget.groupId);
        if (group == null || group.isDeleted) {
          return Scaffold(backgroundColor: AppColors.background, body: const Center(child: CustomEmptyState()));
        }
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SideFrameMasterServices(
            titleText: s.timeTrackerTitle,
            // Two crumbs (see group_form_page.dart).
            secondTitle: FormatHelper.capitalize(
              group.label(isArabic: Localizations.localeOf(context).languageCode == 'ar'),
            ),
            onFirstTap: () => Navigator.of(context).maybePop(),
            child: SideFrameScrollableBody(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SlideInContent(child: _header(context, state, group)),
                  SizedBox(height: 15.h),
                  SlideInContent(
                    delay: const Duration(milliseconds: 60),
                    child: TtFormCard(child: _info(context, state, group)),
                  ),
                  SizedBox(height: 20.h),
                  SlideInContent(
                    delay: const Duration(milliseconds: 120),
                    child: _members(context, state, group),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _header(BuildContext context, EmployeesState state, EmployeeGroup group) {
    final S s = S.of(context);
    final bool hr = state.companyHasHr;
    return Row(
      children: <Widget>[
        GroupPicture(url: group.imageUrl, size: 56.r),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
              FormatHelper.capitalize(group.label(isArabic: Localizations.localeOf(context).languageCode == 'ar')),
              style: StyleText.fontSize18Weight500.copyWith(color: AppColors.text)),
        ),
        if (_access.canEditGroup && !hr)
          CustomEditIcon(
            key: const ValueKey<String>('groupEditButton'),
            title: s.edit,
            onTap: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(builder: (_) => GroupFormPage(original: group)),
            ),
          ),
        if (_access.canDeleteGroup && !hr) ...<Widget>[
          SizedBox(width: 10.w),
          // UI quality pass (owner 13:45 #7): red + white.
          TtDeleteButton(
            key: const ValueKey<String>('groupDeleteButton'),
            title: s.delete,
            onTap: () => _delete(group),
          ),
        ],
      ],
    );
  }

  Widget _info(BuildContext context, EmployeesState state, EmployeeGroup group) {
    final S s = S.of(context);
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    String yesNo(bool v) => v ? s.yes : s.no;
    // Decision 33 (9/10/2026): a group that follows its location shows the
    // location's break / pause rules ("From location"), else its own.
    final WorkLocation? place = state.locationById(group.locationId);
    final AttendanceRules r = group.rules.isCustom || place == null
        ? group.rules
        : EffectiveRulesResolver.locationRules(place).copyWith(
            isDifferentLocationAllowed: group.rules.isDifferentLocationAllowed,
            allowedLocationIds: group.rules.allowedLocationIds,
          );
    final String about = group.about(isArabic: ar);
    final List<(String, String)> items = <(String, String)>[
      (s.timeTrackerDescription, about.isEmpty ? TimeTrackerFormat.dash : about),
      (s.timeTrackerLocation, state.locationById(group.locationId)?.name(isArabic: ar) ?? TimeTrackerFormat.dash),
      (s.timeTrackerStartDate, TimeTrackerFormat.date(context, group.startDate)),
      (s.timeTrackerAllowBreaks, r.isBreakAllowed ? TimeTrackerFormat.mins(context, r.breakMinutes) : s.no),
      (s.timeTrackerAllowPause, yesNo(r.isPauseAllowed)),
      (
        s.timeTrackerAllowDifferentLocation,
        r.isDifferentLocationAllowed
            ? <String>[
                for (final String id in r.allowedLocationIds)
                  state.locationById(id)?.name(isArabic: ar) ?? id,
              ].join(ar ? '، ' : ', ')
            : s.no,
      ),
    ];
    Widget value((String, String) item) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(item.$1, style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText)),
            SizedBox(height: 4.h),
            Text(item.$2, style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
          ],
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < items.length; i += 2) ...<Widget>[
          if (i > 0) SizedBox(height: 12.h),
          TtPair(start: value(items[i]), end: i + 1 < items.length ? value(items[i + 1]) : null),
        ],
        SizedBox(height: 12.h),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: RulesSourceTag(
            key: const ValueKey<String>('groupRulesSource'),
            source: group.rules.isCustom ? RulesSource.group : RulesSource.location,
          ),
        ),
      ],
    );
  }

  Widget _members(BuildContext context, EmployeesState state, EmployeeGroup group) {
    final S s = S.of(context);
    final String q = _query.trim().toLowerCase();
    final List<TimeTrackerEmployee> people = <TimeTrackerEmployee>[
      for (final String e in group.memberEmails)
        state.employeeByEmail(e) ?? TimeTrackerEmployee(email: e),
    ].where((TimeTrackerEmployee e) => q.isEmpty || e.searchText.contains(q)).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(s.timeTrackerEmployeeInformation,
            style: StyleText.fontSize16Weight500.copyWith(color: AppColors.text)),
        SizedBox(height: 10.h),
        Row(
          children: <Widget>[
            TtSearchField(
              controller: _search,
              onChanged: (String v) => setState(() => _query = v),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        if (people.isEmpty)
          const CustomEmptyState()
        else
          AnimatedSizeWrap(
            child: EmployeeCardGrid(
              children: <Widget>[
                for (final TimeTrackerEmployee p in people)
                  EmployeeCard(
                    employee: p,
                    assignment: state.assignmentOf(p.email),
                    rules: state.effectiveRulesOf(p.email),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
