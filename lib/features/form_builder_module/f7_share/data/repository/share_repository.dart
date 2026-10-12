import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/users_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/person_entity.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/form_privacy_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/domain/base_repository/share_base_repository.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/data/data_source/share_remote_data_source.dart';

class ShareRepository implements ShareBaseRepository {
  ShareRemoteDataSource shareRemoteDataSource = ShareRemoteDataSource();

  @override
  Future<dynamic> getFormPrivacy(String formId) async {
    Either<Failure, dynamic> result =
        await shareRemoteDataSource.getFormPrivacy(formId);
    if (result.isLeft()) return result;
    Map<String, dynamic>? map = result.getOrElse(() => null);
    FormPrivacyModel? formPrivacyModel;
    if (map != null)
      formPrivacyModel = FormPrivacyModel.fromMap(map);
    else {
      formPrivacyModel = FormPrivacyModel(
          timestamps: [],
          usersModel: UsersModel(
            emails: [],
            accessBegin: [],
            accessEnd: [],
            editPermission: [],
            status: [],
          ));
    }
    return result = Right(formPrivacyModel);
  }

  @override
  Future<dynamic> grantAccess(
      {required FormPrivacyModel formPrivacyModel,
      required String formId,
      required List<PersonEntity> persons,
      required DateTime timeBegin,
      required DateTime timeEnd,
      required bool isEditPermission}) async {
    
    formPrivacyModel.timestamps!.add(Timestamp.now());
    formPrivacyModel.usersModel!.emails ??= [];
    formPrivacyModel.usersModel!.accessBegin ??= [];
    formPrivacyModel.usersModel!.accessEnd ??= [];
    formPrivacyModel.usersModel!.editPermission ??= [];
    formPrivacyModel.usersModel!.status ??= [];

    for (PersonEntity person in persons) {
      formPrivacyModel.usersModel!.emails!.add(person.id);
      formPrivacyModel.usersModel!.accessBegin!
          .add(Timestamp.fromDate(timeBegin));
      formPrivacyModel.usersModel!.accessEnd!.add(Timestamp.fromDate(timeEnd));
      formPrivacyModel.usersModel!.editPermission!.add(isEditPermission);
      formPrivacyModel.usersModel!.status!.add("active");
    }
    return await shareRemoteDataSource.updateFormPrivacy(
        formPrivacyModel, formId);
  }
}
