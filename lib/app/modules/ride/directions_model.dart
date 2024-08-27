import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter/foundation.dart';

class Directions {
  final LatLngBounds bounds;
  final List<PointLatLng> polylinePoints;
  final String totalDistance;
  final String totalDuration;

  const Directions({
    required this.bounds,
    required this.polylinePoints,
    required this.totalDistance,
    required this.totalDuration,
  });
  factory Directions.fromMap(Map<String, dynamic> map) {
    // Memeriksa apakah 'routes' tidak kosong dan merupakan daftar
    if (map['routes'] == null || (map['routes'] as List).isEmpty) {
      throw Exception('No routes data available');
    }

    // Mengambil data dari rute pertama
    final data = Map<String, dynamic>.from(map['routes'][0]);

    // Memeriksa apakah 'bounds' ada dan memiliki data yang diperlukan
    if (data['bounds'] == null ||
        data['bounds']['northeast'] == null ||
        data['bounds']['southwest'] == null) {
      throw Exception('Bounds data is missing');
    }

    // Mendapatkan koordinat batas timur laut dan barat daya
    final northeast = data['bounds']['northeast'];
    final southwest = data['bounds']['southwest'];
    final bounds = LatLngBounds(
      northeast: LatLng(northeast['lat'], northeast['lng']),
      southwest: LatLng(southwest['lat'], southwest['lng']),
    );

    // Inisialisasi nilai default untuk distance dan duration
    String distance = '';
    String duration = '';

    // Memeriksa apakah 'legs' tidak kosong dan merupakan daftar
    if (data['legs'] != null && (data['legs'] as List).isNotEmpty) {
      final leg = data['legs'][0];
      distance = leg['distance']['text'];
      duration = leg['duration']['text'];
    } else {
      throw Exception('Legs data is missing or empty');
    }

    // Memeriksa apakah 'overview_polyline' ada dan memiliki data
    if (data['overview_polyline'] == null ||
        data['overview_polyline']['points'] == null) {
      throw Exception('Polyline data is missing');
    }

    // Mengembalikan objek Directions
    return Directions(
      bounds: bounds,
      polylinePoints:
          PolylinePoints().decodePolyline(data['overview_polyline']['points']),
      totalDistance: distance,
      totalDuration: duration,
    );
  }
}
