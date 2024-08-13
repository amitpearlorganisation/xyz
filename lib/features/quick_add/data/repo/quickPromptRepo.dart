 import 'package:dio/dio.dart';
import 'package:self_learning_app/utilities/shared_pref.dart';
class QuickAddPromptRepo {
 static Future<Response?> quickAddPrompt() async {
    final Dio _dio = Dio();

    try {
      var token = await SharedPref().getToken();
      print("Quick add token $token");

      Map<String, dynamic> headers = {
        'Authorization': 'bearer' + ' ' + token.toString(),
      };

      Response res = await _dio.get("https://backend.savant.app/web/prompt/", options: Options(headers: headers));
      print("promptgetResponse == ${res}");
      return res;
    } catch (e) {
      print("Error: $e");
      return null; // You can handle the error as needed
    }
  }
 static Future<Response?> quickDeletePrompt({required String promptId}) async {
   final Dio _dio = Dio();

   try {

     var token = await SharedPref().getToken();

     final Map<String, dynamic> headers = {
       'Authorization': 'Bearer $token',
     };
         print("promptId is $promptId");
     Response res = await _dio.delete("https://backend.savant.app/web/prompt/$promptId", options: Options(headers: headers));
     print("deletepromptres == ${res}");
     return res;
   } catch (e) {
     print("Error: $e");
     return null; // You can handle the error as needed
   }
 }
}