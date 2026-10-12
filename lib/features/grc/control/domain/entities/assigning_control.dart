class AssigningControlEntity {
  final String policyId;
  final String controlId;
  final DateTime? expiresOn;

  const AssigningControlEntity({
    required this.policyId,
    required this.controlId,
    this.expiresOn,
  });

  AssigningControlEntity copyWith({
    String? policyId,
    String? controlId,
    DateTime? expiresOn,
  }) {
    return AssigningControlEntity(
      policyId: policyId ?? this.policyId,
      controlId: controlId ?? this.controlId,
      expiresOn: expiresOn ?? this.expiresOn,
    );
  }
}
