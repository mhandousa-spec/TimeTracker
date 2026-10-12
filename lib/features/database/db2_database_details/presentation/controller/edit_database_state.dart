/// Module: database / db2_database_details / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: edit_database_state.dart
/// Purpose: Declares `EditDatabaseState` and `EditDatabaseStatus`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026

part of './edit_database_cubit.dart';

enum EditDatabaseStatus { initial, submitting, success, failure }

@immutable
class EditDatabaseState {
  const EditDatabaseState({
    required this.original,
    required this.titleEn,
    required this.titleAr,
    required this.descriptionEn,
    required this.descriptionAr,
    this.coverImage,
    this.status = EditDatabaseStatus.initial,
    this.titleEnError,
    this.titleArError,
    this.errorMessage,
    this.savedDatabase,
    this.submitted = false,
  });

  /// Seeds every field from the record. Named rather than a default
  /// constructor so a caller cannot accidentally build an EMPTY edit state and
  /// then save it over a full record.
  factory EditDatabaseState.from(DatabaseEntity database) => EditDatabaseState(
        original: database,
        titleEn: database.titleEn,
        titleAr: database.titleAr,
        descriptionEn: database.descriptionEn,
        descriptionAr: database.descriptionAr,
      );

  /// The record as loaded. [isDirty] and the duplicate-title check both
  /// compare against this, and "Discard Changes" restores it.
  final DatabaseEntity original;

  final String titleEn;
  final String titleAr;
  final String descriptionEn;
  final String descriptionAr;

  /// A newly picked cover that has not been uploaded yet. Null means "leave
  /// the stored cover alone" — NOT "remove it"; see the data source's update
  /// payload for why those two must stay distinguishable.
  final File? coverImage;

  final EditDatabaseStatus status;

  final String? titleEnError;
  final String? titleArError;
  final String? errorMessage;

  /// The record the server returned. The details page swaps its own copy for
  /// this one so the card behind the dialog is already correct when the dialog
  /// closes.
  final DatabaseEntity? savedDatabase;

  final bool submitted;

  bool get isSubmitting => status == EditDatabaseStatus.submitting;

  /// Errors stay hidden until the first save attempt, so a form that opens
  /// full does not immediately paint red under fields the user has not
  /// touched. Same rule as the create card.
  String? get visibleTitleEnError => submitted ? titleEnError : null;
  String? get visibleTitleArError => submitted ? titleArError : null;

  /// Different from the record as LOADED — not "non-empty".
  ///
  /// This is what makes "Discard Changes" and the leave-confirmation honest on
  /// an edit screen: every field starts full, so db1's "is anything typed"
  /// rule would report a freshly opened form as dirty and warn about losing
  /// changes nobody made.
  ///
  /// Trimmed on both sides, because a trailing space the user did not notice
  /// is not a change worth blocking a back gesture over.
  bool get isDirty =>
      coverImage != null ||
      titleEn.trim() != original.titleEn.trim() ||
      titleAr.trim() != original.titleAr.trim() ||
      descriptionEn.trim() != original.descriptionEn.trim() ||
      descriptionAr.trim() != original.descriptionAr.trim();

  EditDatabaseState copyWith({
    DatabaseEntity? original,
    String? titleEn,
    String? titleAr,
    String? descriptionEn,
    String? descriptionAr,
    File? coverImage,
    EditDatabaseStatus? status,
    String? titleEnError,
    String? titleArError,
    String? errorMessage,
    DatabaseEntity? savedDatabase,
    bool? submitted,
    bool clearTitleEnError = false,
    bool clearTitleArError = false,
    bool clearErrorMessage = false,
    bool clearCoverImage = false,
  }) {
    return EditDatabaseState(
      original: original ?? this.original,
      titleEn: titleEn ?? this.titleEn,
      titleAr: titleAr ?? this.titleAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      coverImage: clearCoverImage ? null : (coverImage ?? this.coverImage),
      status: status ?? this.status,
      titleEnError:
          clearTitleEnError ? null : (titleEnError ?? this.titleEnError),
      titleArError:
          clearTitleArError ? null : (titleArError ?? this.titleArError),
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      savedDatabase: savedDatabase ?? this.savedDatabase,
      submitted: submitted ?? this.submitted,
    );
  }
}
