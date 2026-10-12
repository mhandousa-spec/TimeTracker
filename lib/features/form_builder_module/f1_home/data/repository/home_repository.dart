import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/features/form_builder_module/f4_fillout/data/model/response_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f4_fillout/data/model/user_responses_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/data/data_source/home_remote_data_source.dart';

import 'package:knowticed_plus/core/network/failure_model.dart' as networkFailure;

class HomeRepository {
  HomeRemoteDataSource homeRemoteDataSource = HomeRemoteDataSource();
  getUserResponsesIds(String userId) async {
    Either<networkFailure.Failure, dynamic> response =
        await homeRemoteDataSource.getUserResponsesIds(userId);
    if (response.isLeft()) return null;
    Map<String, dynamic>? userResponsesJson = response.getOrElse(() => null);
    if (userResponsesJson == null) return null;
    UserResponsesModel userResponsesModel =
        UserResponsesModel.fromMap(userResponsesJson);
    return userResponsesModel;
  }

  getFormResponse(String formId, String employeeId) async {
    Either<networkFailure.Failure, dynamic> response =
        await homeRemoteDataSource.getFormResponse(formId, employeeId);
    if (response.isLeft()) return response;
    Map<String, dynamic>? formResponseJson = response.getOrElse(() => null);
    if (formResponseJson == null)
      return response = Left(networkFailure.FirebaseFailure("No data found"));
    ResponseModel formResponseModel =
        ResponseModel.fromMap(formResponseJson, employeeId);
    return response = Right(formResponseModel);
  }

  getFormNumberOfUsage(String id) async {
    return await homeRemoteDataSource.getFormNumberOfUsage(id);
  }
}
