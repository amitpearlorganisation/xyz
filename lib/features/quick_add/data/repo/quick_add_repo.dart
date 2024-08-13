import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:self_learning_app/features/quick_add/data/bloc/quick_add_bloc.dart';
import 'package:self_learning_app/features/quick_add/data/repo/model/quick_type_model.dart';
import 'package:self_learning_app/utilities/constants.dart';
import '../../../../utilities/base_client.dart';
import 'package:http/http.dart' as http;

import '../../../../utilities/shared_pref.dart';

class QuickAddRepo {
  static Future<int?> quickAdd(
      {required String title, required int contentType}) async {
    print('add category');
    Response res = await Api().post(
      payload: {"type": "QUICKADD", "content": title},
      endPoint: 'resource/quickAdd',
    );
    var data = await jsonDecode(res.body);
    return res.statusCode;
  }

  static Future<int?> deletequickAdd(
      {required String id, required BuildContext context}) async {
    print('deletee category');
    var token = await SharedPref().getToken();
    var url = Uri.parse('https://backend.savant.app/web/resource/$id');
    print(url);
    Response res = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    print(res.body);
    print('res.body');

    //'resource/quickAdd'
    var data = await jsonDecode(res.body);
    print(data);

    return res.statusCode;
  }

  static Future<QuickTypeModel> getAllQuickTypes() async {
    Response res = await Api().get(
      endPoint: 'resource/quickAdd',
    );
    var data = await jsonDecode(res.body);
    print("quick resource data $data");
    return QuickTypeModel.fromJson(data);
  }


}
