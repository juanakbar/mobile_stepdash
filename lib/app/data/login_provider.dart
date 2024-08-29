import 'package:get/get.dart';
import 'package:stepmotor/env.dart';

class LoginProvider extends GetConnect {
  Future<Response> attempt(Map<String, dynamic> data) {
    return post('$BASE_API_URL/login', data, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    });
  }

  Future<Response> logout(String token) {
    return delete('$BASE_API_URL/logout', headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
  }
}
