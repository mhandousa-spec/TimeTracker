///******************************* File Info *******************************
/// File Name: user_grid_item.dart
/// Purpose: entity for users
/// Author: Mohamed Elrashidy
/// Created at: 23/3/2925

import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/person_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/page_entity.dart';
import 'package:pdf/widgets.dart';

class UserGridItem {
  PersonEntity person;
  DateTime? lastReminderTime;
  int reminderCounter;
  List<PageEntity>? page;
  DateTime? submissionTime;

  UserGridItem(
      {required this.person,
      this.lastReminderTime,
      required this.reminderCounter,
      this.page,
      this.submissionTime
      });
}
