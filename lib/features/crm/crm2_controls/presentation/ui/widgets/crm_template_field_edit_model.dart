// ****************** FILE INFO ******************
// File Name: crm_template_field_edit_model.dart
// Purpose: Editable state wrapper for CRM template field forms
// Author: Mohand Adel
// Created At: 05/08/2026

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_field_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';

class CrmTemplateOptionEditModel {
  final TextEditingController enController;
  final TextEditingController arController;

  CrmTemplateOptionEditModel({String en = '', String ar = ''})
      : enController = TextEditingController(text: en),
        arController = TextEditingController(text: ar);

  Map<String, dynamic> toMap(int index) {
    return {
      CrmFirestoreKeys.OPTION_ID_KEY: 'option_${index + 1}',
      CrmFirestoreKeys.OPTION_LABEL_EN_KEY: enController.text.trim(),
      CrmFirestoreKeys.OPTION_LABEL_AR_KEY: arController.text.trim(),
      CrmFirestoreKeys.OPTION_IS_DEFAULT_KEY: index == 0,
      CrmFirestoreKeys.OPTION_IS_DELETED_KEY: false,
      CrmFirestoreKeys.OPTION_ORDER_KEY: index + 1,
    };
  }

  void dispose() {
    enController.dispose();
    arController.dispose();
  }
}

class CrmTemplateFieldEditModel {
  static const List<String> defaultImageTypes = [
    'JPG',
    'PNG',
    'SVG',
    'Gif',
    'WebP',
    'BMP',
    'TIFF',
  ];
  static const List<String> defaultLinkTypes = ['LinkedIn'];
  static const List<String> linkTypes = [
    'LinkedIn',
    'Facebook',
    'X (Twitter)',
    'Instagram',
    'YouTube',
    'GitHub',
  ];
  static const List<String> defaultFileTypes = [
    'PDF',
    'DOC',
    'DOCX',
    'XLS',
    'XLSX',
    'PPT',
    'PPTX',
    'TXT',
    'ZIP',
  ];
  static const List<String> signatureSaveFormats = ['File', 'Image'];
  static const List<String> defaultSignatureFileTypes = [
    'PDF',
    'DOC',
    'DOCX',
    'TXT',
    'RTF',
  ];
  static const List<String> defaultPurchasingValidationTypes = ['Symbols'];
  static const List<String> purchasingValidationTypes = ['Numbers', 'Symbols'];

  CrmTemplateFieldModel field;
  bool isExpanded = true;
  final TextEditingController nameEnController;
  final TextEditingController nameArController;
  final TextEditingController maxController;
  final TextEditingController maximumNumberController;
  final TextEditingController imageSizeController;
  final TextEditingController fileSizeController;
  final TextEditingController dateFromController;
  final TextEditingController dateToController;
  final TextEditingController timeFromController;
  final TextEditingController timeToController;
  final TextEditingController formatController;
  final TextEditingController errorEnController;
  final TextEditingController errorArController;
  final List<CrmTemplateOptionEditModel> options;
  Map<String, dynamic> config;
  String? nameEnError;
  String? nameArError;
  String? errorEnError;
  String? errorArError;

  CrmTemplateFieldEditModel._({
    required this.field,
    required this.config,
    required this.nameEnController,
    required this.nameArController,
    required this.maxController,
    required this.maximumNumberController,
    required this.imageSizeController,
    required this.fileSizeController,
    required this.dateFromController,
    required this.dateToController,
    required this.timeFromController,
    required this.timeToController,
    required this.formatController,
    required this.errorEnController,
    required this.errorArController,
    required this.options,
  });

  factory CrmTemplateFieldEditModel.fromField(CrmTemplateFieldModel field) {
    final Map<String, dynamic> config = _normalizedConfigForField(field);
    final List storedOptions =
        config[CrmFirestoreKeys.DEFAULT_OPTIONS_KEY] as List? ?? const [];
    final List optionMaps = storedOptions.isEmpty && field.options.isNotEmpty
        ? field.options
        : storedOptions;
    final List<CrmTemplateOptionEditModel> optionModels = optionMaps
        .map(_optionFromFirestore)
        .whereType<CrmTemplateOptionEditModel>()
        .toList();
    return CrmTemplateFieldEditModel._(
      field: field,
      config: config,
      nameEnController: TextEditingController(text: field.nameEn),
      nameArController: TextEditingController(text: field.nameAr),
      maxController: TextEditingController(
        text: field.maxCharacters?.toString() ??
            (config[CrmFirestoreKeys.MAX_LENGTH_KEY]?.toString() ?? ''),
      ),
      maximumNumberController: TextEditingController(
        text: (config[CrmFirestoreKeys.MAXIMUM_NUMBER_KEY] ?? '').toString(),
      ),
      imageSizeController: TextEditingController(
        text: (config[CrmFirestoreKeys.IMAGE_SIZE_KEY] ?? '').toString(),
      ),
      fileSizeController: TextEditingController(
        text: (config[CrmFirestoreKeys.FILE_SIZE_KEY] ?? '').toString(),
      ),
      dateFromController: TextEditingController(
        text: (config[CrmFirestoreKeys.DATE_RANGE_FROM_KEY] ?? '').toString(),
      ),
      dateToController: TextEditingController(
        text: (config[CrmFirestoreKeys.DATE_RANGE_TO_KEY] ?? '').toString(),
      ),
      timeFromController: TextEditingController(
        text: (config[CrmFirestoreKeys.TIME_RANGE_FROM_KEY] ?? '').toString(),
      ),
      timeToController: TextEditingController(
        text: (config[CrmFirestoreKeys.TIME_RANGE_TO_KEY] ?? '').toString(),
      ),
      formatController: TextEditingController(
        text: (config[CrmFirestoreKeys.FORMAT_EXAMPLE_KEY] ?? '').toString(),
      ),
      errorEnController: TextEditingController(text: field.errorMessageEn),
      errorArController: TextEditingController(text: field.errorMessageAr),
      options: optionModels,
    );
  }

  static CrmTemplateOptionEditModel? _optionFromFirestore(dynamic option) {
    if (option is Map) {
      return CrmTemplateOptionEditModel(
        en: (option[CrmFirestoreKeys.OPTION_LABEL_EN_KEY] ?? '').toString(),
        ar: (option[CrmFirestoreKeys.OPTION_LABEL_AR_KEY] ?? '').toString(),
      );
    }
    if (option is String) {
      return CrmTemplateOptionEditModel(en: option);
    }
    return null;
  }

  static Map<String, dynamic> _normalizedConfigForField(
    CrmTemplateFieldModel field,
  ) {
    final Map<String, dynamic> config =
        Map<String, dynamic>.from(field.configuration);
    if (field.fieldTypeId.toLowerCase() != 'address') {
      return config;
    }

    final String normalizedComponent =
        _normalizedAddressComponent(field, config);
    if (normalizedComponent.isNotEmpty) {
      config[CrmFirestoreKeys.ADDRESS_COMPONENT_KEY] = normalizedComponent;
    }

    final dynamic existingEntryType = config[CrmFirestoreKeys.ENTRY_TYPE_KEY];
    if (existingEntryType == null ||
        existingEntryType.toString().trim().isEmpty) {
      config[CrmFirestoreKeys.ENTRY_TYPE_KEY] =
          normalizedComponent == 'Country' ? 'Dropdown' : 'Text Field';
    }

    // Migrate previously saved City fields: seed the allowed cities from the
    // stored options so the cities multi-select keeps the existing selection.
    if (normalizedComponent == 'City') {
      final dynamic existingCities = config[CrmFirestoreKeys.CITIES_KEY];
      final bool hasCities =
          (existingCities is List && existingCities.isNotEmpty) ||
              (existingCities is String && existingCities.trim().isNotEmpty);
      if (!hasCities) {
        final List<String> cityNames = _storedOptionLabels(field, config);
        if (cityNames.isNotEmpty) {
          config[CrmFirestoreKeys.CITIES_KEY] = cityNames;
        }
      }
    }

    return config;
  }

  /// Extracts the English option labels stored on the field (from
  /// `Default_Options` config or the legacy `options` list). Uses the same
  /// precedence as `fromField` (falls back to `field.options` when the stored
  /// list is empty).
  static List<String> _storedOptionLabels(
    CrmTemplateFieldModel field,
    Map<String, dynamic> config,
  ) {
    final List storedOptions =
        config[CrmFirestoreKeys.DEFAULT_OPTIONS_KEY] as List? ?? const [];
    final List rawOptions = storedOptions.isEmpty && field.options.isNotEmpty
        ? field.options
        : storedOptions;
    return rawOptions
        .map((dynamic option) {
          if (option is Map) {
            return (option[CrmFirestoreKeys.OPTION_LABEL_EN_KEY] ?? '')
                .toString();
          }
          return option.toString();
        })
        .map((String label) => label.trim())
        .where((String label) => label.isNotEmpty)
        .toSet()
        .toList();
  }

  static String _normalizedAddressComponent(
    CrmTemplateFieldModel field,
    Map<String, dynamic> config,
  ) {
    final String raw = (config[CrmFirestoreKeys.ADDRESS_COMPONENT_KEY] ?? '')
        .toString()
        .trim();
    final String normalizedRaw = _mapAddressComponentValue(raw);
    if (normalizedRaw.isNotEmpty) return normalizedRaw;

    final String fromSystemKey = _mapAddressComponentValue(field.systemKey);
    if (fromSystemKey.isNotEmpty) return fromSystemKey;

    return _mapAddressComponentValue(field.nameEn);
  }

  static String _mapAddressComponentValue(String raw) {
    final String value = raw.trim().toLowerCase();
    if (value.isEmpty) return '';
    if (value == 'country') return 'Country';
    if (value == 'city') return 'City';
    if (value == 'state / province' ||
        value == 'state/province' ||
        value == 'state_province' ||
        value == 'province' ||
        value == 'state') {
      return 'State / Province';
    }
    if (value == 'postal / zip code' ||
        value == 'postal/zip code' ||
        value == 'postal_zip_code' ||
        value == 'zip code' ||
        value == 'postal code' ||
        value == 'street') {
      return 'Postal / ZIP Code';
    }
    return '';
  }

  bool boolConfig(String key, {bool fallback = false}) {
    return config[key] == true
        ? true
        : config[key] == false
            ? false
            : fallback;
  }

  String stringConfig(String key, {String fallback = ''}) {
    return (config[key] ?? fallback).toString();
  }

  List<String> listConfig(String key) {
    final dynamic stored = config[key];
    if (stored is List) {
      return stored
          .map((dynamic value) => value.toString().trim())
          .where((String value) => value.isNotEmpty)
          .toList();
    }
    if (stored is String && stored.trim().isNotEmpty) {
      return stored
          .split(',')
          .map((String value) => value.trim())
          .where((String value) => value.isNotEmpty)
          .toList();
    }
    return const <String>[];
  }

  void setConfig(String key, dynamic value) {
    config = <String, dynamic>{...config, key: value};
  }

  void applyChoicePresetFrom(CrmTemplateFieldModel source) {
    final Map<String, dynamic> sourceConfig =
        Map<String, dynamic>.from(source.configuration);
    final List rawOptions =
        sourceConfig[CrmFirestoreKeys.DEFAULT_OPTIONS_KEY] as List? ??
            source.options;
    for (final CrmTemplateOptionEditModel option in options) {
      option.dispose();
    }
    options
      ..clear()
      ..addAll(
        rawOptions
            .map(_optionFromFirestore)
            .whereType<CrmTemplateOptionEditModel>(),
      );
    config = <String, dynamic>{
      ...config,
      CrmFirestoreKeys.DEFAULT_OPTIONS_KEY: rawOptions,
      if (sourceConfig.containsKey(CrmFirestoreKeys.ALLOW_SEARCH_KEY))
        CrmFirestoreKeys.ALLOW_SEARCH_KEY:
            sourceConfig[CrmFirestoreKeys.ALLOW_SEARCH_KEY],
      if (sourceConfig.containsKey(CrmFirestoreKeys.ENABLE_SEARCH_KEY))
        CrmFirestoreKeys.ENABLE_SEARCH_KEY:
            sourceConfig[CrmFirestoreKeys.ENABLE_SEARCH_KEY],
      if (sourceConfig.containsKey(CrmFirestoreKeys.ALLOW_MULTIPLE_KEY))
        CrmFirestoreKeys.ALLOW_MULTIPLE_KEY:
            sourceConfig[CrmFirestoreKeys.ALLOW_MULTIPLE_KEY],
      if (sourceConfig.containsKey(CrmFirestoreKeys.ALLOW_MULTIPLE_VALUES_KEY))
        CrmFirestoreKeys.ALLOW_MULTIPLE_VALUES_KEY:
            sourceConfig[CrmFirestoreKeys.ALLOW_MULTIPLE_VALUES_KEY],
    };
  }

  static const List<String> textValidationTypes = <String>[
    'String',
    'Numbers',
    'Symbols',
  ];

  List<String> selectedTextValidationTypes() {
    final dynamic stored = config[CrmFirestoreKeys.VALIDATION_TYPES_KEY];
    if (stored is List) {
      return stored
          .map((dynamic value) => value.toString().trim())
          .where((String value) => value.isNotEmpty)
          .toList();
    }
    final String val = field.validationType.trim();
    if (val.isNotEmpty && val.toLowerCase() != 'none') {
      return val
          .split(',')
          .map((String value) => value.trim())
          .where((String value) => value.isNotEmpty)
          .toList();
    }
    return const <String>[];
  }

  List<String> selectedImageTypes() {
    final dynamic stored = config[CrmFirestoreKeys.IMAGE_TYPES_KEY];
    if (stored is List) {
      return stored
          .map((dynamic value) => value.toString())
          .where((String value) => value.isNotEmpty)
          .toList();
    }
    return defaultImageTypes;
  }

  List<String> selectedLinkTypes() {
    final dynamic stored = config[CrmFirestoreKeys.LINK_TYPES_KEY];
    if (stored is List) {
      return stored
          .map((dynamic value) => value.toString())
          .where((String value) => value.isNotEmpty)
          .toList();
    }
    return defaultLinkTypes;
  }

  List<String> selectedFileTypes() {
    final dynamic stored = config[CrmFirestoreKeys.FILE_TYPES_KEY];
    if (stored is List) {
      return stored
          .map((dynamic value) => value.toString())
          .where((String value) => value.isNotEmpty)
          .toList();
    }
    return defaultFileTypes;
  }

  List<String> selectedSignatureTypes() {
    final dynamic stored = config[CrmFirestoreKeys.SIGNATURE_TYPES_KEY];
    if (stored is List) {
      return stored
          .map((dynamic value) => value.toString())
          .where((String value) => value.isNotEmpty)
          .toList();
    }
    return stringConfig(
              CrmFirestoreKeys.SAVE_FORMAT_KEY,
              fallback: 'File',
            ) ==
            'Image'
        ? defaultImageTypes
        : defaultSignatureFileTypes;
  }

  List<String> selectedPurchasingValidationTypes() {
    final dynamic stored = config[CrmFirestoreKeys.VALUE_VALIDATION_TYPES_KEY];
    if (stored is List) {
      return stored
          .map((dynamic value) => value.toString())
          .where((String value) => value.isNotEmpty)
          .toList();
    }
    return defaultPurchasingValidationTypes;
  }

  void addOption() {
    options.add(CrmTemplateOptionEditModel());
  }

  void removeOption(CrmTemplateOptionEditModel option) {
    options.remove(option);
    option.dispose();
  }

  CrmTemplateFieldModel toField() {
    final List<Map<String, dynamic>> optionMaps = List.generate(
      options.length,
      (int index) => options[index].toMap(index),
    );
    final int? max = int.tryParse(maxController.text.trim());
    final String fieldKind = stringConfig(
      CrmFirestoreKeys.FIELD_KIND_KEY,
      fallback: field.fieldTypeId,
    ).toLowerCase();
    final bool isImageField = fieldKind == 'image';
    final bool isPhoneField = fieldKind == 'phone';
    final bool isWebsiteField = field.fieldTypeId == 'website';
    final bool isLinkField = fieldKind == 'link' && !isWebsiteField;
    final bool isFileField = fieldKind == 'attachment' || fieldKind == 'file';
    final bool isDateField =
        fieldKind == 'date' || field.fieldTypeId == 'business_initiation_date';
    final bool isTimeField = fieldKind == 'time';
    final bool isSwitchField = fieldKind == 'switch';
    final bool isSignatureField = fieldKind == 'signature';
    final bool isPurchasingValueField = field.fieldTypeId == 'purchasing_value';
    final Map<String, dynamic> savedConfig = <String, dynamic>{
      ...config,
      CrmFirestoreKeys.MAX_LENGTH_KEY: max,
      CrmFirestoreKeys.FORMAT_EXAMPLE_KEY: formatController.text.trim(),
      CrmFirestoreKeys.DEFAULT_OPTIONS_KEY: optionMaps,
    };
    String validationType = field.validationType;
    if (isImageField) {
      savedConfig[CrmFirestoreKeys.MAXIMUM_NUMBER_KEY] =
          int.tryParse(maximumNumberController.text.trim());
      savedConfig[CrmFirestoreKeys.IMAGE_SIZE_KEY] =
          int.tryParse(imageSizeController.text.trim());
      savedConfig[CrmFirestoreKeys.IMAGE_SIZE_UNIT_KEY] = stringConfig(
        CrmFirestoreKeys.IMAGE_SIZE_UNIT_KEY,
        fallback: 'MB',
      );
      savedConfig[CrmFirestoreKeys.IMAGE_TYPES_KEY] = selectedImageTypes();
    } else {
      savedConfig.remove(CrmFirestoreKeys.MAXIMUM_NUMBER_KEY);
      savedConfig.remove(CrmFirestoreKeys.IMAGE_SIZE_KEY);
      savedConfig.remove(CrmFirestoreKeys.IMAGE_SIZE_UNIT_KEY);
      savedConfig.remove(CrmFirestoreKeys.IMAGE_TYPES_KEY);
    }
    if (isPhoneField) {
      savedConfig[CrmFirestoreKeys.COUNTRY_CODE_ENABLED_KEY] = boolConfig(
        CrmFirestoreKeys.COUNTRY_CODE_ENABLED_KEY,
        fallback: true,
      );
      savedConfig[CrmFirestoreKeys.COUNTRY_CODE_KEY] = stringConfig(
        CrmFirestoreKeys.COUNTRY_CODE_KEY,
        fallback: 'Countries',
      );
      savedConfig[CrmFirestoreKeys.ALLOW_SPACES_KEY] = boolConfig(
        CrmFirestoreKeys.ALLOW_SPACES_KEY,
        fallback: true,
      );
      savedConfig[CrmFirestoreKeys.ALLOW_MULTIPLE_KEY] = boolConfig(
        CrmFirestoreKeys.ALLOW_MULTIPLE_KEY,
        fallback: true,
      );
      savedConfig[CrmFirestoreKeys.ALLOW_MULTIPLE_VALUES_KEY] = boolConfig(
        CrmFirestoreKeys.ALLOW_MULTIPLE_KEY,
        fallback: true,
      );
      savedConfig[CrmFirestoreKeys.UNIQUE_KEY] = boolConfig(
        CrmFirestoreKeys.UNIQUE_KEY,
        fallback: true,
      );
      savedConfig[CrmFirestoreKeys.IS_UNIQUE_KEY] = boolConfig(
        CrmFirestoreKeys.UNIQUE_KEY,
        fallback: true,
      );
    } else {
      savedConfig.remove(CrmFirestoreKeys.COUNTRY_CODE_ENABLED_KEY);
      savedConfig.remove(CrmFirestoreKeys.COUNTRY_CODE_KEY);
      savedConfig.remove(CrmFirestoreKeys.ALLOW_SPACES_KEY);
    }
    if (isLinkField) {
      savedConfig[CrmFirestoreKeys.SPECIFIC_LINK_TYPES_ENABLED_KEY] =
          boolConfig(
        CrmFirestoreKeys.SPECIFIC_LINK_TYPES_ENABLED_KEY,
        fallback: true,
      );
      savedConfig[CrmFirestoreKeys.LINK_TYPES_KEY] = selectedLinkTypes();
      savedConfig[CrmFirestoreKeys.ADD_MORE_LINK_ENABLED_KEY] = boolConfig(
        CrmFirestoreKeys.ADD_MORE_LINK_ENABLED_KEY,
        fallback: true,
      );
      savedConfig[CrmFirestoreKeys.TRIM_SPACES_KEY] = boolConfig(
        CrmFirestoreKeys.TRIM_SPACES_KEY,
        fallback: true,
      );
    } else {
      savedConfig.remove(CrmFirestoreKeys.SPECIFIC_LINK_TYPES_ENABLED_KEY);
      savedConfig.remove(CrmFirestoreKeys.LINK_TYPES_KEY);
      savedConfig.remove(CrmFirestoreKeys.ADD_MORE_LINK_ENABLED_KEY);
    }
    if (isFileField) {
      savedConfig[CrmFirestoreKeys.MAXIMUM_NUMBER_KEY] =
          int.tryParse(maximumNumberController.text.trim());
      savedConfig[CrmFirestoreKeys.FILE_SIZE_KEY] =
          int.tryParse(fileSizeController.text.trim());
      savedConfig[CrmFirestoreKeys.FILE_SIZE_UNIT_KEY] = stringConfig(
        CrmFirestoreKeys.FILE_SIZE_UNIT_KEY,
        fallback: 'MB',
      );
      savedConfig[CrmFirestoreKeys.FILE_TYPES_KEY] = selectedFileTypes();
    } else {
      savedConfig.remove(CrmFirestoreKeys.FILE_SIZE_KEY);
      savedConfig.remove(CrmFirestoreKeys.FILE_SIZE_UNIT_KEY);
      savedConfig.remove(CrmFirestoreKeys.FILE_TYPES_KEY);
    }
    if (isDateField) {
      savedConfig[CrmFirestoreKeys.DATE_RANGE_FROM_KEY] =
          dateFromController.text.trim();
      savedConfig[CrmFirestoreKeys.DATE_RANGE_TO_KEY] =
          dateToController.text.trim();
    } else {
      savedConfig.remove(CrmFirestoreKeys.DATE_RANGE_FROM_KEY);
      savedConfig.remove(CrmFirestoreKeys.DATE_RANGE_TO_KEY);
    }
    if (isTimeField) {
      savedConfig[CrmFirestoreKeys.TIME_RANGE_FROM_KEY] =
          timeFromController.text.trim();
      savedConfig[CrmFirestoreKeys.TIME_RANGE_TO_KEY] =
          timeToController.text.trim();
    } else {
      savedConfig.remove(CrmFirestoreKeys.TIME_RANGE_FROM_KEY);
      savedConfig.remove(CrmFirestoreKeys.TIME_RANGE_TO_KEY);
    }
    if (isSwitchField) {
      savedConfig[CrmFirestoreKeys.MULTIPLE_CHOOSE_KEY] = boolConfig(
        CrmFirestoreKeys.MULTIPLE_CHOOSE_KEY,
        fallback: true,
      );
    } else {
      savedConfig.remove(CrmFirestoreKeys.MULTIPLE_CHOOSE_KEY);
    }
    if (isSignatureField) {
      savedConfig[CrmFirestoreKeys.SAVE_FORMAT_KEY] = stringConfig(
        CrmFirestoreKeys.SAVE_FORMAT_KEY,
        fallback: 'File',
      );
      savedConfig[CrmFirestoreKeys.SIGNATURE_TYPES_KEY] =
          selectedSignatureTypes();
    } else {
      savedConfig.remove(CrmFirestoreKeys.SAVE_FORMAT_KEY);
      savedConfig.remove(CrmFirestoreKeys.SIGNATURE_TYPES_KEY);
    }
    if (isWebsiteField) {
      savedConfig[CrmFirestoreKeys.AUTO_ADD_HTTPS_KEY] = boolConfig(
        CrmFirestoreKeys.AUTO_ADD_HTTPS_KEY,
        fallback: true,
      );
      savedConfig[CrmFirestoreKeys.TRIM_SPACES_KEY] = boolConfig(
        CrmFirestoreKeys.TRIM_SPACES_KEY,
        fallback: true,
      );
    } else {
      savedConfig.remove(CrmFirestoreKeys.AUTO_ADD_HTTPS_KEY);
    }
    if (isPurchasingValueField) {
      final List<String> validationTypes = selectedPurchasingValidationTypes();
      savedConfig[CrmFirestoreKeys.VALUE_VALIDATION_TYPES_KEY] =
          validationTypes;
      validationType = validationTypes.join(',');
    } else if (fieldKind == 'text' || fieldKind.isEmpty) {
      final List<String> validationTypes = selectedTextValidationTypes();
      savedConfig[CrmFirestoreKeys.VALIDATION_TYPES_KEY] = validationTypes;
      validationType = validationTypes.join(',');
    } else {
      savedConfig.remove(CrmFirestoreKeys.VALUE_VALIDATION_TYPES_KEY);
      savedConfig.remove(CrmFirestoreKeys.VALIDATION_TYPES_KEY);
    }
    return field.copyWith(
      nameEn: nameEnController.text.trim(),
      nameAr: nameArController.text.trim(),
      maxCharacters: max,
      validationType: validationType,
      errorMessageEn: errorEnController.text.trim().isNotEmpty
          ? errorEnController.text.trim()
          : (field.isRequired ? 'This Field is Required' : ''),
      errorMessageAr: errorArController.text.trim().isNotEmpty
          ? errorArController.text.trim()
          : (field.isRequired ? 'هذا الحقل مطلوب' : ''),
      options: optionMaps
          .map((option) =>
              (option[CrmFirestoreKeys.OPTION_LABEL_EN_KEY] ?? '').toString())
          .where((value) => value.isNotEmpty)
          .toList(),
      configuration: savedConfig,
    );
  }

  void dispose() {
    nameEnController.dispose();
    nameArController.dispose();
    maxController.dispose();
    maximumNumberController.dispose();
    imageSizeController.dispose();
    fileSizeController.dispose();
    dateFromController.dispose();
    dateToController.dispose();
    timeFromController.dispose();
    timeToController.dispose();
    formatController.dispose();
    errorEnController.dispose();
    errorArController.dispose();
    for (final CrmTemplateOptionEditModel option in options) {
      option.dispose();
    }
  }
}
