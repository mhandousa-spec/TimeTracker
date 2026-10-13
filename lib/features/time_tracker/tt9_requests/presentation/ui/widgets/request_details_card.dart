/// Module: time_tracker / tt9_requests / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: request_details_card.dart
/// Purpose: Declares `RequestDetailsCard` — the "Request Details" card of
///          the requester's and the approver's details pages: the values,
///          description, attachments, Approval Cycle, reasons and the action
///          buttons (or the status pill).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Figma requester `661:30117` … `661:31900` (every status; `661:30811` with
/// the Approval Cycle Manager → HR and "Reasons of Cancellation") and
/// approver `661:85595` / `661:85326` / `661:85064` (Requested by + Job
/// Title + Department; Reject / Approve; Cancel on an approved request).
/// Buttons by role and switch:
///   * requester — Cancel (pending: `Cancel_Time_Tracker_Request`, a
///     transaction `Cancel_Transaction`; approved leave: asks to cancel) and
///     Send Reminder (pending, `Send_Request_Reminder`);
///   * approver — Reject / Approve when the current step is theirs
///     (`Approve_And_Reject` + scope); Cancel on an approved request
///     (`Cancel_Request_After_Approving`).
/// With no button the status pill is shown. Attachments open in the
/// browser / viewer (url_launcher). Cycle avatars are ringed green
/// (approved), red (rejected) or orange (waiting).
/// Updated: 9/10/2026 - code review: Material icons → the app's SVG line
/// icons (`TtAssets` / `TtGlyph`) where an equivalent asset exists.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:knowticed_plus/core/custom/22-custom_uploaded_document_card.dart';
import 'package:knowticed_plus/core/custom/42-custom_approval_cycle.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/approval_step.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_cycle_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/request_actions_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/requests_state.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_formatters.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/features/time_tracker/tt9_requests/presentation/ui/widgets/request_card.dart';
import 'package:knowticed_plus/features/time_tracker/tt9_requests/presentation/ui/widgets/request_flows.dart';
import 'package:knowticed_plus/features/time_tracker/tt9_requests/presentation/ui/widgets/request_text.dart';
import 'package:knowticed_plus/features/time_tracker/tt9_requests/presentation/ui/widgets/request_widgets.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';

class RequestDetailsCard extends StatelessWidget {
  const RequestDetailsCard({
    super.key,
    required this.request,
    required this.state,
    required this.asApprover,
  });

  final TimeTrackerRequest request;
  final RequestsState state;
  final bool asApprover;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final String description = request.description.trim();
    return TtFormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _header(context),
          if (description.isNotEmpty) ...<Widget>[
            SizedBox(height: 12.h),
            Text('${s.timeTrackerDescription}:',
                style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText)),
            SizedBox(height: 4.h),
            Text(description, style: StyleText.fontSize12Weight400.copyWith(color: AppColors.text)),
          ],
          if (request.attachments.isNotEmpty) ...<Widget>[
            SizedBox(height: 12.h),
            _attachments(context),
          ],
          ..._cycle(context),
          ..._reasons(context),
          SizedBox(height: 15.h),
          Align(alignment: AlignmentDirectional.centerEnd, child: _actions(context)),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    final S s = S.of(context);
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    final TimeTrackerEmployee? who = state.employeeOf(request.requesterEmail);
    // 9/10/2026 (UI pass): app language + proper case (KP-TT-017).
    final String department = (who?.department(isArabic: ar) ?? '').isNotEmpty
        ? who!.department(isArabic: ar)
        : state.departments[request.requesterDepartmentId] ?? '';
    final List<Widget> person = <Widget>[
      RequestInfoLine(
        icon: const TtGlyph.svg(TtAssets.person),
        label: s.timeTrackerRequestedBy,
        child: Row(
          children: <Widget>[
            TimeTrackerAvatar(photo: who?.photo ?? '', size: 22.r),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(who?.name(isArabic: ar) ?? request.requesterEmail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text)),
            ),
          ],
        ),
      ),
      RequestInfoLine(
        icon: const TtGlyph.icon(Icons.work_outline),
        label: s.timeTrackerJobTitle,
        value: _orDash(who?.jobTitle(isArabic: ar) ?? ''),
      ),
      RequestInfoLine(
        icon: const TtGlyph.svg(TtAssets.department),
        label: s.timeTrackerDepartment,
        value: _orDash(department),
      ),
    ];
    final List<Widget> details = <Widget>[
      RequestInfoLine(
        icon: const TtGlyph.svg(TtAssets.edit),
        label: request.isTransaction ? s.timeTrackerRequestWord : s.timeTrackerRequestType,
        value: RequestText.typeName(context, request, state),
      ),
      RequestInfoLine(
        icon: const TtGlyph.svg(TtAssets.calendar),
        label: s.timeTrackerDateRequested,
        value: RequestText.requestDate(context, request),
      ),
      ...RequestCardLines.timeLines(context, request),
    ];
    final Widget info = asApprover && !context.isPhone
        ? TtPair(
            start: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: person),
            end: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: details),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[if (asApprover) ...person, ...details],
          );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (!context.isPhone) ...<Widget>[RequestIconBox(size: 90.r), SizedBox(width: 12.w)],
        Expanded(child: info),
      ],
    );
  }

  static String _orDash(String v) => v.trim().isEmpty ? TimeTrackerFormat.dash : v.trim();

  Widget _attachments(BuildContext context) {
    final S s = S.of(context);
    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: <Widget>[
        for (final RequestAttachment a in request.attachments)
          ProductWarrantyCard(
            title: '',
            width: context.isPhone ? double.infinity : 300.w,
            fileName: a.name,
            fileSize: TimeTrackerFormat.fileSize(context, a.sizeBytes),
            date: s.timeTrackerUploadedOn(TimeTrackerFormat.date(context, a.uploadedAt ?? request.startAt)),
            onTapFile: () {
              final Uri? uri = Uri.tryParse(a.url);
              if (uri == null) return;
              unawaited(launchUrl(uri, mode: LaunchMode.externalApplication).catchError((Object _) => false));
            },
          ),
      ],
    );
  }

  List<Widget> _cycle(BuildContext context) {
    final S s = S.of(context);
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    final List<RequestApprovalStep> steps = RequestCycleRules.visibleSteps(request);
    if (steps.isEmpty) return const <Widget>[];
    Color ring(ApprovalDecision d) => d == ApprovalDecision.approved
        ? AppColors.lightGreen
        : (d == ApprovalDecision.rejected ? AppColors.red : AppColors.orange);
    return <Widget>[
      SizedBox(height: 15.h),
      Text('${s.timeTrackerApprovalCycle}:',
          style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText)),
      SizedBox(height: 8.h),
      CustomApprovalCycle(
        key: const ValueKey<String>('requestApprovalCycle'),
        steps: <ApprovalStep>[
          for (final RequestApprovalStep st in steps)
            ApprovalStep(
              name: st.approverEmail.isEmpty
                  ? s.timeTrackerHrStep
                  : (state.employeeOf(st.approverEmail)?.name(isArabic: ar) ?? st.approverEmail),
              title: s.timeTrackerStepDecision(RequestText.stepRole(context, st), RequestText.stepDecision(context, st)),
              avatar: Container(
                padding: EdgeInsetsDirectional.all(2.r),
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ring(st.decision), width: 2)),
                child: TimeTrackerAvatar(photo: state.employeeOf(st.approverEmail)?.photo ?? '', size: 32.r),
              ),
            ),
        ],
      ),
    ];
  }

  List<Widget> _reasons(BuildContext context) {
    final S s = S.of(context);
    String rejection = '';
    for (final RequestApprovalStep st in request.approvalSteps) {
      if (st.decision == ApprovalDecision.rejected && st.reason.trim().isNotEmpty) rejection = st.reason.trim();
    }
    final bool showCancel = request.cancellationReason.trim().isNotEmpty &&
        (request.status == RequestStatus.canceled ||
            request.status == RequestStatus.canceledByHr ||
            request.status == RequestStatus.underReview);
    Widget line(String label, String value, Key key) => Padding(
          key: key,
          padding: EdgeInsetsDirectional.only(top: 12.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TtIcon(const TtGlyph.svg(TtAssets.status), size: 16.r, color: AppColors.red),
              SizedBox(width: 6.w),
              Text('$label: ', style: StyleText.fontSize12Weight500.copyWith(color: AppColors.red)),
              Expanded(child: Text(value, style: StyleText.fontSize12Weight400.copyWith(color: AppColors.text))),
            ],
          ),
        );
    return <Widget>[
      if (request.status == RequestStatus.rejected && rejection.isNotEmpty)
        line(s.timeTrackerReasonsOfRejection, rejection, const ValueKey<String>('requestRejectionReason')),
      if (showCancel)
        line(s.timeTrackerReasonsOfCancellation, request.cancellationReason.trim(),
            const ValueKey<String>('requestCancellationReason')),
    ];
  }

  /// 13/10/2026 (owner Q1 / Q2 / I2 / H3): one row of equal buttons
  /// (`RequestActionRow`); while a reminder cannot go yet, the countdown
  /// sits under the row instead of the Send Reminder button.
  Widget _actions(BuildContext context) {
    final List<Widget> buttons = asApprover ? _approverButtons(context) : _requesterButtons(context);
    final Duration? wait = asApprover || !_mayRemind ? null : RequestReminderCountdown.leftFor(request.lastReminderAt);
    final Widget? note = wait == null
        ? null
        : Align(
            alignment: context.isPhone ? Alignment.center : AlignmentDirectional.centerEnd,
            child: RequestReminderCountdown(key: const ValueKey<String>('requestReminderCountdown'), left: wait),
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (buttons.isEmpty) RequestStatusPill(status: request.status) else RequestActionRow(children: buttons),
        if (note != null) ...<Widget>[SizedBox(height: 10.h), note],
      ],
    );
  }

  /// Send Reminder applies: the switch, a pending request, the requester.
  bool get _mayRemind {
    final TimeTrackerAccess access = GetIt.instance<TimeTrackerAccess>();
    return access.canSendRequestReminder &&
        request.status == RequestStatus.pending &&
        RequestCycleRules.isRequester(request, access.currentUserEmail);
  }

  List<Widget> _requesterButtons(BuildContext context) {
    final S s = S.of(context);
    final TimeTrackerAccess access = GetIt.instance<TimeTrackerAccess>();
    final String me = access.currentUserEmail;
    final bool cancelSwitch = request.isTransaction ? access.canCancelTransaction : access.canCancelRequest;
    final bool canCancel = cancelSwitch &&
        (RequestCycleRules.canCancelPending(request, me) || RequestCycleRules.canRequestCancellation(request, me));
    final bool canRemind = _mayRemind && RequestReminderCountdown.leftFor(request.lastReminderAt) == null;
    return <Widget>[
      if (canCancel)
        KeyedSubtree(
          key: const ValueKey<String>('requestCancelButton'),
          child: RequestOutlinedButton(
            // 13/10/2026 (owner Q1): "Cancel Request", not a bare "Cancel".
            label: s.timeTrackerCancelRequest,
            icon: const TtGlyph.svg(TtAssets.btnCancel, tinted: false),
            color: AppColors.red,
            fillColor: AppColors.red,
            high: true,
            onTap: () => RequestFlows.cancel(context, request),
          ),
        ),
      if (canRemind)
        KeyedSubtree(
          key: const ValueKey<String>('requestReminderButton'),
          child: RequestOutlinedButton(
            label: s.timeTrackerSendRequestReminder,
            icon: const TtGlyph.svg(TtAssets.reminder),
            color: AppColors.primary,
            filled: true,
            onTap: () => RequestFlows.sendReminder(context, request),
          ),
        ),
    ];
  }

  List<Widget> _approverButtons(BuildContext context) {
    final S s = S.of(context);
    final RequestActionsCubit actions = context.read<RequestActionsCubit>();
    return <Widget>[
      if (actions.mayDecide(request)) ...<Widget>[
        KeyedSubtree(
          key: const ValueKey<String>('approvalRejectButton'),
          child: RequestOutlinedButton(
            label: s.reject,
            icon: const TtGlyph.svg(TtAssets.btnReject, tinted: false),
            color: AppColors.red,
            high: true,
            onTap: () => RequestFlows.reject(context, request),
          ),
        ),
        KeyedSubtree(
          key: const ValueKey<String>('approvalApproveButton'),
          child: RequestOutlinedButton(
            label: s.approve,
            icon: const TtGlyph.svg(TtAssets.btnApprove, tinted: false),
            color: AppColors.lightGreen,
            onTap: () => RequestFlows.approve(context, request),
          ),
        ),
      ],
      if (actions.mayCancelAfterApproving(request))
        KeyedSubtree(
          key: const ValueKey<String>('approvalCancelButton'),
          child: RequestOutlinedButton(
            label: s.cancel,
            icon: const TtGlyph.svg(TtAssets.btnCancel, tinted: false),
            color: AppColors.red,
            fillColor: AppColors.red,
            high: true,
            onTap: () => RequestFlows.cancelAfterApproving(context, request),
          ),
        ),
    ];
  }
}
