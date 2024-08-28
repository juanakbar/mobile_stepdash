import 'package:get/get.dart';

import '../controllers/mekanik_controller.dart';

class MekanikBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MekanikController>(
      () => MekanikController(),
    );
  }
}
