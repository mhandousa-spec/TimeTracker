/// Module: time_tracker / tt9_requests / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: request_comments_section.dart
/// Purpose: Declares `RequestCommentsSection` — "Inquiries And Comments"
///          with Expand / Hide: the thread, Edit / Delete on one's own
///          comments, and "Write a Comment".
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Inventory §C (`661:30544`, `661:30811`): bubbles with the author's
/// avatar, name and job title, the text, the date "24 Jan 2024 At 12:00 PM";
/// one's own comments sit on the end side with Edit / Delete. Writing needs
/// `Comment_On_Requests` (own request) or `Comment_On_Approvals` (from the
/// Approvals tab) — `RequestActionsCubit.mayComment`. Delete is soft and
/// confirmed (destructive). The section expands / collapses with
/// `ImplicitExpand`; it starts open when the thread has comments. The page
/// owns the text controllers (playbook §3).
/// Updated: 9/10/2026 - code review: Material icons → the app's SVG line
/// icons (`TtAssets` / `TtGlyph`) where an equivalent asset exists.
/// Updated: 9/10/2026 - data model (owner, 9 Oct): the thread is the
/// `Requests/{id}/Comments` sub-collection, streamed by its own
/// `RequestCommentsCubit` (over `RequestActionsCubit.watchComments`), merged
/// with an old request's embedded comments (read-only until the migration —
/// `RequestCommentRules.thread`). Add / Edit / Delete, Expand / Hide and the
/// permission rules are unchanged; a comment's files (optional
/// `Attachments`) open from the bubble.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_comment_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/request_actions_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/request_comments_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/requests_state.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/features/time_tracker/tt9_requests/presentation/ui/widgets/request_flows.dart';
import 'package:knowticed_plus/features/time_tracker/tt9_requests/presentation/ui/widgets/request_text.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';

class RequestCommentsSection extends StatefulWidget {
  const RequestCommentsSection({
    super.key,
    required this.request,
    required this.state,
    required this.asApprover,
  });

  final TimeTrackerRequest request;
  final RequestsState state;
  final bool asApprover;

  @override
  State<RequestCommentsSection> createState() => _RequestCommentsSectionState();
}

class _RequestCommentsSectionState extends State<RequestCommentsSection> {
  final TextEditingController _new = TextEditingController();
  final TextEditingController _edit = TextEditingController();
  /// null = not toggled yet: open when the thread has comments.
  bool? _expanded;
  String _editingId = '';
  bool _sending = false;

  @override
  void dispose() {
    _new.dispose();
    _edit.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final String text = _new.text.trim();
    if (text.isEmpty || _sending) return;
    HapticController.medium();
    setState(() => _sending = true);
    final bool ok = await context
        .read<RequestActionsCubit>()
        .addComment(widget.request, text, asApprover: widget.asApprover);
    if (!mounted) return;
    setState(() => _sending = false);
    if (ok) _new.clear();
    await RequestFlows.afterAction(context);
  }

  Future<void> _saveEdit(RequestComment c) async {
    final String text = _edit.text.trim();
    if (text.isEmpty) return;
    final bool ok = await context
        .read<RequestActionsCubit>()
        .editComment(widget.request, c.id, text, asApprover: widget.asApprover);
    if (!mounted) return;
    if (ok) setState(() => _editingId = '');
    await RequestFlows.afterAction(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RequestCommentsCubit>(
      create: (BuildContext c) =>
          RequestCommentsCubit(source: c.read<RequestActionsCubit>().watchComments)..watch(widget.request.id),
      child: BlocBuilder<RequestCommentsCubit, RequestCommentsState>(
        builder: (BuildContext context, RequestCommentsState thread) => _section(context, thread),
      ),
    );
  }

  Widget _section(BuildContext context, RequestCommentsState thread) {
    final S s = S.of(context);
    final List<RequestComment> comments =
        RequestCommentRules.thread(thread.comments, legacy: widget.request.legacyComments);
    final bool expanded = _expanded ?? comments.isNotEmpty;
    final bool canWrite =
        context.read<RequestActionsCubit>().mayComment(widget.request, asApprover: widget.asApprover);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(s.timeTrackerInquiriesAndComments,
                  style: StyleText.fontSize18Weight500.copyWith(color: AppColors.text)),
            ),
            GestureDetector(
              key: const ValueKey<String>('requestCommentsToggle'),
              onTap: () {
                HapticController.low();
                setState(() => _expanded = !expanded);
              },
              child: Text(
                expanded ? s.hide : s.expand,
                style: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.blue,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.blue,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ImplicitExpand(
          expanded: expanded,
          child: TtFormCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (comments.isEmpty && thread.isLoading)
                  const Center(child: CircleProgressMaster())
                else if (comments.isEmpty)
                  Text(
                    thread.status == RequestCommentsStatus.failure ? s.timeTrackerLoadError : s.timeTrackerNoComments,
                    key: const ValueKey<String>('requestCommentsEmpty'),
                    style: StyleText.fontSize12Weight400.copyWith(
                      color: thread.status == RequestCommentsStatus.failure ? AppColors.red : AppColors.secondaryText,
                    ),
                  ),
                for (final RequestComment c in comments) _bubble(context, c),
                if (canWrite) ...<Widget>[SizedBox(height: 12.h), _composer(s)],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _composer(S s) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: CustomTextField(
              key: const ValueKey<String>('requestCommentInput'),
              controller: _new,
              hint: s.timeTrackerWriteComment,
              height: 36,
              maxLength: RequestCommentRules.maxLength,
              valueStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
              onSubmitted: (_) => _send(),
            ),
          ),
          SizedBox(width: 10.w),
          GestureDetector(
            key: const ValueKey<String>('requestCommentSend'),
            onTap: _send,
            child: Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: TtIcon(const TtGlyph.svg(TtAssets.send), size: 18.r, color: AppColors.textButton),
            ),
          ),
        ],
      );

  Widget _bubble(BuildContext context, RequestComment c) {
    final S s = S.of(context);
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    final String me = GetIt.instance<TimeTrackerAccess>().currentUserEmail;
    final bool mine = RequestCommentRules.canModify(c, me);
    final TimeTrackerEmployee? who = widget.state.employeeOf(c.authorEmail);
    final CrossAxisAlignment side = mine ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final String when = c.createdAt == null ? '' : RequestText.dateAt(context, c.createdAt!);
    final TextStyle small = StyleText.fontSize10Weight400.copyWith(color: AppColors.secondaryText);
    return Padding(
      key: ValueKey<String>('requestComment_${c.id}'),
      padding: EdgeInsetsDirectional.only(top: 10.h),
      child: Column(
        crossAxisAlignment: side,
        children: <Widget>[
          Row(
            mainAxisAlignment: mine ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: <Widget>[
              TimeTrackerAvatar(photo: who?.photo ?? '', size: 30.r),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(who?.name(isArabic: ar) ?? c.authorEmail,
                      style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
                  if ((who?.jobTitle(isArabic: ar) ?? '').isNotEmpty)
                    Text(who!.jobTitle(isArabic: ar), style: small),
                ],
              ),
            ],
          ),
          SizedBox(height: 6.h),
          if (_editingId == c.id)
            _editor(c, s)
          else
            Container(
              padding: EdgeInsetsDirectional.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: CardStyles.radius()),
              child: Text(c.text, style: StyleText.fontSize12Weight400.copyWith(color: AppColors.text)),
            ),
          // 9/10/2026 (data model): the comment's optional files.
          for (final RequestAttachment a in c.attachments)
            Padding(
              padding: EdgeInsetsDirectional.only(top: 4.h),
              child: _link(a.name.isEmpty ? a.url : a.name, ValueKey<String>('requestCommentFile_${c.id}_${a.url}'), () {
                final Uri? uri = Uri.tryParse(a.url);
                if (uri == null) return;
                unawaited(launchUrl(uri, mode: LaunchMode.externalApplication).catchError((Object _) => false));
              }),
            ),
          SizedBox(height: 4.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(c.editedAt != null ? '$when · ${s.timeTrackerEdited}' : when, style: small),
              if (mine && _editingId != c.id) ...<Widget>[
                SizedBox(width: 12.w),
                _link(s.edit, ValueKey<String>('requestCommentEdit_${c.id}'), () {
                  HapticController.medium();
                  _edit.text = c.text;
                  setState(() => _editingId = c.id);
                }),
                SizedBox(width: 10.w),
                _link(s.delete, ValueKey<String>('requestCommentDelete_${c.id}'), () {
                  HapticController.high();
                  RequestFlows.deleteComment(context, widget.request, c.id, asApprover: widget.asApprover);
                }, color: AppColors.red),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _editor(RequestComment c, S s) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CustomTextField(
            key: ValueKey<String>('requestCommentEditInput_${c.id}'),
            controller: _edit,
            height: 36,
            maxLength: RequestCommentRules.maxLength,
            valueStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
          ),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              _link(s.discard, const ValueKey<String>('requestCommentEditDiscard'), () {
                HapticController.low();
                setState(() => _editingId = '');
              }),
              SizedBox(width: 12.w),
              _link(s.save, const ValueKey<String>('requestCommentEditSave'), () {
                HapticController.medium();
                _saveEdit(c);
              }),
            ],
          ),
        ],
      );

  Widget _link(String label, Key key, VoidCallback onTap, {Color? color}) => GestureDetector(
        key: key,
        onTap: onTap,
        child: Text(label,
            style: StyleText.fontSize12Weight500.copyWith(
              color: color ?? AppColors.blue,
              decoration: TextDecoration.underline,
              decorationColor: color ?? AppColors.blue,
            )),
      );
}
