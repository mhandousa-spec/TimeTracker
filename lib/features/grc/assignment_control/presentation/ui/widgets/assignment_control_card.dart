// lib/features/grc/assignment_control/presentation/ui/widgets/assignment_control_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/entities/assignment_control_item.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/entities/assignment_control_tab.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_score_badge.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_status_pill.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_l10n.dart';

final DateFormat _dueDateFormat = DateFormat('d MMM yyyy');

/// Visual identity (color + icon) for one [AssignmentControlTab], shared by
/// the status pill on this card and the tab bar above the grid.
class AssignmentControlTabStyle {
  final Color color;
  final IconData icon;

  const AssignmentControlTabStyle({required this.color, required this.icon});

  static AssignmentControlTabStyle of(AssignmentControlTab tab) {
    switch (tab) {
      case AssignmentControlTab.pending:
        return AssignmentControlTabStyle(
            color: AppColors.warning, icon: Icons.schedule);
      case AssignmentControlTab.submitted:
        return AssignmentControlTabStyle(
            color: AppColors.warning, icon: Icons.upload_file);
      case AssignmentControlTab.inReview:
        return const AssignmentControlTabStyle(
            color: Colors.orange, icon: Icons.hourglass_bottom);
      case AssignmentControlTab.rejected:
        return const AssignmentControlTabStyle(
            color: Colors.red, icon: Icons.block);
      case AssignmentControlTab.approved:
        return const AssignmentControlTabStyle(
            color: Colors.green, icon: Icons.check_circle);
      case AssignmentControlTab.overdue:
        return const AssignmentControlTabStyle(
            color: Colors.red, icon: Icons.alarm);
    }
  }
}

class AssignmentControlCard extends StatelessWidget {
  final AssignmentControlItem item;
  final bool isArabic;
  final VoidCallback onTap;

  const AssignmentControlCard({
    super.key,
    required this.item,
    required this.isArabic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final control = item.control;
    final style = AssignmentControlTabStyle.of(item.tab);
    final score = item.assignment?.controlScore;

    return InkWell(
      onTap: onTap,
      borderRadius: CardStyles.radius(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: CardStyles.radius(),
          boxShadow: CardStyles.shadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    isArabic ? control.controlsNameAr : control.controlsNameEn,
                    style: CardStyles.value(14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (score != null) ...[
                  SizedBox(width: 8.w),
                  GrcScoreBadge(score: score),
                ],
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              '${S.of(context).policyName}: ${isArabic ? item.policy.policyNameAr : item.policy.policyNameEn}',
              style: CardStyles.label(12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${S.of(context).dueDate}: ${_dueDateFormat.format(control.endDate)}',
                  style: CardStyles.label(12).copyWith(
                    color: item.tab == AssignmentControlTab.overdue
                        ? Colors.red
                        : null,
                  ),
                ),
                GrcStatusPill(label: grcTr(context, item.tab.label), color: style.color, icon: style.icon),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
