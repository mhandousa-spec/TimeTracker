/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: theme_controller.dart
/// Purpose: Declares `ThemeController`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

// // ignore_for_file: sdk_version_since
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
//import 'package:knowticed_plus/core/theme/app_font_size.dart';
//import 'package:knowticed_plus/core/theme/app_colors.dart';
// import 'package:knowticed_plus/features/onboarding/o2_intro/presentation/ui/services_management_module/onboarding.dart';
// import 'package:knowticed_plus/features/settings/presentation/controller/company_controller.dart';
// import 'app_theme.dart';
//
// class ThemeController extends GetxController {
//   final storage = GetStorage();
//   late Rx<ThemeData> currentTheme;
//   final RxBool isInitialized = false.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     currentTheme = AppColors.lightTheme.obs;
//
//     // Load theme data synchronously first
//     _loadThemeDataSync();
//
//     // Then initialize theme systems
//     Future.microtask(() {
//       initTheme(withMessage: false);
//       isInitialized.value = true;
//     });
//
//     // Setup listener for system UI updates
//     ever(currentTheme, (_) {
//       if (isInitialized.value) {
//         Future.microtask(() => updateSystemUIOverlayStyle());
//       }
//     });
//   }
//
//   void _loadThemeDataSync() {
//     print('🎨 [ThemeController] Loading theme from storage...');
//
//     // Load theme mode
//     final savedTheme = storage.read('theme');
//
//     if (savedTheme != null) {
//       if (savedTheme == 'darkMode') {
//         currentTheme.value = AppColors.darkTheme;
//         AppTheme.isDark = true;
//         AppTheme.isDark = true; // ✅ Sync main core
//         print('🎨 [ThemeController] Loaded DARK theme from storage');
//       } else {
//         currentTheme.value = AppColors.lightTheme;
//         AppTheme.isDark = false;
//         AppTheme.isDark = false; // ✅ Sync main core
//         print('🎨 [ThemeController] Loaded LIGHT theme from storage');
//       }
//     } else {
//       currentTheme.value = AppColors.lightTheme;
//       AppTheme.isDark = false;
//       AppTheme.isDark = false; // ✅ Sync main core
//       print('🎨 [ThemeController] No saved theme, using LIGHT theme');
//     }
//
//     // Load and apply colors
//     final primaryColor = storage.read('primaryColor');
//     if (primaryColor != null) {
//       AppColors.lightPrimary = Color(int.parse(primaryColor));
//       AppColors.switchSettings = Color(int.parse(primaryColor));
//       print('🎨 [ThemeController] Loaded primary color: $primaryColor');
//     }
//
//     final secondaryColor = storage.read('secondaryColor');
//     if (secondaryColor != null) {
//       AppColors.signOut = Color(int.parse(secondaryColor));
//       AppColors.barColor = Color(int.parse(secondaryColor));
//       AppColors.bubbleColor = Color(int.parse(secondaryColor));
//       print('🎨 [ThemeController] Loaded secondary color: $secondaryColor');
//     }
//
//     // ✅ CRITICAL: Synchronize AppTheme with loaded state
//     AppTheme.setCurrentThemeColors();
//     AppTheme.setCurrentThemeColors(); // ✅ Sync main core colors
//
//     print('🎨 [ThemeController] Theme sync completed - isDark: ${AppTheme.isDark}');
//   }
//
//   void updateSystemUIOverlayStyle() {
//     if (Get.context != null) {
//       bool isTablet = MediaQuery.of(Get.context!).size.shortestSide > 600;
//       if (isTablet) {
//         updateSystemUIOverlayStyleTablet();
//       } else {
//         updateSystemUIOverlayStyleMobile();
//       }
//     }
//   }
//
//   void updateSystemUIOverlayStyleMobile() {
//     if (currentTheme.value == AppColors.lightTheme) {
//       SystemChrome.setSystemUIOverlayStyle(
//         SystemUiOverlayStyle(
//           statusBarColor: AppColors.colorLightGrey,
//           statusBarIconBrightness: Brightness.dark,
//           statusBarBrightness: Brightness.light,
//         ),
//       );
//     } else {
//       SystemChrome.setSystemUIOverlayStyle(
//         SystemUiOverlayStyle(
//           statusBarColor: AppColors.colorBlack,
//           statusBarIconBrightness: Brightness.light,
//           statusBarBrightness: Brightness.dark,
//         ),
//       );
//     }
//   }
//
//   void updateSystemUIOverlayStyleTablet() {
//     if (currentTheme.value == AppColors.lightTheme) {
//       SystemChrome.setSystemUIOverlayStyle(
//         SystemUiOverlayStyle(
//           statusBarColor: AppColors.colorWhite,
//           statusBarIconBrightness: Brightness.dark,
//           statusBarBrightness: Brightness.light,
//         ),
//       );
//     } else {
//       SystemChrome.setSystemUIOverlayStyle(
//         SystemUiOverlayStyle(
//           statusBarColor: AppColors.dark,
//           statusBarIconBrightness: Brightness.light,
//           statusBarBrightness: Brightness.dark,
//         ),
//       );
//     }
//   }
//
//   void toggleTheme() {
//     print('🎨 [ThemeController] Theme toggle started - Current: ${currentTheme.value == AppColors.lightTheme ? "Light" : "Dark"}');
//
//     // Toggle theme mode
//     if (currentTheme.value == AppColors.lightTheme) {
//       currentTheme.value = AppColors.darkTheme;
//       storage.write('theme', 'darkMode');
//       AppTheme.isDark = true;
//       AppTheme.isDark = true; // ✅ Sync main core
//       print('🎨 [ThemeController] Switched to DARK theme');
//     } else {
//       currentTheme.value = AppColors.lightTheme;
//       storage.write('theme', 'lightMode');
//       AppTheme.isDark = false;
//       AppTheme.isDark = false; // ✅ Sync main core
//       print('🎨 [ThemeController] Switched to LIGHT theme');
//     }
//
//     // Log action
//     systemLogsController.systemLogsAction('change theme');
//
//     // ✅ Update color maps
//     AppTheme.setCurrentThemeColors();
//     AppTheme.setCurrentThemeColors();
//     print('🎨 Color map updated - isDark: ${AppTheme.isDark}');
//
// // Log action
//     systemLogsController.systemLogsAction('change theme');
//
//
//
//
//     // ✅ CRITICAL: Update color maps BEFORE toggling other modules
//     print('🎨 [ThemeController] Updating color maps...');
//     AppTheme.setCurrentThemeColors();
//     AppTheme.setCurrentThemeColors();
//
//     // Synchronize all theme systems
//     print('🎨 [ThemeController] Updating theme in all modules...');
//
//     AppTheme.toggleTheme();
//
//     try {
//             .messagingConfigurations
//             .toggleTheme();
//       }
//     } catch (e) {
//       print('⚠️ [ThemeController] Error updating messaging theme: $e');
//     }
//
//     // Note: This toggles isDark again, but we already set it above
//     // AppTheme.toggleTheme();
//
//     // Update UI in post frame callback
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       updateSystemUIOverlayStyle();
//       Get.forceAppUpdate();
//       print('🎨 [ThemeController] Theme toggle completed - isDark: ${AppTheme.isDark}');
//     });
//   }
//
//   initTheme({bool withMessage = true}) {
//     print('🎨 [ThemeController] Initializing theme...');
//
//     final int primaryColor =
//     int.parse(storage.read('primaryColor') ?? '0xFFFFDE59');
//     final int secondaryColor =
//     int.parse(storage.read('secondaryColor') ?? '0xFFE5B800');
//     Color primary = Color(primaryColor);
//     Color secondary = Color(secondaryColor);
//
//     // ✅ FIX: Use the actual theme state from currentTheme
//     bool isDark = currentTheme.value == AppColors.darkTheme;
//
//     print('🎨 [ThemeController] Primary color: $primary');
//     print('🎨 [ThemeController] Secondary color: $secondary');
//     print('🎨 [ThemeController] Dark mode: $isDark (from currentTheme)');
//     print('🎨 [ThemeController] AppTheme.isDark: ${AppTheme.isDark}');
//     print('🎨 [ThemeController] AppTheme.isDark: ${AppTheme.isDark}');
//
//     // ✅ Ensure all theme systems are in sync
//     AppTheme.isDark = isDark;
//     AppTheme.isDark = isDark;
//
//     // Initialize messaging module if needed
//     if (withMessage) {
//       try {
//               .messagingConfigurations
//               .initTheme(primary, secondary, isDark);
//         }
//       } catch (e) {
//         print('⚠️ [ThemeController] Error initializing messaging theme: $e');
//       }
//     }
//
//     // Initialize other theme systems with correct dark mode state
//     AppTheme.initTheme(primary, secondary, isDark);
//     AppTheme.initTheme(primary, secondary, isDark);
//
//     // ✅ CRITICAL: Update color maps after init
//     AppTheme.setCurrentThemeColors();
//     AppTheme.setCurrentThemeColors();
//
//     print('🎨 [ThemeController] Theme initialization completed');
//   }
//
//   CompanyController addCompanyController = Get.put(CompanyController());
//
//   void updatePrimaryColor() {
//     print('🎨 [ThemeController] Updating primary color...');
//
//     final String? colorValue =
//     addCompanyController.company!.status! == 'active'
//         ? addCompanyController
//         .company!.primaryColor!.primaryColor?.lastOrNull
//         : null;
//
//     print('🎨 [ThemeController] Primary color from company: $colorValue');
//
//     storage.write('primaryColor', colorValue);
//
//     AppColors.lightPrimary = colorValue != null
//         ? Color(int.parse(colorValue))
//         : const Color(0xFFFFDE59);
//
//     AppColors.switchSettings = colorValue != null
//         ? Color(int.parse(colorValue))
//         : const Color(0xFFFFDE59);
//
//     print('🎨 [ThemeController] Primary color set to: ${AppColors.lightPrimary}');
//
//     // Refresh current theme to apply new color
//     if (currentTheme.value == AppColors.lightTheme) {
//       currentTheme.value = AppColors.lightTheme;
//       AppColors.textButton;
//     } else {
//       currentTheme.value = AppColors.darkTheme;
//       AppColors.textButton;
//     }
//
//     // Update modules AFTER setting the storage values
//     updateModulesBranding();
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Get.forceAppUpdate();
//     });
//
//     print('🎨 [ThemeController] Primary color update completed');
//   }
//
//   void updateSecondaryColor() {
//     print('🎨 [ThemeController] Updating secondary color...');
//
//     final String? colorValue =
//     addCompanyController.company!.status! == 'active'
//         ? addCompanyController
//         .company!.secondaryColor!.secondaryColor?.lastOrNull
//         : null;
//
//     print('🎨 [ThemeController] Secondary color from company: $colorValue');
//
//     storage.write('secondaryColor', colorValue);
//
//     AppColors.signOut = colorValue != null
//         ? Color(int.parse(colorValue))
//         : const Color(0xFFE5B800);
//
//     AppColors.barColor = colorValue != null
//         ? Color(int.parse(colorValue))
//         : const Color(0xFFE5B800);
//
//     AppColors.bubbleColor = colorValue != null
//         ? Color(int.parse(colorValue))
//         : const Color(0xFFE5B800);
//
//     print('🎨 [ThemeController] Secondary color set to: ${AppColors.signOut}');
//
//     // Refresh current theme to apply new color
//     if (currentTheme.value == AppColors.lightTheme) {
//       currentTheme.value = AppColors.lightTheme;
//     } else {
//       currentTheme.value = AppColors.darkTheme;
//     }
//
//     // Update modules AFTER setting the storage values
//     updateModulesBranding();
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Get.forceAppUpdate();
//     });
//
//     print('🎨 [ThemeController] Secondary color update completed');
//   }
//
//   updateModulesBranding() {
//     print('🎨 [ThemeController] Updating modules branding...');
//
//     final int primaryColor =
//     int.parse(storage.read('primaryColor') ?? '0xFFFFDE59');
//     final int secondaryColor =
//     int.parse(storage.read('secondaryColor') ?? '0xFFE5B800');
//
//     try {
//             .messagingConfigurations
//             .updateBrandingColors(
//             Color(primaryColor), Color(secondaryColor));
//       }
//     } catch (e) {
//       print('⚠️ [ThemeController] Error updating messaging branding: $e');
//     }
//
//     AppTheme.interfaceUpdateBrandingColors(
//         Color(primaryColor), Color(secondaryColor));
//     AppTheme.interfaceUpdateBrandingColors(
//         Color(primaryColor), Color(secondaryColor));
//
//     // ✅ Update color maps after branding changes
//     AppTheme.setCurrentThemeColors();
//     AppTheme.setCurrentThemeColors();
//
//     print('🎨 [ThemeController] Modules branding updated');
//   }
//
//   void updateFonts() {
//     print('🎨 ========== UPDATE FONTS START ==========');
//     print('🎨 Step 1: Reading current storage values...');
//
//     String? currentFontInStorage = storage.read('font');
//     String? currentArabicFontInStorage = storage.read('font_arabic');
//
//     print('🎨 Current storage - font: $currentFontInStorage');
//     print('🎨 Current storage - font_arabic: $currentArabicFontInStorage');
//
//     print('🎨 Step 2: Checking company status...');
//     print('🎨 Company status: ${addCompanyController.company?.status}');
//
//     // ✅ FIX: Only update from company data if storage is null or empty
//     // This preserves user's font selection in branding screen
//     if (currentFontInStorage == null || currentFontInStorage.isEmpty) {
//       print('🎨 Storage font is empty, loading from company data...');
//       storage.write(
//           'font',
//           addCompanyController.company!.status! == 'active'
//               ? addCompanyController
//               .company!.englishFont!.englishFont?.lastOrNull?.capitalize
//               : null);
//       currentFontInStorage = storage.read('font');
//       print('🎨 Loaded from company - font: $currentFontInStorage');
//     } else {
//       print('🎨 Using existing storage font: $currentFontInStorage');
//     }
//
//     if (currentArabicFontInStorage == null || currentArabicFontInStorage.isEmpty) {
//       print('🎨 Storage Arabic font is empty, loading from company data...');
//       storage.write(
//           'font_arabic',
//           addCompanyController.company!.status! == 'active'
//               ? addCompanyController
//               .company!.arabicFont!.arabicFont?.lastOrNull?.capitalize
//               : null);
//       currentArabicFontInStorage = storage.read('font_arabic');
//       print('🎨 Loaded from company - font_arabic: $currentArabicFontInStorage');
//     } else {
//       print('🎨 Using existing storage Arabic font: $currentArabicFontInStorage');
//     }
//
//     print('🎨 Step 3: Applying fonts to theme...');
//     print('🎨 Current locale: ${Get.locale.toString()}');
//     print('🎨 Is Arabic: ${Get.locale.toString().contains('ar')}');
//
//     AppColors.font = Get.locale.toString().contains('ar')
//         ? currentArabicFontInStorage ?? 'Vazirmatn'
//         : currentFontInStorage ?? 'Cairo';
//
//     print('🎨 AppColors.font set to: ${AppColors.font}');
//
//     AppFontStyle.cairoRegularStyle = TextStyle(
//       color: Colors.black,
//       fontFamily: Get.locale.toString().contains('ar')
//           ? currentArabicFontInStorage ?? 'Vazirmatn'
//           : currentFontInStorage ?? 'Cairo',
//       fontWeight: FontWeight.normal,
//       fontSize: 17,
//     );
//
//     print('🎨 AppFontStyle.cairoRegularStyle updated');
//     print('🎨 Font family: ${AppFontStyle.cairoRegularStyle.fontFamily}');
//
//     print('🎨 Step 4: Forcing UI update...');
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Get.forceAppUpdate();
//       print('🎨 UI update forced');
//     });
//
//     print('🎨 ========== UPDATE FONTS END ==========');
//   }
//
//
//     void loadThemeFromStorage() {
//     // This method is now replaced by _loadThemeDataSync() in onInit
//     // Keep it for backward compatibility if called elsewhere
//     _loadThemeDataSync();
//   }
// }

// ignore_for_file: sdk_version_since
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:knowticed_plus/features/settings/se3_company/presentation/controller/company_cubit.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/presentation/controller/system_logs_controller.dart';
import './app_theme.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
class ThemeController extends GetxController {
  /// The company cubit is injected from main(), which owns it. It stays
  /// optional so the handful of bare `Get.put(ThemeController())` call sites
  /// still compile; those resolve the already-registered instance lazily.
  ThemeController({CompanyCubit? companyCubit}) : _injectedCompanyCubit = companyCubit;

  final CompanyCubit? _injectedCompanyCubit;

  final storage = GetStorage();
  late Rx<ThemeData> currentTheme;
  final RxBool isInitialized = false.obs;

  /// Global "play animations" preference, honoured by SlideAnimation and any
  /// other opt-in animated widget. Previously lived on GRCThemeController in
  /// data_grc_module; that module was removed, so it lives here now.
  final RxBool animationsEnabled = true.obs;

  static const String _kAnimationsEnabled = 'animationsEnabled';

  @override
  void onInit() {
    super.onInit();

    loadAnimationsSetting();

    // ⚠️ AppColors.lightTheme / darkTheme use .sp (ScreenUtil) which requires
    // ScreenUtilInit to be mounted. ThemeController is created in main() before
    // the widget tree, so we can't call AppColors.lightTheme here.
    // Use a plain placeholder; _applyRealTheme() swaps it in post-frame.
    currentTheme = ThemeData
        .light()
        .obs;

    // Load isDark + brand colors from storage (no .sp calls)
    _loadThemePrefsSync();

    // After ScreenUtilInit mounts, apply the real themed ThemeData.
    // _applyRealTheme() will call initTheme + set isInitialized once it succeeds.
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyRealTheme());

    // Setup listener for system UI updates
    ever(currentTheme, (_) {
      if (isInitialized.value) {
        Future.microtask(() => updateSystemUIOverlayStyle());
      }
    });
  }

  /// Applies the real AppColors.lightTheme / darkTheme once ScreenUtil is ready.
  /// If ScreenUtil hasn't been initialized yet (LateInitializationError from .sp
  /// calls), retries on the next frame. initTheme + isInitialized are only set
  /// after a successful apply so they never run with a half-built theme.
  void _applyRealTheme() {
    try {
      currentTheme.value =
          AppTheme.isDark ? AppColors.darkTheme : AppColors.lightTheme;
      AppTheme.isDark = AppTheme.isDark;
      AppTheme.setCurrentThemeColors();
      AppTheme.setCurrentThemeColors();
      update();
      // Only mark as initialized after the theme is fully applied
      initTheme(withMessage: false);
      isInitialized.value = true;
    } catch (e) {
      // ScreenUtil not initialized yet — retry on the next frame
      WidgetsBinding.instance.addPostFrameCallback((_) => _applyRealTheme());
    }
  }

  /// Loads isDark + brand colors from storage. Does NOT access AppColors.lightTheme
  /// or darkTheme — those use .sp and require ScreenUtil to be ready.
  /// Restores the animation preference from storage. Defaults to enabled.
  void loadAnimationsSetting() {
    animationsEnabled.value = storage.read(_kAnimationsEnabled) ?? true;
  }

  /// Enables or disables app-wide opt-in animations and persists the choice.
  /// Widgets read [animationsEnabled] directly, so no restart is required.
  void toggleAnimations(bool isEnabled) {
    animationsEnabled.value = isEnabled;
    storage.write(_kAnimationsEnabled, isEnabled);
    update();
  }

  void _loadThemePrefsSync() {

    // Load theme mode (sets isDark flags only — ThemeData set post-frame)
    final savedTheme = storage.read('theme');
    if (savedTheme == 'darkMode') {
      AppTheme.isDark = true;
      AppTheme.isDark = true;
    } else {
      AppTheme.isDark = false;
      AppTheme.isDark = false;
    }

    // Load and apply brand colors
    final primaryColor = storage.read('primaryColor');
    if (primaryColor != null) {
      final primary = Color(int.parse(primaryColor));
      AppTheme.lightThemeColors['primary'] = primary;
      AppTheme.lightThemeColors['lightPrimary'] = primary;
      AppTheme.darkThemeColors['primary'] = primary;
      AppTheme.darkThemeColors['lightPrimary'] = primary;
      AppColors.currentThemeColors['primary'] = primary;
      AppColors.currentThemeColors['lightPrimary'] = primary;
    }

    final secondaryColor = storage.read('secondaryColor');
    if (secondaryColor != null) {
      final secondary = Color(int.parse(secondaryColor));
      AppTheme.lightThemeColors['secondaryPrimary'] =
          secondary;
      AppTheme.darkThemeColors['secondaryPrimary'] = secondary;
      AppColors.currentThemeColors['secondaryPrimary'] = secondary;
    }

    // Sync color maps (no .sp calls here)
    AppTheme.setCurrentThemeColors();
    AppTheme.setCurrentThemeColors();

  }

  void updateSystemUIOverlayStyle() {
    if (Get.context != null) {
      bool isTablet = MediaQuery
          .of(Get.context!)
          .size
          .shortestSide > 600;
      if (isTablet) {
        updateSystemUIOverlayStyleTablet();
      } else {
        updateSystemUIOverlayStyleMobile();
      }
    }
  }

  void updateSystemUIOverlayStyleMobile() {
    // Reads AppTheme.isDark rather than comparing ThemeData identities — see
    // the note in toggleTheme().
    if (!AppTheme.isDark) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: AppColors.colorLightGrey,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      );
    } else {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: AppColors.colorBlack,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      );
    }
  }

  void updateSystemUIOverlayStyleTablet() {
    if (!AppTheme.isDark) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: AppColors.colorWhite,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      );
    } else {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: AppColors.dark,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      );
    }
  }

  void toggleTheme() {

    // Toggle theme mode.
    //
    // FIXED 22/8/2026: the branch used to be
    // `if (currentTheme.value == AppColors.lightTheme)`, i.e. it asked the
    // *ThemeData* which mode we were in. That is a fragile source of truth —
    // `updatePrimaryColor` / `updateSecondaryColor` reassign `currentTheme`,
    // and any path that leaves it holding something that is neither the
    // `lightTheme` nor the `darkTheme` singleton (the plain
    // `ThemeData.light()` placeholder set in onInit, for one) falls into the
    // else branch and forces light. `AppTheme.isDark` is the flag that is
    // actually persisted to storage and restored on launch, so it is the one
    // piece of state every read below now agrees on.
    final bool goingDark = !AppTheme.isDark;

    AppTheme.isDark = goingDark;
    currentTheme.value = goingDark ? AppColors.darkTheme : AppColors.lightTheme;
    storage.write('theme', goingDark ? 'darkMode' : 'lightMode');

    // Log action
    systemLogsController.systemLogsAction('change theme');

    // Rebuild the active colour map from the isDark flag set above.
    //
    // ⚠️ Do NOT call AppTheme.toggleTheme() here. That method is
    // `isDark = !isDark; setCurrentThemeColors();` — it flips the flag a
    // *second* time and immediately undoes the branch above, so the theme
    // always snapped back to its previous value. Assign isDark explicitly
    // (done above) and only refresh the colour map here.
    AppTheme.setCurrentThemeColors();

    // main.dart wraps GetMaterialApp in GetBuilder<ThemeController>, which
    // rebuilds on update() — not on currentTheme's Rx stream. Without this the
    // new ThemeData only reaches MaterialApp via Get.forceAppUpdate().
    update();

    // Update UI in post frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateSystemUIOverlayStyle();
      Get.forceAppUpdate();
    });
  }

  initTheme({bool withMessage = true}) {

    final int primaryColor =
    int.parse(storage.read('primaryColor') ?? '0xFFFFDE59');
    final int secondaryColor =
    int.parse(storage.read('secondaryColor') ?? '0xFFE5B800');
    Color primary = Color(primaryColor);
    Color secondary = Color(secondaryColor);

    // FIXED 22/8/2026: was `currentTheme.value == AppColors.darkTheme`. During
    // the first `_applyRealTheme()` pass `currentTheme` can still hold the
    // plain `ThemeData.light()` placeholder from onInit, so this read reported
    // "light" and clobbered the `isDark` that `_loadThemePrefsSync()` had just
    // restored from storage — which is how a user who had chosen dark mode
    // landed back on the light sign-in/onboarding screens.
    final bool isDark = AppTheme.isDark;


    // Initialize other theme systems with correct dark mode state
    AppTheme.initTheme(primary, secondary, isDark);
    AppTheme.initTheme(primary, secondary, isDark);

    // ✅ CRITICAL: Update color maps after init
    AppTheme.setCurrentThemeColors();
    AppTheme.setCurrentThemeColors();

  }

  // ⚠️ Must NOT re-create the company cubit on every ThemeController
  // construction.
  //
  // ThemeController is created via `Get.put(ThemeController())` inside many
  // widget build() methods, so a new ThemeController is built every frame. The
  // old code had this as a *field* that called Get.put(CompanyController()),
  // which risked init() -> getCompany() -> update*Color() ->
  // Get.forceAppUpdate() -> rebuild -> re-create... an infinite loop.
  //
  // It is now a getter over the single instance main() created, so no
  // construction happens here at all. The name is unchanged so the ~20 read
  // sites below (`addCompanyController.company?...`) keep working — CompanyCubit
  // exposes the same `company` accessor the GetX controller did.
  CompanyCubit get addCompanyController =>
      _injectedCompanyCubit ?? Get.find<CompanyCubit>();

  SystemLogsController get systemLogsController => Get.find();

  // ✅ FIXED: Check GetStorage FIRST for employee branding, fallback to company branding
  void updatePrimaryColor() {


    // Step 1: Check if there's already a value in GetStorage (employee branding)
    String? existingColorInStorage = storage.read('primaryColor');

    String? colorValue;

    // Step 2: If storage is empty, load from company branding
    if (existingColorInStorage == null || existingColorInStorage.isEmpty) {


      colorValue = addCompanyController.company?.status == 'active'
          ? addCompanyController.company?.primaryColor?.primaryColor?.lastOrNull
          : null;


      if (colorValue != null && colorValue.isNotEmpty) {
        storage.write('primaryColor', colorValue);
      }
    } else {
      // Use existing storage value (employee branding)
      colorValue = existingColorInStorage;

    }



    final _primaryColor = colorValue != null && colorValue.isNotEmpty
        ? Color(int.parse(colorValue))
        : const Color(0xFFFFDE59);
    AppTheme.lightThemeColors['primary'] = _primaryColor;
    AppTheme.lightThemeColors['lightPrimary'] = _primaryColor;
    AppTheme.darkThemeColors['primary'] = _primaryColor;
    AppTheme.darkThemeColors['lightPrimary'] = _primaryColor;
    AppColors.currentThemeColors['primary'] = _primaryColor;
    AppColors.currentThemeColors['lightPrimary'] = _primaryColor;



    // Step 4: Refresh current theme to apply new color.
    //
    // FIXED 22/8/2026: this used to decide light-vs-dark by comparing
    // `currentTheme.value` against the `AppColors.lightTheme` singleton. This
    // method runs when company branding arrives — which is *before*
    // `_applyRealTheme()` has swapped the `ThemeData.light()` placeholder set
    // in onInit for the real theme. The placeholder is not identical to
    // `AppColors.lightTheme`, so the comparison fell through to the else
    // branch and the app's mode was decided by whichever ThemeData instance
    // happened to be in the Rx at that moment rather than by the user's saved
    // preference. `AppTheme.isDark` is what `_loadThemePrefsSync()` restores
    // from storage, so it is the source of truth here.
    currentTheme.value =
        AppTheme.isDark ? AppColors.darkTheme : AppColors.lightTheme;

    // Step 5: Update modules AFTER setting the storage values
    updateModulesBranding();

    // Step 6: Force UI update
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.forceAppUpdate();
    });

  }

  // ✅ FIXED: Check GetStorage FIRST for employee branding, fallback to company branding
  void updateSecondaryColor() {

    // Step 1: Check if there's already a value in GetStorage (employee branding)
    String? existingColorInStorage = storage.read('secondaryColor');

    String? colorValue;

    // Step 2: If storage is empty, load from company branding
    if (existingColorInStorage == null || existingColorInStorage.isEmpty) {

      colorValue = addCompanyController.company?.status == 'active'
          ? addCompanyController.company?.secondaryColor?.secondaryColor
          ?.lastOrNull
          : null;


      if (colorValue != null && colorValue.isNotEmpty) {
        storage.write('secondaryColor', colorValue);
      }
    } else {
      // Use existing storage value (employee branding)
      colorValue = existingColorInStorage;
    }

    // Step 3: Apply the color to theme

    final _secondaryColor = colorValue != null && colorValue.isNotEmpty
        ? Color(int.parse(colorValue))
        : const Color(0xFFE5B800);
    AppTheme.lightThemeColors['secondaryPrimary'] =
        _secondaryColor;
    AppTheme.darkThemeColors['secondaryPrimary'] =
        _secondaryColor;
    AppColors.currentThemeColors['secondaryPrimary'] = _secondaryColor;


    // Step 4: Refresh current theme to apply new color.
    //
    // FIXED 22/8/2026: this used to decide light-vs-dark by comparing
    // `currentTheme.value` against the `AppColors.lightTheme` singleton. This
    // method runs when company branding arrives — which is *before*
    // `_applyRealTheme()` has swapped the `ThemeData.light()` placeholder set
    // in onInit for the real theme. The placeholder is not identical to
    // `AppColors.lightTheme`, so the comparison fell through to the else
    // branch and the app's mode was decided by whichever ThemeData instance
    // happened to be in the Rx at that moment rather than by the user's saved
    // preference. `AppTheme.isDark` is what `_loadThemePrefsSync()` restores
    // from storage, so it is the source of truth here.
    currentTheme.value =
        AppTheme.isDark ? AppColors.darkTheme : AppColors.lightTheme;

    // Step 5: Update modules AFTER setting the storage values
    updateModulesBranding();

    // Step 6: Force UI update
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.forceAppUpdate();
    });

  }

  updateModulesBranding() {

    final int primaryColor =
    int.parse(storage.read('primaryColor') ?? '0xFFFFDE59');
    final int secondaryColor =
    int.parse(storage.read('secondaryColor') ?? '0xFFE5B800');


    AppTheme.interfaceUpdateBrandingColors(
        Color(primaryColor), Color(secondaryColor));
    AppTheme.interfaceUpdateBrandingColors(
        Color(primaryColor), Color(secondaryColor));

    // ✅ Update color maps after branding changes
    AppTheme.setCurrentThemeColors();
    AppTheme.setCurrentThemeColors();

  }

  void updateFonts() {

    String? currentFontInStorage = storage.read('font');
    String? currentArabicFontInStorage = storage.read('font_arabic');



    // ✅ FIX: Only update from company data if storage is null or empty
    // This preserves user's font selection in branding screen
    // `company?.status`, not `company!.status!` (23/8/2026). This method is now
    // also called when the company is inactive — the reset path — where the
    // two `!`s would throw if the cubit had no company loaded. The colour
    // methods above have always used `?.`; this matches them.
    final bool companyIsActive =
        addCompanyController.company?.status == 'active';

    if (currentFontInStorage == null || currentFontInStorage.isEmpty) {
      storage.write(
          'font',
          companyIsActive
              ? addCompanyController
              .company?.englishFont?.englishFont?.lastOrNull?.capitalize
              : null);
      currentFontInStorage = storage.read('font');
    }

    if (currentArabicFontInStorage == null ||
        currentArabicFontInStorage.isEmpty) {
      storage.write(
          'font_arabic',
          companyIsActive
              ? addCompanyController
              .company?.arabicFont?.arabicFont?.lastOrNull?.capitalize
              : null);
      currentArabicFontInStorage = storage.read('font_arabic');
    }


    // Font is read directly from storage by StyleText.englishFontFamily / arabicFontFamily
    // No assignment needed — storage was already written above.

    AppFontStyle.cairoRegularStyle = TextStyle(
      color: Colors.black,
      fontFamily: Get.locale.toString().contains('ar')
          ? currentArabicFontInStorage ?? 'Vazirmatn'
          : currentFontInStorage ?? 'Cairo',
      fontWeight: FontWeight.normal,
      fontSize: 17,
    );


    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.forceAppUpdate();
    });

  }

  void loadThemeFromStorage() {
    _loadThemePrefsSync();
    _applyRealTheme();
  }
}

/// The app-wide theme controller.
///
/// Moved here 12/8/2026 from `o2_intro/presentation/ui/pages/onboarding.dart`,
/// where it was one of three file-scope `Get.find()` / `Get.put(ThemeController())`
/// globals that ran on import — so simply importing the onboarding *page*
/// registered a controller as a side effect (CR-SKEL-O2-N04). Twenty files
/// imported that page for this one symbol, and `core/theme/theme_controller.dart`
/// imported the page back, making core depend on a feature.
///
/// A lazy getter, not a `final`: it resolves on first read rather than at
/// import time, and registers the controller only if the bindings have not.
ThemeController get themeController => Get.isRegistered<ThemeController>()
    ? Get.find<ThemeController>()
    : Get.put(ThemeController());
