/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: user_connection_interface_parameters.dart
/// Purpose: Declares `UserConnectionInterfaceParameters`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:cloud_firestore/cloud_firestore.dart';
import './base_messaging_interface_parameters.dart';

class UserConnectionInterfaceParameters
    extends BaseMessagingInterfaceParameters {
  Timestamp userAccountActivationTime;
  UserConnectionInterfaceParameters(
      {required super.primaryLanguageName,
      required super.secondaryLanguageName,
      required super.primaryLanguageSubInfo,
      required super.secondaryLanguageSubInfo,
      required super.imageUri,
      required super.userId,
      required super.phone,
      required super.userCategory,
      required this.userAccountActivationTime,
      });
}
