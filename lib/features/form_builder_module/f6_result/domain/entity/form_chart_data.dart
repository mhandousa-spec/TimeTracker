class FormChartData {
  final String text;
  final double values;

  const FormChartData(this.text, this.values);

  FormChartData copyWith({
    String? text,
    double? values,
  }) {
    return FormChartData(
      text ?? this.text,
      values ?? this.values,
    );
  }
}