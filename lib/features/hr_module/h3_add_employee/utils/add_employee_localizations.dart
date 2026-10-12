// ***************************** FILE INFO ***************************** //
// File Name: add_employee_localizations.dart
// Purpose: Exposes generated-intl messages required by the add-employee flow.
// Author: Mohamed Elrashidy
// Created At: 2026-08-09
// ********************************************************************* //

import 'package:intl/intl.dart';

import '../../../../../../generated/l10n.dart';

/// Adds new add-employee messages until the project generator is restored.
extension AddEmployeeLocalizations on S {
  String _message(String fallback, String key) =>
      Intl.message(fallback, name: key);
  String get fieldRequired =>
      _message('This field is required.', 'fieldRequired');
  String get nameMaxLength =>
      _message('Names cannot exceed 20 characters.', 'nameMaxLength');
  String get numberMaxLength =>
      _message('Numbers cannot exceed 10 digits.', 'numberMaxLength');
  String get onlyNumbersAllowed =>
      _message('Only numbers are allowed.', 'onlyNumbersAllowed');
  String get contractor => _message('Contractor', 'contractor');
  String get onsite => _message('Onsite', 'onsite');
  String get fullyRemote => _message('Fully Remote', 'fullyRemote');
  String get partiallyRemote => _message('Partially Remote', 'partiallyRemote');
  String get notRemote => _message('Not Remote', 'notRemote');
  String get headquarters => _message('Headquarters', 'headquarters');
  String get branchOffice => _message('Branch Office', 'branchOffice');
  String get intern => _message('Intern', 'intern');
  String get junior => _message('Junior', 'junior');
  String get mid => _message('Mid', 'mid');
  String get senior => _message('Senior', 'senior');
  String get lead => _message('Lead', 'lead');
  String get fridaySaturday => _message('Friday/Saturday', 'fridaySaturday');
  String get saturdaySunday => _message('Saturday/Sunday', 'saturdaySunday');
  String get sundayMonday => _message('Sunday/Monday', 'sundayMonday');
  String get usd => _message('USD', 'usd');
  String get eur => _message('EUR', 'eur');
  String get cny => _message('CNY', 'cny');
  String get highSchool => _message('High School', 'highSchool');
  String get bachelor => _message("Bachelor's", 'bachelor');
  String get master => _message("Master's", 'master');
  String get doctorate => _message('Doctorate', 'doctorate');
  String get professionalCertification =>
      _message('Professional Certification', 'professionalCertification');
  String get business => _message('Business', 'business');
  String get engineering => _message('Engineering', 'engineering');
  String get university => _message('University', 'university');
  String get accreditedInstitute =>
      _message('Accredited Institute', 'accreditedInstitute');
  String get professionalBody =>
      _message('Professional Body', 'professionalBody');
  String get parent => _message('Parent', 'parent');
  String get spouse => _message('Spouse', 'spouse');
  String get sibling => _message('Sibling', 'sibling');
  String get child => _message('Child', 'child');
  String get relative => _message('Relative', 'relative');
  String get friend => _message('Friend', 'friend');
  String get insuranceProviderContact =>
      _message('Insurance Provider Contact', 'insuranceProviderContact');
  String get employeeGrade => _message('Employee Grade', 'employeeGrade');
  String get workArrangement => _message('Work Arrangement', 'workArrangement');
  String get remoteStatus => _message('Remote Status', 'remoteStatus');
  String get jobType => _message('Job Type', 'jobType');
  String get fieldOfStudy => _message('Field of Study', 'fieldOfStudy');
  String get gradeOrScore => _message('Grade or Score', 'gradeOrScore');
  String get certificateId => _message('Certificate ID', 'certificateId');
  String get issuingAuthority =>
      _message('Issuing Authority', 'issuingAuthority');
  String get firstEmergencyContact =>
      _message('First Emergency Contact', 'firstEmergencyContact');
  String get endDateBeforeStartDate => _message(
      'End date must not be before start date.', 'endDateBeforeStartDate');
}
