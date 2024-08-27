import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
}
