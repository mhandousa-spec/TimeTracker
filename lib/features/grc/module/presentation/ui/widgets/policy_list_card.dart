/// Module: GRC / module / presentation / ui / widgets
///
/// ************************* FILE INFO *************************** ///
/// File Name: policy_list_card.dart
/// Purpose: The Policies tab's CARD view — the row the design draws for each
///          policy, and the other half of the card/table toggle beside
///          GrcPolicyTableView.
/// Author: Knowticed Plus team
/// Created At: 14/9/2026
///
/// WHY THIS EXISTS RATHER THAN ModuleInfoCard
/// ------------------------------------------
/// The tab used to render each policy through the shared
/// `43-custom_module_info_card.dart`, which is built for a GRC MODULE: one
/// image, a title, a couple of label/value rows, a score chip and a footer.
/// A policy card in the design carries seven facts and a department chip row,
/// so three quarters of it had nowhere to go and simply was not drawn.
///
/// The design's layout, which this reproduces (MAGDY, mobile card
/// `869:136208`, measured at 375):
///
///   ┌──────┐  Policy Name                              Status: Active
///   │Score │  No of Controls: 3      Weight: 10
///   │ 100  │  Last Edit: 28 Dec 2023  Creation Date: 28 Dec 2023
///   └──────┘
///   Departments
///   [ Customer Service ] [ HR ] [ Marketing ] [ Design ]
///
/// Three things in there are easy to get wrong, and were:
///
/// * **Departments is full width.** The label sits at the CARD's left
///   padding (x=10 of 345), not indented under the title in the column
///   beside the score box (x=70). So it is a sibling of that Row, not a
///   child of it.
/// * **Status stays on the title's line at every size**, trailing-aligned.
///   It used to drop under the name on a phone, which is not what the 375
///   frame draws.
/// * **The facts are a 2x2 grid, not a Wrap**: No of Controls | Weight on
///   one line, Last Edit | Creation Date on the next — in that order. A Wrap
///   reflowed them into whatever order the widths allowed.
///
/// `No of Controls` and `Departments` are not on PolicyEntity — Controls are
/// a subcollection — so they arrive separately as a [PolicyControlsSummary]
/// that PolicyCubit fetches after the list loads. Until it lands (or if that
/// read fails) both lines read "-" rather than a wrong zero.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_date.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_status.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/controller/policy_cubit.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_l10n.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// class name: [PolicyListCard]
///
/// purpose: one policy, drawn the way the design draws it.
///
/// authors: Knowticed Plus team
///
/// created at: 14/9/2026
class PolicyListCard extends StatelessWidget {
  const PolicyListCard({
    super.key,
    required this.policy,
    this.summary,
    this.showScore = true,
    this.onTap,
  });

  final PolicyEntity policy;

  /// Controls count + departments, once PolicyCubit's second pass has them.
  /// Null means "not loaded / could not be read", NOT "zero".
  final PolicyControlsSummary? summary;

  /// Policy_Score permission. When false the score block is dropped entirely,
  /// the same way ModuleInfoCard hides its chip, rather than blanked.
  final bool showScore;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = screenSizeOf(context) == ScreenSize.mobile;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10.r),
          // border: Border.all(color: AppColors.borderCard),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Score box + the title/status/facts column beside it.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (showScore) ...<Widget>[
                  _scoreBlock(context, isMobile),
                  SizedBox(width: 10.w),
                ],
                Expanded(child: _headerAndFacts(context)),
              ],
            ),
            SizedBox(height: 10.h),
            // Departments spans the whole card, underneath the score box
            // rather than beside it -- see the diagram above.
            _departments(context),
          ],
        ),
      ),
    );
  }

  // ── Score block ─────────────────────────────────────────────────────────

  /// The bordered square on the leading edge.
  ///
  /// A score of 0 (no approved evidence yet) is shown as "-" rather than
  /// "0", per product request. Any other value prints as a whole number.
  /// Hiding the block entirely is what the Policy_Score permission does,
  /// via [showScore].
  Widget _scoreBlock(BuildContext context, bool isMobile) {
    // 50x50 in the 375 frame; the wider frames draw it bigger.
    final double side = isMobile ? 55.sp : 76.sp;

    return Container(
      width: side,
      height: side,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.field,
        // 4, not 8 -- the 375 frame's score rectangle is
        // `cornerRadius(4)` with a 1.5 stroke.
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(width: 1.5, color: AppColors.primary),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            S.of(context).score,
            style: StyleText.fontSize12Weight600
                .copyWith(color: AppColors.secondaryText),
          ),
          SizedBox(height: 2.h),
          Text(
            policy.score.round() == 0
                ? '-'
                : LocalizedNumber.digits(
                    context, policy.score.toStringAsFixed(0)),
            style: StyleText.fontSize20Weight500.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  // ── Everything to the side of it ────────────────────────────────────────

  /// Everything to the side of the score box: the title/status line and the
  /// 2x2 fact grid under it.
  Widget _headerAndFacts(BuildContext context) {
    final bool isArabic = context.isArabic;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Title and status share a line at every size. The title is the
        // flexible one, so a long policy name ellipsises rather than
        // squeezing the status out.
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: _title(context, isArabic)),
            SizedBox(width: 8.w),
            _status(context),
          ],
        ),
        SizedBox(height: context.isPhone ? 2.sp : 8.h),
        _factRow(
          left: _fact(
            context,
            S.of(context).noOfControls,
            summary == null
                ? '-'
                : LocalizedNumber.of(context, summary!.controlCount),
          ),
          right: _fact(
            context,
            S.of(context).weight,
            LocalizedNumber.digits(
                context, policy.policyWeight.toStringAsFixed(0)),
          ),
        ),
        SizedBox(height: context.isPhone ? 2.sp : 8.h),
        _factRow(
          left: _fact(
            context,
            S.of(context).lastEdit,
            // A Draft has not been published yet, so its dates show as '-'.
            policy.status == PolicyStatus.draft
                ? '-'
                : LocalizedDate.of(context, policy.lastModifiedDate,
                    pattern: 'd MMM yyyy'),
          ),
          right: _fact(
            context,
            S.of(context).creationDate,
            policy.status == PolicyStatus.draft
                ? '-'
                : LocalizedDate.of(context, policy.createdAt,
                    pattern: 'd MMM yyyy'),
          ),
        ),
      ],
    );
  }

  /// One line of the fact grid.
  ///
  /// flex 2:3 because the design's second column starts a little under
  /// halfway across the card (x=170 of 345) rather than at the midpoint of
  /// the space beside the score box -- an even split pushes "Weight" and
  /// "Creation Date" visibly too far right.
  Widget _factRow({required Widget left, required Widget right}) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(flex: 2, child: left),
          SizedBox(width: 8.w),
          Expanded(flex: 3, child: right),
        ],
      );

  /// The full-width "Departments" label and its chip row.
  Widget _departments(BuildContext context) {
    final List<String> departments = summary?.departments ?? const <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          S.of(context).departments,
          style: StyleText.fontSize12Weight600
              .copyWith(color: AppColors.secondaryText),
        ),
        SizedBox(height: 6.h),
        if (departments.isEmpty)
          Text(
            '-',
            style:
                StyleText.fontSize12Weight600.copyWith(color: AppColors.text),
          )
        else
          // 8 between chips, 10 between rows -- the gaps the 375 frame
          // measures between its two chip rows.
          Wrap(
            spacing: 8.w,
            runSpacing: 10.h,
            children: <Widget>[
              for (final String department in departments)
                _departmentChip(context, department),
            ],
          ),
      ],
    );
  }

  Widget _title(BuildContext context, bool isArabic) => Text(
        policy.localizedName(isArabic: isArabic),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: context.isPhone ?StyleText.fontSize14Weight500
            .copyWith(fontWeight: FontWeight.w600, color: AppColors.text):  StyleText.fontSize16Weight500

            .copyWith(fontWeight: FontWeight.w600, color: AppColors.text),
      );

  Widget _status(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            '${S.of(context).status}: ',
            style: context.isPhone ? StyleText.fontSize10Weight600
                .copyWith(color: AppColors.secondaryText) : StyleText.fontSize12Weight600
                .copyWith(color: AppColors.secondaryText),
          ),
          Text(
            grcTr(context, policy.status.value),
            style:context.isPhone ? StyleText.fontSize10Weight600
      .copyWith(color: _statusColor(policy.status)) : StyleText.fontSize12Weight600
                .copyWith(color: _statusColor(policy.status)),
          ),
        ],
      );

  /// One "Label: value" pair, label muted and value in the body colour, the
  /// way the design separates the two.
  Widget _fact(BuildContext context, String label, String value) => RichText(
        text: TextSpan(
          children: <InlineSpan>[
            TextSpan(
              text: '$label: ',
              style: context.isPhone ? StyleText.fontSize10Weight600
                  .copyWith(color: AppColors.secondaryText) :  StyleText.fontSize12Weight600
                  .copyWith(color: AppColors.secondaryText),
            ),
            TextSpan(
              text: value,
              style: context.isPhone ? StyleText.fontSize10Weight600
                  .copyWith(color: AppColors.text) : StyleText.fontSize12Weight600
                  .copyWith(color: AppColors.text),
            ),
          ],
        ),
      );

  /// The design gives each department chip its own colour. There is no
  /// per-department colour stored anywhere, so the colour is derived from the
  /// name: the same department is always the same colour, across cards and
  /// across sessions, without inventing a field to hold it.
  Widget _departmentChip(BuildContext context, String department) {
    final Color color = _departmentColor(department);

    return Container(
      // 25 tall with 10 of horizontal padding, per the 375 frame.
      height: 25.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: color),
      ),
      // Center(widthFactor: 1), NOT `alignment: Alignment.center` on the
      // Container.
      //
      // A Container given an alignment and no width EXPANDS to its incoming
      // constraints, so inside the Wrap every chip claimed the full card
      // width and each one landed on a line of its own. Center with a
      // widthFactor shrink-wraps horizontally while still centring the label
      // in the 25 of height.
      child: Center(
        widthFactor: 1,
        child: Text(
          grcTr(context, department),
          style: StyleText.fontSize12Weight600.copyWith(color: AppColors.text),
        ),
      ),
    );
  }

  Color _departmentColor(String department) {
    final List<Color> palette = <Color>[
      AppColors.primary,
      AppColors.green,
      AppColors.orange,
      AppColors.red,
    ];
    int hash = 0;
    for (final int unit in department.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return palette[hash % palette.length];
  }

  Color _statusColor(PolicyStatus status) {
    switch (status) {
      case PolicyStatus.active:
        return AppColors.green;
      case PolicyStatus.inactive:
        return AppColors.orange;
      case PolicyStatus.scheduled:
        return AppColors.orange;
      case PolicyStatus.expired:
        return AppColors.red;
      case PolicyStatus.draft:
      case PolicyStatus.removed:
        return AppColors.colorGrey;
    }
  }
}
