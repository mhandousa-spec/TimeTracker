// ****************** FILE INFO ******************
// File Name: crm_template_default_sync_helper.dart
// Purpose: Helpers for syncing default CRM template fields into existing templates
// Author: Mohand Adel
// Created At: 08/08/2026

import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_field_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';

abstract class CrmTemplateDefaultSyncHelper {
  static const Set<String> _standardizedOptionKeys = <String>{
    'decision_role',
    'phone_type',
  };

  static CrmTemplateFieldModel mergeFieldWithDefault({
    required CrmTemplateFieldModel existing,
    required CrmTemplateFieldModel defaultField,
  }) {
    final bool forceStandardOptions =
        _standardizedOptionKeys.contains(defaultField.systemKey);
    final Map<String, dynamic> mergedConfiguration =
        _mergeConfiguration(existing, defaultField, forceStandardOptions);
    final List<String> mergedOptions = _mergeOptions(
      existing: existing,
      defaultField: defaultField,
      forceStandardOptions: forceStandardOptions,
    );

    return existing.copyWith(
      templateId: defaultField.templateId,
      clientTypeId: defaultField.clientTypeId,
      sectionId: defaultField.sectionId,
      fieldTypeId: defaultField.fieldTypeId,
      nameEn: existing.nameEn.trim().isEmpty
          ? defaultField.nameEn
          : existing.nameEn,
      nameAr: existing.nameAr.trim().isEmpty
          ? defaultField.nameAr
          : existing.nameAr,
      isRequired: existing.isRequired || defaultField.isRequired,
      showBothLanguages: defaultField.showBothLanguages,
      options: mergedOptions,
      systemKey: defaultField.systemKey,
      isDefault: true,
      configuration: mergedConfiguration,
      order: defaultField.order,
    );
  }

  static bool needsSync({
    required CrmTemplateFieldModel existing,
    required CrmTemplateFieldModel merged,
  }) {
    return existing.fieldTypeId != merged.fieldTypeId ||
        existing.nameEn != merged.nameEn ||
        existing.nameAr != merged.nameAr ||
        existing.isRequired != merged.isRequired ||
        existing.showBothLanguages != merged.showBothLanguages ||
        existing.systemKey != merged.systemKey ||
        existing.isDefault != merged.isDefault ||
        existing.order != merged.order ||
        !_listEquals(existing.options, merged.options) ||
        !_mapEquals(existing.configuration, merged.configuration);
  }

  static Map<String, dynamic> _mergeConfiguration(
    CrmTemplateFieldModel existing,
    CrmTemplateFieldModel defaultField,
    bool forceStandardOptions,
  ) {
    final Map<String, dynamic> merged =
        Map<String, dynamic>.from(existing.configuration);
    final Map<String, dynamic> defaults =
        Map<String, dynamic>.from(defaultField.configuration);

    defaults.forEach((String key, dynamic value) {
      final bool shouldOverwrite =
          forceStandardOptions && (key == CrmFirestoreKeys.DEFAULT_OPTIONS_KEY);
      if (shouldOverwrite || !_hasMeaningfulValue(merged[key])) {
        merged[key] = value;
      }
    });

    if (defaultField.fieldTypeId.toLowerCase() == 'address') {
      for (final String key in <String>[
        CrmFirestoreKeys.FIELD_KIND_KEY,
        CrmFirestoreKeys.ADDRESS_COMPONENT_KEY,
        CrmFirestoreKeys.ADDRESS_COMPONENTS_KEY,
        CrmFirestoreKeys.SUPPORTED_DATA_SCOPE_KEY,
      ]) {
        if (_hasMeaningfulValue(defaults[key])) {
          merged[key] = defaults[key];
        }
      }
    }

    return merged;
  }

  static List<String> _mergeOptions({
    required CrmTemplateFieldModel existing,
    required CrmTemplateFieldModel defaultField,
    required bool forceStandardOptions,
  }) {
    if (forceStandardOptions) return defaultField.options;
    if (existing.options.isNotEmpty) return existing.options;
    return defaultField.options;
  }

  static bool _hasMeaningfulValue(dynamic value) {
    if (value == null) return false;
    if (value is String) return value.trim().isNotEmpty;
    if (value is List || value is Map) return (value as dynamic).isNotEmpty;
    return true;
  }

  static bool _listEquals(List<dynamic> a, List<dynamic> b) {
    if (a.length != b.length) return false;
    for (int index = 0; index < a.length; index++) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }

  static bool _mapEquals(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (final String key in a.keys) {
      if (!b.containsKey(key)) return false;
      final dynamic left = a[key];
      final dynamic right = b[key];
      if (left is List && right is List) {
        if (!_listEquals(left, right)) return false;
        continue;
      }
      if (left is Map && right is Map) {
        if (!_mapEquals(
          Map<String, dynamic>.from(left),
          Map<String, dynamic>.from(right),
        )) {
          return false;
        }
        continue;
      }
      if (left != right) return false;
    }
    return true;
  }
}
