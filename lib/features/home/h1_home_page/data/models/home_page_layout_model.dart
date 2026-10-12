/// Module: home/h1_home_page
///
/// ********************* FILE INFO ****************************
/// File Name: home_page_layout_model.dart
/// Purpose: Entity for home page layout containing active and draft components
/// Author: Amr Mesbah
/// Created at: 21/9/2025
/// Updated: 11/8/2026 - Fields made final, keys made `static const`, explicit
///          toMap() type, copyWith added, console I/O removed.

import 'package:knowticed_plus/features/home/h1_home_page/domain/enums/app_bar_enum.dart';

import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';

class HomePageLayoutModel {
  const HomePageLayoutModel({
    required this.id,
    required this.activeComponents,
    required this.activeAppBarOptions,
    this.headerIcons = const <String>[],
  });

  final String id;
  final List<HomeComponentModel> activeComponents;
  final List<AppBarOptions> activeAppBarOptions;

  /// Svg asset paths of the icons pinned to the home app bar.
  final List<String> headerIcons;

  static const String idKey = 'Id';
  static const String activeComponentsKey = 'Active_Components';
  static const String activeAppBarOptionsKey = 'Active_AppBar_Options';
  static const String headerIconsKey = 'Header_Icons';

  /// Function Name: [toMap]
  ///
  /// Purpose: Serialise the layout for Firestore.
  ///
  /// Returns: [Map<String, dynamic>] the Firestore representation.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      idKey: id,
      activeComponentsKey: activeComponents
          .map((HomeComponentModel component) => component.toMap())
          .toList(),
      activeAppBarOptionsKey: activeAppBarOptions
          .map((AppBarOptions option) => option.databaseName)
          .toList(),
      headerIconsKey: headerIcons,
    };
  }

  /// Function Name: [copyWith]
  ///
  /// Purpose: Return a copy with selected fields replaced.
  HomePageLayoutModel copyWith({
    String? id,
    List<HomeComponentModel>? activeComponents,
    List<AppBarOptions>? activeAppBarOptions,
    List<String>? headerIcons,
  }) {
    return HomePageLayoutModel(
      id: id ?? this.id,
      activeComponents: activeComponents ?? this.activeComponents,
      activeAppBarOptions: activeAppBarOptions ?? this.activeAppBarOptions,
      headerIcons: headerIcons ?? this.headerIcons,
    );
  }

  factory HomePageLayoutModel.fromMap(Map<String, dynamic> map) {
    return HomePageLayoutModel(
      id: map[idKey] as String,
      activeComponents:
          List<Map<String, dynamic>>.from(map[activeComponentsKey] ?? const [])
              .map(getComponentModel)
              .toList(),
      activeAppBarOptions:
          List<String>.from(map[activeAppBarOptionsKey] ?? const [])
              .map((String e) => AppBarOptions.values
                  .firstWhere((AppBarOptions option) => option.databaseName == e))
              .toList(),
      headerIcons: map[headerIconsKey] != null
          ? List<String>.from(map[headerIconsKey])
          : const <String>[],
    );
  }

  /// Function Name: [getComponentModel]
  ///
  /// Purpose: Deserialise a single stored component.
  ///
  /// Every remaining component deserialises to the base model, so this just
  /// delegates. [HomeComponentModel.fromMap] resolves the component enum with
  /// an `orElse` fallback — required because layouts are persisted per user, so
  /// a stored document may still name a component this build removed (the
  /// messaging Direct_Message / Group_Message cards). Without the fallback
  /// `firstWhere` throws StateError and the whole home page fails to load.
  static HomeComponentModel getComponentModel(
      Map<String, dynamic> componentMap) {
    return HomeComponentModel.fromMap(componentMap);
  }
}
