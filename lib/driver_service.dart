import 'dart:math'; // Untuk menghitung jarak menggunakan Haversine Formula
import 'package:firebase_database/firebase_database.dart'; // Package untuk akses Firebase RTDB

class DriverService {
  DatabaseReference ref = FirebaseDatabase.instance.ref("drivers");

  Future<String?> findNearestDriver(double userLat, double userLong) async {
    try {
      DatabaseEvent _driverRef = await ref.once();
      Map<dynamic, dynamic>? drivers =
          _driverRef.snapshot.value as Map<dynamic, dynamic>?;
      print("DATA DRIVER $drivers");
      if (drivers == null) {
        return null; // Jika tidak ada data driver
      }
      print("userLat $userLat");
      String? nearestDriverId;
      double nearestDistance = double.infinity;

      // Loop untuk mengecek setiap driver
      drivers.forEach((key, value) {
        if (value['status'] == 'Online' && value['busy'] == false) {
          double driverLat = value['location']['latitude'];
          double driverLong = value['location']['longitude'];

          double distance =
              _calculateDistance(userLat, userLong, driverLat, driverLong);
          print("distance $distance");
          if (distance <= 1 && distance < nearestDistance) {
            print("DATA DRIVER KEY $key");
            // Jarak dalam kilometer
            nearestDistance = distance;
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

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Radius bumi dalam kilometer

    double dLat = _degreeToRadian(lat2 - lat1);
    double dLon = _degreeToRadian(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreeToRadian(lat1)) *
            cos(_degreeToRadian(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreeToRadian(double degree) {
    return degree * pi / 180;
  }
}
