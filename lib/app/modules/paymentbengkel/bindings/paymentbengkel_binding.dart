import 'package:get/get.dart';

import '../controllers/paymentbengkel_controller.dart';

class PaymentbengkelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentbengkelController>(
      () => PaymentbengkelController(),
    );
  }
}
