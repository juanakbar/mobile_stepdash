import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'app/routes/app_pages.dart';
import 'package:sp_util/sp_util.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SpUtil.getInstance();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    GetMaterialApp(
      title: "StepDash",
      initialRoute: (SpUtil.getBool('isLogin', defValue: false)!
          ? SpUtil.getString('role', defValue: 'Customer') == 'Driver'
              ? Routes.DRIVER
              : Routes.HOME
          : Routes.LOGIN),
      getPages: AppPages.routes,
      builder: EasyLoading.init(),
    ),
  );
}
