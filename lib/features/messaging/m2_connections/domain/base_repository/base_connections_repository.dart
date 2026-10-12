/// Module: messaging / connections / domain/base_repository/connections_repository.dart
/// ************************* FILE INFO *************************** ///
/// File Name: connections_repository.dart
/// Purpose: Connections repository — messaging Connections sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/message_module/services/error_handler.dart';
import '../../../../../core/helper/message_module/interface/entity/base_messaging_interface_parameters.dart';
import '../../../../../core/helper/message_module/interface/entity/user_category.dart';

abstract class ConnectionsRepositoryInterface {
  Future<Either<Failure, void>> createNewConnection({
    required BaseMessagingInterfaceParameters currentUser,
    required BaseMessagingInterfaceParameters newConnectionUser,
  });

  Stream<Either<Failure, dynamic>> getCurrentUserConnections({
    required String currentUserId,
    required List<UserCategory> categories, // ✅ add this line
  });
}