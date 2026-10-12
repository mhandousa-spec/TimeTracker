
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/department.dart';

import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/person_entity.dart';

class OpenAccessModel {
  bool isEdit;
  DateTime? timeBegin, timeEnd;
  List<DepartmentEntity>? selectedDepartments;
  List<PersonEntity>? selectedPersons;
  OpenAccessModel(
      {required this.isEdit,
      this.timeBegin,
      this.selectedPersons,
      this.timeEnd,
      this.selectedDepartments});
}
