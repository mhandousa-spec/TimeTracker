import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/36-custom_comment_widget.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:knowticed_plus/features/grc/shared/constants/grc_firebase_paths.dart';

/// class name: [MyAuditInquiriesCard]
///
/// purpose: the Inquires tab on the My Audit details page — the
///          owner ↔ champion comment thread for one audited control, with
///          file attachments and the "Write a Comment" box, through the
///          app's [UniversalCommentSection] (Figma MAGDY › My Audit ›
///          "Inquiries And Comments").
///          Stored under grc/{Module_ID}/My_Audit_Inquiries, one thread per
///          Policy_ID + Control_ID + Champion_Email.
class MyAuditInquiriesCard extends StatelessWidget {
  final String moduleId;
  final String policyId;
  final String controlId;
  final String championEmail;

  const MyAuditInquiriesCard({
    super.key,
    required this.moduleId,
    required this.policyId,
    required this.controlId,
    required this.championEmail,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = screenSizeOf(context) == ScreenSize.mobile;
    return UniversalCommentSection(
      key: ValueKey<String>(
          'my-audit-inquiries-$policyId-$controlId-$championEmail'),
      collectionPath: '${GrcFirebasePaths.modulesCollection}/$moduleId/My_Audit_Inquiries',
      filterFields: <String, dynamic>{
        'Policy_ID': policyId,
        'Control_ID': controlId,
        'Champion_Email': championEmail,
      },
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
