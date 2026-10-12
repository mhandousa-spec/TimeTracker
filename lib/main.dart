
import 'package:knowticed_plus/core/services/restricted_location/restricted_location_guard.dart';
import 'package:knowticed_plus/core/one_time_fixes/activate_yousef_account.dart';
import 'package:knowticed_plus/core/theme/toggle_control.dart';
import 'dart:async';
import 'dart:io';

//
import 'package:cloud_firestore/cloud_firestore.dart';
// Scoped on purpose: this file only needs the delegate, and a bare import
// would drop Country / CountryService into a 900-line file's namespace.
import 'package:country_picker/country_picker.dart' show CountryLocalizations;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' hide Transition;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_storage/get_storage.dart';

import 'package:knowticed_plus/core/helper/main_helper/app_locale.dart';
import 'package:knowticed_plus/features/grc/grc_get_it.dart';
import 'package:knowticed_plus/features/todo/domain/base_repository/todo_base_repository.dart';
import 'package:knowticed_plus/features/todo/todo_get_it.dart';
// ADDED 8/10/2026 — Time Tracker DI (phase 1).
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/time_tracker_get_it.dart';
import 'package:knowticed_plus/features/grc/module/presentation/controller/cubit/grc_module_cubit.dart';

import 'package:knowticed_plus/features/notification/services/flutter_local_notification_handler.dart';
import 'package:knowticed_plus/core/theme/theme_controller.dart';

import 'package:knowticed_plus/features/onboarding/o3_authentication/presentation/controller/login_controller.dart';
import 'package:knowticed_plus/features/settings/se6_requests/presentation/controller/request_controller.dart';
import 'package:knowticed_plus/features/settings/se3_company/presentation/controller/company_cubit.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/presentation/controller/system_logs_controller.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/modules_cubit.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/helper/main_helper/device_policy_controller.dart';
import 'package:knowticed_plus/firebase/dev/firebase_options.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/pages/no_internet_screen.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/home_cubit.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/roles_home_stats_cubit.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/services_home_stats_cubit.dart';
import 'package:knowticed_plus/features/settings/se8_watermark/presentation/controller/watermark_cubit.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/app_bar_date.dart';
import 'package:knowticed_plus/features/onboarding/o1_splash/presentation/ui/pages/splash_screen.dart';
import 'package:knowticed_plus/features/home/main_controller/helper/events/events_stub.dart';
import './generated/l10n.dart';

GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();


// `@pragma('vm:entry-point')` is REQUIRED: FCM invokes this in a separate
// background isolate, and in release / obfuscated builds the tree-shaker would
// otherwise strip a function that has no visible caller — leaving background
// data messages silently unhandled. Firebase must be initialized WITH options
// here too; the background isolate does not share main()'s initialization.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FlutterLocalNotificationHandler.initialize();
  await FlutterLocalNotificationHandler.showNotification(message);
}

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = FlutterError.presentError;

    // Fonts: use the .ttf files bundled in google_fonts/ instead of fetching
    // from fonts.gstatic.com at runtime. Avoids a network round-trip on every
    // cold start and works offline / inside the macOS sandbox.
    GoogleFonts.config.allowRuntimeFetching = false;

    // intl date symbols for every supported locale. Loading these up-front is
    // what lets AppBarDate format Arabic dates without a defensive try/catch
    // in the widget (presentation/ui must not catch).
    await AppBarDate.ensureDateFormattingInitialized();

    // test
    // Firebase
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // Department data. Owned by main() and provided to the tree below via
    // BlocProvider.value. Also registered with Get for the moment because the
    // legacy MainCoreEmployeeController still resolves it that way; that
    // registration goes away with the employee-controller conversion.
    // Must be registered BEFORE MainCoreEmployeeController, which resolves it.
    final departmentCubit = MainCoreDepartmentCubit();
    Get.put(departmentCubit);

    // Core controllers
    Get.put(MainCoreEmployeeController());

    // GRC dependency injection. The module resolves everything through
    // GetIt.instance (data sources, repositories, use cases, cubits), so this
    // must run before the GRC tab is opened — otherwise GrcResponsivePageLayout
    // throws "GRCModuleCubit is not registered inside GetIt".
    // Guarded so a hot restart doesn't re-register the same lazy singletons.
    if (!GetIt.instance.isRegistered<GRCModuleCubit>()) {
      setupGRCDependencies(GetIt.instance);
    }

    // To-Do dependency injection (7/10/2026) — same guard, same reason.
    if (!GetIt.instance.isRegistered<TodoBaseRepository>()) {
      setupTodoDependencies(GetIt.instance);
    }

    // Time Tracker dependency injection (ADDED 8/10/2026) — same guard.
    if (!GetIt.instance.isRegistered<TimeTrackerAccess>()) {
      setupTimeTrackerDependencies(GetIt.instance);
    }

    // ScreenUtil
    await ScreenUtil.ensureScreenSize();

    // FCM (mobile only).
    //
    // FIXED: the guard was `!isWindows && !isLinux && !isMacOS && !isIOS`,
    // which is TRUE only on Android — so iOS was excluded from the entire push
    // setup. On iOS this block is what asks the user for notification
    // permission (without it APNs is never authorised and no push arrives),
    // registers the background handler, and forwards foreground messages to a
    // local notification. iOS subscribes to its topic at login just like
    // Android (see login_controller `_warmUpSessionData`), so leaving it out
    // here meant iOS users were subscribed but could never receive anything.
    // Now gated positively to the two mobile platforms.
    // `kIsWeb` first: `Platform` (dart:io) throws on web (7/10/2026).
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      await FlutterLocalNotificationHandler.initialize();
      await FirebaseMessaging.instance.requestPermission();
      FirebaseMessaging.onMessage.listen((msg) {
        FlutterLocalNotificationHandler.showNotification(msg);
      });
    }

    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

    // Storage
    await GetStorage.init();
    // ONE-TIME FIX 28/9/2026 — remove with lib/core/one_time_fixes/activate_yousef_account.dart
    unawaited(activateYousefAccountOnce());
    await Future.delayed(const Duration(milliseconds: 150));

    // Locale.
    //
    // CHANGED: this used to read GetStorage['LocaleData'] inline and call
    // `S.load(Locale('ar'))` — language only. `MyApp.build` then read the same
    // key and built `Locale('ar', 'EG')`, and the language picker used
    // `Locale('ar', 'SA')`. Three different tags for one language meant
    // `Intl.defaultLocale` differed depending on whether you booted into
    // Arabic or switched into it. AppLocale is now the only thing that decides.
    await AppLocale.restore();

    // Device policy (Take Screen Shot / Restricted Location / Screen Share).
    // Registered here rather than only in settings_layout so the screenshot
    // block is applied at boot: a device left with the switch off must be
    // protected from the first frame, not from the first time Settings opens.
    // Needs GetStorage.init() above — the controller reads its flags from it.
    final devicePolicyController = Get.put(DevicePolicyController());
    unawaited(devicePolicyController.applyScreenCapturePolicy());

    // Register controllers needed early (before splash screen navigation)
    Get.put(SystemLogsController());
    // RequestController must be registered before LoginController, whose
    // constructor calls Get.find<RequestController>().
    Get.lazyPut(() => RequestController());
    // ScheduleController (home screen) calls Get.find for this stub controller
    // in its constructor, so register it here before any home screen builds.
    // (To-dos now come from the To-Do module via get_it — no GetX controller.)
    Get.lazyPut(() => EventsEmployeeController());

    // Company branding cubit.
    // Created here rather than by a root BlocProvider because ThemeController
    // is constructed before runApp() and depends on it (and the cubit calls
    // back into themeController.update*). Same pattern as themeCubit below:
    // owned here, exposed to the widget tree via BlocProvider.value in MyApp.
    final companyCubit = Get.put(CompanyCubit());

    Get.lazyPut(() => LoginController(companyCubit));

    // Theme — company cubit injected explicitly so ThemeController never has
    // to reach into the service locator for it.
    final themeController = Get.put(ThemeController(companyCubit: companyCubit));
    // ✅ FIX: ModulesCubit (was ModulesController) was never registered (Knowticed_plus registers
    // it in main.dart). Without it, Get.find<ModulesCubit>() threw in
    // the "Add New Role" page and it showed "No modules available".
    Get.put(ModulesCubit());
    final themeCubit = Get.put(ThemeAndLocalizationsCubit());

    // Mirrors the old CompanyController.onInit(), which loaded the company in
    // an addPostFrameCallback so the first frame isn't blocked on Firestore.
    WidgetsBinding.instance.addPostFrameCallback((_) => companyCubit.bootstrap());

    await Future.delayed(const Duration(seconds: 2));
    FlutterNativeSplash.remove();

    runApp(MyApp(themeCubit, themeController, companyCubit, departmentCubit));
  }, (Object error, StackTrace stack) {
    // Last-resort sink for uncaught async errors. This previously did
    // `print('App error: ...')`; stripping that would have left an empty
    // handler that swallows every uncaught error in the app, so route it to
    // Flutter's own reporter instead (debug console in debug builds, and the
    // hook a crash reporter would attach to in release).
    FlutterError.reportError(FlutterErrorDetails(
      exception: error,
      stack: stack,
      library: 'knowticed_plus',
      context: ErrorDescription('uncaught async error in runZonedGuarded'),
    ));
  });
}

class MyApp extends StatelessWidget {
  MyApp(this.themeCubit, this.themeController, this.companyCubit,
      this.departmentCubit,
      {super.key});

  final ThemeAndLocalizationsCubit themeCubit;
  final ThemeController themeController;
  final CompanyCubit companyCubit;

  /// Owned by main() (see comment there); exposed to the tree via
  /// BlocProvider.value in build().
  final MainCoreDepartmentCubit departmentCubit;

  Size _getDesignSize(double w, double h) {
    if (w >= 1920) return const Size(1920, 1080);
    if (w >= 1366) return const Size(1366, 768);
    if (w >= 768) return w > h ? const Size(1024, 768) : const Size(768, 1024);
    return w > h ? const Size(812, 375) : const Size(375, 812);
  }

  @override
  Widget build(BuildContext context) {
    // CHANGED: was a second, independent read of GetStorage['LocaleData'] that
    // built `Locale('ar', 'EG')` — a different country code from both the
    // `S.load` in main() and the `Get.updateLocale` in the language picker.
    // One source now, so the tag the tree resolves against is the tag every
    // other locale-aware API was given.
    final targetLocale = AppLocale.current;

    return LayoutBuilder(
      builder: (context, constraints) {
        final mq = MediaQuery.of(context);
        final w = mq.size.width > 0 ? mq.size.width : constraints.maxWidth;
        final h = mq.size.height > 0 ? mq.size.height : constraints.maxHeight;

        return ScreenUtilInit(
          minTextAdapt: true,
          splitScreenMode: true,
          ensureScreenSize: true,
          designSize: _getDesignSize(w, h),
          child: MultiBlocProvider(
            providers: [
              BlocProvider.value(value: themeCubit),
              // Company branding/info. Owned by main() (see comment there),
              // provided by value so the whole widget tree can read it.
              BlocProvider.value(value: companyCubit),
              // Root-level AppHomeCubit — HomeScreenMobile (mobile nav Home tab)
              // reads it via context.read<AppHomeCubit>(), same as Knowticed.
              // init() replaces the old constructor side-effects. The locale is
              // not available this high in the tree, so HomeResponsivePage
              // calls initFor(context) to re-resolve the localized quote.
              BlocProvider<AppHomeCubit>(create: (_) => AppHomeCubit()..init()),
              // Department lookups, read across the app via
              // context.read<MainCoreDepartmentCubit>().
              BlocProvider.value(value: departmentCubit),
              // Counts behind the four Roles home cards (Role Management /
              // User Management / User Access / User Management Requests).
              //
              // Root-level because those cards appear on the home page and in
              // the Adding Widget picker, neither of which sits under the
              // roles routes — so RoleCubit, UserManagementAccessCubit and
              // UserAccessCubit are all out of scope there. This holds only
              // the numbers; see roles_home_stats_cubit.dart.
              //
              // No `..load()`: BlocProvider is lazy, and the cards call
              // ensureLoaded() themselves, so an account that never opens Home
              // or the picker never touches Firestore for this.
              BlocProvider<RolesHomeStatsCubit>(
                create: (_) => RolesHomeStatsCubit(),
              ),
              // The same arrangement for the Services home cards, and for the
              // same reason: ServicesManagerCubit is provided by the services
              // module's own composition root and DashboardMasterCubit is owned
              // by a single page, so neither is in scope on Home or in the
              // picker. See services_home_stats_cubit.dart.
              //
              // Lazy and ensureLoaded()-driven, exactly like the Roles one.
              BlocProvider<ServicesHomeStatsCubit>(
                create: (_) => ServicesHomeStatsCubit(),
              ),
              // The company-wide watermark. Root-level for two reasons: every
              // WatermarkLayer in the app reads ONE instance, so the settings
              // are fetched once rather than per page; and the editor writes to
              // that same instance, so saving restamps every open screen
              // immediately instead of on next launch.
              //
              // Lazy, and the layers call ensureLoaded() — an account that
              // never opens a watermarked page never reads the document.
              BlocProvider<WatermarkCubit>(create: (_) => WatermarkCubit()),

          // Knowledge Hub dashboard. Provided at the root (same as the
          // master app) so the home-page knowledge widgets and the module's
          // own screens all read one shared instance.



            ],
            child: GetBuilder<ThemeController>(
              builder: (controller) => GetMaterialApp(
                scrollBehavior: const MaterialScrollBehavior().copyWith(scrollbars: false),
                navigatorKey: globalNavigatorKey,
                theme: controller.currentTheme.value,
                defaultTransition: Transition.fadeIn,
                transitionDuration: const Duration(milliseconds: 300),
                supportedLocales: const [Locale('en'), Locale('ar')],
                localizationsDelegates: const [
                  S.delegate,
                  // Gives country_picker its Arabic country names. Without this
                  // delegate `CountryLocalizations.of(context)` is null and the
                  // country dropdown in settings falls back to English even in
                  // the Arabic UI.
                  CountryLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                locale: targetLocale,
                fallbackLocale: const Locale('en', 'US'),
                debugShowCheckedModeBanner: false,
                // Connectivity is an OVERLAY, not a gate.
                //
                // Previously this returned `SplashScreen()` or `NoInternetScreen`
                // and ignored `child`, so every connectivity event built a brand
                // new SplashScreen — re-running its initState (Get.find<LoginController>,
                // biometrics check, pushReplacement) and restarting the login flow
                // mid-authentication. It also meant a single spurious
                // `ConnectivityResult.none` at startup (common on macOS, where
                // connectivity_plus reports interface presence rather than real
                // reachability) replaced the whole app with the offline screen.
                //
                // Now `child` is passed straight through — the app subtree is
                // built once and preserved — and being offline only stacks a
                // banner on top.
                home: OfflineBuilder(
                  connectivityBuilder: (ctx, connectivity, child) {
                    // flutter_offline 6 reports a LIST of active interfaces.
                    final bool connected =
                        !connectivity.contains(ConnectivityResult.none);
                    if (connected) return child;
                    return Stack(
                      children: [
                        child,
                        const Align(
                          alignment: Alignment.topCenter,
                          child: NoInternetBanner(),
                        ),
                      ],
                    );
                  },
                  child: const SplashScreen(),
                ),
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(
                      MediaQuery.of(context).textScaleFactor.clamp(1.0, 1.2),
                    ),
                  ),
                  // ADDED 28/9/2026 — the Restricted Location block screen
                  // sits over EVERY route, so a restricted employee cannot
                  // reach any page from outside their role's countries.
                  child: RestrictedLocationOverlay(child: child!),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}


// ─── Notification tap handlers (stubs) ───────────────────────────────────────
Future<void> onTapOnNotificationMobile(String? payload, context) async {}
Future<void> onTapOnNotificationTablet(String? payload, context) async {}
