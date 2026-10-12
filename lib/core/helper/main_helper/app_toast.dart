/// Module: core/helper/main_helper
///
///*************************** FILE INFO ****************************///
/// File Name: app_toast.dart
/// Purpose: Platform-safe wrapper around Fluttertoast.
/// Author: Knowticed Plus team
/// Created at: 2/9/2026
///
/// `fluttertoast` ships Android, iOS and Web only — it has **no macOS,
/// Windows or Linux implementation**, which you can confirm in
/// `macos/Flutter/GeneratedPluginRegistrant.swift`: it is not registered there.
/// Calling `Fluttertoast.showToast` on desktop therefore throws
///
///     MissingPluginException(No implementation found for method showToast on
///     channel PonnamKarthik/fluttertoast)
///
/// as an uncaught async error. That is bad anywhere, and actively harmful in an
/// error handler: the toast reporting a failure blows up and hides the failure
/// it was reporting. That is exactly what happened with the chat recorder.
///
/// Use [AppToast.show] instead of `Fluttertoast.showToast` everywhere. On the
/// supported platforms it is the same toast; on desktop it logs instead of
/// throwing.

import 'dart:io' show Platform;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

abstract final class AppToast {
  const AppToast._();

  /// True only where `fluttertoast` actually has an implementation.
  static bool get isSupported =>
      kIsWeb || Platform.isAndroid || Platform.isIOS;

  /// Function Name: [show]
  ///
  /// Purpose: show [message] as a toast where the plugin exists, and log it
  ///          otherwise. Never throws.
  ///
  /// Parameters:
  ///           [String][message] : the text to show
  ///           [Color?][backgroundColor] : defaults to AppColors.primary
  ///           [Color?][textColor] : defaults to the contrasting text colour
  static void show(
    String message, {
    Color? backgroundColor,
    Color? textColor,
    Toast toastLength = Toast.LENGTH_SHORT,
  }) {
    if (!isSupported) {
      // Desktop has no toast surface here. Losing the text silently is worse
      // than a log line — this is usually an error message.
      debugPrint('[AppToast] $message');
      return;
    }

    // Still guarded: a plugin can be missing at runtime even on a supported
    // platform (an old host app, a partial build), and this must never be the
    // thing that crashes an error path.
    try {
      Fluttertoast.showToast(
        msg: message,
        toastLength: toastLength,
        backgroundColor: backgroundColor ?? AppColors.primary,
        textColor: textColor ?? AppTheme.contrastColor(),
      );
    } catch (e) {
      debugPrint('[AppToast] $message (toast failed: $e)');
    }
  }
}
