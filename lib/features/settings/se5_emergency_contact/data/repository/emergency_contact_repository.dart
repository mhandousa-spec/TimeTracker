/// Module: settings/se5_emergency_contact
///
///*************************** FILE INFO ****************************///
/// File Name: emergency_contact_repository.dart
/// Purpose: Reads and writes an employee's two emergency contacts.
/// Author: Amr Mesbah
/// Created at: 20/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SE5-N09: mapping moved to EmergencyContactMapper.

// PORTED into services_app under features/settings.
// Source: services_app features/employees/data/repository/emergency_contact_repository.dart
// Imports rewired to the equivalents that already exist in services_app.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/helper/main_helper/single_value_model.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/settings/se5_emergency_contact/data/models/emergency_contacts_model.dart';
import 'package:knowticed_plus/features/settings/se5_emergency_contact/data/models/emergency_contact_mapper.dart';
import 'package:knowticed_plus/features/settings/se5_emergency_contact/domain/entities/emergency_contact_entity.dart';

import 'package:knowticed_plus/features/settings/se5_emergency_contact/data/data_source/remote_data_source/emergency_contact_remote_data_source.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/mobile_phone_model.dart';
import 'package:knowticed_plus/features/settings/main_controller/data/repository/employees_repository.dart';

/// **************************** FILE INFO **************************** ///
/// Purpose: Repository to handle Emergency contact data operations
/// Author: Amr Mesbah
/// created At: 21/11/2024

class EmergencyContactRepository {
  final EmergencyContactRemoteDataSource _remoteDataSource =
  EmergencyContactRemoteDataSource();

  Future<Either<Failure, dynamic>> addEmployeeInsuranceData({
    required EmergencyContactEntity emergencyContactData,
  }) async {
    final result = await _checkIfEmployeeExist(
        employeeId: emergencyContactData.employeeId);
    if (result.isLeft()) return result;
    return await _addEmployeeEmergencyContactData(
        emergencyContactData: emergencyContactData);
  }

  // Todo: refactor this method
  _checkIfEmployeeExist({required String employeeId}) async {
    Either<Failure, dynamic> isEmployeeExist =
    await EmployeesRepository().isEmployeeExist(employeeId: employeeId);
    if (isEmployeeExist.isLeft()) return isEmployeeExist;
    if (isEmployeeExist.getOrElse(() => false) == false) {
      return Left(FirebaseFailure('Employee not found'));
    }
    return isEmployeeExist = Right(true);
  }

  _addEmployeeEmergencyContactData(
      {required EmergencyContactEntity emergencyContactData}) async {
    Either<Failure, dynamic> result = await _getEmployeeEmergencyContactModel(
        employeeId: emergencyContactData.employeeId);
    if (result.isLeft()) return result;
    EmergencyContactsModel emergencyContactModel = result.getOrElse(() => null);
    _updateEmergencyContactModel(
        originalEmergencyContactModel: emergencyContactModel,
        newEmergencyContactData: emergencyContactData);
    return await _remoteDataSource.addEmergencyContactData(
        data: emergencyContactModel.toMap(),
        documentId: emergencyContactModel.employeeId);
  }

  _getEmployeeEmergencyContactModel({required String employeeId}) async {
    Either<Failure, dynamic> result =
    await _remoteDataSource.getEmergencyContactData(employeeId: employeeId);
    if (result.isLeft()) return result;
    Map<String, dynamic>? insuranceData = result.getOrElse(() => null);
    if (insuranceData == null) {
      return result = Right(_createTempInsuranceModel(employeeId: employeeId));
    }
    return result = Right(EmergencyContactsModel.fromMap(insuranceData));
  }

  void _updateEmergencyContactModel(
      {required EmergencyContactsModel originalEmergencyContactModel,
        required EmergencyContactEntity newEmergencyContactData}) {
    // First Emergency Contact
    _handleSingleValueItem(
        itemModel:
        originalEmergencyContactModel.firstEmergencyContact!.firstName,
        itemValue: newEmergencyContactData.firstContactFirstName);
    _handleSingleValueItem(
        itemModel:
        originalEmergencyContactModel.firstEmergencyContact!.middleName,
        itemValue: newEmergencyContactData.firstContactMiddleName);
    _handleSingleValueItem(
        itemModel:
        originalEmergencyContactModel.firstEmergencyContact!.lastName,
        itemValue: newEmergencyContactData.firstContactLastName);
    _handleSingleValueItem(
        itemModel:
        originalEmergencyContactModel.firstEmergencyContact!.relationShip,
        itemValue: newEmergencyContactData.firstContactRelationShip);
    _handleSingleValueItem(
        itemModel: originalEmergencyContactModel.firstEmergencyContact!.email,
        itemValue: newEmergencyContactData.firstContactEmail);
    _handleSingleValueItem(
        itemModel: originalEmergencyContactModel.firstEmergencyContact!.country,
        itemValue: newEmergencyContactData.firstContactCountry);
    _handleSingleValueItem(
        itemModel:
        originalEmergencyContactModel.firstEmergencyContact!.province,
        itemValue: newEmergencyContactData.firstContactProvince);
    _handleSingleValueItem(
        itemModel: originalEmergencyContactModel.firstEmergencyContact!.city,
        itemValue: newEmergencyContactData.firstContactCity);
    _handleSingleValueItem(
        itemModel: originalEmergencyContactModel.firstEmergencyContact!.street,
        itemValue: newEmergencyContactData.firstContactStreet); // NEW: Added street handling

    // Second Emergency Contact
    _handleSingleValueItem(
        itemModel:
        originalEmergencyContactModel.secondEmergencyContact!.firstName,
        itemValue: newEmergencyContactData.secondContactFirstName);
    _handleSingleValueItem(
        itemModel:
        originalEmergencyContactModel.secondEmergencyContact!.middleName,
        itemValue: newEmergencyContactData.secondContactMiddleName);
    _handleSingleValueItem(
        itemModel:
        originalEmergencyContactModel.secondEmergencyContact!.lastName,
        itemValue: newEmergencyContactData.secondContactLastName);
    _handleSingleValueItem(
        itemModel:
        originalEmergencyContactModel.secondEmergencyContact!.relationShip,
        itemValue: newEmergencyContactData.secondContactRelationShip);
    _handleSingleValueItem(
        itemModel: originalEmergencyContactModel.secondEmergencyContact!.email,
        itemValue: newEmergencyContactData.secondContactEmail);
    _handleSingleValueItem(
        itemModel:
        originalEmergencyContactModel.secondEmergencyContact!.country,
        itemValue: newEmergencyContactData.secondContactCountry);
    _handleSingleValueItem(
        itemModel:
        originalEmergencyContactModel.secondEmergencyContact!.province,
        itemValue: newEmergencyContactData.secondContactProvince);
    _handleSingleValueItem(
        itemModel: originalEmergencyContactModel.secondEmergencyContact!.city,
        itemValue: newEmergencyContactData.secondContactCity);
    _handleSingleValueItem(
        itemModel: originalEmergencyContactModel.secondEmergencyContact!.street,
        itemValue: newEmergencyContactData.secondContactStreet); // NEW: Added street handling

    // Phone handling
    _handlePhoneItem(
        itemModel: originalEmergencyContactModel.firstEmergencyContact!.phone,
        phoneNumber: newEmergencyContactData.firstContactPhone,
        countryApp: newEmergencyContactData.firstContactCountryApp,
        countryCode: newEmergencyContactData.firstContactCountryCode);
    _handlePhoneItem(
        itemModel: originalEmergencyContactModel.secondEmergencyContact!.phone,
        phoneNumber: newEmergencyContactData.secondContactPhone,
        countryApp: newEmergencyContactData.secondContactCountryApp,
        countryCode: newEmergencyContactData.secondContactCountryCode);
  }

  _createTempInsuranceModel({required String employeeId}) {
    return EmergencyContactsModel(
      employeeId: employeeId,
      firstEmergencyContact: _getEmptyEmergencyContactModel(),
      secondEmergencyContact: _getEmptyEmergencyContactModel(),
    );
  }

  EmergencyContactModel _getEmptyEmergencyContactModel() {
    return EmergencyContactModel(
      firstName: SingleValueModel<String>(
        values: [],
        timestamps: [],
      ),
      middleName: SingleValueModel<String>(
        values: [],
        timestamps: [],
      ),
      lastName: SingleValueModel<String>(
        values: [],
        timestamps: [],
      ),
      relationShip: SingleValueModel<String>(
        values: [],
        timestamps: [],
      ),
      phone: MobilePhone(
        phones: [],
        countryCode: [],
        countryApp: [],
        timestamps: [],
      ),
      email: SingleValueModel<String>(
        values: [],
        timestamps: [],
      ),
      country: SingleValueModel<String>(
        values: [],
        timestamps: [],
      ),
      province: SingleValueModel<String>(
        values: [],
        timestamps: [],
      ),
      city: SingleValueModel<String>(
        values: [],
        timestamps: [],
      ),
      street: SingleValueModel<String>(
        values: [],
        timestamps: [],
      ),
      language: SingleValueModel<String>( // ADD THIS
        values: [],
        timestamps: [],
      ),
    );
  }

  void _handleSingleValueItem(
      {required SingleValueModel<String> itemModel,
        required String? itemValue}) {
    if (itemValue != null && itemValue != itemModel.values.lastOrNull) {
      itemModel.values.add(itemValue);
      itemModel.timestamps.add(Timestamp.now());
    }
  }

  _handlePhoneItem(
      {required MobilePhone itemModel,
        required String? countryApp,
        required String? phoneNumber,
        required String? countryCode}) {
    if ((phoneNumber != null && phoneNumber != itemModel.phones!.lastOrNull) ||
        (countryCode != null &&
            countryCode != itemModel.countryCode!.lastOrNull)||
        (countryApp != null && countryApp != itemModel.countryApp!.lastOrNull)) {
      // services_app's MobilePhone declares List<String> (non-nullable
      // elements), whereas services_app's declares List<String?>. The guard
      // above only requires ONE of the three to be non-null, so the other two
      // may still be null here - coerce to '' since a null cannot be stored.
      itemModel.phones!.add(phoneNumber ?? '');
      itemModel.countryCode!.add(countryCode ?? '');
      itemModel.countryApp!.add(countryApp ?? '');
      itemModel.timestamps!.add(Timestamp.now());
    }
  }

  Future<Either<Failure, EmergencyContactEntity>>
  getEmployeeEmergencyContactData({required String employeeId}) async {
    Either<Failure, dynamic> data =
    await _getEmployeeEmergencyContactModel(employeeId: employeeId);
    Either<Failure, EmergencyContactEntity> result;
    if (data.isLeft()) {
      Failure? failure = data.fold((l) => l, (r) => null);
      return Left(failure!);
    }
    EmergencyContactsModel emergencyContactModel = data.getOrElse(() => null);
    return result =
        Right(EmergencyContactMapper.toEntity(emergencyContactModel));
  }
}