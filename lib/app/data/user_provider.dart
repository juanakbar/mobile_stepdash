import 'package:get/get.dart';
import 'package:sp_util/sp_util.dart';
import 'package:stepmotor/env.dart';

class UserProvider extends GetConnect {
  Future<Response> getMyProfile() async {
    final response = await get('$BASE_API_URL/me', headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${SpUtil.getString('token')}',
    });
    return response;
  }

  Future<Response> updateProfile(Map<String, dynamic> data) async {
    final response = await patch('$BASE_API_URL/me', data, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${SpUtil.getString('token')}',
    });
    return response;
  }

  Future<Response> createOrder(Map<String, dynamic> data) async {
    print('DATA FROM PROVIDER: $data');
    return await post('$BASE_API_URL/create_order', data, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${SpUtil.getString('token')}',
    });
  }

  Future<Response> getBengkels() async {
    return await get('$BASE_API_URL/bengkels', headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${SpUtil.getString('token')}',
    });
  }
}
