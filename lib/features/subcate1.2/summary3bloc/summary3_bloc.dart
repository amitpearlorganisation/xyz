import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../category/data/repo/category_repo.dart';
import '../../subcategory/model/sub_cate_model.dart';

part 'summary3_event.dart';
part 'summary3_state.dart';

class Summary3Bloc extends Bloc<Summary3Event, Summary3State> {
  Summary3Bloc() : super(Summary3Initial()) {
    on<Summary3LoadedEvent>(_onGetSubCategoryList);

  }

  void _onGetSubCategoryList(
      Summary3LoadedEvent event, Emitter<Summary3State> emit) async {
    emit(Summary3Loading());

    await CategoryRepo.getMainCategorySummary(event.rootId).then((value) {

      emit(Summary3LoadedState(sumaryList: value));
    });
  }
}
