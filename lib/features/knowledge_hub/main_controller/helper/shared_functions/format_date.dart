/// Module: knowledge_hub / core/shared_functions/format_date.dart
/// ************************* FILE INFO *************************** ///
/// File Name: format_date.dart
/// Purpose: Format date — knowledge_hub core/widgets.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:intl/intl.dart';

String formatDate(DateTime? date) {
  if (date == null) return 'N/A';
  return DateFormat('dd MMM yyyy').format(date);
}