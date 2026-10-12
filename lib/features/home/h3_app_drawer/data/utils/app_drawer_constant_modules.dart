/// Module: home/h3_app_drawer
///
///*************************** FILE INFO ****************************///
/// File Name: app_drawer_constant_modules.dart
/// Purpose: Declares `AppDrawerConstantModules`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.


import 'package:knowticed_plus/core/helper/role/modules_enum.dart';

abstract class AppDrawerConstantModules{
static List <Modules> drawerModules = [
  Modules.home,
  //Modules.tasks,
  Modules.employees,
  Modules.messages,
  Modules.roles,
  Modules.services,
  Modules.grc,
  Modules.todo,
  Modules.requests,
  Modules.events,
  Modules.notes,
  // 8/10/2026 — the real Time Tracker module replaces the legacy `tracking`
  // placeholder in the same slot (owner decision 17); the list length stays
  // 20, so the drawer's reserved indexes 18–21 are untouched.
  Modules.timeTracker,
  Modules.knowledgeHub,
  Modules.inventory,
  Modules.qiyas,
  Modules.database,
  Modules.formBuilder,
  Modules.settings,
  Modules.notification,
  Modules.hr,
  Modules.crm
];

}