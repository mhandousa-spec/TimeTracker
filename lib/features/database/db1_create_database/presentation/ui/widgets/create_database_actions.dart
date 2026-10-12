/// Module: database / db1_create_database / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: create_database_actions.dart
/// Purpose: Declares `CreateDatabaseActions`.
/// Author: Knowticed Plus team
/// Created at: 15/8/2026
///
/// The Discard / Create row under the card. Figma nodes 7398:6211 (Discard)
/// and 7398:6172 (Next, landscape) / 7398:6257 (Create, portrait).
///
/// The primary label differs between the two Figma frames — "Next" on the
/// landscape frame, "Create" on the portrait one. That is a flow difference,
/// not a layout one: "Next" belongs to the multi-step variant that continues
/// into table creation. It is exposed as [primaryLabel] so the caller picks,
/// instead of the button quietly changing meaning with the device rotation.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/create_database_metrics.dart';

class CreateDatabaseActions extends StatelessWidget {
  const CreateDatabaseActions({
    super.key,
    required this.metrics,
    required this.discardLabel,
    required this.primaryLabel,
    required this.onDiscard,
    required this.onPrimary,
    this.isSubmitting = false,
    this.isPrimaryEnabled = true,
    this.primaryDisabledHint,
  });

  final CreateDatabaseMetrics metrics;
  final String discardLabel;
  final String primaryLabel;
  final VoidCallback onDiscard;
  final VoidCallback onPrimary;
  final bool isSubmitting;

  /// Whether the screen has everything the primary button needs. ADDED
  /// 16/8/2026.
  ///
  /// Defaults to true so the db2 and db3 screens that share this row are
  /// unaffected — only the create wizard gates its buttons so far.
  ///
  /// The DISCARD side is never gated. It is the way out of a half-filled form,
  /// which is exactly the state this flag describes, so disabling it would trap
  /// the user on the screen the rule is meant to protect.
  final bool isPrimaryEnabled;

  /// One line naming what is still missing, shown under the row while the
  /// primary button is greyed out. ADDED 16/8/2026.
  ///
  /// A grey button with no explanation is the worst state this row can be in:
  /// the user has filled every field they can SEE — the tabbed review only
  /// shows one department's rule at a time — and the screen answers by doing
  /// nothing at all. Null keeps the old silent behaviour for callers that have
  /// nothing specific to say.
  final String? primaryDisabledHint;

  @override
  Widget build(BuildContext context) {
    // Two different reasons to be untappable, and they are NOT the same:
    // a write in flight must swallow taps, an unfinished form must explain
    // itself. Both grey the button; only the first blocks the callback.
    final bool blocked = isSubmitting || !isPrimaryEnabled;
    final bool showHint =
        !isSubmitting && !isPrimaryEnabled && primaryDisabledHint != null;

    final Widget row = Row(
      // Discard sits at the leading edge, the primary at the trailing edge.
      // spaceBetween rather than two Aligns so the row still reads correctly
      // when the locale flips it.
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        customButton(
          title: discardLabel,
          function: isSubmitting ? () {} : onDiscard,
          // Figma 150pt, wider than ButtonSizing's 135.sp tablet default.
          // Height and radius still come from ButtonSizing.
          exactWidth: metrics.actionButtonWidth,
          color: AppColors.darkGrey,
          textColor: AppColors.text,
        ),
        customButton(
          title: primaryLabel,
          // A DISABLED-BUT-NOT-SUBMITTING PRIMARY STILL FIRES (16/8/2026).
          //
          // It used to be a no-op, which meant the handler behind it — the one
          // holding the "here is what is missing" dialog — could never run. The
          // button was grey, the tap did nothing, and the only explanation in
          // the codebase was unreachable. The handler's own guard is what keeps
          // this safe: it checks the same condition before writing anything.
          //
          // `isSubmitting` still swallows the tap, because there the answer is
          // "wait", not "here is what to fix".
          function: isSubmitting ? () {} : onPrimary,
          exactWidth: metrics.actionButtonWidth,
          color: blocked ? AppColors.greyDark : AppColors.primary,
          textColor: blocked ? AppColors.black : AppColors.textButton,
        ),
      ],
    );

    if (!showHint) return row;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        row,
      ],
    );
  }
}
