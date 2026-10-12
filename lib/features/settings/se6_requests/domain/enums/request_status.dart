/// Module: settings/se6_requests
///
///*************************** FILE INFO ****************************///
/// File Name: request_status.dart
/// Purpose: The lifecycle of a change request.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Added for CR-SKEL-SE6-N03. The status was a bare string compared against
/// `'pending'` / `'approved'` / `'rejected'` literals in four pages and the
/// controller, so a typo in any one of them silently produced a request no
/// screen could filter.

enum RequestStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected'),
  cancelled('cancelled');

  const RequestStatus(this.wireValue);

  /// Exactly the string stored in Firestore. Do not change these.
  final String wireValue;

  /// Firestore holds both spellings of cancelled, depending on which screen
  /// wrote the record. `request_page.dart` already normalised for this when
  /// counting; reads funnel through [fromWire] so nothing else has to.
  static const String _cancelledUsSpelling = 'canceled';

  /// Function Name: [fromWire]
  ///
  /// Purpose: Read a stored status, defaulting to [pending] for anything
  ///          unrecognised — which is how the pages already behaved
  ///          (`data['status'] ?? 'pending'`).
  static RequestStatus fromWire(String? value) {
    final String normalized = (value ?? '').toLowerCase().trim();
    if (normalized == _cancelledUsSpelling) return RequestStatus.cancelled;

    for (final RequestStatus status in RequestStatus.values) {
      if (status.wireValue == normalized) return status;
    }
    return RequestStatus.pending;
  }

  bool get isPending => this == RequestStatus.pending;

  /// A decided request cannot be withdrawn.
  bool get isDecided => this != RequestStatus.pending;
}
