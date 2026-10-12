part of 'employee_details_services.dart';

// Split from employee_details_services.dart to keep files <700 LOC.

extension EmployeeEntityModelExtension on EmployeeEntityModell {
  EmployeeEntityModell copyWith({String? state}) {
    return EmployeeEntityModell(
      id: id,
      email: email,
      title: title,
      gender: gender,
      lastName: lastName,
      firstName: firstName,
      state: state ?? this.state,
    );
  }
}
