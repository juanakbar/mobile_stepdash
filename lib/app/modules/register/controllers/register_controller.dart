import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as serviceHttp;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:stepmotor/env.dart';

class RegisterController extends GetxController {
  //TODO: Implement RegisterController
  TextEditingController userName = TextEditingController();
  TextEditingController userPass = TextEditingController();
  TextEditingController userEmail = TextEditingController();
  TextEditingController userPh = TextEditingController();
  TextEditingController alamat = TextEditingController();
  TextEditingController role = TextEditingController();
  TextEditingController nama = TextEditingController();
  final count = 0.obs;
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

  void increment() => count.value++;

  Future<void> register() async {
    final data = jsonEncode({
      "nama": nama.text,
      "email": userEmail.text,
      "telepon": userPh.text,
      "alamat": alamat.text,
      "username": userName.text,
      "password": userPass.text,
      "role": role.text
    });
    try {
      EasyLoading.show(status: 'Tunggu Sebentar...');
      final response = await serviceHttp.post(
        Uri.parse('$BASE_API_URL/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: data,
      );
      print(response.body);
      if (response.statusCode == 201) {
        EasyLoading.showSuccess('Berhasil Register');
        Get.back();
      } else {
        EasyLoading.showError('Gagal Register');
      }
    } catch (e) {
      print(e);
      EasyLoading.showError('Gagal Register : $e');
    }
  }
}
