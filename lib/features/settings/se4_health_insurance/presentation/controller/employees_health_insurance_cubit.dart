/// Module: settings/se4_health_insurance
///
///*************************** FILE INFO ****************************///
/// File Name: employees_health_insurance_cubit.dart
/// Purpose: Loads insurance data and bulk-imports it from a CSV.
/// Author: Amr Mesbah
/// Created at: 20/11/2024
/// Updated: 11/8/2026 - Added the standard header (Docs).

// ******************* FILE INFO *******************
// File Name: employees_health_insurance_cubit.dart
// Description: Employee health-insurance data. Converted from the GetX
//              `HealthInsuranceController`, which shared its class name with
//              the neighbouring health_insurance_controller.dart's
//              SettingsHealthInsuranceController and was confusing to read.
// Module: features / settings / presentation / controller
// Source: ported from services_app
//         features/employees/presentation/controller/health_insurance_controller.dart
// *************************************************

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/settings/se4_health_insurance/data/repository/health_insurance_repository.dart';
import 'package:knowticed_plus/features/settings/se4_health_insurance/domain/entities/request_health_insurance_entity.dart';
import 'package:knowticed_plus/features/settings/se4_health_insurance/presentation/controller/employees_health_insurance_state.dart';

class EmployeesHealthInsuranceCubit
    extends Cubit<EmployeesHealthInsuranceState> {
  EmployeesHealthInsuranceCubit({HealthInsuranceRepository? repository})
      : _repository = repository ?? HealthInsuranceRepository(),
        super(EmployeesHealthInsuranceState.initial());

  final HealthInsuranceRepository _repository;

  /// Guard against emit-after-close when a screen is popped mid-await.
  @override
  void emit(EmployeesHealthInsuranceState state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Loads one employee's insurance record into state and returns it.
  ///
  /// The return value is kept because the existing caller
  /// (SettingsHealthInsuranceController) consumes it directly rather than
  /// watching state; new UI should prefer BlocBuilder over the return value.
  Future<HealthInsuranceEntity?> loadEmployeeData({
    required String employeeId,
  }) async {
    emit(state.copyWith(
      status: EmployeesHealthInsuranceStatus.loading,
      employeeId: employeeId,
      clearError: true,
    ));

    final Either<Failure, HealthInsuranceEntity> result =
        await _repository.getEmployeeInsuranceData(employeeId: employeeId);

    return result.fold(
      (failure) {
        emit(state.copyWith(
          status: EmployeesHealthInsuranceStatus.failure,
          errorMessage: failure.toString(),
          clearInsurance: true,
        ));
        return null;
      },
      (entity) {
        emit(state.copyWith(
          status: EmployeesHealthInsuranceStatus.success,
          insurance: entity,
        ));
        return entity;
      },
    );
  }

  /// Bulk-imports employee insurance rows from parsed CSV data.
  ///
  /// NOTE: nothing calls this today — it was already unreferenced on the GetX
  /// controller. Preserved during the cubit conversion so the capability isn't
  /// silently lost; safe to delete if the CSV import path is truly gone.
  Future<void> importFromCsvData({
    required List<List<dynamic>> csvData,
  }) async {
    emit(state.copyWith(
      status: EmployeesHealthInsuranceStatus.loading,
      clearError: true,
    ));

    try {
      final rows = _parseCsv(csvData);
      for (final row in rows) {
        await _repository.addEmployeeInsuranceData(insuranceData: row);
      }
      emit(state.copyWith(status: EmployeesHealthInsuranceStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: EmployeesHealthInsuranceStatus.failure,
        errorMessage: 'Failed to import insurance data: $e',
      ));
    }
  }

  /// Row 0 is the header, so parsing starts at 1.
  List<HealthInsuranceEntity> _parseCsv(List<List<dynamic>> csvData) {
    final List<HealthInsuranceEntity> insuranceData = [];
    for (int i = 1; i < csvData.length; i++) {
      insuranceData.add(HealthInsuranceEntity(
        employeeId: csvData[i][0].toString(),
        providerCountryCode: csvData[i][1].toString(),
        providerCountryApp: csvData[i][2].toString(),
        providerNumber: csvData[i][3].toString(),
        policyNumber: csvData[i][4].toString(),
        providerName: csvData[i][5].toString(),
        postalCode: csvData[i][6].toString(),
      ));
    }
    return insuranceData;
  }
}
