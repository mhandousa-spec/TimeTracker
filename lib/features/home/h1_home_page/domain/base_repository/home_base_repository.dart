/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: home_base_repository.dart
/// Purpose: Domain contract for the home layout repository so the cubit binds
///          to an abstraction instead of the concrete data-layer class.
/// Author: Amr Mesbah
/// Created at: 11/8/2026

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_page_layout_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/domain/enums/app_bar_enum.dart';

/// Contract implemented by the data layer for reading and persisting the
/// per-user home page layout.
abstract class HomeBaseRepository {
  /// Function Name: [updateHomeComponents]
  ///
  /// Purpose: Persist the user's home layout (components, app-bar options and
  ///          header icons).
  ///
  /// Parameters:
  /// - [appBarOptions]: App-bar options enabled for the user.
  /// - [components]: The components laid out on the home page.
  /// - [currentUserEmail]: Document id the layout is stored under.
  /// - [headerIcons]: Svg asset paths of the pinned header icons.
  ///
  /// Returns: [Either<Failure, dynamic>] — `Left` on write failure.
  Future<Either<Failure, dynamic>> updateHomeComponents({
    required List<AppBarOptions> appBarOptions,
    required List<HomeComponentModel> components,
    required String currentUserEmail,
    required List<String> headerIcons,
  });

  /// Function Name: [getHomeLayout]
  ///
  /// Purpose: Read the stored home layout for a user.
  ///
  /// Parameters:
  /// - [currentUserEmail]: Document id the layout is stored under.
  ///
  /// Returns: [Either<Failure, HomePageLayoutModel>] — `Left` when the read
  ///          fails or no layout document exists.
  Future<Either<Failure, HomePageLayoutModel>> getHomeLayout({
    required String currentUserEmail,
  });
}
