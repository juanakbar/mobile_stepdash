import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stepmotor/app/data/login_provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:sp_util/sp_util.dart';
import 'package:stepmotor/app/routes/app_pages.dart';

class LoginController extends GetxController {
  final count = 0.obs;
  var isLoading = false.obs;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // ignore: non_constant_identifier_names
  final Map<String, TextEditingController> TextEditingControllers = {
    'password': TextEditingController(),
    'email': TextEditingController(),
  };
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void logout(token) async {
    EasyLoading.show(status: 'Tunggu Sebentar...');
    LoginProvider().logout(token).then((value) async {
      await SpUtil.clear();
      Get.offAllNamed(Routes.LOGIN);
      EasyLoading.dismiss();
      Get.snackbar('Success', 'Logout Success');
      // if (value.isOk) {
      //   await SpUtil.clear();
      //   Get.offAllNamed(Routes.LOGIN);
      //   EasyLoading.dismiss();
      //   Get.snackbar('Success', 'Logout Success');
      // } else {
      //   EasyLoading.dismiss();
      //   print(value.body);
      //   Get.snackbar('Error', 'Logout Failed ');
      // }
    });
  }

  void login() async {
    EasyLoading.show(status: 'Tunggu Sebentar...');
    final EMAIL = TextEditingControllers['email']?.text;
    final PASSWORD = TextEditingControllers['password']?.text;

    final data = {
      'email': EMAIL,
      'password': PASSWORD,
    };

    LoginProvider().attempt(data).then((value) {
      print("valueLOGIN: ${value.body}");
      if (value.statusCode == 200) {
        // Dekode value.body menjadi Map<String, dynamic>
        // Map<String, dynamic> parsedJson = jsonDecode(value.body);
        // Simpan data user dan token menggunakan SpUtil
        SpUtil.putObject('userDetail', value.body['user']);
        SpUtil.putString('token', value.body['token']);
        SpUtil.putString('role', value.body['user']['roles'][0]['name']);
        SpUtil.putBool('isLogin', true);
        // Menghilangkan loading
        EasyLoading.dismiss();

        // Menampilkan snackbar dengan nama pengguna
        Get.snackbar(
          'Berhasil',
          'Selamat Datang Kembali ${value.body['user']['nama']}', // Menggunakan parsedJson untuk mengambil data nama
        );

        // Update status loading
        isLoading.value = false;
        printInfo(info: 'User Role: ${value.body['user']['roles'][0]['name']}');
        // Pindah ke halaman HOME
        if (value.body['user']['roles'][0]['name'] == 'Driver') {
          Get.offAllNamed(Routes.DRIVER);
        } else if (value.body['user']['roles'][0]['name'] == 'Mekanik') {
          Get.offAllNamed(Routes.MEKANIK);
        } else {
          Get.offAllNamed(Routes.HOME);
        }
        // Get.offAllNamed(Routes.HOME);
      } else {
        // Menghilangkan loading jika terjadi error
        EasyLoading.dismiss();

        // Menampilkan pesan kesalahan
        Get.snackbar('Error', 'Email atau Password Salah');
      }
    }).catchError((error) {
      // Tangani error lain yang mungkin terjadi
      EasyLoading.dismiss();
      Get.snackbar('Error', 'Terjadi kesalahan: $error');
    });
  }

  void increment() => count.value++;
}
