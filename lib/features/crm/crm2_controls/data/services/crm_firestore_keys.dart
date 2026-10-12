// ****************** FILE INFO ******************
// File Name: crm_firestore_keys.dart
// Purpose: Centralized Firestore collection and field keys for CRM controls
// Author: Mohand Adel
// Created At: 04/08/2026

// ignore_for_file: constant_identifier_names

abstract class CrmFirestoreCollections {
  static const String CONTROLS_COLLECTION = 'Controls';
  static const String CLIENTS_COLLECTION = 'Clients';
  static const String CLIENT_TYPES_COLLECTION = 'Client_Types';
  static const String RELATIONSHIP_CATEGORIES_COLLECTION =
      'Relationship_Categories';
  static const String FIELD_TYPES_COLLECTION = 'Field_Types';
  static const String TEMPLATES_COLLECTION = 'Templates';
  static const String TEMPLATE_SECTIONS_COLLECTION = 'Template_Sections';
  static const String TEMPLATE_FIELDS_COLLECTION = 'Template_Fields';
  static const String TEMPLATE_LAYOUTS_COLLECTION = 'Template_Layouts';
  static const String TEMPLATE_HISTORY_COLLECTION = 'Template_History';
  static const String SAVED_SECTIONS_COLLECTION = 'Saved_Sections';
  static const String SAVED_SECTION_FIELDS_COLLECTION = 'Saved_Section_Fields';
  static const String RECORDS_COLLECTION = 'Records';
  static const String TERMS_COLLECTION = 'Terms';
  static const String ACTIVITY_CATEGORIES_COLLECTION = 'Activity_Categories';
  static const String ACTIVITY_TAGS_COLLECTION = 'Activity_Tags';
  static const String DEAL_CATEGORIES_COLLECTION = 'Deal_Categories';
  static const String DEAL_STAGES_COLLECTION = 'Deal_Stages';
  static const String PRODUCT_CATEGORIES_COLLECTION = 'Product_Categories';
  static const String PRODUCTS_COLLECTION = 'Products';
  static const String SERVICE_CATEGORIES_COLLECTION = 'Service_Categories';
  static const String SERVICES_COLLECTION = 'Services';
  static const String DISCOUNTS_COLLECTION = 'Discounts';
  static const String MERGE_LEVELS_COLLECTION = 'Merge_Levels';
  static const String MERGE_SETTINGS_COLLECTION = 'Merge_Settings';
  static const String MERGE_HISTORY_COLLECTION = 'Merge_History';
  static const String DOCUMENTS_COLLECTION = 'Documents';
}

abstract class CrmFirestoreKeys {
  static const String DOC_NAME_KEY = 'Name';
  static const String DOC_URL_KEY = 'Url';
  static const String DOC_SIZE_KEY = 'Size_Bytes';
  static const String DOC_EXTENSION_KEY = 'Extension';
  static const String DOC_UPLOADED_BY_KEY = 'Uploaded_By';
  static const String DOC_UPLOADED_BY_NAME_KEY = 'Uploaded_By_Name';
  static const String DOC_UPLOADED_AT_KEY = 'Uploaded_At';
  static const String DOC_STORAGE_PATH_KEY = 'Storage_Path';
  static const String CHECKLIST_ITEMS_KEY = 'Checklist_Items';
  static const String PROBABILITY_KEY = 'Probability';
  static const String COLOR_KEY = 'Color';
  static const String TYPES_KEY = 'Types';
  static const String CLAUSES_KEY = 'Clauses';
  static const String ID_KEY = 'Id';
  static const String SYSTEM_KEY = 'System_Key';
  static const String TITLE_KEY = 'Title';
  static const String NAME_EN_KEY = 'Name_En';
  static const String NAME_AR_KEY = 'Name_Ar';
  static const String SVG_ASSET_KEY = 'Svg_Asset';
  static const String ICON_KEY = 'Icon_Key';
  static const String ICON_URL_KEY = 'Icon_Url';
  static const String VALUE_TYPE_KEY = 'Value_Type';
  static const String INPUT_TYPE_KEY = 'Input_Type';
  static const String ALLOWED_CLIENT_TYPE_IDS_KEY = 'Allowed_Client_Type_Ids';
  static const String IS_DEFAULT_KEY = 'Is_Default';
  static const String IS_ACTIVE_KEY = 'Is_Active';
  static const String IS_DELETED_KEY = 'Is_Deleted';
  static const String IS_SYSTEM_KEY = 'Is_System';
  static const String IS_COLLAPSIBLE_KEY = 'Is_Collapsible';
  static const String CONFIGURATION_KEY = 'Configuration';
  static const String ORDER_KEY = 'Order';
  static const String STATUS_KEY = 'Status';
  static const String VERSION_KEY = 'Version';
  static const String FIELD_COUNT_KEY = 'Field_Count';
  static const String SECTION_COUNT_KEY = 'Section_Count';
  static const String PAGE_COUNT_KEY = 'Page_Count';
  static const String DEFAULTS_VERSION_KEY = 'Defaults_Version';
  static const String PUBLISHED_AT_KEY = 'Published_At';
  static const String AUDIT_KEY = 'Audit';
  static const String CREATED_AT_KEY = 'Created_At';
  static const String UPDATED_AT_KEY = 'Updated_At';
  static const String CREATED_BY_KEY = 'Created_By';
  static const String UPDATED_BY_KEY = 'Updated_By';
  static const String TEMPLATE_ID_KEY = 'Template_Id';
  static const String TEMPLATE_VERSION_KEY = 'Template_Version';
  static const String CLIENT_TYPE_ID_KEY = 'Client_Type_Id';
  static const String TAG_IDS_KEY = 'Tag_Ids';
  static const String NOTE_EN_KEY = 'Note_En';
  static const String NOTE_AR_KEY = 'Note_Ar';
  static const String VALUES_KEY = 'Values';
  static const String SECTION_ID_KEY = 'Section_Id';
  static const String SAVED_SECTION_ID_KEY = 'Saved_Section_Id';
  static const String SOURCE_SAVED_SECTION_ID_KEY = 'Source_Saved_Section_Id';
  static const String SOURCE_SAVED_SECTION_FIELD_ID_KEY =
      'Source_Saved_Section_Field_Id';
  static const String SOURCE_SYSTEM_KEY_KEY = 'Source_System_Key';
  static const String FIELD_TYPE_ID_KEY = 'Field_Type_Id';
  static const String MAX_CHARACTERS_KEY = 'Max_Characters';
  static const String VALIDATION_TYPE_KEY = 'Validation_Type';
  static const String IS_REQUIRED_KEY = 'Is_Required';
  static const String ERROR_MESSAGE_EN_KEY = 'Error_Message_En';
  static const String ERROR_MESSAGE_AR_KEY = 'Error_Message_Ar';
  static const String SHOW_BOTH_LANGUAGES_KEY = 'Show_Both_Languages';
  static const String OPTIONS_KEY = 'Options';
  static const String PAGES_KEY = 'Pages';
  static const String ROWS_KEY = 'Rows';
  static const String COLUMNS_KEY = 'Columns';
  static const String TITLE_EN_KEY = 'Title_En';
  static const String TITLE_AR_KEY = 'Title_Ar';
  static const String COLUMNS_COUNT_KEY = 'Columns_Count';
  static const String TYPE_KEY = 'Type';
  static const String REF_ID_KEY = 'Ref_Id';
  static const String TARGET_TYPE_KEY = 'Target_Type';
  static const String TARGET_ID_KEY = 'Target_Id';
  static const String ACTION_KEY = 'Action';
  static const String BEFORE_KEY = 'Before';
  static const String AFTER_KEY = 'After';
  static const String CHANGED_BY_KEY = 'Changed_By';
  static const String CHANGED_AT_KEY = 'Changed_At';
  static const String ALLOW_SPECIAL_CHARACTERS_KEY = 'Allow_Special_Characters';
  static const String TRIM_SPACES_KEY = 'Trim_Spaces';
  static const String IS_ENABLED_KEY = 'Is_Enabled';
  static const String ADDRESS_COMPONENT_KEY = 'Address_Component';
  static const String ENTRY_TYPE_KEY = 'Entry_Type';
  static const String ALLOW_SEARCH_KEY = 'Allow_Search';
  static const String ALLOW_MULTIPLE_KEY = 'Allow_Multiple';
  static const String MAX_LENGTH_ENABLED_KEY = 'Max_Length_Enabled';
  static const String MAX_LENGTH_KEY = 'Max_Length';
  static const String FORMAT_EXAMPLE_KEY = 'Format_Example';
  static const String UNIQUE_KEY = 'Unique';
  static const String OPTION_ID_KEY = 'Option_Id';
  static const String OPTION_LABEL_EN_KEY = 'Option_Label_En';
  static const String OPTION_LABEL_AR_KEY = 'Option_Label_Ar';
  static const String OPTION_IS_DEFAULT_KEY = 'Option_Is_Default';
  static const String OPTION_IS_DELETED_KEY = 'Option_Is_Deleted';
  static const String OPTION_ORDER_KEY = 'Option_Order';
  static const String ADDRESS_COMPONENTS_KEY = 'Address_Components';
  static const String ENTRY_TYPES_KEY = 'Entry_Types';
  static const String CONTINENTS_KEY = 'Continents';
  static const String COUNTRIES_KEY = 'Countries';
  static const String CITIES_KEY = 'Cities';
  static const String ALLOW_MULTIPLE_VALUES_KEY = 'Allow_Multiple_Values';
  static const String IS_UNIQUE_KEY = 'Is_Unique';
  static const String ENABLE_SEARCH_KEY = 'Enable_Search';
  static const String SUPPORTED_DATA_SCOPE_KEY = 'Supported_Data_Scope';
  static const String DEFAULT_OPTIONS_KEY = 'Default_Options';
  static const String DEFAULT_VALUE_KEY = 'Default_Value';
  static const String FIELD_KIND_KEY = 'Field_Kind';
  static const String MAXIMUM_NUMBER_KEY = 'Maximum_Number';
  static const String IMAGE_SIZE_KEY = 'Image_Size';
  static const String IMAGE_SIZE_UNIT_KEY = 'Image_Size_Unit';
  static const String IMAGE_TYPES_KEY = 'Image_Types';
  static const String COUNTRY_CODE_ENABLED_KEY = 'Country_Code_Enabled';
  static const String COUNTRY_CODE_KEY = 'Country_Code';
  static const String ALLOW_SPACES_KEY = 'Allow_Spaces';
  static const String LINK_TYPES_KEY = 'Link_Types';
  static const String SPECIFIC_LINK_TYPES_ENABLED_KEY =
      'Specific_Link_Types_Enabled';
  static const String ADD_MORE_LINK_ENABLED_KEY = 'Add_More_Link_Enabled';
  static const String FILE_SIZE_KEY = 'File_Size';
  static const String FILE_SIZE_UNIT_KEY = 'File_Size_Unit';
  static const String FILE_TYPES_KEY = 'File_Types';
  static const String DATE_RANGE_FROM_KEY = 'Date_Range_From';
  static const String DATE_RANGE_TO_KEY = 'Date_Range_To';
  static const String TIME_RANGE_FROM_KEY = 'Time_Range_From';
  static const String TIME_RANGE_TO_KEY = 'Time_Range_To';
  static const String MULTIPLE_CHOOSE_KEY = 'Multiple_Choose';
  static const String SAVE_FORMAT_KEY = 'Save_Format';
  static const String SIGNATURE_TYPES_KEY = 'Signature_Types';
  static const String AUTO_ADD_HTTPS_KEY = 'Auto_Add_HTTPS';
  static const String VALUE_VALIDATION_TYPES_KEY = 'Value_Validation_Types';
  static const String VALIDATION_TYPES_KEY = 'Validation_Types';
  static const String RANGE_FROM_KEY = 'Range_From';
  static const String RANGE_TO_KEY = 'Range_To';
  static const String COLOR_HEX_KEY = 'Color_Hex';
  static const String UNDO_ENABLED_KEY = 'Undo_Enabled';
  static const String DURATION_VALUE_KEY = 'Duration_Value';
  static const String DURATION_UNIT_KEY = 'Duration_Unit';
  static const String MATCHING_RULES_KEY = 'Matching_Rules';
  static const String MERGED_INTO_ID_KEY = 'Merged_Into_Id';
  static const String MERGED_CLIENT_IDS_KEY = 'Merged_Client_Ids';
  static const String SNAPSHOT_KEY = 'Snapshot';
  static const String MERGED_RECORD_SNAPSHOT_KEY = 'Merged_Record_Snapshot';
  static const String UNDO_EXPIRES_AT_KEY = 'Undo_Expires_At';

  static dynamic read(
    Map<String, dynamic> map,
    String key, [
    String? legacyKey,
  ]) {
    return map[key] ?? (legacyKey == null ? null : map[legacyKey]);
  }
}
