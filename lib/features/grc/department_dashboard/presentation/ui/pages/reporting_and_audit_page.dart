/// Module: GRC / Dashboard Of All Departments
/// Description: "Reporting and Audit" (MAGDY → "MAIN PAGE : Dashboard Of
///              All Departments"), opened from the Departments tab.
///            * Department picker, with a Hide / Show link for the summary
///            * Summary card: Compliance Score / Applied Policies / Applied
///              Controls, Choose Policy / Choose Control, and — once a
///              control is chosen — that control's name, status, score,
///              description, owner and champion (with Message buttons)
///            * "Inquiries And Comments" thread (UniversalCommentSection),
///              scoped to the chosen department / policy / control, with its
///              own Hide / Show link
///          Shares the tab's DepartmentDashboardCubit (BlocProvider.value).
/// Author: Knowticed Plus team
/// Date: 2026-09-16
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/36-custom_comment_widget.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/approval/presentation/ui/widgets/approval_details_sections.dart'
    show
        ApprovalMessagePlacement,
        ApprovalPersonLine,
        ApprovalScoreChip,
        approvalControlStatusColor,
        approvalLabelValue;
import 'package:knowticed_plus/features/grc/department_dashboard/domain/entities/department_dashboard_data.dart';
import 'package:knowticed_plus/features/grc/department_dashboard/presentation/controller/department_dashboard_cubit.dart';
import 'package:knowticed_plus/features/grc/department_dashboard/presentation/ui/widgets/department_common_widgets.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_l10n.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/grc/shared/constants/grc_firebase_paths.dart';

/// class name: [ReportingAndAuditPage]
class ReportingAndAuditPage extends StatefulWidget {
  final GRCModuleEntity module;

  const ReportingAndAuditPage({super.key, required this.module});

  @override
  State<ReportingAndAuditPage> createState() => _ReportingAndAuditPageState();
}

class _ReportingAndAuditPageState extends State<ReportingAndAuditPage> {
  bool _showSummary = true;
  bool _showInquiries = true;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return SideFrameMasterServices(
      titleText: s.grc,
      onFirstTap: () => popFrameRoutes(context, 2),
      secondTitle: widget.module.localizedName(isArabic: context.isArabic),
      onSecondTap: () => popFrameRoutes(context, 1),
      thirdTitle: s.reportingAndAudit,
      child: SideFrameScrollableBody(
        child: BlocBuilder<DepartmentDashboardCubit, DepartmentDashboardState>(
          builder: (context, st) {
            final DepartmentDashboardData? d = st.data;
            if (d == null) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h),
                child: const Center(child: CircleProgressMaster()),
              );
            }
            final cubit = context.read<DepartmentDashboardCubit>();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: DepartmentPicker(
                    hint: s.department,
                    value: st.department,
                    items: DepartmentPicker.departmentItems(context, d),
                    onChanged: cubit.setDepartment,
                  ),
                ),
                SizedBox(height: 6.h),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: _HideLink(
                    shown: _showSummary,
                    onTap: () => setState(() => _showSummary = !_showSummary),
                  ),
                ),
                SizedBox(height: 6.h),
                if (_showSummary) ...[
                  _summaryCard(context, st, d, cubit),
                  SizedBox(height: 15.h),
                ],
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        s.inquiriesAndComments,
                        style: StyleText.fontSize16Weight400.copyWith(
                          color: AppColors.text,
                          fontSize: 20.sp,
                        ),
                      ),
                    ),
                    _HideLink(
                      shown: _showInquiries,
                      onTap: () =>
                          setState(() => _showInquiries = !_showInquiries),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                if (_showInquiries) _inquiries(context, st),
                SizedBox(height: 30.h),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _summaryCard(
    BuildContext context,
    DepartmentDashboardState st,
    DepartmentDashboardData d,
    DepartmentDashboardCubit cubit,
  ) {
    final S s = S.of(context);
    final DepartmentControlRef? ref = st.reportControlId == null
        ? null
        : d
            .controlsFor(department: st.department, policyId: st.reportPolicyId)
            .where((r) => r.control.id == st.reportControlId)
            .firstOrNull;

    return Container(
      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: CardStyles.radius(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DepartmentStatsRow(
            data: d,
            department: st.department,
            chipBackground: AppColors.background,
          ),
          SizedBox(height: 20.h),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Wrap(
              spacing: 15.sp,
              runSpacing: 10.sp,
              alignment: WrapAlignment.end,
              children: [
                DepartmentPicker(
                  hint: s.choosePolicy,
                  value: st.reportPolicyId,
                  fillColor: AppColors.background,
                  items: DepartmentPicker.policyItems(context, d, st.department),
                  onChanged: cubit.setReportPolicy,
                ),
                DepartmentPicker(
                  hint: s.chooseControl,
                  value: st.reportControlId,
                  fillColor: AppColors.background,
                  items: DepartmentPicker.controlItems(
                      context, d, st.department, st.reportPolicyId),
                  onChanged: cubit.setReportControl,
                ),
              ],
            ),
          ),
          if (ref != null) ...[
            SizedBox(height: 20.h),
            _ControlSummary(ref: ref),
          ],
        ],
      ),
    );
  }

  Widget _inquiries(BuildContext context, DepartmentDashboardState st) {
    final String department = st.department ?? 'All';
    final String policyId = st.reportPolicyId ?? '';
    final String controlId = st.reportControlId ?? '';
    final bool isMobile = screenSizeOf(context) == ScreenSize.mobile;
    return UniversalCommentSection(
      key: ValueKey<String>('dept-inquiries-$department-$policyId-$controlId'),
      collectionPath:
          '${GrcFirebasePaths.modulesCollection}/${widget.module.moduleId}/Department_Inquiries',
      filterFields: <String, dynamic>{
        'Department': department,
        'Policy_ID': policyId,
        'Control_ID': controlId,
      },
      currentUserId: currentGrcUserEmail(),
      isExpandable: false,
      collapsedHeight: isMobile ? 360.h : 380.h,
      style: CommentSectionStyle(
        containerDecoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: CardStyles.radius(),
        ),
        containerPadding: EdgeInsets.all(15.sp),
      ),
    );
  }
}

/// Blue underlined "Hide" / "Show" link.
class _HideLink extends StatelessWidget {
  final bool shown;
  final VoidCallback onTap;

  const _HideLink({required this.shown, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.sp),
        child: Text(
          shown ? S.of(context).hide : S.of(context).show,
          style: StyleText.fontSize14Weight400.copyWith(
            color: AppColors.blue,
            decoration: TextDecoration.underline,
            decorationColor: AppColors.blue,
          ),
        ),
      ),
    );
  }
}

/// The chosen control inside the summary card: name + score, status,
/// description, and owner / champion with Message buttons.
class _ControlSummary extends StatelessWidget {
  final DepartmentControlRef ref;

  const _ControlSummary({required this.ref});

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool ar = context.isArabic;
    final bool isMobile = screenSizeOf(context) == ScreenSize.mobile;
    final control = ref.control;
    final placement = isMobile
        ? ApprovalMessagePlacement.trailingIcon
        : ApprovalMessagePlacement.below;

    final Widget owner = ApprovalPersonLine(
      label: s.controlOwner,
      email: ref.ownerEmail,
      placement: placement,
    );
    final Widget champion = ApprovalPersonLine(
      label: s.controlChampion,
      email: ref.championEmail,
      placement: placement,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                ar ? control.controlsNameAr : control.controlsNameEn,
                style: CardStyles.value(16),
              ),
            ),
            ApprovalScoreChip(score: control.score.toDouble()),
          ],
        ),
        SizedBox(height: 8.h),
        approvalLabelValue(
          s.Status,
          grcTr(context, control.status.value),
          valueColor: approvalControlStatusColor(control.status),
        ),
        SizedBox(height: 10.h),
        approvalLabelValue(
          s.description,
          ar ? control.controlsDescriptionAr : control.controlsDescriptionEn,
          valueSize: 14,
        ),
        SizedBox(height: 25.h),
        if (isMobile) ...[
          owner,
          SizedBox(height: 15.h),
          champion,
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: owner),
              Expanded(child: champion),
            ],
          ),
      ],
    );
  }
}
