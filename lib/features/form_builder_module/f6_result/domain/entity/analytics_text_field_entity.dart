
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/person_entity.dart';

class AnalyticsTextFieldEntity {
  PersonEntity person;
  DateTime submissionDate;
  List<String> answers;

  AnalyticsTextFieldEntity({
    required this.person,
    required this.submissionDate,
    required this.answers,
  });
}