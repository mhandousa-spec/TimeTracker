// lib/features/grc/my_audit/presentation/ui/pages/my_audit_details_page.dart
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/9-filter_tab_with_container.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/52-custom_upload_document.dart'
    show fileNameOf;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/11-custom_confirm_diaolog.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/22-custom_uploaded_document_card.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/entities/assignment_control_status.dart';
import 'package:knowticed_plus/features/grc/assignment_control/presentation/controller/submission_history_cubit.dart';
import 'package:knowticed_plus/features/grc/my_audit/domain/entities/my_audit_item.dart';
import 'package:knowticed_plus/features/grc/my_audit/domain/entities/my_audit_tab.dart';
import 'package:knowticed_plus/features/grc/my_audit/presentation/controller/my_audit_cubit.dart';
import 'package:knowticed_plus/features/grc/my_audit/presentation/ui/widgets/my_audit_inquiries_card.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_document_launcher.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_button_loading_placeholder.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_contact_inline_row.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_label_value_row.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_score_badge.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_section_card.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_status_pill.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_submitter_row.dart';

import 'package:knowticed_plus/core/helper/main_helper/pagination_app_bar.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_l10n.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';

final DateFormat _cardDateFormat = DateFormat('d MMM yyyy');
final DateFormat _cardTimeFormat = DateFormat('h:mm a');

class MyAuditDetailsPage extends StatefulWidget {
  final MyAuditItem item;
  final GRCModuleEntity module;

  /// GRC bug report p3: opened from Approvals → Give Score by the Module
  /// Owner, who only gives the score — the approve / reject decision was the
  /// control owner's. Refreshes the Give Score queue instead of My Audits.
  final bool scoreOnly;

  const MyAuditDetailsPage({
    super.key,
    required this.item,
    required this.module,
    this.scoreOnly = false,
  });

  @override
  State<MyAuditDetailsPage> createState() => _MyAuditDetailsPageState();
}

class _MyAuditDetailsPageState extends State<MyAuditDetailsPage> {
  int _submissionTab = 0; // 0 = Submission, 1 = Inquires
  late final SubmissionHistoryCubit _historyCubit;

  @override
  void initState() {
    super.initState();
    _historyCubit = GetIt.instance<SubmissionHistoryCubit>();
    final assignmentControl = widget.item.assignmentControl;
    if (assignmentControl != null) {
      _historyCubit.loadHistory(
        moduleId: widget.module.moduleId,
        controlId: widget.item.control.id,
        championEmail: assignmentControl.controlChampionEmail,
      );
    }
  }

  @override
  void dispose() {
    _historyCubit.close();
    super.dispose();
  }

  void _onApprovePressed(BuildContext context) {
    final cubit = context.read<MyAuditCubit>();
    showConfirmDialog(
      context: context,
      title: S.of(context).approveEvidence,
      subtitle: S.of(context).areYouSureYouWantToApproveThisEvidence,
      lottieAsset: 'assets/lottie_assets/main_lottie_assets/approved.json',
      confirmLabel: S.of(context).yes,
      cancelLabel: S.of(context).no,
      onConfirm: () => cubit.approve(
        moduleId: widget.module.moduleId,
        controlId: widget.item.control.id,
        championEmail: widget.item.assignmentControl!.controlChampionEmail,
        ownerEmail: currentGrcUserEmail(),
      ),
    );
  }

  void _onRejectPressed(BuildContext context) {
    final cubit = context.read<MyAuditCubit>();
    showConfirmDialog(
      context: context,
      title: S.of(context).rejectEvidence,
      subtitle: S.of(context).areYouSureYouWantToRejectThisEvidence,
      confirmLabel: S.of(context).yes,
      cancelLabel: S.of(context).no,
      onConfirm: () => showCommentDialog(
        context: context,
        title: S.of(context).ReasonOfRejection,
        fieldLabel: S.of(context).Justifications,
        hint: S.of(context).Texthere,
        submitLabel: S.of(context).submit,
        onSubmit: (reason) => cubit.reject(
          moduleId: widget.module.moduleId,
          controlId: widget.item.control.id,
          championEmail: widget.item.assignmentControl!.controlChampionEmail,
          ownerEmail: currentGrcUserEmail(),
          reason: reason,
        ),
      ),
    );
  }

  void _onScorePressed(BuildContext context) {
    final cubit = context.read<MyAuditCubit>();
    final scoreController = TextEditingController(
        text: widget.item.audit?.controlScore?.toString() ?? '');
    final justificationController = TextEditingController(
        text: widget.item.audit?.controlOwnerJustification ?? '');
    showDialog(
      context: context,
      barrierColor: AppColors.totalBlack.withValues(alpha: 0.4),
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.card,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        child: Container(
          width: 380.w,
          padding: EdgeInsets.all(16.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 30.r,
                    height: 30.r,
                    decoration: BoxDecoration(
                        color: AppColors.primary, shape: BoxShape.circle),
                    child: Icon(Icons.workspace_premium,
                        size: 16.r, color: AppColors.textButton),
                  ),
                  SizedBox(width: 8.w),
                  Text(S.of(context).giveAScore, style: StyleText.fontSize14Weight600),
                ],
              ),
              SizedBox(height: 16.h),
              Text(S.of(context).score, style: CardStyles.label(12)),
              SizedBox(height: 6.h),
              CustomTextField(
                hint: S.of(context).Texthere,
                controller: scoreController,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 12.h),
              Text(S.of(context).Justifications, style: CardStyles.label(12)),
              SizedBox(height: 6.h),
              CustomTextField(
                hint: S.of(context).Texthere,
                controller: justificationController,
                maxLines: 3,
              ),
              SizedBox(height: 16.h),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 120.w,
                  child: customButton(
                    title: S.of(context).submit,
                    function: () {
                      final score =
                          double.tryParse(scoreController.text.trim());
                      if (score == null) return;
                      Navigator.of(dialogContext).pop();
                      cubit.submitScore(
                        moduleId: widget.module.moduleId,
                        policyId: widget.item.control.policyId,
                        controlId: widget.item.control.id,
                        championEmail:
                            widget.item.assignmentControl!.controlChampionEmail,
                        ownerEmail: currentGrcUserEmail(),
                        score: score,
                        justification:
                            justificationController.text.trim().isEmpty
                                ? null
                                : justificationController.text.trim(),
                      );
                    },
                    height: 36.h,
                    color: AppColors.primary,
                    textStyle: StyleText.fontSize14Weight500
                        .copyWith(color: AppColors.textButton),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;
    final control = widget.item.control;
    final policy = widget.item.policy;
    final assignmentControl = widget.item.assignmentControl;
    final audit = widget.item.audit;
    final moduleOwnerEmail = widget.module.moduleOwners.isNotEmpty
        ? widget.module.moduleOwners.first
        : null;
    final policyDocument =
        isArabic ? policy.policyDocumentAr : policy.policyDocumentEn;

    return BlocConsumer<MyAuditCubit, MyAuditState>(
      listener: (context, state) {
        if (state is MyAuditActionSuccess) {
          if (widget.scoreOnly) {
            context
                .read<MyAuditCubit>()
                .getScoreRequests(moduleId: widget.module.moduleId);
          } else {
            context.read<MyAuditCubit>().getMyAudits(
                  moduleId: widget.module.moduleId,
                  ownerEmail: currentGrcUserEmail(),
                );
          }
          showSuccessDialog(
            context: context,
            title: S.of(context).Successful,
            subtitle: widget.item.tab == MyAuditTab.rejected
                ? S.of(context).youSuccessfullyRejectedThisEvidence
                : S.of(context).youSuccessfullyApprovedThisEvidence,
          );
          Navigator.pop(context);
        } else if (state is MyAuditFailure) {
          CustomDialogManager.showMessage(
            context: context,
            lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
            title: S.of(context).unsuccessful,
            subtitle: state.message,
          );
        }
      },
      builder: (context, state) {
        final isSaving = state is MyAuditLoading;
        final style = MyAuditTabStyle.of(widget.item.tab);
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
                      S.of(context).myAudit,
                      isArabic
                          ? control.controlsNameAr
                          : control.controlsNameEn,
                    ],
                  ),
                  SizedBox(height: 15.h),
                  Expanded(
                    child: assignmentControl == null
                        ? _OverdueBody(
                            control: control,
                            policy: policy,
                            isArabic: isArabic)
                        : ListView(
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
                                      child: GrcLabelValueRow(
                                          S.of(context).policyWeight,
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          GrcLabelValueRow(
                                              S.of(context).startDate,
                                              _cardDateFormat
                                                  .format(policy.startDate)),
                                          SizedBox(height: 4.h),
                                          GrcLabelValueRow(
                                              S.of(context).endDate,
                                              _cardDateFormat
                                                  .format(policy.endDate)),
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(S.of(context).controlDetails,
                                      style: StyleText.fontSize16Weight600),
                                  if (assignmentControl.controlScore != null)
                                    GrcScoreBadge(
                                        score: assignmentControl.controlScore!),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              GrcSectionCard(color: AppColors.card, children: [
                                Text(
                                  isArabic
                                      ? control.controlsNameAr
                                      : control.controlsNameEn,
                                  style: StyleText.fontSize16Weight600,
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
                                      child: GrcContactInlineRow(
                                        label: S.of(context).controlOwner,
                                        email: assignmentControl.controlOwner,
                                      ),
                                    ),
                                    Expanded(
                                      child: GrcContactInlineRow(
                                        label: S.of(context).controlChampion,
                                        email: assignmentControl
                                            .controlChampionEmail,
                                      ),
                                    ),
                                  ],
                                ),
                              ]),
                              SizedBox(height: 15.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // GRC bug report p2: an owner added with
                                  // "Give Score" off only approves/rejects;
                                  // the Module Owner scores from Approvals.
                                  if (widget.item.ownerCanScore &&
                                      (widget.item.tab ==
                                              MyAuditTab.outstanding ||
                                          widget.item.tab ==
                                              MyAuditTab.scored))
                                    isSaving
                                        ? GrcButtonLoadingPlaceholder(
                                            width: 120.w, height: 34.h)
                                        : SizedBox(
                                            width: 120.w,
                                            child: customButton(
                                              title: grcTr(context, (widget.item.tab ==
                                                          MyAuditTab.scored
                                                      ? 'Edit Score'
                                                      : 'Add Score')),
                                              function: () =>
                                                  _onScorePressed(context),
                                              width: 120.w,
                                              color: AppColors.primary,
                                              textStyle: StyleText
                                                  .fontSize14Weight500
                                                  .copyWith(
                                                      color:
                                                          AppColors.textButton),
                                            ),
                                          ),
                                  // Text(S.of(context).submission,
                                  //     style: StyleText.fontSize16Weight600),
                                  const Spacer(),
                                  CustomSegmentedTabs(
                                    tabs: [S.of(context).submission, S.of(context).inquires],
                                    selectedIndex: _submissionTab,
                                    onTabSelected: (i) =>
                                        setState(() => _submissionTab = i),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              if (_submissionTab == 1)
                                MyAuditInquiriesCard(
                                  moduleId: widget.module.moduleId,
                                  policyId: widget.item.control.policyId,
                                  controlId: widget.item.control.id,
                                  championEmail: widget.item.assignmentControl
                                          ?.controlChampionEmail ??
                                      '',
                                )
                              else
                                Column(
                                  children: [
                                    BlocBuilder<SubmissionHistoryCubit,
                                        SubmissionHistoryState>(
                                      bloc: _historyCubit,
                                      builder: (context, historyState) {
                                        if (historyState
                                            is SubmissionHistoryFailure) {
                                          return GrcSectionCard(children: [
                                            Text(
                                              historyState.message,
                                              style: CardStyles.value(12)
                                                  .copyWith(color: Colors.red),
                                            ),
                                          ]);
                                        }
                                        if (historyState
                                            is! SubmissionHistoryLoaded) {
                                          return Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 24.h),
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
                                              GrcSectionCard(
                                                  color: AppColors.card,
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        GrcSubmitterRow(
                                                            email: assignmentControl
                                                                .controlChampionEmail),
                                                        Text(
                                                          '${S.of(context).submissionDate}: '
                                                          '${_cardDateFormat.format(e.value.submittedDate)} '
                                                          '${S.of(context).at} '
                                                          '${_cardTimeFormat.format(e.value.submittedDate)}',
                                                          style:
                                                              CardStyles.label(
                                                                  12),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 12.h),
                                                    if (e.value.document
                                                        .isNotEmpty)
                                                      ProductWarrantyCard(
                                                        title: S.of(context).submission,
                                                        fileName: fileNameOf(e.value.document),
                                                        onTapFile: () =>
                                                            openGrcDocument(e
                                                                .value
                                                                .document),
                                                      ),
                                                    SizedBox(height: 12.h),
                                                    if (e.value.note
                                                        .isNotEmpty) ...[
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
                                                        e.value
                                                            .rejectionReason!,
                                                        color: Colors.red,
                                                      ),
                                                      SizedBox(height: 12.h),
                                                    ],
                                                    if (e.key == 0 &&
                                                        widget.item.tab ==
                                                            MyAuditTab.pending)
                                                      isSaving
                                                          ? Align(
                                                              alignment: Alignment
                                                                  .centerRight,
                                                              child:
                                                                  GrcButtonLoadingPlaceholder(
                                                                width: 120.w,
                                                                height: 44.h,
                                                              ),
                                                            )
                                                          : Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                customButtonWithSvg(
                                                                  colorBorder:
                                                                      AppColors
                                                                          .red,
                                                                  space: 8.w,
                                                                  widthImage:
                                                                      18.w,
                                                                  heightImage:
                                                                      18.h,
                                                                  image:
                                                                      "assets/icons_assets/main_icons_assets/status_rejected_stamp_red.svg",
                                                                  title:
                                                                      S.of(context).reject,
                                                                  function: () =>
                                                                      _onRejectPressed(
                                                                          context),
                                                                  color:
                                                                      Colors.transparent,
                                                                  textStyle: StyleText
                                                                      .fontSize16Weight500
                                                                      .copyWith(
                                                                          color:
                                                                              AppColors.red),

                                                                ),
                                                                SizedBox(
                                                                    width:
                                                                        16.w),
                                                                customButtonWithSvg(
                                                                  colorBorder:
                                                                      AppColors
                                                                          .green,
                                                                  space: 8.w,
                                                                  widthImage:
                                                                      18.w,
                                                                  heightImage:
                                                                      18.h,
                                                                  image:
                                                                      'assets/icons_assets/data_grc_assets/images_success.svg',
                                                                  title:
                                                                      S.of(context).approve,
                                                                  function: () =>
                                                                      _onApprovePressed(
                                                                          context),
                                                                  color:
                                                                      Colors.transparent,
                                                                  textStyle: StyleText
                                                                      .fontSize16Weight500
                                                                      .copyWith(
                                                                          color:
                                                                              AppColors.green),

                                                                ),
                                                              ],
                                                            )
                                                    else if (e.key == 0)
                                                      Align(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: GrcStatusPill(
                                                          label: grcTr(context, widget.item.tab
                                                              .label),
                                                          color: style.color,
                                                          icon: style.icon,
                                                        ),
                                                      )
                                                    else
                                                      Align(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: GrcStatusPill(
                                                          label: grcTr(context, e.value.status
                                                              .label),
                                                          color:
                                                              AssignmentControlStatusStyle
                                                                      .of(e
                                                                          .value
                                                                          .status)
                                                                  .color,
                                                          icon: AssignmentControlStatusStyle
                                                                  .of(e.value
                                                                      .status)
                                                              .icon,
                                                        ),
                                                      ),
                                                  ]),
                                              SizedBox(height: 12.h),
                                            ],
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
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

/// Read-only body for a derived-Overdue row: the Champion never submitted,
/// so there is no Assignment Control / My Audit data to show — just an
/// informational message.
class _OverdueBody extends StatelessWidget {
  final dynamic control;
  final dynamic policy;
  final bool isArabic;

  const _OverdueBody(
      {required this.control, required this.policy, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text(S.of(context).policyDetails, style: StyleText.fontSize16Weight600),
        SizedBox(height: 8.h),
        GrcSectionCard(children: [
          Text(
            isArabic
                ? policy.policyNameAr as String
                : policy.policyNameEn as String,
            style: StyleText.fontSize16Weight600,
          ),
        ]),
        SizedBox(height: 15.h),
        Text(S.of(context).controlDetails, style: StyleText.fontSize16Weight600),
        SizedBox(height: 8.h),
        GrcSectionCard(children: [
          Text(
            isArabic
                ? control.controlsNameAr as String
                : control.controlsNameEn as String,
            style: StyleText.fontSize16Weight600,
          ),
        ]),
        SizedBox(height: 15.h),
        GrcSectionCard(children: [
          Text(S.of(context).noSubmissionWasMadeBeforeTheDeadline,
              style: CardStyles.value(12)),
        ]),
      ],
    );
  }
}
