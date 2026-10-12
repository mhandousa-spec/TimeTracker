import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/page_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f4_fillout/data/model/response_model.dart';

// Date: 21/2/2025
// By: Fouad
// Last update: 21/2/2025
// Objectives: Interface for response repository
abstract class ResponseRepo {
  Future<Either<Failure, void>> sendResponse(
      {required List<PageEntity> pages, required FormEntity form, required String responseId});

  Future<Either<Failure, List<ResponseModel>>> getUserResponses();
}
