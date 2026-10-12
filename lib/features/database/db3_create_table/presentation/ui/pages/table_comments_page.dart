/// Module: database / db3_create_table / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: table_comments_page.dart
/// Purpose: Declares `TableCommentsPage`.
/// Author: Knowticed Plus team
/// Created at: 17/8/2026
///
/// "Comments" — Figma 7398:8232 (iPad H 1024, the thread), 7398:8311 / 8587
/// (the reply and reacted states), 7398:8360 / 8437 / 8484 (the 768 twins).
///
/// Reached from the yellow Comments button on the Table Name Details card, and
/// from nowhere else: the breadcrumb is four crumbs deep
/// ("Database > Database Details > Table Name Details > Comments") and every one
/// of them is a screen this was pushed from.
///
/// ONE CARD, TWO PARTS
/// -------------------
/// The Figma draws the whole screen as a single white card with the thread
/// scrolling inside it and the composer pinned to its bottom edge. That pinning
/// is the reason the list is not simply part of the page scroll: a composer that
/// slid away as the conversation grew would leave the user scrolling to the
/// bottom to reply.
///
/// WHY THE HEIGHT IS HANDLED TWICE
/// -------------------------------
/// `SideFrameMasterServices` hands its child a BOUNDED height on a tablet
/// (`Expanded(child: child!)`) and an UNBOUNDED one on a phone, where the shell
/// itself is a scroll view. A pinned composer needs a bound, so the phone branch
/// supplies one from the viewport instead. Same fork
/// `CreateDatabaseMetrics.pageScroll` documents, resolved the other way round —
/// this page cannot be part of an outer scroll.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/11-custom_confirm_diaolog.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/constants/database_details_constants.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/constants/create_table_constants.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/database_table_entity.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_comment.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/controller/table_comments_cubit.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/ui/widgets/table_comment_bubble.dart';

class TableCommentsPage extends StatefulWidget {
  const TableCommentsPage({
    super.key,
    required this.database,
    required this.table,
    this.currentEmployeeId,
  });

  /// The parent, carried for its NAME only — the second crumb. The thread's
  /// path comes off [table], which knows its own `databaseId`.
  final DatabaseEntity database;

  final DatabaseTableEntity table;

  /// Who is reading, and therefore who posts. Null leaves the thread readable
  /// and the composer out — see `TableCommentsState.canPost`.
  final String? currentEmployeeId;

  static Future<void> open(
    BuildContext context, {
    required DatabaseEntity database,
    required DatabaseTableEntity table,
    String? currentEmployeeId,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => TableCommentsPage(
          database: database,
          table: table,
          currentEmployeeId: currentEmployeeId,
        ),
      ),
    );
  }

  @override
  State<TableCommentsPage> createState() => _TableCommentsPageState();
}

class _TableCommentsPageState extends State<TableCommentsPage> {
  late final TableCommentsCubit _cubit = TableCommentsCubit(
    table: widget.table,
    currentEmployeeId: widget.currentEmployeeId,
  )..load();

  final TextEditingController _composer = TextEditingController();
  final ScrollController _threadScroll = ScrollController();

  @override
  void dispose() {
    _composer.dispose();
    _threadScroll.dispose();
    _cubit.close();
    super.dispose();
  }

  /// Drops the view to the newest message.
  ///
  /// Posted through the frame callback because it runs BEFORE the list has laid
  /// out the message that was just added — `maxScrollExtent` at that moment is
  /// still the old one, and jumping to it would stop a bubble short.
  void _scrollToNewest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_threadScroll.hasClients) return;
      _threadScroll.animateTo(
        _threadScroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _onSendPressed() async {
    final String text = _composer.text;
    if (text.trim().isEmpty) return;

    final bool posted = await _cubit.post(text);
    if (!mounted) return;

    if (!posted) {
      final CreateTableStrings strings = CreateTableStrings.of(context);
      final String message = _cubit.state.errorMessage ?? strings.commentFailed;
      _cubit.clearMessages();
      await showErrorDialog(
        context: context,
        title: strings.errorTitle,
        subtitle: message,
        closeLabel: strings.close,
      );
      return;
    }

    // Cleared only on success. A message that failed to send is still in the
    // box, which is the difference between "try again" and "type it again".
    _composer.clear();
    _scrollToNewest();
  }

  Future<void> _onDeletePressed(TableComment comment) async {
    final CreateTableStrings strings = CreateTableStrings.of(context);

    // showConfirmDialog pops before invoking onConfirm, so this flag is set
    // while the await below is still suspended and is readable after it.
    bool confirmed = false;
    await showConfirmDialog(
      context: context,
      title: strings.deleteCommentTitle,
      subtitle: strings.deleteCommentSubtitle,
      confirmLabel: strings.yes,
      cancelLabel: strings.no,
      onConfirm: () => confirmed = true,
    );
    if (!confirmed || !mounted) return;

    await _cubit.delete(comment);
  }

  @override
  Widget build(BuildContext context) {
    final CreateTableStrings strings = CreateTableStrings.of(context);
    final bool isArabic = context.isArabic;

    final String databaseTitle = FormatHelper.capitalize(
      widget.database.localizedTitle(isArabic: isArabic),
    );
    final String tableName = FormatHelper.capitalize(
      widget.table.localizedName(isArabic: isArabic),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: strings.database,
        secondTitle: DatabaseDetailsStrings.of(context).detailsCrumb(
          databaseTitle,
        ),
        thirdTitle: strings.tableDetailsCrumb(tableName),
        fourthTitle: strings.comments,
        // Every crumb but the last leaves this screen. They pop rather than
        // pushing a fresh copy of the screen they name: those screens are still
        // underneath this one, with their scroll position and their state.
        onFirstTap: () => Navigator.of(context).pop(),
        onSecondTap: () => Navigator.of(context).pop(),
        onThirdTap: () => Navigator.of(context).pop(),
        child: BlocConsumer<TableCommentsCubit, TableCommentsState>(
          bloc: _cubit,
          // Only the first load scrolls automatically. After that the user owns
          // the scroll position — yanking them to the bottom because somebody
          // else's message arrived is the behaviour every chat app was asked to
          // stop doing.
          listenWhen: (TableCommentsState was, TableCommentsState now) =>
              was.isLoading && !now.isLoading,
          listener: (_, __) => _scrollToNewest(),
          builder: (BuildContext context, TableCommentsState state) {
            return _card(context, state, strings);
          },
        ),
      ),
    );
  }

  /// The white card, sized so the composer can be pinned inside it.
  Widget _card(
    BuildContext context,
    TableCommentsState state,
    CreateTableStrings strings,
  ) {
    final Widget card = Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: CardStyles.shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(child: _thread(state, strings)),
          SizedBox(height: 10.h),
          _composerRow(state, strings),
        ],
      ),
    );

    if (!context.isPhone) return card;

    // On a phone the shell is itself a scroll view and hands this an unbounded
    // height, which an `Expanded` inside a Column cannot resolve. 72% of the
    // viewport is the card's share once the header and the breadcrumb are
    // counted, and it keeps the composer on screen with the keyboard up.
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.72,
      child: card,
    );
  }

  /// The scrolling conversation.
  Widget _thread(TableCommentsState state, CreateTableStrings strings) {
    if (state.isLoading) return const Center(child: CircleProgressMaster());

    // A failed read is retried, not mistaken for a quiet thread — the same
    // distinction the table list makes, and the reason this is a sentence with
    // a button rather than the empty-state animation.
    if (state.hasError && state.comments.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              state.errorMessage ?? strings.commentsLoadFailed,
              textAlign: TextAlign.center,
              style: StyleText.fontSize14Weight400
                  .copyWith(color: AppColors.secondaryText),
            ),
            SizedBox(height: 16.h),
            TextButton(
              onPressed: () {
                _cubit.clearMessages();
                _cubit.load();
              },
              child: Text(
                strings.retry,
                style: StyleText.fontSize14Weight500
                    .copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
      );
    }

    if (state.comments.isEmpty) return const CustomEmptyState();

    return ListView.builder(
      controller: _threadScroll,
      padding: EdgeInsets.symmetric(vertical: 4.h),
      itemCount: state.comments.length,
      itemBuilder: (BuildContext context, int index) {
        final TableComment comment = state.comments[index];
        final bool mine = comment.isMine(state.currentEmployeeId);

        return TableCommentBubble(
          comment: comment,
          isMine: mine,
          myReaction: comment.reactionOf(state.currentEmployeeId),
          canReact: state.canPost,
          onReact: (TableCommentReaction reaction) =>
              _cubit.react(comment, reaction),
          // Only your own message offers Delete. Everyone else's passes null,
          // which is also what turns the long-press off — see the bubble.
          onDelete: mine ? () => _onDeletePressed(comment) : null,
        );
      },
    );
  }

  /// "Write a Comment" plus the yellow send button (Figma 7398:8232).
  ///
  /// When the reader may not post, the row is replaced by ONE SENTENCE saying
  /// why — not by nothing. A Comments screen with no way to comment reads as
  /// broken, and both reasons it can happen (the table is Private, or nobody is
  /// signed in) have completely different fixes, so they are two sentences.
  Widget _composerRow(TableCommentsState state, CreateTableStrings strings) {
    if (!state.canPost) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Text(
          state.currentEmployeeId.isEmpty
              ? strings.signInToComment
              : strings.commentsPrivate,
          style: StyleText.fontSize12Weight400
              .copyWith(color: AppColors.secondaryText),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: TextField(
            controller: _composer,
            enabled: !state.isPosting,
            minLines: 1,
            // Grows to four lines and then scrolls. The Figma's box is one line
            // tall, but it is drawn holding a placeholder — a real comment is
            // often a paragraph, and a single line that scrolls sideways is the
            // one shape that makes it unreadable while you write it.
            maxLines: 4,
            textInputAction: TextInputAction.newline,
            style:
                StyleText.fontSize13Weight400.copyWith(color: AppColors.text),
            decoration: InputDecoration(
              hintText: strings.writeAComment,
              hintStyle: StyleText.fontSize12Weight400
                  .copyWith(color: AppColors.secondaryText),
              filled: true,
              fillColor: AppTheme.isDark
                  ? AppColors.chatField
                  : AppColors.fieldFillLight,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: AppColors.transparent),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: AppColors.transparent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        _sendButton(state, strings),
      ],
    );
  }

  Widget _sendButton(TableCommentsState state, CreateTableStrings strings) {
    final double size = 42.sp;

    return Semantics(
      label: strings.send,
      button: true,
      child: GestureDetector(
        onTap: state.isPosting ? null : _onSendPressed,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: state.isPosting ? AppColors.disabledGrey : AppColors.primary,
            borderRadius: BorderRadius.circular(8.r),
          ),
          alignment: Alignment.center,
          // The spinner replaces the plane rather than sitting beside it: the
          // button is 42pt square and there is room for exactly one thing in
          // it, and a send button that still shows a plane while sending
          // invites a second tap.
          child: state.isPosting
              ? SizedBox(
                  width: 18.r,
                  height: 18.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.textButton),
                  ),
                )
              : CustomSvgImage(
                  assetPath: CreateTableAssets.send,
                  width: 18.r,
                  height: 18.r,
                  color: AppColors.textButton,
                ),
        ),
      ),
    );
  }
}
