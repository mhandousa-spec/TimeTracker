/// Module: home/h2_nav_bar
///
///*************************** FILE INFO ****************************///
/// File Name: route_and_navigator_settings.dart
/// Purpose: Declares `RouteAndNavigatorSettings`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Extracted from the oversized model.dart as part of
///          breaking up the vendored persistent-nav-bar god files.

import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/home/h2_nav_bar/persistent_nav_bar.dart';

class RouteAndNavigatorSettings {
  const RouteAndNavigatorSettings({
    this.defaultTitle,
    this.routes,
    this.onGenerateRoute,
    this.onUnknownRoute,
    this.initialRoute,
    this.navigatorObservers = const <NavigatorObserver>[],
    this.navigatorKey,
  });
  final String? defaultTitle;

  final Map<String, WidgetBuilder>? routes;

  final RouteFactory? onGenerateRoute;

  final RouteFactory? onUnknownRoute;

  final String? initialRoute;

  final List<NavigatorObserver> navigatorObservers;

  final GlobalKey<NavigatorState>? navigatorKey;

  RouteAndNavigatorSettings copyWith({
    final String? defaultTitle,
    final Map<String, WidgetBuilder>? routes,
    final RouteFactory? onGenerateRoute,
    final RouteFactory? onUnknownRoute,
    final String? initialRoute,
    final List<NavigatorObserver>? navigatorObservers,
    final GlobalKey<NavigatorState>? navigatorKeys,
  }) =>
      RouteAndNavigatorSettings(
        defaultTitle: defaultTitle ?? this.defaultTitle,
        routes: routes ?? this.routes,
        onGenerateRoute: onGenerateRoute ?? this.onGenerateRoute,
        onUnknownRoute: onUnknownRoute ?? this.onUnknownRoute,
        initialRoute: initialRoute ?? this.initialRoute,
        navigatorObservers: navigatorObservers ?? this.navigatorObservers,
        navigatorKey: navigatorKey ?? navigatorKey,
      );
}
