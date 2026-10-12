import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/org_chart_module/data/models/department_model.dart';

import 'package:knowticed_plus/features/org_chart_module/data/data_source/remote_data_source/departments_remote_data_source.dart';
///********************** FILE INFO ********************///
/// Class Name: DepartmentsRepository
/// Purpose: A class to control data flow for departments
/// Author: Mohamed Elrashidy
/// created At: 5/11/2024
class DepartmentsRepository {
  final DepartmentsRemoteDataSource _remoteDataSource =
      DepartmentsRemoteDataSource();
  /// Function Name : getDepartments
  /// Purpose: function to get all departments in form of department model
  /// return: Future<Either<Failure, dynamic> - department model or failure
  Future<Either<Failure, dynamic>> getDepartments() async {
    Either<Failure, dynamic> result;
    result = await _remoteDataSource.getDepartments();
    if (result.isLeft()) return result;
    Map<String, dynamic>? data = result.getOrElse(() => null);
    if (data == null) return Left(FirebaseFailure("No data found"));
    DepartmentModel departments = DepartmentModel.fromMap(data);
    return result= Right(departments);
  }

}
