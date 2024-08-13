import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../utilities/shared_pref.dart';
import 'flow_model.dart';

class AddPromptNew {
  static Future<void> addFlow({required AddFlowModel? flow}) async {
    var token = await SharedPref().getToken();

    print(flow!.toJson());
    print("flow.toJson()");

    final dd = jsonEncode(flow.toJson());
    print(dd);
    print("dd");
    print("flow!.toJson()");

    // Create a new Dio instance
    Dio dio = Dio();

    // You can set the authorization header like this
    dio.options.headers['Authorization'] = 'bearer $token';

    try {
      // Make the POST request using Dio
      Response response = await dio.post(
        'https://backend.savant.app/web/flow',
        data: dd, // Use the JSON string as the request body
      );

      print(response.data);
      print('res.body');

      // Parse the response JSON if needed
      var gg = response.data;
    } catch (error) {
      print('Error: $error');
    }
  }
}
