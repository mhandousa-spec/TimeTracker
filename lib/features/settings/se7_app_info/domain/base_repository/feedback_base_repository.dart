/// Module: settings/se7_app_info
///
///*************************** FILE INFO ****************************///
/// File Name: feedback_base_repository.dart
/// Purpose: Domain contract for submitting and reading back app feedback.
/// Author: Knowticed Plus team
/// Created at: 13/8/2026
/// Updated: 1/9/2026 - Added [listForEmployee] for the "Request Details" list.

import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/domain/entities/app_feedback.dart';

abstract class FeedbackBaseRepository {
  /// Function Name: [submit]
  ///
  /// Purpose: Persist one feedback submission.
  ///
  /// Parameters:
  /// - [feedback]: must not be empty; the caller short-circuits rather than
  ///   issuing a no-op write.
  ///
  /// Returns: [Future<Either<Failure, void>>].
  Future<Either<Failure, void>> submit(AppFeedback feedback);

  /// Function Name: [countsByStatus]
  ///
  /// Purpose: How many of one employee's submissions are open, fixed and
  ///          closed — the three figures the "Comments and Feedbacks" home
  ///          widget shows.
  ///
  /// ADDED 25/8/2026. This contract was write-only: `submit` and
  /// `uploadAttachment` and nothing else, so no caller could ever see what had
  /// been submitted. The home widget is the first reader.
  ///
  /// Parameters:
  /// - [employeeId]: whose submissions to count.
  ///
  /// Returns: [Future<Either<Failure, Map<FeedbackStatus, int>>>] with all
  ///          three statuses present, so a caller renders 0 rather than blank.
  Future<Either<Failure, Map<FeedbackStatus, int>>> countsByStatus(
    String employeeId,
  );

  /// Function Name: [listForEmployee]
  ///
  /// Purpose: One employee's submissions, newest first.
  ///
  /// ADDED 1/9/2026 for the "Request Details" list. [countsByStatus] answers
  /// "how many" and this answers "which" — the list needs the second, and
  /// deriving counts from this result (as `CommentsFeedbackCubit` does) means
  /// the chips and the cards can never disagree about the same data.
  ///
  /// Parameters:
  /// - [employeeId]: whose submissions to read.
  ///
  /// Returns: [Future<Either<Failure, List<FeedbackRequest>>>].
  Future<Either<Failure, List<FeedbackRequest>>> listForEmployee(
    String employeeId,
  );

  /// Function Name: [uploadAttachment]
  ///
  /// Purpose: Put one picked file in Storage and describe where it landed.
  ///
  /// Takes bytes rather than a `File` on purpose: `file_picker` returns bytes
  /// on every platform including web, while `path` is null there — and this
  /// screen is reachable from the desktop build.
  ///
  /// Parameters:
  /// - [kind]: which of the three boxes the file belongs to; it becomes a
  ///   folder in the bucket so the three streams stay separable.
  /// - [fileName]: the user's original name, kept for the stored descriptor.
  /// - [bytes]: the file contents.
  /// - [contentType]: optional MIME type.
  ///
  /// Returns: [Future<Either<Failure, FeedbackAttachment>>].
  Future<Either<Failure, FeedbackAttachment>> uploadAttachment({
    required FeedbackKind kind,
    required String fileName,
    required Uint8List bytes,
    String? contentType,
  });
}
