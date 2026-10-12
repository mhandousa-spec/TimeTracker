import 'package:knowticed_plus/features/grc/control/domain/entities/assigning_control.dart';
import 'package:knowticed_plus/features/grc/shared/constants/grc_firestore_keys.dart';
import 'package:intl/intl.dart';

final DateFormat _assigningControlDateFormat = DateFormat('d MMM yyyy', 'en');

class AssigningControlModel {
  static const String _keyControlId = 'Control_ID';
  static const String _keyExpiresOn = 'Expires_On';

  final String policyId;
  final String controlId;
  final DateTime? expiresOn;

  const AssigningControlModel({
    required this.policyId,
    required this.controlId,
    this.expiresOn,
  });

  Map<String, dynamic> toJson() {
    return {
      GrcFirestoreKeys.policyId: policyId,
      _keyControlId: controlId,
      _keyExpiresOn:
          expiresOn != null ? _assigningControlDateFormat.format(expiresOn!) : null,
    };
  }

  factory AssigningControlModel.fromJson(Map<String, dynamic> json) {
    final expiresOnRaw = json[_keyExpiresOn] as String?;
    return AssigningControlModel(
      policyId: json[GrcFirestoreKeys.policyId] as String,
      controlId: json[_keyControlId] as String,
      expiresOn:
          expiresOnRaw != null ? _assigningControlDateFormat.parse(expiresOnRaw) : null,
    );
  }

  AssigningControlEntity toEntity() {
    return AssigningControlEntity(
      policyId: policyId,
      controlId: controlId,
      expiresOn: expiresOn,
    );
  }
}
