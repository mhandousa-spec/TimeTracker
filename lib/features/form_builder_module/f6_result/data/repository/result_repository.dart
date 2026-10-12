import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/features/form_builder_module/f4_fillout/data/model/response_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/data/data_source/result_remote_data_source.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/data/repository/common_repository.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/domain/base_repository/result_base_repository.dart';

class ResultRepository with CommonRepository implements ResultBaseRepository {
  ResultRemoteDataSource resultRemoteDataSource = ResultRemoteDataSource();

  @override
  Future<dynamic> getFormResponses({required String formId}) async {
    return await resultRemoteDataSource.getFormResponses(formId: formId);
  }

  @override
  Future<dynamic> remindUser(
      {required String userId, required String formId}) async {
    Either<Failure, dynamic> result = await resultRemoteDataSource
        .getUserResponse(userId: userId, formId: formId);
    if (result.isLeft()) return result;
    ResponseModel? responseModel = result.getOrElse(() => null);
    
    if (responseModel == null) {
       responseModel = ResponseModel(
         id:  userId,
        reminder: [Timestamp.now()],
        submittedBy: userId,
        pages: null,
        timestamps: [],
      );
    } else {
      responseModel.reminder.add(Timestamp.now());
    }
    return await resultRemoteDataSource.updateUserResponse(
        responseModel: responseModel!, formId: formId);
  }
}
