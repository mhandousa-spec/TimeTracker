// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/form_builder/fb_api_constants.dart';
import 'package:knowticed_plus/core/helper/form_builder/fb_api_constants.dart';
import 'package:knowticed_plus/features/form_builder_module/f4_fillout/data/model/user_responses_model.dart';

import 'package:knowticed_plus/core/services/firebase/repository/firebase_repository.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/form_builder_module/f4_fillout/data/model/response_model.dart';

// Date: 21/2/2025
// By: Fouad
// Last update: 21/2/2025
// Objectives: Implementation of response data source
class ResponseDataSource {
  FirebaseFirestore db = FirebaseFirestore.instance;

  /// Saves a response to the data source
  ///
  /// [responseModel] The response model to be saved
  /// [formId] The id of the form to save the response to
  ///
  /// Returns a [Future] with no value when the saving is successful.
  Future<void> saveResponse(ResponseModel responseModel, String formId) async {

    

    try {
      final path = getBaseUrl(FormApiConstants.formResponses);

      await db
          .collection(path)
          .doc(formId)
          .collection(FormApiConstants.responses)
          .doc(responseModel.submittedBy)
          .set(responseModel.toMap(), SetOptions(merge: true));

    } catch (e, stackTrace) {

      rethrow;
    }
    
  }

  // get user responses at all forms
  Future<List<ResponseModel>> getUserResponses() async {

    List<ResponseModel> responses = [];

    try {
      // Check if employee controller is initialized
      
      final employeeController = Get.find<MainCoreEmployeeController>();

      if (employeeController.employeeEntity == null) {
        
        return responses;
      }

      final currentUserEmail = employeeController.employeeEntity!.email;

      // Get collection path
      final collectionPath = getBaseUrl(FormApiConstants.formResponses);

      // Get all form response documents
      final querySnapshot = await db.collection(collectionPath).get();

      if (querySnapshot.docs.isEmpty) {
        
        return responses;
      }

      // Process each form document
      int processedDocs = 0;
      for (var doc in querySnapshot.docs) {
        processedDocs++;

        try {
          // Get responses subcollection
          final responsesQuery = await doc.reference
              .collection(FormApiConstants.responses)
              .where('Submitted_By', isEqualTo: currentUserEmail)
              .get();

          // Process each response
          for (var responseDoc in responsesQuery.docs) {

            try {
              final responseData = responseDoc.data() as Map<String, dynamic>;

              final response = ResponseModel.fromMap(responseData, responseDoc.id);
              responses.add(response);
              
            } catch (e, stackTrace) {

            }
          }
        } catch (e, stackTrace) {

        }
      }

    } catch (e, stackTrace) {

    }

    return responses;
  }

  getUserResponseIds(String submittedBy) async {

    

    try {
      final result = await FirebaseRepository.getDocumentWithId(
          collection: FormApiConstants.userResponses,
          documentId: submittedBy);

      if (result.isRight()) {
        
      }

      return result;
    } catch (e, stackTrace) {

      
      rethrow;
    }
  }

  saveUserResponseIds(UserResponsesModel userResponsesModel) async {

    

    try {
      final result = await FirebaseRepository.setDocumentWithId(
          collection: FormApiConstants.userResponses,
          documentId: userResponsesModel.email,
          data: userResponsesModel.toMap());

      
      return result;
    } catch (e, stackTrace) {

      
      rethrow;
    }
  }
}