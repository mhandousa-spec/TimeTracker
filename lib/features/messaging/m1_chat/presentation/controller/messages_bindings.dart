// Date: 1/8/2024
// By: Nada Moha,med
// Last update: 14/8/2024
// Objectives: This file is responsible for providing a binding class that is used to bind the message controller to the message view.

import 'package:get/get.dart';

import './message_controller.dart';
import 'package:knowticed_plus/core/services/image_picker_cubit.dart';

class MessagesBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => MessageCubit(),
    );
    Get.lazyPut(
      () => ImagePickerCubit(),
    );
  }
}
