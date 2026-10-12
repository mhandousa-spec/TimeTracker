/// Module: home/main_controller
///
///*************************** FILE INFO ****************************///
/// File Name: tasks_stub.dart
/// Purpose: Placeholder pages for the removed Tasks (boards) module.
/// Author: Knowticed Plus team
/// Updated: 7/10/2026 - Dropped the To-Do stubs (TaskModel,
///          TaskFirebaseService, ToDoListScreen, TaskStatus/TaskPriority):
///          the home To-Do cards now read the real To-Do module.

// ============================================================================
// Tasks module stub
// ----------------------------------------------------------------------------
// The real "tasks_module" was removed from this (demo) copy of the app. The
// upcoming schedule's board-card rows still push these two pages, which show
// the neutral "not available" placeholder.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/86-removed_module_placeholder.dart';
import 'package:knowticed_plus/generated/l10n.dart';

// Stub: TaskDetailsTabletScreen — opened from a board card (tablet).
class TaskDetailsTabletScreen extends StatelessWidget {
  final dynamic currentCard;
  final dynamic cards;
  final dynamic boardModel;
  final dynamic projectName;
  final dynamic listName;
  final dynamic department;

  const TaskDetailsTabletScreen({
    super.key,
    this.currentCard,
    this.cards,
    this.boardModel,
    this.projectName,
    this.listName,
    this.department,
  });

  @override
  Widget build(BuildContext context) =>
      RemovedModulePage(moduleName: S.current.tasks);
}

// Stub: TaskDetailsMobile — opened from a board card (mobile).
class TaskDetailsMobile extends StatelessWidget {
  final dynamic department;
  final dynamic board;
  final dynamic cardModel;
  final dynamic boardModel;
  final dynamic cards;

  const TaskDetailsMobile({
    super.key,
    this.department,
    this.board,
    this.cardModel,
    this.boardModel,
    this.cards,
  });

  @override
  Widget build(BuildContext context) =>
      RemovedModulePage(moduleName: S.current.tasks);
}
