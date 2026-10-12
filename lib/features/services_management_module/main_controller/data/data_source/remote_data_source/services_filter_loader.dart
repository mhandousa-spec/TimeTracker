// ******************* FILE INFO *******************
// File Name: services_filter_loader
// Description: Builds the filtered request list + per-employee/aggregate stats
//              for a parent service. Extracted from ServicesManagerCubit.
// Module: services_management_module / data / helper
// *************************************************

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/model_employee.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/s5_service_details/presentation/ui/widgets/calc_state_method.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/controller/create_services_helper.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Loads request documents for a parent service, enriches them with creator
/// details from CreateServices, computes status counts and per-employee stats.
class ServicesFilterLoader {
  ServicesFilterLoader({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<Map<String, dynamic>> loadFilteredItems({
    required String? parentServiceId,
    required BuildContext context,
    required ServicesHistoryModel parentService,
  }) async {
    final firestore = _firestore;
    final String? parentId = parentServiceId?.trim();

    final emptyResult = {
      'filteredItems': <Map<String, dynamic>>[],
      'allEmployees': <EmployeeEntityModell>[],
      'displayedStats': <Map<String, dynamic>>[],
      'localStats': {
        'done': 0,
        'approved': 0,
        'inprogress': 0,
        'pending': 0,
        'rejected': 0,
        'cancel': 0,
        'branchsla': 0,
      },
    };

    if (parentId == null || parentId.isEmpty) {
      return emptyResult;
    }

    try {
      final String requestServicesPath = getBaseUrl(FirestoreCollections.requestServicesRoot);

      // Path may be any odd-segment length
      // (e.g. Demo/{id}/Modules/services/RequestServices).
      // Firestore.collection() accepts a full slash-delimited path directly.
      final CollectionReference<Map<String, dynamic>> requestsCollection =
          firestore.collection(requestServicesPath);

      final requestsSnapshot = await requestsCollection.get();

      List<QueryDocumentSnapshot> matchingDocs = [];

      for (final doc in requestsSnapshot.docs) {
        final data = doc.data();
        String docParentId = '';

        if (data['Parent_Service_Id'] is List) {
          final parentIdList = data['Parent_Service_Id'] as List;
          if (parentIdList.isNotEmpty) {
            docParentId = parentIdList.last.toString().trim();
          }
        } else if (data['Parent_Service_Id'] is String) {
          docParentId = data['Parent_Service_Id'].toString().trim();
        }

        if (docParentId == parentId) {
          matchingDocs.add(doc);
        }
      }

      if (matchingDocs.isEmpty) {
        return emptyResult;
      }

      final List<Map<String, dynamic>> results = [];
      final isArabic = Localizations.localeOf(context).languageCode == 'ar';

      int doneCount = 0;
      int approvedCount = 0;
      int inProgressCount = 0;
      int pendingCount = 0;
      int rejectedCount = 0;
      int cancelCount = 0;
      int branchSlaCount = 0;

      for (int i = 0; i < matchingDocs.length; i++) {
        final doc = matchingDocs[i];
        final data = doc.data() as Map<String, dynamic>;
        final docId = doc.id;

        ServicesHistoryModel? model;
        try {
          model = ServicesHistoryModel.fromJson(data, docId);
        } catch (e) {
          continue;
        }

        // ✅ FETCH MISSING DATA FROM CreateServices
        Map<String, String> serviceDetails = {};

        // Extract email from model
        String emailRequester = model.currentEmailRequester;

        // If email is empty, try to extract from data
        if (emailRequester.isEmpty && data.containsKey('Email_Requester')) {
          final rawEmail = data['Email_Requester'];
          if (rawEmail is List && rawEmail.isNotEmpty) {
            emailRequester = rawEmail.last.toString();
          } else if (rawEmail is String) {
            emailRequester = rawEmail;
          }
        }

        if (emailRequester.isNotEmpty && parentId.isNotEmpty) {
          try {
            // ✅ CRITICAL: Fetch service and requester data from CreateServices
            serviceDetails = await CreateServicesHelper.getServiceDetailsFromCreateServices(
        departments: context.read<MainCoreDepartmentCubit>(),
              parentServiceId: parentId,
              emailRequester: emailRequester,
            );

            // ✅ UPDATE the model with fetched data
            model = model.copyWith(
              serviceNameEnglish: serviceDetails['serviceNameEnglish']!.isNotEmpty
                  ? serviceDetails['serviceNameEnglish']
                  : null,
              serviceNameArabic: serviceDetails['serviceNameArabic']!.isNotEmpty
                  ? serviceDetails['serviceNameArabic']
                  : null,
              firstNameRequester: serviceDetails['requesterName']!.split(' ').first,
              lastNameRequester: serviceDetails['requesterName']!.split(' ').length > 1
                  ? serviceDetails['requesterName']!.split(' ').sublist(1).join(' ')
                  : '',
              firstNameRequesterArabic: serviceDetails['requesterNameArabic']!.split(' ').first,
              lastNameRequesterArabic: serviceDetails['requesterNameArabic']!.split(' ').length > 1
                  ? serviceDetails['requesterNameArabic']!.split(' ').sublist(1).join(' ')
                  : '',
              jobTitleRequester: serviceDetails['jobTitle'],
              jobTitleRequesterArabic: serviceDetails['jobTitleArabic'],
              // ✅ FIX: display backfill, not an edit — must not append "now" to
              // the timestamps history. See ServicesHistoryModel.copyWith.
              bumpTimestamp: false,
            );

          } catch (e) {
            // Continue with empty data if fetch fails
          }
        }

        final requestor = isArabic
            ? '${model!.currentFirstNameRequesterArabic} ${model.currentLastNameRequesterArabic}'.trim()
            : '${model!.currentFirstNameRequester} ${model.currentLastNameRequester}'.trim();

        final jobTitle = isArabic
            ? model.currentJobTitleRequesterArabic
            : model.currentJobTitleRequester;

        String calculatedStatus = 'pending';

        if (data.containsKey('state')) {
          final rawState = data['state'];
          if (rawState is List && rawState.isNotEmpty) {
            calculatedStatus = rawState.last.toString().toLowerCase().trim();
          } else if (rawState is String && rawState.isNotEmpty) {
            calculatedStatus = rawState.toLowerCase().trim();
          }
        }

        if ((calculatedStatus.isEmpty || calculatedStatus == 'pending') &&
            model.currentState.isNotEmpty) {
          calculatedStatus = model.currentState.toLowerCase().trim();
        }

        switch (calculatedStatus) {
          case 'done':
            doneCount++;
            break;
          case 'approved':
            approvedCount++;
            break;
          case 'inprogress':
          case 'in progress':
            inProgressCount++;
            break;
          case 'pending':
            pendingCount++;
            break;
          case 'rejected':
            rejectedCount++;
            break;
          case 'cancel':
          case 'cancelled':
          case 'canceled':
            cancelCount++;
            break;
          case 'branchsla':
          case 'breached sla':
            branchSlaCount++;
            break;
          default:
            pendingCount++;
        }

        String assignedEmail = '';
        if (data.containsKey('Assigned_Provider_Email')) {
          final rawEmail = data['Assigned_Provider_Email'];

          if (rawEmail is List && rawEmail.isNotEmpty) {
            assignedEmail = rawEmail.last.toString().trim().toLowerCase();
          } else if (rawEmail is String && rawEmail.isNotEmpty) {
            assignedEmail = rawEmail.trim().toLowerCase();
          }
        }

        if (assignedEmail.isEmpty) {
          assignedEmail = model.currentAssignedProviderEmail.trim().toLowerCase();
        }

        String providerName = 'N/A';

        if (assignedEmail.isNotEmpty) {
          List<EmployeeEntityModell> availableProviders = [];
          availableProviders.addAll(parentService.currentProviderServices);

          if (data.containsKey('Provider_Services')) {
            try {
              final rawProviders = data['Provider_Services'];
              String providersJson = '';

              if (rawProviders is List && rawProviders.isNotEmpty) {
                providersJson = rawProviders.last.toString();
              } else if (rawProviders is String) {
                providersJson = rawProviders;
              }

              if (providersJson.isNotEmpty) {
                final providersList = jsonDecode(providersJson) as List;
                for (var providerData in providersList) {
                  try {
                    final provider = EmployeeEntityModell(
                      id: providerData['id']?.toString() ?? '',
                      email: providerData['email']?.toString() ?? '',
                      firstName: providerData['firstName']?.toString() ?? '',
                      lastName: providerData['lastName']?.toString() ?? '',
                      firstNameInArabic: providerData['firstNameInArabic']?.toString() ?? '',
                      lastNameInArabic: providerData['lastNameInArabic']?.toString() ?? '',
                      middleName: providerData['middleName']?.toString() ?? '',
                      middleNameInArabic: providerData['middleNameInArabic']?.toString() ?? '',
                      title: providerData['title']?.toString() ?? '',
                      titleInArabic: providerData['titleInArabic']?.toString() ?? '',
                      departmentId: providerData['departmentId']?.toString() ?? '',
                      role: providerData['role']?.toString() ?? '',
                      gender: providerData['gender']?.toString() ?? '',
                      status: providerData['status']?.toString() ?? 'active',
                    );
                    availableProviders.add(provider);
                  } catch (e) {
                  }
                }
              }
            } catch (e) {
            }
          }

          EmployeeEntityModell? foundProvider;

          try {
            foundProvider = availableProviders.firstWhere(
                  (p) => (p.email ?? '').toLowerCase() == assignedEmail,
            );
          } catch (e) {
            try {
              foundProvider = parentService.currentApprovalCycle.firstWhere(
                    (p) => (p.email ?? '').toLowerCase() == assignedEmail,
              );
            } catch (e2) {
            }
          }

          if (foundProvider != null) {
            providerName = isArabic
                ? '${foundProvider.firstNameInArabic ?? ''} ${foundProvider.lastNameInArabic ?? ''}'.trim()
                : '${foundProvider.firstName ?? ''} ${foundProvider.lastName ?? ''}'.trim();

            if (providerName.isEmpty) {
              providerName = assignedEmail;
            }

          } else {
            providerName = assignedEmail;
          }
        }

        final timestamp = model.currentDurationOfServicesTimestamp;
        final requestDate = DateFormat.yMMMMd(Localizations.localeOf(context).languageCode)
            .format(timestamp.toDate());

        // ✅ Use department from fetched data if available
        String departmentId = model.currentDepartmentRequester;
        if (departmentId.isEmpty && serviceDetails.containsKey('department')) {
          // If we have department name from helper, we need to convert it back to ID
          // For now, just use what we have
          departmentId = serviceDetails['department'] ?? '';
        }

        results.add({
          "no": i + 1,
          "department": departmentId,
          "serviceName": model.currentServiceNameEnglish.isNotEmpty
              ? model.currentServiceNameEnglish
              : model.currentServiceNameArabic,
          "gender": model.currentGenderRequester,
          "requestor": requestor.isNotEmpty ? requestor : "-",
          "jobtitle": jobTitle.isEmpty ? "-" : jobTitle,
          "requestDate": requestDate,
          "status": calculatedStatus,
          "provider": providerName,
          "docId": docId,
          "model": model,  // ✅ Updated model with fetched data
          "raw": data,
        });
      }

      final providerList = parentService.currentProviderServices;
      final approvalList = parentService.currentApprovalCycle;

      final Set<String> usedEmails = {};
      final List<EmployeeEntityModell> combined = [];

      for (final provider in providerList) {
        final email = (provider.email ?? '').toLowerCase();
        if (email.isNotEmpty && !usedEmails.contains(email)) {
          combined.add(provider);
          usedEmails.add(email);
        }
      }

      for (final approver in approvalList) {
        final email = (approver.email ?? '').toLowerCase();
        if (email.isNotEmpty && !usedEmails.contains(email)) {
          combined.add(approver);
          usedEmails.add(email);
        }
      }
      final displayedStats = combined
          .map((e) => calculateStatsForEmployee(
        e,
        context,
        results,
        parentDuration: parentService.currentDurationOfServices,
        parentDurationUnit: parentService.currentSelectedDurationUnit,
      ))
          .toList();

      final localStats = {
        'done': doneCount,
        'approved': approvedCount,
        'inprogress': inProgressCount,
        'pending': pendingCount,
        'rejected': rejectedCount,
        'cancel': cancelCount,
        'branchsla': branchSlaCount,
      };

      return {
        'filteredItems': results,
        'allEmployees': combined,
        'displayedStats': displayedStats,
        'localStats': localStats,
      };
    } catch (e, stackTrace) {
      return emptyResult;
    }
  }
}
