/// Module: GRC / Approvals (Department Manager)
///
///*************************** FILE INFO ****************************///
/// File Name: approval_card.dart
/// Purpose: One card on the Approvals list, laid out the way MAGDY
///          ("MAIN PAGE : Approvals") draws it at each design width.
/// Author: Mohamed Magdy Abdelkhalek
/// Updated: 16/9/2026 - Responsive rebuild for mobile (375), tablet (768)
///          and desktop (1024):
///            * 1024: Control Name + Score chip on the first line, Policy
///                    Name, Control Champion, status pill bottom-trailing.
///            * 768:  Control Name + Request Date on the first line, Policy
///                    Name, Control Champion, Score chip bottom-leading and
///                    status pill bottom-trailing.
///            * 375:  Control Name, Policy Name, Control Champion, status
///                    pill bottom-trailing (no date, no score).
///          A Pending approval shows no pill at any width, as in the design.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/grc/approval/domain/entities/approval_item.dart';
import 'package:knowticed_plus/features/grc/approval/domain/entities/approval_status.dart';
import 'package:knowticed_plus/features/grc/approval/presentation/ui/widgets/approval_details_sections.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_person_profile_card.dart'
    show GrcAvatarName;
import 'package:knowticed_plus/features/grc/shared/widgets/grc_score_badge.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// class name: [ApprovalCard]
///
/// purpose: tappable white card for one [ApprovalItem]. Opens the Request
///          Details page through [onTap].
class ApprovalCard extends StatelessWidget {
  final ApprovalItem item;
  final bool isArabic;
  final VoidCallback onTap;

  const ApprovalCard({
    super.key,
    required this.item,
    required this.isArabic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final ScreenSize size = screenSizeOf(context);
    final control = item.control;
    final policy = item.policy;
    final double? score = item.assignmentControl.controlScore;
    final bool isPending = item.approval.status == ApprovalStatus.pending;
    final String dateLocale = isArabic ? 'ar' : 'en';

    final Widget controlName = Text(
      isArabic ? control.controlsNameAr : control.controlsNameEn,
      style: CardStyles.value(14),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    final Widget requestDate = Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '${s.RequestDate}: ', style: CardStyles.label(8)),
          TextSpan(
            text: DateFormat('d MMM yyyy', dateLocale)
                .format(item.assignmentControl.lastModificationDate),
            style: CardStyles.value(8),
          ),
        ],
      ),
    );

    final Widget policyLine = Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '${s.policyName}: ', style: CardStyles.label(10)),
          TextSpan(
            text: isArabic ? policy.policyNameAr : policy.policyNameEn,
            style: CardStyles.value(10),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    final Widget championLine = Row(
      children: [
        Text('${s.controlChampion}: ', style: CardStyles.label(10)),
        Flexible(
          child: GrcAvatarName(
            email: item.assignmentControl.controlChampionEmail,
            avatarRadius: 15,
            style: CardStyles.value(12),
          ),
        ),
      ],
    );

    final Widget? pill =
        isPending ? null : ApprovalStatusPill(status: item.approval.status);

    final Widget firstLine = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: controlName),
        if (size != ScreenSize.mobile) ...[
          SizedBox(width: 8.w),
          requestDate,
        ],
      ],
    );

    final Widget footer = Row(
      children: [
        if (size != ScreenSize.mobile && score != null) GrcScoreBadge(score: score),
        const Spacer(),
        if (pill != null) pill,
      ],
    );

    // Pending cards on tablet/desktop keep the footer height so every card
    // in a grid row lines up; the phone list has no rows to line up with.
    final bool showFooter = pill != null ||
        (size != ScreenSize.mobile && score != null) ||
        size != ScreenSize.mobile;

    // GestureDetector, not InkWell: no hover / splash overlay on the card
    // (same as the GRC Requests list).
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(15.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: CardStyles.radius(),
          boxShadow: CardStyles.shadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            firstLine,
            SizedBox(height: 8.h),
            policyLine,
            SizedBox(height: 10.h),
            championLine,
            if (showFooter) ...[
              SizedBox(height: 10.h),
              SizedBox(height: 24.sp, child: footer),
            ],
          ],
        ),
      ),
    );
  }
}
