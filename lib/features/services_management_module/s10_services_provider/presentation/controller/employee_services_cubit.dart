/// Module: services_management_module
/// Description: Cubit owning the single Firestore fetch-and-cache pass for
///              the s10 "my assigned services" list screen: pulls every
///              request-service doc under the tenant's RequestServices
///              collection, filters to the ones assigned to the current
///              provider email, enriches with employee/department data
///              already held by MainCoreEmployeeController (no extra
///              Firestore calls), and backfills the service name from
///              CreateServicesHelper when missing. All filtering/searching/
///              counting the UI does afterwards works off this cached list.
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: flutter_bloc, cloud_firestore, ApiConstants,
///               FirebaseCollections, MainCoreEmployeeController,
///               CreateServicesHelper
/// Revision History: Initial version — extracted from
///                    s10_services_provider/ui/services_management_module/employee_services.dart
///                    _loadAndCacheServices() (audit fix 1b). Replaced the
///                    hardcoded 'Demo'/'RequestServices' collection path
///                    segments with FirebaseCollections constants.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/controller/create_services_helper.dart';
import 'package:knowticed_plus/features/services_management_module/s10_services_provider/presentation/controller/employee_services_state.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';

class EmployeeServicesCubit extends Cubit<EmployeeServicesState> {
  // B5 FIX: guard against emit-after-close (StateError) when the user
  // navigates away mid-await. Applies to every emit in this cubit.
  @override
  void emit(state) {
    if (isClosed) return;
    super.emit(state);
  }

  final FirebaseFirestore firestore;
  final MainCoreEmployeeController employeeController;

  /// Department lookups are injected; no service locator.
  final MainCoreDepartmentCubit departmentCubit;

  EmployeeServicesCubit({
    required this.departmentCubit,
    required this.employeeController,
    FirebaseFirestore? firestore,
  })  : firestore = firestore ?? FirebaseFirestore.instance,
        super(const EmployeeServicesLoading());

  String _extractValue(dynamic value) {
    if (value == null) return '';
    if (value is List) {
      if (value.isEmpty) return '';
      return value[0]?.toString() ?? '';
    }
    return value.toString();
  }

  /// Fetches every request-service doc under the tenant root once, filters
  /// to the ones assigned to [currentProviderEmail], and enriches/backfills
  /// each before emitting the cached list.
  Future<void> loadAndCacheServices(String currentProviderEmail) async {
    emit(const EmployeeServicesLoading());

    final currentEmail = currentProviderEmail.trim().toLowerCase();
    if (currentEmail.isEmpty) {
      emit(const EmployeeServicesLoaded([]));
      return;
    }

    final companyId = ApiConstants.baseUri.split("/").last;
    if (companyId.isEmpty) {
      emit(const EmployeeServicesLoaded([]));
      return;
    }

    try {
      final allDocsSnapshot = await firestore
          .collection(FirebaseCollections.demo)
          .doc(companyId)
          .collection('Modules')
          .doc('services')
          .collection(FirebaseCollections.requestServices)
          .get();

      if (allDocsSnapshot.docs.isEmpty) {
        emit(const EmployeeServicesLoaded([]));
        return;
      }

      final assignedServices = <ServicesHistoryModel>[];

      for (final doc in allDocsSnapshot.docs) {
        final data = doc.data();
        try {
          dynamic assignedRaw = data['assignedProviderEmail'] ??
              data['Assigned_Provider_Email'] ??
              data['AssignedProviderEmail'];

          String assignedEmail = '';
          if (assignedRaw is List && assignedRaw.isNotEmpty) {
            assignedEmail =
                assignedRaw.first?.toString().trim().toLowerCase() ?? '';
          } else if (assignedRaw is String) {
            assignedEmail = assignedRaw.trim().toLowerCase();
          }

          if (assignedEmail.isEmpty || assignedEmail != currentEmail) continue;

          final requesterEmail = _extractValue(data['Email_Requester'])
                  .isNotEmpty
              ? _extractValue(data['Email_Requester'])
              : _extractValue(data['emailRequester']).isNotEmpty
                  ? _extractValue(data['emailRequester'])
                  : _extractValue(data['email_requester']);

          if (requesterEmail.isNotEmpty) {
            final employee =
                employeeController.getLocaleEmployee(requesterEmail);
            if (employee != null) {
              final nameEn =
                  "${employee.firstName ?? ''} ${employee.lastName ?? ''}".trim();
              final nameAr =
                  "${employee.firstNameInArabic ?? ''} ${employee.lastNameInArabic ?? ''}"
                      .trim();
              data['First_Name_Requester'] = nameEn.split(' ').first;
              data['Last_Name_Requester'] = nameEn.split(' ').skip(1).join(' ');
              data['First_Name_Requester_Arabic'] = nameAr.split(' ').first;
              data['Last_Name_Requester_Arabic'] =
                  nameAr.split(' ').skip(1).join(' ');
              data['Job_Title_Requester'] = employee.title ?? '';
              data['Job_Title_Requester_Arabic'] = employee.titleInArabic ?? '';
              data['Department_Requester'] = employee.departmentId ?? '';
            }
          }

          final bool missingName = (data['Service_Name_English'] == null ||
                  data['Service_Name_English'].toString().isEmpty) &&
              (data['Service_Name_Arabic'] == null ||
                  data['Service_Name_Arabic'].toString().isEmpty);

          if (missingName) {
            final parentServiceId = _extractValue(data['Parent_Service_Id']);
            if (parentServiceId.isNotEmpty && requesterEmail.isNotEmpty) {
              final details =
                  await CreateServicesHelper.getServiceDetailsFromCreateServices(
        departments: departmentCubit,
                parentServiceId: parentServiceId,
                emailRequester: requesterEmail,
              );
              data['Service_Name_English'] = details['serviceNameEnglish'] ?? '-';
              data['Service_Name_Arabic'] = details['serviceNameArabic'] ?? '-';
              data['Service_Description_English'] =
                  details['serviceDescriptionEnglish'] ?? '-';
              data['Service_Description_Arabic'] =
                  details['serviceDescriptionArabic'] ?? '-';
              data['Duration_Of_Services'] = details['duration'] ?? '-';
              data['Selected_Duration_Unit'] = details['unit'] ?? '-';
            } else {
              continue;
            }
          }

          if ((data['Service_Name_English'] == null ||
                  data['Service_Name_English'].toString().isEmpty) &&
              (data['Service_Name_Arabic'] == null ||
                  data['Service_Name_Arabic'].toString().isEmpty)) {
            continue;
          }

          assignedServices.add(ServicesHistoryModel.fromJson(data, doc.id));
        } catch (_) {
          // Skip malformed docs; one bad doc shouldn't fail the whole list.
        }
      }

      emit(EmployeeServicesLoaded(assignedServices));
    } catch (e) {
      emit(EmployeeServicesError('Error loading services: $e'));
    }
  }
}
