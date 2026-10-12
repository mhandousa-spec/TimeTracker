import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/notification/presentation/controller/notification_controller_cubit_main_core.dart';

import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f4_fillout/domain/repo/response_repo.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';

class SendResponseUseCase {
  final ResponseRepo responseRepo;

  SendResponseUseCase({required this.responseRepo});

  Future<Either<Failure, void>> execute(
      {required FormEntity model, required bool isEdit}) async {
    var response = await responseRepo.sendResponse(
      pages: model.pages,
      form: model,
      responseId: Get.find<MainCoreEmployeeController>().employeeEntity!.email!,
    );
    if (response.isLeft()) return response;
    if (isEdit) {
      NotificationControllerCubit().sendNotification(
          title: "A Submission Has Been Edited – ${model.formHeadModel.title}",
          arabicTitle: "تم تعديل رد - ${model.formHeadModel.arTitle}",
          body:
              "A previously submitted response to your form  ${model.formHeadModel.title} has been updated.",
          arabicBody: " تم تحديث رد سابق على النموذج الخاص بك ${model.formHeadModel.arTitle}",
          type: 'formBuilder',
          emails: [model.requestedBy!]);
    } else {
      NotificationControllerCubit().sendNotification(
          title: "New Submission Received on Your Form}",
          arabicTitle: "تم استلام رد جديد على النموذج الخاص بك",
          body:
              "A new response has been submitted to the form you created: ${model.formHeadModel.title}",
          arabicBody: "تم إرسال رد جديد على النموذج الذي أنشأته: ${model.formHeadModel.arTitle}",
          type: 'formBuilder',
          emails: [model.requestedBy!]);
    }

    return response;
  }
}
