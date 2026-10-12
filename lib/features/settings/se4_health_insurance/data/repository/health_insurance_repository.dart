/// Module: settings/se4_health_insurance
///
///*************************** FILE INFO ****************************///
/// File Name: health_insurance_repository.dart
/// Purpose: Reads and writes an employee's health-insurance record.
/// Author: Amr Mesbah
/// Created at: 20/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SE4-N04: the load path no longer falls through to a fabricated
///          `Right` on failure, and the mapping moved to HealthInsuranceMapper.

// PORTED into services_app under features/settings.
// Source: services_app features/employees/data/repository/health_insurance_repository.dart
// Imports rewired to the equivalents that already exist in services_app.

/// **************************** FILE INFO **************************** ///
/// Purpose: Repository to handle insurance data operations
/// Author: Amr Mesbah
/// created At: 20/11/2024

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/settings/main_controller/data/repository/employees_repository.dart';
import 'package:knowticed_plus/core/helper/main_helper/single_value_model.dart';
import 'package:knowticed_plus/features/settings/se4_health_insurance/domain/entities/request_health_insurance_entity.dart';
import 'package:knowticed_plus/features/settings/se4_health_insurance/data/data_source/remote_data_source/insurance_remote_data_source.dart';
import 'package:knowticed_plus/features/settings/se4_health_insurance/data/models/health_insurance_mapper.dart';
import 'package:knowticed_plus/features/settings/se4_health_insurance/data/models/health_insurance_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/mobile_phone_model.dart';


class HealthInsuranceRepository {
  final InsuranceRemoteDataSource _remoteDataSource =
      InsuranceRemoteDataSource();

  /// Function Name : addEmployeeInsuranceData
  /// Purpose: starting point function to add employee insurance data
  /// Parameters:
  ///            insuranceData: RequestInsuranceEntity - new insurance data to be added
  /// return: Future<Either<Failure, dynamic> - failure message or success
  Future<Either<Failure, dynamic>> addEmployeeInsuranceData({
    required HealthInsuranceEntity insuranceData,
  }) async {
    final result =
        await _checkIfEmployeeExist(employeeId: insuranceData.employeeId);
    if (result.isLeft()) return result;
    return await _addEmployeeInsuranceData(insuranceData: insuranceData);
  }

  /// Function Name : _checkIfEmployeeExist
  /// Purpose: function to check if employee exist or send error that no employee in the system
  /// Parameters:
  ///            employeeId: String - employee id to check if exist
  /// return: Future<Either<Failure, dynamic> - failure message or true if exist
  Future<Either<Failure, dynamic>> _checkIfEmployeeExist(
      {required String employeeId}) async {
    Either<Failure, dynamic> isEmployeeExist =
        await EmployeesRepository().isEmployeeExist(employeeId: employeeId);
    if (isEmployeeExist.isLeft()) return isEmployeeExist;
    if (isEmployeeExist.getOrElse(() => false) == false) {
      return Left(FirebaseFailure('Employee not found'));
    }
    return isEmployeeExist = Right(true);
  }

  /// Function Name : _addEmployeeInsuranceData
  /// Purpose: function controls algorithm flow to add employee insurance data
  /// Parameters:
  ///          RequestInsuranceEntity insuranceData - new insurance data to be added
  /// return: Future<Either<Failure, dynamic> - failure message or success
  Future<Either<Failure, dynamic>> _addEmployeeInsuranceData(
      {required HealthInsuranceEntity insuranceData}) async {
    Either<Failure, dynamic> result =
        await _getEmployeeInsuranceModel(employeeId: insuranceData.employeeId);
    if (result.isLeft()) return result;
    HealthInsuranceModel insuranceModel = result.getOrElse(() => null);
    _updateInsuranceModel(
        originalInsuranceModel: insuranceModel,
        newInsuranceData: insuranceData);
    return await _remoteDataSource.addEmployeeInsuranceData(
        data: insuranceModel.toMap(), documentId: insuranceData.employeeId);
  }

  /// Function Name : _getEmployeeInsuranceModel
  /// Purpose: function to get employee insurance model from database or create new one if not exist
  /// Parameters:
  ///            employeeId: String - employee id to get insurance data
  /// return: Future<Either<Failure, dynamic> - failure message or insurance model
  Future<Either<Failure, dynamic>> _getEmployeeInsuranceModel(
      {required String employeeId}) async {
    Either<Failure, dynamic> result = await _remoteDataSource
        .getEmployeeInsuranceData(employeeId: employeeId);
    if (result.isLeft()) return result;
    Map<String, dynamic>? insuranceData = result.getOrElse(() => null);
    if (insuranceData == null) {
      return Right(_createTempInsuranceModel(employeeId: employeeId));
    }
    return Right(HealthInsuranceModel.fromMap(insuranceData));
  }

  /// Function Name : _createTempInsuranceModel
  /// Purpose: function to create temporary insurance model
  /// Parameters:
  ///           employeeId: String - employee id to create insurance data
  /// return: InsuranceModel - temporary insurance model
  HealthInsuranceModel _createTempInsuranceModel({required String employeeId}) {
    return HealthInsuranceModel(
      employeeId: employeeId,
      insuranceProviderContact: MobilePhone(),
      insurancePolicyNumber: SingleValueModel(values:[] , timestamps: []),
      insuranceProviderName:
          SingleValueModel<String>(values: [], timestamps: []),
      postalCode: SingleValueModel<String>(values: [], timestamps: []),
    );
  }

  /// Function Name : _updateInsuranceModel
  /// Purpose: function controls algorithm flow to update insurance model locally
  /// Parameters:
  ///           originalInsuranceModel: InsuranceModel - original insurance model to be updated
  ///           newInsuranceData: RequestInsuranceEntity - new insurance data to be added
  void _updateInsuranceModel(
      {required HealthInsuranceModel originalInsuranceModel,
      required HealthInsuranceEntity newInsuranceData}) {
    originalInsuranceModel.employeeId = newInsuranceData.employeeId;
    _handleInsuranceProviderName(
        originalInsuranceModel: originalInsuranceModel,
        newInsuranceData: newInsuranceData);
    _handleInsuranceProviderContact(
        originalInsuranceModel: originalInsuranceModel,
        newInsuranceData: newInsuranceData);
    _handleInsurancePolicyNumber(
        originalInsuranceModel: originalInsuranceModel,
        newInsuranceData: newInsuranceData);
    _handleInsurancePostalCode(
        originalInsuranceModel: originalInsuranceModel,
        newInsuranceData: newInsuranceData);
  }

  /// Function Name : _handleInsurancePolicyNumber
  /// Purpose: function update insurance policy number in insurance model locally
  /// Parameters:
  ///            originalInsuranceModel: InsuranceModel - original insurance model to be updated
  ///            newInsuranceData: RequestInsuranceEntity - new insurance data to be added
  void _handleInsurancePolicyNumber(
      {required HealthInsuranceModel originalInsuranceModel,
      required HealthInsuranceEntity newInsuranceData}) {
    if (newInsuranceData.policyNumber != null) {
      originalInsuranceModel.insurancePolicyNumber.values
          .add(newInsuranceData.policyNumber!);
      originalInsuranceModel.insurancePolicyNumber.timestamps
          .add(Timestamp.now());
    }
  }

  /// Function Name : _handleInsuranceProviderContact
  /// Purpose: function update insurance provider contact in insurance model locally
  /// Parameters:
  ///           originalInsuranceModel: InsuranceModel - original insurance model to be updated
  ///           newInsuranceData: RequestInsuranceEntity - new insurance data to be added
  void _handleInsuranceProviderContact(
      {required HealthInsuranceModel originalInsuranceModel,
      required HealthInsuranceEntity newInsuranceData}) {
    if (newInsuranceData.providerNumber != null ||
        newInsuranceData.providerCountryCode != null ||
        newInsuranceData.providerCountryApp != null) {
      // check if any value changed
      if (originalInsuranceModel.insuranceProviderContact.countryCode == null) {
        originalInsuranceModel.insuranceProviderContact.countryCode = [];
        originalInsuranceModel.insuranceProviderContact.phones = [];
        originalInsuranceModel.insuranceProviderContact.countryApp = [];
        originalInsuranceModel.insuranceProviderContact.timestamps = [];
      }
      if(newInsuranceData.providerCountryCode != null){
        originalInsuranceModel.insuranceProviderContact.countryCode!
            .add(newInsuranceData.providerCountryCode!);
      } else {
        originalInsuranceModel.insuranceProviderContact.countryCode!.add(
            originalInsuranceModel.insuranceProviderContact.countryCode!.last);
      }

      if (newInsuranceData.providerCountryApp != null) {
        originalInsuranceModel.insuranceProviderContact.countryApp!
            .add(newInsuranceData.providerCountryApp!);
      } else {
        originalInsuranceModel.insuranceProviderContact.countryApp!.add(
            originalInsuranceModel.insuranceProviderContact.countryApp!.last);
      }

      if (newInsuranceData.providerNumber != null) {
        originalInsuranceModel.insuranceProviderContact.phones!
            .add(newInsuranceData.providerNumber!);
      } else {
        originalInsuranceModel.insuranceProviderContact.phones!
            .add(originalInsuranceModel.insuranceProviderContact.phones!.last);
      }
      originalInsuranceModel.insuranceProviderContact.timestamps!
          .add(Timestamp.now());
    }
  }

  /// Function Name : _handleInsuranceProviderName
  /// Purpose: function update insurance provider name in insurance model locally
  /// Parameters:
  ///            originalInsuranceModel: InsuranceModel - original insurance model to be updated
  ///            newInsuranceData: RequestInsuranceEntity - new insurance data to be added
  void _handleInsuranceProviderName(
      {required HealthInsuranceModel originalInsuranceModel,
      required HealthInsuranceEntity newInsuranceData}) {
    if (newInsuranceData.providerName != null) {
      originalInsuranceModel.insuranceProviderName.values
          .add(newInsuranceData.providerName!);
      originalInsuranceModel.insuranceProviderName.timestamps
          .add(Timestamp.now());
    }
  }

  void _handleInsurancePostalCode(
      {required HealthInsuranceModel originalInsuranceModel,
      required HealthInsuranceEntity newInsuranceData}) {
    if (newInsuranceData.postalCode != null) {
      originalInsuranceModel.postalCode.values
          .add(newInsuranceData.postalCode!);
      originalInsuranceModel.postalCode.timestamps.add(Timestamp.now());
    }
  }

  Future<Either<Failure, HealthInsuranceEntity>> getEmployeeInsuranceData(
      {required String employeeId}) async {
    final Either<Failure, dynamic> data =
        await _getEmployeeInsuranceModel(employeeId: employeeId);

    // The `if (data.isLeft())` branch below used to assign `result` but never
    // return, so execution fell through to `getOrElse(() => null)` and then
    // passed null into `HealthInsuranceEntity.fromModel` — a read failure was
    // reported as success and crashed with an NPE. Matches se5's pattern now.
    return data.fold<Either<Failure, HealthInsuranceEntity>>(
      (Failure failure) => Left(failure),
      (dynamic insuranceModel) {
        if (insuranceModel is! HealthInsuranceModel) {
          return Left(FirebaseFailure('No insurance record for this employee'));
        }
        return Right(HealthInsuranceMapper.toEntity(insuranceModel));
      },
    );
  }
}
