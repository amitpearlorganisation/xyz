import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:self_learning_app/utilities/shared_pref.dart';
import 'constants.dart';


class Api {
  // get client helper
  Future<Response> get({required String endPoint}) async {
    try {
      var token = await SharedPref().getToken();
      const int TIME_OUT_DURATION = 50;
      String base = DEVELOPMENT_BASE_URL;
      var url = Uri.parse(base + endPoint);
      print(url);

      final response = await http.get(url,headers: {
        'Authorization': 'bearer' + ' ' + token.toString(),
      },).timeout(const Duration(seconds: TIME_OUT_DURATION));
      return response;
    } on SocketException {
      throw ('No Internet Connection');
    } on TimeoutException {
      throw ('API not responded in time');
    }
  }

  // post api client

  Future<http.Response> post({required String endPoint,
        required Map<String, dynamic> payload}) async {
      var token = await SharedPref().getToken();
      String base = DEVELOPMENT_BASE_URL;
      var uri = Uri.parse(base + endPoint);
      var response = await http.post(uri,headers: {
        'Authorization': 'bearer' + ' ' + token.toString(),
      }, body: payload);
      return response;
    }



  Future<http.Response> delete({required String endPoint,}) async {
    var token = await SharedPref().getToken();
    String base = DEVELOPMENT_BASE_URL;
    var uri = Uri.parse(base + endPoint);
    var response = await http.delete(uri,headers: {
      'Authorization': 'bearer' + ' ' + token.toString(),
    },);
    return response;
  }
  }




