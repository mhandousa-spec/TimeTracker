import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:knowticed_plus/core/custom/62-custom_date_time_helper.dart';
import 'package:knowticed_plus/features/form_builder_module/f4_fillout/data/model/user_responses_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/page_entity.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';

import 'package:knowticed_plus/core/network/failure_model.dart' as networkFailure;
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f4_fillout/domain/repo/response_repo.dart';
import 'package:knowticed_plus/features/form_builder_module/f4_fillout/data/data_source/response_data_source.dart';
import 'package:knowticed_plus/features/form_builder_module/f4_fillout/data/model/response_model.dart';

import 'package:knowticed_plus/core/helper/form_builder/fb_api_constants.dart';
// Date: 21/2/2025
// By: Fouad
// Last update: 21/2/2025
// Objectives: Implementation of response repository
class ResponseRepoImpl extends ResponseRepo {
  final ResponseDataSource responseDataSource;
  ResponseRepoImpl({required this.responseDataSource});

  @override
  Future<Either<Failure, List<ResponseModel>>> getUserResponses() async {

    try {
      var responses = await responseDataSource.getUserResponses();

      
      return Right(responses);
    } catch (e, stackTrace) {

      
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendResponse({
    required List<PageEntity> pages,
    required FormEntity form,
    required String responseId
  }) async {

    

    try {
      // Upload media
      
      Either<Failure, dynamic> response = await uploadMedia(
          pages: pages,
          form: form,
          responseId: responseId
      );

      if (response.isLeft()) {

        return response;
      }

      // Create response model
      
      ResponseModel responseModel = ResponseModel(
          reminder: [],
          pages: pages.map((page) => page.toModel()).toList(),
          submittedBy: responseId,
          timestamps: [Timestamp.now()]
      );

      // Save response
      
      await responseDataSource.saveResponse(responseModel, form.id);

      // Update user response IDs
      
      await updateUserResponseIds(
          responseModel.submittedBy,
          responseModel.timestamps.last,
          form.id
      );

      
      
      return const Right(null);

    } catch (e, stackTrace) {

      
      return Left(FirebaseFailure(e.toString()));
    }
  }

  updateUserResponseIds(
      String submittedBy,
      Timestamp submissionTime,
      String formId
      ) async {

    

    try {
      // Get existing user response IDs
      
      Either<networkFailure.Failure, dynamic> response =
      await responseDataSource.getUserResponseIds(submittedBy);

      if (response.isLeft()) {

        return response;
      }

      Map<String, dynamic>? data = response.getOrElse(() => null);

      UserResponsesModel userResponsesModel;
      if (data != null) {
        
        userResponsesModel = UserResponsesModel.fromMap(data);
        
      } else {
        
        userResponsesModel = UserResponsesModel(
            email: submittedBy,
            formIds: [],
            submissionTimestamp: []
        );
      }

      // Add new form ID and timestamp
      userResponsesModel.formIds.add(formId);
      userResponsesModel.submissionTimestamp.add(submissionTime);

      // Save updated user response IDs
      
      final result = await responseDataSource.saveUserResponseIds(userResponsesModel);

      
      return result;

    } catch (e, stackTrace) {

      
      rethrow;
    }
  }

  /// Method Name: [uploadMedia]
  ///
  /// Purpose: upload all media files in response
  ///
  /// Parameters:
  ///            services_management_module [PageEntity] - list of services_management_module in the response
  ///            form [FormEntity] - form entity
  ///            responseId [String] - response id
  ///
  /// Returns:
  ///          Either<Failure, dynamic> - returns a [Right] if successful, [Left] if failed
  uploadMedia({
    required List<PageEntity> pages,
    required FormEntity form,
    required String responseId
  }) async {

    

    Either<Failure, dynamic> result;
    String mediaPath = getBaseUrl(
        "${FormApiConstants.storageBase}/${form.personEntity.department}/${form.id}/Responses/$responseId/ResponseData"
    );

    String fileNamePrefix =
        "${form.formHeadModel.title}_${responseId}_${FormDateTimeHelper.getMediaTimestamp(Timestamp.now())}";

    try {
      int pageCount = 0;
      for (var page in pages) {
        pageCount++;

        int rowCount = 0;
        for (var row in page.rows) {
          rowCount++;

          int fieldCount = 0;
          for (var field in row.fields) {
            fieldCount++;

            try {
              await field.uploadMedia(
                  mediaPath: mediaPath,
                  fileNamePrefix: fileNamePrefix
              );
              
            } catch (e) {
              
            }
          }
        }
      }

      result = const Right(null);
      
    } catch (e, stackTrace) {

      result = Left(FirebaseFailure(e.toString()));
    }

    return result;
  }
}