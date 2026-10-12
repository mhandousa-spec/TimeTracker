// ******************* FILE INFO *******************
// File Name: request_provider_resolver
// Description: Resolves / fairly assigns the service provider for a single
//              request document, and converts between EmployeeEntityModell and
//              Firestore maps. Extracted from MyRequestDetails (page logic).
// Module: services_management_module / presentation/s6_services_requests/controller
// *************************************************

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/model_employee.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';

/// Holds no widget state — operates on the given [model] and [requesterEmail].
class RequestProviderResolver {
  RequestProviderResolver({
    required this.model,
    required this.requesterEmail,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final ServicesHistoryModel model;
  final String requesterEmail;
  final FirebaseFirestore _firestore;

  Future<Map<String, dynamic>?> getRequestSpecificProvider() async {
    try {
      final docId = model.currentId;

      final providerServices = model.currentProviderServices;
      for (int i = 0; i < providerServices.length; i++) {
        final provider = providerServices[i];
      }

      if (docId.isEmpty) {
        return null;
      }

      final querySnapshot = await _firestore
          .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
          .where("Email_Requester", arrayContains: requesterEmail)
          .get();

      final requestDoc = querySnapshot.docs.firstWhere(
            (doc) => doc.id == docId,
        orElse: () => throw Exception("Document not found"),
      );

      final data = requestDoc.data();

      final assignedEmail = model.currentAssignedProviderEmail;

      if (assignedEmail.isNotEmpty) {
        final providerServices = model.currentProviderServices;

        if (providerServices.isNotEmpty) {
          try {
            final assignedProvider = providerServices.firstWhere(
                  (p) =>
              (p.email ?? '').toLowerCase() == assignedEmail.toLowerCase(),
            );

            final providerMap = convertEmployeeToMap(assignedProvider);

            return providerMap;
          } catch (e) {
          }
        }
      }

      if (data.containsKey('Provider_Services') &&
          data['Provider_Services'] is Map) {
        final providerData = data['Provider_Services'] as Map<String, dynamic>;
        return providerData;
      }

      final providerServicesForSelection = model.currentProviderServices;

      if (providerServicesForSelection.isNotEmpty) {
        final selectedProvider = await _selectFairProviderFromModel(
          providers: providerServicesForSelection,
          requestDate: model.timestamps.isNotEmpty
              ? DateTime.fromMillisecondsSinceEpoch(model.timestamps.first)
              : DateTime.now(),
        );

        if (selectedProvider != null) {
          final assignedEmail =
          selectedProvider['email'].toString().toLowerCase();

          await requestDoc.reference.update({
            'Provider_Services': selectedProvider,
            'Assigned_Provider_Email': FieldValue.arrayUnion([assignedEmail]),
            'timestamps':
            FieldValue.arrayUnion([DateTime.now().millisecondsSinceEpoch]),
          });

          return selectedProvider;
        }
      }

      final providerServicesFromModel = model.currentProviderServices;

      if (providerServicesFromModel.isNotEmpty) {
        final firstProvider = providerServicesFromModel.first;

        final providerMap = convertEmployeeToMap(firstProvider);
        final assignedEmail = (firstProvider.email ?? '').toLowerCase();

        await requestDoc.reference.update({
          'Provider_Services': providerMap,
          'Assigned_Provider_Email': FieldValue.arrayUnion([assignedEmail]),
          'timestamps':
          FieldValue.arrayUnion([DateTime.now().millisecondsSinceEpoch]),
        });

        return providerMap;
      }

      return null;
    } catch (e, stackTrace) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _selectFairProviderFromModel({
    required List<EmployeeEntityModell> providers,
    required DateTime requestDate,
  }) async {
    try {
      if (providers.isEmpty) return null;

      final providersList =
      providers.map((p) => convertEmployeeToMap(p)).toList();

      return await _selectFairProviderFromMaps(
        providers: providersList,
        requestDate: requestDate,
      );
    } catch (e) {
      return providers.isNotEmpty
          ? convertEmployeeToMap(providers.first)
          : null;
    }
  }

  Map<String, dynamic> convertEmployeeToMap(EmployeeEntityModell employee) {
    if (employee.mobilePhone != null) {
      try {
        final jsonTest = employee.mobilePhone!.toJson();
      } catch (e) {
      }
    }

    final map = {
      'id': employee.id ?? '',
      'email': employee.email ?? '',
      'firstName': employee.firstName ?? '',
      'lastName': employee.lastName ?? '',
      'firstNameInArabic': employee.firstNameInArabic ?? '',
      'lastNameInArabic': employee.lastNameInArabic ?? '',
      'middleName': employee.middleName ?? '',
      'middleNameInArabic': employee.middleNameInArabic ?? '',
      'departmentId': employee.departmentId ?? '',
      'title': employee.title ?? '',
      'titleInArabic': employee.titleInArabic ?? '',
      'role': employee.role ?? '',
      'gender': employee.gender ?? '',
      'workLocation': employee.workLocation ?? '',
      'status': employee.status ?? 'active',
      'nationalId': employee.nationalId ?? '',
      'nationality': employee.nationality ?? '',
      'birthDay': employee.birthDay ?? '',
      'country': employee.country ?? '',
      'province': employee.province ?? '',
      'city': employee.city ?? '',
      'maritalStatus': employee.maritalStatus ?? '',
      'language': employee.language ?? '',
      'supervisor': employee.supervisor ?? '',
      'mobilePhone': employee.mobilePhone?.toJson(),
      'officePhone': employee.officePhone ?? '',
      'homePhone': employee.homePhone ?? '',
      'extension': employee.extension ?? '',
    };

    if (map['mobilePhone'] != null && map['mobilePhone'] is Map) {
      final phoneMap = map['mobilePhone'] as Map;
    }

    return map;
  }

  Future<Map<String, dynamic>?> _selectFairProviderFromMaps({
    required List<Map<String, dynamic>> providers,
    required DateTime requestDate,
  }) async {
    try {
      if (providers.isEmpty) return null;

      final sevenDaysAgo = requestDate.subtract(Duration(days: 7));

      final recentRequestsQuery = await _firestore
          .collectionGroup('user')
          .where('createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo))
          .where('createdAt',
          isLessThanOrEqualTo: Timestamp.fromDate(requestDate))
          .get();

      Map<String, int> providerWorkload = {};
      for (var provider in providers) {
        final email = provider['email']?.toString() ?? '';
        if (email.isNotEmpty) {
          providerWorkload[email] = 0;
        }
      }

      for (var doc in recentRequestsQuery.docs) {
        final data = doc.data();
        if (data['provider'] is Map) {
          final providerEmail = data['provider']['email']?.toString();
          if (providerEmail != null &&
              providerWorkload.containsKey(providerEmail)) {
            providerWorkload[providerEmail] =
                (providerWorkload[providerEmail] ?? 0) + 1;
          }
        }
      }

      String? selectedProviderEmail;
      int minWorkload = double.maxFinite.toInt();

      for (var entry in providerWorkload.entries) {
        if (entry.value < minWorkload) {
          minWorkload = entry.value;
          selectedProviderEmail = entry.key;
        }
      }

      if (selectedProviderEmail != null) {
        return providers.firstWhere(
              (p) => p['email'] == selectedProviderEmail,
          orElse: () => providers.first,
        );
      }

      return providers.first;
    } catch (e) {
      return providers.isNotEmpty ? providers.first : null;
    }
  }

  EmployeeEntityModell convertMapToEmployeeEntityModel(
      Map<String, dynamic> data) {
    List<String?>? _convertToStringList(dynamic value) {
      if (value == null) return null;
      if (value is List) {
        return value.map((e) => e?.toString()).toList();
      }
      if (value is String) {
        return value.isEmpty ? null : [value];
      }
      return null;
    }

    return EmployeeEntityModell(
      id: data['id']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      firstName: data['firstName']?.toString() ?? '',
      lastName: data['lastName']?.toString() ?? '',
      firstNameInArabic: data['firstNameInArabic']?.toString() ?? '',
      lastNameInArabic: data['lastNameInArabic']?.toString() ?? '',
      middleName: data['middleName']?.toString() ?? '',
      middleNameInArabic: data['middleNameInArabic']?.toString() ?? '',
      nationalId: data['nationalId']?.toString() ?? '',
      nationalIdExpirationDate:
      data['nationalIdExpirationDate']?.toString() ?? '',
      nationality: data['nationality']?.toString() ?? '',
      passport: data['passport']?.toString() ?? '',
      passportExpirationDate:
      data['passportExpirationDate']?.toString() ?? '',
      mobilePhone: data['mobilePhone'] != null && data['mobilePhone'] is Map
          ? ServicesMobilePhoneEntity.fromJson(data['mobilePhone'])
          : null,
      officePhone: data['officePhone']?.toString() ?? '',
      homePhone: data['homePhone']?.toString() ?? '',
      extension: data['extension']?.toString() ?? '',
      birthDay: data['birthDay']?.toString() ?? '',
      gender: data['gender']?.toString() ?? '',
      country: data['country']?.toString() ?? '',
      province: data['province']?.toString() ?? '',
      city: data['city']?.toString() ?? '',
      postalCode: data['postalCode']?.toString() ?? '',
      street: data['street']?.toString() ?? '',
      maritalStatus: data['maritalStatus']?.toString() ?? '',
      language: data['language']?.toString() ?? '',
      departmentId: data['departmentId']?.toString() ?? '',
      supervisor: data['supervisor']?.toString() ?? '',
      role: data['role']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      titleInArabic: data['titleInArabic']?.toString() ?? '',
      workLocation: data['workLocation']?.toString() ?? '',
      drivingLicenseId: data['drivingLicenseId']?.toString() ?? '',
      carPlates: _convertToStringList(data['carPlates']),
      academicHistory:
      data['academicHistory'] != null && data['academicHistory'] is Map
          ? AcademicHistoryEntity.fromJson(data['academicHistory'])
          : null,
      bio: data['bio']?.toString() ?? '',
      photo: data['photo']?.toString() ?? '',
      skills: _convertToStringList(data['skills']),
      hobbies: _convertToStringList(data['hobbies']),
      status: data['status']?.toString() ?? '',
      firstLogin: data['firstLogin'],
      lastLogin: data['lastLogin']?.toString() ?? '',
      deactivationDate: data['deactivationDate']?.toString() ?? '',
      activationDate: data['activationDate']?.toString() ?? '',
      state: data['state']?.toString() ?? '',
    );
  }
}
