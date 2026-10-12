/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: forms_submission_summary.dart
/// Purpose: Real data for the Home "Forms Submission" card (form bug report
///          #25): the signed-in user's latest PUBLISHED form, and how many of
///          the people it was sent to have submitted it.
/// Created at: 26/9/2026
library;

import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/enums/form_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/form_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/form_privacy_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/remote_data_source/form_data_source.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/repo/form_repo_impl.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/data/repository/result_repository.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/controller/result_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/controller/result_state.dart';

/// Loads the latest published form and keeps a [ResultCubit] for it, so the
/// card can show the completion ring and send reminders with the exact same
/// logic as the Form Builder's Pending tab.
class FormsSubmissionSummary {
  final ResultCubit resultCubit =
      ResultCubit(resultRepository: ResultRepository());

  FormEntity? form;

  int get submitted {
    final s = resultCubit.state;
    return s is ResultLoaded ? s.submittedUsers.length : 0;
  }

  int get pending {
    final s = resultCubit.state;
    return s is ResultLoaded ? s.pendingUsers.length : 0;
  }

  double get completion {
    final total = submitted + pending;
    return total == 0 ? 0 : submitted / total;
  }

  /// Returns false when the user has no published form.
  Future<bool> load(TickerProvider vsync) async {
    if (!Get.isRegistered<MainCoreEmployeeController>()) return false;
    final email =
        Get.find<MainCoreEmployeeController>().employeeEntity?.email;
    if (email == null || email.isEmpty) return false;

    final repo = FormRepoImpl(formDataSource: FormDataSource());
    final Either<Failure, dynamic> result = await repo.getMyCreatedFroms(email);
    if (result.isLeft()) return false;

    final List<FormModel> models =
        List<FormModel>.from(result.getOrElse(() => <FormModel>[]) as List);

    final List<FormEntity> published = [];
    for (final model in models) {
      FormPrivacyModel privacy = FormPrivacyModel();
      final privacyResult = await repo.getFormPrivacy(model.id);
      privacyResult.fold((_) {}, (p) => privacy = p);
      final entity = FormEntity.fromModel(model, privacy);
      if (entity.status == FormStatus.publish) published.add(entity);
    }
    if (published.isEmpty) return false;

    published.sort((a, b) => b.createDate.compareTo(a.createDate));
    form = published.first;

    await resultCubit.initialize(form!, vsync);
    return true;
  }

  /// Sends every due reminder; returns how many went out.
  Future<int> remindAll() => resultCubit.remindAllClicked();

  void dispose() => resultCubit.close();
}
