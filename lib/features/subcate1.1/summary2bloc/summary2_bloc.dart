import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../category/data/repo/category_repo.dart';
import '../../subcategory/model/sub_cate_model.dart';

part 'summary2_event.dart';
part 'summary2_state.dart';

class Summary2Bloc extends Bloc<Summary2Event, Summary2State> {
  Summary2Bloc() : super(Summary2Initial()) {
    on<Summary2LoadedEvent>(_onGetSubCategoryList);

  }

  void _onGetSubCategoryList(
      Summary2LoadedEvent event, Emitter<Summary2State> emit) async {
    emit(Summary2Loading());

    await CategoryRepo.getMainCategorySummary(event.rootId).then((value) {

      emit(Summary2LoadedState(sumaryList: value));
    });
  }
}
