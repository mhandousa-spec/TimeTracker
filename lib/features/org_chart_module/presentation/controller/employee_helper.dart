import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:knowticed_plus/features/org_chart_module/presentation/employees_views/employee_views_mobile/employee_personal_info.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';

abstract class EmployeeHelper {
  static String getEmployeeFirstAndLastNames(
      {required NewEmployeeModelHistory employee}) {
    if (Get.locale!.languageCode == 'en') {
      return capitalize(
          '${employee.firstName!.last!} ${employee.lastName!.last!}');
    } else {
      return capitalize(
          '${employee.firstNameInArabic!.last!} ${employee.lastNameInArabic!.last!}');
    }
  }

  static String getEmployeeJobTitle({required NewEmployeeModelHistory employee}) {
    if (Get.locale!.languageCode == 'en') {
      return capitalize(employee.title!.last!);
    } else {
      return capitalize(employee.titleInArabic!.last!);
    }
  }

  static String getImageUrl({required NewEmployeeModelHistory employee}) {
    String employeeImageUrl = "assets/icons_assets/main_icons_assets/assets_male.svg";
    if (employee.gender?.last == "female") {
      employeeImageUrl = "assets/icons_assets/main_icons_assets/images_female.svg";
    }
    if (employee.photo?.lastOrNull != null) {
      employeeImageUrl = employee.photo!.last!;
    }
    return employeeImageUrl;
  }
}
