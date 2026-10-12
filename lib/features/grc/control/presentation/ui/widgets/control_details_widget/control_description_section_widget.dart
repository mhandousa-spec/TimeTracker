/// Module: GRC Policy Management
/// Description: Description header + text + Control Owner badge section
///              for the Control Details page, extracted from
///              ControlDetailsPage.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-21
/// Dependencies: flutter_bloc, OwnerCubit, GrcOwnerBadge
/// Revision History: 2026-07-21 - Initial creation (inline in
///                                control_details_page.dart)
///                   2026-07-28 - Split out into its own widget file
library;

/// ************************* FILE INFO *************************** ///
/// File Name: control_description_section_widget.dart
/// Purpose: Contains ControlDescriptionSectionWidget: the "Control
///          Description" label + Last Update date, the description text
///          itself, and the Control Owner badge below it.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 28/7/2026

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/entities/owner_entity.dart';
import 'package:knowticed_plus/features/grc/control_owner/presentation/controller/owner_cubit.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/widgets/policy_details_widget/grc_owner_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:knowticed_plus/generated/l10n.dart';

/// class name: [ControlDescriptionSectionWidget]
///
/// purpose: renders the Control Description header/text and, below it, the
///          Control Owner badge — pre-selected with whoever is already
///          assigned to this exact {Policy, Control} pair.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 28/7/2026
class ControlDescriptionSectionWidget extends StatelessWidget {
  final String descriptionEn;
  final String descriptionAr;
  final bool isArabic;
  final DateTime lastModifiedDate;
  final DateFormat dateFormat;
  final String policyId;
  final String controlId;

  const ControlDescriptionSectionWidget({
    super.key,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.isArabic,
    required this.lastModifiedDate,
    required this.dateFormat,
    required this.policyId,
    required this.controlId,
  });

  /// Every owner email assigned to this exact {Policy, Control} pair, in
  /// [owners]' original order. Mirrors AddEditControlPage's
  /// `_alreadyAssignedOwnerEmails`.
  List<String> _ownerEmailsForControl(List<OwnerEntity> owners) {
    return owners
        .where((o) => o.assigningControls
            .any((a) => a.policyId == policyId && a.controlId == controlId))
        .map((o) => o.ownerEmail)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Flexible on both: at 375 the label and the "Last Update"
            // stamp share a 345-wide line, and in Arabic either one can be
            // long enough to overflow a plain Row.
            Flexible(
              child: Text(
                S.of(context).controlDescription,
                style: StyleText.fontSize14Weight500
                    .copyWith(color: AppColors.secondaryText),
              ),
            ),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                '${S.of(context).lastUpdate}: ${dateFormat.format(lastModifiedDate)}',
                style: StyleText.fontSize12Weight400
                    .copyWith(color: AppColors.secondaryText),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
        Text(
          isArabic ? descriptionAr : descriptionEn,
          // GRC bug report p28/p34 "color": body text, like the policy
          // description, not the grey used for labels.
          style: StyleText.fontSize12Weight500
              .copyWith(color: AppColors.text),
        ),
        SizedBox(height: 10.h),
        BlocBuilder<OwnerCubit, OwnerState>(
          builder: (context, state) {
            final owners =
                state is OwnerListLoaded ? state.owners : const <OwnerEntity>[];
            return GrcOwnerBadge(
              label: 'Control Owner:',
              ownerEmails: _ownerEmailsForControl(owners),
            );
          },
        ),
      ],
    );
  }
}
