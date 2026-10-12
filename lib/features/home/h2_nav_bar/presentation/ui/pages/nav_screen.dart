/// Module: home/h2_nav_bar
///
///*************************** FILE INFO ****************************///
/// File Name: nav_screen.dart
/// Purpose: Declares `NavScreen`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

// Date Created :16/july/2023
// Developer Name : Mazen sha//App Version : Version 1
// Date of Last Edit :18/july/2023
// Objectives: this class named NavScreen created for controlling the new navbar package with styling and
// the icons and screens that open on Tap navigation bar

// ignore_for_file: unrelated_type_equality_checks, deprecated_member_use, must_be_immutable, sdk_version_since, await_only_futures, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/home/h2_nav_bar/presentation/ui/widgets/custom_appbar.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/home/h2_nav_bar/presentation/controller/nav_bar_cubit.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/core/theme/theme_controller.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/pages/no_internet_screen.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/presentation/controller/system_logs_controller.dart';
import 'package:knowticed_plus/main.dart';
import 'package:knowticed_plus/features/home/h2_nav_bar/persistent_nav_bar.dart';
import 'package:knowticed_plus/core/custom/33-custom_haptic.dart';
import 'package:knowticed_plus/core/helper/main_helper/role_access.dart';

class NavScreen extends StatefulWidget {
  const NavScreen({super.key});

  @override
  State<NavScreen> createState() => _NavScreenState();
}

final ThemeController themeController = Get.put(ThemeController());
SystemLogsController systemLogsController = Get.find();

class _NavScreenState extends State<NavScreen> {
  double screenWidth = WidgetsBinding
      .instance.platformDispatcher.views.first.physicalSize.width /
      WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
  NavBarCubit navBarController = Get.put(NavBarCubit());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      themeController.initTheme();
    });

    screenWidth > 600
        ? SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ])
        : SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);

  }

  int currentIndex = 0;

  void onScreenChanged(int index) {
    if (index != currentIndex) {
      FocusScope.of(context).unfocus();
      currentIndex = index;
      setState(() {});
    }
  }


  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final bool isTabletView = MediaQuery.of(context).size.shortestSide > 600;
    var lightMode = Theme.of(context).brightness == Brightness.light;

    return OfflineBuilder(
        connectivityBuilder: (
            BuildContext context,
            List<ConnectivityResult> connectivity,
            Widget child,
            ) {
          bool connected = !connectivity.contains(ConnectivityResult.none);
          return Stack(
            children: [
              child,
              if (!connected)
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black.withOpacity(0.5),
                    child: const NoInternetScreen(
                        backgroundColor: AppColors.transparent),
                  ),
                ),
            ],
          );
        },
        child: BlocBuilder<NavBarCubit, NavBarState>(
          bloc: Get.find<NavBarCubit>(),
          builder: (context, _) {
            final controller = Get.find<NavBarCubit>();
            // ✅ CRITICAL FIX: Show loading screen while modules are being loaded
            if (controller.isLoadingModules || controller.navBarModules.length < 2) {
              return Scaffold(
                appBar: AppBar(
                  title: Text('Loading...'),
                  automaticallyImplyLeading: false,
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Loading modules...',
                        style: TextStyle(
                          fontSize: 16,
                          color: lightMode ? Colors.black : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // ✅ Now it's safe to build the NavBar
            final screens = controller.navBarItems;


            return Scaffold(
              body: ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: PersistentTabView(
                  popAllScreensOnTapOfSelectedTab: true,
                  context,
                  screens: screens,
                  items: [
                    for (int i = 0; i < controller.navBarModules.length; i++)
                      PersistentBottomNavBarItem(
                          // Role QA p.2: the SVGs filled the whole item height
                          // (IconTheme's size does not apply to SvgPicture), so
                          // the bar icons looked oversized. Fixed at 24.
                          icon: SvgPicture.asset(
                            controller.navBarIcons[i],
                            color: AppColors.primary,
                            width: 24,
                            height: 24,
                          ),
                          inactiveIcon: SvgPicture.asset(
                            width: 24,
                            height: 24,
                            color: themeController.currentTheme ==
                                AppColors.lightTheme
                                ? null
                                : AppColors.colorWhite,
                            controller.navBarIcons[i],
                          ),
                          title: (controller.navBarTitles[i]),
                          activeColorPrimary: AppColors.primary,
                          inactiveColorPrimary:
                          themeController.currentTheme == AppColors.lightTheme
                              ? AppColors.colorGreyDark
                              : AppColors.colorWhite
                      )
                  ],
                  controller: RoleAccess.controller,
                  navBarHeight: orientation == Orientation.portrait
                      ? isTabletView
                      ? 0.065.h
                      : 0.085.h >= 60
                      ? 0.085.h
                      : 60
                      : 0.08.h,
                  confineInSafeArea: true,
                  hideNavigationBarWhenKeyboardShows: true,
                  popActionScreens: PopActionScreensType.all,
                  resizeToAvoidBottomInset: true,
                  backgroundColor: lightMode ? AppColors.background : AppColors.chatBackground,
                  itemAnimationProperties: const ItemAnimationProperties(
                    duration: Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                  ),
                  screenTransitionAnimation: const ScreenTransitionAnimation(
                    animateTabTransition: true,
                    curve: Curves.easeInOutCubicEmphasized,
                    duration: Duration(milliseconds: 450),
                  ),
                  navBarStyle: NavBarStyle.style3,
                  onItemSelected: (index) {
                    // when open item tapped return to the first screen
                    Navigator.popUntil(context, (route) => route.isFirst);

                    hapticController.triggerHapticFeedback(
                        vibration: VibrateType.lightImpact,
                        hapticFeedback: HapticFeedback.lightImpact);
                    index == 0
                        ? systemLogsController.systemLogsAction('home')
                        : index == 1
                        ? systemLogsController.systemLogsAction('employees')
                        : index == 2
                        ? systemLogsController.systemLogsAction('roles')
                        : index == 3
                        ? systemLogsController.systemLogsAction('todo')
                        : index == 4
                        ? systemLogsController
                        .systemLogsAction('task')
                        : null;
                  },
                  padding: NavBarPadding.symmetric(
                      horizontal: orientation == Orientation.portrait
                          ? isTabletView
                          ? 0.1.w
                          : 0.001.w
                          : 0.2.w),
                ),
              ),
            );
          },
        ));
  }
}
