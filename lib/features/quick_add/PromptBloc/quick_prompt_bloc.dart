import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:meta/meta.dart';

import '../data/repo/model/quick_type_prompt_model.dart';
import '../data/repo/quickPromptRepo.dart';

part 'quick_prompt_event.dart';
part 'quick_prompt_state.dart';

class QuickPromptBloc extends Bloc<QuickPromptEvent, QuickPromptState> {
  QuickPromptBloc() : super(QuickPromptAddLoadingState()) {
    on<QuickAddPromptEvent>(_onLoadQuickPrompt);
    on<DeleteQuickPromptEvent>(_onDeleteQuickprompt);

  }


  void _onLoadQuickPrompt(QuickAddPromptEvent event,
      Emitter<QuickPromptState> emit) async {
    print("Quick promt event");
    emit(QuickPromptAddLoadingState());
    var res = await QuickAddPromptRepo.quickAddPrompt();
    List<QuickPromptModel> quickPromptList = [];
    print("hello world");
    if (res?.statusCode == 200) {
      print("the code is working");

      // quickPromptList.add(QuickPromptModel(promptid: "1", promptname: "promptname"));
      // Parse the JSON response and extract prompt records
      final jsonResponse = res?.data;
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

        print("name of prompt $name");

        quickPromptList.add(QuickPromptModel(
          promptid: id,
          promptname: name,
          side1content: side1Content,
          side2content: side2Content,
          side1Type: firstWord,
          side2Type: SecondWord
        ));

      }
      for(var item in quickPromptList){

        print("here we can try ${item.promptname}");
      }
      emit(QuickPromptAddLoadedState(list: quickPromptList));
    }
    else {
      print("the code is not working");
    }
  }

  void _onDeleteQuickprompt(DeleteQuickPromptEvent event,
      Emitter<QuickPromptState> emit) async {
    var res = await QuickAddPromptRepo.quickDeletePrompt(promptId: event.promptId!);
    print("hello world");
    if (res?.statusCode == 200) {
      state.list?.removeAt(event.index);
      EasyLoading.showSuccess("${event.promptName} is successfully deleted");
      emit(QuickPromptDeletingSuccess());


    }
    else {
      print("the code is not working");
    }
  }
}
