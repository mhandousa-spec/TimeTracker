/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: get_base_url.dart
/// Purpose: Get base url.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:knowticed_plus/core/network/api_constants.dart';

String getBaseUrl(String path) {
 // print("base Uri is ${ApiConstants.baseUri}");
  return "${ApiConstants.baseUri}/$path";
}

