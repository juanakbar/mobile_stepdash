import 'package:get/get.dart';
import 'package:sp_util/sp_util.dart';

class UserProvider extends GetConnect {
  Future<Response> getMyProfile() async {
    final response = await get('http://localhost:8000/api/me', headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${SpUtil.getString('token')}',
    });
    return response;
  }

  Future<Response> updateProfile(Map<String, dynamic> data) async {
    final response =
        await patch('http://localhost:8000/api/me', data, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${SpUtil.getString('token')}',
    });
    return response;
  }

  Future<Response> createOrder(Map<String, dynamic> data) async {
    final response =
        await post('http://10.0.2.2:8000/api/create_order', data, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${SpUtil.getString('token')}',
    });
    return response;
  }
}
