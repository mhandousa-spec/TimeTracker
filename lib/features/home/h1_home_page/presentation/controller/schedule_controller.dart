/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: schedule_controller.dart
/// Purpose: Declares `ScheduleController`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

/// *************************** FILE INFO ****************************
/// File Name: schedule_controller.dart
/// Purpose: This file contains the controller for the schedule section of the home page.
/// Author: Amr Mesbah
/// Created at: 11/2/2025

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/skeleton_home_controller.dart';
import 'package:knowticed_plus/features/todo/data/services/todo_access.dart';
import 'package:knowticed_plus/features/todo/domain/base_repository/todo_base_repository.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';

import 'package:knowticed_plus/features/home/main_controller/helper/events/events_stub.dart';
import 'package:knowticed_plus/features/home/main_controller/helper/events/controllers/events_controllers/model/event_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/board_model/board_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/card_model/card_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/card_model/checklist_item.dart';

import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/core/helper/main_helper/calnder_size.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/controller/employee_controller.dart';

part './schedule_state.dart';

/// Converted from GetxController to Cubit.
///
/// Dependency lookup still goes through GetX (`Get.put` in
/// home_responsive_page, `Get.find` at the call sites) — only the state
/// mechanism changed. The former `onInit()` hook now runs from the
/// constructor: GetX does not drive lifecycle callbacks on a Cubit, so
/// getAnyWorkToDO() would otherwise never fire on creation.
///
/// NOTE: the `eventsEmployeeController.update()` calls below are left
/// untouched — those are GetX calls on *another* controller, not on this class.
///
/// To-dos (7/10/2026) come from the new To-Do module: this cubit listens to
/// `TodoBaseRepository.watchTodos` for the signed-in user and emits
/// [ScheduleUpdated] on every change, so the upcoming schedule rebuilds live.
class ScheduleController extends Cubit<ScheduleState> {
  ScheduleController() : super(ScheduleInitial()) {
    getAnyWorkToDO();
  }

  List<EventModel> inviteAtEvents = [];
  List<EventModel> surveyEvents = [];
  List<TodoEntity> todoList = [];
  List<BoardModel> boardsModel = [];
  List<CardModel> cardsModel = [];

  List<dynamic> requestedServices = [];
  List<CheckListItems> filteredItems = [];
  bool isThereTodo = false;
  bool isThereEvent = false;
  bool isThereTasks = false;
  bool isThereServices = false;
  bool isThereSurvey = false;

  bool isThereAnyWork() {
    return isThereEvent ||
        isThereTodo ||
        isThereTasks ||
        isThereServices ||
        isThereSurvey;
  }

  DateTime selectedDate = DateTime.now();

  // To-Do module source (get_it, registered in main()).
  final TodoBaseRepository _todoRepository =
      GetIt.instance<TodoBaseRepository>();
  final TodoAccess _todoAccess = GetIt.instance<TodoAccess>();
  StreamSubscription<List<TodoEntity>>? _todoSubscription;
  String _todoOwner = '';
  List<TodoEntity> _allTodos = <TodoEntity>[];
  //TaskController taskController = Get.find();
  EventsEmployeeController eventsEmployeeController = Get.find();

  /// Method Name: [getAnyWorkToDO]
  ///
  /// Purpose: This method is responsible for fetching all the work that the user has to do on the selected date.
  getAnyWorkToDO() async {
    await Future.wait(
        [getTodo(), getEvents(), getSurveyEvents(), getTasks(), getServices()]);
  }

  /// Method Name: [getTodo]
  ///
  /// Purpose: Collects the signed-in user's to-dos that fall on [selectedDate]
  /// (see [_isTodoOnDay]). Starts the live to-do subscription on first use.
  Future<void> getTodo() async {
    isThereTodo = false;
    todoList = [];
    if (!Get.find<SkeletonHomeController>().modules.contains(Modules.todo)) {
      return;
    }
    _ensureTodoSubscription();
    todoList = _allTodos
        .where((TodoEntity todo) => _isTodoOnDay(todo, selectedDate))
        .toList();
    if (todoList.isNotEmpty) isThereTodo = true;
  }

  /// Method Name: [_ensureTodoSubscription]
  ///
  /// Purpose: (Re)subscribes to the user's to-dos when nobody is listening yet
  /// or the signed-in email changed. No-op before login.
  void _ensureTodoSubscription() {
    final String email = _todoAccess.currentUserEmail;
    if (email.isEmpty) return;
    if (_todoSubscription != null && email == _todoOwner) return;
    _todoSubscription?.cancel();
    _todoOwner = email;
    _todoSubscription = _todoRepository
        .watchTodos(ownerEmail: email)
        .listen(_onTodos, onError: _onTodosError);
  }

  void _onTodos(List<TodoEntity> todos) {
    _allTodos = todos;
    getTodo();
    if (!isClosed) emit(ScheduleUpdated());
  }

  /// A failed read leaves the schedule without to-dos rather than stale ones.
  void _onTodosError(Object error) {
    _allTodos = <TodoEntity>[];
    getTodo();
    if (!isClosed) emit(ScheduleUpdated());
  }

  /// Method Name: [_isTodoOnDay]
  ///
  /// Purpose: Whether [todo] belongs on [day]'s schedule — a live (not done,
  /// not deleted) to-do whose recurrence lands on [day], or whose scheduled
  /// start..end range covers any part of [day].
  bool _isTodoOnDay(TodoEntity todo, DateTime day) {
    if (todo.isDeleted || todo.isDone) return false;
    final DateTime? anchor = todo.recurrenceAnchor;
    if (todo.hasFrequency &&
        anchor != null &&
        todo.frequency.occursOn(anchor: anchor, day: day)) {
      return true;
    }
    if (!todo.isScheduled) return false;
    final DateTime? start = todo.startAt ?? todo.endAt;
    final DateTime? end = todo.endAt ?? todo.startAt;
    if (start == null || end == null) return false;
    final DateTime dayStart = DateTime(day.year, day.month, day.day);
    final DateTime dayEnd = DateTime(day.year, day.month, day.day + 1);
    return start.isBefore(dayEnd) && !end.isBefore(dayStart);
  }

  /// Method Name: [getEvents]
  ///
  /// Purpose: This method is responsible for fetching all the events that the user has to attend on the selected date.
  Future<void> getEvents() async {
    isThereEvent = false;
    inviteAtEvents = [];
    if (!Get.find<SkeletonHomeController>().modules.contains(Modules.events)) {
      eventsEmployeeController.update();
      return;
    }

    for (EventModel event in eventsEmployeeController.inviteAtEvents) {
      Map<String, int> eventSplitDate =
          HomeHelper.splitDateString(event.date.toLowerCase());
      DateTime eventDate = _createEventDateTime(eventSplitDate, event);
      if (eventSplitDate['year'] == selectedDate.year &&
          eventSplitDate['month'] == selectedDate.month &&
          eventSplitDate['day'] == selectedDate.day &&
          eventsEmployeeController.acceptInvitation(eventId: event.id) &&
          eventDate.isAfter(selectedDate.add(Duration(
              hours: DateTime.now().hour, minutes: DateTime.now().minute)))) {
        inviteAtEvents.add(event);
      }
    }
    eventsEmployeeController.update();
    if (inviteAtEvents.isNotEmpty) isThereEvent = true;
  }

  /// Method Name: [getSurveyEvents]
  ///
  /// Purpose: This method is responsible for fetching all the survey events that the user has to attend on the selected date.
  Future<void> getSurveyEvents() async {
    surveyEvents = [];
    isThereSurvey = false;
    if (!Get.find<SkeletonHomeController>().modules.contains(Modules.events)) {
      eventsEmployeeController.update();
      return;
    }
    for (EventModel event in eventsEmployeeController.inviteAtEvents) {
      Map<String, int> eventSplitDate =
          HomeHelper.splitDateString(event.date.toLowerCase());
      DateTime eventDate = _createEventDateTime(eventSplitDate, event);
      if (HomeHelper.isDateInRange(
              selectedDate: selectedDate,
              startDate: DateFormat("d MMM yyyy").parse(event.date),
              endDate: DateFormat("d MMM yyyy")
                  .parse(event.date)
                  .add(const Duration(days: 5))) &&
          eventsEmployeeController.findEmployeeSubmission(
                  surveyId: event.surveyId) ==
              null &&
          eventsEmployeeController.acceptInvitation(eventId: event.id) &&
          eventDate.isBefore(selectedDate!.add(Duration(
              hours: DateTime.now().hour, minutes: DateTime.now().minute)))) {
        surveyEvents.add(event);
      }
    }
    if (inviteAtEvents.isNotEmpty) isThereSurvey = true;
    eventsEmployeeController.update();
  }

  /// Method Name: [_createEventDateTime]
  ///
  /// Purpose: This method is responsible for creating a DateTime object from the event date and time.
  DateTime _createEventDateTime(
      Map<String, int> eventSplitDate, EventModel event) {
    DateTime eventDate = DateTime(
        eventSplitDate['year']!,
        eventSplitDate['month']!,
        eventSplitDate['day']!,
        DateFormat("hh:mm a").parse(event.time).hour,
        DateFormat("hh:mm a").parse(event.time).minute);
    return eventDate;
  }

  /// Method Name: [getTasks]
  ///
  /// Purpose: This method is responsible for fetching all the tasks that the user has to do on the selected date.
  Future<void> getTasks() async {
    filteredItems = [];
    cardsModel = [];
    boardsModel = [];
    isThereTasks = false;
    if (!Get.find<SkeletonHomeController>().modules.contains(Modules.tasks)) {
      // taskController.update();
      return;
    }

    String memberId =
        Get.find<EmployeeController>().employee!.email!.last!;
    /*  for (var board in taskController.allBoards) {
      for (var card in board.cards) {
        //Skip cards with a null start date
        if (card.startDate!.startDate!.isNotEmpty) {
          for (var checklist in card.cardCheckLists!) {
            if (card.cardCheckLists != null &&
                card.cardCheckLists!.isNotEmpty) {
              for (var item in checklist.checkListItems!) {
                // Check if the item's status is "todo" and the member is in the list
                if (item.itemStatus!.last == 'todo' ||
                    item.itemMembers!.contains(memberId)) {
                  // Determine effective start date
                  DateTime? effectiveStartDate = DateFormat('dd/MM/yyyy').parse(
                      item.itemStartDate?.lastOrNull ??
                          card.startDate!.startDate!.last);
                  DateTime? effectiveEndDate = item.itemEndDate?.lastOrNull !=
                          null
                      ? DateFormat('dd/MM/yyyy').parse(item.itemEndDate!.last)
                      : null;

                  // Skip if both start and end dates are null
                  if (effectiveEndDate == null && item.itemStartDate == null)
                    continue;
                  // Check if the selected date is within the range
                  if (effectiveStartDate.isBefore(selectedDate) ||
                      effectiveStartDate.isAtSameMomentAs(selectedDate)) {
                    if (effectiveEndDate != null &&
                        (effectiveEndDate.isAfter(selectedDate) ||
                            effectiveEndDate.isAtSameMomentAs(selectedDate))) {
                      filteredItems.add(item);
                      cardsModel.add(card);
                      boardsModel.add(board);
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
   */
    if (filteredItems.isNotEmpty) {
      isThereTasks = true;
    }
    // taskController.update();
  }

  /// Method Name: [getServices]
  ///
  /// Purpose: This method is responsible for fetching all the services that the user has to do on the selected date.
  Future<void> getServices() async {
    isThereServices = false;
    requestedServices = [];
    if (!Get.find<SkeletonHomeController>()
        .modules
        .contains(Modules.services)) {
      // serviceController.update();
      return;
    }
    /* for (RequestedServiceModel service
        in serviceController.myRequestedServices) {
      if (HomeHelper.isDateWithinServiceRange(
            startDate: service.startDate!.toDate(),
            durationType:
                service.serviceModel!.durationType!.durationType!.last!,
            durationValue: int.parse(
                service.serviceModel!.serviceDuration!.serviceDuration!.last!),
            selectedDate: selectedDate,
          ) &&
          service.status!.requestStatus!.last == 'in progress') {
        requestedServices.add(service);
      }
    }*/
    if (requestedServices.isNotEmpty) isThereServices = true;
    // serviceController.update();
  }

  /// Method Name: [isDayHasToDo]
  ///
  /// Purpose: This method is responsible for checking if the selected date has any todos.
  ///
  /// Parameters: [currentDate] of type [DateTime] - The date to check.
  ///
  /// Returns: [bool] - True if the date has todos, false otherwise.
  bool isDayHasToDo(DateTime currentDate) {
    if (!Get.find<SkeletonHomeController>().modules.contains(Modules.todo)) {
      return false;
    }
    _ensureTodoSubscription();
    return _allTodos.any((TodoEntity todo) => _isTodoOnDay(todo, currentDate));
  }

  /// Method Name: [isDayHasRequestServices]
  ///
  /// Purpose: This method is responsible for checking if the selected date has any requested services.
  ///
  /// Parameters: [currentDate] of type [DateTime] - The date to check.
  ///
  /// Returns: [bool] - True if the date has requested services, false otherwise.
  bool isDayHasRequestServices(DateTime currentDate) {
    if (!Get.find<SkeletonHomeController>()
        .modules
        .contains(Modules.services)) {
      return false;
    }
    bool isExist = false;
/*    for (RequestedServiceModel service
        in serviceController.myRequestedServices) {
      if (HomeHelper.isDateWithinServiceRange(
              startDate: service.startDate!.toDate(),
              durationType:
                  service.serviceModel!.durationType!.durationType!.last!,
              durationValue: int.parse(service
                  .serviceModel!.serviceDuration!.serviceDuration!.last!),
              selectedDate: currentDate) &&
          service.status!.requestStatus!.last == 'in progress') {
        isExist = true;
        break;
      }
    }*/
    return isExist;
  }

  /// Method Name: [isDayHasEvent]
  ///
  /// Purpose: This method is responsible for checking if the selected date has any events.
  ///
  /// Parameters: [currentDate] of type [DateTime] - The date to check.
  ///
  /// Returns: [bool] - True if the date has events, false otherwise.
  bool isDayHasEvent(DateTime currentDate) {
    if (!Get.find<SkeletonHomeController>().modules.contains(Modules.events)) {
      return false;
    }
    bool isExist = false;
    for (EventModel event in eventsEmployeeController.inviteAtEvents) {
      bool isValidEvent = false;
      Map<String, int> splitDate =
          HomeHelper.splitDateString(event.date.toLowerCase());
      DateTime eventDate = _createEventDateTime(splitDate, event);
      bool isFirstSetValidEvent = splitDate['year'] == currentDate.year &&
          splitDate['month'] == currentDate.month &&
          splitDate['day'] == currentDate.day;
      isFirstSetValidEvent &=
          eventsEmployeeController.acceptInvitation(eventId: event.id);
      isFirstSetValidEvent &= eventDate.isAfter(currentDate.add(Duration(
          hours: DateTime.now().hour, minutes: DateTime.now().minute)));
      bool isSecondSetValidEvent = HomeHelper.isDateInRange(
          selectedDate: currentDate,
          startDate: DateFormat("d MMM yyyy").parse(event.date),
          endDate: DateFormat("d MMM yyyy")
              .parse(event.date)
              .add(const Duration(days: 5)));
      isSecondSetValidEvent &= eventsEmployeeController.findEmployeeSubmission(
              surveyId: event.surveyId) ==
          null;
      isSecondSetValidEvent &=
          eventsEmployeeController.acceptInvitation(eventId: event.id);
      isSecondSetValidEvent &= eventDate.isBefore(currentDate.add(Duration(
          hours: DateTime.now().hour, minutes: DateTime.now().minute)));
      isValidEvent = isFirstSetValidEvent || isSecondSetValidEvent;
      if (isValidEvent) {
        isExist = true;
        break;
      }
    }
    return isExist;
  }

  /// Method Name: [isDayHasSurvey]
  ///
  /// Purpose: This method is responsible for checking if the selected date has any survey events.
  ///
  /// Parameters:
  ///            [currentDate] of type [DateTime] - The date to check.
  ///            [memverId] of type [String] - The id of the member.
  ///
  /// Returns: [bool] - True if the date has survey events, false otherwise.
  bool isDayHasTasks(
      {required DateTime selectedDate, required String memberId}) {
    if (!Get.find<SkeletonHomeController>().modules.contains(Modules.tasks)) {
      return false;
    }
    List<CheckListItems> filteredItems = [];

    return filteredItems.isNotEmpty;
  }

  /// Method Name: [updateUpcomingSchedule]
  ///
  /// Purpose: This method is responsible for updating the upcoming schedule list.
  ///
  /// Parameters: [selectedDate] of type [DateTime] - The selected date.
  updateUpcomingSchedule(DateTime selectedDate) {
    this.selectedDate = selectedDate;
    getAnyWorkToDO();
  }

  @override
  Future<void> close() async {
    await _todoSubscription?.cancel();
    return super.close();
  }
}
