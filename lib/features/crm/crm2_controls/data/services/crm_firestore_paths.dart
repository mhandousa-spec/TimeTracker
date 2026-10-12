// ****************** FILE INFO ******************
// File Name: crm_firestore_paths.dart
// Purpose: Centralized Firestore and storage paths for CRM data
// Author: Mohand Adel
// Created At: 04/08/2026

import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';

abstract class CrmFirestorePaths {
  static const String crmRoot = 'Modules/crm';
  static const String controlsDocument = 'controls';
  static const String clientsDocument = 'clients';
  static const String _controlsRoot =
      '$crmRoot/${CrmFirestoreCollections.CONTROLS_COLLECTION}/'
      '$controlsDocument';
  static const String _clientsRoot =
      '$crmRoot/${CrmFirestoreCollections.CLIENTS_COLLECTION}/'
      '$clientsDocument';

  static String get clientTypes => getBaseUrl(
        '$_controlsRoot/${CrmFirestoreCollections.CLIENT_TYPES_COLLECTION}',
      );
  static String get relationshipCategories => getBaseUrl(
        '$_controlsRoot/'
        '${CrmFirestoreCollections.RELATIONSHIP_CATEGORIES_COLLECTION}',
      );
  static String get terms => getBaseUrl(
        '$_controlsRoot/${CrmFirestoreCollections.TERMS_COLLECTION}',
      );
  static String get activityCategories => getBaseUrl(
        '$_controlsRoot/'
        '${CrmFirestoreCollections.ACTIVITY_CATEGORIES_COLLECTION}',
      );
  static String get activityTags => getBaseUrl(
        '$_controlsRoot/'
        '${CrmFirestoreCollections.ACTIVITY_TAGS_COLLECTION}',
      );
  static String get dealCategories => getBaseUrl(
        '$_controlsRoot/'
        '${CrmFirestoreCollections.DEAL_CATEGORIES_COLLECTION}',
      );
  static String get dealStages => getBaseUrl(
        '$_controlsRoot/'
        '${CrmFirestoreCollections.DEAL_STAGES_COLLECTION}',
      );
  static String get productCategories => getBaseUrl(
        '$_controlsRoot/'
        '${CrmFirestoreCollections.PRODUCT_CATEGORIES_COLLECTION}',
      );
  static String get products => getBaseUrl(
        '$_controlsRoot/'
        '${CrmFirestoreCollections.PRODUCTS_COLLECTION}',
      );
  static String get serviceCategories => getBaseUrl(
        '$_controlsRoot/'
        '${CrmFirestoreCollections.SERVICE_CATEGORIES_COLLECTION}',
      );
  static String get services => getBaseUrl(
        '$_controlsRoot/'
        '${CrmFirestoreCollections.SERVICES_COLLECTION}',
      );
  static String get discounts => getBaseUrl(
        '$_controlsRoot/'
        '${CrmFirestoreCollections.DISCOUNTS_COLLECTION}',
      );
  static String get mergeLevels => getBaseUrl(
        '$_controlsRoot/'
        '${CrmFirestoreCollections.MERGE_LEVELS_COLLECTION}',
      );
  static String get mergeSettings => getBaseUrl(
        '$_controlsRoot/'
        '${CrmFirestoreCollections.MERGE_SETTINGS_COLLECTION}',
      );
  static String get fieldTypes => getBaseUrl(
        '$_controlsRoot/${CrmFirestoreCollections.FIELD_TYPES_COLLECTION}',
      );
  static String get templates => getBaseUrl(
        '$_controlsRoot/${CrmFirestoreCollections.TEMPLATES_COLLECTION}',
      );
  static String get templateSections => getBaseUrl(
        '$_controlsRoot/${CrmFirestoreCollections.TEMPLATE_SECTIONS_COLLECTION}',
      );
  static String get templateFields => getBaseUrl(
        '$_controlsRoot/${CrmFirestoreCollections.TEMPLATE_FIELDS_COLLECTION}',
      );
  static String get templateLayouts => getBaseUrl(
        '$_controlsRoot/${CrmFirestoreCollections.TEMPLATE_LAYOUTS_COLLECTION}',
      );
  static String get templateHistory => getBaseUrl(
        '$_controlsRoot/${CrmFirestoreCollections.TEMPLATE_HISTORY_COLLECTION}',
      );
  static String get savedSections => getBaseUrl(
        '$_controlsRoot/${CrmFirestoreCollections.SAVED_SECTIONS_COLLECTION}',
      );
  static String get savedSectionFields => getBaseUrl(
        '$_controlsRoot/${CrmFirestoreCollections.SAVED_SECTION_FIELDS_COLLECTION}',
      );
  static String get clientRecords => getBaseUrl(
        '$_clientsRoot/${CrmFirestoreCollections.RECORDS_COLLECTION}',
      );
  static String get mergeHistory => getBaseUrl(
        '$_clientsRoot/${CrmFirestoreCollections.MERGE_HISTORY_COLLECTION}',
      );

  static String clientDocuments(String recordId) =>
      '$clientRecords/$recordId/${CrmFirestoreCollections.DOCUMENTS_COLLECTION}';

  static String clientTypeIconStoragePath(String typeId) {
    return '$_controlsRoot/'
        '${CrmFirestoreCollections.CLIENT_TYPES_COLLECTION}/$typeId';
  }

  static String clientRecordFileStoragePath(String recordId) {
    return '$_clientsRoot/'
        '${CrmFirestoreCollections.RECORDS_COLLECTION}/$recordId';
  }

  static String clientDocumentFileStoragePath(
      String recordId, String fileName) {
    return '$_clientsRoot/'
        '${CrmFirestoreCollections.RECORDS_COLLECTION}/$recordId/documents/$fileName';
  }
}
