import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:self_learning_app/features/promt/promts_screen.dart';
import 'package:self_learning_app/features/quick_add/data/bloc/quick_add_bloc.dart';
import 'package:self_learning_app/features/quick_add/data/repo/model/quick_type_model.dart';
import 'package:self_learning_app/utilities/constants.dart';
import '../../../../utilities/base_client.dart';


import '../../../../utilities/shared_pref.dart';
import 'model/flow_model.dart';
import 'model/promt_model.dart';




class PromtRepo {
  static Future<PromtAndAddFlowModel> getPromts(
      {required String promtId, required Prompt fromType}) async {
    String idType;
    if(fromType == Prompt.fromResource){
      idType = 'resourceId';
    }else if(fromType == Prompt.fromFlow){
      idType = 'flowId';
    }else{
      idType = 'categoryId';
    }
    Response res = await Api().get(
      endPoint: 'prompt?$idType=$promtId',);
    print(res.body);
    print('res.body');
    var data = await jsonDecode(res.body);
    final List<PromtModel> list = [];

    final List<dynamic> mylist = data['data']['record'];
    AddFlowModel.fromJson(data);
    if (mylist.isNotEmpty) {
      for (var l in mylist) {
        list.add(PromtModel.fromJson(l));
      }
    }
    return PromtAndAddFlowModel(
        addFlowModel: AddFlowModel.fromJson(data), promtList: list);
  }
}


