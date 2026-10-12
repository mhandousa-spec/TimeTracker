
import 'package:knowticed_plus/core/helper/form_builder/fb_api_constants.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/form_privacy_model.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';

import 'package:knowticed_plus/core/services/firebase/repository/firebase_repository.dart';

class ShareRemoteDataSource {
  getFormPrivacy(String formId) async {
    return await FirebaseRepository.getDocumentWithId(
        collection: getBaseUrl(FormApiConstants.formPrivacy), documentId: formId);
  }

  updateFormPrivacy(FormPrivacyModel formPrivacyModel, String formId) async {
    return await FirebaseRepository.setDocumentWithId(
        collection: getBaseUrl(FormApiConstants.formPrivacy),
        documentId: formId,
        data: formPrivacyModel.toMap());
  }
}
