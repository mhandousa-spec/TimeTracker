/// Module: GRC Request Management
/// Description: Details view for a single GRC Request. For
///              GrcRequestType.reassignChampion / reassignOwner, shows
///              Current vs New Champion/Owner, dates, note, and assigned
///              controls, with Approve/Reject actions while pending. Any
///              other request type renders a "not supported" placeholder.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-25
/// Dependencies: flutter_bloc, GrcRequestCubit, custom_confirm_dialog
library;

import 'package:knowticed_plus/features/grc/shared/helpers/grc_permissions.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/3-custom_dropdown_calander.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/assigning_control.dart';
import 'package:knowticed_plus/features/grc/control_champion/presentation/controller/champion_cubit.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_assignment_chip.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_person_profile_card.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_responsive_field_row.dart';
import 'package:get_it/get_it.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/11-custom_confirm_diaolog.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/domain/enums/approval_status.dart';
import 'package:knowticed_plus/core/custom/84-messaging_custom_button.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/entities/grc_request_entity.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/entities/grc_request_type.dart';
import 'package:knowticed_plus/features/grc/grc_request/presentation/controller/grc_request_cubit.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_request_status_pill.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_l10n.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';


class GrcRequestDetailsPage extends StatelessWidget {
  final GRCModuleEntity module;
  final GrcRequestEntity request;
  final bool isMyRequest;

  const GrcRequestDetailsPage({
    super.key,
    required this.module,
    required this.request,
    required this.isMyRequest,
  });

  @override
  Widget build(BuildContext context) {
    // GrcRequestCubit is provided by the caller (grc_requests_list_page.dart
    // wraps this page's route in BlocProvider.value using its own instance)
    // so the details page and list page share one Cubit and stay in sync
    // without a manual re-fetch. Only read/watch it here, don't resolve a
    // fresh one from GetIt.
    return _GrcRequestDetailsBody(
      module: module,
      request: request,
      isMyRequest: isMyRequest,
    );
  }
}

class _GrcRequestDetailsBody extends StatefulWidget {
  final GRCModuleEntity module;
  final GrcRequestEntity request;
  final bool isMyRequest;

  const _GrcRequestDetailsBody({
    required this.module,
    required this.request,
    required this.isMyRequest,
  });

  @override
  State<_GrcRequestDetailsBody> createState() => _GrcRequestDetailsBodyState();
}

class _GrcRequestDetailsBodyState extends State<_GrcRequestDetailsBody> {
  late GrcRequestEntity _request;
  final Map<String, List<ControlEntity>> _policyControls = {};
  bool _isLoadingControls = true;

  /// What the current champion / owner holds right now -- the "Assigned
  /// Controls" of the Current card, and the "Old Assigned Controls" when a
  /// request only changes one person's controls.
  List<AssigningControlEntity> _currentControls = const [];

  @override
  void initState() {
    super.initState();
    _request = widget.request;
    _loadPolicyData();
    _loadCurrentAssigneeControls();
  }

  Future<void> _loadCurrentAssigneeControls() async {
    final ChampionCubit cubit = GetIt.instance<ChampionCubit>();
    final String email = _currentAssigneeEmail;
    List<AssigningControlEntity> found = const [];
    if (_isOwnerRequest) {
      final result =
          await cubit.getAllOwners(moduleId: widget.module.moduleId);
      result.fold((_) {}, (owners) {
        for (final o in owners) {
          if (o.ownerEmail == email) found = o.assigningControls;
        }
      });
    } else {
      final result =
          await cubit.getAllChampionsRaw(moduleId: widget.module.moduleId);
      result.fold((_) {}, (champions) {
        for (final c in champions) {
          if (c.championEmail == email) found = c.assigningControls;
        }
      });
    }
    await cubit.close();
    if (mounted) setState(() => _currentControls = found);
  }

  Future<void> _loadPolicyData() async {
    final grcRequestCubit = context.read<GrcRequestCubit>();
    final polResult =
        await grcRequestCubit.getAllPolicies(moduleId: widget.module.moduleId);
    await polResult.fold(
      (failure) async {},
      (policies) async {
        for (final policy in policies) {
          final ctrlResult = await grcRequestCubit.getAllControlsForPolicy(
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
    if (mounted) setState(() => _isLoadingControls = false);
  }

  ControlEntity? _getControlEntity(String policyId, String controlId) {
    final list = _policyControls[policyId];
    if (list != null) {
      for (final c in list) {
        if (c.id == controlId) return c;
      }
    }
    return null;
  }

  bool get _isOwnerRequest => _request.type == GrcRequestType.reassignOwner;

  String get _currentAssigneeEmail => _isOwnerRequest
      ? (_request.currentOwnerEmail ?? '')
      : (_request.currentChampionEmail ?? '');

  String get _newAssigneeEmail => _isOwnerRequest
      ? (_request.newOwnerEmail ?? '')
      : (_request.newChampionEmail ?? '');

  String get _currentAssigneeLabel => _isOwnerRequest
      ? S.of(context).currentControlOwner
      : S.of(context).currentControlChampion;

  String get _newAssigneeLabel =>
      _isOwnerRequest ? S.of(context).newControlOwner : S.of(context).newControlChampion;

  /// Read-only chips for [controls] (grey, inside the white card).
  Widget _controlsChips(
      BuildContext context, List<AssigningControlEntity> controls) {
    if (_isLoadingControls) {
      return Center(
        child: const CircleProgressMaster(),
      );
    }
    if (controls.isEmpty) {
      return Text(
        S.of(context).noControlsAssigned,
        style: StyleText.fontSize12Weight400
            .copyWith(color: AppColors.secondaryText),
      );
    }
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: [
        for (final c in controls)
          GrcAssignmentChip(
            label: () {
              final ctrl = _getControlEntity(c.policyId, c.controlId);
              if (ctrl == null) return c.controlId;
              return context.isArabic
                  ? ctrl.controlsNameAr
                  : ctrl.controlsNameEn;
            }(),
            backgroundColor: AppColors.background,
          ),
      ],
    );
  }

  List<Widget> _controlsBlock(BuildContext context, String title,
      List<AssigningControlEntity> controls) {
    return [
      SizedBox(height: 15.h),
      Text(
        title,
        style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
      ),
      SizedBox(height: 8.h),
      _controlsChips(context, controls),
    ];
  }

  /// Mirrors GrcRequestsListPage's own `_canCancel` rule exactly: only the
  /// requester, only while pending, and only before the request's start
  /// date has arrived.
  bool get _canCancel =>
      // Cancel_Service (GRC > Dashboards) gates cancelling a request.
      GrcPermission.canCancelService &&
      widget.isMyRequest &&
      _request.status == ApprovalStatus.pending &&
      _request.startDate != null &&
      _request.startDate!.isAfter(DateTime.now());

  void _onCancel(BuildContext context) {
    showConfirmDialog(
      context: context,
      title: S.of(context).CancelRequest,
      subtitle: S.of(context).AreYousureYouWanttoCancelThisRequest,
      cancelLabel: S.of(context).no,
      confirmLabel: S.of(context).yes,
      onConfirm: () {
        context.read<GrcRequestCubit>().cancelRequest(
              moduleId: widget.module.moduleId,
              requestId: _request.id,
            );
      },
    );
  }

  Widget _cancelButton(BuildContext context) {
    return CustomButton(
      width: 100.w,
      horizontalPadding: 10,
      verticalPadding: 6,
      onTap: () => _onCancel(context),
      buttonText: S.of(context).Cancel,
    );
  }

  void _onApprove() {
    showConfirmDialog(
      context: context,
      title: S.of(context).ApproveRequest,
      subtitle: S.of(context).AreYouSureYouWantToApproveThisRequest,
      onConfirm: () {
        context.read<GrcRequestCubit>().approveRequest(
              moduleId: widget.module.moduleId,
              requestId: _request.id,
            );
      },
    );
  }

  void _onReject() {
    showCommentDialog(
      context: context,
      title: S.of(context).ReasonOfRejection,
      fieldLabel: S.of(context).Justifications,
      onSubmit: (reason) {
        context.read<GrcRequestCubit>().rejectRequest(
              moduleId: widget.module.moduleId,
              requestId: _request.id,
              reason: reason,
            );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GrcRequestCubit, GrcRequestState>(
      listener: (context, state) {
        if (state is GrcRequestActionSuccess &&
            state.request.id == _request.id) {
          setState(() => _request = state.request);
        } else if (state is GrcRequestFailure) {
          CustomDialogManager.showMessage(
            context: context,
            lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
            title: S.of(context).unsuccessful,
            subtitle: '${S.of(context).actionFailed} ${state.message}',
          );
        }
      },
      builder: (context, state) => _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final isSupportedRequestType = _request.type.isReassignment;
    if (!isSupportedRequestType) {
      return _buildUnsupportedRequestTypeScaffold(context);
    }
    return _buildReassignmentScaffold(context);
  }

  /// Placeholder shown for any [GrcRequestType] other than the two
  /// reassignment types this page renders full details for.
  Widget _buildUnsupportedRequestTypeScaffold(BuildContext context) {
    return SideFrameMasterServices(
      titleText: S.of(context).grc,
      onFirstTap: () => popFrameRoutes(context, 3),
      secondTitle: widget.module.localizedName(isArabic: context.isArabic),
      onSecondTap: () => popFrameRoutes(context, 2),
      thirdTitle: S.of(context).requests,
      onThirdTap: () => popFrameRoutes(context, 1),
      fourthTitle: S.of(context).requestDetails,
      child: Padding(
        padding: EdgeInsets.only(top: 40.h),
        child: Center(
          child: Text(S.of(context).thisRequestTypeIsNotSupportedYet),
        ),
      ),
    );
  }

  /// Main scaffold for reassignChampion / reassignOwner requests. MAGDY
  /// draws three shapes:
  ///   * Current + New person, both with controls (a real reassignment);
  ///   * Current + New person without controls;
  ///   * one person whose controls change ("Old / New Assigned Controls")
  ///     -- when the request's current and new person are the same.
  Widget _buildReassignmentScaffold(BuildContext context) {
    final bool isMobile = screenSizeOf(context) == ScreenSize.mobile;
    final bool samePerson = _currentAssigneeEmail == _newAssigneeEmail;
    final TextStyle sectionTitle =
        StyleText.fontSize16Weight400.copyWith(color: AppColors.text);
    final Widget actions = _buildActionOrStatusSection(context, isMobile);

    return SideFrameMasterServices(
      // The frame owns the Scaffold, SafeArea, breadcrumb and side padding.
      // GRC > Module > Requests > Details: three routes back to GRC.
      titleText: S.of(context).grc,
      onFirstTap: () => popFrameRoutes(context, 3),
      secondTitle: widget.module.localizedName(isArabic: context.isArabic),
      onSecondTap: () => popFrameRoutes(context, 2),
      thirdTitle: widget.isMyRequest
          ? S.of(context).myRequests
          : S.of(context).requests,
      onThirdTap: () => popFrameRoutes(context, 1),
      fourthTitle: S.of(context).requestsDetails,
      child: SideFrameScrollableBody(
        child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_canCancel)
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: _cancelButton(context),
                        ),
                      if (samePerson) ...[
                        Text(
                          _isOwnerRequest
                              ? S.of(context).controlOwner
                              : S.of(context).controlChampion,
                          style: sectionTitle,
                        ),
                        SizedBox(height: 8.h),
                        GrcPersonProfileCard(
                          email: _newAssigneeEmail,
                          children: [
                            ..._datesAndNote(context, isMobile),
                            ..._controlsBlock(
                              context,
                              S.of(context).oldAssignedControls,
                              _currentControls,
                            ),
                            ..._controlsBlock(
                              context,
                              S.of(context).newAssignedControls,
                              _request.controls ?? const [],
                            ),
                            if (isMobile) ...[SizedBox(height: 20.h), actions],
                          ],
                        ),
                      ] else ...[
                        Text(_currentAssigneeLabel, style: sectionTitle),
                        SizedBox(height: 8.h),
                        GrcPersonProfileCard(
                          email: _currentAssigneeEmail,
                          children: [
                            if (_currentControls.isNotEmpty)
                              ..._controlsBlock(
                                context,
                                S.of(context).assignedControls,
                                _currentControls,
                              ).skip(1),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        Text(_newAssigneeLabel, style: sectionTitle),
                        SizedBox(height: 8.h),
                        GrcPersonProfileCard(
                          email: _newAssigneeEmail,
                          children: [
                            ..._datesAndNote(context, isMobile).skip(1),
                            if ((_request.controls ?? const []).isNotEmpty)
                              ..._controlsBlock(
                                context,
                                isMobile
                                    ? S.of(context).newAssignedControls
                                    : S.of(context).assignedControls,
                                _request.controls!,
                              ),
                            if (isMobile) ...[SizedBox(height: 20.h), actions],
                          ],
                        ),
                      ],
                      if (!isMobile) ...[SizedBox(height: 15.h), actions],
                      SizedBox(height: 24.h),
                    ],
                  ),
      ),
    );
  }

  /// Start / End dates (side by side at 768 / 1024, stacked at 375) and
  /// the request note, all read-only. The first entry is a spacer so a
  /// caller that already has one can `.skip(1)`.
  List<Widget> _datesAndNote(BuildContext context, bool isMobile) {
    final DateFormat dateFormat =
        DateFormat('d MMM yyyy', context.isArabic ? 'ar' : 'en');
    String format(DateTime d) =>
        LocalizedNumber.digits(context, dateFormat.format(d));

    return [
      SizedBox(height: 15.h),
      IgnorePointer(
        child: GrcResponsiveFieldRow(
          isTablet: !isMobile,
          children: [
            CustomDropdownCalendar(
              label: S.of(context).startDate,
              hint: S.of(context).chooseTheDate,
              value: _request.startDate,
              fillColor: AppColors.background,
              dateFormatter: format,
            ),
            // FIXED 28/9/2026 (GRC bug report p9): a request made without an
            // end date showed an empty "Choose the date" field here. Hide it;
            // on 768 / 1024 an empty slot keeps Start Date at half width.
            if (_request.endDate != null)
              CustomDropdownCalendar(
                label: S.of(context).endDate,
                hint: S.of(context).chooseTheDate,
                value: _request.endDate,
                fillColor: AppColors.background,
                dateFormatter: format,
              )
            else if (!isMobile)
              const SizedBox.shrink(),
          ],
        ),
      ),
      // FIXED 28/9/2026 (GRC bug report p9): a reassignment made without a
      // request has no note — hide the whole Request Note block rather than
      // show an empty "Text here" box and a 0/500 counter.
      if (_request.note.trim().isNotEmpty) ...[
      SizedBox(height: 15.h),
      Text(
        isMobile ? S.of(context).reasonForRequest : S.of(context).request_note,
        style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
      ),
      SizedBox(height: 6.h),
      Container(
        width: double.infinity,
        // Same height as the 4-line Request Note field on the reassign form
        // (GRC bug report p9 "height") — it used to be a one-line 56.h box.
        constraints: BoxConstraints(minHeight: 100.h),
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          _request.note.isNotEmpty ? _request.note : S.of(context).Texthere,
          style: StyleText.fontSize12Weight400.copyWith(
            color: _request.note.isNotEmpty
                ? AppColors.text
                : AppColors.secondaryText,
          ),
        ),
      ),
      SizedBox(height: 4.h),
      Align(
        alignment: AlignmentDirectional.centerEnd,
        child: Text(
          '${LocalizedNumber.of(context, _request.note.length)}/'
          '${LocalizedNumber.of(context, 500)}',
          style: StyleText.fontSize10Weight400
              .copyWith(color: AppColors.secondaryText),
        ),
      ),
      ],
    ];
  }

  /// Approve / Reject for an approver on a pending request -- filled and
  /// trailing at 768 / 1024, outlined and half-width inside the card at 375.
  /// Anyone else sees the read-only status banner.
  Widget _buildActionOrStatusSection(BuildContext context, bool isMobile) {
    if (_request.status == ApprovalStatus.pending && !widget.isMyRequest) {
      const String rejectSvg =
          'assets/icons_assets/main_icons_assets/status_blocked_circle_red.svg';
      const String approveSvg =
          'assets/icons_assets/main_icons_assets/status_approved_check_green.svg';

      Widget button({
        required String title,
        required VoidCallback onTap,
        required Color color,
        required String svg,
      }) {
        return customButtonWithSvg(
          title: title,
          function: onTap,
          textStyle: StyleText.fontSize16Weight400
              .copyWith(color: isMobile ? color : color),
          color: AppColors.transparent,
          colorBorder: color,
          image: svg,
          widthImage: 22.sp,
          heightImage: 22.sp,
          space: 8.w,
          fixedWidth: isMobile ? null : 150.w,
        );
      }

      final Widget reject = button(
        title: S.of(context).Reject,
        onTap: _onReject,
        color: AppColors.red,
        svg: rejectSvg,
      );
      final Widget approve = button(
        title: S.of(context).Approve,
        onTap: _onApprove,
        color: AppColors.green,
        svg: approveSvg,
      );

      if (isMobile) {
        return Row(
          children: [
            Expanded(child: SizedBox(width: double.infinity, child: reject)),
            SizedBox(width: 12.w),
            Expanded(child: SizedBox(width: double.infinity, child: approve)),
          ],
        );
      }
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [reject, SizedBox(width: 8.w), approve],
      );
    }
    return _statusSection(_request.status);
  }

  /// Read-only status, drawn with the same outlined pill as the Requests
  /// list cards ([GrcRequestStatusPill]). A rejected request also shows the
  /// stored rejection reason above the pill.
  Widget _statusSection(ApprovalStatus status) {
    final String reason = _request.rejectionReason?.trim() ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (status == ApprovalStatus.rejected && reason.isNotEmpty) ...[
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${S.of(context).reasonsOfRejectionTitle}: ',
                  style: StyleText.fontSize14Weight500
                      .copyWith(color: AppColors.red),
                ),
                TextSpan(
                  text: reason,
                  style: StyleText.fontSize14Weight400
                      .copyWith(color: AppColors.text),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
        ],
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: GrcRequestStatusPill(status: status, large: true),
        ),
      ],
    );
  }
}
