/// Module: knowledge_hub / core/responsive_helper.dart
/// ************************* FILE INFO *************************** ///
/// File Name: responsive_helper.dart
/// Purpose: Responsive helper — knowledge_hub core/widgets.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:flutter/material.dart';


class ResponsivePage {

static  bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 900;
  }

static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width>=900;
  }
static bool isLandScape(BuildContext context) {
  return MediaQuery.of(context).size.width>=1024;
}
}
class ResponsiveHelper {
  static const double mobileMaxWidth = 600;
  static const double tabletMaxWidth = 1000;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width <= mobileMaxWidth;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width > mobileMaxWidth &&
      MediaQuery.of(context).size.width <= tabletMaxWidth;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width > tabletMaxWidth;
}
