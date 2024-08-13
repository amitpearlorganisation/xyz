

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:self_learning_app/features/search_category/bloc/search_cate_event.dart';
import 'package:self_learning_app/features/search_category/bloc/search_cate_state.dart';

import '../../category/bloc/category_state.dart';
import '../data/search_cate_repo.dart';

class SearchCategoryBloc extends Bloc<SearchCategoryEvent, SearchCategoryState> {
  SearchCategoryBloc() : super(SearchCategoryInitial()) {
    on<SearcCategoryLoadEvent>(_onGetCategoryList);
  }

  void _onGetCategoryList(
      SearcCategoryLoadEvent event, Emitter<SearchCategoryState> emit) async {
    emit(SearchCategoryLoading());
    try {
      await SearchCategoryRepo.searchCategories(event.query).then((value) {
        emit(SearchCategoryLoaded(cateList: value));
      });
    } catch (e) {
      print(e);
      emit(SearchCategoryFailed(errorText: 'Oops Something went wrong'));
    }
  }




}
