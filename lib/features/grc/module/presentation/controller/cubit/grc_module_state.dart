part of 'grc_module_cubit.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: grc_module_state.dart
/// Purpose: Contains all sealed state classes emitted by [GRCModuleCubit].
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 30/6/2026

sealed class GRCModuleState {}

/// State emitted before any action has been requested.
final class GRCModuleInitial extends GRCModuleState {}

/// State emitted while any async operation is in progress.
final class GRCModuleLoading extends GRCModuleState {}

/// State emitted when the full list of modules has been loaded successfully.
final class GRCModuleListLoaded extends GRCModuleState {
  final List<GRCModuleEntity> modules;

  GRCModuleListLoaded(this.modules);
}

/// State emitted when a single module has been loaded successfully.
final class GRCModuleSingleLoaded extends GRCModuleState {
  final GRCModuleEntity module;

  GRCModuleSingleLoaded(this.module);
}

/// State emitted when a create / update / delete / restore action completes
/// successfully. [module] holds the entity that was affected.
final class GRCModuleActionSuccess extends GRCModuleState {
  final GRCModuleEntity module;

  GRCModuleActionSuccess(this.module);
}

/// State emitted when any operation fails.
final class GRCModuleFailure extends GRCModuleState {
  final String message;

  GRCModuleFailure(this.message);
}
