import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/form_privacy_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/data/data_source/common_remote_data_source.dart';

mixin CommonRepository{
  CommonRemoteDataSource commonRemoteDataSource = CommonRemoteDataSource();
  getFormPrivacy(String formId) async {
    Either<Failure, dynamic> result =
    await commonRemoteDataSource.getFormPrivacy(formId);
    if (result.isLeft()) return result;
    Map<String, dynamic>? map = result.getOrElse(() => null);
    if (map == null) return result = Left(FirebaseFailure('Error'));
    FormPrivacyModel? formPrivacyModel = FormPrivacyModel.fromMap(map);

    return result = Right(formPrivacyModel);
  }
}