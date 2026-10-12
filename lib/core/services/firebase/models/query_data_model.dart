/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: query_data_model.dart
/// Purpose: Declares `QueryDataModel`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

class QueryDataModel {
  String documentId;
  String collectionPath;
  Map<String, dynamic>? equalFieldsValues = {};
  Map<String, dynamic> queryData;
  QueryDataModel(
      {required this.documentId,
      required this.collectionPath,
      this.equalFieldsValues,
      required this.queryData});
}
