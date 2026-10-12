/// Module: onboarding/o3_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: demo_initialization_repository.dart
/// Purpose: Seeds a new demo tenant.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - CR-SKEL-O3-N05: renamed from the misspelled `demo_initialiazation_repository.dart`.

///************************** FILE INFO **************************///
/// File Name: demo_initialization_repository.dart
/// Purpose: Contains the repository for demo data initialization feature.
/// Author: Amr Mesbah
/// Created At: 4/1/2025
/// Updated: 9/12/2025 - Structure now created by admin app, just validate here
/// ✅ SIMPLIFIED VERSION: Admin app creates structure, this just validates

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/data/data_source/remote_data_source/demo_remote_data_source.dart' hide Right;
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/data/models/demo_company_model.dart';

class DemoInitializationRepository {
  DemoRemoteDataSource demoRemoteDataSource = DemoRemoteDataSource();

  /// function name: startDemoAdminData
  /// function purpose: Validate that demo structure exists (created by admin app)
  /// parameters:
  ///           companyModel - DemoCompanyModel - the company model to validate
  /// ✅ SIMPLIFIED: Just check if structure exists, no creation needed
  startDemoAdminData({required DemoCompanyModel companyModel}) async {
    Either<Failure, dynamic> result;

    try {
      // ✅ Check if Demo structure already exists

      DocumentSnapshot employeeDoc = await FirebaseFirestore.instance
          .collection(getBaseUrl('Employees_Info'))
          .doc('1')
          .get();

      if (employeeDoc.exists) {

        // Return the existing employee
        NewEmployeeModelHistory employee = NewEmployeeModelHistory.fromMap(
            employeeDoc.data() as Map<String, dynamic>);

        result = Right(employee);
      } else {

        result = Left(FirebaseFailure(
            "Demo structure not found. Please contact administrator."));
      }
    } catch (e, stackTrace) {

      result = Left(FirebaseFailure(
          "Failed to validate demo structure: ${e.toString()}"));
    }

    return result;
  }
}