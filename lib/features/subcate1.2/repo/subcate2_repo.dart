import 'dart:convert';
import 'package:http/http.dart';
import 'package:self_learning_app/features/category/data/model/category_model.dart';
import 'package:self_learning_app/features/subcategory/model/sub_cate_model.dart';
import '../../../../utilities/base_client.dart';
import '../model/sub_cate_model.dart';

class SubCategory2Repo {

  static Future<List<SubCategory2Model>> getAllCategory(String? rootId) async {
    Response res = await Api().get(
        endPoint: 'category/?rootId=$rootId',
    );
    var data = await jsonDecode(res.body);
    print(data);
    List<dynamic> recordata = data['data']['record'];
    List<SubCategory2Model> recordList = [];
    if (recordata.isEmpty) {
      return recordList;
    } else {
      for (var element in recordata) {
        recordList.add(SubCategory2Model.fromJson(element));
      }
    }
    return recordList;
  }


  // static Future<List<SubCategoryModel>> getAllSubCategory(String? rootId) async {
  //   Response res = await Api().get(
  //     endPoint: 'category/?rootId=$rootId',
  //   );
  //   print(res.body);
  //   print('subcategory body');
  //   var data = await jsonDecode(res.body);
  //   List<dynamic> recordata = data['data']['record'];
  //   List<SubCategoryModel> recordList = [];
  //   if (recordata.isEmpty) {
  //     return recordList;
  //   } else {
  //     for (var element in recordata) {
  //       recordList.add(SubCategoryModel.fromJson(element));
  //     }
  //   }
  //   return recordList;
  // }

//Search Category


}
