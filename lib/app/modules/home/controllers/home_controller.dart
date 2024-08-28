import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stepmotor/app/data/user_provider.dart';
import 'package:stepmotor/components/bengkel_card.dart';
import 'package:stepmotor/components/step_motor.dart';
import 'package:sp_util/sp_util.dart';
import 'package:stepmotor/components/home_screen.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeController extends GetxController {
  // Use RxInt to make the selectedIndex reactive
  var selectedIndex = 0.obs;
  var selectedIndexService = 0.obs;
  // var userDetailString = {}.obs;
  var listBengkelDropoff = <Bengkel>[].obs; // Ubah menjadi list of Bengkel
  final FocusNode startLocationFocusNode = FocusNode();
  final FocusNode endLocationFocusNode = FocusNode();
  final startLocationName = TextEditingController();
  final endLocationName = TextEditingController();
  Map<String, dynamic>? userDetail =
      SpUtil.getObject('userDetail') as Map<String, dynamic>?;

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.w600);

  // List of widgets corresponding to different tabs or sections
  static List<Widget> widgetOptions = <Widget>[
    HomeScreen(),
    const Text(
      'History',
      style: optionStyle,
    )
  ];
  static List<Widget> widgetOptionsService = <Widget>[
    const StepMotor(),
    const Text(
      'Tab 2',
      style: optionStyle,
    )
  ];

  // Method to update the selectedIndex
  void updateIndex(int index) {
    selectedIndex.value = index;
  }

  void updateIndexService(int index) {
    selectedIndexService.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    userDetail = SpUtil.getObject('userDetail') as Map<String, dynamic>?;
    getBengkels();
    print("listBengkelDropoff: $listBengkelDropoff");
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void updateUserDetails() {
    userDetail = SpUtil.getObject('userDetail') as Map<String, dynamic>;
  }

  void getBengkels() async {
    bool isDone = false;
    while (!isDone) {
      try {
        final response = await UserProvider().getBengkels();

        if (response.statusCode == 200) {
          // Pastikan respons berupa List dan setiap elemen adalah Map
          if (response.body != null && response.body is List) {
            // Parsing data menjadi List<Bengkel>
            List<dynamic> data = response.body;
            listBengkelDropoff.value =
                data.map((e) => Bengkel.fromMap(e)).toList();
            isDone = true;
            print('Parsed Bengkels: ${listBengkelDropoff.length}');
            print(
                'Bengkels: ${listBengkelDropoff.map((bengkel) => bengkel.nama)}');
          } else {
            isDone = false;
            print('Unexpected data format: ${response.body}');
          }
        } else {
          await Future.delayed(
              const Duration(seconds: 1)); // Jeda selama 2 detik
          print('Error: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        print('Exception: $e');
      }
    }
  }
}
