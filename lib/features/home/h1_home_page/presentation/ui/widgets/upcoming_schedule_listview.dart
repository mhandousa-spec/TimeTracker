/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: upcoming_schedule_listview.dart
/// Purpose: Declares `UpcomingScheduleListview`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/features/home/main_controller/helper/events/events_stub.dart';
import 'package:knowticed_plus/features/home/main_controller/helper/events/controllers/events_controllers/model/event_model.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/events/mobile/employee/take_survey_screen_mobile.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/events/mobile/event_details_mobiel.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/events/tablet/media_departments_view/views/event_details.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/events/tablet/media_departments_view/views/survey/take_survey_screen.dart';

import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/custom_schedule_container.dart';
import 'package:knowticed_plus/features/home/h2_nav_bar/persistent_nav_bar.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';

import 'package:knowticed_plus/features/home/main_controller/helper/todo_new_module/tasks_stub.dart';
import 'package:knowticed_plus/core/helper/main_helper/calnder_size.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/card_model/checklist_item.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/schedule_controller.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/controller/employee_controller.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/custom/37-custom_navigate.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';
import 'package:knowticed_plus/features/todo/presentation/ui/pages/todo_module_entry.dart';

class UpcomingScheduleListview extends StatefulWidget {
  List<DateTime?>? selectedDate;

  UpcomingScheduleListview({super.key, this.selectedDate});
  @override
  _UpcomingScheduleListviewState createState() =>
      _UpcomingScheduleListviewState();
}

final EventsEmployeeController empController =
    Get.put(EventsEmployeeController());

// Employee controller used for member photos/details in the schedule cards.
final EmployeeController addEmployeeController = Get.find();

class _UpcomingScheduleListviewState extends State<UpcomingScheduleListview> {
  ScheduleController scheduleController = Get.find();
  DateTime addDurationToTimestamp(Timestamp timestamp, String duration) {
    // Step 1: Convert the Timestamp to DateTime
    DateTime dateTime = timestamp.toDate();

    // Step 2: Parse the duration string
    int number = int.parse(duration.split(' ')[0]);
    String unit = duration.split(' ')[1].toLowerCase();

    // Step 3: Add the duration based on the unit
    if (unit.contains('hour')) {
      dateTime = dateTime.add(Duration(hours: number));
    } else if (unit.contains('day')) {
      dateTime = dateTime.add(Duration(days: number));
    } else if (unit.contains('week')) {
      dateTime = dateTime.add(Duration(days: number * 7)); // 1 week = 7 days
    } else if (unit.contains('month')) {
      dateTime = DateTime(dateTime.year, dateTime.month + number, dateTime.day);
    } else {
      throw Exception("Unsupported duration unit");
    }

    return dateTime;
  }

  @override
  void initState() {
    super.initState();
    scheduleController.getAnyWorkToDO();
  }

  EmployeeController emplController = Get.find();

  @override
  Widget build(BuildContext context) {
    // ScheduleController emits ScheduleUpdated whenever the user's to-dos
    // change, so the empty-state check and the lists below stay live.
    return BlocBuilder<ScheduleController, ScheduleState>(
      bloc: scheduleController,
      builder: (BuildContext context, ScheduleState _) =>
          _buildSchedule(context),
    );
  }

  Widget _buildSchedule(BuildContext context) {
    bool isDesktop = Platform.isLinux || Platform.isMacOS || Platform.isWindows;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    bool isLargeTablet = MediaQuery.of(context).size.shortestSide >= 1024;
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: isPortrait
                ? null
                : (isLargeTablet
                    ? 0.45.h
                    : (isDesktop
                        ? HomeHelper.getConditionalHeight(context)
                        : 0.35.h)),
            child: !scheduleController.isThereAnyWork()
                ? Center(
                    child: SizedBox(
                      height: 0.3.h,
                      child: Transform.scale(
                        scale: isTablet ? (isPortrait ? 6 : 5) : 4,
                        child: Padding(
                          padding: EdgeInsets.only(top: 0.0.h),
                          child: Lottie.asset(
                            "assets/lottie_assets/main_lottie_assets/emptyTask.json",
                          ),
                        ),
                      ),
                    ),
                  )
                : ListView(
                    physics:
                        isPortrait ? const NeverScrollableScrollPhysics() : null,
                    shrinkWrap: isPortrait ? true : false,
                    padding: EdgeInsets.zero,
                    children: [
                      todoItemsBuilder(isTablet),
                      serviceItemsBuilder(context, isTablet),
                      eventsItemsBuilder(context, isTablet),
                      surveyItemsBuilder(context, isTablet),
                      tasksItemBuilder(isTablet),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  GetBuilder<EventsEmployeeController> surveyItemsBuilder(BuildContext context, bool isTablet) {
    return GetBuilder<EventsEmployeeController>(builder: (employeeController) {
      return ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: scheduleController.surveyEvents.length,
        itemBuilder: (BuildContext context, int index) {
          List<EventModel> inviteAtEvents = scheduleController.surveyEvents;

          return InkWell(
            onTap: () {
              isTablet
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TakeSurveyScreen(
                            survey: employeeController.getSurvey(
                                eventId: inviteAtEvents[index].id)),
                      ),
                    )
                  : Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.fade,
                        child: TakeSurveyScreenMobile(
                            survey: employeeController.getSurvey(
                                eventId: inviteAtEvents[index].id)),
                      ),
                    );
            },
            child: CustomScheduleContainer(
              cardTitle: context.isArabic
                  ? employeeController
                      .getSurvey(eventId: inviteAtEvents[index].id)!
                      .surveyTitleArabic
                  : employeeController
                      .getSurvey(eventId: inviteAtEvents[index].id)!
                      .surveyTitle,
              eventType: 'Event',
              description: context.isArabic
                  ? 'إستبيان الحدث: ${inviteAtEvents[index].eventNameArabic}'
                  : 'Survey of Event: ${inviteAtEvents[index].eventNameEnglish}',
              dueDate: inviteAtEvents[index].date,
              imagesList: inviteAtEvents[index]
                  .guests
                  .map((e) => addEmployeeController.getEmployeePhoto(e.email))
                  .toList(),
            ),
          );
        },
      );
    });
  }

  Widget serviceItemsBuilder(BuildContext context, bool isTablet) {
    return /*GetBuilder<RequestedServicesEmployeeController>(
        builder: (requestedServicesEmployeeController) {
      return ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: scheduleController.requestedServices.length,
        itemBuilder: (BuildContext context, int index) {
          List<RequestedServiceModel> requestedServiceModel =
              scheduleController.requestedServices;
          return InkWell(
            onTap: () {
              isTablet
                  ? Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.fade,
                          child:
                              RoleScreen(rowInvalid: [], isFristTime: false)),
                    )
                  : PersistentNavBarNavigator.pushNewScreen(
                      context,
                      withNavBar: false,
                      screen: Container()
                      */ /*RequestedServicesEmployeeDetailsScreenMobile(
                                        providerProfileImage:
                                            addEmployeeController
                                                .getEmployeePhoto(
                                                    requestedServiceModel[
                                                            index]
                                                        .serviceProvideer!),
                                        serviceName: context.isEnglish
                                            ? requestedServiceModel[index]
                                                .serviceModel!
                                                .serviceName!
                                                .serviceName!
                                                .last!
                                                .capitalize!
                                            : requestedServiceModel[index]
                                                .serviceModel!
                                                .serviceNameArabic!
                                                .serviceNameInArabic!
                                                .last!,
                                        serviceDescription:
                                            requestedServiceModel[index]
                                                .serviceModel!
                                                .serviceDescription!
                                                .serviceDescription!
                                                .last!
                                                .capitalize!,
                                        serviceLastDate: DateFormat(
                                                'dd MMMM yyyy',
                                                context.languageCode)
                                            .format(DateTime.parse(
                                                requestedServiceModel[index]
                                                    .lastUpdate!)),
                                        serviceStartDate: DateFormat(
                                                'dd MMMM yyyy',
                                                context.languageCode)
                                            .format(
                                                requestedServiceModel[index]
                                                    .requestDate!
                                                    .toDate()),
                                        duration:
                                            // No GetX Translations are registered anywhere in
                                            // the app, so the old trailing `.tr` returned the
                                            // key unchanged — dropping it is behaviour-identical
                                            // and matches the sibling call site below.
                                            '${englishArabicNumber(requestedServiceModel[index].serviceModel!.serviceDuration!.serviceDuration!.last!)} ${requestedServiceModel[index].serviceModel!.durationType!.durationType!.last!}'
                                                .capitalize!,
                                        jobTitle: addEmployeeController
                                            .getEmployeeJobTitle(
                                                requestedServiceModel[index]
                                                    .serviceModel!
                                                    .email!
                                                    .emails!
                                                    .last!)
                                            .capitalize!,
                                        pointOfContact: addEmployeeController
                                            .getEmployeeName(
                                                requestedServiceModel[index]
                                                    .serviceProvideer!)
                                            .capitalize!,
                                        photo: addEmployeeController
                                            .getEmployeePhoto(
                                                requestedServiceModel[index]
                                                    .serviceProvideer!),
                                        status: requestedServiceModel[index]
                                            .status!
                                            .requestStatus!
                                            .last
                                            .capitalize!,
                                        approval: requestedServiceModel[index]
                                                    .serviceModel!
                                                    .needsApproval ==
                                                "yes"
                                            ? true
                                            : false,
                                        email: requestedServiceModel[index]
                                            .serviceModel!
                                            .email!
                                            .emails!
                                            .last!,
                                        phoneNumber:
                                            "${addEmployeeController.getLocaleEmployee(requestedServiceModel[index].serviceModel!.email!.emails!.last!).mobilePhone!.countryApp?.lastOrNull} ${addEmployeeController.getLocaleEmployee(requestedServiceModel[index].serviceModel!.email!.emails!.last!).mobilePhone!.phones!.last!}",
                                        comments: departmentServiceController
                                            .getComments(
                                                requestedServiceModel[index]
                                                    .comments!),
                                        requestModel:
                                            requestedServiceModel[index],
                                      )*/ /*
                      ,
                    );
            },
            child: CustomScheduleContainer(
              cardTitle: context.isArabic
                  ? requestedServiceModel[index]
                      .serviceModel!
                      .serviceNameArabic!
                      .serviceNameInArabic!
                      .last!
                  : requestedServiceModel[index]
                      .serviceModel!
                      .serviceName!
                      .serviceName!
                      .last!,
              eventType: "Service",
              description:
                  '${emplController.getDepartment(emplController.getLocaleEmployee(requestedServiceModel[index].requestCreator!).departmentid!.departmentId!.last!).capitalize!}/${emplController.getEmployeeName(requestedServiceModel[index].requestCreator!).capitalize!}',
              dueDate: DateFormat("dd MMM yyyy").format(addDurationToTimestamp(
                  requestedServiceModel[index].startDate!,
                  "${requestedServiceModel[index].serviceModel!.serviceDuration!.serviceDuration!.last!} ${requestedServiceModel[index].serviceModel!.durationType!.durationType!.last!}")),
              imagesList: [],
            ),
          );
        },
      );
    })*/
        Container();
  }

  Widget tasksItemBuilder(bool isTablet) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: scheduleController.filteredItems.length,
      itemBuilder: (BuildContext context, int index) {
        List<CheckListItems> checkListItems = scheduleController.filteredItems;

        return InkWell(
          onTap: () {
            isTablet
                ? Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.fade,
                      child: TaskDetailsTabletScreen(
                        currentCard: scheduleController.cardsModel[index],
                        cards: scheduleController.boardsModel[index].cards,
                        boardModel: scheduleController.boardsModel[index],
                        projectName: scheduleController
                            .boardsModel[index].boardName!.boardgName!.last,
                        listName: scheduleController.cardsModel[index]
                                    .cardStatus!.cardStatus!.last ==
                                'todo'
                            ? 'To Do'
                            : scheduleController.cardsModel[index].cardStatus!
                                .cardStatus!.last.capitalize!,
                        department: scheduleController.boardsModel[index]
                            .boardDeparment!.boardgDepartment!.last,
                      ),
                    ),
                  )
                : PersistentNavBarNavigator.pushNewScreen(
                    context,
                    withNavBar: true,
                    screen: TaskDetailsMobile(
                      department: scheduleController.boardsModel[index]
                          .boardDeparment!.boardgDepartment!.last,
                      board: scheduleController
                          .boardsModel[index].boardName!.boardgName!.last,
                      cardModel: scheduleController.cardsModel[index],
                      boardModel: scheduleController.boardsModel[index],
                      cards: scheduleController.boardsModel[index].cards,
                    ),
                  );
          },
          child: CustomScheduleContainer(
            cardTitle: checkListItems[index].itemTitle!.last,
            eventType: 'Board',
            description:
                '${scheduleController.boardsModel[index].boardName!.boardgName!.last} - ${scheduleController.cardsModel[index].cardName!.cardName!.last}',
            dueDate: checkListItems[index].itemEndDate?.lastOrNull == null
                ? " "
                : DateFormat("dd MMM yyyy").format(DateFormat('dd/MM/yyyy')
                    .parse(checkListItems[index].itemEndDate!.last)),
            imagesList: checkListItems[index]
                .itemMembers!
                .map((e) => addEmployeeController.getEmployeePhoto(e))
                .toList(),
          ),
        );
      },
    );
  }

  Widget eventsItemsBuilder(BuildContext context, bool isTablet) {
    return GetBuilder<EventsEmployeeController>(builder: (employeeController) {
      return ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: scheduleController.inviteAtEvents.length,
        itemBuilder: (BuildContext context, int index) {
          List<EventModel> inviteAtEvents = scheduleController.inviteAtEvents;
          return InkWell(
            onTap: () {
              isTablet
                  ? Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.fade,
                        child: EditEvent(
                          event: inviteAtEvents[index],
                          isApproval: true,
                        ),
                      ),
                    )
                  : PersistentNavBarNavigator.pushNewScreen(
                      context,
                      pageTransitionAnimation: PageTransitionAnimation.fade,
                      screen: EventDetailsMobile(
                        event: inviteAtEvents[index],
                        isApprovals: true,
                      ),
                      withNavBar: false,
                    );
            },
            child: CustomScheduleContainer(
              cardTitle: context.isArabic
                  ? inviteAtEvents[index].eventNameArabic
                  : inviteAtEvents[index].eventNameEnglish,
              eventType: 'Event',
              description: context.isArabic
                  ? inviteAtEvents[index].summaryArabic
                  : inviteAtEvents[index].summary,
              dueDate: inviteAtEvents[index].date,
              imagesList: inviteAtEvents[index]
                  .guests
                  .map((e) => addEmployeeController.getEmployeePhoto(e.email))
                  .toList(),
            ),
          );
        },
      );
    });
  }

  /// To-dos on the selected day (from `ScheduleController.todoList`).
  /// Tapping one opens the To-Do module with THAT to-do's details pushed on
  /// top of its list (`TodoModuleEntry.initialTodoId`, same as the calendar
  /// and home checklist taps). Both branches build the entry directly, so
  /// the constructor argument reaches it (no drawer switch → no
  /// `pendingTodoId` hint needed).
  Widget todoItemsBuilder(bool isTablet) {
    final List<TodoEntity> todos = scheduleController.todoList;
    return ListView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: todos.length,
      itemBuilder: (BuildContext context, int index) {
        final TodoEntity todo = todos[index];
        final DateTime? due = todo.endAt ?? todo.startAt;
        return InkWell(
          onTap: () {
            HapticController.low();
            final TodoModuleEntry entry = TodoModuleEntry(
              initialTodoId: todo.id.isEmpty ? null : todo.id,
            );
            isTablet
                ? navigateTo(context, entry)
                : PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: entry,
                    withNavBar: true,
                  );
          },
          child: CustomScheduleContainer(
            cardTitle: todo.name,
            eventType: 'To Do list',
            description: todo.description,
            dueDate: due == null ? ' ' : DateFormat('dd MMM yyyy').format(due),
            imagesList: const <String?>[],
          ),
        );
      },
    );
  }
}
