/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: getx_cach_helper.dart
/// Purpose: Declares `GetXCacheHelper`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

// Date: 1/8/2024
// By: Youssef Ashraf
// Last update: 3/8/2024
// Objectives: This file is responsible for providing a helper class that is used to cache data in the app (shared preferences) used in places like
// OnBoarding feature to save the user's choice of skipping the onboarding screen, Caching localizations and Theme Mode.

import 'package:get_storage/get_storage.dart';

abstract class GetXCacheHelper {
  static final GetStorage storage = GetStorage();

  static init() async {
    await GetStorage.init();
  }

  static dynamic getData({
    required String key,
  }) {
    return storage.read(key);
  }

  static Future<void> saveData({
    required String key,
    required dynamic value,
  }) async {
    return await storage.write(key, value);
  }

  static Future<void> removeData({
    required String key,
  }) async {
    return await storage.remove(key);
  }
}
