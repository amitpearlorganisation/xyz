import 'dart:convert';
import 'package:dio/dio.dart';

import 'package:self_learning_app/features/search_category/data/search_cate_model.dart';
import 'package:self_learning_app/utilities/shared_pref.dart';

class SearchSubCategoryRepo {

  //Search Category

  static Future<List<SearchCategoryModel>> searchSubCategories(String? query, String? rootId) async {
     final Dio _dio = Dio(); // Create a Dio instance
     final token = await SharedPref().getToken();
     print("sub cat token $token");

    Response res = await _dio.get("https://backend.savant.app/web/category/search?keyword=$query",
    queryParameters: {'categoryId': rootId},

        options: Options(
          headers: {
            'Authorization': 'Bearer ${token}', // Add the bearer token header
          },
        )
    );
    print("categoryid ---$rootId");
    print("Query:${query}");
    print('-0-0-0-${res.data}');
    var data =  res.data;
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
