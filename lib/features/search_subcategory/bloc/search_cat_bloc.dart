

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:self_learning_app/features/search_category/bloc/search_cate_event.dart';
import 'package:self_learning_app/features/search_category/bloc/search_cate_state.dart';
import 'package:self_learning_app/features/search_subcategory/bloc/search_cate_event.dart';
import 'package:self_learning_app/features/search_subcategory/bloc/search_cate_state.dart';
import 'package:self_learning_app/features/search_subcategory/data/repo/search_sub_cat_repo.dart';

import '../../category/bloc/category_state.dart';
import '../../search_category/data/search_cate_repo.dart';

class SearchSubCategoryBloc extends Bloc<SearchSubCategoryEvent, SearchSubCategoryState> {
  SearchSubCategoryBloc() : super(SearchSubCategoryInitial()) {
    on<SearchSubCategoryLoadEvent>(_onGetCategoryList);
  }

  void _onGetCategoryList(
      SearchSubCategoryLoadEvent event, Emitter<SearchSubCategoryState> emit) async {
    emit(SearchSubCategoryLoading());
    try {
      await SearchSubCategoryRepo.searchSubCategories(event.query, event.rootId).then((value) {
        emit(SearchSubCategoryLoaded(cateList: value));
      });
    } catch (e) {
      print(e);
      emit(SearchSubCategoryFailed(errorText: 'Oops Something went wrong'));
    }
  }




}
