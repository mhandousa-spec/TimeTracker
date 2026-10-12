// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:knowticed_plus/core/helper/form_builder/fb_api_constants.dart';
import 'package:path/path.dart';

import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/enums/form_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/form_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/form_privacy_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/users_model.dart';

// Date: 14/2/2025
// By: Fouad
// Last update: 19/2/2025
// Objectives: Implementation of form data source
class FormDataSource {
  FirebaseFirestore db = FirebaseFirestore.instance;

  /// Creates a NEW form in the data source
  ///
  /// [formModel] The form model to be created
  ///
  /// Returns a [Future] with no value if the creation is successful
  Future<void> createForm(FormModel formModel) async {
    await db
        .collection(getBaseUrl(FormApiConstants.forms))
        .doc(formModel.id)
        .set(formModel.toMap(), SetOptions(merge: false)); // ✅ merge: false for new forms
  }

  /// Updates an EXISTING form in the data source
  ///
  /// [formModel] The form model to be updated
  ///
  /// Returns a [Future] with no value if the update is successful
  Future<void> updateForm(FormModel formModel) async {
    await db
        .collection(getBaseUrl(FormApiConstants.forms))
        .doc(formModel.id)
        .set(formModel.toMap(), SetOptions(merge: true)); // ✅ merge: true for updates
  }

  /// Marks a form as deleted by adding a deleted status
  ///
  /// [formModel] The form model to be deleted
  ///
  /// Returns a [Future] with no value if the deletion is successful
  Future<void> deletedForm(FormModel formModel) async {
    formModel.formStatus!.add(FormStatus.deleted.name.toLowerCase());
    formModel.timestamps.add(Timestamp.now());
    await db
        .collection(getBaseUrl(FormApiConstants.forms))
        .doc(formModel.id)
        .set(formModel.toMap(), SetOptions(merge: true));
  }

  /// Restores a deleted form to the status it held before it was deleted.
  ///
  /// [formModel] The form model to be restored
  ///
  /// CHANGED 19/8/2026: this appended `publish` unconditionally, so restoring a
  /// deleted DRAFT published it — a form that had never been published landed in
  /// the Publish tab, visible to everyone it was shared with.
  ///
  /// `formStatus` is an append-only history (`deletedForm` above adds to it
  /// rather than replacing), so the previous state is still on the record: it is
  /// the last entry that is not 'deleted'. Appending that value returns the form
  /// to the tab it came from and keeps the history honest — a reader can still
  /// see it was published, deleted, then restored.
  ///
  /// Returns a [Future] with no value if the restoration is successful
  Future<void> restoreForm(FormModel formModel) async {
    formModel.formStatus.add(_statusBeforeDelete(formModel));
    formModel.timestamps.add(Timestamp.now());
    await db
        .collection(getBaseUrl(FormApiConstants.forms))
        .doc(formModel.id)
        .set(formModel.toMap(), SetOptions(merge: true));
  }

  /// The last status in [formModel]'s history that is not 'deleted', lowercased
  /// the same way every other writer here stores it.
  ///
  /// Scanning backwards rather than reading `formStatus[length - 2]` on purpose:
  /// a form can be deleted, restored and deleted again, and older records were
  /// written before this method existed, so consecutive 'deleted' entries are
  /// possible. Falls back to 'publish' — restore's previous unconditional
  /// behaviour — when the history contains nothing else.
  String _statusBeforeDelete(FormModel formModel) {
    final String deleted = FormStatus.deleted.name.toLowerCase();

    for (int i = formModel.formStatus.length - 1; i >= 0; i--) {
      final String entry = formModel.formStatus[i].toLowerCase();
      if (entry != deleted) return entry;
    }

    return FormStatus.publish.name.toLowerCase();
  }

  /// Adds form privacy to the data source
  ///
  /// [formPrivacyModel] The form privacy model to be added
  /// [formId] The id of the form to add the privacy to
  ///
  /// Returns a [Future] with no value if the addition is successful
  Future<void> addFormPrivacy(
      FormPrivacyModel formPrivacyModel, String formId) async {
    await db
        .collection(getBaseUrl(FormApiConstants.formPrivacy))
        .doc(formId)
        .set(formPrivacyModel.toMap(), SetOptions(merge: true));
  }

  /// Gets all forms from the data source
  ///
  /// Returns a [Future] with a list of [FormModel] if the retrieval is successful
  Future<List<FormModel>> getForms() async {
    List<FormModel> forms = [];
    await db
        .collection(getBaseUrl(FormApiConstants.forms))
        .get()
        .then((value) => value.docs.forEach((element) {
      forms.add(FormModel.fromMap(element.data()));
    }));
    return forms;
  }

  /// Retrieves the privacy settings for a specific form from the data source
  ///
  /// [formId] The ID of the form whose privacy settings are to be retrieved
  ///
  /// Returns a [Future] containing a [FormPrivacyModel] that represents the
  /// privacy settings of the specified form
  Future<FormPrivacyModel> getFormPrivacy(String formId) async {
    FormPrivacyModel formPrivacyModel = FormPrivacyModel();
    await db
        .collection(getBaseUrl(FormApiConstants.formPrivacy))
        .doc(formId)
        .get()
        .then((value) =>
    formPrivacyModel = FormPrivacyModel.fromMap(value.data()!));
    return formPrivacyModel;
  }

  /// Uploads a file to Firebase Storage
  ///
  /// [filePath] The path to the file to be uploaded
  /// [storagePath] The path in the storage to upload the file to
  ///
  /// Returns a [Future] with the download URL of the file if the upload is successful,
  /// or [null] if there is an error during the upload
  Future<String?> uploadFile(String filePath, String storagePath) async {
    try {
      File file = File(filePath);
      String fileName = basename(file.path);
      Reference storageRef =
      FirebaseStorage.instance.ref().child('$storagePath/$fileName');

      final metadata = SettableMetadata(contentType: 'image/jpeg');
      final uploadTask = await storageRef.putFile(file, metadata);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  /// Retrieves a single form by its ID
  ///
  /// [id] The ID of the form to retrieve
  ///
  /// Returns a [Future] with a map containing the form data, or null if not found
  Future<Map<String, dynamic>?> getForm(String id) async {
    final result =
    await db.collection(getBaseUrl(FormApiConstants.forms)).doc(id).get();
    return result.data();
  }

  /// Retrieves all forms created by a specific user
  ///
  /// [currentUserId] The email/ID of the user whose forms to retrieve
  ///
  /// Returns a [Future] with a list of [FormModel] created by the user
  Future<List<FormModel>> getUserCreatedForms(String currentUserId) async {
    final forms = await db
        .collection(getBaseUrl(FormApiConstants.forms))
        .where(FormModel.fieldCreatedByEmail, isEqualTo: currentUserId)
        .get()
        .then((value) =>
        value.docs.map((e) => FormModel.fromMap(e.data())).toList());
    return forms;
  }

  /// Retrieves all forms that the current user has access to
  ///
  /// [currentUserId] The email/ID of the user
  ///
  /// Returns a [Future] with a list of [FormPrivacyModel] representing accessible forms
  Future<List<FormPrivacyModel>> getAllMyAccessData(String currentUserId) async {
    final accessData = await db
        .collection(getBaseUrl(FormApiConstants.formPrivacy))
        .where("${FormPrivacyModel.fieldUid}.${UsersModel.EMAILSFEILD}",
        arrayContains: currentUserId)
        .get()
        .then((value) => value.docs
        .map((e) => FormPrivacyModel.fromMap(e.data(), id: e.id))
        .toList());
    return accessData;
  }
}