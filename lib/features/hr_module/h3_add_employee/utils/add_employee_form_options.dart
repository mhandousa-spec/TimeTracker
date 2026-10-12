// ***************************** FILE INFO ***************************** //
// File Name: add_employee_form_options.dart
// Purpose: Groups localized options used by add-employee form selectors.
// Author: Mohamed Elrashidy
// Created At: 2026-08-09
// ********************************************************************* //

import 'add_employee_currency_option.dart';
import 'add_employee_days_off_option.dart';
import 'add_employee_degree_option.dart';
import 'add_employee_employee_grade_option.dart';
import 'add_employee_field_of_study_option.dart';
import 'add_employee_issuing_authority_option.dart';
import 'add_employee_job_type_option.dart';
import 'add_employee_relationship_option.dart';
import 'add_employee_remote_status_option.dart';
import 'add_employee_work_arrangement_option.dart';
import 'add_employee_work_location_option.dart';

export 'add_employee_currency_option.dart';
export 'add_employee_days_off_option.dart';
export 'add_employee_degree_option.dart';
export 'add_employee_employee_grade_option.dart';
export 'add_employee_field_of_study_option.dart';
export 'add_employee_gender_option.dart';
export 'add_employee_issuing_authority_option.dart';
export 'add_employee_language_option.dart';
export 'add_employee_job_type_option.dart';
export 'add_employee_marital_status_option.dart';
export 'add_employee_relationship_option.dart';
export 'add_employee_remote_status_option.dart';
export 'add_employee_work_arrangement_option.dart';
export 'add_employee_work_location_option.dart';

/// Groups standard selector options by their form responsibility.
abstract final class AddEmployeeStandardOptions {
  static const jobTypes = [
    JobTypeOption.partTime,
    JobTypeOption.fullTime,
    JobTypeOption.contractor
  ];
  static const workArrangements = [
    WorkArrangementOption.onsite,
    WorkArrangementOption.remote,
    WorkArrangementOption.hybrid
  ];
  static const remoteStatuses = [
    RemoteStatusOption.fullyRemote,
    RemoteStatusOption.partiallyRemote,
    RemoteStatusOption.notRemote
  ];
  static const jobLocations = [
    WorkLocationOption.headquarters,
    WorkLocationOption.branchOffice,
    WorkLocationOption.clientSite,
    WorkLocationOption.remote
  ];
  static const grades = [
    EmployeeGradeOption.intern,
    EmployeeGradeOption.junior,
    EmployeeGradeOption.mid,
    EmployeeGradeOption.senior,
    EmployeeGradeOption.lead,
    EmployeeGradeOption.manager,
    EmployeeGradeOption.executive
  ];
  static const daysOff = [
    DaysOffOption.fridaySaturday,
    DaysOffOption.saturdaySunday,
    DaysOffOption.sundayMonday,
    DaysOffOption.custom
  ];
  static final currencies = CurrencyOption.values;
  static const degrees = [
    DegreeOption.highSchool,
    DegreeOption.diploma,
    DegreeOption.bachelor,
    DegreeOption.master,
    DegreeOption.doctorate,
    DegreeOption.professionalCertification
  ];
  static const fieldsOfStudy = [
    FieldOfStudyOption.business,
    FieldOfStudyOption.humanResources,
    FieldOfStudyOption.finance,
    FieldOfStudyOption.informationTechnology,
    FieldOfStudyOption.engineering,
    FieldOfStudyOption.other
  ];
  static const issuingAuthorities = [
    IssuingAuthorityOption.university,
    IssuingAuthorityOption.accreditedInstitute,
    IssuingAuthorityOption.professionalBody,
    IssuingAuthorityOption.other
  ];
  static const relationships = [
    RelationshipOption.parent,
    RelationshipOption.spouse,
    RelationshipOption.sibling,
    RelationshipOption.child,
    RelationshipOption.relative,
    RelationshipOption.friend,
    RelationshipOption.other
  ];
}
