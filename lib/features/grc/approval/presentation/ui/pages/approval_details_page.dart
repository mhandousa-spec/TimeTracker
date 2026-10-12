/// Module: GRC / Approvals (Department Manager)
///
///*************************** FILE INFO ****************************///
/// File Name: approval_details_page.dart
/// Purpose: "Request Details" for one approval (MAGDY →
///          "MAIN PAGE : Approvals"): Policy Details, Control Details, and
///          the Approvals | Inquires section with the Reject / Approve flow.
/// Author: Mohamed Magdy Abdelkhalek
/// Updated: 16/9/2026 - Responsive rebuild for 375 / 768 / 1024.
///          * Wears SideFrameMasterServices like the rest of GRC: breadcrumb
///            "GRC > Module > Approvals > Control Name" on tablet / desktop,
///            "Request Details" with a back chevron on a phone.
///          * Every section is drawn per width (approval_details_sections).
///          * Inquires is the real comment thread (UniversalCommentSection)
///            instead of the "coming soon" placeholder.
///          * Dialog flow follows the design:
///              Reject  → "Reject Document" confirm (red icon)
///                      → "Reason Of Rejection" (Justifications, 0/500)
///                      → "Successful — You Successfully Rejected …"
///              Approve → "Approve Request" confirm (green icon)
///                      → "Successful — You Successfully Approved …"
///            and the page closes once the success dialog is dismissed
///            (the old code popped the success dialog itself, straight away).
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:knowticed_plus/core/custom/11-custom_confirm_diaolog.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/grc/approval/domain/entities/approval_item.dart';
import 'package:knowticed_plus/features/grc/approval/domain/entities/approval_status.dart';
import 'package:knowticed_plus/features/grc/approval/presentation/controller/approval_cubit.dart';
import 'package:knowticed_plus/features/grc/approval/presentation/ui/widgets/approval_details_sections.dart';
import 'package:knowticed_plus/features/grc/assignment_control/presentation/controller/submission_history_cubit.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Which decision the manager last confirmed, so the success dialog can say
/// "approved" or "rejected".
enum _ApprovalDecision { approve, reject }

class ApprovalDetailsPage extends StatefulWidget {
  final ApprovalItem item;
  final GRCModuleEntity module;

  const ApprovalDetailsPage({
    super.key,
    required this.item,
    required this.module,
  });

  @override
  State<ApprovalDetailsPage> createState() => _ApprovalDetailsPageState();
}

class _ApprovalDetailsPageState extends State<ApprovalDetailsPage> {
  int _approvalsTab = 0; // 0 = Approvals, 1 = Inquires
  _ApprovalDecision? _decision;
  late final SubmissionHistoryCubit _historyCubit;

  @override
  void initState() {
    super.initState();
    _historyCubit = GetIt.instance<SubmissionHistoryCubit>();
    _historyCubit.loadHistory(
      moduleId: widget.module.moduleId,
      controlId: widget.item.control.id,
      championEmail: widget.item.assignmentControl.controlChampionEmail,
    );
  }

  @override
  void dispose() {
    _historyCubit.close();
    super.dispose();
  }

  Widget _dialogIcon(String asset) => CustomSvgImage(
        assetPath: asset,
        width: 50.sp,
        height: 50.sp,
      );

  void _onApprovePressed(BuildContext context) {
    final ApprovalCubit cubit = context.read<ApprovalCubit>();
    final S s = S.of(context);
    showConfirmDialog(
      context: context,
      title: s.ApproveRequest,
      subtitle: s.AreYouSureYouWantToApproveThisRequest,
      confirmLabel: s.yes,
      cancelLabel: s.no,
      iconWidget: _dialogIcon(ApprovalAssets.approve),
      onConfirm: () {
        _decision = _ApprovalDecision.approve;
        cubit.approve(
          moduleId: widget.module.moduleId,
          controlId: widget.item.control.id,
          championEmail: widget.item.assignmentControl.controlChampionEmail,
          managerEmail: currentGrcUserEmail(),
        );
      },
    );
  }

  void _onRejectPressed(BuildContext context) {
    final ApprovalCubit cubit = context.read<ApprovalCubit>();
    final S s = S.of(context);
    showConfirmDialog(
      context: context,
      title: s.rejectDocument,
      subtitle: s.areYouSureYouWantToRejectThisDocument,
      confirmLabel: s.yes,
      cancelLabel: s.no,
      iconWidget: _dialogIcon(ApprovalAssets.reject),
      onConfirm: () => showCommentDialog(
        context: context,
        title: s.ReasonOfRejection,
        fieldLabel: s.Justifications,
        hint: s.Texthere,
        submitLabel: s.submit,
        textDirection:
            context.isArabic ? TextDirection.rtl : TextDirection.ltr,
        titleIconAsset: ApprovalAssets.rejectionTitle,
        onSubmit: (reason) {
          _decision = _ApprovalDecision.reject;
          cubit.reject(
            moduleId: widget.module.moduleId,
            controlId: widget.item.control.id,
            championEmail: widget.item.assignmentControl.controlChampionEmail,
            managerEmail: currentGrcUserEmail(),
            reason: reason,
          );
        },
      ),
    );
  }

  Future<void> _onDecisionSaved(BuildContext context) async {
    final S s = S.of(context);
    final ApprovalCubit cubit = context.read<ApprovalCubit>();
    final bool rejected = _decision == _ApprovalDecision.reject;
    _decision = null;
    // Refresh the list underneath so it shows the new status on return.
    cubit.getMyApprovals(
      moduleId: widget.module.moduleId,
      managerEmail: currentGrcUserEmail(),
    );
    await showSuccessDialog(
      context: context,
      title: s.successful,
      subtitle: rejected
          ? s.YouSuccessfullyRejectedThisRequest
          : s.YouSuccessfullyApprovedThisRequest,
    );
    if (mounted) Navigator.of(this.context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = context.isArabic;
    final bool isMobile = screenSizeOf(context) == ScreenSize.mobile;
    final control = widget.item.control;
    final String controlName =
        isArabic ? control.controlsNameAr : control.controlsNameEn;
    final String? moduleOwnerEmail = widget.module.moduleOwners.isNotEmpty
        ? widget.module.moduleOwners.first
        : null;

    return BlocListener<ApprovalCubit, ApprovalState>(
      listenWhen: (_, current) =>
          current is ApprovalActionSuccess ||
          (current is ApprovalFailure && _decision != null),
      listener: (context, state) {
        if (state is ApprovalActionSuccess) {
          _onDecisionSaved(context);
        } else if (state is ApprovalFailure) {
          _decision = null;
          CustomDialogManager.showMessage(
            context: context,
            lottiePath: 'assets/lottie_assets/main_lottie_assets/error.json',
            title: S.of(context).unsuccessful,
            subtitle: state.message,
          );
        }
      },
      // The frame owns the Scaffold, SafeArea, breadcrumb and side padding.
      child: SideFrameMasterServices(
        titleText: S.of(context).grc,
        onFirstTap: () => popFrameRoutes(context, 3),
        secondTitle: widget.module.localizedName(isArabic: isArabic),
        onSecondTap: () => popFrameRoutes(context, 2),
        thirdTitle: S.of(context).approvals,
        onThirdTap: () => popFrameRoutes(context, 1),
        // The phone design titles this screen "Request Details"; wider
        // screens show the control's name as the last crumb.
        fourthTitle: isMobile ? S.of(context).requestDetails : controlName,
        child: SideFrameScrollableBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ApprovalSectionTitle(S.of(context).policyDetails),
              SizedBox(height: 8.h),
              ApprovalPolicyDetailsCard(
                item: widget.item,
                moduleOwnerEmail: moduleOwnerEmail,
                isArabic: isArabic,
              ),
              SizedBox(height: 15.h),
              ApprovalSectionTitle(S.of(context).controlDetails),
              SizedBox(height: 8.h),
              ApprovalControlDetailsCard(
                item: widget.item,
                isArabic: isArabic,
              ),
              SizedBox(height: 20.h),
              ApprovalSectionHeader(
                selected: _approvalsTab,
                onChanged: (i) => setState(() => _approvalsTab = i),
              ),
              SizedBox(height: 8.h),
              if (_approvalsTab == 1)
                ApprovalInquiriesCard(
                  moduleId: widget.module.moduleId,
                  approvalId: widget.item.approval.requestId,
                )
              else
                _buildSubmissions(isArabic),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmissions(bool isArabic) {
    final bool isPending =
        widget.item.approval.status == ApprovalStatus.pending;
    final String championEmail =
        widget.item.assignmentControl.controlChampionEmail;

    return BlocBuilder<ApprovalCubit, ApprovalState>(
      buildWhen: (previous, current) =>
          (previous is ApprovalLoading) != (current is ApprovalLoading),
      builder: (context, approvalState) {
        // Only a decision in flight shows the loading placeholder, not the
        // list refresh that follows it.
        final bool isSaving =
            approvalState is ApprovalLoading && _decision != null;
        return BlocBuilder<SubmissionHistoryCubit, SubmissionHistoryState>(
          bloc: _historyCubit,
          builder: (context, historyState) {
            if (historyState is SubmissionHistoryFailure) {
              return Container(
                width: double.infinity,
                padding: EdgeInsets.all(15.sp),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: CardStyles.radius(),
                ),
                child: Text(
                  historyState.message,
                  style: CardStyles.value(12).copyWith(color: AppColors.red),
                ),
              );
            }
            if (historyState is! SubmissionHistoryLoaded) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: const Center(child: CircleProgressMaster()),
              );
            }
            final entries = historyState.entries;
            if (entries.isEmpty) {
              return const CustomEmptyState(size: 160);
            }
            return Column(
              children: [
                for (var i = 0; i < entries.length; i++) ...[
                  if (i > 0) SizedBox(height: 15.h),
                  ApprovalSubmissionCard(
                    entry: entries[i],
                    championEmail: championEmail,
                    // Only the newest submission of a Pending approval can
                    // still be decided.
                    showDecision: i == 0 && isPending,
                    approvalStatus:
                        i == 0 ? widget.item.approval.status : null,
                    isSaving: isSaving,
                    isArabic: isArabic,
                    onReject: () => _onRejectPressed(context),
                    onApprove: () => _onApprovePressed(context),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }
}
