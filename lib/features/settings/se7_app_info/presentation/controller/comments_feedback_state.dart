/// Module: settings/se7_app_info
///
///*************************** FILE INFO ****************************///
/// File Name: comments_feedback_state.dart
/// Purpose: States for [CommentsFeedbackCubit].
/// Author: Knowticed Plus team
/// Created at: 1/9/2026

import 'package:knowticed_plus/features/settings/se7_app_info/domain/entities/app_feedback.dart';

/// How the "Request Details" list is ordered.
///
/// Date Requested, in both directions — that is the whole menu.
///
/// NARROWED 1/9/2026. It also offered Status and Type. Both were dropped: the
/// status chips sit directly above the list and the type IS each card's title,
/// so those two sorts reordered the list by something already on screen while
/// taking the only ordering that carries information off the top.
///
/// [descending] is the default because the list is a person's own submissions
/// and the thing they just sent is the thing they came to look at.
///
/// NOTE 2/9/2026 — "the default" and "what the user picked" are now different
/// things. `CommentsFeedbackLoaded.sortOption` is NULLABLE: null means nobody
/// has opened the sort menu yet, and the list is still ordered [descending]
/// because that is the default. The Sort button reads that null to draw itself
/// dimmed, so do not collapse the two by defaulting the field — see
/// [CommentsFeedbackLoaded.sortOption] and `FeedbackSortMenu`.
enum FeedbackSortOption { descending, ascending }

/// The status filter behind the All / Open / Fixed / Closed chips.
///
/// [all] is not a [FeedbackStatus] — it is the absence of a filter — so the
/// two are deliberately different types rather than a nullable status that
/// every call site would have to null-check.
enum FeedbackStatusFilter { all, open, fixed, closed }

abstract class CommentsFeedbackState {
  const CommentsFeedbackState();
}

class CommentsFeedbackInitial extends CommentsFeedbackState {
  const CommentsFeedbackInitial();
}

class CommentsFeedbackLoading extends CommentsFeedbackState {
  const CommentsFeedbackLoading();
}

/// Emitted on every load, filter, search and sort.
///
/// [displayedItems] is computed by the cubit rather than by the widget: the
/// chip counts and the cards then come from one pass over one list and cannot
/// disagree about what "Open" means.
class CommentsFeedbackLoaded extends CommentsFeedbackState {
  const CommentsFeedbackLoaded({
    required this.allItems,
    required this.displayedItems,
    required this.counts,
    required this.totalCount,
    required this.selectedStatus,
    required this.sortOption,
    required this.searchText,
    this.isSubmitting = false,
  });

  /// Everything the employee has submitted, newest first.
  final List<FeedbackRequest> allItems;

  /// [allItems] after the status chip, the search box and the sort.
  final List<FeedbackRequest> displayedItems;

  /// Always all three [FeedbackStatus] keys, so a chip renders 0 not blank.
  final Map<FeedbackStatus, int> counts;

  /// The "All" chip's number — [allItems].length, kept here so the widget does
  /// not have to know that.
  final int totalCount;

  final FeedbackStatusFilter selectedStatus;

  /// The sort the user PICKED, or null if they have not picked one.
  ///
  /// CHANGED 2/9/2026 — was non-nullable and defaulted to
  /// [FeedbackSortOption.descending], which made "newest first because that is
  /// the default" indistinguishable from "newest first because I chose it".
  /// The Sort button needs to tell those apart: it is dimmed until a choice is
  /// made. The ORDERING is unchanged — the cubit still falls back to
  /// [FeedbackSortOption.descending] when this is null.
  ///
  /// [copyWith] cannot clear it back to null, by design: there is no way back
  /// to "never chosen" once a choice is made.
  final FeedbackSortOption? sortOption;
  final String searchText;

  /// True while a submission is in flight. Lives in the state rather than in
  /// the screen's `setState` so the Submit button and the list reload cannot
  /// get out of step.
  final bool isSubmitting;

  CommentsFeedbackLoaded copyWith({
    List<FeedbackRequest>? allItems,
    List<FeedbackRequest>? displayedItems,
    Map<FeedbackStatus, int>? counts,
    int? totalCount,
    FeedbackStatusFilter? selectedStatus,
    FeedbackSortOption? sortOption,
    String? searchText,
    bool? isSubmitting,
  }) {
    return CommentsFeedbackLoaded(
      allItems: allItems ?? this.allItems,
      displayedItems: displayedItems ?? this.displayedItems,
      counts: counts ?? this.counts,
      totalCount: totalCount ?? this.totalCount,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      sortOption: sortOption ?? this.sortOption,
      searchText: searchText ?? this.searchText,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

/// A read failed. The list keeps whatever it had — see the note on
/// `CommentsFeedbackCubit.load` — so this is for the snack bar only.
class CommentsFeedbackError extends CommentsFeedbackState {
  const CommentsFeedbackError(this.message);

  final String message;
}
