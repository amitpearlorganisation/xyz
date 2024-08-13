import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../category/data/repo/category_repo.dart';
import '../model/sub_cate_model.dart';

part 'summary_event.dart';
part 'summary_state.dart';

class SummaryBloc extends Bloc<SummaryEvent, SummaryState> {
  SummaryBloc() : super(SummaryInitial()) {
    on<SummaryLoadedEvent>(_onGetSubCategoryList);

  }

  void _onGetSubCategoryList(
      SummaryLoadedEvent event, Emitter<SummaryState> emit) async {
    emit(SummaryLoading());

    await CategoryRepo.getMainCategorySummary(event.rootId).then((value) {

      emit(SummaryLoadedState(sumaryList: value));
    });
  }
}
