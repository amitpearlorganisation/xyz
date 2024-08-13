import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:self_learning_app/features/category/data/model/category_model.dart';
import 'package:self_learning_app/features/search_category/data/search_cate_model.dart';
import '../../../../utilities/base_client.dart';

class SearchCategoryRepo {

  //Search Category

  static Future<List<SearchCategoryModel>> searchCategories(String? query) async {
    print('inside srarch ctegory');
    Response res = await Api().get(
      endPoint: 'category/search?keyword=$query',

    );
    print(res.body);
    print("Query:${query}");
    print('-0-0-0-${res.body}');
    var data = await jsonDecode(res.body);
    print("data:-----${data}");
    List<dynamic> recordata = data['data']['record'];
    List<SearchCategoryModel> recordList = [];
    if (recordata.isEmpty) {
      return recordList;
    } else {
      for (var element in recordata) {
        recordList.add(SearchCategoryModel.fromJson(element));
      }
    }
    return recordList;
  }

}
