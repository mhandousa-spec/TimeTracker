import 'package:flutter/material.dart';

class FormBuilderNavigatorService {
  // ✅ Singleton pattern
  static final FormBuilderNavigatorService _instance = FormBuilderNavigatorService._internal();
  factory FormBuilderNavigatorService() => _instance;
  FormBuilderNavigatorService._internal();

  // Navigator key.
  //
  // NOT final and NOT owned here any more. This service is a process-wide
  // singleton, so a single app-lifetime GlobalKey used to be attached to the
  // form-builder Navigator forever. When two instances of the form-builder
  // page were briefly alive at once — during a GetX page transition, or when
  // the page is re-entered before the previous one finished disposing — both
  // Navigators claimed this one key, and Flutter threw
  // "'_elements.contains(element)': is not true" and painted the red error box.
  //
  // Each page mount now creates its OWN key and calls [bindNavigatorKey], so
  // no two live Navigators ever share a key, while the helper methods below
  // keep driving whichever form-builder Navigator is currently on screen.
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Point the service at the currently-mounted form-builder Navigator.
  /// Called from the page's initState with a key unique to that mount.
  void bindNavigatorKey(GlobalKey<NavigatorState> key) {
    navigatorKey = key;
  }

  // ✅ Helper methods
  NavigatorState? get currentState => navigatorKey.currentState;

  bool get isReady => currentState != null;

  Future<T?>? navigateTo<T>(String routeName, {Object? arguments}) {
    if (currentState != null) {
      return currentState!.pushNamed<T>(routeName, arguments: arguments);
    }
    
    return null;
  }

  void pop<T>([T? result]) {
    if (currentState != null && currentState!.canPop()) {
      currentState!.pop(result);
    }
  }

  void popToFirst() {
    if (currentState != null) {
      currentState!.popUntil((route) => route.isFirst);
    }
  }
}