import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stepmotor/app/routes/app_pages.dart';
import 'package:stepmotor/tokenService.dart';

import '../controllers/trackingbengkel_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class TrackingbengkelView extends StatefulWidget {
  const TrackingbengkelView({super.key});

  @override
  State<TrackingbengkelView> createState() => _TrackingbengkelViewState();
}

class _TrackingbengkelViewState extends State<TrackingbengkelView> {
  final Map<String, dynamic> ordersData = Get.arguments;
  RxList<Map<String, dynamic>> getMekanik = <Map<String, dynamic>>[].obs;
  RxInt harga = 0.obs;
  RxBool isDone = false.obs;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDetailMekanik();
    cekStatus();
  }

  void cekStatus() async {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("serviceOrders/${ordersData['id']}");
    while (!isDone.value) {
      print('JALAN TERUS');
      try {
        DatabaseEvent _ordersRef = await ref.once();
        Map<dynamic, dynamic>? orders =
            _ordersRef.snapshot.value as Map<dynamic, dynamic>?;
        if (orders != null) {
          if (orders['status'] == 'completed') {
            print('orders : ${orders['harga']}');
            setState(() {
              harga.value = int.parse(orders['harga']);
              isDone.value = true;
            });
          }
        }
      } catch (e) {
        print('Failed to update data: $e');
      }
    }
    await Future.delayed(
      const Duration(seconds: 1),
    ); // Menunggu 2 detik sebelum mengulang
  }

  void getDetailMekanik() async {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("mekaniks/${ordersData['driverId']}");
    try {
      DatabaseEvent _ordersRef = await ref.once();
      Map<dynamic, dynamic>? orders =
          _ordersRef.snapshot.value as Map<dynamic, dynamic>?;
      if (orders != null) {
        getMekanik.add(Map<String, dynamic>.from(orders));
        print("orders['driverId'] :  ${ordersData['driverId']}}");
      }
    } catch (e) {
      print('Failed to update data: $e');
      Get.snackbar(
        'Error',
        'Failed to create order. Please try again later.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print("getMekanik: ${ordersData['driverId']}");
    return Scaffold(
      appBar: AppBar(
        title: const Text("Service Tracking"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Service Motor",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text("ID Order: ${ordersData['id']}"),
                          const SizedBox(width: 4),
                          const Icon(Icons.copy, size: 16, color: Colors.grey),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Shipment Details Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bengkel",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    Text(ordersData['nama_layanan']),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("Alamat"),
                    Text(
                      ordersData['alamat'],
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                const Text("Mekanik"),
                const SizedBox(width: 8),
                Text(getMekanik.isNotEmpty ? getMekanik[0]['nama_mekanik'] : "",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            // Live Tracking Button
            Obx(() {
              if (isDone.value) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Aksi saat tombol di klik
                      EasyLoading.show(status: "Tunggu Sebentar...");
                      var payload = {
                        "service_name": "Step Motor",
                        "harga": harga.value
                      };

                      var payloadJson = jsonEncode(payload);
                      final result = await TokenService().getToken(payloadJson);
                      if (result.isRight()) {
                        String? tokenJson =
                            result.fold((l) => null, (r) => r.token);
                        String token =
                            tokenJson!.replaceAll(RegExp(r'[\[\]\"]'), '');
                        print("token $tokenJson");
                        var data = {
                          "url": token,
                        };
                        Get.toNamed(Routes.PAYMENT, arguments: data);
                        EasyLoading.dismiss();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Bayar",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              } else {
                return Container();
              }
            }),
          ],
        ),
      ),
    );
  }
}
