/// Module: roles / r1_role_management / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: access_data.dart
/// Purpose: Declares `AccessData`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

class AccessData {
  AccessData(
      {required this.accessIcon,
        required this.grantedBy,
        required this.text,
        required this.grantedDate,
        required this.isRemoved});
  final String accessIcon;
  final String text;
  final String grantedBy;
  final String grantedDate;
  bool isRemoved;
}
