/// Module: GRC / Approvals (Department Manager)
///
///*************************** FILE INFO ****************************///
/// File Name: approval_details_sections.dart
/// Purpose: The building blocks of the Approvals "Request Details" screen
///          (MAGDY → "MAIN PAGE : Approvals"), each drawn the way the design
///          lays it out at 375 (mobile), 768 (tablet) and 1024 (desktop):
///            * [ApprovalPolicyDetailsCard]
///            * [ApprovalControlDetailsCard]
///            * [ApprovalSectionHeader]      (Approvals | Inquires switch)
///            * [ApprovalSubmissionCard]     (one submission + decision)
///            * [ApprovalInquiriesCard]      (Inquiries And Comments thread)
///            * [ApprovalStatusPill] / [ApprovalOutcomeBadge]
///            * [ApprovalDecisionButtons]    (Reject / Approve)
///          Built only from core/custom widgets: customButtonWithSvg (6),
///          CustomSegmentedTabs (9), CustomSvgImage (32), CardStyles (16),
///          ProductWarrantyCard (22), UniversalCommentSection (36) and the
///          ResponsiveHelper breakpoints (38).
/// Author: Knowticed Plus team
/// Created: 16/9/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/22-custom_uploaded_document_card.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/36-custom_comment_widget.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/custom/52-custom_upload_document.dart'
    show fileNameOf;
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/9-filter_tab_with_container.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/approval/domain/entities/approval_item.dart';
import 'package:knowticed_plus/features/grc/approval/domain/entities/approval_status.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/entities/assignment_control_status.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/entities/submission_history_entry.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_status.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_document_launcher.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_l10n.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_messaging.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_button_loading_placeholder.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_person_profile_card.dart'
    show GrcAvatarName;
import 'package:knowticed_plus/features/grc/shared/widgets/grc_submitter_row.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/grc/shared/constants/grc_firebase_paths.dart';

// ─────────────────────────────────────────────────────────────────────────
// Assets
// ─────────────────────────────────────────────────────────────────────────

/// SVGs the Approvals screens draw. The approve / reject circles keep their
/// own fill colours (green / red with a white glyph), so callers pass no
/// `svgColor` for them.
abstract class ApprovalAssets {
  static const String approve =
      'assets/icons_assets/data_grc_assets/images_success.svg';
  static const String reject =
      'assets/icons_assets/main_icons_assets/status_blocked_circle_red.svg';
  static const String rejectionPulse =
      'assets/icons_assets/main_icons_assets/status_pulse_line.svg';
  static const String rejectionTitle =
      'assets/icons_assets/main_icons_assets/prohibited_circle.svg';
}

/// Shared "Label: value" text used everywhere on the details cards.
Widget approvalLabelValue(
  String label,
  String value, {
  double labelSize = 12,
  double valueSize = 12,
  Color? valueColor,
  Color? labelColor,
  int? maxLines,
}) {
  return Text.rich(
    TextSpan(
      children: [
        TextSpan(
          text: '$label: ',
          style: CardStyles.label(labelSize).copyWith(color: labelColor),
        ),
        TextSpan(
          text: value,
          style: CardStyles.value(valueSize).copyWith(color: valueColor),
        ),
      ],
    ),
    maxLines: maxLines,
    overflow: maxLines == null ? null : TextOverflow.ellipsis,
  );
}

/// Colour the design gives a Control's status text ("Active" in green).
Color approvalControlStatusColor(ControlStatus status) {
  switch (status) {
    case ControlStatus.active:
      return AppColors.green;
    case ControlStatus.scheduled:
      return AppColors.orange;
    case ControlStatus.inactive:
    case ControlStatus.expired:
      return AppColors.red;
    case ControlStatus.draft:
    case ControlStatus.unassigned:
      return AppColors.secondaryText;
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Status pill / outcome badge
// ─────────────────────────────────────────────────────────────────────────

/// class name: [ApprovalOutcomeBadge]
///
/// purpose: the white, coloured-border "(icon) Approved" / "(icon) Rejected"
///          badge. [large] is the one at the foot of a submission on the
///          details page (≈200×36, 150 wide on a phone); the small one sits
///          on the list cards (100×24).
class ApprovalOutcomeBadge extends StatelessWidget {
  final String label;
  final Color color;
  final String image;
  final bool large;

  const ApprovalOutcomeBadge({
    super.key,
    required this.label,
    required this.color,
    required this.image,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = screenSizeOf(context) == ScreenSize.mobile;
    final double iconSize = large ? 24.sp : 14.sp;
    return customButtonWithSvg(
      title: label,
      function: () {},
      textStyle: (large
              ? StyleText.fontSize16Weight400
              : StyleText.fontSize10Weight400)
          .copyWith(color: color),
      color: AppColors.card,
      image: image,
      widthImage: iconSize,
      heightImage: iconSize,
      space: large ? 10.sp : 6.sp,
      colorBorder: color,
      fixedWidth: large ? (isMobile ? 150.sp : 200.sp) : 100.sp,
      fixedHeight: large ? 36.sp : 24.sp,
      fixedRadius: large ? 8.r : 4.r,
    );
  }
}

/// class name: [ApprovalStatusPill]
///
/// purpose: [ApprovalOutcomeBadge] for an [ApprovalStatus]. Pending has no
///          badge in the design, so it falls back to an orange label-only one
///          for the few places that still want to show it.
class ApprovalStatusPill extends StatelessWidget {
  final ApprovalStatus status;
  final bool large;

  const ApprovalStatusPill({super.key, required this.status, this.large = false});

  @override
  Widget build(BuildContext context) {
    final String label = grcTr(context, status.value);
    switch (status) {
      case ApprovalStatus.approved:
        return ApprovalOutcomeBadge(
          label: label,
          color: AppColors.green,
          image: ApprovalAssets.approve,
          large: large,
        );
      case ApprovalStatus.rejected:
        return ApprovalOutcomeBadge(
          label: label,
          color: AppColors.red,
          image: ApprovalAssets.reject,
          large: large,
        );
      case ApprovalStatus.pending:
        return ApprovalOutcomeBadge(
          label: label,
          color: AppColors.orange,
          image: '',
          large: large,
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────
// People + Message
// ─────────────────────────────────────────────────────────────────────────

/// Yellow "Message" button. Icon-only (38×38) on a phone, labelled
/// (≈100×30) on tablet / desktop.
Widget approvalMessageButton(
  BuildContext context,
  String email, {
  required bool withTitle,
}) {
  return customButtonWithSvg(
    title: withTitle ? S.of(context).message : '',
    function: () => openGrcChat(context, email),
    textStyle:
        StyleText.fontSize12Weight400.copyWith(color: AppColors.textButton),
    color: AppColors.primary,
    image: CardSvg.message,
    widthImage: 18.sp,
    heightImage: 18.sp,
    space: 8.sp,
    colorBorder: AppColors.transparent,
    svgColor: AppColors.textButton,
    fixedWidth: withTitle ? 100.sp : 30.sp,
    fixedHeight: 30.sp,
  );
}

/// How an [ApprovalPersonLine] places its Message button.
enum ApprovalMessagePlacement {
  /// Icon-only button pushed to the trailing edge (mobile).
  trailingIcon,

  /// Labelled button right after the name (tablet/desktop Module Owner).
  inline,

  /// Labelled button under the avatar + name (tablet/desktop Control
  /// Owner / Control Champion).
  below,
}

/// class name: [ApprovalPersonLine]
///
/// purpose: "Label: (avatar) Name  [Message]" row for the Module Owner,
///          Control Owner and Control Champion.
class ApprovalPersonLine extends StatelessWidget {
  final String label;
  final String? email;
  final ApprovalMessagePlacement placement;
  final double labelSize;

  const ApprovalPersonLine({
    super.key,
    required this.label,
    required this.email,
    required this.placement,
    this.labelSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    final String email = this.email ?? '';
    if (email.isEmpty) {
      return approvalLabelValue(label, '-', labelSize: labelSize);
    }
    final Widget labelText =
        Text('$label: ', style: CardStyles.label(labelSize));
    final Widget person = GrcAvatarName(
      email: email,
      avatarRadius: 15,
      style: CardStyles.value(12),
    );

    switch (placement) {
      case ApprovalMessagePlacement.trailingIcon:
        return Row(
          children: [
            labelText,
            Flexible(child: person),
            SizedBox(width: 10.w),
            const Spacer(),
            approvalMessageButton(context, email, withTitle: false),
          ],
        );
      case ApprovalMessagePlacement.inline:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            labelText,
            Flexible(child: person),
            SizedBox(width: 30.w),
            approvalMessageButton(context, email, withTitle: true),
          ],
        );
      case ApprovalMessagePlacement.below:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 6.sp),
              child: labelText,
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  person,
                  SizedBox(height: 8.h),
                  approvalMessageButton(context, email, withTitle: true),
                ],
              ),
            ),
          ],
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Card shell + score chip + titles
// ─────────────────────────────────────────────────────────────────────────

class _WhiteCard extends StatelessWidget {
  final List<Widget> children;
  const _WhiteCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: CardStyles.radius(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

/// "Policy Details" / "Control Details" heading above a card.
class ApprovalSectionTitle extends StatelessWidget {
  final String title;
  const ApprovalSectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: StyleText.fontSize16Weight400.copyWith(color: AppColors.text),
    );
  }
}

/// Grey "Score:100" chip (number in green) on the Control Details card.
class ApprovalScoreChip extends StatelessWidget {
  final double score;
  const ApprovalScoreChip({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 6.sp),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: CardStyles.radius(),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '${S.of(context).score}:',
              style: CardStyles.value(14),
            ),
            TextSpan(
              text: score.toInt().toString(),
              style: CardStyles.value(14).copyWith(color: AppColors.green),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _lastEdit(BuildContext context, DateTime date, String locale) {
  return approvalLabelValue(
    S.of(context).lastEdit,
    DateFormat('d MMM yyyy', locale).format(date),
    labelSize: 8,
    valueSize: 8,
  );
}

// ─────────────────────────────────────────────────────────────────────────
// Policy Details
// ─────────────────────────────────────────────────────────────────────────

/// class name: [ApprovalPolicyDetailsCard]
///
/// purpose: the Policy Details card.
///   * 1024: Policy Number + Last Edit / description / Weight | Module
///           Owner + Message / Start | End | document.
///   * 768:  Policy Name / description / Module Owner + Message /
///           Weight | Number / Start over End | document.
///   * 375:  Policy Number + Last Edit / description / Module Owner + icon /
///           Weight / Start / End / document (full width).
class ApprovalPolicyDetailsCard extends StatelessWidget {
  final ApprovalItem item;
  final String? moduleOwnerEmail;
  final bool isArabic;

  const ApprovalPolicyDetailsCard({
    super.key,
    required this.item,
    required this.moduleOwnerEmail,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final ScreenSize size = screenSizeOf(context);
    final policy = item.policy;
    final String locale = isArabic ? 'ar' : 'en';
    final DateFormat df = DateFormat('d MMM yyyy', locale);
    final String number = isArabic ? policy.policyNumberAr : policy.policyNumberEn;
    final String? document =
        isArabic ? policy.policyDocumentAr : policy.policyDocumentEn;
    final bool hasDocument = document != null && document.isNotEmpty;
    final double big = size == ScreenSize.mobile ? 12 : 14;

    Widget documentCard({double? width}) => ProductWarrantyCard(
          title: '',
          width: width,
          fileName: fileNameOf(document!),
          date: '${s.uploadedOn}: ${df.format(policy.lastModifiedDate)}',
          onTapFile: () => openGrcDocument(document!),
        );

    final Widget description = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(s.policyDescription, style: CardStyles.label(big)),
        SizedBox(height: 4.h),
        Text(
          isArabic ? policy.policyDescriptionAr : policy.policyDescriptionEn,
          style: CardStyles.value(size == ScreenSize.mobile ? 12 : 10)
              .copyWith(height: size == ScreenSize.mobile ? 2 : 1.8),
        ),
      ],
    );

    final Widget numberLine = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: approvalLabelValue(s.policyNumber, number,
              labelSize: big, valueSize: big),
        ),
        _lastEdit(context, policy.lastModifiedDate, locale),
      ],
    );

    final Widget weight = approvalLabelValue(
        s.policyWeight,
        policy.policyWeight == policy.policyWeight.roundToDouble()
            ? policy.policyWeight.toInt().toString()
            : policy.policyWeight.toString(),
        labelSize: big, valueSize: big);
    final Widget start = approvalLabelValue(
        s.startDate, df.format(policy.startDate),
        labelSize: big, valueSize: big);
    final Widget end = approvalLabelValue(s.endDate, df.format(policy.endDate),
        labelSize: big, valueSize: big);

    final List<Widget> children = switch (size) {
      ScreenSize.desktop => [
          numberLine,
          SizedBox(height: 10.h),
          description,
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(child: weight),
              Expanded(
                child: ApprovalPersonLine(
                  label: s.moduleOwner,
                  email: moduleOwnerEmail,
                  placement: ApprovalMessagePlacement.inline,
                  labelSize: big,
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: start),
              Expanded(child: end),
              if (hasDocument) documentCard(width: 283.sp),
            ],
          ),
        ],
      ScreenSize.tablet => [
          Text(
            isArabic ? policy.policyNameAr : policy.policyNameEn,
            style: CardStyles.value(16),
          ),
          SizedBox(height: 10.h),
          description,
          SizedBox(height: 15.h),
          ApprovalPersonLine(
            label: s.moduleOwner,
            email: moduleOwnerEmail,
            placement: ApprovalMessagePlacement.inline,
            labelSize: big,
          ),
          SizedBox(height: 15.h),
          Row(
            children: [
              Expanded(child: weight),
              Expanded(
                child: approvalLabelValue(s.policyNumber, number,
                    labelSize: big, valueSize: big),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [start, SizedBox(height: 15.h), end],
                ),
              ),
              if (hasDocument) documentCard(width: 283.sp),
            ],
          ),
        ],
      ScreenSize.mobile => [
          numberLine,
          SizedBox(height: 10.h),
          description,
          SizedBox(height: 15.h),
          ApprovalPersonLine(
            label: s.moduleOwner,
            email: moduleOwnerEmail,
            placement: ApprovalMessagePlacement.trailingIcon,
            labelSize: big,
          ),
          SizedBox(height: 15.h),
          weight,
          SizedBox(height: 15.h),
          start,
          SizedBox(height: 15.h),
          end,
          if (hasDocument) ...[
            SizedBox(height: 15.h),
            documentCard(width: double.infinity),
          ],
        ],
    };

    return _WhiteCard(children: children);
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Control Details
// ─────────────────────────────────────────────────────────────────────────

/// class name: [ApprovalControlDetailsCard]
///
/// purpose: the Control Details card.
///   * 1024: Name + Score / Status / Description / Owner | Champion with a
///           labelled Message button under each.
///   * 768:  Name + Score / Description / Owner | Champion (Message under).
///   * 375:  Name + Score / Control Status / Control Description / Owner +
///           icon / Champion + icon.
class ApprovalControlDetailsCard extends StatelessWidget {
  final ApprovalItem item;
  final bool isArabic;

  const ApprovalControlDetailsCard({
    super.key,
    required this.item,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final ScreenSize size = screenSizeOf(context);
    final control = item.control;
    final assignment = item.assignmentControl;
    final double? score = assignment.controlScore;
    final bool isMobile = size == ScreenSize.mobile;
    final double text = isMobile ? 10 : 14;

    final Widget header = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            isArabic ? control.controlsNameAr : control.controlsNameEn,
            style: CardStyles.value(isMobile ? 14 : 16),
          ),
        ),
        if (score != null) ApprovalScoreChip(score: score),
      ],
    );

    final Widget status = approvalLabelValue(
      isMobile ? s.controlStatus : s.Status,
      grcTr(context, control.status.value),
      labelSize: isMobile ? 10 : 12,
      valueSize: isMobile ? 10 : 12,
      valueColor: approvalControlStatusColor(control.status),
    );

    final Widget description = approvalLabelValue(
      isMobile ? s.controlDescription : s.description,
      isArabic ? control.controlsDescriptionAr : control.controlsDescriptionEn,
      labelSize: isMobile ? 10 : 12,
      valueSize: text,
    );

    final ApprovalMessagePlacement placement = isMobile
        ? ApprovalMessagePlacement.trailingIcon
        : ApprovalMessagePlacement.below;

    final Widget owner = ApprovalPersonLine(
      label: s.controlOwner,
      email: assignment.controlOwner,
      placement: placement,
      labelSize: isMobile ? 10 : 12,
    );
    final Widget champion = ApprovalPersonLine(
      label: s.controlChampion,
      email: assignment.controlChampionEmail,
      placement: placement,
      labelSize: isMobile ? 10 : 12,
    );

    final List<Widget> children = [
      header,
      SizedBox(height: isMobile ? 15.h : 8.h),
      if (size != ScreenSize.tablet) ...[
        status,
        SizedBox(height: isMobile ? 15.h : 8.h),
      ],
      description,
      SizedBox(height: isMobile ? 15.h : 30.h),
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
    ];

    return _WhiteCard(children: children);
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Approvals | Inquires header
// ─────────────────────────────────────────────────────────────────────────

/// class name: [ApprovalSectionHeader]
///
/// purpose: "Approvals" / "Inquiries And Comments" title on the leading edge
///          and the white Approvals | Inquires switch on the trailing edge,
///          the title sitting on the baseline under the switch.
class ApprovalSectionHeader extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;

  const ApprovalSectionHeader({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool isMobile = screenSizeOf(context) == ScreenSize.mobile;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            selected == 0 ? s.approvals : s.inquiriesAndComments,
            style: (isMobile
                    ? StyleText.fontSize16Weight400
                    : StyleText.fontSize16Weight500)
                .copyWith(color: AppColors.text, fontSize: isMobile ? 18.sp : 20.sp),
          ),
        ),
        CustomSegmentedTabs(
          tabs: [s.approvals, s.inquires],
          selectedIndex: selected,
          onTabSelected: onChanged,
          containerColor: AppColors.card,
          unselectedColor: AppColors.card,
          selectedColor: AppColors.primary,
          selectedTextColor: AppColors.textButton,
          unselectedTextColor: AppColors.secondaryText,
          containerPadding: EdgeInsets.all(6.sp),
          tabHorizontalPadding: isMobile ? 8.sp : 20.sp,
          tabVerticalPadding: 6.sp,
          spacing: 6.sp,
          textStyle: StyleText.fontSize14Weight400,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Decision buttons
// ─────────────────────────────────────────────────────────────────────────

/// class name: [ApprovalDecisionButtons]
///
/// purpose: outlined "Reject" (red) and "Approve" (green). Two equal halves
///          on a phone, 150 wide each on the trailing edge otherwise.
///          [isSaving] swaps them for the shared loading placeholder.
class ApprovalDecisionButtons extends StatelessWidget {
  final VoidCallback onReject;
  final VoidCallback onApprove;
  final bool isSaving;

  const ApprovalDecisionButtons({
    super.key,
    required this.onReject,
    required this.onApprove,
    required this.isSaving,
  });

  Widget _button({
    required String title,
    required Color color,
    required String image,
    required VoidCallback onTap,
    required double width,
  }) {
    return customButtonWithSvg(
      title: title,
      function: onTap,
      textStyle: StyleText.fontSize16Weight400.copyWith(color: color),
      color: AppColors.card,
      image: image,
      widthImage: 24.sp,
      heightImage: 24.sp,
      space: 10.sp,
      colorBorder: color,
      fixedWidth: width,
      fixedHeight: 36.sp,
      fixedRadius: 8.r,
    );
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool isMobile = screenSizeOf(context) == ScreenSize.mobile;

    if (isSaving) {
      return Align(
        alignment: AlignmentDirectional.centerEnd,
        child: GrcButtonLoadingPlaceholder(
          width: isMobile ? double.infinity : 150.sp,
          height: 36.sp,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double gap = 15.sp;
        final double width = isMobile
            ? (constraints.maxWidth - gap) / 2
            : 150.sp;
        return Row(
          mainAxisAlignment:
              isMobile ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
          children: [
            _button(
              title: s.Reject,
              color: AppColors.red,
              image: ApprovalAssets.reject,
              onTap: onReject,
              width: width,
            ),
            SizedBox(width: gap),
            _button(
              title: s.Approve,
              color: AppColors.green,
              image: ApprovalAssets.approve,
              onTap: onApprove,
              width: width,
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// One submission
// ─────────────────────────────────────────────────────────────────────────

/// class name: [ApprovalSubmissionCard]
///
/// purpose: one entry of the champion's submission history — submitter,
///          date, document, notes, reasons of rejection, and at the foot
///          either the Reject / Approve pair (latest entry of a Pending
///          approval) or the outcome badge.
class ApprovalSubmissionCard extends StatelessWidget {
  final SubmissionHistoryEntry entry;
  final String championEmail;
  final bool showDecision;
  final bool isSaving;
  final VoidCallback onReject;
  final VoidCallback onApprove;
  final bool isArabic;

  /// The manager's decision on this approval. When set (the newest entry of
  /// an Approved / Rejected approval) the badge shows it instead of the
  /// assignment's workflow status, which reads "In Review" after an approve.
  final ApprovalStatus? approvalStatus;

  const ApprovalSubmissionCard({
    super.key,
    required this.entry,
    required this.championEmail,
    required this.showDecision,
    required this.isSaving,
    required this.onReject,
    required this.onApprove,
    required this.isArabic,
    this.approvalStatus,
  });

  Widget _outcome(BuildContext context) {
    if (approvalStatus != null && approvalStatus != ApprovalStatus.pending) {
      return ApprovalStatusPill(status: approvalStatus!, large: true);
    }
    final String label = grcTr(context, entry.status.label);
    switch (entry.status) {
      case AssignmentControlStatus.approved:
        return ApprovalOutcomeBadge(
          label: label,
          color: AppColors.green,
          image: ApprovalAssets.approve,
          large: true,
        );
      case AssignmentControlStatus.rejected:
        return ApprovalOutcomeBadge(
          label: label,
          color: AppColors.red,
          image: ApprovalAssets.reject,
          large: true,
        );
      default:
        final Color color =
            AssignmentControlStatusStyle.of(entry.status).color;
        return ApprovalOutcomeBadge(
          label: label,
          color: color,
          image: '',
          large: true,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final ScreenSize size = screenSizeOf(context);
    final bool isMobile = size == ScreenSize.mobile;
    final String locale = isArabic ? 'ar' : 'en';
    final String when =
        '${DateFormat('d MMM yyyy', locale).format(entry.submittedDate)} '
        '${s.at} '
        '${DateFormat('h:mm a', locale).format(entry.submittedDate)}';
    final double notes = size == ScreenSize.desktop ? 14 : 12;

    final Widget date = isMobile
        ? Text(when, style: CardStyles.label(12))
        : approvalLabelValue(s.submissionDate, when,
            labelSize: 10, valueSize: 10);

    final bool isRejected = entry.status == AssignmentControlStatus.rejected &&
        (entry.rejectionReason?.isNotEmpty ?? false);

    return _WhiteCard(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: GrcSubmitterRow(email: championEmail),
              ),
            ),
            SizedBox(width: 8.w),
            date,
          ],
        ),
        if (entry.document.isNotEmpty) ...[
          SizedBox(height: 10.h),
          ProductWarrantyCard(
            title: '',
            width: 200.sp,
            fileName: fileNameOf(entry.document),
            onTapFile: () => openGrcDocument(entry.document),
          ),
        ],
        if (entry.note.isNotEmpty) ...[
          SizedBox(height: 15.h),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${s.submissionNotes}: ',
                  style: CardStyles.label(notes),
                ),
                TextSpan(
                  text: entry.note,
                  style: CardStyles.value(notes).copyWith(height: 1.9),
                ),
              ],
            ),
          ),
        ],
        if (isRejected) ...[
          SizedBox(height: 15.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 5.sp),
                child: CustomSvgImage(
                  assetPath: ApprovalAssets.rejectionPulse,
                  width: 14.sp,
                  height: 12.sp,
                  color: AppColors.red,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${s.reasonsOfRejectionTitle}: ',
                        style:
                            CardStyles.value(notes).copyWith(color: AppColors.red),
                      ),
                      TextSpan(
                        text: entry.rejectionReason,
                        style: CardStyles.value(notes).copyWith(height: 1.9),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
        SizedBox(height: isMobile ? 30.h : 20.h),
        if (showDecision)
          ApprovalDecisionButtons(
            onReject: onReject,
            onApprove: onApprove,
            isSaving: isSaving,
          )
        else
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: _outcome(context),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Inquiries And Comments
// ─────────────────────────────────────────────────────────────────────────

/// class name: [ApprovalInquiriesCard]
///
/// purpose: the Inquires tab — the manager ↔ champion comment thread for
///          this approval, with file attachments and the "Write a Comment"
///          box, through the app's [UniversalCommentSection].
///          Stored under grc/{Module_ID}/Approvals/{Approval_ID}/Inquiries.
class ApprovalInquiriesCard extends StatelessWidget {
  final String moduleId;
  final String approvalId;

  const ApprovalInquiriesCard({
    super.key,
    required this.moduleId,
    required this.approvalId,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = screenSizeOf(context) == ScreenSize.mobile;
    return UniversalCommentSection(
      key: ValueKey<String>('approval-inquiries-$approvalId'),
      collectionPath:
          '${GrcFirebasePaths.modulesCollection}/$moduleId/Approvals/$approvalId/Inquiries',
      filterFields: const <String, dynamic>{},
      currentUserId: currentGrcUserEmail(),
      isExpandable: false,
      collapsedHeight: isMobile ? 340.h : 360.h,
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
