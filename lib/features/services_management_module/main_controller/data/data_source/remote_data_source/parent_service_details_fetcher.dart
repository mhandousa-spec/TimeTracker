// ******************* FILE INFO *******************
// File Name: parent_service_details_fetcher
// Description: Data-layer helper that fetches a parent CreateServices document
//              and extracts its service name/description/duration fields. Ported
//              out of the presentation CreateServicesHelper so the repository no
//              longer imports presentation (R01) and stays smaller (R02).
// Module: services_management_module / data / helper
// *************************************************

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';

class ParentServiceDetailsFetcher {
  final FirebaseFirestore firestore;

  ParentServiceDetailsFetcher(this.firestore);

  static String _extractFromArray(dynamic value) {
    if (value == null) return '';
    if (value is List) {
      if (value.isEmpty) return '';
      final extracted = value[0];
      return extracted?.toString() ?? '';
    }
    return value.toString();
  }

  static String _companyId() {
    final baseUri = ApiConstants.baseUri;
    if (baseUri.isEmpty) return '';
    if (baseUri.startsWith('Demo/')) return baseUri.substring(5);
    return baseUri;
  }

  /// Returns serviceNameEnglish/Arabic, serviceDescriptionEnglish/Arabic,
  /// duration and unit for the given parent service. Empty strings on miss.
  Future<Map<String, String>> fetch({
    required String parentServiceId,
    required String emailRequester,
  }) async {
    final result = <String, String>{
      'serviceNameEnglish': '',
      'serviceNameArabic': '',
      'serviceDescriptionEnglish': '',
      'serviceDescriptionArabic': '',
      'duration': '',
      'unit': '',
    };

    if (parentServiceId.isEmpty) return result;

    final companyId = _companyId();
    if (companyId.isEmpty) return result;

    final docPath = '/Demo/$companyId/Modules/services/CreateServices/$parentServiceId';

    DocumentSnapshot? docSnapshot;
    try {
      docSnapshot = await firestore.doc(docPath).get();
      if (!docSnapshot.exists) {
        final querySnapshot = await firestore
            .collection('/Demo/$companyId/Modules/services/CreateServices')
            .where('Email_Requester', arrayContains: emailRequester)
            .limit(1)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          docSnapshot = querySnapshot.docs.first;
        } else {
          return result;
        }
      }
    } catch (e) {
      return result;
    }

    if (!docSnapshot.exists) return result;

    final data = docSnapshot.data() as Map<String, dynamic>?;
    if (data == null) return result;

    result['serviceNameEnglish'] = data.containsKey('Service_Name_English')
        ? _extractFromArray(data['Service_Name_English'])
        : data.containsKey('serviceNameEnglish')
            ? _extractFromArray(data['serviceNameEnglish'])
            : '';
    result['serviceNameArabic'] = data.containsKey('Service_Name_Arabic')
        ? _extractFromArray(data['Service_Name_Arabic'])
        : data.containsKey('serviceNameArabic')
            ? _extractFromArray(data['serviceNameArabic'])
            : '';
    result['serviceDescriptionEnglish'] = data.containsKey('Service_Description_English')
        ? _extractFromArray(data['Service_Description_English'])
        : data.containsKey('serviceDescriptionEnglish')
            ? _extractFromArray(data['serviceDescriptionEnglish'])
            : '';
    result['serviceDescriptionArabic'] = data.containsKey('Service_Description_Arabic')
        ? _extractFromArray(data['Service_Description_Arabic'])
        : data.containsKey('serviceDescriptionArabic')
            ? _extractFromArray(data['serviceDescriptionArabic'])
            : '';
    result['duration'] = data.containsKey('Duration_Of_Services')
        ? _extractFromArray(data['Duration_Of_Services'])
        : data.containsKey('durationOfServices')
            ? _extractFromArray(data['durationOfServices'])
            : '';
    result['unit'] = data.containsKey('Selected_Duration_Unit')
        ? _extractFromArray(data['Selected_Duration_Unit'])
        : data.containsKey('selectedDurationUnit')
            ? _extractFromArray(data['selectedDurationUnit'])
            : '';

    return result;
  }
}
