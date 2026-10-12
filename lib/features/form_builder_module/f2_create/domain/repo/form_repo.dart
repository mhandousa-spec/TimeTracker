import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/form_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/form_privacy_model.dart';

// Date: 14/2/2025
// By: Fouad
// Last update: 19/2/2025
// Objectives: Interface for form repository

abstract class FormRepo {
  /// Creates a new form in the database using the provided [FormModel].
  /// Returns a [Right] with a null value if the operation is successful,
  /// otherwise returns a [Left] with a [Failure] object.
  Future<Either<Failure, void>> createForm(FormModel formModel);

  /// Updates an existing form in the database using the provided [FormModel].
  /// Returns a [Right] with a null value if the operation is successful,
  /// otherwise returns a [Left] with a [Failure] object.
  Future<Either<Failure, void>> updateForm(FormModel formModel);

  /// Deletes a form from the database using the provided [FormModel].
  /// Returns a [Right] with a null value if the operation is successful,
  Future<Either<Failure, void>> deleteForm(FormModel formModel);

  /// Restores a form from the database using the provided [FormModel].
  /// Returns a [Right] with a null value if the operation is successful,
  Future<Either<Failure, void>> restoreForm(FormModel formModel);

  /// Adds a new form privacy to the database using the provided [FormPrivacyModel].
  /// Returns a [Right] with a null value if the operation is successful,
  /// otherwise returns a [Left] with a [Failure] object.
  Future<Either<Failure, void>> addFormPrivacy(
      FormPrivacyModel formPrivacyModel, String formId);

  /// Retrieves a list of forms from the database.
  /// Returns a [Right] with a list of [FormModel] objects if the operation is
  /// successful, otherwise returns a [Left] with a [Failure] object.
  Future<Either<Failure, List<FormModel>>> getForms();

  /// Retrieves the privacy settings for a specific form from the database.
  /// Returns a [Right] with a [FormPrivacyModel] object if the operation is
  /// successful, otherwise returns a [Left] with a [Failure] object.
  Future<Either<Failure, FormPrivacyModel>> getFormPrivacy(String formId);

  /// Uploads a file to the specified storage path in the cloud.
  ///
  /// [filePath]: The path to the file that will be uploaded.
  /// [storagePath]: The path in the cloud where the file will be uploaded.
  ///
  /// Returns a [Right] with the URL of the uploaded file if the operation is
  /// successful, otherwise returns a [Left] with a [Failure] object.
  Future<Either<Failure, String>> uploadFile(
      String filePath, String storagePath);

  getMyCreatedFroms(String currentUserId);

  getAllMyAccessData(String currentUserId);

  getForm(String s);
}