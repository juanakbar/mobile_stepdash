import 'package:get/get.dart';
import 'package:sp_util/sp_util.dart';

class DriverController extends GetxController {
  //TODO: Implement DriverController

  final count = 0.obs;
  final isOnline = false.obs;
  Rx<dynamic> driverDetail = Rx<dynamic>(null);
  @override
  void onInit() {
    super.onInit();
    driverDetail.value = SpUtil.getObject('userDetail');
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
