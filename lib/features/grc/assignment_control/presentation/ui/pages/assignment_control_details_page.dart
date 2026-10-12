import 'package:knowticed_plus/features/grc/approval/presentation/ui/widgets/approval_details_sections.dart';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/custom/52-custom_upload_document.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/11-custom_confirm_diaolog.dart'
    hide showUploadDialog;
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/22-custom_uploaded_document_card.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/entities/assignment_control_item.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/entities/assignment_control_status.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/entities/assignment_control_tab.dart';
import 'package:knowticed_plus/features/grc/assignment_control/presentation/controller/assignment_control_cubit.dart';
import 'package:knowticed_plus/features/grc/assignment_control/presentation/controller/submission_history_cubit.dart';
import 'package:knowticed_plus/features/grc/assignment_control/presentation/ui/widgets/assignment_control_card.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_document_launcher.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_contact_inline_row.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_label_value_row.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_score_badge.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_section_card.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_section_sub_tabs.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_status_pill.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_submitter_row.dart';
import 'package:knowticed_plus/core/helper/main_helper/pagination_app_bar.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_l10n.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';

final DateFormat _cardDateFormat = DateFormat('d MMM yyyy');
final DateFormat _cardTimeFormat = DateFormat('h:mm a');

class AssignmentControlDetailsPage extends StatefulWidget {
  final AssignmentControlItem item;
  final GRCModuleEntity module;

  const AssignmentControlDetailsPage({
    super.key,
    required this.item,
    required this.module,
  });

  @override
  State<AssignmentControlDetailsPage> createState() =>
      _AssignmentControlDetailsPageState();
}

class _AssignmentControlDetailsPageState
    extends State<AssignmentControlDetailsPage> {
  int _submissionsTab = 0; // 0 = Submission, 1 = Inquires
  late final SubmissionHistoryCubit _historyCubit;

  @override
  void initState() {
    super.initState();
    _historyCubit = GetIt.instance<SubmissionHistoryCubit>();
    final assignment = widget.item.assignment;
    if (assignment != null) {
      _historyCubit.loadHistory(
        moduleId: widget.module.moduleId,
        controlId: widget.item.control.id,
        championEmail: assignment.controlChampionEmail,
      );
    }
  }

  @override
  void dispose() {
    _historyCubit.close();
    super.dispose();
  }

  bool get _isRejected => widget.item.tab == AssignmentControlTab.rejected;

  String get _actionLabel {
    if (_isRejected) return 'Resubmit Evidence';
    return 'Upload Evidence';
  }

  void _onActionPressed(BuildContext context) {
    showUploadDialog(
      context: context,
      dialogTitle: grcTr(context, _actionLabel),
      titleFieldLabel: S.of(context).submissionNote,
      titleFieldHint: S.of(context).Texthere,
      submitLabel: S.of(context).submit,
      onSubmit: (file, note) => _confirmSubmit(context, file, note),
    );
  }

  void _confirmSubmit(BuildContext context, PlatformFile file, String note) {
    if (file.path == null) {
      CustomDialogManager.showMessage(
        context: context,
        lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
        title: S.of(context).unsuccessful,
        subtitle: S.of(context).couldNotReadTheSelectedFilePleaseTryAgain,
      );
      return;
    }
    final cubit = context.read<AssignmentControlCubit>();
    showConfirmDialog(
      context: context,
      title: S.of(context).submitEvidence,
      subtitle: S.of(context).areYouSureYouWantToSubmitThisEvidence,
      confirmLabel: S.of(context).submit,
      cancelLabel: S.of(context).Cancel,
      onConfirm: () => cubit.submitEvidence(
        moduleId: widget.module.moduleId,
        policyId: widget.item.control.policyId,
        controlId: widget.item.control.id,
        championEmail: currentGrcUserEmail(),
        documentFile: File(file.path!),
        note: note,
      ),
    );
  }

  /// The Upload/Resubmit Evidence button, replaced with a small spinner
  /// while a submit is in flight so the user gets clear loading feedback.
  Widget _submitButton(BuildContext context, bool isSaving) {
    if (isSaving) {
      return SizedBox(
        width: 180.w,
        height: 44.h,
        child: Center(
          child: SizedBox(
            width: 20.w,
            height: 20.w,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }
    return SizedBox(
      width: 180.w,
      child: customButtonWithSvg(
        title: grcTr(context, _actionLabel),
        function: () => _onActionPressed(context),
        textStyle:
            StyleText.fontSize14Weight500.copyWith(color: AppColors.textButton),
        color: AppColors.primary,
        image: 'assets/icons_assets/data_grc_assets/upload_minimalistic.svg',
        widthImage: 18.r,
        heightImage: 18.r,
        colorBorder: AppColors.transparent,
        svgColor: AppColors.textButton,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final control = widget.item.control;
    final policy = widget.item.policy;
    final assignment = widget.item.assignment;
    final isArabic = context.isArabic;
    final moduleOwnerEmail = widget.module.moduleOwners.isNotEmpty
        ? widget.module.moduleOwners.first
        : null;
    final policyDocument =
        isArabic ? policy.policyDocumentAr : policy.policyDocumentEn;
    final rejectionReason =
        (assignment?.departmentManagerRejectionReason?.isNotEmpty == true)
            ? assignment!.departmentManagerRejectionReason
            : assignment?.controlOwnerRejectionReason;

    return BlocConsumer<AssignmentControlCubit, AssignmentControlState>(
      listener: (context, state) {
        if (state is AssignmentControlActionSuccess) {
          // Refresh the shared list cubit now so the list page (already
          // underneath us) shows the new status/tab counts by the time we
          // pop back to it, instead of the stale pre-submit snapshot.
          context.read<AssignmentControlCubit>().getMyAssignmentControls(
                moduleId: widget.module.moduleId,
                championEmail: currentGrcUserEmail(),
              );
          showSuccessDialog(
            context: context,
            title: S.of(context).evidenceSubmitted,
            subtitle: S.of(context).yourEvidenceWasSubmittedSuccessfully,
          );
          Navigator.pop(context);
        } else if (state is AssignmentControlFailure) {
          CustomDialogManager.showMessage(
            context: context,
            lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
            title: S.of(context).unsuccessful,
            subtitle: state.message,
          );
        }
      },
      builder: (context, state) {
        final isSaving = state is AssignmentControlLoading;
        final style = AssignmentControlTabStyle.of(widget.item.tab);
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PaginationAppBar(
                    screensTitles: [
                      S.of(context).grc,
                      S.of(context).assignmentControls,
                      isArabic
                          ? control.controlsNameAr
                          : control.controlsNameEn,
                    ],
                  ),
                  SizedBox(height: 15.h),
                  Expanded(
                    child: ListView(
                      children: [
                        Text(S.of(context).policyDetails,
                            style: StyleText.fontSize16Weight600),
                        SizedBox(height: 8.h),
                        GrcSectionCard(color: AppColors.card, children: [
                          Text(
                            isArabic
                                ? policy.policyNameAr
                                : policy.policyNameEn,
                            style: StyleText.fontSize16Weight600,
                          ),
                          SizedBox(height: 8.h),
                          Text(S.of(context).policyDescription,
                              style: CardStyles.label(12)),
                          SizedBox(height: 4.h),
                          Text(
                            isArabic
                                ? policy.policyDescriptionAr
                                : policy.policyDescriptionEn,
                            style: CardStyles.value(12),
                          ),
                          SizedBox(height: 12.h),
                          if (moduleOwnerEmail != null) ...[
                            GrcContactInlineRow(
                                label: S.of(context).moduleOwner,
                                email: moduleOwnerEmail),
                            SizedBox(height: 12.h),
                          ],
                          Row(
                            children: [
                              Expanded(
                                child: GrcLabelValueRow(S.of(context).policyWeight,
                                    policy.policyWeight.toString()),
                              ),
                              Expanded(
                                child: GrcLabelValueRow(
                                  S.of(context).policyNumber,
                                  isArabic
                                      ? policy.policyNumberAr
                                      : policy.policyNumberEn,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GrcLabelValueRow(
                                        S.of(context).startDate,
                                        _cardDateFormat
                                            .format(policy.startDate)),
                                    SizedBox(height: 4.h),
                                    GrcLabelValueRow(S.of(context).endDate,
                                        _cardDateFormat.format(policy.endDate)),
                                  ],
                                ),
                              ),
                              if (policyDocument != null &&
                                  policyDocument.isNotEmpty)
                                ProductWarrantyCard(
                                  title: S.of(context).policyDocument,
                                  fileName: fileNameOf(policyDocument),
                                  onTapFile: () =>
                                      openGrcDocument(policyDocument),
                                ),
                            ],
                          ),
                        ]),
                        SizedBox(height: 15.h),
                        Text(S.of(context).controlDetails,
                            style: StyleText.fontSize16Weight600),
                        SizedBox(height: 8.h),
                        GrcSectionCard(color: AppColors.card, children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  isArabic
                                      ? control.controlsNameAr
                                      : control.controlsNameEn,
                                  style: StyleText.fontSize16Weight600,
                                ),
                              ),
                              if (assignment?.controlScore != null)
                                GrcScoreBadge(score: assignment!.controlScore!),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          GrcLabelValueRow(
                            S.of(context).description,
                            isArabic
                                ? control.controlsDescriptionAr
                                : control.controlsDescriptionEn,
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: GrcLabelValueRow(
                                  S.of(context).controlWeight,
                                  control.controlsWeight.toString(),
                                ),
                              ),
                              if (widget.item.ownerEmail != null)
                                GrcContactInlineRow(
                                    label: S.of(context).controlOwner,
                                    email: widget.item.ownerEmail),
                            ],
                          ),
                        ]),
                        SizedBox(height: 15.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(S.of(context).submissions,
                                style: StyleText.fontSize16Weight600),
                            GrcSectionSubTabs(
                              labels: [S.of(context).submission, S.of(context).inquires],
                              selected: _submissionsTab,
                              onChanged: (i) =>
                                  setState(() => _submissionsTab = i),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        // FIXED 28/9/2026 (GRC bug report p25): the tab said
                        // "Inquiries coming soon". It is the same champion ↔
                        // manager thread the manager sees on the Approvals
                        // details page — same Firestore path, whose Approval
                        // id is `{controlId}_{championEmail}`.
                        if (_submissionsTab == 1)
                          ApprovalInquiriesCard(
                            moduleId: widget.module.moduleId,
                            approvalId:
                                '${control.id}_${currentGrcUserEmail()}',
                          )
                        else
                          GrcSectionCard(children: [
                            if (assignment == null) ...[
                              SizedBox(height: 20.h),
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons_assets/qiyas_assets/cloud_upload.svg',
                                      width: 56.w,
                                      height: 56.h,
                                      colorFilter: ColorFilter.mode(
                                          AppColors.text.withValues(alpha: 0.4),
                                          BlendMode.srcIn),
                                    ),
                                    SizedBox(height: 16.h),
                                    _submitButton(context, isSaving),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20.h),
                            ] else ...[
                              BlocBuilder<SubmissionHistoryCubit,
                                  SubmissionHistoryState>(
                                bloc: _historyCubit,
                                builder: (context, historyState) {
                                  if (historyState
                                      is SubmissionHistoryFailure) {
                                    return Text(
                                      historyState.message,
                                      style: CardStyles.value(12)
                                          .copyWith(color: Colors.red),
                                    );
                                  }
                                  if (historyState
                                      is! SubmissionHistoryLoaded) {
                                    return Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 24.h),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                            color: AppColors.primary),
                                      ),
                                    );
                                  }
                                  final entries = historyState.entries;
                                  return Column(
                                    children: [
                                      for (final e
                                          in entries.asMap().entries) ...[
                                        Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10.h,
                                                horizontal: 12.w),
                                            decoration: BoxDecoration(
                                              color: AppColors.card,
                                              borderRadius: CardStyles.radius(),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    GrcSubmitterRow(
                                                        email: assignment
                                                            .controlChampionEmail),
                                                    Text.rich(
                                                      TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text:
                                                                '${S.of(context).submissionDate}: ',
                                                            style: CardStyles
                                                                    .label(12)
                                                                .copyWith(
                                                                    color: AppColors
                                                                        .text),
                                                          ),
                                                          TextSpan(
                                                            text:
                                                                '${_cardDateFormat.format(e.value.submittedDate)} '
                                                                '${S.of(context).at} '
                                                                '${_cardTimeFormat.format(e.value.submittedDate)}',
                                                            style: CardStyles
                                                                .label(12),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 12.h),
                                                if (e.value.document.isNotEmpty)
                                                  ProductWarrantyCard(
                                                    title: S.of(context).submission,
                                                    fileName: fileNameOf(e.value.document),
                                                    onTapFile: () =>
                                                        openGrcDocument(
                                                            e.value.document),
                                                  ),
                                                SizedBox(height: 12.h),
                                                if (e
                                                    .value.note.isNotEmpty) ...[
                                                  GrcLabelValueRow(
                                                      S.of(context).submissionNotes,
                                                      e.value.note),
                                                  SizedBox(height: 12.h),
                                                ],
                                                if (e.value.status ==
                                                        AssignmentControlStatus
                                                            .rejected &&
                                                    (e.value.rejectionReason
                                                            ?.isNotEmpty ??
                                                        false)) ...[
                                                  GrcLabelValueRow(
                                                    S.of(context).reasonsOfRejectionTitle,
                                                    e.value.rejectionReason!,
                                                    color: Colors.red,
                                                  ),
                                                  SizedBox(height: 12.h),
                                                ],
                                                if (e.key == 0 && _isRejected)
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      _submitButton(
                                                          context, isSaving),
                                                      GrcStatusPill(
                                                        label: grcTr(context, widget
                                                            .item.tab.label),
                                                        color: style.color,
                                                        icon: style.icon,
                                                      ),
                                                    ],
                                                  )
                                                else
                                                  Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: GrcStatusPill(
                                                      label: grcTr(context, e.value.status
                                                          .label),
                                                      color:
                                                          AssignmentControlStatusStyle
                                                                  .of(e.value
                                                                      .status)
                                                              .color,
                                                      icon:
                                                          AssignmentControlStatusStyle
                                                                  .of(e.value
                                                                      .status)
                                                              .icon,
                                                    ),
                                                  ),
                                              ],
                                            )),
                                        SizedBox(height: 12.h),
                                      ],
                                    ],
                                  );
                                },
                              ),
                            ],
                          ]),
                        SizedBox(height: 15.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
