import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:get/get.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/department.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/person_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/access_management.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/open_access_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/restricted_access_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';

import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/form_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/form_privacy_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/watermark_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/page_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f5_submissions/domain/entity/submissions.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/enums/form_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_head_data.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/page_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';

// Date: 21/1/2025
// By: mohamed Mohy
// Last update: 22/1/2025
// Objectives: Represents the model of a form containing head data and a list of services_management_module.
class FormEntity {
  /// Unique identifier for the form
  late String id;

  /// Number of times the form has been used
  late int numberUsed;

  /// Date of the form creation
  late DateTime createDate;
  DateTime? deleteDate;

  late DateTime? submissionDate, receivedDate;
  late String? requestedBy;

  /// Head data for form creation
  late FormHeadData formHeadModel;

  /// List of services_management_module in the form
  late List<PageEntity> pages;

  /// enum representing the status of the form
  late FormStatus status;
  bool isEdit;
  List<SubmissionsModel>? submissions = [];
  List<RequestedModel>? requests = [];
  OpenAccessModel? openAccessModel;
  RestrictedAccessModel? restrictedAccessModel;
  PersonEntity personEntity;
  bool isHasAccess;
  FormEntity(
      {required this.id,
      required this.status,
      required this.formHeadModel,
      required this.pages,
      required this.createDate,
      this.requestedBy,
      this.deleteDate,
      this.isEdit = false,
      this.isHasAccess = false,
      this.receivedDate,
      this.submissionDate,
      this.openAccessModel,
      this.restrictedAccessModel,
      this.numberUsed = 0,
      this.submissions,
      required this.personEntity});

  List<PageControllerModel> toControllers() {
    List<PageControllerModel> pagesController = [];
    for (var element in pages) {
      pagesController.add(element.toController());
    }
    return pagesController;
  }

  FormEntity duplicate() {
    FormHeadData newFormHeadModel = formHeadModel.duplicate();
    List<PageEntity> newPages = [];
    for (var element in pages) {
      newPages.add(element.duplicate());
    }
    FormEntity newFormModel = FormEntity(
      id: '${Get.find<MainCoreEmployeeController>().employeeEntity!.id}_${DateTime.now().toString()}',
      status: status,
      formHeadModel: newFormHeadModel,
      pages: newPages,
      createDate: createDate,
      submissionDate: submissionDate,
      receivedDate: receivedDate,
      requestedBy: requestedBy,
      numberUsed: numberUsed,
      openAccessModel: openAccessModel,
      restrictedAccessModel: restrictedAccessModel,
      personEntity: personEntity,
    );

    return newFormModel;
  }

  //to form model
  FormModel toModel() {
    return FormModel(
      id: id,
      timestamps: [Timestamp.fromDate(createDate)],
      createdByEmail:
          Get.find<MainCoreEmployeeController>().employeeEntity!.email!,
      arabicDescription: [formHeadModel.arDescription ?? ""],
      arabicTitle: [formHeadModel.arTitle ?? ""],
      description: [formHeadModel.description],
      title: [formHeadModel.title],
      image: formHeadModel.cover == null ? [] : [formHeadModel.cover ?? ''],
      accessMangement: [formHeadModel.accessManagement.toLowerCase()],
      orientation: [formHeadModel.orientation],
      horizontalPadding: [formHeadModel.horizontalPadding.toString()],
      verticalPadding: [formHeadModel.verticalPadding.toString()],
      formStatus: [status.name.toLowerCase()],
      watermark: WatermarkModel(
        imageUrl:
            formHeadModel.watermark == null ? [] : [formHeadModel.watermark!],
        imageName: formHeadModel.watermark == null
            ? []
            : [formHeadModel.watermark!.split('/').last.split('.').first],
        opacity: [formHeadModel.watermarkOpacity.toString()],
        size: [formHeadModel.watermarkSize.toString()],
      ),
      pages: pages.map((e) => e.toModel()).toList(),
    );
  }
  //from model

  static FormEntity fromModel(
      FormModel formModel, FormPrivacyModel formPrivacyModel,
      {int usedBy = 0, bool isEdit = false, bool isHasAccess = false}) {

    EmployeeEntityPro employeeEntity = Get.find<MainCoreEmployeeController>()
        .allEmployeesEntities!
        .firstWhere((element) => element.email == formModel.createdByEmail);

    return FormEntity(
      isEdit: isEdit,
      isHasAccess: isHasAccess,
      personEntity: PersonEntity.fromEmployeeEntity(employeeEntity),
      id: formModel.id,
      status: FormStatus.values.firstWhere((element) =>
      element.name.toLowerCase() ==
          formModel.formStatus!.last.toLowerCase()),
      formHeadModel: FormHeadData(
        title: formModel.title!.last,
        arTitle: formModel.arabicTitle!.last,
        description: formModel.description!.last,
        arDescription: formModel.arabicDescription!.last,
        cover: formModel.image!.lastOrNull,
        accessManagement: formModel.accessMangement!.last.capitalize!,
        orientation: formModel.orientation!.last,
        horizontalPadding: double.parse(formModel.horizontalPadding!.last),
        verticalPadding: double.parse(formModel.verticalPadding!.last),
        watermark: formModel.watermark!.imageUrl!.lastOrNull,
        watermarkOpacity: int.parse(formModel.watermark!.opacity!.last!),
        watermarkSize: int.parse(formModel.watermark!.size!.last!),
      ),
      pages: formModel.pages!.map((e) => PageEntity.fromModel(e)).toList(),
      createDate: formModel.timestamps.first.toDate(),
      requestedBy: formModel.createdByEmail,
      numberUsed: usedBy,
      deleteDate: formModel.formStatus.last.toLowerCase() ==
          FormStatus.deleted.name.toLowerCase()
          ? formModel.timestamps.last.toDate()
          : null,

      // ✅ FIX: Check if arrays are not empty before accessing .last
      openAccessModel: formModel.accessMangement!.last.toLowerCase() ==
          AccessManagement.openAccess.name.toLowerCase()
          ? OpenAccessModel(
        selectedDepartments: (formPrivacyModel.usersModel?.emails != null &&
            formPrivacyModel.usersModel!.emails!.isNotEmpty)
            ? formPrivacyModel.usersModel!.emails!
            .map((e) => DepartmentEntity(
            nameAr: Get.find<MainCoreDepartmentCubit>()
                .getDepartmentName(
                Get.find<MainCoreEmployeeController>()
                    .getLocaleEmployee(e!)!
                    .departmentId!,
                false),
            name: Get.find<MainCoreDepartmentCubit>()
                .getDepartmentName(
                Get.find<MainCoreEmployeeController>()
                    .getLocaleEmployee(e)!
                    .departmentId!,
                true),
            id: Get.find<MainCoreEmployeeController>()
                .getLocaleEmployee(e)!
                .departmentId!))
            .toList()
            : [], // Return empty list if no emails
        isEdit: isEdit,
        timeBegin: (formPrivacyModel.usersModel?.accessBegin != null &&
            formPrivacyModel.usersModel!.accessBegin!.isNotEmpty)
            ? formPrivacyModel.usersModel!.accessBegin!.last?.toDate()
            : null,
        timeEnd: (formPrivacyModel.usersModel?.accessEnd != null &&
            formPrivacyModel.usersModel!.accessEnd!.isNotEmpty)
            ? formPrivacyModel.usersModel!.accessEnd!.last?.toDate()
            : null,
      )
          : null,

      // ✅ FIX: Check if arrays are not empty before accessing .last
      restrictedAccessModel: formModel.accessMangement!.last.toLowerCase() !=
          AccessManagement.personalAccess.name.toLowerCase()
          ? RestrictedAccessModel(
        isEdit: (formPrivacyModel.usersModel?.editPermission != null &&
            formPrivacyModel.usersModel!.editPermission!.isNotEmpty)
            ? formPrivacyModel.usersModel!.editPermission!.last
            : false,
        timeBegin: (formPrivacyModel.usersModel?.accessBegin != null &&
            formPrivacyModel.usersModel!.accessBegin!.isNotEmpty)
            ? formPrivacyModel.usersModel!.accessBegin!.last?.toDate()
            : null,
        timeEnd: (formPrivacyModel.usersModel?.accessEnd != null &&
            formPrivacyModel.usersModel!.accessEnd!.isNotEmpty)
            ? formPrivacyModel.usersModel!.accessEnd!.last?.toDate()
            : null,
        selectedPersons: formPrivacyModel.usersModel != null
            ? PersonEntity.fromUsersModel(formPrivacyModel.usersModel!)
            : null,
      )
          : null,
    );
  }

  String get getTitle {
    if (Get.context!.isArabic) {
      if (formHeadModel.arTitle != null && formHeadModel.arTitle!.isNotEmpty) {
        return formHeadModel.arTitle ?? '';
      }
    }

    return formHeadModel.title ?? '';
  }
}
