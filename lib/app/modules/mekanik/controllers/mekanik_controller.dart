import 'package:get/get.dart';
import 'package:sp_util/sp_util.dart';

class MekanikController extends GetxController {
  //TODO: Implement MekanikController
  Rx<dynamic> mekanikDetail = Rx<dynamic>(null);
  final isOnline = false.obs;
  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
    mekanikDetail.value = SpUtil.getObject('userDetail');
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
