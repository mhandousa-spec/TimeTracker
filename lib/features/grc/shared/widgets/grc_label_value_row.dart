import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';

/// "Label: value" row used throughout every Details page's section cards
/// (Policy Details, Control Details, Submissions/Approvals, ...). Extracted
/// because both the Assignment Controls and Approvals features built the
/// exact same row independently.
class GrcLabelValueRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const GrcLabelValueRow(this.label, this.value, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$label: ', style: CardStyles.label(12).copyWith(color: color)),
        Expanded(child: Text(value, style: CardStyles.value(12).copyWith(color: color))),
      ],
    );
  }
}
