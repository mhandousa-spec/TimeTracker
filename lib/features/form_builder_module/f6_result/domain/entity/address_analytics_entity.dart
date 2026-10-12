/// Module: services_app_module/result
///
/// FILE INFO
/// File Name   : address_analytics_entity.dart
/// Objective   : Domain entity holding address-analytics data. UI-free (§3) —
///               the Material table builders live in the presentation layer
///               (presentation/ui/widgets/address_analytics_table_builder.dart).
library;

import 'package:knowticed_plus/features/form_builder_module/f6_result/domain/entity/analytics_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/domain/entity/form_chart_data.dart';

import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';

class AddressAnalyticsEntity extends AnalyticsEntity {
  List<String>? addressItems;
  List<List<FormChartData>>? addressChartData;
  List<String>? headerItems;
  List<List<String>>? addressTableList;
  List<String>? images;

  AddressAnalyticsEntity({
    required String title,
    required FormFieldType type,
  }) : super(title: title, type: type);
}
