/// Module: services_app_module/submissions
///
/// Immutable submission/request entities (final fields + copyWith, §4.1/§10).

class RequestedModel {
  final DateTime receivedDate;
  final String email;

  const RequestedModel(this.receivedDate, this.email);

  RequestedModel copyWith({
    DateTime? receivedDate,
    String? email,
  }) {
    return RequestedModel(
      receivedDate ?? this.receivedDate,
      email ?? this.email,
    );
  }
}

class SubmissionsModel {
  final DateTime submissionDate;
  final DateTime receivedDate;
  final String email;

  const SubmissionsModel({
    required this.submissionDate,
    required this.email,
    required this.receivedDate,
  });

  SubmissionsModel copyWith({
    DateTime? submissionDate,
    DateTime? receivedDate,
    String? email,
  }) {
    return SubmissionsModel(
      submissionDate: submissionDate ?? this.submissionDate,
      receivedDate: receivedDate ?? this.receivedDate,
      email: email ?? this.email,
    );
  }
}
