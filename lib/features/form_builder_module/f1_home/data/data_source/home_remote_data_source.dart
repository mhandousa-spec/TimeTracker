import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/helper/form_builder/fb_api_constants.dart';
import 'package:knowticed_plus/features/form_builder_module/f4_fillout/data/model/user_responses_model.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';

import 'package:knowticed_plus/core/services/firebase/repository/firebase_repository.dart';

class HomeRemoteDataSource {
  getUserResponsesIds(String userId) async {
    return await FirebaseRepository.getDocumentWithId(
        collection: FormApiConstants.userResponses, documentId: userId);
  }

  getFormResponse(String formId, String employeeId) async {
    return await FirebaseRepository.getDocumentWithId(
      collection: getBaseUrl(
          "${FormApiConstants.formResponses}/$formId/${FormApiConstants.responses}"),
      documentId: employeeId,
    );
  }

  getFormNumberOfUsage(String id) async {
    try {
      CollectionReference userPrivacy =
          FirebaseFirestore.instance.collection(FormApiConstants.userResponses);
      var response = await userPrivacy
          .where(UserResponsesModel.formIdsField, arrayContains: id)
          .count()
          .get();
      return response.count ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
