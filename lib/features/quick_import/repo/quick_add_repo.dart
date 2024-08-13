import 'dart:convert';
import 'package:http/http.dart';
import '../../../../utilities/base_client.dart';
import 'package:http/http.dart' as http;
import '../../../../utilities/shared_pref.dart';
import '../../category/bloc/category_bloc.dart';
import '../../dashboard/bloc/dashboard_bloc.dart';
import 'model/quick_type_model.dart';

class QuickImportRepo {
  static Future<List<QuickImportModel>> getAllCategory({String? rootId}) async {
    Response res = await Api().get(
      endPoint: 'category/${rootId ?? ''}',
    );
    var data = await jsonDecode(res.body);
    print(data);
    List<dynamic> recordata = data['data']['record'];
    List<QuickImportModel> recordList = [];
    if (recordata.isEmpty) {
      return recordList;
    } else {
      for (var element in recordata) {
        recordList.add(QuickImportModel.fromJson(element));
      }
    }
    return recordList;
  }

  static Future<int?> deletequickAdd({
    required String id,
  }) async {
    print('delete category');
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
    var data = await jsonDecode(res.body);
    return res.statusCode;
  }

  static Future<String> addCategory({String? title, String? rootId}) async {
    Map<String, dynamic> payload = {};
    List<String> keywords = [];
    List<Map<String, String>> styles = [
      {"key": "font-size", "value": "12"},
      {"key": "background-color", "value": '4280079139'}
    ];
    payload.addAll({
      "name": title,
    });
    payload.addAll({"keywords": keywords});
    payload.addAll({"styles": styles});
    if (rootId != null) {
      payload.addAll({"rootId": rootId});
    }
    var token = await SharedPref().getToken();
    var res = await http.post(
      Uri.parse('https://backend.savant.app/web/category/create'),
      body: jsonEncode(payload),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );
    final body = jsonDecode(res.body);
    print("add category function is working now${body}");
    print('response of add category');
    return body['data']['record']['id'];
  }

  static Future<int?> updateResources(
      {required String rootId,
      required String resourceId,
      required String mediaType,
      required String resourceTitle,
      required String resourceContent
       }) async {
    var token = await SharedPref().getToken();
    print("resource title = ${resourceTitle}");
    // title media type

    var url = Uri.parse(
        'https://backend.savant.app/web/resource/update/$resourceId');
    print(url);
    print("Save resource");
    final payload = {};
    print(mediaType);
    print(rootId);
    payload.addAll({
      "rootId": rootId,
      "type": mediaType,
      "title":resourceTitle,
      "content":resourceContent
    });
    Response res = await http.patch(
      url,
      body: jsonEncode(payload),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );
    var data = await jsonDecode(res.body);
    print("update response-->${data}");
    return res.statusCode;
  }


  static Future<int> onSaveNewCategoryResource({required String categoryTitle})async{
    Map<String, dynamic> payload = {};
    List<Map<String, String>> styles = [
      {"key": "font-size", "value": "2rem"},
    ];
    payload.addAll({"styles": styles});
    payload.addAll({"keywords": ["tags"]});

    payload.addAll({
      "name": categoryTitle,
    });
    var token = await SharedPref().getToken();

    var res = await http.post(
      Uri.parse('https://backend.savant.app/web/category/create'),
      body: jsonEncode(payload),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );
    print("find error${res.body}");
    if(res.statusCode==200){
      print("newcategorycreatedResponse${res.body}");

    }
    return res.statusCode;
  }

}
