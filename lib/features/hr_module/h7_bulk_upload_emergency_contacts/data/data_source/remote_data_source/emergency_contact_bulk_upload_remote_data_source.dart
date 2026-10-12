// ***************************** FILE INFO ***************************** //
// File Name: emergency_contact_bulk_upload_remote_data_source.dart
// Purpose: Transactionally updates employee emergency-contact histories.
// Author: Mohamed Elrashidy
// Created At: 2026-08-19
// ********************************************************************* //

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../../core/helper/hr/hr_api_constants.dart';
import '../../../../../roles/r4_active_directory/data/models/employees_model/mobile_phone_model.dart';
import '../../../utils/emergency_contact_bulk_upload_headers.dart';
import '../../../../shared/bulk_upload/bulk_upload_template.dart';
import '../../models/emergency_contact_bulk_upload_models.dart';

/// Firestore boundary for emergency-contact bulk updates.
class EmergencyContactBulkUploadRemoteDataSource {
  EmergencyContactBulkUploadRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  Future<EmergencyContactBulkUploadPreflight> loadPreflight() async {
    final snapshot = await _firestore
        .collection(HrEmployeeApiConstants.employeesInfoPath)
        .get();
    return EmergencyContactBulkUploadPreflight(
        {for (final doc in snapshot.docs) doc.id.trim()});
  }

  Future<void> appendEmergencyContact({required BulkUploadRow row}) async {
    final id = row.value(EmergencyContactBulkUploadHeaders.employeeId);
    final employeeRef =
        _firestore.collection(HrEmployeeApiConstants.employeesInfoPath).doc(id);
    final detailsRef = _firestore
        .collection(HrEmployeeApiConstants.emergencyDetailsPath)
        .doc(id);
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    await _firestore.runTransaction((transaction) async {
      final employeeSnapshot = await transaction.get(employeeRef);
      if (!employeeSnapshot.exists) throw StateError('employee-not-found');
      final detailsSnapshot = await transaction.get(detailsRef);
      final employee = Map<String, dynamic>.from(employeeSnapshot.data()!);
      final details = detailsSnapshot.exists
          ? Map<String, dynamic>.from(detailsSnapshot.data()!)
          : <String, dynamic>{'Employee_Id': id};
      employee['timestamps'] = [..._list(employee['timestamps']), timestamp];
      _append(employee, 'First_Contact_First_Name',
          row.value(EmergencyContactBulkUploadHeaders.firstName));
      _append(employee, 'First_Contact_Last_Name',
          row.value(EmergencyContactBulkUploadHeaders.firstLastName));
      _append(employee, 'First_Contact_First_Name_Arabic',
          row.value(EmergencyContactBulkUploadHeaders.firstNameArabic));
      _append(employee, 'First_Contact_Last_Name_Arabic',
          row.value(EmergencyContactBulkUploadHeaders.firstLastNameArabic));
      _append(employee, 'First_Contact_Relationship',
          row.value(EmergencyContactBulkUploadHeaders.firstRelationship));
      _append(employee, 'First_Contact_Email',
          row.value(EmergencyContactBulkUploadHeaders.firstEmail));
      _append(employee, 'First_Contact_Phone',
          row.value(EmergencyContactBulkUploadHeaders.firstPhone));
      _append(employee, 'First_Contact_Language',
          row.value(EmergencyContactBulkUploadHeaders.firstLanguage));
      _append(employee, 'First_Contact_Country',
          row.value(EmergencyContactBulkUploadHeaders.firstCountry));
      _append(employee, 'First_Contact_Province',
          row.value(EmergencyContactBulkUploadHeaders.firstProvince));
      _append(employee, 'First_Contact_City',
          row.value(EmergencyContactBulkUploadHeaders.firstCity));
      _append(employee, 'First_Contact_Street',
          row.value(EmergencyContactBulkUploadHeaders.firstStreet));
      _append(employee, 'Second_Contact_First_Name',
          row.value(EmergencyContactBulkUploadHeaders.secondName));
      _append(employee, 'Second_Contact_Last_Name',
          row.value(EmergencyContactBulkUploadHeaders.secondLastName));
      _append(employee, 'Second_Contact_First_Name_Arabic',
          row.value(EmergencyContactBulkUploadHeaders.secondNameArabic));
      _append(employee, 'Second_Contact_Last_Name_Arabic',
          row.value(EmergencyContactBulkUploadHeaders.secondLastNameArabic));
      _append(employee, 'Second_Contact_Relationship',
          row.value(EmergencyContactBulkUploadHeaders.secondRelationship));
      _append(employee, 'Second_Contact_Email',
          row.value(EmergencyContactBulkUploadHeaders.secondEmail));
      _append(employee, 'Second_Contact_Phone',
          row.value(EmergencyContactBulkUploadHeaders.secondPhone));
      _append(employee, 'Second_Contact_Language',
          row.value(EmergencyContactBulkUploadHeaders.secondLanguage));
      _append(employee, 'Second_Contact_Country',
          row.value(EmergencyContactBulkUploadHeaders.secondCountry));
      _append(employee, 'Second_Contact_Province',
          row.value(EmergencyContactBulkUploadHeaders.secondProvince));
      _append(employee, 'Second_Contact_City',
          row.value(EmergencyContactBulkUploadHeaders.secondCity));
      _append(employee, 'Second_Contact_Street',
          row.value(EmergencyContactBulkUploadHeaders.secondStreet));
      _append(details, 'First_Contact_First_Name_Arabic',
          row.value(EmergencyContactBulkUploadHeaders.firstNameArabic));
      _append(details, 'First_Contact_Last_Name_Arabic',
          row.value(EmergencyContactBulkUploadHeaders.firstLastNameArabic));
      _append(details, 'First_Contact_Country_Code',
          row.value(EmergencyContactBulkUploadHeaders.firstPhoneCountryCode));
      _append(details, 'Second_Contact_First_Name_Arabic',
          row.value(EmergencyContactBulkUploadHeaders.secondNameArabic));
      _append(details, 'Second_Contact_Last_Name_Arabic',
          row.value(EmergencyContactBulkUploadHeaders.secondLastNameArabic));
      _append(details, 'Second_Contact_Country_Code',
          row.value(EmergencyContactBulkUploadHeaders.secondPhoneCountryCode));
      details['Timestamps'] = [..._list(details['Timestamps']), timestamp];
      employee['First_Contact_Phone_Details'] = [
        ..._list(employee['First_Contact_Phone_Details']),
        MobilePhone(phones: [
          row.value(EmergencyContactBulkUploadHeaders.firstPhone)
        ], countryCode: [
          row.value(EmergencyContactBulkUploadHeaders.firstPhoneCountryCode)
        ], countryApp: const [
          'EG'
        ], timestamps: [
          Timestamp.fromDate(now)
        ]).toMap()
      ];
      employee['Second_Contact_Phone_Details'] = [
        ..._list(employee['Second_Contact_Phone_Details']),
        MobilePhone(phones: [
          row.value(EmergencyContactBulkUploadHeaders.secondPhone)
        ], countryCode: [
          row.value(EmergencyContactBulkUploadHeaders.secondPhoneCountryCode)
        ], countryApp: const [
          'EG'
        ], timestamps: [
          Timestamp.fromDate(now)
        ]).toMap()
      ];
      transaction.update(employeeRef, employee);
      transaction.set(detailsRef, details);
    });
  }

  void _append(Map<String, dynamic> map, String key, String value) =>
      map[key] = [..._list(map[key]), value];
  List<dynamic> _list(dynamic value) =>
      value is List ? List<dynamic>.from(value) : <dynamic>[];
}
