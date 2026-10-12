/// Module: home/h3_app_drawer
///
///*************************** FILE INFO ****************************///
/// File Name: custom_drawer.dart
/// Purpose: Declares `CustomDrawer`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/core/helper/inventory_module/core/svg_custom.dart';
import 'package:animated_reorderable_list/animated_reorderable_list.dart';

import 'package:knowticed_plus/core/theme/haptic_controller.dart';

import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/presentation/ui/pages/sign_in_screen.dart';
import 'package:knowticed_plus/core/custom/70-custom_appbar.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/skeleton/employees/employees_views/employee_attendance.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/feature/notification/notification_screen.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/skeleton/authentication/welcome_screen/views/mobile_view/nav_bar.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/skeleton/authentication/welcome_screen/views/start_sign_in.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/core/helper/inventory_module/core/navigate.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/home_cubit.dart';
import 'package:knowticed_plus/main.dart';
import 'package:knowticed_plus/core/theme/theme_controller.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/pages/no_internet_screen.dart';
import 'package:page_transition/page_transition.dart';

// REMOVED_MODULE: import '../../../../../external/calender/calendar_screen.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/pages/notification_page.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/pages/clear_page_notification.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/pages/pin_notification.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/ui/pages/role_management_home.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/controller/settings_controller.dart';
import 'package:knowticed_plus/core/custom/33-custom_haptic.dart';
import '../../controller/app_drawer_cubit.dart';
import 'package:get_storage/get_storage.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/presentation/controller/system_logs_controller.dart';
import 'package:knowticed_plus/features/onboarding/o2_intro/presentation/ui/pages/onboarding.dart';
import 'package:knowticed_plus/features/home/h3_app_drawer/data/utils/app_drawer_update_ids.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/home/h3_app_drawer/presentation/controller/app_drawer_cubit.dart';
import 'package:knowticed_plus/features/home/h3_app_drawer/presentation/ui/widgets/drawer_logo_container.dart';
import 'package:knowticed_plus/features/home/h3_app_drawer/presentation/ui/widgets/drawer_menu_item.dart';
import 'package:knowticed_plus/features/settings/se8_watermark/presentation/ui/widgets/watermark_layer.dart';

class CustomDrawer extends StatefulWidget {
  CustomDrawer({
    Key? key,
  }) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final ThemeController themeController = Get.find<ThemeController>();
  final SystemLogsController systemLogsController = Get.find<SystemLogsController>();
  final GetStorage storage = GetStorage();
  AppDrawerCubit appDrawerController = Get.put(AppDrawerCubit());
  List<Widget> screens = [];
  int? draggingIndex;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    appDrawerController.reload();
    var settings = Get.put(SettingsController());
    settings.onInit();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      themeController.initTheme();
    });
    screens = appDrawerController.drawerItems;
    appDrawerController.loadAppVersion();
  }

  @override
  void didUpdateWidget(covariant CustomDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screens = appDrawerController.drawerItems;
  }

  int get settingsModuleIndex {
    for (int i = 0; i < appDrawerController.drawerTitles.length; i++) {
      if (appDrawerController.drawerTitles[i].toLowerCase() == 'settings' ||
          appDrawerController.drawerTitles[i].toLowerCase() == 'الإعدادات') {
        return i;
      }
    }
    return -1;
  }

  bool get isReorderingEnabled {
    return settingsModuleIndex != -1 &&
        appDrawerController.selectedIndex == settingsModuleIndex &&
        appDrawerController.isReorderingActive;
  }

  void _onItemTapped(int index) {
    if (appDrawerController.isReorderingActive) return;

    hapticController.triggerHapticFeedback(
        vibration: VibrateType.lightImpact,
        hapticFeedback: HapticFeedback.lightImpact);

    if (index == appDrawerController.allowedDrawerModules.length) {
      // MIGRATED 22/8/2026: was `CustomLogOutDialogBox`, a one-off dialog
      // widget that duplicated what CustomDialogManager already does — and did
      // it worse: it ignored the `title` and `subtitle` it was handed and
      // printed its own hardcoded ones, took a non-localized `buttonText`, and
      // had no success step. That widget's file is deleted; every confirm flow
      // in the app goes through the one manager now.
      CustomDialogManager.showDialogFlow(
        context: context,
        confirmLottie: 'assets/lottie_assets/home_lottie_assets/newLogOut.json',
        confirmTitle: S.of(context).logout,
        confirmSubtitle: S.of(context).confirmLogout,
        confirmYesText: S.of(context).yes,
        confirmNoText: S.of(context).Cancel,
        onConfirm: () async {
          hapticController.triggerHapticFeedback(
              vibration: VibrateType.heavyImpact,
              hapticFeedback: HapticFeedback.heavyImpact);
          systemLogsController.systemLogsAction('logout');
          return true;
        },
        // No "signed out successfully" dialog: the sign-in screen appearing
        // IS the confirmation, and the extra dialog just added a tap.
        showSuccessDialog: false,
        successLottie: 'assets/lottie_assets/main_lottie_assets/successful.json',
        successTitle: S.of(context).logout,
        successSubtitle: S.of(context).signedOutSuccessfully,
        // Navigation runs after the success dialog closes, so sign-in is not
        // pushed underneath it.
        //
        // FIXED 22/8/2026: this used to land on `Onboarding()` — the intro
        // carousel — so signing out replayed the eight welcome slides. The
        // mobile More tab already went to SignInScreen; both agree now.
        onSuccessComplete: () {
          if (!context.mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              child: const SignInScreen(),
            ),
            (Route<dynamic> route) => false,
          );
        },
      );
    } else {
      appDrawerController.updateSelectedIndex(index);
      String moduleName =
      appDrawerController.drawerTitles[index].toLowerCase();
      if (moduleName.contains('home') || moduleName.contains('الرئيسية')) {
        systemLogsController.systemLogsAction('home');
      } else if (moduleName.contains('task') || moduleName.contains('مهام')) {
        systemLogsController.systemLogsAction('tasks');
      } else if (moduleName.contains('database') ||
          moduleName.contains('قاعدة البيانات')) {
        systemLogsController.systemLogsAction('database');
      } else if (moduleName.contains('employee') ||
          moduleName.contains('موظف')) {
        systemLogsController.systemLogsAction('employees');
      } else if (moduleName.contains('inventory') ||
          moduleName.contains('مخزون')) {
        systemLogsController.systemLogsAction('inventory management');
      } else if (moduleName.contains('role') ||
          moduleName.contains('صلاحيات')) {
        systemLogsController.systemLogsAction('roles');
      } else if (moduleName.contains('to do') ||
          moduleName.contains('قائمة')) {
        systemLogsController.systemLogsAction('to do list');
      } else if (moduleName.contains('request') ||
          moduleName.contains('طلبات')) {
        systemLogsController.systemLogsAction('requests');
      } else if (moduleName.contains('setting') ||
          moduleName.contains('إعدادات')) {
        systemLogsController.systemLogsAction('settings');
      } else if (moduleName.contains('service') ||
          moduleName.contains('خدمات')) {
        systemLogsController.systemLogsAction('services');
      }
    }
  }

  void _moveItem(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;

    setState(() {
      final modules =
      List<Modules>.from(appDrawerController.allowedDrawerModules);
      final item = modules.removeAt(oldIndex);
      modules.insert(newIndex, item);

      appDrawerController.saveCustomOrder(modules);
      screens = appDrawerController.drawerItems;

      if (appDrawerController.selectedIndex == oldIndex) {
        appDrawerController.updateSelectedIndex(newIndex);
      } else if (oldIndex < appDrawerController.selectedIndex &&
          newIndex >= appDrawerController.selectedIndex) {
        appDrawerController
            .updateSelectedIndex(appDrawerController.selectedIndex - 1);
      } else if (oldIndex > appDrawerController.selectedIndex &&
          newIndex <= appDrawerController.selectedIndex) {
        appDrawerController
            .updateSelectedIndex(appDrawerController.selectedIndex + 1);
      }
    });

    hapticController.triggerHapticFeedback(
        vibration: VibrateType.mediumImpact,
        hapticFeedback: HapticFeedback.mediumImpact);
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final background = Theme.of(context).colorScheme.inversePrimary;
    final orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return OfflineBuilder(
      connectivityBuilder:
          (BuildContext context, List<ConnectivityResult> connectivity,
              Widget child) {
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
      child: BlocProvider<AppHomeCubit>(
        // init() replaces the old constructor side-effects; HomeResponsivePage
        // later calls initFor(context) to localize the quote.
        create: (context) => AppHomeCubit()..init(),
        child: Scaffold(
          // ── Watermark ──────────────────────────────────────────────────
          // ADDED 26/8/2026, and wrapped HERE — around the whole shell body —
          // rather than around each page.
          //
          // WatermarkLayer was already applied at HomeResponsivePage,
          // RoleScreenHost and the settings shell, but all three of those sit
          // in the CONTENT column of the Row below. That left the two things a
          // screenshot most obviously identifies untouched: the 90.sp sidebar
          // on the leading edge and the CustomAppBar across the top. Wrapping
          // the body means the stamp covers the sidebar, the app bar and the
          // content in one pass, on every module the shell hosts — home,
          // settings, roles, the notification pages, all of them.
          //
          // The inner layers do NOT need removing and are NOT drawn twice:
          // WatermarkLayer publishes a _WatermarkScope and any descendant
          // layer hands its child straight back. The outermost one wins, which
          // is now this one. See watermark_layer.dart.
          //
          // Inside the Scaffold rather than around it, so the layer is laid
          // out against the body's bounded constraints.
          //
          // CHANGED 28/9/2026 (Settings bug report p.1 — "watermark must show
          // only in modules user choose"). This layer used to omit `module`,
          // which means ALWAYS STAMP, and because it is the OUTERMOST layer it
          // won over every module-aware layer inside it — so un-ticking a tile
          // in the Watermark Modules grid changed nothing on desktop/tablet.
          // It now passes the module the sidebar has selected, so the grid
          // decides. The notification pages (indices past the module list)
          // have no tile and keep the always-stamp default.
          body: BlocBuilder<AppDrawerCubit, AppDrawerState>(
            bloc: Get.find<AppDrawerCubit>(),
            builder: (context, _) => WatermarkLayer(
            module: _selectedWatermarkModule(),
            child: Container(
            color: AppColors.card,
            child: BlocBuilder<AppDrawerCubit, AppDrawerState>(
              bloc: Get.find<AppDrawerCubit>(),
              builder: (context, _) {
                final controller = Get.find<AppDrawerCubit>();
                screens = appDrawerController.drawerItems;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 90.sp,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(0.r),
                          bottomRight: Radius.circular(0.r),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildLogoContainer(orientation),
                            ],
                          ),
                          SizedBox(height: 5.h),
                          Expanded(
                            child: _buildMenuItems(orientation),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: orientation ? 10.h : 15.h),
                            child: _buildMenuItem(
                              orientation,
                              appDrawerController.allowedDrawerModules.length,
                              'assets/icons_assets/home_assets/logout_arrow.svg',
                              S.of(context).logOut,
                              isLogout: true,
                            ),
                          ),
                          if (appDrawerController.appVersion.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(
                                top: 8.h,
                                bottom: 12.h,
                              ),
                              child: Text(
                                appDrawerController.appVersion,
                                style: StyleText.fontSize12Weight500.copyWith(
                                  color: Theme.of(context).brightness ==
                                      Brightness.light
                                      ? AppColors.blackButton
                                      : AppColors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          CustomAppBar(),
                          if (controller.selectedIndex == 19)
                            Expanded(child: NotificationLandPage()),
                          if (controller.selectedIndex == 20)
                            Expanded(child: CleanedNotificationLandPage()),
                          if (controller.selectedIndex == 21)
                            Expanded(child: PinNotificationLandPage()),
                          if (controller.selectedIndex !=
                              appDrawerController
                                  .allowedDrawerModules.length &&
                              controller.selectedIndex != 18 &&
                              controller.selectedIndex != 19 &&
                              controller.selectedIndex != 20 &&
                              controller.selectedIndex != 21)
                            Expanded(
                              child: IndexedStack(
                                index: controller.selectedIndex,
                                children: screens,
                              ),
                            ),
                        ],
                      ),
                    )
                  ],
                );
              },
            ),
          ),
          ),
          ),
        ),
      ),
    );
  }

  /// The module the sidebar currently shows, for the watermark's per-module
  /// opt-out. Null (always stamp) for the notification pages, which sit past
  /// the end of the module list and have no tile in the Watermark grid.
  Modules? _selectedWatermarkModule() {
    final int index = appDrawerController.selectedIndex;
    final List<Modules> modules = appDrawerController.allowedDrawerModules;
    if (index < 0 || index >= modules.length) return null;
    return modules[index];
  }

  Widget _buildLogoContainer(bool orientation) =>
      DrawerLogoContainer(logoUrl: storage.read('logo') as String?);

  Widget _buildMenuItems(bool orientation) {
    return BlocBuilder<AppDrawerCubit, AppDrawerState>(
        bloc: appDrawerController,
        builder: (BuildContext context, AppDrawerState state) {
      final bool isReorderingActiveValue =
          appDrawerController.isReorderingActive;

      final isReordering = settingsModuleIndex != -1 &&
          appDrawerController.selectedIndex == settingsModuleIndex &&
          isReorderingActiveValue;

      if (isReordering) {
        return ScrollConfiguration(
          behavior:
          ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: AnimatedReorderableListView(
            controller: _scrollController,
            padding: EdgeInsets.only(left: 5.w),
            proxyDecorator:
                (Widget child, int index, Animation<double> animation) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Material(
                  elevation: 10,
                  color: AppColors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                  child: child,
                ),
              );
            },
            buildDefaultDragHandles: false,
            key: ValueKey(
                'reorderable_${appDrawerController.selectedIndex}_${appDrawerController.isReorderingActive}'),
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            items: appDrawerController.allowedDrawerModules,
            // ✅ KEY RULE: The key MUST always be on the ROOT widget returned
            // by itemBuilder. Here Padding is the root, so key goes on Padding.
            // Do NOT pass key to _buildMenuItem when Padding wraps it.
            itemBuilder: (context, i) {
              final itemKey = ValueKey(
                  '${appDrawerController.allowedDrawerModules[i]}_$i');
              return Padding(
                key: itemKey, // ✅ Key on root widget (Padding)
                padding:  EdgeInsets.only(top: 5.h,right: 20.w, left: 10.w),
                child: _buildMenuItem(
                  orientation,
                  i,
                  appDrawerController.drawerIcons[i],
                  appDrawerController.drawerTitles[i],
                  // ✅ No key here — Padding above owns the key
                ),
              );
            },
            enterTransition: [FadeIn(), ScaleIn()],
            exitTransition: [FadeIn(), ScaleIn()],
            insertDuration: const Duration(milliseconds: 300),
            removeDuration: const Duration(milliseconds: 300),
            dragStartDelay: const Duration(milliseconds: 300),
            onReorder: (oldIndex, newIndex) {
              _moveItem(oldIndex, newIndex);
            },
            isSameItem: (a, b) => a == b,
          ),
        );
      } else {
        return ScrollConfiguration(
          behavior:
          ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: ListView.builder(
            controller: _scrollController,
            key: PageStorageKey('drawer_list_view'),
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            itemCount: appDrawerController.allowedDrawerModules.length,
            itemBuilder: (context, i) {
              return _buildMenuItem(
                orientation,
                i,
                appDrawerController.drawerIcons[i],
                appDrawerController.drawerTitles[i],
                // ✅ Key on Obx (root) when no wrapper — this is correct
                key: ValueKey(
                    '${appDrawerController.allowedDrawerModules[i]}_$i'),
              );
            },
          ),
        );
      }
    });
  }

  Widget _buildMenuItem(
      bool orientation,
      int index,
      String iconPath,
      String title, {
        Key? key,
        bool isLogout = false,
      }) {
    // The key must sit on the root widget returned here: in reorder mode the
    // Padding wrapper owns it (key is null), in list mode this widget does.
    return DrawerMenuItem(
      key: key,
      cubit: appDrawerController,
      compact: orientation,
      index: index,
      iconPath: iconPath,
      title: title,
      isLogout: isLogout,
      onTap: _onItemTapped,
    );
  }
}
