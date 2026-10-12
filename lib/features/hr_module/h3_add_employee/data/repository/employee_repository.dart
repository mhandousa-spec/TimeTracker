// ***************************** FILE INFO ***************************** //
// File Name: employee_repository.dart
// Purpose: Orchestrates validated employee profile and HR record creation.
// Author: Mohamed Elrashidy
// Created At: 2026-08-10
// ********************************************************************* //

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../roles/r4_active_directory/data/models/employees_model/home_phone_model.dart';
import '../../../../roles/r4_active_directory/data/models/employees_model/mobile_phone_model.dart';
import '../../../../roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import '../../../../roles/r4_active_directory/data/models/employees_model/office_phone_model.dart';
import '../../../../onboarding/o3_authentication/data/models/demo_user_account_overview.dart';
import '../../../main_controller/domain/entity/hr_employee_entity.dart';
import '../../../../../../core/helper/main_helper/phone_number.dart';
import '../../../../../../core/helper/hr/hr_api_constants.dart';
import '../../utils/employee_creation_failure.dart';
import '../../utils/employee_form_snapshot.dart';
import '../../utils/employee_submission.dart';
import '../../utils/employee_update_failure.dart';
import '../../utils/employee_update_payload.dart';
import '../data_source/remote_data_source/employee_remote_data_source.dart';
import '../models/employee_attachments_model.dart';
import '../models/employee_certification_details_model.dart';
import '../models/employee_contact_details_model.dart';
import '../models/employee_emergency_details_model.dart';
import '../models/employee_insurance_details_model.dart';

/// Creates the legacy employee profile and supplemental HR section records.
class EmployeeRepository {
  EmployeeRepository({EmployeeRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? EmployeeRemoteDataSource();

  final EmployeeRemoteDataSource _remoteDataSource;

  /// Method Name: [updateEmployee]
  ///
  /// Purpose: Persists one selected employee section without replacing others.
  ///
  /// Parameters:
  /// - [payload]: Normalized values captured by the edit form.
  ///
  /// Returns: A typed update result from the remote data source.
  Future<Either<EmployeeUpdateFailure, void>> updateEmployee(
    EmployeeUpdatePayload payload,
  ) {
    return _remoteDataSource.updateEmployeeSection(payload);
  }

  /// Method Name: [createEmployee]
  ///
  /// Purpose: Validates, uploads, maps, and atomically creates one employee.
  ///
  /// Parameters:
  /// - [employeeEntity]: Normalized employee entity built by the Cubit.
  ///
  /// Returns: Either a typed creation failure or the new Employee ID.
  Future<Either<EmployeeCreationFailure, String>> createEmployee(
    HrEmployeeEntity employeeEntity, {
    required List<String> selectedLanguages,
    String? profileImagePath,
    String? passportDocumentPath,
    String? nationalIdFrontDocumentPath,
    String? nationalIdBackDocumentPath,
    String? drivingLicenseDocumentPath,
    String? certificationDocumentPath,
  }) async {
    final snapshot = _snapshotFromEntity(
      employeeEntity,
      selectedLanguages: selectedLanguages,
      profileImagePath: profileImagePath,
      passportDocumentPath: passportDocumentPath,
      nationalIdFrontDocumentPath: nationalIdFrontDocumentPath,
      nationalIdBackDocumentPath: nationalIdBackDocumentPath,
      drivingLicenseDocumentPath: drivingLicenseDocumentPath,
      certificationDocumentPath: certificationDocumentPath,
    );
    final employeeId = snapshot.value(EmployeeFormField.employeeId);
    final businessEmail =
        _normalizeEmail(snapshot.value(EmployeeFormField.businessEmail));
    final personalEmail =
        _normalizeEmail(snapshot.value(EmployeeFormField.personalEmail));

    if (businessEmail == personalEmail) {
      return const Left(MatchingEmployeeEmailsFailure(
        'Personal and business emails must differ',
      ));
    }

    final duplicate = await _remoteDataSource.validateUniqueValues(
      employeeId: employeeId,
      businessEmail: businessEmail,
      personalEmail: personalEmail,
    );
    if (duplicate != null) return Left(duplicate);

    final uploadedUrls = <String, String>{};
    final uploadFailure = await _uploadSelectedFiles(
      snapshot: snapshot,
      employeeId: employeeId,
      uploadedUrls: uploadedUrls,
    );
    if (uploadFailure != null) {
      await _remoteDataSource.deleteUploadedFiles(uploadedUrls.values);
      return Left(uploadFailure);
    }

    final submission = _buildSubmission(
      snapshot: snapshot,
      employeeEntity: employeeEntity,
      businessEmail: businessEmail,
      personalEmail: personalEmail,
      uploadedUrls: uploadedUrls,
    );
    final result = await _remoteDataSource.commitSubmission(submission);
    return result.fold(
      (failure) async {
        await _remoteDataSource.deleteUploadedFiles(uploadedUrls.values);
        return Left<EmployeeCreationFailure, String>(failure);
      },
      (_) async => Right<EmployeeCreationFailure, String>(employeeId),
    );
  }

  EmployeeFormSnapshot _snapshotFromEntity(
    HrEmployeeEntity entity, {
    required List<String> selectedLanguages,
    String? profileImagePath,
    String? passportDocumentPath,
    String? nationalIdFrontDocumentPath,
    String? nationalIdBackDocumentPath,
    String? drivingLicenseDocumentPath,
    String? certificationDocumentPath,
  }) {
    String value(String? item) => item ?? '';
    return EmployeeFormSnapshot(
      values: {
        EmployeeFormField.employeeId: value(entity.id),
        EmployeeFormField.firstName: value(entity.firstName),
        EmployeeFormField.middleName: value(entity.middleName),
        EmployeeFormField.lastName: value(entity.lastName),
        EmployeeFormField.firstNameArabic: value(entity.firstNameInArabic),
        EmployeeFormField.middleNameArabic: value(entity.middleNameInArabic),
        EmployeeFormField.lastNameArabic: value(entity.lastNameInArabic),
        EmployeeFormField.nationalId: value(entity.nationalId),
        EmployeeFormField.nationalIdExpirationDate:
            value(entity.nationalIdExpirationDate),
        EmployeeFormField.nationality: value(entity.nationality),
        EmployeeFormField.passport: value(entity.passport),
        EmployeeFormField.passportExpirationDate:
            value(entity.passportExpirationDate),
        EmployeeFormField.personalEmail: value(entity.personalEmail),
        EmployeeFormField.businessEmail: value(entity.email),
        EmployeeFormField.mobileCountryCode:
            value(entity.mobilePhone?.countryCode),
        EmployeeFormField.mobileNumber: value(entity.mobilePhone?.number),
        EmployeeFormField.homeCountryCode:
            value(entity.homePhoneNumber?.countryCode),
        EmployeeFormField.homeNumber: value(entity.homePhoneNumber?.number),
        EmployeeFormField.officeCountryCode:
            value(entity.officePhoneNumber?.countryCode),
        EmployeeFormField.officeNumber: value(entity.officePhoneNumber?.number),
        EmployeeFormField.extension: value(entity.extension),
        EmployeeFormField.birthDay: value(entity.birthDay),
        EmployeeFormField.gender: value(entity.gender),
        EmployeeFormField.country: value(entity.country),
        EmployeeFormField.province: value(entity.province),
        EmployeeFormField.city: value(entity.city),
        EmployeeFormField.postalCode: value(entity.postalCode),
        EmployeeFormField.street: value(entity.street),
        EmployeeFormField.maritalStatus: value(entity.maritalStatus),
        EmployeeFormField.departmentId: value(entity.departmentId),
        EmployeeFormField.title: value(entity.title),
        EmployeeFormField.workLocation: value(entity.workLocation),
        EmployeeFormField.drivingLicenseId: value(entity.drivingLicenseId),
        EmployeeFormField.carPlates: entity.carPlates?.join(', ') ?? '',
        EmployeeFormField.jobType: value(entity.jobType),
        EmployeeFormField.workArrangement: value(entity.workArrangement),
        EmployeeFormField.remoteStatus: value(entity.remoteStatus),
        EmployeeFormField.employeeGrade: value(entity.employeeGrade),
        EmployeeFormField.startDate: value(entity.startDate),
        EmployeeFormField.startTime: value(entity.startTime),
        EmployeeFormField.endTime: value(entity.endTime),
        EmployeeFormField.daysOff: value(entity.daysOff),
        EmployeeFormField.salary: value(entity.salary),
        EmployeeFormField.currency: value(entity.currency),
        EmployeeFormField.institutionName: value(entity.institutionName),
        EmployeeFormField.degree: value(entity.degree),
        EmployeeFormField.fieldOfStudy: value(entity.fieldOfStudy),
        EmployeeFormField.certificationStartDate:
            value(entity.certificationStartDate),
        EmployeeFormField.certificationEndDate:
            value(entity.certificationEndDate),
        EmployeeFormField.gradeOrScore: value(entity.gradeOrScore),
        EmployeeFormField.certificateId: value(entity.certificateId),
        EmployeeFormField.issuingAuthority: value(entity.issuingAuthority),
        EmployeeFormField.certificationNotes: value(entity.certificationNotes),
        EmployeeFormField.insuranceName: value(entity.insuranceName),
        EmployeeFormField.insurancePolicyNumber:
            value(entity.insurancePolicyNumber),
        EmployeeFormField.insuranceProviderContact:
            value(entity.insuranceProviderContact),
        EmployeeFormField.firstEmergencyFirstName:
            value(entity.firstContactFirstName),
        EmployeeFormField.firstEmergencyLastName:
            value(entity.firstContactLastName),
        EmployeeFormField.firstEmergencyFirstNameArabic:
            value(entity.firstContactFirstNameArabic),
        EmployeeFormField.firstEmergencyLastNameArabic:
            value(entity.firstContactLastNameArabic),
        EmployeeFormField.firstEmergencyRelationship:
            value(entity.firstContactRelationship),
        EmployeeFormField.firstEmergencyEmail: value(entity.firstContactEmail),
        EmployeeFormField.firstEmergencyCountryCode:
            value(entity.firstEmergencyPhone?.countryCode),
        EmployeeFormField.firstEmergencyMobile:
            value(entity.firstEmergencyPhone?.number),
        EmployeeFormField.firstEmergencyCountry:
            value(entity.firstContactCountry),
        EmployeeFormField.firstEmergencyProvince:
            value(entity.firstContactProvince),
        EmployeeFormField.firstEmergencyCity: value(entity.firstContactCity),
        EmployeeFormField.firstEmergencyStreet:
            value(entity.firstContactStreet),
        EmployeeFormField.firstEmergencyLanguage:
            value(entity.firstContactLanguage),
        EmployeeFormField.secondEmergencyFirstName:
            value(entity.secondContactFirstName),
        EmployeeFormField.secondEmergencyLastName:
            value(entity.secondContactLastName),
        EmployeeFormField.secondEmergencyFirstNameArabic:
            value(entity.secondContactFirstNameArabic),
        EmployeeFormField.secondEmergencyLastNameArabic:
            value(entity.secondContactLastNameArabic),
        EmployeeFormField.secondEmergencyRelationship:
            value(entity.secondContactRelationship),
        EmployeeFormField.secondEmergencyEmail:
            value(entity.secondContactEmail),
        EmployeeFormField.secondEmergencyCountryCode:
            value(entity.secondEmergencyPhone?.countryCode),
        EmployeeFormField.secondEmergencyMobile:
            value(entity.secondEmergencyPhone?.number),
        EmployeeFormField.secondEmergencyCountry:
            value(entity.secondContactCountry),
        EmployeeFormField.secondEmergencyProvince:
            value(entity.secondContactProvince),
        EmployeeFormField.secondEmergencyCity: value(entity.secondContactCity),
        EmployeeFormField.secondEmergencyStreet:
            value(entity.secondContactStreet),
        EmployeeFormField.secondEmergencyLanguage:
            value(entity.secondContactLanguage),
      },
      selectedLanguages: selectedLanguages,
      profileImagePath: profileImagePath,
      passportDocumentPath: passportDocumentPath,
      nationalIdFrontDocumentPath: nationalIdFrontDocumentPath,
      nationalIdBackDocumentPath: nationalIdBackDocumentPath,
      drivingLicenseDocumentPath: drivingLicenseDocumentPath,
      certificationDocumentPath: certificationDocumentPath,
    );
  }

  /// Method Name: [_uploadSelectedFiles]
  ///
  /// Purpose: Uploads every selected attachment while retaining cleanup URLs.
  ///
  /// Parameters:
  /// - [snapshot]: Captured file paths and employee values.
  /// - [employeeId]: Employee-specific Storage folder identifier.
  /// - [uploadedUrls]: Mutable URL registry for mapping and cleanup.
  ///
  /// Returns: The first upload failure, or null when all uploads succeed.
  Future<EmployeeCreationFailure?> _uploadSelectedFiles({
    required EmployeeFormSnapshot snapshot,
    required String employeeId,
    required Map<String, String> uploadedUrls,
  }) async {
    final files = <String, String?>{
      _profileSlot: snapshot.profileImagePath,
      _passportSlot: snapshot.passportDocumentPath,
      _nationalIdFrontSlot: snapshot.nationalIdFrontDocumentPath,
      _nationalIdBackSlot: snapshot.nationalIdBackDocumentPath,
      _drivingLicenseSlot: snapshot.drivingLicenseDocumentPath,
      _certificationSlot: snapshot.certificationDocumentPath,
    };

    for (final entry in files.entries) {
      final filePath = entry.value;
      if (filePath == null || filePath.isEmpty) continue;
      final upload = await _remoteDataSource.uploadFile(
        storagePath: 'hr_module/employees/$employeeId/${entry.key}',
        documentName: entry.key,
        filePath: filePath,
      );
      final failure = upload.fold<EmployeeCreationFailure?>(
        (value) => value,
        (url) {
          uploadedUrls[entry.key] = url;
          return null;
        },
      );
      if (failure != null) return failure;
    }
    return null;
  }

  /// Method Name: [_buildSubmission]
  ///
  /// Purpose: Maps normalized values and uploaded URLs into persistence records.
  ///
  /// Parameters:
  /// - [snapshot]: Immutable employee form values.
  /// - [businessEmail]: Normalized canonical business email.
  /// - [personalEmail]: Normalized personal email.
  /// - [uploadedUrls]: Download URLs keyed by attachment slot.
  ///
  /// Returns: One complete atomic-write payload.
  EmployeeSubmission _buildSubmission({
    required EmployeeFormSnapshot snapshot,
    required HrEmployeeEntity employeeEntity,
    required String businessEmail,
    required String personalEmail,
    required Map<String, String> uploadedUrls,
  }) {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    final employeeId = snapshot.value(EmployeeFormField.employeeId);
    final employee = _buildLegacyEmployee(
      snapshot: snapshot,
      employeeEntity: employeeEntity,
      businessEmail: businessEmail,
      profileUrl: uploadedUrls[_profileSlot] ?? '',
      uploadedUrls: uploadedUrls,
      now: now,
    );

    return EmployeeSubmission(
      employee: employee,
      accountOverview: DemoUserAccountOverview(
        email: businessEmail,
        companyId: HrEmployeeApiConstants.tenantId,
        isActivated: false,
        demoGranted: null,
        demoActivated: null,
      ),
      contactDetails: EmployeeContactDetailsModel(
        employeeId: employeeId,
        timestamps: [timestamp],
        personalEmail: [personalEmail],
        homeCountryCode: [
          snapshot.value(EmployeeFormField.homeCountryCode),
        ],
        officeCountryCode: [
          snapshot.value(EmployeeFormField.officeCountryCode),
        ],
      ),
      certificationDetails: EmployeeCertificationDetailsModel(
        employeeId: employeeId,
        timestamps: [Timestamp.fromMillisecondsSinceEpoch(timestamp)],
        institutionName: [snapshot.value(EmployeeFormField.institutionName)],
        degree: [snapshot.value(EmployeeFormField.degree)],
        fieldOfStudy: [snapshot.value(EmployeeFormField.fieldOfStudy)],
        startDate: [
          snapshot.value(EmployeeFormField.certificationStartDate),
        ],
        endDate: [snapshot.value(EmployeeFormField.certificationEndDate)],
        gradeOrScore: [snapshot.value(EmployeeFormField.gradeOrScore)],
        certificateId: [snapshot.value(EmployeeFormField.certificateId)],
        issuingAuthority: [
          snapshot.value(EmployeeFormField.issuingAuthority),
        ],
        certificationDocumentUrl: [
          uploadedUrls[_certificationSlot] ?? '',
        ],
        notes: [snapshot.value(EmployeeFormField.certificationNotes)],
      ),
      insuranceDetails: EmployeeInsuranceDetailsModel(
        employeeId: employeeId,
        timestamps: [timestamp],
        providerContact: [
          snapshot.value(EmployeeFormField.insuranceProviderContact),
        ],
      ),
      emergencyDetails: EmployeeEmergencyDetailsModel(
        employeeId: employeeId,
        timestamps: [timestamp],
        firstContactFirstNameArabic: [
          snapshot.value(EmployeeFormField.firstEmergencyFirstNameArabic),
        ],
        firstContactLastNameArabic: [
          snapshot.value(EmployeeFormField.firstEmergencyLastNameArabic),
        ],
        firstContactCountryCode: [
          snapshot.value(EmployeeFormField.firstEmergencyCountryCode),
        ],
        secondContactFirstNameArabic: [
          snapshot.value(EmployeeFormField.secondEmergencyFirstNameArabic),
        ],
        secondContactLastNameArabic: [
          snapshot.value(EmployeeFormField.secondEmergencyLastNameArabic),
        ],
        secondContactCountryCode: [
          snapshot.value(EmployeeFormField.secondEmergencyCountryCode),
        ],
      ),
      attachments: EmployeeAttachmentsModel(
        employeeId: employeeId,
        timestamps: [timestamp],
        passportDocumentUrl: [uploadedUrls[_passportSlot] ?? ''],
        nationalIdFrontUrl: [uploadedUrls[_nationalIdFrontSlot] ?? ''],
        nationalIdBackUrl: [uploadedUrls[_nationalIdBackSlot] ?? ''],
        drivingLicenseDocumentUrl: [
          uploadedUrls[_drivingLicenseSlot] ?? '',
        ],
      ),
    );
  }

  /// Method Name: [_buildLegacyEmployee]
  ///
  /// Purpose: Maps compatible form values into the unchanged legacy model.
  ///
  /// Parameters:
  /// - [snapshot]: Immutable employee form values.
  /// - [businessEmail]: Normalized legacy employee email.
  /// - [profileUrl]: Uploaded profile image URL, or an empty string.
  /// - [now]: Shared creation timestamp for the legacy record.
  ///
  /// Returns: A legacy employee record accepted by existing readers.
  NewEmployeeModelHistory _buildLegacyEmployee({
    required EmployeeFormSnapshot snapshot,
    required HrEmployeeEntity employeeEntity,
    required String businessEmail,
    required String profileUrl,
    required Map<String, String> uploadedUrls,
    required DateTime now,
  }) {
    final timestamp = now.millisecondsSinceEpoch;
    String value(EmployeeFormField field) => snapshot.value(field);
    List<String> history(EmployeeFormField field) => [value(field)];

    return NewEmployeeModelHistory(
      id: value(EmployeeFormField.employeeId),
      timestamps: [timestamp],
      firstName: history(EmployeeFormField.firstName),
      middleName: history(EmployeeFormField.middleName),
      lastName: history(EmployeeFormField.lastName),
      firstNameInArabic: history(EmployeeFormField.firstNameArabic),
      middleNameInArabic: history(EmployeeFormField.middleNameArabic),
      lastNameInArabic: history(EmployeeFormField.lastNameArabic),
      nationalId: history(EmployeeFormField.nationalId),
      nationalIdExpirationDate:
          history(EmployeeFormField.nationalIdExpirationDate),
      nationality: history(EmployeeFormField.nationality),
      passport: history(EmployeeFormField.passport),
      passportExpirationDate: history(EmployeeFormField.passportExpirationDate),
      email: [businessEmail],
      mobilePhone: [
        MobilePhone(
          phones: history(EmployeeFormField.mobileNumber),
          countryCode: history(EmployeeFormField.mobileCountryCode),
          countryApp: const [''],
          timestamps: [Timestamp.fromMillisecondsSinceEpoch(timestamp)],
        ),
      ],
      officePhone: history(EmployeeFormField.officeNumber),
      homePhone: history(EmployeeFormField.homeNumber),
      homePhoneDetails: [
        _homePhoneModel(employeeEntity.homePhoneNumber, timestamp),
      ],
      officePhoneDetails: [
        _officePhoneModel(employeeEntity.officePhoneNumber, timestamp),
      ],
      extension: history(EmployeeFormField.extension),
      birthDay: history(EmployeeFormField.birthDay),
      gender: history(EmployeeFormField.gender),
      country: history(EmployeeFormField.country),
      province: history(EmployeeFormField.province),
      city: history(EmployeeFormField.city),
      postalCode: history(EmployeeFormField.postalCode),
      street: history(EmployeeFormField.street),
      maritalStatus: history(EmployeeFormField.maritalStatus),
      language: [snapshot.selectedLanguages.join(', ')],
      departmentId: history(EmployeeFormField.departmentId),
      supervisor: const [''],
      role: const [''],
      title: history(EmployeeFormField.title),
      titleInArabic: const [''],
      workLocation: history(EmployeeFormField.workLocation),
      drivingLicenseId: history(EmployeeFormField.drivingLicenseId),
      carPlates: [_parseCarPlates(value(EmployeeFormField.carPlates))],
      academicHistory: [
        {
          'university': value(EmployeeFormField.institutionName),
          'graduateFrom': value(EmployeeFormField.degree),
          'gpa': value(EmployeeFormField.gradeOrScore),
          'yearOfGraduation': value(EmployeeFormField.certificationEndDate),
        },
      ],
      bio: const [''],
      photo: [profileUrl],
      skills: const [[]],
      hobbies: const [[]],
      status: const ['active'],
      personalEmail: [employeeEntity.personalEmail],
      homeCountryCode: [employeeEntity.homePhoneNumber?.countryCode],
      officeCountryCode: [employeeEntity.officePhoneNumber?.countryCode],
      jobType: [employeeEntity.jobType],
      workArrangement: [employeeEntity.workArrangement],
      remoteStatus: [employeeEntity.remoteStatus],
      employeeGrade: [employeeEntity.employeeGrade],
      startDate: [employeeEntity.startDate],
      startTime: [employeeEntity.startTime],
      endTime: [employeeEntity.endTime],
      daysOff: [employeeEntity.daysOff],
      salary: [employeeEntity.salary],
      currency: [employeeEntity.currency],
      institutionName: [employeeEntity.institutionName],
      degree: [employeeEntity.degree],
      fieldOfStudy: [employeeEntity.fieldOfStudy],
      certificationStartDate: [employeeEntity.certificationStartDate],
      certificationEndDate: [employeeEntity.certificationEndDate],
      gradeOrScore: [employeeEntity.gradeOrScore],
      certificateId: [employeeEntity.certificateId],
      issuingAuthority: [employeeEntity.issuingAuthority],
      certificationDocumentUrl: [
        uploadedUrls[_certificationSlot],
      ],
      certificationNotes: [employeeEntity.certificationNotes],
      insuranceName: history(EmployeeFormField.insuranceName),
      insurancePolicyNumber: history(EmployeeFormField.insurancePolicyNumber),
      insuranceProviderContact: [employeeEntity.insuranceProviderContact],
      firstContactFirstName: history(EmployeeFormField.firstEmergencyFirstName),
      firstContactLastName: history(EmployeeFormField.firstEmergencyLastName),
      firstContactRelationship:
          history(EmployeeFormField.firstEmergencyRelationship),
      firstContactEmail: history(EmployeeFormField.firstEmergencyEmail),
      firstContactPhone: history(EmployeeFormField.firstEmergencyMobile),
      firstContactPhoneDetails: [
        _mobilePhoneModel(employeeEntity.firstEmergencyPhone, timestamp),
      ],
      firstContactLanguage: history(EmployeeFormField.firstEmergencyLanguage),
      firstContactCountry: history(EmployeeFormField.firstEmergencyCountry),
      firstContactProvince: history(EmployeeFormField.firstEmergencyProvince),
      firstContactCity: history(EmployeeFormField.firstEmergencyCity),
      firstContactStreet: history(EmployeeFormField.firstEmergencyStreet),
      secondContactFirstName:
          history(EmployeeFormField.secondEmergencyFirstName),
      secondContactLastName: history(EmployeeFormField.secondEmergencyLastName),
      secondContactRelationship:
          history(EmployeeFormField.secondEmergencyRelationship),
      secondContactEmail: history(EmployeeFormField.secondEmergencyEmail),
      secondContactPhone: history(EmployeeFormField.secondEmergencyMobile),
      secondContactPhoneDetails: [
        _mobilePhoneModel(employeeEntity.secondEmergencyPhone, timestamp),
      ],
      secondContactLanguage: history(EmployeeFormField.secondEmergencyLanguage),
      secondContactCountry: history(EmployeeFormField.secondEmergencyCountry),
      secondContactProvince: history(EmployeeFormField.secondEmergencyProvince),
      secondContactCity: history(EmployeeFormField.secondEmergencyCity),
      secondContactStreet: history(EmployeeFormField.secondEmergencyStreet),
      passportDocumentUrl: [uploadedUrls[_passportSlot]],
      nationalIdFrontUrl: [uploadedUrls[_nationalIdFrontSlot]],
      nationalIdBackUrl: [uploadedUrls[_nationalIdBackSlot]],
      drivingLicenseDocumentUrl: [uploadedUrls[_drivingLicenseSlot]],
      password: null,
      defaultPassword: null,
      passwordExpirationTime: null,
      passwordExpirationUnit: null,
      firstLogin: null,
      lastLogin: null,
      deactivationDate: null,
      activationDate: now.toIso8601String(),
    );
  }

  HomePhone _homePhoneModel(PhoneNumber? phone, int timestamp) => HomePhone(
        phones: [phone?.number],
        countryCode: [phone?.countryCode],
        countryApp: [phone?.countryApp],
        timestamps: [Timestamp.fromMillisecondsSinceEpoch(timestamp)],
      );

  OfficePhone _officePhoneModel(PhoneNumber? phone, int timestamp) =>
      OfficePhone(
        phones: [phone?.number],
        countryCode: [phone?.countryCode],
        countryApp: [phone?.countryApp],
        timestamps: [Timestamp.fromMillisecondsSinceEpoch(timestamp)],
      );

  MobilePhone _mobilePhoneModel(PhoneNumber? phone, int timestamp) =>
      MobilePhone(
        phones: [phone?.number ?? ''],
        countryCode: [phone?.countryCode ?? ''],
        countryApp: [phone?.countryApp ?? ''],
        timestamps: [Timestamp.fromMillisecondsSinceEpoch(timestamp)],
      );

  /// Method Name: [_normalizeEmail]
  ///
  /// Purpose: Produces the canonical value used for email comparisons.
  ///
  /// Parameters:
  /// - [value]: Raw email entered in the form.
  ///
  /// Returns: A trimmed lowercase email.
  String _normalizeEmail(String value) => value.trim().toLowerCase();

  /// Method Name: [_parseCarPlates]
  ///
  /// Purpose: Converts the form's comma-delimited plates into legacy values.
  ///
  /// Parameters:
  /// - [value]: Raw comma-delimited plate text.
  ///
  /// Returns: Trimmed non-empty plate values.
  List<String> _parseCarPlates(String value) => value
      .split(',')
      .map((plate) => plate.trim())
      .where((plate) => plate.isNotEmpty)
      .toList();

  static const _profileSlot = 'profile';
  static const _passportSlot = 'passport';
  static const _nationalIdFrontSlot = 'national_id/front';
  static const _nationalIdBackSlot = 'national_id/back';
  static const _drivingLicenseSlot = 'driving_license';
  static const _certificationSlot = 'certification';
}
