/// Module: home/h1_home_page
///
/// *********************** FILE INFO *****************************
/// File Name: home_component_model.dart
/// Purpose: Entity for hold component information to be used in the home screen
/// Author: Amr Mesbah
/// Created at: 21/9/2025
/// Updated: 11/8/2026 - Fields made final, explicit toMap() type, copyWith.

import 'package:knowticed_plus/features/home/h1_home_page/domain/enums/home_components.dart';

class HomeComponentModel {
  const HomeComponentModel({
    required this.component,
    required this.rowNumber,
    required this.columnNumber,
  });

  final HomeComponents component;
  final int rowNumber;
  final int columnNumber;

  static const String componentKey = 'Component';
  static const String rowNumberKey = 'Row_Number';
  static const String columnNumberKey = 'Column_Number';

  /// Function Name: [toMap]
  ///
  /// Purpose: Serialise this component for Firestore.
  ///
  /// Returns: [Map<String, dynamic>] the Firestore representation.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      componentKey: component.databaseName,
      rowNumberKey: rowNumber,
      columnNumberKey: columnNumber,
    };
  }

  /// Function Name: [copyWith]
  ///
  /// Purpose: Return a copy with selected fields replaced. Needed now that the
  ///          fields are final — drag-reorder rebuilds components rather than
  ///          mutating them.
  HomeComponentModel copyWith({
    HomeComponents? component,
    int? rowNumber,
    int? columnNumber,
  }) {
    return HomeComponentModel(
      component: component ?? this.component,
      rowNumber: rowNumber ?? this.rowNumber,
      columnNumber: columnNumber ?? this.columnNumber,
    );
  }

  factory HomeComponentModel.fromMap(Map<String, dynamic> map) {
    return HomeComponentModel(
      // orElse: stored layouts may name components this build removed.
      component: HomeComponents.values.firstWhere(
        (e) => e.databaseName == map[componentKey],
        orElse: () => HomeComponents.unknown,
      ),
      rowNumber: map[rowNumberKey] as int,
      columnNumber: map[columnNumberKey] as int,
    );
  }
}
