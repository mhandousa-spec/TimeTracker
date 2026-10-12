/// Module: settings/se5_emergency_contact
///
///*************************** FILE INFO ****************************///
/// File Name: emergency_contact_controller.dart
/// Purpose: Loads an employee's emergency contacts, and bulk-imports them from
///          a CSV.
/// Author: Amr Mesbah
/// Created at: 20/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SE5-N01/N11/N12/N13: converted from a plain
///          class to a Cubit with a state object; the repository is injected
///          rather than constructed in a field initializer; a failed load emits
///          [EmergencyContactStatus.failure] instead of folding the `Left` to
///          `null`; and the CSV import stops reporting success when a row fails
///          to write — it used to fire the writes in a loop and drop every
///          returned `Either` on the floor.
///
/// The class name is kept: `SettingsHealthInsuranceController` and the settings
/// shell resolve it by that name through GetX.
///
/// PORTED into services_app under features/settings.
/// Source: services_app features/employees/presentation/controller/…

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/settings/se5_emergency_contact/data/repository/emergency_contact_repository.dart';
import 'package:knowticed_plus/features/settings/se5_emergency_contact/domain/entities/emergency_contact_entity.dart';

part './emergency_contact_state.dart';

class EmergencyContactController extends Cubit<EmergencyContactState> {
  EmergencyContactController({EmergencyContactRepository? repository})
      : _repository = repository ?? EmergencyContactRepository(),
        super(const EmergencyContactState());

  final EmergencyContactRepository _repository;

  @override
  void emit(EmergencyContactState state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Column order of the bulk-import CSV. Written out so a reordered export is
  /// a compile-time rename rather than silent data corruption
  /// (CR-SKEL-SE5-N13 — the parser used bare indexes 0..22).
  static const int _colEmployeeId = 0;
  static const int _colFirstFirstName = 1;
  static const int _colFirstMiddleName = 2;
  static const int _colFirstLastName = 3;
  static const int _colFirstCountryCode = 4;
  static const int _colFirstCountryApp = 5;
  static const int _colFirstPhone = 6;
  static const int _colFirstEmail = 7;
  static const int _colFirstRelationship = 8;
  static const int _colFirstCountry = 9;
  static const int _colFirstCity = 10;
  static const int _colFirstProvince = 11;
  static const int _colSecondFirstName = 12;
  static const int _colSecondMiddleName = 13;
  static const int _colSecondLastName = 14;
  static const int _colSecondCountryCode = 15;
  static const int _colSecondCountryApp = 16;
  static const int _colSecondPhone = 17;
  static const int _colSecondEmail = 18;
  static const int _colSecondRelationship = 19;
  static const int _colSecondCountry = 20;
  static const int _colSecondCity = 21;
  static const int _colSecondProvince = 22;

  /// The number of columns a valid row must have.
  static const int _expectedColumns = 23;

  /// Function Name: [getEmployeeData]
  ///
  /// Purpose: Load one employee's emergency contacts.
  ///
  /// Returns: [Future<EmergencyContactEntity?>] — kept for the existing call
  ///          sites in se4, which await the entity directly. The failure is
  ///          also recorded in state, so a caller that reads the cubit can tell
  ///          "no contacts" from "the read failed".
  Future<EmergencyContactEntity?> getEmployeeData(
      {required String employeeId}) async {
    emit(state.copyWith(status: EmergencyContactStatus.loading));

    final Either<Failure, EmergencyContactEntity> result =
        await _repository.getEmployeeEmergencyContactData(
            employeeId: employeeId);

    return result.fold(
      (Failure failure) {
        emit(state.copyWith(
          status: EmergencyContactStatus.failure,
          contact: null,
          errorMessage: failure.errMessage,
        ));
        return null;
      },
      (EmergencyContactEntity contact) {
        emit(state.copyWith(
          status: EmergencyContactStatus.success,
          contact: contact,
          errorMessage: null,
        ));
        return contact;
      },
    );
  }

  /// Function Name: [addEmployeesEmergencyContactData]
  ///
  /// Purpose: Bulk-import contacts from a parsed CSV.
  ///
  /// Returns: [Future<int>] — how many rows failed to write. Was `void`, with
  ///          the writes fired in a loop and every returned `Either` ignored,
  ///          so a partly-failed import looked identical to a clean one.
  Future<int> addEmployeesEmergencyContactData(
      {required List<List<dynamic>> csvData}) async {
    emit(state.copyWith(status: EmergencyContactStatus.loading));

    final List<EmergencyContactEntity> rows = _parseCsv(csvData);
    int failures = 0;

    for (final EmergencyContactEntity contact in rows) {
      final Either<Failure, dynamic> result =
          await _repository.addEmployeeInsuranceData(
              emergencyContactData: contact);
      if (result.isLeft()) failures++;
    }

    emit(state.copyWith(
      status: failures == 0
          ? EmergencyContactStatus.success
          : EmergencyContactStatus.failure,
      errorMessage:
          failures == 0 ? null : '$failures of ${rows.length} rows failed.',
    ));

    return failures;
  }

  /// Row 0 is the header, so parsing starts at 1. Rows with too few columns are
  /// skipped rather than throwing a RangeError mid-import.
  List<EmergencyContactEntity> _parseCsv(List<List<dynamic>> csvData) {
    final List<EmergencyContactEntity> contacts = <EmergencyContactEntity>[];

    for (int i = 1; i < csvData.length; i++) {
      final List<dynamic> row = csvData[i];
      if (row.length < _expectedColumns) continue;

      String cell(int index) => row[index]?.toString() ?? '';

      contacts.add(EmergencyContactEntity(
        employeeId: cell(_colEmployeeId),
        firstContactFirstName: cell(_colFirstFirstName),
        firstContactMiddleName: cell(_colFirstMiddleName),
        firstContactLastName: cell(_colFirstLastName),
        firstContactCountryCode: cell(_colFirstCountryCode),
        firstContactCountryApp: cell(_colFirstCountryApp),
        firstContactPhone: cell(_colFirstPhone),
        firstContactEmail: cell(_colFirstEmail),
        firstContactRelationShip: cell(_colFirstRelationship),
        firstContactCountry: cell(_colFirstCountry),
        firstContactCity: cell(_colFirstCity),
        firstContactProvince: cell(_colFirstProvince),
        secondContactFirstName: cell(_colSecondFirstName),
        secondContactMiddleName: cell(_colSecondMiddleName),
        secondContactLastName: cell(_colSecondLastName),
        secondContactCountryCode: cell(_colSecondCountryCode),
        secondContactCountryApp: cell(_colSecondCountryApp),
        secondContactPhone: cell(_colSecondPhone),
        secondContactEmail: cell(_colSecondEmail),
        secondContactRelationShip: cell(_colSecondRelationship),
        secondContactCountry: cell(_colSecondCountry),
        secondContactCity: cell(_colSecondCity),
        secondContactProvince: cell(_colSecondProvince),
      ));
    }

    return contacts;
  }
}
