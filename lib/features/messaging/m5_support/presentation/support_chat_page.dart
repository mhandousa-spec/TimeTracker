/// Module: messaging / m5_support / presentation
///
///*************************** FILE INFO ****************************///
/// File Name: support_chat_page.dart
/// Purpose: "Knowticed Support" — the tile at the top of Messages and the
///          conversation page behind it.
/// Author: Amr Mesbah
/// Created at: 23/9/2026
///
/// The user's Comments and Feedback submissions (Settings › App Info) are
/// the first messages of this conversation; the Knowticed team replies from
/// the admin dashboard and the user can answer here. See
/// support_chat_repository.dart for the Firestore layout.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:knowticed_plus/core/helper/main_helper/custom_app_bar.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/messaging/m2_connections/presentation/controller/connections_controller.dart';
import '../data/support_chat_repository.dart';
import 'support_voice_player.dart';

/// Strings of this feature (the generated l10n needs a regeneration step, so
/// the two languages are kept here).
String _t(BuildContext context, String en, String ar) =>
    Localizations.localeOf(context).languageCode == 'ar' ? ar : en;

String _kind(BuildContext context, String? kind) {
  switch (kind) {
    case 'bug':
      return _t(context, 'Report Bug', 'الإبلاغ عن خطأ');
    case 'feature_request':
      return _t(context, 'New Feature Request', 'طلب ميزة جديدة');
    default:
      return _t(context, 'Comment', 'تعليق');
  }
}

/// The signed-in user as the messaging module knows them (email + name), or
/// null before `useGroupAndSingleMessaging` has run.
({String email, String name})? _currentUser() {
  final bool available = Get.isRegistered<ConnectionsCubit>() ||
      Get.isPrepared<ConnectionsCubit>();
  if (!available) return null;
  final cubit = Get.find<ConnectionsCubit>();
  if (!cubit.isCurrentUserInitialized) return null;
  final email = cubit.currentUser.userId;
  if (email.trim().isEmpty) return null;
  return (email: email, name: cubit.currentUser.fullName);
}

// ── Tile on the Messages home ────────────────────────────────────────────────

class SupportChatTile extends StatelessWidget {
  const SupportChatTile({super.key});

  @override
  Widget build(BuildContext context) {
    final user = _currentUser();
    if (user == null) return const SizedBox.shrink();
    return StreamBuilder<SupportChatSummary>(
      stream: SupportChatRepository().watchSummary(user.email),
      builder: (context, snap) {
        final s = snap.data ?? const SupportChatSummary();
        return InkWell(
          borderRadius: BorderRadius.circular(8.r),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) =>
                SupportChatPage(email: user.email, name: user.name),
          )),
          child: Container(
            margin: EdgeInsets.only(bottom: 10.h),
            padding: EdgeInsets.all(10.sp),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: AppColors.secondaryPrimary,
                  child: Icon(Icons.support_agent_rounded,
                      color: AppColors.white, size: 22.sp),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_t(context, 'Knowticed Support', 'دعم Knowticed'),
                          style: StyleText.fontSize14Weight500
                              .copyWith(color: AppColors.text)),
                      SizedBox(height: 2.h),
                      Text(
                        s.lastText.isEmpty
                            ? _t(context,
                                'Your comments and feedback, and our replies',
                                'تعليقاتك وملاحظاتك وردودنا عليها')
                            : s.lastText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: StyleText.fontSize12Weight400
                            .copyWith(color: AppColors.secondaryText),
                      ),
                    ],
                  ),
                ),
                if (s.unread > 0)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryPrimary,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text('${s.unread}',
                        style: StyleText.fontSize12Weight500
                            .copyWith(color: AppColors.white)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Conversation page ────────────────────────────────────────────────────────

class SupportChatPage extends StatefulWidget {
  const SupportChatPage({super.key, required this.email, required this.name});

  final String email;
  final String name;

  @override
  State<SupportChatPage> createState() => _SupportChatPageState();
}

class _SupportChatPageState extends State<SupportChatPage> {
  final SupportChatRepository _repo = SupportChatRepository();
  final TextEditingController _input = TextEditingController();
  StreamSubscription? _msgSub;
  StreamSubscription? _fbSub;
  List<SupportMessage> _messages = const [];
  List<SupportMessage> _feedback = const [];
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _msgSub = _repo.watchMessages(widget.email).listen((l) {
      if (!mounted) return;
      setState(() {
        _messages = l;
        _loading = false;
      });
      _repo.markRead(widget.email);
    }, onError: (_) {
      if (mounted) setState(() => _loading = false);
    });
    _fbSub = _repo.watchFeedback(widget.email).listen((l) {
      if (mounted) setState(() => _feedback = l);
    }, onError: (_) {});
    _repo.markRead(widget.email);
  }

  @override
  void dispose() {
    _msgSub?.cancel();
    _fbSub?.cancel();
    _input.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await _repo.send(email: widget.email, name: widget.name, text: text);
      _input.clear();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(_t(context, 'Message not sent, try again',
                'لم يتم إرسال الرسالة، حاول مرة أخرى'))));
      }
    }
    if (mounted) setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final all = [..._feedback, ..._messages]
      ..sort((a, b) => (a.time ?? DateTime.now())
          .compareTo(b.time ?? DateTime.now()));
    final reversed = all.reversed.toList();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              CustomAppBar(
                title: _t(context, 'Knowticed Support', 'دعم Knowticed'),
                centerTitle: false,
              ),
              Expanded(
                child: _loading && all.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : all.isEmpty
                        ? Center(
                            child: Text(
                              _t(
                                  context,
                                  'Send comments and feedback from Settings › App Info and our team will reply here.',
                                  'أرسل تعليقاتك وملاحظاتك من الإعدادات › معلومات التطبيق وسيرد فريقنا هنا.'),
                              textAlign: TextAlign.center,
                              style: StyleText.fontSize14Weight400
                                  .copyWith(color: AppColors.secondaryText),
                            ),
                          )
                        : ListView.builder(
                            reverse: true,
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            itemCount: reversed.length,
                            itemBuilder: (_, i) =>
                                _SupportBubble(message: reversed[i]),
                          ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 12.h, top: 6.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: TextField(
                          controller: _input,
                          minLines: 1,
                          maxLines: 4,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _send(),
                          style: StyleText.fontSize14Weight400
                              .copyWith(color: AppColors.text),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: _t(context, 'Type your message',
                                'اكتب رسالتك'),
                            hintStyle: StyleText.fontSize14Weight400
                                .copyWith(color: AppColors.secondaryText),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    _sending
                        ? SizedBox(
                            width: 40.sp,
                            height: 40.sp,
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : InkWell(
                            onTap: _send,
                            customBorder: const CircleBorder(),
                            child: CircleAvatar(
                              radius: 20.r,
                              backgroundColor: AppColors.secondaryPrimary,
                              child: Icon(Icons.send_rounded,
                                  size: 20.sp, color: AppColors.white),
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportBubble extends StatelessWidget {
  const _SupportBubble({required this.message});

  final SupportMessage message;

  @override
  Widget build(BuildContext context) {
    // Mine (user) on the end side, the team's replies on the start side.
    final mine = !message.fromAdmin;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Align(
        alignment:
            mine ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 0.75.sw),
          child: Container(
            padding: EdgeInsets.all(10.sp),
            decoration: BoxDecoration(
              color: mine
                  ? AppColors.secondaryPrimary.withOpacity(0.18)
                  : AppColors.card,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (message.fromAdmin)
                  Padding(
                    padding: EdgeInsets.only(bottom: 4.h),
                    child: Text(
                        _t(context, 'Knowticed Support', 'دعم Knowticed'),
                        style: StyleText.fontSize12Weight500
                            .copyWith(color: AppColors.secondaryPrimary)),
                  ),
                if (message.feedbackKind != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: 4.h),
                    child: Text(_kind(context, message.feedbackKind),
                        style: StyleText.fontSize12Weight500
                            .copyWith(color: AppColors.secondaryPrimary)),
                  ),
                if (message.text.isNotEmpty)
                  Text(message.text,
                      style: StyleText.fontSize14Weight400
                          .copyWith(color: AppColors.text)),
                if (message.mediaUrl.isNotEmpty && message.isVoice) ...[
                  // 24/9/2026 — voice note from Knowticed Support.
                  SizedBox(height: 4.h),
                  SupportVoicePlayer(url: message.mediaUrl),
                ] else if (message.mediaUrl.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  message.fileName.toLowerCase().endsWith('.png') ||
                          message.fileName.toLowerCase().endsWith('.jpg') ||
                          message.fileName.toLowerCase().endsWith('.jpeg')
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(4.r),
                          child: Image.network(message.mediaUrl,
                              width: 200.w, fit: BoxFit.cover),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.attach_file_rounded,
                                size: 16.sp, color: AppColors.text),
                            SizedBox(width: 4.w),
                            Flexible(
                              child: Text(
                                message.fileName.isEmpty
                                    ? _t(context, 'Attachment', 'مرفق')
                                    : message.fileName,
                                style: StyleText.fontSize12Weight400
                                    .copyWith(color: AppColors.text),
                              ),
                            ),
                          ],
                        ),
                ],
                if (message.time != null) ...[
                  SizedBox(height: 4.h),
                  Text(DateFormat('d MMM, h:mm a').format(message.time!),
                      style: StyleText.fontSize12Weight400
                          .copyWith(color: AppColors.secondaryText)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
