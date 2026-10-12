/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: home_state.dart
/// Purpose: State management for home screen
/// Author: Amr Mesbah
/// Created at: 20/9/2025
/// Updated: 11/8/2026 - HeaderIconItem now comes from data/models/ instead of
///          a presentation widget file.

import 'package:knowticed_plus/features/home/h1_home_page/data/models/header_icon_item.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/home_cubit.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {}

class HomeEditingComponent extends HomeState {}

class HomeIconsUpdated extends HomeState {
  final List<HeaderIconItem> icons;
  HomeIconsUpdated(this.icons);
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}
class HomePreviewModeChanged extends HomeState {
  final PreviewMode mode;
  HomePreviewModeChanged(this.mode);
}