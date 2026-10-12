// Date: 1/8/2024
// By: Youssef Ashraf
// Last update: 14/8/2024
// Objectives: This file is responsible for providing a binding class that is used to bind the media controller to the media view.

import 'package:get/get.dart';

import './media_controller.dart';

class MediaBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => MediaCubit(),
    );
  }
}
