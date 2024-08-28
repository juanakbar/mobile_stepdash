import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stepmotor/app/modules/History/views/history_view.dart';
import 'package:stepmotor/app/modules/user/controllers/user_controller.dart';
import 'package:stepmotor/app/modules/user/views/user_view.dart';
import 'package:stepmotor/theme.dart';
import 'package:sp_util/sp_util.dart';
import '../controllers/mekanik_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as serviceHttp;

class MekanikView extends StatefulWidget {
  const MekanikView({super.key});

  @override
  State<MekanikView> createState() => _MekanikViewState();
}

class _MekanikViewState extends State<MekanikView> {
  MekanikController controller = Get.put(MekanikController());
  RxList<Map<String, dynamic>> getRequest = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> listActiveOrder = <Map<String, dynamic>>[].obs;
  Map<String, dynamic>? mekanikDetail =
      SpUtil.getObject('userDetail') as Map<String, dynamic>?;
  TextEditingController harga = TextEditingController();
  bool isModalShown = false;
  bool requestIn = false;
  int ordersId = 0;
  int orderIDAPI = 0;
  // Fungsi
  void updateStatus(String status) async {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("mekaniks/${mekanikDetail!['id']}");
    try {
      await ref.update({
        "status": status,
      });
      print('Data updated successfully.');
    } catch (e) {
      print('Failed to update data: $e');
    }
  }

  void createRef() async {
    // Check if driverDetail is null
    if (mekanikDetail == null || mekanikDetail!['id'] == null) {
      print('Driver details are incomplete or missing.');
      return;
    }

    DatabaseReference ref =
        FirebaseDatabase.instance.ref("mekaniks/${mekanikDetail!['id']}");

    try {
      await ref.set({
        ...mekanikDetail!,
        "status": "Offline",
        "busy": false,
      });

      print('Data updated successfully.');
    } catch (e) {
      print('Failed to update data: $e');
    }
  }

  void _startPolling() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("serviceOrders");
    while (!requestIn) {
      // if (controller.isOnline.value) {
      print("Looping sampai requestIn menjadi true");
      // Looping sampai requestIn menjadi true
      try {
        DatabaseEvent _ordersRef = await ref.once();
        Map<dynamic, dynamic>? orders =
            _ordersRef.snapshot.value as Map<dynamic, dynamic>?;
        print("DATA ORDERS $orders");
        if (orders != null) {
          orders.forEach((key, value) {
            print("VALUE: $value");
            if (value is Map &&
                value['status'] == 'pending' &&
                value['driverId'] == mekanikDetail!['id']) {
              print('Data found: $value');

              setState(() {
                getRequest.add(Map<String, dynamic>.from(
                    value)); // Jika data ditemukan, set requestIn ke true

                ordersId = int.parse(key);
              });
            }
          });
        } else {
          print('No data found.');
        }

        print('Data updated successfully.');
      } catch (e) {
        print('Failed to update data: $e');
      }

      // Menunggu sebelum melakukan loop berikutnya
      await Future.delayed(
          const Duration(seconds: 2)); // Menunggu 2 detik sebelum mengulang
      // }
    }

    print('Loop berhenti karena requestIn: $requestIn');
  }

  void _showModal(
      BuildContext context, List<Map<String, dynamic>> requestData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _CustomModalWidget(requestData: requestData);
      },
    );
  }

  Future<void> createOrder(data, int requestId) async {
    // Tampilkan indikator loading
    EasyLoading.show(status: 'Tunggu Sebentar...');

    // Mendapatkan referensi ke node di Firebase Realtime Database
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("serviceOrders/$requestId");
    try {
      var response = await serviceHttp.post(
        Uri.parse("http://10.0.2.2:8000/api/create_order"),
        headers: <String, String>{
          'Content-Type': 'application/json',
          "Authorization": 'Bearer ${SpUtil.getString('token')}',
        },
        body: data,
      );
      print(response.body);
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        await ref.update({
          'status': 'accepted',
        });
        setState(() {
          orderIDAPI = jsonResponse['id'];
          listActiveOrder.add(Map<String, dynamic>.from(
              jsonResponse)); // Jika data ditemukan, set requestIn ke true
        });
        // Sembunyikan indikator loading
        EasyLoading.dismiss();
      } else {
        print(
            'Failed to create order: ${response.statusCode} + ${response.body}');
        EasyLoading.showError('Failed to create order.');
        EasyLoading.dismiss();
      }
    } catch (e) {
      print('Failed to update request status: $e');
      EasyLoading.showError('Failed to update request status.');
      EasyLoading.dismiss();
    }
  }

  void tolakOrder(int requestId) async {
    EasyLoading.show(status: 'Tunggu Sebentar...');
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("serviceOrders/$requestId");
    try {
      await ref.update({
        'status': 'rejected',
      });
      setState(() {
        getRequest.value = [];
      });
      // Sembunyikan indikator loading
      EasyLoading.dismiss();
    } catch (e) {
      print('Failed to update request status: $e');
      EasyLoading.showError('Failed to update request status.');
      EasyLoading.dismiss();
    }
  }

  void completedOrder() async {
    EasyLoading.show(status: 'Tunggu Sebentar...');
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("serviceOrders/$ordersId");
    try {
      final response = await serviceHttp.post(
        Uri.parse("http://10.0.2.2:8000/api/create_pembayaran"),
        headers: <String, String>{
          'Content-Type': 'application/json',
          "Authorization": 'Bearer ${SpUtil.getString('token')}',
        },
        body: jsonEncode({"order_id": orderIDAPI, "total": harga.text}),
      );
      if (response.statusCode == 200) {
        final responseUpdate = await serviceHttp.put(
          Uri.parse("http://10.0.2.2:8000/api/update_status_order"),
          headers: <String, String>{
            'Content-Type': 'application/json',
            "Authorization": 'Bearer ${SpUtil.getString('token')}',
          },
          body: jsonEncode({"id": orderIDAPI, "status": "completed"}),
        );
        if (response.statusCode == 200) {
          await ref.update({
            'status': 'completed',
            'harga': harga.text,
          });
          setState(() {
            isModalShown = false;
            requestIn = false;
            ordersId = 0;
            orderIDAPI = 0;
            getRequest.value = [];
            listActiveOrder.value = [];
            _startPolling();
          });
          // Sembunyikan indikator loading
          EasyLoading.dismiss();
          Get.snackbar('Success', 'Pekerjaan Selesai');
        } else {
          print(
              'Failed to create order: ${response.statusCode} + ${response.body}');
          EasyLoading.showError('Failed to create order.');
          EasyLoading.dismiss();
        }
      } else {
        print(
            'Failed to create order: ${response.statusCode} + ${response.body}');
        EasyLoading.showError('Failed to create order.');
        EasyLoading.dismiss();
      }
      await ref.update({
        "status": "completed",
        "harga": harga.text,
      });
      print('Data updated successfully.');
    } catch (e) {
      print('Failed to update data: $e');
    }
  }

// State
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    createRef();
  }

  @override
  Widget build(BuildContext context) {
    print("listActiveOrder : $listActiveOrder");
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu), // Ikon untuk membuka drawer
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Membuka drawer
              },
            );
          },
        ),
      ),
      drawer: Obx(
        () => Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // Header
              Container(
                height: 220,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [green2, Colors.green],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 36,
                        backgroundImage: NetworkImage(
                            'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      controller.mekanikDetail.value['nama'] ?? 'Nama Pengguna',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.mekanikDetail.value['email'] ??
                          'email@example.com',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Body
              const Divider(),
              ListTile(
                leading: Icon(Icons.history, color: green2),
                title: const Text('History'),
                onTap: () {
                  // Tindakan ketika item 1 di-tap
                  Get.to(() => HistoryView());
                },
              ),
              ListTile(
                leading: Icon(Icons.person, color: green2),
                title: const Text('Profile'),
                onTap: () {
                  Get.lazyPut(() => UserController());
                  Get.to(() => const UserView());
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Obx(
        () {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300), // Durasi animasi
            transitionBuilder: (Widget child, Animation<double> animation) {
              // Tween animasi untuk efek slide
              final offsetAnimation = Tween<Offset>(
                begin: const Offset(1.0, 0.0), // Mulai dari bawah
                end: const Offset(0.0, 0.0), // Akhir di posisi asalnya
              ).animate(animation);

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
            child: controller.isOnline.value
                ? FloatingActionButton.extended(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    key: const ValueKey(
                        'online'), // Key unik untuk AnimatedSwitcher
                    icon: const Icon(
                      Icons.power_settings_new,
                      size: 30,
                      color: Colors.green,
                    ),
                    onPressed: () async {
                      controller.isOnline.value = false;
                      updateStatus("Offline");
                      requestIn = true;
                    },
                    label: const Text("Online"),
                  )
                : FloatingActionButton(
                    key: const ValueKey(
                        'offline'), // Key unik untuk AnimatedSwitcher
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    onPressed: () async {
                      controller.isOnline.value = true;
                      updateStatus("Online");
                      requestIn = false;
                      _startPolling();
                    },
                    child: const Icon(
                      Icons.power_settings_new,
                      size: 30,
                      color: Colors.red,
                    ),
                  ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      body: Stack(
        children: [
          Obx(() {
            if (listActiveOrder.isEmpty) {
              return const Center(
                  child: Column(
                children: [
                  // CircularProgressIndicator(),
                  Text("Tidak ada order"),
                ],
              ));
            } else {
              return Padding(
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
                                  Text("ID Order: $ordersId"),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.copy,
                                      size: 16, color: Colors.grey),
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
                            const Text(
                              "Bengkel",
                              style: TextStyle(color: Colors.grey),
                            ),
                            Text(getRequest[0]['nama_layanan']),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text("Alamat",
                                style: const TextStyle(color: Colors.grey)),
                            Text(
                              getRequest[0]['alamat'],
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
                        const Text("Customer"),
                        const SizedBox(width: 8),
                        Text(getRequest[0]['nama'] ?? 'Nama Customer',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      controller: harga,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter harga';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        label: const Text('Harga'),
                        hintText: 'Masukkan Harga',
                        hintStyle: const TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.black26,
                        ),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.black12, // Default border color
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.black12, // Default border color
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Aksi saat tombol di klik
                          completedOrder();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "Selesaikan Pekerjaan",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          }),
          Obx(() {
            // Cek apakah RxList getRequest memiliki data
            // Cek apakah RxList getRequest memiliki data dan modal belum ditampilkan
            if (getRequest.isNotEmpty && !isModalShown) {
              // Jika ya, tampilkan modal dan set isModalShown menjadi true
              Future.delayed(Duration.zero, () {
                isModalShown = true;
                _showModal(context, getRequest);
              });
            }
            return Container();
          }),
        ],
      ),
    );
  }

  Widget _CustomModalWidget({required List<Map<String, dynamic>> requestData}) {
    print("requestData : $requestData");

    // Pastikan requestData memiliki data sebelum digunakan
    if (requestData.isEmpty) {
      return AlertDialog(
        title: const Text('No Data'),
        content: const Text('Tidak ada data yang tersedia.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Tutup modal
            },
            child: const Text('OK'),
          ),
        ],
      );
    }
    return AlertDialog(
      title: const Text('Order Masuk'),
      content: SizedBox(
        // Menentukan ukuran modal dengan lebar 300 dan tinggi sesuai konten
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min, // Ukuran modal mengikuti konten
          children: [
            Row(
              children: [
                Container(
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SvgPicture.network(
                      requestData[0]['avatar'],
                      fit: BoxFit.cover, // To ensure the SVG scales properly
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                TextCustom(text: requestData[0]['nama']),
              ],
            ),
            const SizedBox(height: 20.0), // Jarak vertikal sebelum tombol
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    var data = jsonEncode({
                      "id_layanan": requestData[0]['service_name'],
                      "id_user": requestData[0]['id'],
                      "pickup": requestData[0]['nama_layanan'],
                      "dropoff": requestData[0]['alamat'],
                      "status": 'on_the_way',
                    });
                    print("DATA ORDER PERPARE : $data");
                    await createOrder(data, ordersId);
                    Navigator.of(context).pop(); // Tutup modal
                    // Tambahkan logika untuk menerima order di sini
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor:
                        Colors.green, // Warna latar belakang tombol
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8.0), // Sudut melengkung
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 20.0), // Padding tombol
                    elevation: 5, // Bayangan tombol
                  ),
                  child: const Text('Terima', style: TextStyle(fontSize: 16)),
                ),
                ElevatedButton(
                  onPressed: () {
                    tolakOrder(requestData[0]['id']);
                    Navigator.of(context).pop(); // Tutup modal
                    // Tambahkan logika untuk menolak order di sini
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red, // Warna latar belakang tombol
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8.0), // Sudut melengkung
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 20.0), // Padding tombol
                    elevation: 5, // Bayangan tombol
                  ),
                  child: const Text('Tolak', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
