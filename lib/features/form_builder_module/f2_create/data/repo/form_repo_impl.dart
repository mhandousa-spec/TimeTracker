import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/form_privacy_model.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/repo/form_repo.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/form_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/remote_data_source/form_data_source.dart';

import 'package:knowticed_plus/core/helper/form_builder/fb_api_constants.dart';
// Date: 14/2/2025
// By: Fouad
// Last update: 19/2/2025
// Objectives: Implementation of form repository
class FormRepoImpl extends FormRepo {
  final FormDataSource formDataSource;

  FormRepoImpl({required this.formDataSource});

  @override
  /// Creates a NEW form in the data source
  ///
  /// [formModel] The form model to be created
  ///
  /// Returns a [Right] with null if the creation is successful, a [Left] with a [Failure]
  /// if the creation fails
  Future<Either<Failure, void>> createForm(FormModel formModel) async {
    try {

      await uploadImagesIfExist(formModel);
      await formDataSource.createForm(formModel);

      return const Right(null);
    } catch (e) {
      
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  /// Updates an EXISTING form in the data source
  ///
  /// [formModel] The form model to be updated
  ///
  /// Returns a [Right] with null if the update is successful, a [Left] with a [Failure]
  /// if the update fails
  Future<Either<Failure, void>> updateForm(FormModel formModel) async {
    try {

      // Get existing form data
      Map<String, dynamic>? existingData = await formDataSource.getForm(formModel.id);

      if (existingData == null) {
        
        return Left(FirebaseFailure("Form not found"));
      }

      FormModel existingForm = FormModel.fromMap(existingData);

      // Upload new images if they exist
      await uploadImagesIfExist(formModel);

      // Merge with existing data
      FormModel mergedForm = _mergeFormData(formModel, existingForm);

      // Update in database
      await formDataSource.updateForm(mergedForm);

      return const Right(null);
    } catch (e) {
      
      return Left(FirebaseFailure(e.toString()));
    }
  }

  /// Merges new form data with existing form data
  /// This is a PRIVATE helper method (note the underscore prefix)
  FormModel _mergeFormData(FormModel newForm, FormModel oldForm) {

    oldForm.timestamps.add(newForm.timestamps!.last);

    

    // Only add if values changed
    if (oldForm.image!.lastOrNull != newForm.image!.lastOrNull) {
      oldForm.image!.add(newForm.image!.last);
    }
    if (oldForm.title.last != newForm.title!.last) {
      oldForm.title.add(newForm.title!.last);
    }
    if (oldForm.description!.last != newForm.description!.last) {
      oldForm.description!.add(newForm.description!.last);
    }
    if (oldForm.arabicTitle!.last != newForm.arabicTitle!.last) {
      oldForm.arabicTitle!.add(newForm.arabicTitle!.last);
    }
    if (oldForm.arabicDescription!.last != newForm.arabicDescription!.last) {
      oldForm.arabicDescription!.add(newForm.arabicDescription!.last);
    }
    if (oldForm.accessMangement!.last != newForm.accessMangement!.last) {
      oldForm.accessMangement!.add(newForm.accessMangement!.last);
    }
    if (oldForm.orientation!.last != newForm.orientation!.last) {
      oldForm.orientation!.add(newForm.orientation!.last);
    }
    if (oldForm.horizontalPadding!.last != newForm.horizontalPadding!.last) {
      oldForm.horizontalPadding!.add(newForm.horizontalPadding!.last);
    }
    if (oldForm.verticalPadding!.last != newForm.verticalPadding!.last) {
      oldForm.verticalPadding!.add(newForm.verticalPadding!.last);
    }
    if (oldForm.formStatus!.last != newForm.formStatus!.last) {
      oldForm.formStatus!.add(newForm.formStatus!.last);
    }
    if (oldForm.watermark!.imageName!.lastOrNull != newForm.watermark!.imageName!.lastOrNull) {
      oldForm.watermark!.imageName!.add(newForm.watermark!.imageName!.last);
    }
    if (oldForm.watermark!.imageUrl!.lastOrNull != newForm.watermark!.imageUrl!.lastOrNull) {
      oldForm.watermark!.imageUrl!.add(newForm.watermark!.imageUrl!.last);
    }
    if (oldForm.watermark!.opacity!.last != newForm.watermark!.opacity!.last) {
      oldForm.watermark!.opacity!.add(newForm.watermark!.opacity!.last);
    }
    if (oldForm.watermark!.size!.last != newForm.watermark!.size!.last) {
      oldForm.watermark!.size!.add(newForm.watermark!.size!.last);
    }

    // Replace services_management_module entirely
    oldForm.pages.clear();
    oldForm.pages.addAll(newForm.pages);

    return oldForm;
  }

  Future<void> uploadImagesIfExist(FormModel formModel) async {
    if (formModel.image!.isNotEmpty &&
        !formModel.image!.last.contains("http")) {
      final formImagePath = await uploadFile(
          formModel.image!.last,
          "${getBaseUrl(FormApiConstants.storageBase)}/${formModel.title.last}/FormAssets/${formModel.title.last}_${Timestamp.now()}_${formModel.image!.last.split('.').last}.${formModel.image!.last.split('.').last}");
      if (formImagePath.isRight()) {
        formModel.image!.removeLast();
        formModel.image!.add(formImagePath.getOrElse(() => ""));
      }
    }
    // do the same for watermark image
    if (formModel.watermark.imageUrl.isNotEmpty &&
        !formModel.watermark.imageUrl.last.contains("http")) {
      final watermarkImagePath = await uploadFile(
          formModel.watermark.imageUrl!.last,
          "${getBaseUrl(FormApiConstants.storageBase)}/${formModel.title.last}/FormAssets/${formModel.title.last}_${Timestamp.now()}_${formModel.watermark.imageUrl!.last.split('.').last}.${formModel.watermark.imageUrl!.last.split('.').last}");
      if (watermarkImagePath.isRight()) {
        formModel.watermark.imageUrl.removeLast();
        formModel.watermark.imageUrl
            .add(watermarkImagePath.getOrElse(() => ""));
      }
    }
  }

  @override
  /// Uploads a file to the data source
  ///
  /// [filePath] The path to the file to be uploaded
  /// [storagePath] The path in the storage to upload the file to
  ///
  /// Returns a [Right] with the download URL of the file if the upload is successful,
  /// a [Left] with a [Failure] if the upload fails
  Future<Either<Failure, String>> uploadFile(
      String filePath, String storagePath) async {
    try {
      String? url = await formDataSource.uploadFile(filePath, storagePath);
      return Right(url!);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  /// Gets all forms from the data source
  ///
  /// Returns a [Right] with a list of [FormModel] if the retrieval is successful, a [Left] with a [Failure]
  /// if the retrieval fails
  Future<Either<Failure, List<FormModel>>> getForms() async {
    try {
      var forms = await formDataSource.getForms();
      return Right(forms);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  /// Adds form privacy to the data source
  ///
  /// [formPrivacyModel] The form privacy model to be added
  /// [formId] The id of the form to add the privacy to
  ///
  /// Returns a [Right] with no value if the addition is successful,
  /// a [Left] with a [Failure] if the addition fails
  Future<Either<Failure, void>> addFormPrivacy(
      FormPrivacyModel formPrivacyModel, String formId) async {
    try {
      await formDataSource.addFormPrivacy(formPrivacyModel, formId);
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  /// Gets the form privacy from the data source
  ///
  /// [formId] The id of the form to get the privacy of
  ///
  /// Returns a [Right] with the [FormPrivacyModel] if the retrieval is successful, a [Left] with a [Failure]
  /// if the retrieval fails
  Future<Either<Failure, FormPrivacyModel>> getFormPrivacy(
      String formId) async {
    try {
      var formPrivacyModel = await formDataSource.getFormPrivacy(formId);
      return Right(formPrivacyModel);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  /// Deletes a form from the data source
  ///
  /// [formModel] The form model to be deleted
  ///
  /// Returns a [Right] with no value if the deletion is successful, a [Left] with a [Failure]
  /// if the deletion fails
  Future<Either<Failure, void>> deleteForm(FormModel formModel) async {
    try {
      await formDataSource.deletedForm(formModel);
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> restoreForm(FormModel formModel) async {
    try {
      await formDataSource.restoreForm(formModel);
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  getMyCreatedFroms(String currentUserId) async {
    Either<Failure, dynamic> result;
    try {
      List<FormModel> forms =
      await formDataSource.getUserCreatedForms(currentUserId);
      result = Right(forms);
    } catch (e) {
      result = Left(FirebaseFailure(e.toString()));
    }
    return result;
  }

  @override
  getAllMyAccessData(String currentUserId) async {
    Either<Failure, dynamic> result;
    try {
      List<FormPrivacyModel> forms =
      await formDataSource.getAllMyAccessData(currentUserId);
      result = Right(forms);
    } catch (e) {
      
      result = Left(FirebaseFailure(e.toString()));
    }
    return result;
  }

  @override
  getForm(String formId) async {
    Either<Failure, dynamic> result;
    try {
      Map<String, dynamic>? form = await formDataSource.getForm(formId);
      result = Right(form);
    } catch (e) {
      result = Left(FirebaseFailure(e.toString()));
    }
    return result;
  }
}