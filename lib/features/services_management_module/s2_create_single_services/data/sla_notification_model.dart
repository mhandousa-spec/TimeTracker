/// Module: services_management_module
/// Description: Data model for the SLA notification screen. Owns the
///              TextEditingControllers used by the SLA form (moved here,
///              out of SlaNotificationCubit, so the cubit stays free of
///              widget-lifecycle objects — the cubit only calls the
///              add/remove/dispose methods below).
/// Author: Amr Mesbah
/// Date: 30/8/2025
/// Dependencies: flutter/cupertino.dart
/// Revision History:
///   - 30/8/2025 (Amr Mesbah): Initial version.
///   - 02/07/2026 (Knowticed Team): Moved controller add/remove/listener
///     lifecycle methods here from SlaNotificationCubit (fix item 3).

import 'dart:async';
import 'package:flutter/cupertino.dart';

class SlaNotificationModel {
  // Controllers
  final TextEditingController slaOneController = TextEditingController();
  final TextEditingController slaTwoController = TextEditingController();
  List<TextEditingController> extraSlaControllers = [];
  List<TextEditingController> extraSlaTwoControllers = [];

  // Checkbox states
  bool notifyRequesterChecked = true;
  bool notifyProviderChecked = true;
  bool notifyManagerChecked = true;

  // Switch states
  bool notifyRequesterSwitch0 = false;
  bool notifyManagerSwitch1 = false;

  // Validation flags
  bool isInvalidNumber = false;
  bool isInvalidNumberTwo = false;

  // Notification switches map
  Map<String, Map<int, bool>> notificationSwitches = {};

  // Other fields
  String? formatDate;
  static const int maxSlaInputs = 5;

  /// Adds a new extra-SLA controller (list 1) and wires its debounced
  /// listener to [onChanged]. Returns true if a controller was added.
  bool addExtraSlaController(void Function() onChanged) {
    if (extraSlaControllers.length >= maxSlaInputs) return false;
    final newController = TextEditingController();
    extraSlaControllers.add(newController);
    _setupExtraControllerListener(newController, onChanged);
    return true;
  }

  /// Adds a new extra-SLA controller (list 2) and wires its debounced
  /// listener to [onChanged]. Returns true if a controller was added.
  bool addExtraSlaTwoController(void Function() onChanged) {
    if (extraSlaTwoControllers.length >= maxSlaInputs) return false;
    final newController = TextEditingController();
    extraSlaTwoControllers.add(newController);
    _setupExtraControllerListener(newController, onChanged);
    return true;
  }

  /// Removes and disposes the extra-SLA controller (list 1) at [index].
  /// Returns true if a controller was removed.
  bool removeExtraSlaController(int index) {
    if (index < 0 || index >= extraSlaControllers.length) return false;
    extraSlaControllers[index].dispose();
    extraSlaControllers.removeAt(index);
    return true;
  }

  /// Removes and disposes the extra-SLA controller (list 2) at [index].
  /// Returns true if a controller was removed.
  bool removeExtraSlaTwoController(int index) {
    if (index < 0 || index >= extraSlaTwoControllers.length) return false;
    extraSlaTwoControllers[index].dispose();
    extraSlaTwoControllers.removeAt(index);
    return true;
  }

  void _setupExtraControllerListener(
    TextEditingController controller,
    void Function() onChanged,
  ) {
    Timer? debounceTimer;

    controller.addListener(() {
      debounceTimer?.cancel();
      debounceTimer = Timer(const Duration(milliseconds: 500), onChanged);
    });
  }

  void dispose() {
    slaOneController.dispose();
    slaTwoController.dispose();
    for (var controller in extraSlaControllers) {
      controller.dispose();
    }
    for (var controller in extraSlaTwoControllers) {
      controller.dispose();
    }
  }
}