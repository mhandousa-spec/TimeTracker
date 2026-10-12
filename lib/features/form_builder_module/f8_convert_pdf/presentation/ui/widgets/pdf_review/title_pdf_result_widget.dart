import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/alignment.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/title_field_model.dart';
import 'package:knowticed_plus/core/helper/main_helper/extensions.dart';

class TitlePdfResultWidget extends StatelessWidget {
  // Constructor parameters for identifying the specific field
  final TitleFieldModel model;

  const TitlePdfResultWidget({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    // Align the text based on the selected alignment
    return Align(
        alignment: model.alignment.alignment, child: _buildText(model));
  }

  // Build the text with custom styling
  Widget _buildText(TitleFieldModel model) {
    
/*    String hexColor =
        model.titleColor.replaceAll("Color(", "").replaceAll(")", "");*/
    return Text(
      // Use empty string if title is null
      model.title,
      style: TextStyle(
        // Apply selected text color
        color: ColorExtension1(model.titleColor).toColor(),
        // Parse and apply text size
        fontSize: _parseTextSize(model),
        // Apply bold styling
        fontWeight: _getFontWeight(model),
        // Apply underline decoration
        decoration: _getDecoration(model),
        // Use same color for decoration
        decorationColor: ColorExtension1(model.titleColor).toColor(),
        // Apply italic styling
        fontStyle: _getFontStyle(model),
      ),
    );
  }

  // textSize is a plain field access; no try/catch in UI (§11.2).
  double _parseTextSize(TitleFieldModel model) => model.textSize;

  // Determine font weight based on bold setting
  FontWeight _getFontWeight(TitleFieldModel model) {
    return model.isBold ? FontWeight.bold : FontWeight.normal;
  }

  // Determine text decoration based on underline setting
  TextDecoration _getDecoration(TitleFieldModel model) {
    return model.isUnderLine ? TextDecoration.underline : TextDecoration.none;
  }

  // Determine font style based on italic setting
  FontStyle _getFontStyle(TitleFieldModel model) {
    return model.isItalic ? FontStyle.italic : FontStyle.normal;
  }
}
