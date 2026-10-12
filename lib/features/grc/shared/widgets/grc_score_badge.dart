import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Small "Score: 100" pill (gray background, green number) shown next to a
/// Control's name once the Control Owner has scored it — used on the
/// Assignment Controls card/details page and the Approvals card.
class GrcScoreBadge extends StatelessWidget {
  final double score;

  const GrcScoreBadge({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${S.of(context).score}: ', style: CardStyles.label(12)),
          Text(
            score.toInt().toString(),
            style: CardStyles.value(12).copyWith(color: Colors.green),
          ),
        ],
      ),
    );
  }
}
