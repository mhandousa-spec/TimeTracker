import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/domain/entity/analytics_text_field_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/domain/entity/form_chart_data.dart';

class AnalyticsEntity {
  FormFieldType type;
  String title;
  bool? isAggregated;
  List<AnalyticsTextFieldEntity>? data;
  List<FormChartData>? chartData;

  AnalyticsEntity(
      {required this.title, required this.type, this.data, this.chartData});

  int get getTotalChartSubmissions {
    int total = 0;
    if (chartData != null) {
      for (var chart in chartData!) {
        total += chart.values.toInt();
      }
    }
    return total;
  }
}
