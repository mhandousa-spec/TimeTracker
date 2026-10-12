
import 'package:knowticed_plus/core/helper/form_builder/fb_api_constants.dart';

import 'package:knowticed_plus/core/services/firebase/repository/firebase_repository.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';

class CommonRemoteDataSource{
  getFormPrivacy(String formId) async {
    return await FirebaseRepository.getDocumentWithId(
        collection: getBaseUrl(FormApiConstants.formPrivacy), documentId: formId);
  }
}