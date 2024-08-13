import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import '../../../../utilities/constants.dart';
import '../../../../utilities/shared_pref.dart';

class LoginRepo {
  static Future<int?> loginUser(
      {required String email, required String password}) async {
    print("login api");
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    String? fcmtoken = await _firebaseMessaging.getToken();

    print("fcm token is ${fcmtoken}");
    String endpoints = "user/login";
    String baseUrl = DEVELOPMENT_BASE_URL + endpoints;
    final response =
    await http.post(
        Uri.parse('$baseUrl'),
        body: {"email": email, "password": password,
        "deviceToken":fcmtoken
        });
    print("login api 2");
    print("login_response${response.statusCode}");
    if (response.statusCode == 201) {
      print("login response ${response.body}");
      print("---------break");
      print(response.body);
      var res = jsonDecode(response.body);
      SharedPref().clear();
      SharedPref().saveToken(res['data']['token']);
    }
    return response.statusCode;
  }
}
