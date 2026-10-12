
import 'package:get/get.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/users_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';

class PersonEntity {
  String department, id;
  bool isSelected;
  String image;
  String arabicName;
  String englishName;
  String titleEnglish;
  String titleArabic;
  String phone;

  PersonEntity(
      {required this.department,
      required this.id,
      required this.isSelected,
      required this.image,
      required this.arabicName,
      required this.englishName,
      required this.titleEnglish,
      required this.titleArabic,
      required this.phone
      });

static  fromEmployeeEntity(EmployeeEntityPro employeeEntity) {
    return PersonEntity(
      phone: (employeeEntity.mobilePhone?.countryCode??"")+ (employeeEntity.mobilePhone?.phone??""),
      department: employeeEntity.departmentId!,
      id: employeeEntity.email!,
      isSelected: false,
      image: employeeEntity.photo ??
          (employeeEntity.gender == "female"
              ? AppAssets.female
              : AppAssets.male),
      arabicName:
          "${employeeEntity.firstNameInArabic!} ${employeeEntity.lastNameInArabic!}",
      englishName: "${employeeEntity.firstName!} ${employeeEntity.lastName!}",
      titleEnglish: employeeEntity.title!,
      titleArabic: employeeEntity.titleInArabic!,
    );
  }

  static List<PersonEntity> fromUsersModel(UsersModel userModel){
  List<PersonEntity> persons = [];
  if(userModel.emails == null){
    return persons;}

   for(int i=0;i<userModel.emails!.length;i++){
     EmployeeEntityPro employeeEntity =Get.find<MainCoreEmployeeController>()
         .allEmployeesEntities!.firstWhere((element) => element.email! == userModel.emails![i]);
     PersonEntity personEntity = PersonEntity.fromEmployeeEntity(employeeEntity);
     personEntity.isSelected = userModel.status![i] == "active";
   }
    return persons;
  }

  String get name =>
      Get.locale?.languageCode == "ar" ? arabicName : englishName;
  String get title =>
      Get.locale?.languageCode == "ar" ? titleArabic : titleEnglish;
  String get departmentName {
    try {
      MainCoreDepartmentCubit addDepartmentController = Get.find();

      String? deptName = addDepartmentController.getDepartmentName(
          department,
          Get.locale?.languageCode == "en"
      );

      return deptName ?? 'N/A';
    } catch (e) {
      
      return 'N/A';
    }
  }
}
