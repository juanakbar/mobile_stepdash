import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:stepmotor/failure.dart';
import 'package:http/http.dart' as http;
import 'package:stepmotor/tokenModel.dart';
import 'package:sp_util/sp_util.dart';

class TokenService {
  Future<Either<Failure, TokenModel>> getToken(payload) async {
    // Payload
    // var payload = {
    //   "id": DateTime.now().millisecondsSinceEpoch, // Unique Id
    //   "productName": "Mentos Marbels",
    //   "price": 2500,
    //   "quantity": 2
    // };

    try {
      var response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/create_token'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          "Authorization": 'Bearer ${SpUtil.getString('token')}',
        },
        body: payload,
      );
      print(response.body);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        return right(TokenModel(token: jsonResponse.toString()));
      } else {
        return left(ServerFailure(
            data: response.body,
            code: response.statusCode,
            message: 'Unknown Error'));
      }
    } catch (e) {
      return left(ServerFailure(
          data: e.toString(), code: 400, message: 'Unknown Error'));
    }
  }
}
