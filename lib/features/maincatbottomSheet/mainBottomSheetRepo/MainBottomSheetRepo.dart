import 'dart:convert';

import '../../../utilities/base_client.dart';
import '../../../utilities/constants.dart';
import '../../../utilities/shared_pref.dart';
import '../../subcategory/model/sub_cate_model.dart';

import 'package:dio/dio.dart';

class MainBottomSheetRepo{

  static final Dio _dio = Dio();

  static Future<Response?> getAllSubCategory({required String rootId})async{
    var token = await SharedPref().getToken();

    Map<String, dynamic> headers = {
      'Authorization': 'bearer' + ' ' + token.toString(),
    };
    String base = DEVELOPMENT_BASE_URL;
    String endPoint = "category/?rootId=$rootId";
    var url = Uri.parse(base + endPoint);
    try{
      Response res = await _dio.get("$url",options: Options(headers: headers));
      print("9999-${res.data.toString()}");

      return res;


    }catch(e){
      print("00000-${e.toString()}");
    }
  }




}