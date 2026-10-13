/// Module: time_tracker / tt7_groups / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: group_form_page.dart
/// Purpose: Declares `GroupFormPage` — "Tracking Time › Creating New
///          Group" / "› Editing Group": group picture · Group
///          Name · Description (0/500) · Members · Location · Start Date ·
///          Allow Breaks (+ length) · Allow Pause · Allow Different Work
///          Location (+ Select Location) · Discard / Create Group | Save.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Figma `661:95712` (create) / `661:96092` (edit) + a Members picker (a
/// group needs members; Figma has none on the form). Dialogs: create →
/// "Group Creation" `661:95388`; edit `661:95354` → `661:95346`. Saving
/// applies the group's location / start date / rules to its members'
/// assignments (`EmployeesCubit.saveGroup` → `GroupService`). Gates
/// `Create_Group` / `Edit_Group`. The page owns the text controllers.
/// Updated: 9/10/2026 - owner decisions 32–33: name + description in EN
/// and AR; under the location its rules preview + "Use the location's
/// rules" (OFF = custom break / pause for this group, from the location's
/// values).
/// Updated: 9/10/2026 - owner review: the group image is the app's image
/// picker (`CustomImagePicker` — a circle with the yellow camera badge);
/// Members = `GroupMemberPicker` (Search + Department on one row, rows
/// with tick boxes, selected count); field labels keep the text colour on
/// an error (red labels were unreadable on the dark card) — the red error
/// line under the field says what is missing.
/// Updated: 9/10/2026 - code review: Material icons → the app's SVG line
/// icons (`TtAssets` / `TtGlyph`) where an equivalent asset exists.
/// Updated: 9/10/2026 - QA KP-TT-008 (re-checked on the round-6 form): with
/// "Use the location's rules" ON the group follows the chosen location
/// (preview + nothing copied — fixed by decision 33). Remaining gap fixed
/// here: custom rules not yet edited by hand now re-seed from a NEWLY
/// chosen location (they kept the first location's values), like Grant
/// Access.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/3-custom_dropdown_calander.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_date.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/effective_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/employee_assignment_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_action_failure.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/location_rules_panel.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/features/time_tracker/tt5_locations/presentation/ui/widgets/location_form_fields.dart';
import 'package:knowticed_plus/features/time_tracker/tt6_employees/presentation/controller/employees_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt6_employees/presentation/ui/widgets/grant_access_dialog.dart';
import 'package:knowticed_plus/features/time_tracker/tt7_groups/presentation/controller/group_form_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt7_groups/presentation/ui/widgets/group_member_picker.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class GroupFormPage extends StatelessWidget {
  const GroupFormPage({super.key, this.original});

  /// The group to edit (null = create).
  final EmployeeGroup? original;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GroupFormCubit>(
      create: (_) => GetIt.instance<GroupFormCubit>(param1: original),
      child: const _GroupFormView(),
    );
  }
}

class _GroupFormView extends StatefulWidget {
  const _GroupFormView();

  @override
  State<_GroupFormView> createState() => _GroupFormViewState();
}

class _GroupFormViewState extends State<_GroupFormView> {
  late final TextEditingController _name;
  late final TextEditingController _nameAr;
  late final TextEditingController _description;
  late final TextEditingController _descriptionAr;
  late final TextEditingController _break;
  late final TextEditingController _pauseLimit;
  TtDurationUnit _unit = TtDurationUnit.minutes;

  /// QA KP-TT-008 (9/10/2026): the custom break / pause values were changed
  /// by hand. Until then they follow the chosen location (a new location
  /// re-seeds them), exactly like the Grant Access dialog.
  bool _rulesTouched = false;

  GroupFormCubit get _cubit => context.read<GroupFormCubit>();
  EmployeeGroup get _draft => _cubit.state.draft;

  @override
  void initState() {
    super.initState();
    final EmployeeGroup g = context.read<GroupFormCubit>().state.draft;
    _name = TextEditingController(text: g.name);
    _nameAr = TextEditingController(text: g.nameAr);
    _description = TextEditingController(text: g.description);
    _descriptionAr = TextEditingController(text: g.descriptionAr);
    final int m = g.rules.breakMinutes;
    final bool hours = m > 0 && m % 60 == 0;
    _unit = hours ? TtDurationUnit.hours : TtDurationUnit.minutes;
    _break = TextEditingController(text: m <= 0 ? '' : '${hours ? m ~/ 60 : m}');
    _pauseLimit = TextEditingController(text: g.rules.pauseMinutes <= 0 ? '' : '${g.rules.pauseMinutes}');
    // An existing group's own custom rules are kept as they are.
    _rulesTouched = g.rules.isCustom;
  }

  @override
  void dispose() {
    _name.dispose();
    _nameAr.dispose();
    _description.dispose();
    _descriptionAr.dispose();
    _break.dispose();
    _pauseLimit.dispose();
    super.dispose();
  }

  void _rules({bool? breaks, bool? pause, bool? different, List<String>? allowed}) {
    final AttendanceRules r = _draft.rules;
    _cubit.update(_draft.copyWith(
      rules: AttendanceRules(
        isBreakAllowed: r.isCustom && (breaks ?? r.isBreakAllowed),
        breakMinutes: r.isCustom ? TtBreakLengthField.minutesOf(_break.text, _unit) : 0,
        isPauseAllowed: r.isCustom && (pause ?? r.isPauseAllowed),
        pauseMinutes: r.isCustom && (pause ?? r.isPauseAllowed)
            ? TtPauseLimitField.minutesOf(_pauseLimit.text)
            : 0,
        isDifferentLocationAllowed: different ?? r.isDifferentLocationAllowed,
        allowedLocationIds: allowed ?? r.allowedLocationIds,
        isCustom: r.isCustom,
      ),
    ));
  }

  /// A break / pause value changed by hand (QA KP-TT-008).
  void _editRules({bool? breaks, bool? pause}) {
    _rulesTouched = true;
    _rules(breaks: breaks, pause: pause);
  }

  WorkLocation? _location(List<WorkLocation> all) {
    for (final WorkLocation l in all) {
      if (l.id == _draft.locationId) return l;
    }
    return null;
  }

  /// QA KP-TT-008 (9/10/2026): choosing another location while the group
  /// has untouched custom rules re-seeds them from the new location (they
  /// kept the first location's values — or "no breaks" — before).
  void _pickLocation(String id, List<WorkLocation> all) {
    _cubit.update(_draft.copyWith(locationId: id));
    if (_draft.rules.isCustom && !_rulesTouched) _setUseLocation(false, _location(all));
  }

  /// Decision 33 (9/10/2026): OFF = custom rules for this group, starting
  /// from the location's values; ON = follow the location (nothing copied).
  void _setUseLocation(bool use, WorkLocation? location) {
    final AttendanceRules r = _draft.rules;
    if (use) {
      _cubit.update(_draft.copyWith(rules: AttendanceRules.fromLocation.copyWith(
        isDifferentLocationAllowed: r.isDifferentLocationAllowed,
        allowedLocationIds: r.allowedLocationIds,
      )));
      return;
    }
    final AttendanceRules from = location == null
        ? const AttendanceRules()
        : EffectiveRulesResolver.locationRules(location);
    final bool hours = from.breakMinutes > 0 && from.breakMinutes % 60 == 0;
    setState(() {
      _rulesTouched = false;
      _unit = hours ? TtDurationUnit.hours : TtDurationUnit.minutes;
      _break.text = from.breakMinutes <= 0 ? '' : '${hours ? from.breakMinutes ~/ 60 : from.breakMinutes}';
      _pauseLimit.text = from.pauseMinutes <= 0 ? '' : '${from.pauseMinutes}';
    });
    _cubit.update(_draft.copyWith(rules: from.copyWith(
      isCustom: true,
      isDifferentLocationAllowed: r.isDifferentLocationAllowed,
      allowedLocationIds: r.allowedLocationIds,
    )));
  }

  Future<void> _submit() async {
    final GroupFormCubit form = _cubit;
    if (!form.revealErrors()) return;
    final EmployeesCubit employees = context.read<EmployeesCubit>();
    final S s = S.of(context);
    final bool edit = form.state.isEdit;
    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmWidth: 411,
      scaleIn: true,
      confirmLottie: edit ? AppAssets.lottieEditDocument : AppAssets.lottieConfirmation,
      confirmTitle: edit ? s.timeTrackerEditingGroupDetails : s.timeTrackerCreatingNewGroup,
      confirmSubtitle: edit ? s.timeTrackerEditGroupConfirm : s.timeTrackerCreateGroupConfirm,
      confirmYesText: s.yes,
      confirmNoText: s.no,
      onConfirm: refreshingCheckIn(
        context,
        () => employees.saveGroup(form.state.draft, before: form.state.original),
      ),
      successLottie: AppAssets.successful,
      successTitle: edit ? s.timeTrackerEditedGroupTitle : s.timeTrackerGroupCreationTitle,
      successSubtitle: edit ? s.timeTrackerGroupEdited : s.timeTrackerGroupCreated,
      onSuccessComplete: () {
        if (mounted) Navigator.of(context).pop();
      },
    );
    if (!mounted || employees.state.failure == TimeTrackerActionFailure.none) return;
    final bool denied = employees.state.failure == TimeTrackerActionFailure.denied;
    employees.acknowledgeFailure();
    await showTimeTrackerFailure(context, denied: denied);
  }

  /// The Discard · primary row (pinned on a phone, under the form on a tablet).
  Widget _actions(GroupFormState state) {
    final S s = S.of(context);
    return TimeTrackerFormActions(
      primaryKey: const ValueKey<String>('groupSubmitButton'),
      primaryTitle: state.isEdit ? s.save : s.timeTrackerCreateGroup,
      canSubmit: state.canSubmit,
      onDiscard: () => Navigator.of(context).maybePop(),
      onSubmit: _submit,
      onDisabledTap: _cubit.revealErrors,
      // 12/10/2026 (owner R4 / K2): an unchanged Edit form says why Save is grey.
      hint: state.isEdit && state.showErrors && state.groupErrors.isEmpty && state.ruleErrors.isEmpty && !state.isDirty ? s.noChangeFound : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool edit = _cubit.state.isEdit;
    return Scaffold(
      backgroundColor: AppColors.background,
      // 12/10/2026 (owner R8): phone — the action row stays fixed.
      bottomNavigationBar: context.isPhone
          ? TtPinnedFormActions(
              child: BlocBuilder<GroupFormCubit, GroupFormState>(
                builder: (BuildContext context, GroupFormState state) => _actions(state),
              ),
            )
          : null,
      body: SideFrameMasterServices(
        titleText: s.timeTrackerTitle,
        // Two crumbs like every phase-3 page: the core tablet breadcrumb
        // does not shrink, so a third one overflows with long names.
        secondTitle: edit ? s.timeTrackerEditingGroup : s.timeTrackerCreatingNewGroup,
        onFirstTap: () => Navigator.of(context).maybePop(),
        child: SideFrameScrollableBody(
          child: BlocBuilder<GroupFormCubit, GroupFormState>(
            builder: (BuildContext context, GroupFormState state) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SlideInContent(child: TtFormCard(child: _fields(state))),
                if (!context.isPhone) ...<Widget>[
                  SizedBox(height: 20.h),
                  _actions(state),
                  SizedBox(height: 20.h),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Owner review (9/10/2026): the app's image picker — a circle with the
  /// yellow camera badge (`CustomImagePicker`), like every other profile /
  /// group picture; the picked file is uploaded by the cubit.
  Widget _picture(GroupFormState state) {
    final S s = S.of(context);
    final String url = state.draft.imageUrl;
    return Row(
      children: <Widget>[
        KeyedSubtree(
          key: const ValueKey<String>('groupPicture'),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              CustomImagePicker(
                imageUrl: url.startsWith('http') ? url : null,
                radius: 32.r,
                readOnly: state.isUploading,
                onImagePicked: _cubit.uploadImageFile,
                onError: (_) => _cubit.markUploadFailed(),
              ),
              if (state.isUploading)
                SizedBox(width: 24.r, height: 24.r, child: const CircleProgressMaster()),
            ],
          ),
        ),
        if (state.uploadFailed) ...<Widget>[
          SizedBox(width: 12.w),
          Expanded(child: TtFieldError(s.timeTrackerUploadFailed)),
        ],
      ],
    );
  }

  /// Labels stay in the text colour on an error (dark mode contrast).
  TextStyle get _label => StyleText.fontSize14Weight500.copyWith(color: AppColors.text);

  Widget _fields(GroupFormState state) {
    final S s = S.of(context);
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    final EmployeesState people = context.watch<EmployeesCubit>().state;
    final EmployeeGroup d = state.draft;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _picture(state),
        SizedBox(height: 15.h),
        // Decision 32 (9/10/2026): name + description in EN and AR.
        TtPair(
          start: CustomTextField(
            key: const ValueKey<String>('groupNameField'),
            controller: _name,
            label: s.timeTrackerGroupName,
            labelStyle: _label,
            hint: s.textHere,
            height: 36,
            errorText: state.shows(GroupFormError.nameRequired) ? s.timeTrackerNameRequired : null,
            valueStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
            onChanged: (String v) => _cubit.update(_draft.copyWith(name: v)),
          ),
          end: CustomTextField(
            key: const ValueKey<String>('groupNameArField'),
            controller: _nameAr,
            label: s.timeTrackerGroupNameAr,
            labelStyle: _label,
            hint: s.timeTrackerTextHereAr,
            height: 36,
            textDirection: TextDirection.rtl,
            errorText: state.shows(GroupFormError.nameArRequired) ? s.timeTrackerArabicNameRequired : null,
            valueStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
            onChanged: (String v) => _cubit.update(_draft.copyWith(nameAr: v)),
          ),
        ),
        SizedBox(height: 15.h),
        TtPair(
          start: CustomTextField(
            key: const ValueKey<String>('groupDescriptionField'),
            controller: _description,
            label: s.timeTrackerDescription,
            labelStyle: _label,
            hint: s.textHere,
            height: 72,
            maxLines: 3,
            minLines: 3,
            maxLength: GroupFormState.maxDescriptionLength,
            keyboardType: TextInputType.multiline,
            valueStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
            onChanged: (String v) => _cubit.update(_draft.copyWith(description: v)),
          ),
          end: CustomTextField(
            key: const ValueKey<String>('groupDescriptionArField'),
            controller: _descriptionAr,
            label: s.timeTrackerGroupDescriptionAr,
            labelStyle: _label,
            hint: s.timeTrackerTextHereAr,
            height: 72,
            maxLines: 3,
            minLines: 3,
            maxLength: GroupFormState.maxDescriptionLength,
            keyboardType: TextInputType.multiline,
            textDirection: TextDirection.rtl,
            valueStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
            onChanged: (String v) => _cubit.update(_draft.copyWith(descriptionAr: v)),
          ),
        ),
        SizedBox(height: 15.h),
        GroupMemberPicker(
          key: const ValueKey<String>('groupMembersField'),
          people: <TimeTrackerEmployee>[for (final EmployeeAssignmentRow r in people.rows) r.employee],
          departments: people.departments,
          selected: d.memberEmails,
          error: state.shows(GroupFormError.membersRequired) ? s.timeTrackerMembersRequired : null,
          onChanged: _cubit.setMembers,
        ),
        SizedBox(height: 15.h),
        // 12/10/2026 (owner T5 / T6 / U4): Work Locations (main first),
        // the main location's rules right under it, then the start date.
        TtWorkLocationsField(
          key: const ValueKey<String>('groupLocationField'),
          mainId: d.locationId,
          extraIds: d.rules.allowedLocationIds,
          locations: people.activeLocations,
          isArabic: ar,
          labelStyle: _label,
          error: state.showsRule(AssignmentError.locationRequired) ? s.timeTrackerLocationRequired : null,
          onChanged: (String main, List<String> extras) {
            _rules(allowed: extras);
            // QA KP-TT-008 (9/10/2026): untouched custom rules follow it.
            if (main != d.locationId) _pickLocation(main, people.activeLocations);
          },
        ),
        SizedBox(height: 15.h),
        // Decision 33 (9/10/2026): the location's rules + the switch.
        LocationRulesPanel(
          location: _location(people.activeLocations),
          useLocation: !d.rules.isCustom,
          onUseLocation: (bool use) => _setUseLocation(use, _location(people.activeLocations)),
          customTitle: s.timeTrackerCustomRulesGroup,
        ),
        SizedBox(height: 15.h),
        CustomDropdownCalendar(
          key: const ValueKey<String>('groupStartDateField'),
          label: s.timeTrackerStartDate,
          labelStyle: _label,
          hint: s.timeTrackerChooseTheDate,
          value: d.startDate,
          height: 36,
          errorText: state.showsRule(AssignmentError.startDateRequired) ? s.timeTrackerStartDateRequired : null,
          dateFormatter: (DateTime x) => LocalizedDate.of(context, x),
          onChanged: (DateTime? x) {
            if (x != null) _cubit.update(_draft.copyWith(startDate: x));
          },
        ),
        SizedBox(height: 15.h),
        AttendanceRulesFields(
          showBreakPause: d.rules.isCustom,
          breaks: d.rules.isBreakAllowed,
          pause: d.rules.isPauseAllowed,
          different: d.rules.isDifferentLocationAllowed,
          breakController: _break,
          pauseController: _pauseLimit,
          onPauseLength: (_) => _editRules(),
          unit: _unit,
          locations: people.activeLocations,
          isArabic: ar,
          breakError: state.showsRule(AssignmentError.breakLengthRequired) ? s.timeTrackerBreakLengthRequired : null,
          // QA KP-TT-008 (9/10/2026): a break / pause edit is the admin's own.
          onBreaks: (bool v) => _editRules(breaks: v),
          onPause: (bool v) => _editRules(pause: v),
          onDifferent: (bool v) => _rules(different: v),
          onBreakLength: _editRules,
          onUnit: (TtDurationUnit u) {
            setState(() => _unit = u);
            _editRules();
          },
        ),
      ],
    );
  }
}
