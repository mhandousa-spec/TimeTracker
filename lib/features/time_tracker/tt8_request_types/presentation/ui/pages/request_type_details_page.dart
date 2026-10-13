/// Module: time_tracker / tt8_request_types / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: request_type_details_page.dart
/// Purpose: Declares `RequestTypeDetailsPage` — "Tracking Time › {Request
///          Type}": every value of the type, Edit · Remove · Active /
///          Inactive.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Figma `661:44218`. Gates: Edit `Edit_Request_Type`, Remove
/// `Remove_Request_Type` (status `removed`; hidden once removed), the status
/// switch `Change_Request_Type_Status` (a removed type can be re-activated).
/// Dialogs (owner copy fixes): Remove `661:44426` → "Removing Request Type"
/// / "Request Type Removed" (the button says Remove, the Figma dialog said
/// Delete); Status `661:44439` "Changing Status" → `661:44452`. Live from
/// `RequestTypesCubit`.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/13-custom_edit_icon.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_formatters.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/setup_status.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_action_failure.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/features/time_tracker/tt8_request_types/presentation/controller/request_types_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt8_request_types/presentation/ui/pages/request_type_form_page.dart';
import 'package:knowticed_plus/features/time_tracker/tt8_request_types/presentation/ui/widgets/request_type_text.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class RequestTypeDetailsPage extends StatelessWidget {
  const RequestTypeDetailsPage({super.key, required this.typeId});

  final String typeId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RequestTypesCubit, RequestTypesState>(
      builder: (BuildContext context, RequestTypesState state) {
        final RequestType? type = state.byId(typeId);
        if (type == null) {
          return Scaffold(backgroundColor: AppColors.background, body: const Center(child: CustomEmptyState()));
        }
        return _Details(type: type, state: state);
      },
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.type, required this.state});

  final RequestType type;
  final RequestTypesState state;

  TimeTrackerAccess get _access => GetIt.instance<TimeTrackerAccess>();

  Future<void> _afterFlow(BuildContext context) async {
    final RequestTypesCubit cubit = context.read<RequestTypesCubit>();
    if (!context.mounted || cubit.state.failure == TimeTrackerActionFailure.none) return;
    final bool denied = cubit.state.failure == TimeTrackerActionFailure.denied;
    cubit.acknowledgeFailure();
    await showTimeTrackerFailure(context, denied: denied);
  }

  Future<void> _remove(BuildContext context) async {
    final S s = S.of(context);
    final RequestTypesCubit cubit = context.read<RequestTypesCubit>();
    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmWidth: 411,
      destructive: true,
      confirmLottie: AppAssets.lottieWarning,
      confirmTitle: s.timeTrackerRemovingRequestType,
      confirmSubtitle: s.timeTrackerRemoveRequestTypeConfirm,
      confirmYesText: s.yes,
      confirmNoText: s.no,
      onConfirm: () => cubit.remove(type),
      successLottie: AppAssets.successful,
      successTitle: s.timeTrackerRequestTypeRemovedTitle,
      successSubtitle: s.timeTrackerRequestTypeRemoved,
    );
    if (context.mounted) await _afterFlow(context);
  }

  Future<void> _restore(BuildContext context) async {
    final S s = S.of(context);
    final RequestTypesCubit cubit = context.read<RequestTypesCubit>();
    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmWidth: 411,
      confirmLottie: AppAssets.lottieWarning,
      confirmTitle: s.timeTrackerRestoringRequestType,
      confirmSubtitle: s.timeTrackerRestoreRequestTypeConfirm,
      confirmYesText: s.yes,
      confirmNoText: s.no,
      onConfirm: () => cubit.restore(type),
      successLottie: AppAssets.successful,
      successTitle: s.timeTrackerRequestTypeRestoredTitle,
      successSubtitle: s.timeTrackerRequestTypeRestored,
    );
    if (context.mounted) await _afterFlow(context);
  }

  /// Redesigned 12/10/2026 (owner J2 / R-3 / R-5): a header card (icon tile,
  /// name, description, the status as a coloured chip — no loose "Removed"
  /// text), then sections with icons: Approval Cycle · Request Requirements ·
  /// Availability · History (created by / date, last update by / date and,
  /// once removed, removed by / date).
  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    final String description = type.description(isArabic: ar);
    String person(String email) =>
        email.isEmpty ? TimeTrackerFormat.dash : (state.employeeByEmail(email)?.name(isArabic: ar) ?? email);
    final bool removed = type.status == RequestTypeStatus.removed;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: s.timeTrackerTitle,
        secondTitle: RequestTypeText.name(context, type),
        onFirstTap: () => Navigator.of(context).maybePop(),
        child: SideFrameScrollableBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SlideInContent(child: _actions(context, s)),
              SizedBox(height: 15.h),
              SlideInContent(
                delay: const Duration(milliseconds: 40),
                child: TtFormCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      RequestTypeIconTile(type: type, size: 56.r),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(RequestTypeText.name(context, type),
                                style: StyleText.fontSize18Weight500.copyWith(color: AppColors.text)),
                            if (description.isNotEmpty) ...<Widget>[
                              SizedBox(height: 4.h),
                              Text(description,
                                  style: StyleText.fontSize14Weight400.copyWith(color: AppColors.secondaryText)),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(width: 10.w),
                      RequestTypeStatusChip(key: const ValueKey<String>('requestTypeDetailsStatus'), status: type.status),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 15.h),
              SlideInContent(
                delay: const Duration(milliseconds: 80),
                child: TtPair(
                  start: _section(s.timeTrackerApprovalCycle, TtAssets.group, <Widget>[
                    _rule(const TtGlyph.svg(TtAssets.group), s.timeTrackerHrApproval,
                        RequestTypeText.required(context, type.isHrApprovalRequired), type.isHrApprovalRequired),
                    _rule(const TtGlyph.svg(TtAssets.person), s.timeTrackerManagerApproval,
                        RequestTypeText.required(context, type.isManagerApprovalRequired), type.isManagerApprovalRequired),
                  ]),
                  end: _section(s.timeTrackerSectionRequirements, TtAssets.description, <Widget>[
                    _rule(const TtGlyph.svg(TtAssets.description), s.timeTrackerDescription,
                        RequestTypeText.optional(context, type.isDescriptionRequired), type.isDescriptionRequired),
                    _rule(const TtGlyph.svg(TtAssets.attachment), s.timeTrackerAttachments,
                        RequestTypeText.optional(context, type.isAttachmentRequired), type.isAttachmentRequired),
                    _rule(const TtGlyph.svg(TtAssets.calendar), s.timeTrackerDeductsFromVacation,
                        type.isDeductedFromVacationBalance ? s.timeTrackerYes : s.timeTrackerNo,
                        type.isDeductedFromVacationBalance),
                  ]),
                ),
              ),
              SizedBox(height: 15.h),
              SlideInContent(
                delay: const Duration(milliseconds: 120),
                child: TtPair(
                  start: _section(s.timeTrackerSectionAvailability, TtAssets.location, <Widget>[
                    _info(TtAssets.location, s.timeTrackerLocationAvailability,
                        RequestTypeText.locations(context, type, state)),
                    _info(TtAssets.department, s.timeTrackerDepartmentAvailability,
                        RequestTypeText.departments(context, type, state)),
                  ]),
                  end: _section(s.timeTrackerSectionHistory, TtAssets.clock, <Widget>[
                    _info(TtAssets.person, s.timeTrackerAddedBy, person(type.audit.createdBy)),
                    _info(TtAssets.calendar, s.timeTrackerCreationDate,
                        TimeTrackerFormat.date(context, type.audit.createdAt)),
                    if (removed) ...<Widget>[
                      _info(TtAssets.person, s.timeTrackerRemovedBy, person(type.audit.modifiedBy),
                          key: const ValueKey<String>('requestTypeRemovedBy')),
                      _info(TtAssets.calendar, s.timeTrackerRemovedDate,
                          TimeTrackerFormat.date(context, type.audit.updatedAt)),
                    ] else ...<Widget>[
                      _info(TtAssets.person, s.timeTrackerUpdatedBy, person(type.audit.modifiedBy)),
                      _info(TtAssets.clock, s.timeTrackerLastUpdate,
                          TimeTrackerFormat.date(context, type.audit.updatedAt)),
                    ],
                  ]),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actions(BuildContext context, S s) {
    // UI quality pass (owner 13:45 #7 / #8): the status is changed inside
    // Edit (`TtStatusSwitch`); Remove is red with a white trash + text.
    // 12/10/2026 (owner R-4): a removed type shows Restore instead.
    final bool removed = type.status == RequestTypeStatus.removed;
    return Row(
      children: <Widget>[
        const Spacer(),
        if (_access.canEditRequestType && !removed)
          CustomEditIcon(
            key: const ValueKey<String>('requestTypeEditButton'),
            title: s.edit,
            onTap: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(builder: (_) => RequestTypeFormPage(original: type)),
            ),
          ),
        if (_access.canRemoveRequestType && !removed) ...<Widget>[
          SizedBox(width: 10.w),
          TtDeleteButton(
            key: const ValueKey<String>('requestTypeRemoveButton'),
            title: s.timeTrackerRemove,
            onTap: () => _remove(context),
          ),
        ],
        if (_access.canChangeRequestTypeStatus && removed)
          TtToolbarButton(
            key: const ValueKey<String>('requestTypeRestoreButton'),
            title: s.timeTrackerRestore,
            icon: TtAssets.import,
            onTap: () => _restore(context),
          ),
      ],
    );
  }

  /// A titled card section with an icon.
  Widget _section(String title, String icon, List<Widget> rows) => TtFormCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 28.r,
                  height: 28.r,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: TtIcon(TtGlyph.svg(icon), size: 15.r, color: AppColors.textButton),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(title, style: StyleText.fontSize16Weight500.copyWith(color: AppColors.text)),
                ),
              ],
            ),
            for (final Widget r in rows) ...<Widget>[SizedBox(height: 10.h), r],
          ],
        ),
      );

  /// icon · label ............ coloured value (Required / Optional / Yes).
  Widget _rule(TtGlyph icon, String label, String value, bool on) => Row(
        children: <Widget>[
          TtIcon(icon, size: 16.r, color: AppColors.secondaryText),
          SizedBox(width: 8.w),
          Expanded(child: Text(label, style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text))),
          Container(
            padding: EdgeInsetsDirectional.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: on ? AppColors.blue.withValues(alpha: 0.12) : AppColors.background,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(value,
                style: StyleText.fontSize12Weight500.copyWith(color: on ? AppColors.blue : AppColors.secondaryText)),
          ),
        ],
      );

  /// icon · label / value (the value wraps).
  Widget _info(String icon, String label, String value, {Key? key}) => Row(
        key: key,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsetsDirectional.only(top: 2.h),
            child: TtIcon(TtGlyph.svg(icon), size: 16.r, color: AppColors.secondaryText),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label, style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText)),
                SizedBox(height: 2.h),
                Text(value, style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
              ],
            ),
          ),
        ],
      );
}
