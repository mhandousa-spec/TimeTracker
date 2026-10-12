// Date: 1/9/2024
// By:  Nada Mohammed ,Mohamed Ashraf
// Last update: 1/9/2024
// Objectives: This file is responsible for providing the community binding used in the community feature.
import 'package:get/get.dart';

import '../../../m1_chat/presentation/controller/message_controller.dart';
import '../../../m1_chat/presentation/controller/media_controller.dart';
import '../../../m3_groups/presentation/controller/groups_controller.dart';
import './community_controller.dart';

class CommunityBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MessageCubit());

    Get.lazyPut(() => CommunityCubit());
    //Get.lazyPut(() => GroupsController());
    Get.lazyPut(() => MediaCubit(), fenix: true);
  }
}
