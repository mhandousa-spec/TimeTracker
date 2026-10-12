import 'dart:ui';

import 'package:knowticed_plus/core/theme/app_colors.dart';

class ColorGenerator {
  static  Color yellowBase =AppColors.primary;
  static Color lightGreyBase = AppColors.grey;
  static  Color darkGreyBase = AppColors.secondaryText;

  static List<Color> generateColors(int count) {
    List<Color> colors = [];

    // Add the three main colors first
    colors.add(yellowBase);
    colors.add(lightGreyBase);
    colors.add(darkGreyBase);

    // If we need more colors, generate variations
    if (count > 3) {
      int remainingColors = count - 3;
      double step = 1.0 / (remainingColors ~/ 3 + 1);

      for (int i = 0; i < remainingColors; i++) {
        if (i < remainingColors / 3) {
          // Yellow variations
          double factor = 0.8 - (step * i);
          colors.add(_adjustColor(yellowBase, factor));
        } else if (i < (remainingColors * 2) / 3) {
          // Light grey variations
          double factor = 0.8 - (step * (i - remainingColors ~/ 3));
          colors.add(_adjustColor(lightGreyBase, factor));
        } else {
          // Dark grey variations
          double factor = 0.8 - (step * (i - (remainingColors * 2) ~/ 3));
          colors.add(_adjustColor(darkGreyBase, factor));
        }
      }
    }

    return colors;
  }

  static Color _adjustColor(Color baseColor, double factor) {
    return Color.fromARGB(
      baseColor.alpha,
      (baseColor.red * factor).round(),
      (baseColor.green * factor).round(),
      (baseColor.blue * factor).round(),
    );
  }
}