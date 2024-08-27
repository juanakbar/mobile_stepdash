import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:stepmotor/app/modules/ride/directions_model.dart';
import 'package:uuid/uuid.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sp_util/sp_util.dart';

class PlacesApiProvider extends GetConnect {
  final String apiKey = 'AIzaSyBJcFAXOkV0woU4RaV9rHbTQRpUcMrJ8Ww';
  var uuid = Uuid();
  Future<Response> getSuggestions(String input) async {
    return await get(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey&sessiontoken=${uuid.v4()}');
  }

  Future<Response> getSettings() async {
    try {
      final response = await get(
        'http://localhost:8000/api/settings',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${SpUtil.getString('token')}',
        },
      );

      if (response.statusCode == 200) {
        print("Response body: ${response.body}");
        return response; // Return the whole Response object for more flexibility
      } else {
        print('Failed to load settings: ${response.statusCode}');
        throw Exception('Failed to load settings');
      }
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('Error occurred while fetching settings , $e');
    }
  }

  Future<Directions> getDirections(
      {required LatLng origin, required LatLng destination}) async {
    String url = 'https://maps.googleapis.com/maps/api/directions/json?';
    var response = await get(url, query: {
      'origin': '${origin.latitude},${origin.longitude}',
      'destination': '${destination.latitude},${destination.longitude}',
      'key': apiKey,
    });
    if (response.statusCode == 200) {
      return Directions.fromMap(response.body);
    } else {
      return Directions.fromMap(response.body);
    }
  }
}

// origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey

