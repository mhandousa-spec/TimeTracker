/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: no_internet_screen.dart
/// Purpose: Declares `NoInternetScreen`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Full-screen "no connection" state.
///
/// Was previously a [Dialog], but it is used as a route/page body
/// (`home:` in main.dart, `Scaffold.body` in the drawer and nav shell). A
/// Dialog outside `showDialog` renders as a floating card over a bare
/// background with no Scaffold, which is why it looked wrong. It is now a
/// proper Scaffold-based screen.
///
/// For the banner variant shown over live content see [NoInternetBanner].
class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key, this.backgroundColor});

  /// Defaults to the opaque app background. Pass [AppColors.transparent] when
  /// stacking this over live content behind a dimmed parent (see the nav shell
  /// and drawer), so the parent's translucent scrim stays visible.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.08.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: isTablet ? (isPortrait ? 2.5 : 1.5) : 1.2,
                  child: Lottie.asset(
                    "assets/lottie_assets/main_lottie_assets/internet.json",
                    width: isTablet ? 0.15.w : 0.3.w,
                    fit: BoxFit.fitHeight,
                  ),
                ),
                SizedBox(
                  height: isTablet && isPortrait
                      ? 0.15.h
                      : isTablet
                          ? 0.1.h
                          : 0.05.h,
                ),
                Text(
                  S.of(context).canTConnectCheckInternet,
                  textAlign: TextAlign.center,
                  style: AppFontStyle.cairoRegularStyle.copyWith(
                    fontSize: isTablet
                        ? (isPortrait
                            ? FontConstants.fontSize025.h
                            : FontConstants.fontSize032.h)
                        : FontConstants.fontSize020.h,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Slim offline banner shown *over* the running app.
///
/// Used by the connectivity gate in main.dart so a transient or incorrect
/// `ConnectivityResult.none` — common on macOS at startup, since
/// connectivity_plus reports interface presence rather than real reachability —
/// no longer replaces the whole app and restarts the splash/login flow.
class NoInternetBanner extends StatelessWidget {
  const NoInternetBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: SafeArea(
        child: Container(
          width: double.infinity,
          color: AppColors.red,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_rounded,
                  size: 16.sp, color: AppColors.textButton),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  S.of(context).canTConnectCheckInternet,
                  textAlign: TextAlign.center,
                  style: AppFontStyle.cairoRegularStyle.copyWith(
                    fontSize: FontConstants.fontSize014.h,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textButton,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
