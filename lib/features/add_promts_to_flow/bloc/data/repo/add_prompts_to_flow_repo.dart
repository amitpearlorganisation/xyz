



import 'dart:convert';

import 'package:bloc/src/bloc.dart';
import 'package:dio/dio.dart';
import 'package:self_learning_app/features/add_promts_to_flow/bloc/data/model/category_model.dart';

import 'package:self_learning_app/features/add_promts_to_flow/bloc/data/model/prompt_model.dart';

import '../../../../../utilities/base_client.dart';
import '../../../../../utilities/shared_pref.dart';
import '../model/add_prompt_to_flow_model.dart';

class AddPromptsToFlowRepo {

  static Future<AddPromptToFlowModel?> getData({required String mainCatId}) async {
    final token = await SharedPref().getToken();

    print("0000---$mainCatId");
    final Options options = Options(
        headers: {"Authorization": 'Bearer $token'}
    );
    Response res = await Dio().get(
      'https://backend.savant.app/web/prompt?categoryId=$mainCatId',
      options: options,
    );
    print("------@@$res");
    print("----------###break");


    print('Main Cat ID: $mainCatId');
    print(res.data);    //var data = await jsonDecode(res.body);
    final AddPromptToFlowModel list;

    List<PromptModel> promptList = [];
    List<CategoryModel> categoryList = [];
    for (var item in res.data['data']['record']) {
      print(item);
      if(item != null){
        promptList.add(PromptModel(
          promptId: item['_id'],
          resourceId: item['resourceId']?['_id']??'',
          title: item['name'],
          isSelected: item['isActive'],
        ));
      }
    }

    Response res1 = await Dio().get(
      'https://backend.savant.app/web/category/?rootId=$mainCatId',
      options: options,
    );
    print('OK tested');
    print(res1.data);
    for (var item in res1.data['data']['record']) {
      categoryList.add(CategoryModel(categoryId: item['_id'], title: item['name']));
    }

    list = AddPromptToFlowModel(promptList: promptList, categoryList: categoryList);
    if(res.statusCode != 200 ) {
      return null;
    }
    return list;
  }
}