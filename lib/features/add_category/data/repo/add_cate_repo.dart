// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart';
//
// import '../../../../utilities/base_client.dart';
//
// class AddCateRepo {
//
//   static Future<int?> addCategory(
//       {required String cateTitle, Color? fontColor}) async {
//     print('add category');
//     Response res = await Api().post(
//       payload: {
//         "name": cateTitle,
//         "keywords": ["dart", "bloc"],
//         "styles": [
//           {"key": "font-size", "value": "2rem"},
//           {"key": "background-color", "value": fontColor}
//         ]
//       },
//       endPoint: 'category',
//     );
//     var data = await jsonDecode(res.body);
//     print(data);
//     return null;
//   }
// }
