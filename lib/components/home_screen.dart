import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stepmotor/app/modules/bengkel/views/bengkel_view.dart';
import 'package:stepmotor/app/modules/home/controllers/home_controller.dart';
import 'package:stepmotor/app/modules/ride/views/ride_view.dart';
import 'package:stepmotor/app/routes/app_pages.dart';
import 'package:stepmotor/components/bengkel_card.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print(controller.listBengkelDropoff);
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Lagi Butuh Apa ?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Get.to(() => const RideView());
                  },
                  style: TextButton.styleFrom(
                    splashFactory: NoSplash.splashFactory,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: const Color(0xffF3F3F3),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              spreadRadius: 5)
                        ]),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/Motor.png',
                          fit: BoxFit.cover,
                        ),
                        const Text(
                          'Foot Step',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 2,
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {},
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: const Color(0xffF3F3F3),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              spreadRadius: 5)
                        ]),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/Bengkel.png',
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          'Bengkel',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Bengkel Kami',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.listBengkelDropoff.isEmpty) {
              return Center(child: CircularProgressIndicator());
            } else {
              return ListView.builder(
                itemCount: controller.listBengkelDropoff.length,
                itemBuilder: (context, index) {
                  var bengkel = controller.listBengkelDropoff[index];
                  print(bengkel.alamat);
                  return Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      BengkelCard(
                          onTap: () {
                            var data = {
                              'name': bengkel.nama,
                              'address': bengkel.alamat,
                            };
                            Get.to(() => BengkelView(), arguments: data);
                          },
                          bengkel:
                              bengkel), // Pass object Bengkel ke BengkelCard
                    ],
                  );
                },
              );
            }
          }),
        ),
      ],
    );
  }
}
