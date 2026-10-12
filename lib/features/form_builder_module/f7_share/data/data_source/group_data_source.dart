import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/helper/form_builder/fb_api_constants.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/core/services/firebase/repository/firebase_repository.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/data/models/forms_group_model.dart';

/// Date: 21/2/2025
/// By: Fouad
/// Last update: 21/2/2025
/// Objectives: Implementation of group data source
class GroupDataSource {
  FirebaseFirestore db = FirebaseFirestore.instance;

  /// Creates a group in the data source
  ///
  /// [groupModel] The group model to be created
  ///
  /// Returns a [Future] with no value if the creation is successful,
  createGroup(
      FormsGroupModel groupModel, String id, String currentUserId) async {
    return await FirebaseRepository.setDocumentWithId(
        collection:
            "${getBaseUrl(FormApiConstants.formGroups)}/$currentUserId/${FormApiConstants.groups}",
        data: groupModel.toMap(),
        documentId: id);
  }

  /// Gets all active groups from the data source
  ///
  /// Returns a [Future] with a list of [FormsGroupModel] if the retrieval is successful
  getGroups({required String currentUserId}) async {
    return await FirebaseRepository.getDocumentsWithOneIsNotEqualToFilter(
      collectionPath:
          "${getBaseUrl(FormApiConstants.formGroups)}/$currentUserId/${FormApiConstants.groups}",
      filterKey: FormsGroupModel.fieldIsDeleted,
      filterValue: true,
    );
  }

  uploadImage(
      {required String image,
      required String userId,
      required String groupId}) async {
    String fileName = image.split('/').last.split('.').first;
    String ext = image.split('.').last;
    return await FirebaseRepository.uploadFile(
        collectionName: getBaseUrl("${FormApiConstants.storageBase}/$userId/$groupId"),
        documentName: "${fileName}_${Timestamp.now()}_$ext.ext",
        filePath: image);
  }

  deleteGroup({required String userId, required String groupId}) async {
    return await FirebaseRepository.setDocumentWithId(
        collection: getBaseUrl(
            "${FormApiConstants.formGroups}/$userId/${FormApiConstants.groups}"),
        data: {
          FormsGroupModel.fieldIsDeleted: true,
          FormsGroupModel.fieldTimestamp:
              FieldValue.arrayUnion([Timestamp.now()]),
        },
        documentId: groupId);
  }

  getGroupData({required String groupId, required String currentUserId}) async {
    return await FirebaseRepository.getDocumentWithId(
        collection: getBaseUrl(
            "${FormApiConstants.formGroups}/$currentUserId/${FormApiConstants.groups}"),
        documentId: groupId);
  }
}
