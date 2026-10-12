/// Module: services_app_module/share
///
/// FILE INFO
/// File Name   : share_base_repository.dart
/// Objective   : Domain contract for share/access operations. Presentation
///               depends on this interface instead of the concrete data
///               implementation (§3, §4.3).
library;

import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/form_privacy_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/person_entity.dart';

abstract class ShareBaseRepository {
  Future<dynamic> getFormPrivacy(String formId);

  Future<dynamic> grantAccess({
    required FormPrivacyModel formPrivacyModel,
    required String formId,
    required List<PersonEntity> persons,
    required DateTime timeBegin,
    required DateTime timeEnd,
    required bool isEditPermission,
  });
}
