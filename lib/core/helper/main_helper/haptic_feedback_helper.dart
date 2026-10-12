/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: haptic_feedback_helper.dart
/// Purpose: Enum `VibrateType` used by this feature.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

// Date: 18/8/2024
// By: Nada Mohammed
// Last update: 18/8/2024
// Objectives: This file is responsible for providing the haptic feedback helper.

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

enum VibrateType {
  lightImpact,
  mediumImpact,
  heavyImpact,
}

abstract class HapticFeedbackHelper {
  // function to trigger haptic feedback based on the vibrate type
  static Future<void> triggerHapticFeedback({
    VibrateType vibration = VibrateType.lightImpact,
    Function() hapticFeedback = HapticFeedback.mediumImpact,
  }) async {
    if (Platform.isAndroid) {
      Vibration.vibrate(
        duration: vibration == VibrateType.lightImpact
            ? 50
            : vibration == VibrateType.mediumImpact
                ? 70
                : 90,
      );
    } else {
      hapticFeedback();
    }
  }
}
