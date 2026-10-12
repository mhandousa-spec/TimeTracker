/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: template_variable_samples.dart
/// Purpose: Placeholder values for demo / test data.
/// Author: Knowticed Plus team
/// Created at: 27/9/2026
///
/// Every notification and calendar event asserts that a value is supplied for
/// each `{{placeholder}}` it declares. The "Apply all modules" demo seeder
/// sends EVERY event, so it needs a believable value for ANY variable without
/// a hand-written map per event. [sampleValue] derives one from the key:
/// dates become a real date, counts a number, names "Demo <Thing>".

import 'package:intl/intl.dart';
import 'template_variable.dart';

extension TemplateVariableSample on TemplateVariable {
  /// A believable demo value for this placeholder.
  String sampleValue({DateTime? now}) {
    final DateTime today = now ?? DateTime.now();
    final String k = key;
    final String lower = k.toLowerCase();

    if (lower.contains('date')) {
      final int shift = lower.startsWith('old') ? 0 : 14;
      return DateFormat('dd/MM/yyyy', 'en')
          .format(today.add(Duration(days: shift)));
    }
    if (k == 'time') return DateFormat('hh:mm a', 'en').format(today);
    if (k == 'minutes') return '15';
    if (lower.contains('count')) return '3';
    if (lower.contains('score')) return lower.startsWith('old') ? '70' : '85';
    if (lower.contains('weight')) return lower.startsWith('old') ? '10' : '20';
    if (lower.contains('status')) {
      return lower.startsWith('old') ? 'Pending' : 'Approved';
    }
    if (k == 'channel') return 'Email';
    if (k == 'permissionLevel') return 'Editor';

    // camelCase -> "Demo Service" / "Demo Rejection Reason".
    final String words = k
        .replaceAllMapped(RegExp(r'([a-z0-9])([A-Z])'), (m) => '${m[1]} ${m[2]}')
        .split(' ')
        .where((w) => w.toLowerCase() != 'name')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
    return 'Demo $words';
  }
}

extension TemplateVariableSampleSet on Iterable<TemplateVariable> {
  /// `{variable: sampleValue}` for every placeholder in this set.
  Map<TemplateVariable, String> toSampleValues({DateTime? now}) => {
        for (final TemplateVariable v in this) v: v.sampleValue(now: now),
      };
}
