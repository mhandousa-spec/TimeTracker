import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/person_entity.dart';

class RestrictedAccessModel{
  bool isEdit;
  DateTime? timeBegin,timeEnd;
  List<PersonEntity>? selectedPersons;

  RestrictedAccessModel(
      {required this.isEdit, this.timeBegin, this.timeEnd, this.selectedPersons});
}