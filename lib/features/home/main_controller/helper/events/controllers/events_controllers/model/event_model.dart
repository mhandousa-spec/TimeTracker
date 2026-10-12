/// Module: home/main_controller
///
///*************************** FILE INFO ****************************///
/// File Name: event_model.dart
/// Purpose: Declares `EventModel`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

class EventModel {
  String id;
  String eventCreator;
  String eventPhoto;
  String eventNameEnglish;
  String eventNameArabic;
  String summary;
  String summaryArabic;
  String agenda;
  String agendaArabic;
  String? departmentOwner;
  String date;
  String time;
  String? type;
  String flyer;
  bool isRemote;
  bool isOnsite;
  String remoteUrl;
  String onSiteAddress;
  String maximumCapacity;
  List<Employee> guests;
  List<Reminder> reminders;
  bool sendReminders;
  bool requiredApproval;
  bool hasSurvey;
  String surveyId;
  Employee? approvalEmail;
  String invited;
  String accepted;
  String rejected;
  String? status;
  EventModel(
      {required this.sendReminders,
      required this.id,
      required this.eventPhoto,
      required this.accepted,
      required this.rejected,
      required this.invited,
      required this.eventNameEnglish,
      required this.eventNameArabic,
      required this.summary,
      required this.summaryArabic,
      required this.agenda,
      required this.agendaArabic,
      this.departmentOwner,
      required this.date,
      required this.time,
      this.type,
      required this.flyer,
      required this.isRemote,
      required this.isOnsite,
      required this.remoteUrl,
      required this.onSiteAddress,
      required this.maximumCapacity,
      required this.guests,
      required this.reminders,
      required this.requiredApproval,
      required this.status,
      required this.approvalEmail,
      required this.hasSurvey,
      required this.surveyId,
      required this.eventCreator});
}

class Employee {
  final String imageUrl;
  final String role;
  final String name;
  final String arabicName;
  final String department;
  final String arabicDepartment;
  final String email;
  final Map<String, String> invitedEvents;
  final Map<String, String> approvalEvents;
  const Employee(
      {required this.email,
      required this.department,
      required this.imageUrl,
      required this.name,
      required this.role,
      required this.arabicName,
      required this.arabicDepartment,
      required this.invitedEvents,
      required this.approvalEvents});
}

class Reminder {
  final String date;
  final String time;

  const Reminder({required this.date, required this.time});
}
