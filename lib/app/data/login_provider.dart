import 'package:get/get.dart';

class LoginProvider extends GetConnect {
  Future<Response> attempt(Map<String, dynamic> data) {
    return post('http://10.0.2.2:8000/api/login', data, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    });
  }

  Future<Response> logout(String token) {
    return delete('http://10.0.2.2:8000/api/logout', headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
  }
}
