import 'package:get/get.dart';

import '../controllers/trackingbengkel_controller.dart';

class TrackingbengkelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TrackingbengkelController>(
      () => TrackingbengkelController(),
    );
  }
}
