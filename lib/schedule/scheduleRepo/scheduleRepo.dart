import 'package:dio/dio.dart';
import 'package:jwt_decode/jwt_decode.dart';

import '../../utilities/shared_pref.dart';

class ScheduleRepo{

 static Future<Response?> getFlow({String? queary}) async {
  print("this is scheduled flow");
    Response response;

    try{
      final token = await SharedPref().getToken();
      // dynamic check = Jwt.parseJwt(token.toString());
      response = await Dio().get(
          'https://backend.savant.app/web/flow?keyword=$queary',
          options: Options(
              headers: {"Authorization": 'Bearer $token'}
          ));
    }on DioError catch (e) {
      response = Response(requestOptions: RequestOptions());
      response.data = {
        'msg' : 'Failed to communicate with server!',
        'errorMsg' : e.toString(),
      };
      response.statusCode = 400;
    }

    print('Flowww $response');
    return response;  }
 static Future<Response?> addDateTime({required String? flowId, required DateTime? scheduledDateTime,required String? flowName}) async {

   Response response;
   String formattedDateTime = scheduledDateTime!.toIso8601String();
   final token = await SharedPref().getToken();

   Map<String, dynamic> decodedToken = Jwt.parseJwt(token!);
   print("Decoded token: $decodedToken");

   // Get the id from the decoded token
   String id = decodedToken['id'];
   print("decodedId--$id");

   try{
     response = await Dio().put(
         'https://backend.savant.app/web/flow/update/$flowId',
         data: {
           'scheduledDateTime': formattedDateTime,
           "title":flowName

         },
         options: Options(
             headers: {"Authorization": 'Bearer $token'}
         ));
   }on DioError catch (e) {
     response = Response(requestOptions: RequestOptions());
     response.data = {
       'msg' : 'Failed to communicate with server!',
       'errorMsg' : e.toString(),
     };
     response.statusCode = 400;
   }

   print('Flowww $response');
   return response;  }


}