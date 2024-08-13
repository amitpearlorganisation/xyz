import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:meta/meta.dart';

import '../../repo/create_dailog_repo.dart';

part 'create_dailog_event.dart';
part 'create_dailog_state.dart';

class CreateDailogBloc extends Bloc<CreateDailogEvent, CreateDailogState> {
  CreateDailogBloc() : super(CreateDailogInitial()) {
    on<AddDailogEvent>(_onAddDailog);
  }
  void _onAddDailog(AddDailogEvent event,
      Emitter<CreateDailogState> emit) async {
    emit(AddDailogLoadingState());
    var res = await DailogRepo.addDailog(dailog_name: event.dailogName,
        resourceId: event.resourceIds,
        prompt: event.promtIds, color: event.color, tags: event.tags);
    print("hello world");
    if (res?.statusCode == 200) {
      emit(DailogCreateSuccessState());
    }
    else {
      print("the code is not working");

    }
  }
}
