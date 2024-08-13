

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../utilities/base_client.dart';
import '../../../../utilities/shared_pref.dart';

class CreateFlowRepo {
  static Future<Response?> createFlow(
      {required String title,}) async {
    try {
      final token = await SharedPref().getToken();

      var request = await Dio().post(
          'https://backend.savant.app/web/prompt/',
          data: {
            'title': title,
          },
          options: Options(
              headers: {"Authorization": 'Bearer $token'}
          ));
      return request;
    } catch (e) {
      print(e);
    }
    return null;
  }
  static Future<Response?> selectFlow({required String flowId,required String flowType, required String rootId,

  required String flowTitle
  }) async {
    print("uuuid");
    try {
      final token = await SharedPref().getToken();
      print("---my token $token");
      Response res = await Dio().put(
          'https://backend.savant.app/web/flow/update/$flowId',
          data: {
            'type': "primary",
            'title':'$flowTitle',
            'categoryId':'$rootId'
          },
          options: Options(
              headers: {"Authorization": 'Bearer $token'}
          ));
      print("status code of flow select${res.statusCode}");
      print(res.data);
      return res;
    }catch(e){
      print("catch error");
      print(e);
    }
  }

  static Future<Response> getAllFlow({required String catID, String? keyword}) async {
    Response response;

    try{
      final token = await SharedPref().getToken();
      print("we need to fecth cat id "+ catID);
      print("we need to fecth token "+ token!);

      response = await Dio().get(
          'https://backend.savant.app/web/flow?categoryId=$catID&keyword=$keyword',
          options: Options(
              headers: {"Authorization": 'Bearer $token'}
          ));
      print("response flow ${response}");
    }on DioError catch (e) {
      response = Response(requestOptions: RequestOptions());
      response.data = {
        'msg' : 'Failed to communicate with server!',
        'errorMsg' : e.toString(),
      };
      response.statusCode = 400;
    }

    print('Flowww $response');
    print("break");
    return response;
  }

  static Future<Response> deleteFlow({required String flowId}) async {
    Response response;

    try{
      final token = await SharedPref().getToken();
      response = await Dio().delete(
          'https://backend.savant.app/web/flow/$flowId',
          options: Options(
              headers: {"Authorization": 'Bearer $token'}
          ));
    }on DioError catch (e) {
      response = Response(requestOptions: RequestOptions());
      response.data = {
        'msg' : 'Failed to communicate with server!',
        'errorMsg' : e.toString(),
      };
      response.statusCode = 400;
    }

    return response;
  }
  static Future<Response> selectedPrompts ({required String flowId}) async{
    Response response;
    try{
      final token = await SharedPref().getToken();
      response = await Dio().post("https://backend.savant.app/web/flow/$flowId",
      options: Options(
        headers: {"Authorization": 'Bearer $token'}
      )
      );

    }on DioError catch (e) {
      response = Response(requestOptions: RequestOptions());
      response.data = {
        'msg' : 'Failed to communicate with server!',
        'errorMsg' : e.toString(),
      };
      response.statusCode = 400;
    }
    return response;

  }

}
