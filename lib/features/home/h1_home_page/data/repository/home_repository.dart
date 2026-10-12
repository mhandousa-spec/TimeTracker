/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: home_repository.dart
/// Purpose: Data-layer implementation of [HomeBaseRepository]; maps raw
///          Firebase maps to [HomePageLayoutModel].
/// Author: Amr Mesbah
/// Created at: 20/9/2025
/// Updated: 11/8/2026 - Implements the domain contract, data source injected.

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/data_source/remote_data_source/home_remote_data_source.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_page_layout_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/domain/base_repository/home_base_repository.dart';
import 'package:knowticed_plus/features/home/h1_home_page/domain/enums/app_bar_enum.dart';

class HomeRepository implements HomeBaseRepository {
  /// The remote data source is injected so tests (and future DI wiring) can
  /// substitute a fake instead of hitting Firebase.
  HomeRepository({HomeRemoteDataSource? homeRemoteDataSource})
      : _homeRemoteDataSource =
            homeRemoteDataSource ?? HomeRemoteDataSource();

  final HomeRemoteDataSource _homeRemoteDataSource;

  @override
  Future<Either<Failure, dynamic>> updateHomeComponents({
    required List<AppBarOptions> appBarOptions,
    required List<HomeComponentModel> components,
    required String currentUserEmail,
    required List<String> headerIcons,
  }) async {
    final HomePageLayoutModel layoutModel = HomePageLayoutModel(
      id: currentUserEmail,
      activeComponents: components,
      activeAppBarOptions: appBarOptions,
      headerIcons: headerIcons,
    );
    return _homeRemoteDataSource.updateHomeComponents(layoutModel);
  }

  @override
  Future<Either<Failure, HomePageLayoutModel>> getHomeLayout({
    required String currentUserEmail,
  }) async {
    final Either<Failure, dynamic> result =
        await _homeRemoteDataSource.getHomeLayout(currentUserEmail);

    return result.fold<Either<Failure, HomePageLayoutModel>>(
      (Failure failure) => Left(failure),
      (dynamic layoutMap) {
        if (layoutMap is! Map<String, dynamic>) {
          return Left(FirebaseFailure('No layout found'));
        }
        return Right(HomePageLayoutModel.fromMap(layoutMap));
      },
    );
  }
}
