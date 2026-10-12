/// Module: settings/se5_emergency_contact
///
///*************************** FILE INFO ****************************///
/// File Name: emergency_contact_state.dart
/// Purpose: States for EmergencyContactController.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026

part of './emergency_contact_controller.dart';

enum EmergencyContactStatus { initial, loading, success, failure }

@immutable
class EmergencyContactState {
  const EmergencyContactState({
    this.status = EmergencyContactStatus.initial,
    this.contact,
    this.errorMessage,
  });

  final EmergencyContactStatus status;

  /// The loaded contacts, or `null` before the first load / after a failure.
  final EmergencyContactEntity? contact;

  /// Why the last load failed. `getEmployeeData` used to fold the `Left` to
  /// `null`, so a failure was indistinguishable from "no contacts recorded"
  /// (CR-SKEL-SE5-N12).
  final String? errorMessage;

  EmergencyContactState copyWith({
    EmergencyContactStatus? status,
    Object? contact = _unset,
    Object? errorMessage = _unset,
  }) {
    return EmergencyContactState(
      status: status ?? this.status,
      contact: identical(contact, _unset)
          ? this.contact
          : contact as EmergencyContactEntity?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

/// Sentinel so `copyWith` can tell "leave unchanged" from "set to null".
const Object _unset = Object();
