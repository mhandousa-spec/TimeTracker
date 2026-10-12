/// Module: messaging / connections / domain/use_cases/create_new_connection_use_case.dart
/// ************************* FILE INFO *************************** ///
/// File Name: create_new_connection_use_case.dart
/// Purpose: Create new connection use case — messaging Connections sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/message_module/services/error_handler.dart';
import '../../../../../core/helper/message_module/interface/entity/base_messaging_interface_parameters.dart';
import '../base_repository/base_connections_repository.dart';

class CreateNewConnectionUseCase {
  final ConnectionsRepositoryInterface connectionRepository;

  CreateNewConnectionUseCase({required this.connectionRepository});

  Future<Either<Failure, void>>  createNewConnection(
      {required BaseMessagingInterfaceParameters currentUser,
      required BaseMessagingInterfaceParameters newConnectionUser})async {
    return await connectionRepository.createNewConnection(
        currentUser: currentUser, newConnectionUser: newConnectionUser);
  }
}
