import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:self_learning_app/features/dailog_category/bloc/add_prompt_res_cubit.dart';
import 'package:self_learning_app/features/dailog_category/dailog_cate_screen.dart';
import 'package:self_learning_app/utilities/shared_pref.dart';

import '../../../utilities/constants.dart';

class DailogRepo{
  static Dio _dio = Dio();

  static Future<Response?> addDailog({required String dailog_name, required List resourceId, required List prompt, required String color,
    required List tags

  }) async{
    print("add dailog fun run");
    print("select prompt Id $prompt, selected resourceid=$resourceId");
/*
    String token = SharedPref.getUserToken();
*/
    var token = await SharedPref().getToken();

    Map<String, dynamic> headers = {
      'Authorization': 'bearer' + ' ' + token.toString(),
    };
    print("colors$color");
    List<Map<String, String>> styles = [
      {"key": "font-size", "value": "2rem"},
      {"key": "background-color", "value": color!.toString()}
    ];
    print("${dailog_name + color + tags.toString()}");
    Map<String, dynamic> payload = {};
    payload.addAll({
      "name": dailog_name.toString(),
    });
    payload.addAll({"resourceIds": resourceId});
    payload.addAll({'promptIds':prompt});
    payload.addAll({"keywords": tags});
    payload.addAll({"styles": styles});
    print("keywrods-==$payload");
    print("requestBody$payload");
    try{
      print("try bloc is run");
      Response res = await _dio.post("https://backend.savant.app/web/category/create-dialog",
          data: jsonEncode(payload),
          options: Options(headers: headers)
          );
      print("respone of dailog ${res.data}");
      if(res.statusCode == 200){
        print(res);
        print("inside of 2000 respone of dailog ${res.data}");

      }
      else{
        print(res);
        print("inside of else condition respone of dailog ${res.data}");

      }
      return res;
    }
    catch(e){
      print("error $e");
      return null;
    }

  }

  static Future<Response?> getDailog() async{
    var token = await SharedPref().getToken();
    String endpoints = "category/get-dialogs";
    String baseUrl = DEVELOPMENT_BASE_URL + endpoints;

    Map<String, dynamic> headers = {
      'Authorization': 'bearer' + ' ' + token.toString(),
    };
    try{
      Response res = await _dio.get("$baseUrl",  options: Options(headers: headers));
      return res;
    }
    catch(e){
      print("error ${e.toString()}");
    }

  }

  static Future<Response> deleteDailog({required String dailogId}) async {
    var token = await SharedPref().getToken();

    Map<String, dynamic> headers = {
      'Authorization': 'bearer' + ' ' + token.toString(),
    };    Response res;
    try {
      res = await _dio.delete(
          'https://backend.savant.app/web/category/${dailogId}',
          options: Options(
            headers:headers,
          )
      );
      print("dailog delete response$res");

      //print(res.body);
      //print('data');
    } on DioError catch (_) {
      res = Response(requestOptions: RequestOptions());
      res.statusCode = 400;
    }

    return res;
  }

  static Future<Response> saveDailog({required String dailogId, required String title, required List<String> promptId, required BuildContext context}) async {
    print("dailog repo hit");
    var token = await SharedPref().getToken();

    Map<String, dynamic> headers = {
      'Authorization': 'bearer' + ' ' + token.toString(),
    };    Response res;
    final List<Map<String, String>> dataToSend = promptId
        .map((promptId) => {'promptId': promptId})
        .toList();
    try {
      res = await _dio.post(
          'https://backend.savant.app/web/flow',
          data: {
            'categoryId': dailogId,
            'title': title,
            'flow': dataToSend,
            'type':'dialog'
          },

          options: Options(
            headers: headers,
          )
      );
      print("flow created success response$res");
      print(res.statusCode);
      if (res.statusCode==201){
       EasyLoading.showSuccess("Dailog Created Success", duration: Duration(seconds: 3));
       Navigator.pop(context,true);
       context.read<AddPromptResCubit>().getFlowDialog(dailogId: dailogId);
       Navigator.pop(context,true);

      }

      //print(res.body);
      //print('data');
    } on DioError catch (_) {
      res = Response(requestOptions: RequestOptions());
      res.statusCode = 400;
    }

    return res;
  }

}