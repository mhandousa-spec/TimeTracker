import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/helper/form_builder/fb_api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/services/firebase/repository/firebase_repository.dart';
import 'package:knowticed_plus/features/form_builder_module/f4_fillout/data/model/response_model.dart';

class ResultRemoteDataSource {
  Future<Either<Failure, dynamic>> getFormResponses(
      {required String formId}) async {
    Either<Failure, dynamic> result;
    try {
      CollectionReference collectionReference = FirebaseFirestore.instance
          .collection(getBaseUrl(FormApiConstants.formResponses +
              "/" +
              formId +
              '/' +
          FormApiConstants.responses));
      QuerySnapshot querySnapshot = await collectionReference.get();
      List<ResponseModel> responses = [];
      for (var doc in querySnapshot.docs) {
        responses.add(
            ResponseModel.fromMap(doc.data() as Map<String, dynamic>, doc.id));
      }
      result = Right(responses);
    } catch (e) {
      
      result = Left(FirebaseFailure(e.toString()));
    }
    return result;
  }

  Future<Either<Failure, dynamic>> getUserResponse(
      {required String userId, required String formId}) async {
    Either<Failure, dynamic> result;
    try {
      final response = await FirebaseFirestore.instance
          .collection(getBaseUrl(FormApiConstants.formResponses +
              "/" +
              formId +
              '/' +
          FormApiConstants.responses))
          .doc(userId)
          .get();
      if (response.exists) {
        ResponseModel responseModel = ResponseModel.fromMap(
            response.data() as Map<String, dynamic>, response.id);
        result = Right(responseModel);
      } else {
        result = Right(null);
      }
    } catch (e) {
      
      result = Left(FirebaseFailure(e.toString()));
    }
    return result;
  }

  updateUserResponse(
      {required ResponseModel responseModel, required String formId}) async {
    return await FirebaseRepository.setDocumentWithId(
        collection: getBaseUrl(FormApiConstants.formResponses +
            "/" +
            formId +
            '/' +
            FormApiConstants.responses),
        data: responseModel.toMap(),
        documentId: responseModel.id!);
  }
}
