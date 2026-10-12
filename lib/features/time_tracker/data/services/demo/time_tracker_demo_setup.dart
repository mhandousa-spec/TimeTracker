/// Module: time_tracker / data / services / demo
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_demo_setup.dart
/// Purpose: Declares `TtDemoSetup` — the DEBUG-ONLY demo set-up documents:
///          locations (only when the company has fewer than two active
///          ones), the employees' location assignments, one group, the five
///          request types and the 21-day vacation balances.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (UI quality pass — demo data)
///
/// Pure Dart. Owner brief (9/10/2026): Annual Vacation (deducted from the
/// balance) · Sick Leave (attachment required) · Business Mission (manager
/// only) · Excused — Workshop (HR only), plus one INACTIVE type so the
/// Request Types cards show every status. Ministry-style working week
/// Sunday–Thursday.

import 'package:knowticed_plus/features/time_tracker/data/services/demo/time_tracker_demo_plan.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/demo/time_tracker_demo_texts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/setup_status.dart';

class TtDemoSetup {
  TtDemoSetup(this.input);

  final TtDemoInput input;

  static const List<int> _week = WorkSchedule.sundayToThursday;

  /// The demo locations (written only when [createsLocations]).
  static const List<WorkLocation> demoLocations = <WorkLocation>[
    WorkLocation(
      id: TtDemoIds.headquarters,
      nameEn: 'Ministry Headquarters',
      nameAr: 'مقر الوزارة الرئيسي',
      googleMapsUrl: 'https://www.google.com/maps/place/30.0187,31.7600',
      latitude: 30.0187,
      longitude: 31.76,
      isGeofenceEnabled: true,
      geofenceRadiusMeters: 200,
      country: 'EG',
      state: 'C',
      city: 'New Cairo',
      postalCode: '11865',
      workStartMinutes: 8 * 60,
      workEndMinutes: 16 * 60,
      workingDays: _week,
      lateAfterMinutes: 15,
      isBreakAllowed: true,
      breakMinutes: 30,
      isPauseAllowed: true,
      pauseMinutes: 15,
    ),
    WorkLocation(
      id: TtDemoIds.serviceCenter,
      nameEn: 'Citizen Service Center — Nasr City',
      nameAr: 'مركز خدمة المواطنين — مدينة نصر',
      googleMapsUrl: 'https://www.google.com/maps/place/30.0561,31.3301',
      latitude: 30.0561,
      longitude: 31.3301,
      isGeofenceEnabled: true,
      geofenceRadiusMeters: 150,
      country: 'EG',
      state: 'C',
      city: 'Nasr City',
      postalCode: '11765',
      workStartMinutes: 9 * 60,
      workEndMinutes: 17 * 60,
      workingDays: _week,
      lateAfterMinutes: 10,
      isBreakAllowed: true,
      breakMinutes: 45,
    ),
    WorkLocation(
      id: TtDemoIds.archive,
      nameEn: 'Records and Archives Building',
      nameAr: 'مبنى السجلات والأرشيف',
      googleMapsUrl: 'https://www.google.com/maps/place/29.9727,30.9437',
      latitude: 29.9727,
      longitude: 30.9437,
      country: 'EG',
      state: 'GZ',
      city: '6th of October',
      postalCode: '12566',
      workStartMinutes: 8 * 60 + 30,
      workEndMinutes: 15 * 60 + 30,
      workingDays: _week,
      lateAfterMinutes: 10,
      isPauseAllowed: true,
    ),
  ];

  /// Fewer than two real active locations → the demo brings its own.
  bool get createsLocations => !input.companyHasHr && input.existingLocations.length < 2;

  /// The locations the demo works with (demo or real).
  List<WorkLocation> get locations => createsLocations
      ? demoLocations
      : (input.existingLocations.isEmpty ? demoLocations : input.existingLocations);

  WorkLocation get main => locations.first;
  WorkLocation get second => locations.length > 1 ? locations[1] : locations.first;

  /// Department ids in first-seen order (the first goes to [main]).
  late final List<String> _departments = <String>{
    for (final TimeTrackerEmployee e in input.everyone)
      if (e.departmentId.isNotEmpty) e.departmentId,
  }.toList();

  /// Function Name: [locationOf]
  ///
  /// Purpose: Where [employee] works: the second department → [second],
  /// everyone else → [main].
  ///
  /// Return type: [WorkLocation]
  WorkLocation locationOf(TimeTrackerEmployee employee) {
    final int dept = _departments.indexOf(employee.departmentId);
    return dept == 1 ? second : main;
  }

  /// The group's members: up to three colleagues at [main] (never the
  /// signed-in user).
  late final List<TimeTrackerEmployee> groupMembers = <TimeTrackerEmployee>[
    for (final TimeTrackerEmployee e in input.others)
      if (locationOf(e).id == main.id) e,
  ].take(3).toList();

  DateTime get _setupDate => TtDemoCalendar.addDays(input.now, -60);

  /// Function Name: [group]
  ///
  /// Purpose: "Records Digitisation Team" at [main] with its own (custom)
  /// break / pause rules. Null with HR or without members.
  ///
  /// Return type: [EmployeeGroup?]
  EmployeeGroup? get group {
    if (input.companyHasHr || groupMembers.isEmpty) return null;
    return EmployeeGroup(
      id: TtDemoIds.group,
      name: TtDemoTexts.groupName.en,
      nameAr: TtDemoTexts.groupName.ar,
      description: TtDemoTexts.groupDescription.en,
      descriptionAr: TtDemoTexts.groupDescription.ar,
      memberEmails: <String>[for (final TimeTrackerEmployee e in groupMembers) e.email],
      locationId: main.id,
      startDate: _setupDate,
      rules: const AttendanceRules(
        isBreakAllowed: true,
        breakMinutes: 45,
        isPauseAllowed: true,
        pauseMinutes: 20,
      ),
    );
  }

  /// Function Name: [assignments]
  ///
  /// Purpose: One assignment per employee (group members link to the
  /// group; one employee has personal custom rules). Written only where
  /// none exists.
  ///
  /// Return type: [List<LocationAssignment>]
  List<LocationAssignment> get assignments {
    if (input.companyHasHr) return const <LocationAssignment>[];
    final Set<String> members = <String>{for (final TimeTrackerEmployee e in groupMembers) e.email};
    final List<LocationAssignment> out = <LocationAssignment>[];
    for (int i = 0; i < input.everyone.length; i++) {
      final TimeTrackerEmployee e = input.everyone[i];
      final bool inGroup = members.contains(e.email);
      out.add(LocationAssignment(
        employeeEmail: e.email,
        locationId: locationOf(e).id,
        startDate: _setupDate,
        groupId: inGroup ? TtDemoIds.group : '',
        rules: inGroup
            ? const AttendanceRules(isCustom: false)
            : i == input.everyone.length - 1 && i > 0
                ? AttendanceRules(
                    isBreakAllowed: true,
                    breakMinutes: 60,
                    isDifferentLocationAllowed: true,
                    allowedLocationIds: <String>[main.id, second.id],
                  )
                : const AttendanceRules(isCustom: false),
      ));
    }
    return out;
  }

  /// Function Name: [requestTypes]
  ///
  /// Purpose: The four brief types + one inactive (Request Types states).
  ///
  /// Return type: [List<RequestType>]
  List<RequestType> get requestTypes => <RequestType>[
        RequestType(
          id: TtDemoIds.annual,
          nameEn: TtDemoTexts.annual.en,
          nameAr: TtDemoTexts.annual.ar,
          descriptionEn: TtDemoTexts.annualDescription.en,
          descriptionAr: TtDemoTexts.annualDescription.ar,
          isDeductedFromVacationBalance: true,
        ),
        RequestType(
          id: TtDemoIds.sick,
          nameEn: TtDemoTexts.sick.en,
          nameAr: TtDemoTexts.sick.ar,
          descriptionEn: TtDemoTexts.sickDescription.en,
          descriptionAr: TtDemoTexts.sickDescription.ar,
          isAttachmentRequired: true,
        ),
        RequestType(
          id: TtDemoIds.mission,
          nameEn: TtDemoTexts.mission.en,
          nameAr: TtDemoTexts.mission.ar,
          descriptionEn: TtDemoTexts.missionDescription.en,
          descriptionAr: TtDemoTexts.missionDescription.ar,
          isHrApprovalRequired: false,
          isDescriptionRequired: true,
          locationIds: <String>{main.id, second.id}.toList(),
        ),
        RequestType(
          id: TtDemoIds.workshop,
          nameEn: TtDemoTexts.workshop.en,
          nameAr: TtDemoTexts.workshop.ar,
          descriptionEn: TtDemoTexts.workshopDescription.en,
          descriptionAr: TtDemoTexts.workshopDescription.ar,
          isManagerApprovalRequired: false,
          isDescriptionRequired: true,
        ),
        RequestType(
          id: TtDemoIds.emergency,
          nameEn: TtDemoTexts.emergency.en,
          nameAr: TtDemoTexts.emergency.ar,
          descriptionEn: TtDemoTexts.emergencyDescription.en,
          descriptionAr: TtDemoTexts.emergencyDescription.ar,
          status: RequestTypeStatus.inactive,
        ),
      ];

  /// The set-up creation date (two months back).
  DateTime get setupDate => _setupDate;
}
