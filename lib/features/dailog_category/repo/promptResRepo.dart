import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:self_learning_app/utilities/shared_pref.dart';

import '../bloc/add_prompt_res_cubit.dart';

class PromptResRepo {
  static final Dio _dio = Dio();

static Future<Response?> get_Res_Prompt({required String dailogId})async{
  var token = await SharedPref().getToken();

  Map<String, dynamic> headers = {
    'Authorization': 'bearer' + ' ' + token.toString(),
  };
  try{
    Response res = await _dio.get("https://backend.savant.app/web/category/get-dialog-detail?dialogId=$dailogId",options: Options(headers: headers));
    print("9999-${res.data.toString()}");

    return res;


  }catch(e){
 print("00000-${e.toString()}");
  }
}
  static Future<Response?> AddPromptInResource({required String resourceId,
    required String promptId, required String
  dialogId
  })async{
    var token = SharedPref().getToken();

    final Map<String, dynamic> headers = {
      'Authorization': 'Bearer $token',
    };
   try{
     Response res = await _dio.put("https://backend.savant.app/web/",options: Options(headers: headers),
     data: {"resourceId":resourceId,
            "promptId":promptId
     }
     );
     return res;

   }catch(e){

   }


  }

  static Future<Response?> getPrompResource({required String resourceId}) async {
    var token = await SharedPref().getToken();

    Map<String, dynamic> headers = {
      'Authorization': 'bearer' + ' ' + token.toString(),
    };
    try{
      Response res = await _dio.get("https://backend.savant.app/web/prompt?resourceId=$resourceId",options: Options(headers: headers));
      return res;

    }catch(e){
        print(e);
    }

  }

  static Future<Response> deleteResource({required String resourceId}) async {
    var token = await SharedPref().getToken();
    Response res;
    try {
      res = await _dio.delete(
          'https://backend.savant.app/web/resource/${resourceId}',
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token'
            },
          )
      );

      //print(res.body);
      //print('data');
    } on DioError catch (_) {
      res = Response(requestOptions: RequestOptions());
      res.statusCode = 400;
    }

    return res;
  }

  static Future<Response?> updatePrompt({required List<String> listpromtId, required String dialogId, required BuildContext context})async{

    print("=-===-=-===-=-===--=>$listpromtId");
    var token = await SharedPref().getToken();
    final Map<String, dynamic> headers = {
      'Authorization': 'Bearer $token',
    };
    try{

      Response res = await _dio.patch("https://backend.savant.app/web/prompt/update/$dialogId",options: Options(headers: headers),
          data: ({"promptIds":listpromtId,
            "categoryId":dialogId
          })
      );
      print("update prompt list -------> ${res.statusCode}");
      if(res.statusCode ==200){
        EasyLoading.showSuccess("prompt add successfully", duration: Duration(seconds: 1));
        await Future.delayed(Duration(seconds: 1));
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);

      }
      return res;

    }catch(e){
      EasyLoading.showToast(e.toString());
      print("here is catch error is found${e.toString()}");
    }
  }

  static Future<Response?> fethResourcePrompt({ required String dialogId})async{

    var token = await SharedPref().getToken();
    final Map<String, dynamic> headers = {
      'Authorization': 'Bearer $token',
    };
    try{

      Response res = await _dio.get("https://backend.savant.app/web/category/get-resource-prompt-list/$dialogId",options: Options(headers: headers),
      );

      return res;

    }catch(e){
      EasyLoading.showToast(e.toString());
      print("here is catch error is found${e.toString()}");
    }
  }



}