import 'package:get/get.dart';

import '../directions_model.dart';

class DirectionsProvider extends GetConnect {
  @override
  void onInit() {
    httpClient.defaultDecoder = (map) {
      if (map is Map<String, dynamic>) return Directions.fromMap(map);
      if (map is List) {
        return map.map((item) => Directions.fromMap(item)).toList();
      }
    };
    httpClient.baseUrl = 'YOUR-API-URL';
  }

  Future<Directions?> getDirections(int id) async {
    final response = await get('directions/$id');
    return response.body;
  }

  Future<Response<Directions>> postDirections(Directions directions) async =>
      await post('directions', directions);
  Future<Response> deleteDirections(int id) async =>
      await delete('directions/$id');
}
