/// Module: settings / se7_app_info / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: feedback_request_details_view.dart
/// Purpose: The details PAGE of one filed Comment & Feedback request, opened
///          by tapping its card on the "Requested Feedback" tab.
/// Author: Knowticed Plus team
/// Created At: 21/9/2026 — replaces feedback_request_details_dialog.dart.
///
/// Figma (MESBAH, Settings section) has no frame for this screen yet, so it
/// follows the nearest designed sibling, the Requests "Request Details" page
/// (se6_requests/details_request.dart): a "Request Details" header with the
/// requested date on the trailing edge, one card for the content, and the
/// status as a 150.sp outlined pill on the trailing edge at the bottom.
///
/// On tablet / desktop it renders INSIDE the settings pane in place of the
/// request list ([FeedbackRequestDetailsView] + [onBack]); on a phone it is
/// pushed as its own route with the settings breadcrumb
/// ([openFeedbackRequestDetailsPage]).
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_date.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/domain/entities/app_feedback.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/presentation/ui/widgets/feedback_display.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

/// Phone: push the details as a full page under the settings breadcrumb.
Future<void> openFeedbackRequestDetailsPage(
  BuildContext context,
  FeedbackRequest request,
) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (BuildContext ctx) => Scaffold(
        backgroundColor: AppColors.background,
        body: SideFrameMasterServices(
          titleText: S.of(ctx).settings,
          secondTitle: S.of(ctx).commentsAndFeedbacks,
          thirdTitle: S.of(ctx).requestDetails,
          onFirstTap: () => Navigator.of(ctx).pop(),
          onSecondTap: () => Navigator.of(ctx).pop(),
          child: SingleChildScrollView(
            child: FeedbackRequestDetailsView(request: request),
          ),
        ),
      ),
    ),
  );
}

class FeedbackRequestDetailsView extends StatelessWidget {
  const FeedbackRequestDetailsView({
    super.key,
    required this.request,
    this.onBack,
  });

  final FeedbackRequest request;

  /// Shown as a back arrow before the header when set (the in-pane layout).
  /// The pushed phone page has the breadcrumb instead, so it passes null.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _header(context),
        SizedBox(height: 15.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(15.sp),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _titleRow(context),
              ..._detailsGrid(context),
              SizedBox(height: 15.h),
              _textBlock(context, S.of(context).reportBugs, request.body),
              if (request.details.stepsToReproduce.trim().isNotEmpty) ...<Widget>[
                SizedBox(height: 15.h),
                _textBlock(context, S.of(context).stepsToReproduce,
                    request.details.stepsToReproduce),
              ],
              if (request.attachments.isNotEmpty) ...<Widget>[
                SizedBox(height: 15.h),
                _label(S.of(context).attachments),
                SizedBox(height: 8.h),
                for (final FeedbackAttachment file in request.attachments)
                  _attachmentTile(file),
              ],
              SizedBox(height: 20.h),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: SizedBox(width: 150.sp, child: _statusPill(context)),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  // ── Header: back + "Request Details" …… "Requested Date: x" ─────────────
  Widget _header(BuildContext context) {
    final bool isArabic = Directionality.of(context) == TextDirection.rtl;
    return Row(
      children: <Widget>[
        if (onBack != null) ...<Widget>[
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(4.r),
            child: Padding(
              padding: EdgeInsets.all(4.sp),
              child: Icon(
                isArabic ? Icons.arrow_forward_ios : Icons.arrow_back_ios_new,
                size: 16.sp,
                color: AppColors.text,
              ),
            ),
          ),
          SizedBox(width: 6.w),
        ],
        Text(
          S.of(context).requestDetails,
          style: StyleText.fontSize16Weight600.copyWith(color: AppColors.text),
        ),
        const Spacer(),
        Text(
          '${S.of(context).requestedDate}: ',
          style: StyleText.fontSize12Weight400
              .copyWith(color: AppColors.secondaryText),
        ),
        Text(
          request.createdAt == null
              ? '—'
              : LocalizedDate.of(context, request.createdAt!),
          style: StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
        ),
      ],
    );
  }

  // ── Kind icon + label, priority on the trailing edge ────────────────────
  Widget _titleRow(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 30.sp,
          height: 30.sp,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(.15),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: CustomSvgImage(
            assetPath: 'assets/icons_assets/settings_assets/feedback_stamp.svg',
            width: 16.sp,
            height: 16.sp,
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            FeedbackDisplay.kindLabel(context, request.kind),
            style: StyleText.fontSize18Weight500.copyWith(color: AppColors.text),
          ),
        ),
        if (request.priority != null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 4.sp),
            decoration: BoxDecoration(
              color: AppColors.field,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text.rich(
              TextSpan(
                text: '${S.of(context).priority}: ',
                style: StyleText.fontSize12Weight400
                    .copyWith(color: AppColors.secondaryText),
                children: <InlineSpan>[
                  TextSpan(
                    text: FeedbackDisplay.priorityLabel(
                        context, request.priority!),
                    style: StyleText.fontSize12Weight500
                        .copyWith(color: AppColors.text),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ── The optional "more options" answers, two per row ────────────────────
  List<Widget> _detailsGrid(BuildContext context) {
    final S l = S.of(context);
    final FeedbackDetails d = request.details;
    final List<MapEntry<String, String>> cells = <MapEntry<String, String>>[
      if (d.module != null)
        MapEntry(l.module, FeedbackDisplay.moduleLabel(context, d.module!)),
      if (d.screenSection != null)
        MapEntry(l.screenSection,
            FeedbackDisplay.screenSectionLabel(context, d.screenSection!)),
      if (d.designIssue != null)
        MapEntry(l.designIssue,
            FeedbackDisplay.designIssueLabel(context, d.designIssue!)),
      if (d.logicIssue != null)
        MapEntry(l.logicIssue,
            FeedbackDisplay.logicIssueLabel(context, d.logicIssue!)),
      if (d.device != null)
        MapEntry(l.device, FeedbackDisplay.deviceLabel(context, d.device!)),
      if (d.softwareType != null)
        MapEntry(l.softwareType,
            FeedbackDisplay.softwareTypeLabel(context, d.softwareType!)),
      if (d.frequency != null)
        MapEntry(l.frequency,
            FeedbackDisplay.frequencyLabel(context, d.frequency!)),
    ];
    if (cells.isEmpty) return const <Widget>[];

    return <Widget>[
      SizedBox(height: 15.h),
      LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool twoColumns = constraints.maxWidth >= 420;
          final double gap = 12.sp;
          final double cellWidth = twoColumns
              ? (constraints.maxWidth - gap) / 2
              : constraints.maxWidth;
          return Wrap(
            spacing: gap,
            runSpacing: 10.h,
            children: <Widget>[
              for (final MapEntry<String, String> cell in cells)
                SizedBox(
                  width: cellWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _label(cell.key),
                      SizedBox(height: 6.h),
                      _valueBox(cell.value),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    ];
  }

  Widget _textBlock(BuildContext context, String label, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _label(label),
        SizedBox(height: 6.h),
        Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: 80.sp),
          padding: EdgeInsets.all(12.sp),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: SelectableText(
            text.trim().isEmpty ? '—' : text.trim(),
            style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
          ),
        ),
      ],
    );
  }

  Widget _label(String text) => Text(
        text,
        style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
      );

  Widget _valueBox(String value) => Container(
        width: double.infinity,
        height: 40.sp,
        alignment: AlignmentDirectional.centerStart,
        padding: EdgeInsets.symmetric(horizontal: 12.sp),
        decoration: BoxDecoration(
          color: AppColors.field,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
        ),
      );

  Widget _attachmentTile(FeedbackAttachment file) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(4.r),
        onTap: file.url.isEmpty
            ? null
            : () => launchUrl(Uri.parse(file.url),
                mode: LaunchMode.externalApplication),
        child: Container(
          height: 48.sp,
          padding: EdgeInsets.symmetric(horizontal: 12.sp),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Row(
            children: <Widget>[
              CustomSvgImage(
                assetPath: FeedbackDisplay.fileIcon(file.extension),
                width: 24.sp,
                height: 24.sp,
                color: FeedbackDisplay.iconNeedsTint(file.extension)
                    ? AppColors.text
                    : null,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  file.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: StyleText.fontSize14Weight400
                      .copyWith(color: AppColors.text),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _statusPill(BuildContext context) {
    final Color color = FeedbackDisplay.statusColor(request.status);
    return Container(
      height: 36.sp,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            FeedbackDisplay.statusLabel(context, request.status),
            style: StyleText.fontSize16Weight500.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
