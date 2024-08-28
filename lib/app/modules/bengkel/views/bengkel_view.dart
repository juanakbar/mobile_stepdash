import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:stepmotor/app/modules/home/controllers/home_controller.dart';
import 'package:stepmotor/app/routes/app_pages.dart';
import 'package:stepmotor/theme.dart';

import '../controllers/bengkel_controller.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as serviceHttp;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class BengkelView extends StatefulWidget {
  const BengkelView({super.key});

  @override
  State<BengkelView> createState() => _BengkelViewState();
}

class _BengkelViewState extends State<BengkelView> {
  final BengkelController controller = Get.put(BengkelController());
  final HomeController homeController = Get.put(HomeController());
  final Map<String, dynamic> bengkelData = Get.arguments;
  bool _hasSearched = false;
  RxBool isStatusAccepted = false.obs;
  String? _availMekanik;
  bool _isLoading = false;
  Future<String?> findNearestDriver() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("mekaniks");
    try {
      DatabaseEvent _driverRef = await ref.once();
      Map<dynamic, dynamic>? drivers =
          _driverRef.snapshot.value as Map<dynamic, dynamic>?;
      print("DATA Mekanik $drivers");
      if (drivers == null) {
        return null; // Jika tidak ada data driver
      }
      String? nearestDriverId;

      // Loop untuk mengecek setiap driver
      drivers.forEach((key, value) {
        if (value['status'] == 'Online' && value['busy'] == false) {
          if (value['orders'] == null) {
            print("DATA DRIVER KEY $key");
            nearestDriverId = key; // Simpan ID driver terdekat
          }
        }
      });

      return nearestDriverId; // Hanya mengembalikan satu driver terdekat
    } catch (e) {
      print('Error while fetching drivers: $e');
      return null;
    }
  }

  void getConfirmationFromDriver() async {
    EasyLoading.show(status: 'Sedang Menunggu Konfirmasi Driver...');
    DatabaseReference ref = FirebaseDatabase.instance
        .ref("serviceOrders/${homeController.userDetail!['id']}");

    while (!isStatusAccepted.value) {
      try {
        DatabaseEvent _ordersRef = await ref.once();
        Map<dynamic, dynamic>? orderStatus =
            _ordersRef.snapshot.value as Map<dynamic, dynamic>?;

        if (orderStatus != null && orderStatus['status'] == 'accepted') {
          isStatusAccepted.value =
              true; // Status sudah berubah menjadi accepted
          var data = {
            "alamat": orderStatus['alamat'],
            "avatar": orderStatus['avatar'],
            "created_at": orderStatus['created_at'],
            "driverId": orderStatus['driverId'],
            "email": orderStatus['email'],
            "id": orderStatus['id'],
            "nama": orderStatus['nama'],
            "nama_layanan": orderStatus['nama_layanan'],
            "roles": orderStatus['role'],
            "service_ name": orderStatus['service_name'],
            "status": orderStatus['status'],
            "telepon": orderStatus['telepon'],
            "updated_at": orderStatus['updated_at'],
            "username": orderStatus['username'],
          };
          Get.offAllNamed(Routes.TRACKINGBENGKEL, arguments: data);
        } else {
          // Jika status belum berubah, tunggu sebentar sebelum melakukan pengecekan lagi
          await Future.delayed(
              const Duration(seconds: 1)); // Jeda selama 2 detik
        }
      } catch (e) {
        print('Failed to Get Orders data: $e');
        EasyLoading.dismiss();
        return; // Keluar dari fungsi jika terjadi error
      }
    }

    // Status sudah diterima, tutup EasyLoading
    EasyLoading.dismiss();
  }

  Future<void> requestToMekanik() async {
    if (_hasSearched) return;

    setState(() {
      _isLoading = true;
    });

    try {
      EasyLoading.show(status: 'Sedang Mencari Mekanik...');

      String? driverId;
      // Lakukan pencarian berkala hingga driver ditemukan
      while (driverId == null) {
        driverId = await findNearestDriver();

        if (driverId == null) {
          // Jika driver belum ditemukan, tunggu beberapa detik sebelum mencoba lagi
          await Future.delayed(const Duration(seconds: 1));
        }
      }

      setState(() {
        _availMekanik = driverId;
        _isLoading = false;
        _hasSearched = true;
      });

      // Update database dengan driverId yang ditemukan
      try {
        DatabaseReference ref = FirebaseDatabase.instance
            .ref("serviceOrders/${homeController.userDetail!['id']}");
        await ref.update({
          "driverId": int.parse(driverId),
        });
        print('Data updated successfully.');
      } catch (e) {
        print('Failed to update data: $e');
      }

      EasyLoading.dismiss();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasSearched = true;
      });

      EasyLoading.dismiss();
      print("Error: $e");
    }
  }

  void createOrder() async {
    DatabaseReference ref = FirebaseDatabase.instance
        .ref("serviceOrders/${homeController.userDetail!['id']}");
    try {
      await ref.set({
        ...?homeController.userDetail,
        "nama_layanan": bengkelData['name'],
        "alamat": bengkelData['address'],
        "service_name": 2,
        "status": 'pending',
      });
      requestToMekanik().then((_) {
        getConfirmationFromDriver();
      });
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
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(Get.arguments);
    return Scaffold(
      appBar: AppBar(
        title: Text(bengkelData['name']),
        backgroundColor: green2, // Atur sesuai dengan tema aplikasi Anda
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(height: 16),

            // Nama Bengkel
            Text(
              bengkelData['name'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Alamat Bengkel
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    bengkelData['address'],
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const SizedBox(height: 16),

            const SizedBox(height: 16),

            // Tombol Telepon
            ElevatedButton.icon(
              onPressed: () async {
                // Aksi untuk menelepon bengkel
                createOrder();
              },
              icon: const Icon(Icons.request_page),
              label: const Text('Request Service'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
