import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stepmotor/app/modules/History/controllers/history_controller.dart';

import 'package:sp_util/sp_util.dart';

class HistoryView extends StatefulWidget {
  @override
  _HistoryViewState createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  bool isFootstepSelected = true;
  HistoryController historyController = Get.put(HistoryController());
  String? role = SpUtil.getString('role', defValue: 'Customer');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Orderan'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          saldoCard(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                role == 'Driver'
                    ? ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isFootstepSelected = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: role == "Driver"
                              ? Colors.red
                              : Colors.grey.shade300,
                          foregroundColor:
                              role == "Driver" ? Colors.white : Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                        ),
                        child: const Text('Footstep'),
                      )
                    : ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isFootstepSelected = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: role == "Mekanik"
                              ? Colors.red
                              : Colors.grey.shade300,
                          foregroundColor:
                              role == "Mekanik" ? Colors.white : Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                        ),
                        child: const Text('Bengkel'),
                      ),
              ],
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child:
                  role == 'Driver' ? buildFootstepBody() : buildBengkelBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget saldoCard() {
    return Obx(() => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        'assets/images/credit-wallet.png', // Path ke file logo
                        width: 40,
                        height: 40,
                      ),
                      Text(
                        'Saldo Pendapatan Kamu',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      historyController.totalPendapatan.value == 0
                          ? CircularProgressIndicator()
                          : Text(
                              historyController.formatRupiah(double.parse(
                                  historyController.totalPendapatan
                                      .toString())),
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget buildFootstepBody() {
    return Obx(() {
      if (historyController.historyFootStep.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      } else {
        return ListView.builder(
            itemCount: historyController.historyFootStep.length,
            itemBuilder: (context, index) {
              var order = historyController.historyFootStep[index];
              return buildOrderItem(
                  order['order']['dropoff'],
                  order['order']['pembayaran'][0]['total'].toString(),
                  Icons.location_on,
                  Colors.green);
            });
      }
    });
  }

  Widget buildBengkelBody() {
    return Obx(() {
      if (historyController.historyBengkel.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      } else {
        return ListView.builder(
            itemCount: historyController.historyBengkel.length,
            itemBuilder: (context, index) {
              var order = historyController.historyBengkel[index];
              return buildOrderItem(
                  order['order']['pickup'],
                  order['order']['pembayaran'][0]['total'].toString(),
                  Icons.tire_repair,
                  Colors.blue);
            });
      }
    });
  }

  Widget buildOrderItem(
      String title, String price, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color,
            child: Icon(icon, color: Colors.white),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 16),
              SizedBox(width: 5),
              Text('Perjalanan selesai'),
            ],
          ),
          trailing: Text(
            historyController.formatRupiah(double.parse(price)),
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
      ),
    );
  }
}
