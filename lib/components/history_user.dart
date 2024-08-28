import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stepmotor/app/modules/History/controllers/history_controller.dart';

class HistoryUserView extends StatefulWidget {
  @override
  _HistoryUserViewState createState() => _HistoryUserViewState();
}

class _HistoryUserViewState extends State<HistoryUserView> {
  bool isFootstepSelected = true;
  HistoryController historyController = Get.put(HistoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isFootstepSelected = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isFootstepSelected ? Colors.red : Colors.grey.shade300,
                    foregroundColor:
                        isFootstepSelected ? Colors.white : Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                  child: const Text('Footstep'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isFootstepSelected = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        !isFootstepSelected ? Colors.red : Colors.grey.shade300,
                    foregroundColor:
                        !isFootstepSelected ? Colors.white : Colors.black,
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
                  isFootstepSelected ? buildFootstepBody() : buildBengkelBody(),
            ),
          ),
        ],
      ),
    );
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
                  order['order']['dropoff'],
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
