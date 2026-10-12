// ***************************** FILE INFO ***************************** //
// File Name: add_employee_read_only_scope.dart
// Purpose: Provides the AddEmployeeReadOnlyScope widget for add-employee forms.
// Author: Mohamed Elrashidy
// Created At: 2026-08-10
// ********************************************************************* //

import 'package:flutter/material.dart';

/// Provides read-only rendering to reused preview form controls.
class AddEmployeeReadOnlyScope extends InheritedWidget {
  const AddEmployeeReadOnlyScope({
    super.key,
    required this.isReadOnly,
    required super.child,
  });

  final bool isReadOnly;

  /// Method Name: [isEnabled]
  ///
  /// Purpose: Resolves whether form controls may accept user interaction.
  ///
  /// Parameters:
  /// - [context]: Context beneath the optional read-only scope.
  ///
  /// Returns: True when a control should remain editable.
  static bool isEnabled(BuildContext context) {
    return !(context
            .dependOnInheritedWidgetOfExactType<AddEmployeeReadOnlyScope>()
            ?.isReadOnly ??
        false);
  }

  @override
  bool updateShouldNotify(AddEmployeeReadOnlyScope oldWidget) {
    return isReadOnly != oldWidget.isReadOnly;
  }
}
