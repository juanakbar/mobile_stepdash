import 'package:get/get.dart';

class RideController extends GetxController {
  //TODO: Implement RideController
  final count = 0.obs;
  RxList settting = [].obs;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;

  double calculateTotalCost(String distanceText, double ratePerKm) {
    // Convert the distance string (e.g., "10.5 km") to a double value
    double distanceKm = _parseDistance(distanceText);
    printInfo(info: 'Distance: $distanceKm');
    // Calculate the total cost by multiplying the distance by the rate per KM
    double totalCost = distanceKm * ratePerKm;
    printInfo(info: 'Total Cost: $totalCost');
    return totalCost;
  }

  double _parseDistance(String distanceText) {
    // Remove the " km" suffix and parse the remaining number
    return double.parse(distanceText.replaceAll(' km', ''));
  }

  Future<void> createOrder(dataOrder) async {
    try {
      
    } catch (e) {
      print('Failed to create order: $e');
    }
  }
}
