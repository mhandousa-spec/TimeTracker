// ***************************** FILE INFO ***************************** //
// File Name: employee_remote_data_source.dart
// Purpose: Performs employee creation reads, uploads, and atomic writes.
// Author: Mohamed Elrashidy
// Created At: 2026-08-10
// ********************************************************************* //

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../../../../core/network/failure_model.dart';
import '../../../../../../core/network/api_constants.dart';
import '../../../../../../core/services/firebase/repository/firebase_repository.dart';
import '../../models/employee_contact_details_model.dart';
import '../../models/employee_emergency_details_model.dart';
import '../../../../../../core/helper/hr/hr_api_constants.dart';
import '../../../utils/employee_creation_failure.dart';
import '../../../utils/employee_submission.dart';
import '../../../utils/employee_update_failure.dart';
import '../../../utils/employee_update_payload.dart';
import '../../../utils/add_employee_step.dart';

/// Firebase boundary for creating one employee and its HR section records.
class EmployeeRemoteDataSource {
  EmployeeRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore,
        _storage = storage;

  final FirebaseFirestore? _firestore;
  final FirebaseStorage? _storage;

  FirebaseFirestore get _database => _firestore ?? FirebaseFirestore.instance;
  FirebaseStorage get _storageBucket => _storage ?? FirebaseStorage.instance;

  /// Method Name: [validateUniqueValues]
  ///
  /// Purpose: Detects existing IDs and emails before uploading any files.
  ///
  /// Parameters:
  /// - [employeeId]: Requested employee document identifier.
  /// - [businessEmail]: Normalized canonical employee email.
  /// - [personalEmail]: Normalized personal employee email.
  ///
  /// Returns: A failure when a duplicate exists, otherwise null.
  Future<EmployeeCreationFailure?> validateUniqueValues({
    required String employeeId,
    required String businessEmail,
    required String personalEmail,
  }) async {
    try {
      final employee = await _database
          .collection(HrEmployeeApiConstants.employeesInfoPath)
          .doc(employeeId)
          .get();
      if (employee.exists) {
        return const DuplicateEmployeeIdFailure('Employee ID already exists');
      }

      if (await _legacyEmailExists(businessEmail)) {
        return const DuplicateBusinessEmailFailure(
          'Business email already exists',
        );
      }
      final accountOverview = await _database
          .collection(ApiConstants.demoUsersAccounts)
          .doc(businessEmail)
          .get();
      if (accountOverview.exists) {
        return const DuplicateBusinessEmailFailure(
          'Business email already has an account overview',
        );
      }

      if (await _legacyEmailExists(personalEmail) ||
          await _personalEmailExists(personalEmail)) {
        return const DuplicatePersonalEmailFailure(
          'Personal email already exists',
        );
      }
      return null;
    } catch (error) {
      return UnknownEmployeeCreationFailure(error.toString());
    }
  }

  /// Method Name: [uploadFile]
  ///
  /// Purpose: Uploads one selected employee file through the shared API.
  ///
  /// Parameters:
  /// - [storagePath]: Employee-specific Storage folder.
  /// - [documentName]: Stable logical document name.
  /// - [filePath]: Local selected file path.
  ///
  /// Returns: Either an upload failure or the download URL.
  Future<Either<EmployeeCreationFailure, String>> uploadFile({
    required String storagePath,
    required String documentName,
    required String filePath,
  }) async {
    final Either<FirebaseFailure, String> result =
        await FirebaseRepository.uploadFile(
      collectionName: storagePath,
      documentName: documentName,
      filePath: filePath,
    );
    return result.fold(
      (failure) => Left(EmployeeFileUploadFailure(failure.message)),
      Right.new,
    );
  }

  /// Method Name: [commitSubmission]
  ///
  /// Purpose: Creates the legacy employee and HR section records atomically.
  ///
  /// Parameters:
  /// - [submission]: Fully prepared employee persistence payload.
  ///
  /// Returns: Either a duplicate/transaction failure or successful completion.
  Future<Either<EmployeeCreationFailure, void>> commitSubmission(
    EmployeeSubmission submission,
  ) async {
    final employeeId = submission.employee.id!;
    final employeeRef = _database
        .collection(HrEmployeeApiConstants.employeesInfoPath)
        .doc(employeeId);
    final accountOverviewRef = _database
        .collection(ApiConstants.demoUsersAccounts)
        .doc(submission.accountOverview.email);
    try {
      await _database.runTransaction((transaction) async {
        final employee = await transaction.get(employeeRef);
        final accountOverview = await transaction.get(accountOverviewRef);

        if (employee.exists) {
          throw const DuplicateEmployeeIdFailure(
            'Employee ID already exists during transaction',
          );
        }
        if (accountOverview.exists) {
          throw const DuplicateBusinessEmailFailure(
            'Business email already has an account overview during transaction',
          );
        }
        final employeeData = submission.employee.toMap()
          ..removeWhere(
            (key, _) => EmployeeEmergencyDetailsModel.legacyMiddleNameKeys
                .contains(key),
          );
        transaction.set(employeeRef, employeeData);
        transaction.set(accountOverviewRef, submission.accountOverview.toMap());
        transaction.set(
          _database
              .collection(HrEmployeeApiConstants.contactDetailsPath)
              .doc(employeeId),
          submission.contactDetails.toMap(),
        );
        transaction.set(
          _database
              .collection(HrEmployeeApiConstants.certificationsPath)
              .doc(employeeId),
          submission.certificationDetails.toMap(),
        );
        transaction.set(
          _database
              .collection(HrEmployeeApiConstants.insuranceDetailsPath)
              .doc(employeeId),
          submission.insuranceDetails.toMap(),
        );
        transaction.set(
          _database
              .collection(HrEmployeeApiConstants.emergencyDetailsPath)
              .doc(employeeId),
          submission.emergencyDetails.toMap(),
        );
        transaction.set(
          _database
              .collection(HrEmployeeApiConstants.attachmentsPath)
              .doc(employeeId),
          submission.attachments.toMap(),
        );
      });
      return const Right(null);
    } on EmployeeCreationFailure catch (failure) {
      return Left(failure);
    } catch (error) {
      return Left(EmployeeTransactionFailure(error.toString()));
    }
  }

  /// Method Name: [updateEmployeeSection]
  ///
  /// Purpose: Appends one selected section to the existing employee records.
  ///
  /// Parameters:
  /// - [payload]: Employee ID, section, and normalized values to persist.
  ///
  /// Returns: A typed update result after the Firestore transaction completes.
  Future<Either<EmployeeUpdateFailure, void>> updateEmployeeSection(
    EmployeeUpdatePayload payload,
  ) async {
    final employeeRef = _database
        .collection(HrEmployeeApiConstants.employeesInfoPath)
        .doc(payload.employeeId);
    final isSupplemental = payload.section == AddEmployeeStep.contactDetails ||
        payload.section == AddEmployeeStep.certificationDetails ||
        payload.section == AddEmployeeStep.insuranceDetails ||
        payload.section == AddEmployeeStep.emergencyDetails;
    final collection = switch (payload.section) {
      AddEmployeeStep.contactDetails =>
        HrEmployeeApiConstants.contactDetailsPath,
      AddEmployeeStep.certificationDetails =>
        HrEmployeeApiConstants.certificationsPath,
      AddEmployeeStep.insuranceDetails =>
        HrEmployeeApiConstants.insuranceDetailsPath,
      AddEmployeeStep.emergencyDetails =>
        HrEmployeeApiConstants.emergencyDetailsPath,
      _ => HrEmployeeApiConstants.employeesInfoPath,
    };
    final target = _database.collection(collection).doc(payload.employeeId);
    try {
      await _database.runTransaction((transaction) async {
        final snapshot = await transaction.get(target);
        final current = snapshot.data() ?? <String, dynamic>{};
        final employeeSnapshot =
            isSupplemental ? await transaction.get(employeeRef) : null;
        final updates = <String, dynamic>{};
        final targetValues = payload.section == AddEmployeeStep.contactDetails
            ? Map<String, dynamic>.fromEntries(
                payload.values.entries.where((entry) => {
                      'Personal_Email',
                      'Home_Country_Code',
                      'Office_Country_Code',
                    }.contains(entry.key)),
              )
            : payload.values;
        for (final entry in targetValues.entries) {
          if (entry.key == 'Mobile_Phone') {
            final value = entry.value as Map<String, dynamic>;
            updates[entry.key] = [
              {
                'Phone': [value['number']],
                'Country_Code': [value['countryCode']],
                'Country_App': [''],
                'Timestamp': [Timestamp.now()],
              },
            ];
          } else {
            final previous = current[entry.key];
            final history =
                previous is List ? List<dynamic>.from(previous) : <dynamic>[];
            history.add(entry.value);
            updates[entry.key] = history;
          }
        }
        final timestampKey = isSupplemental ? 'Timestamps' : 'timestamps';
        final timestamps = current[timestampKey] is List
            ? List<dynamic>.from(current[timestampKey] as List)
            : <dynamic>[];
        timestamps.add(isSupplemental &&
                payload.section == AddEmployeeStep.certificationDetails
            ? Timestamp.now()
            : DateTime.now().millisecondsSinceEpoch);
        updates[timestampKey] = timestamps;
        if (isSupplemental) {
          updates['Employee_Id'] = payload.employeeId;
        }
        transaction.set(target, updates, SetOptions(merge: true));
        if (isSupplemental && employeeSnapshot != null) {
          final employeeCurrent =
              employeeSnapshot.data() ?? <String, dynamic>{};
          final employeeUpdates = <String, dynamic>{};
          for (final entry in payload.values.entries) {
            if (entry.key == 'Mobile_Phone') continue;
            final previous = employeeCurrent[entry.key];
            final history =
                previous is List ? List<dynamic>.from(previous) : <dynamic>[];
            history.add(entry.value);
            employeeUpdates[entry.key] = history;
          }
          final timestamps = employeeCurrent['timestamps'] is List
              ? List<dynamic>.from(employeeCurrent['timestamps'] as List)
              : <dynamic>[];
          timestamps.add(DateTime.now().millisecondsSinceEpoch);
          employeeUpdates['timestamps'] = timestamps;
          transaction.set(
            employeeRef,
            employeeUpdates,
            SetOptions(merge: true),
          );
        }
      });
      return const Right(null);
    } catch (error) {
      return Left(EmployeeUpdateTransactionFailure(error.toString()));
    }
  }

  /// Method Name: [deleteUploadedFiles]
  ///
  /// Purpose: Best-effort cleanup for files from a failed create attempt.
  ///
  /// Parameters:
  /// - [urls]: Download URLs created by the current submission attempt.
  ///
  /// Returns: Completes after every cleanup attempt finishes.
  Future<void> deleteUploadedFiles(Iterable<String> urls) async {
    for (final url in urls.where((value) => value.isNotEmpty)) {
      try {
        await _storageBucket.refFromURL(url).delete();
      } catch (_) {
        // Cleanup is intentionally best-effort and must not replace the
        // original creation failure shown to the caller.
      }
    }
  }

  /// Method Name: [_legacyEmailExists]
  ///
  /// Purpose: Checks normalized email histories in the employee collection.
  ///
  /// Parameters:
  /// - [email]: Normalized email to find in legacy employee histories.
  ///
  /// Returns: Whether a legacy employee already uses the email.
  Future<bool> _legacyEmailExists(String email) async {
    final snapshot = await _database
        .collection(HrEmployeeApiConstants.employeesInfoPath)
        .where('Email', arrayContains: email)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  /// Method Name: [_personalEmailExists]
  ///
  /// Purpose: Checks personal-email histories in contact details.
  ///
  /// Parameters:
  /// - [email]: Normalized personal email to find.
  ///
  /// Returns: Whether a contact-details record already uses the email.
  Future<bool> _personalEmailExists(String email) async {
    final snapshot = await _database
        .collection(HrEmployeeApiConstants.contactDetailsPath)
        .where(
          EmployeeContactDetailsModel.personalEmailKey,
          arrayContains: email,
        )
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }
}
