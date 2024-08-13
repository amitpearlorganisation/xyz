import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import '../../../../utilities/shared_pref.dart';
import '../../../quick_add/data/repo/model/quick_type_prompt_model.dart';

part 'new_dialog_dart_state.dart';

class NewDialogDartCubit extends Cubit<NewDialogDartState> {
  final Dio _dio = Dio();
  NewDialogDartCubit() : super(NewDialogDartInitial());
  void getQuickPromptList() async {
    emit(NewDialogPromptLoading());
    try {
/*
      String token = SharedPref().getToken() as String;
*/

      var token = await SharedPref().getToken();

      Map<String, dynamic> headers = {
        'Authorization': 'bearer' + ' ' + token.toString(),
      };

      Response res = await _dio.get(
        "https://backend.savant.app/web/prompt/",
        options: Options(headers: headers),
      );
      print("Quick prompt api ${res.data}");
      print("--------------------break");
      List<QuickPromptModelList> quickPromptList =[];
      final jsonResponse = res?.data;
      print("promtpId checking$jsonResponse");
      final data = jsonResponse['data'];
      final recordList = data['record'] as List;

      for (var record in recordList) {
        String id = record['_id'];
        String name = record['name'];
        String side1Content = record["side1"]["content"];
        String side2Content = record["side2"]['content'];
        String side1Type = record['side1']['type'];
        String side2Type = record['side2']['type'];
        String firstWord = side1Type.split('-')[0];
        String SecondWord = side2Type.split('-')[0];
        quickPromptList.add(QuickPromptModelList(
          promptid: id,
          promptname: name,
          side1content: side1Content,
          side2content: side2Content,
          side1Type: firstWord,
          side2Type: SecondWord
        ));
      }
      emit(NewDialogPromptSuccess(promtModelList: quickPromptList));
      // Update the UI and set isLoading to false.
    } catch (e) {
      print("Error: $e");
      emit(NewDialogPromptError(error: e.toString()));
      // You can handle the error as needed
    }
  }

}
