import 'package:dio/dio.dart';
import 'package:self_learning_app/features/subcategory/primaryflow/data/primary_model.dart';

import '../../../../../utilities/shared_pref.dart';

class AddPromptsToPrimaryFlowRepo {
  static Future<Response> getData({required String mainCatId}) async {
    final token = await SharedPref().getToken();

    final Options options = Options(
      headers: {"Authorization": 'Bearer $token'},
    );

    Response res = await Dio().get(
        'https://backend.savant.app/web/flow?categoryId=$mainCatId&type=primary',
        options: options,
        data: {'type':'primary'}
    );
    print("@----$res");
    print("break");

    return res;
  }
  static Future<Response> defalutPrimaryflow({required String mainCatId}) async {
    final token = await SharedPref().getToken();

    final Options options = Options(
      headers: {"Authorization": 'Bearer $token'},
    );

    Response res = await Dio().get(
      'https://backend.savant.app/web/prompt?categoryId=$mainCatId',
      options: options,
    );
    print("@----$res");
    print("break");

    return res;
  }

}
