/// Module: home/h2_nav_bar
///
///*************************** FILE INFO ****************************///
/// File Name: nav_bar.dart
/// Purpose: Declares `NavScreen`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

// Stub NavScreen — mobile nav bar not fully included in knowticed.
import 'package:knowticed_plus/core/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/home/h2_nav_bar/presentation/ui/pages/more_page.dart';
import 'package:knowticed_plus/features/home/h2_nav_bar/presentation/controller/nav_bar_cubit.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/presentation/controller/system_logs_controller.dart';


export 'package:knowticed_plus/features/home/h2_nav_bar/presentation/ui/pages/more_page.dart';

// Global accessor used by event controllers — lazy so it resolves after registration
SystemLogsController get systemLogsController => Get.find<SystemLogsController>();

// GRC theme controller global used by tracking/attendance components
ThemeController themeController = Get.put(ThemeController());

class NavScreen extends StatelessWidget {
  const NavScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // MorePage (and CustomAppBarMobile) call Get.find<NavBarCubit>(),
    // so make sure it is registered before they build.
    if (!Get.isRegistered<NavBarCubit>()) {
      Get.put(NavBarCubit());
    }
    return const MorePage();
  }
}
