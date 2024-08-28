import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as serviceHttp;
import 'package:sp_util/sp_util.dart';

class HistoryController extends GetxController {
  //TODO: Implement HistoryController

  final count = 0.obs;
  RxList<Map<String, dynamic>> historyFootStep = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> historyBengkel = <Map<String, dynamic>>[].obs;
  RxInt totalPendapatan = 0.obs;
  @override
  void onInit() {
    super.onInit();
    getHistoryFootStep(1);
    getHistoryBengkel(2);
    getTotalPendapatan();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  String formatRupiah(double amount) {
    final NumberFormat formatter = NumberFormat('#,##0.00', 'id_ID');
    String formattedAmount = formatter.format(amount);
    return 'Rp $formattedAmount';
  }

  void getTotalPendapatan() async {
    EasyLoading.show(status: 'Loading...');
    try {
      final response = await serviceHttp.get(
          Uri.parse('http://10.0.2.2:8000/api/total_pendapatan_user'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            "Authorization": 'Bearer ${SpUtil.getString('token')}',
            'Accept': 'application/json',
          });
      print(response.body);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        totalPendapatan.value = jsonResponse;
        EasyLoading.dismiss();
      } else {
        print('Error Fetch: ${response.body}');
        EasyLoading.showError('Error');
      }
    } catch (e) {
      print('Error Fetch: $e');
      EasyLoading.showError('Error');
    } finally {
      EasyLoading.dismiss();
    }
  }

  void getHistoryFootStep(layananID) async {
    EasyLoading.show(status: 'Loading...');
    try {
      final response = await serviceHttp.get(
          Uri.parse('http://10.0.2.2:8000/api/history?layanan=$layananID'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            "Authorization": 'Bearer ${SpUtil.getString('token')}',
            'Accept': 'application/json',
          });
      print(response.body);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse is List) {
          // Mengkonversi List<dynamic> ke List<Map<String, dynamic>>
          List<Map<String, dynamic>> parsedData =
              List<Map<String, dynamic>>.from(jsonResponse);
          // Menyimpan hasil konversi ke getRequest
          historyFootStep.value = parsedData;
        } else {
          // Tangani kasus jika data tidak sesuai dengan format yang diharapkan
          print("Data tidak dalam format yang diharapkan");
        }
        EasyLoading.dismiss();
      } else {
        print('Error Fetch: ${response.body}');
        EasyLoading.showError('Error');
      }
    } catch (e) {
      print('Error Fetch: $e');
      EasyLoading.showError('Error');
    } finally {
      EasyLoading.dismiss();
    }
  }

  void getHistoryBengkel(layananID) async {
    EasyLoading.show(status: 'Loading...');
    try {
      final response = await serviceHttp.get(
          Uri.parse('http://10.0.2.2:8000/api/history?layanan=$layananID'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            "Authorization": 'Bearer ${SpUtil.getString('token')}',
            'Accept': 'application/json',
          });
      print(response.body);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse is List) {
          // Mengkonversi List<dynamic> ke List<Map<String, dynamic>>
          List<Map<String, dynamic>> parsedData =
              List<Map<String, dynamic>>.from(jsonResponse);
          // Menyimpan hasil konversi ke getRequest
          historyBengkel.value = parsedData;
        } else {
          // Tangani kasus jika data tidak sesuai dengan format yang diharapkan
          print("Data tidak dalam format yang diharapkan");
        }
        EasyLoading.dismiss();
      } else {
        print('Error Fetch: ${response.body}');
        EasyLoading.showError('Error');
      }
    } catch (e) {
      print('Error Fetch: $e');
      EasyLoading.showError('Error');
    } finally {
      EasyLoading.dismiss();
    }
  }

  void increment() => count.value++;
}
