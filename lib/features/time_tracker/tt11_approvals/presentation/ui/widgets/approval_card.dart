/// Module: time_tracker / tt11_approvals / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: approval_card.dart
/// Purpose: Declares `ApprovalCard` — one request on the Approvals tab.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Figma `661:83996`: icon box + "Request Type: Sick Leave" ("Request:
/// Transaction"); Requested by (avatar + name) · Job Title · Department ·
/// Request Date · Requested Timeframe (or Check In / Check Out) · Total
/// Time; footer = red Reject + green Approve when the current step waits
/// for the viewer (`Approve_And_Reject` + scope), otherwise one full-width
/// status bar (Approved / Rejected / Canceled / Pending / Under Review). The
/// card opens the approval details (LOW haptic, no splash); the buttons run
/// the same flows as the details page.
/// Updated: 9/10/2026 - code review: Material icons → the app's SVG line
/// icons (`TtAssets` / `TtGlyph`) where an equivalent asset exists.
/// Updated: 9/10/2026 - owner review: names / titles take up to two lines
/// (no "…" on a normal name such as "Bayanatz Transformation").

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
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

class ApprovalCard extends StatelessWidget {
  const ApprovalCard({super.key, required this.request, required this.state, required this.onTap});

  final TimeTrackerRequest request;
  final RequestsState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    final TimeTrackerEmployee? who = state.employeeOf(request.requesterEmail);
    // 9/10/2026 (UI pass): app language + proper case (KP-TT-017).
    final String department = (who?.department(isArabic: ar) ?? '').isNotEmpty
        ? who!.department(isArabic: ar)
        : state.departments[request.requesterDepartmentId] ?? TimeTrackerFormat.dash;
    final String jobTitle = who?.jobTitle(isArabic: ar) ?? '';
    return GestureDetector(
      key: ValueKey<String>('approvalCard_${request.id}'),
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticController.low();
        onTap();
      },
      child: Container(
        padding: EdgeInsetsDirectional.all(12.r),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: CardStyles.radius()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                const RequestIconBox(),
                SizedBox(width: 10.w),
                Text('${request.isTransaction ? s.timeTrackerRequestWord : s.timeTrackerRequestType}: ',
                    style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText)),
                Expanded(
                  child: Text(RequestText.typeName(context, request, state),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            RequestInfoLine(
              icon: const TtGlyph.svg(TtAssets.person),
              label: s.timeTrackerRequestedBy,
              child: Row(
                children: <Widget>[
                  TimeTrackerAvatar(photo: who?.photo ?? '', size: 22.r),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(who?.name(isArabic: ar) ?? request.requesterEmail,
                        key: ValueKey<String>('approvalRequester_${request.id}'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text)),
                  ),
                ],
              ),
            ),
            RequestInfoLine(
              icon: const TtGlyph.icon(Icons.work_outline),
              label: s.timeTrackerJobTitle,
              value: jobTitle.isEmpty ? TimeTrackerFormat.dash : jobTitle,
            ),
            RequestInfoLine(icon: const TtGlyph.svg(TtAssets.department), label: s.timeTrackerDepartment, value: department),
            RequestInfoLine(
              icon: const TtGlyph.svg(TtAssets.calendar),
              label: s.timeTrackerRequestDate,
              value: RequestText.requestDate(context, request),
            ),
            ...RequestCardLines.timeLines(context, request),
            const Spacer(),
            SizedBox(height: 10.h),
            _footer(context),
          ],
        ),
      ),
    );
  }

  Widget _footer(BuildContext context) {
    final S s = S.of(context);
    if (!context.read<RequestActionsCubit>().mayDecide(request)) {
      return SizedBox(width: double.infinity, child: RequestStatusPill(status: request.status));
    }
    return Row(
      children: <Widget>[
        Expanded(
          child: KeyedSubtree(
            key: ValueKey<String>('approvalCardReject_${request.id}'),
            child: RequestOutlinedButton(
              label: s.reject,
              icon: const TtGlyph.icon(Icons.block),
              color: AppColors.red,
              high: true,
              onTap: () => RequestFlows.reject(context, request),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: KeyedSubtree(
            key: ValueKey<String>('approvalCardApprove_${request.id}'),
            child: RequestOutlinedButton(
              label: s.approve,
              icon: const TtGlyph.icon(Icons.check_circle_outline),
              color: AppColors.lightGreen,
              onTap: () => RequestFlows.approve(context, request),
            ),
          ),
        ),
      ],
    );
  }
}
