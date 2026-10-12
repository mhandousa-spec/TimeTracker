/// Module: onboarding/o3_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: demo_user_account_overview.dart
/// Purpose: Per-module user counts for a demo tenant.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - Added the standard header (Docs).

import 'package:cloud_firestore/cloud_firestore.dart';

/// **************************** FILE INFO ****************************
///
/// File name: demo_user_account_overview.dart
///
/// Purpose: To create a model for the demo user account overview
///
/// Author: Amr Mesbah
///
/// Created at: 4/1/2024
class DemoUserAccountOverview {
  String email;
  String companyId;
  bool isActivated;
  Timestamp? demoGranted;
  Timestamp? demoActivated;

  DemoUserAccountOverview({
    required this.email,
    required this.companyId,
    required this.isActivated,
    required this.demoGranted,
    required this.demoActivated,
  });

  static const String emailField = 'Email';
  static const String companyIdField = 'Company_Id';
  static const String isActivatedField = 'Is_Activated';
  static const String demoGrantedField = 'Demo_Granted';
  static const String demoActivatedField = 'Demo_Activated';

  factory DemoUserAccountOverview.fromMap(Map<String, dynamic> map) {
    return DemoUserAccountOverview(
      email: map[emailField],
      companyId: map[companyIdField],
      isActivated: map[isActivatedField],
      demoGranted: map[demoGrantedField],
      demoActivated: map[demoActivatedField],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      emailField: email,
      companyIdField: companyId,
      isActivatedField: isActivated,
      demoGrantedField: demoGranted,
      demoActivatedField: demoActivated,
    };
  }
}
