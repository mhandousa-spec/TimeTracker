/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: home_responsive_page.dart
/// Purpose: Declares `HomeResponsivePage`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

/// Fixed HomeResponsivePage that properly handles resize
///
/// This widget:
/// 1. Detects when screen size changes
/// 2. Cleans up the wrong controller
/// 3. Shows the correct layout (mobile or tablet)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/home_cubit.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/pages/home_screen.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/70-custom_appbar.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/ui/pages/role_management_home.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/schedule_controller.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/skeleton_home_controller.dart';
import 'package:knowticed_plus/features/home/main_controller/helper/events/events_stub.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/settings/se8_watermark/presentation/ui/widgets/watermark_layer.dart';

// Import the controllers
import 'package:knowticed_plus/features/home/h3_app_drawer/presentation/controller/app_drawer_cubit.dart';
import 'package:knowticed_plus/features/home/h2_nav_bar/presentation/controller/nav_bar_cubit.dart';

GlobalKey homeNavKey = GlobalKey();

class HomeResponsivePage extends StatefulWidget {
  const HomeResponsivePage({super.key});

  @override
  State<HomeResponsivePage> createState() => _HomeResponsivePageState();
}

class _HomeResponsivePageState extends State<HomeResponsivePage> {
  bool? _wasTablet;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    if (!Get.isRegistered<SkeletonHomeController>()) {
      Get.put(SkeletonHomeController());
    }
    // ScheduleController's constructor calls Get.find() for this stub
    // controller, so it must be registered BEFORE it is created. (To-dos come
    // from the To-Do module through get_it.)
    if (!Get.isRegistered<EventsEmployeeController>()) {
      Get.put(EventsEmployeeController());
    }
    if (!Get.isRegistered<ScheduleController>()) {
      Get.put(ScheduleController());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Neither cubit does start-up work in its constructor any more, so the
    // page drives it. Safe to call repeatedly: init() runs once, later calls
    // only re-resolve the quote for the current locale.
    context.read<AppHomeCubit>().initFor(context);
    if (Get.isRegistered<SkeletonHomeController>()) {
      Get.find<SkeletonHomeController>().initFor(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Check if current size is tablet
    final isTablet = MediaQuery.of(context).size.width >= 768.0;

    // ✅ Detect size change
    if (_wasTablet != null && _wasTablet != isTablet) {

      // Clean up wrong controller after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleSizeChange(isTablet);
      });
    }

    _wasTablet = isTablet;

    // Single page now; HomeScreen branches on form factor internally.
    //
    // On tablet/desktop the home module sits inside the drawer shell's
    // IndexedStack, so a plain Navigator.push from here would cover the whole
    // window — sidebar and app bar included. Hosting a nested Navigator means
    // pages pushed from home (the Calendar screen, for example) render inside
    // the content area and keep the frame, which is the same pattern the
    // settings and services modules use.
    //
    // WATERMARK 25/8/2026. This widget is the whole of `Modules.home` —
    // `modules_enum.dart` builds exactly `HomeResponsivePage()` for every form
    // factor — so one wrap here stamps the home module everywhere it is
    // mounted. On the tablet branch the layer is deliberately ABOVE the nested
    // Navigator, which extends the stamp to every page pushed inside home
    // rather than just the landing screen.
    //
    // `module: Modules.home` ADDED 2/9/2026. Both layers used to omit it, which
    // means "always stamp" — so the Home tile added to the settings grid on the
    // same day would have controlled nothing. With it, Home is stamped only
    // while its tile is ticked.
    if (!isTablet) {
      return const WatermarkLayer(
        module: Modules.home,
        child: HomeScreen(),
      );
    }

    return WatermarkLayer(
      module: Modules.home,
      child: Navigator(
        key: homeNavKey,
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      ),
    );
  }

  void _handleSizeChange(bool isNowTablet) {

    if (isNowTablet) {
      // Switched to tablet - remove NavBarCubit
      if (Get.isRegistered<NavBarCubit>()) {
        Get.delete<NavBarCubit>(force: true);
      }

      // Initialize AppDrawerCubit if needed
      if (!Get.isRegistered<AppDrawerCubit>()) {
        Get.put(AppDrawerCubit());
      }
    } else {
      // Switched to mobile - remove AppDrawerCubit
      if (Get.isRegistered<AppDrawerCubit>()) {
        Get.delete<AppDrawerCubit>(force: true);
      }

      // Initialize NavBarCubit if needed
      if (!Get.isRegistered<NavBarCubit>()) {
        Get.put(NavBarCubit());
      }
    }

    // Force rebuild
    if (mounted) {
      setState(() {});
    }
  }
}