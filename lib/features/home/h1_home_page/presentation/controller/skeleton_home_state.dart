// Module: home/h1_home_page
//
//*************************** FILE INFO ****************************///
// File Name: skeleton_home_state.dart
// Purpose: Declares `SkeletonHomeState`.
// Author: Knowticed Plus team
// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

part of './skeleton_home_controller.dart';

@immutable
sealed class SkeletonHomeState {}

final class SkeletonHomeInitial extends SkeletonHomeState {}

/// Emitted once the daily quote and the allowed module list are resolved.
///
/// A fresh instance is created on every emit so Cubit's equality check does not
/// deduplicate consecutive refreshes.
final class SkeletonHomeReady extends SkeletonHomeState {}
