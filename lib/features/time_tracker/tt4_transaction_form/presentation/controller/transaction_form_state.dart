/// Module: time_tracker / tt4_transaction_form / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: transaction_form_state.dart
/// Purpose: Declares `TransactionFormState` (+ `TransactionFormStatus`) —
///          the "Creating Transaction" draft: check-in / check-out, the
///          description, the uploaded document and the validation errors.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Figma `661:80120` (empty) / `661:80227` (with a file). Owner rules
/// (playbook §4b): Submit stays disabled until every required field is
/// valid; a tap on the disabled Submit reveals the errors ([showErrors]).

import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/transaction_rules.dart';

enum TransactionFormStatus { editing, submitting, success, failure }

class TransactionFormState {
  const TransactionFormState({
    this.status = TransactionFormStatus.editing,
    this.checkIn,
    this.checkOut,
    this.description = '',
    this.attachment,
    this.isUploading = false,
    this.uploadFailed = false,
    this.fileTooLarge = false,
    this.errors = const <TransactionError>{},
    this.showErrors = false,
    this.permissionDenied = false,
    this.errorMessage = '',
    this.overnightShift = false,
  });

  final TransactionFormStatus status;

  /// ADDED 9/10/2026 (code review finding 6): the employee's shift crosses
  /// midnight — only then may the check-out fall on the next day.
  final bool overnightShift;

  /// Null until BOTH the date and the time of that end were picked.
  final DateTime? checkIn;
  final DateTime? checkOut;
  final String description;

  /// The uploaded "Transaction Document" (optional).
  final RequestAttachment? attachment;
  final bool isUploading;
  final bool uploadFailed;
  final bool fileTooLarge;

  /// Current validation problems (see `TransactionRules.validate`).
  final Set<TransactionError> errors;

  /// Errors are shown only after a tap on the disabled Submit.
  final bool showErrors;
  final bool permissionDenied;
  final String errorMessage;

  /// Every required field is valid and no upload is running.
  bool get canSubmit =>
      errors.isEmpty && !isUploading && status != TransactionFormStatus.submitting;

  /// Whether [error] should be drawn under its field.
  bool shows(TransactionError error) => showErrors && errors.contains(error);

  /// Function Name: [copyWith]
  ///
  /// Purpose: Immutable update. [clearAttachment] removes the file.
  ///
  /// Return type: [TransactionFormState]
  TransactionFormState copyWith({
    TransactionFormStatus? status,
    DateTime? checkIn,
    DateTime? checkOut,
    String? description,
    RequestAttachment? attachment,
    bool clearAttachment = false,
    bool? isUploading,
    bool? uploadFailed,
    bool? fileTooLarge,
    Set<TransactionError>? errors,
    bool? showErrors,
    bool? permissionDenied,
    String? errorMessage,
    bool? overnightShift,
  }) =>
      TransactionFormState(
        status: status ?? this.status,
        checkIn: checkIn ?? this.checkIn,
        checkOut: checkOut ?? this.checkOut,
        description: description ?? this.description,
        attachment: clearAttachment ? null : (attachment ?? this.attachment),
        isUploading: isUploading ?? this.isUploading,
        uploadFailed: uploadFailed ?? this.uploadFailed,
        fileTooLarge: fileTooLarge ?? this.fileTooLarge,
        errors: errors ?? this.errors,
        showErrors: showErrors ?? this.showErrors,
        permissionDenied: permissionDenied ?? this.permissionDenied,
        errorMessage: errorMessage ?? this.errorMessage,
        overnightShift: overnightShift ?? this.overnightShift,
      );
}
