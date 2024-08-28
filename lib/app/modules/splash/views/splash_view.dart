import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stepmotor/components/main_button.dart';
import 'package:stepmotor/theme.dart';

import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  SplashView({super.key});
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    const String splashText = """
Bantuan cepat untuk sepeda motor Anda yang mogok di jalan.
Dapatkan bantuan kapan saja dan di mana saja
dengan hanya beberapa ketukan di aplikasi ini.
""";

    return Scaffold(
      backgroundColor: white,
      body: Stack(
        children: [
          Container(
            height: height,
            color: blackBG,
            child: Image.asset(
              'assets/images/92.jpg',
              height: height,
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: height / 1.8,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  RichText(
                    text: const TextSpan(children: [
                      TextSpan(
                        text: 'StepDash',
                        style: headline,
                      ),
                      TextSpan(
                        text: '.',
                        style: headlineDot,
                      ),
                    ]),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  const Text(
                    splashText,
                    textAlign: TextAlign.center,
                    style: headline2,
                  ),
                  Mainbutton(
                    onTap: () {
                      Get.toNamed('/login');
                    },
                    btnColor: blueButton,
                    text: 'Get Started',
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
