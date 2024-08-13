import 'package:flutter/material.dart';
import 'package:self_learning_app/features/search_category/data/search_cate_model.dart';

import '../../add_category/data/model/add_cate_model.dart';

@immutable
abstract class SearchSubCategoryState {}

class SearchSubCategoryInitial extends SearchSubCategoryState {}

class SearchSubCategoryLoading extends SearchSubCategoryState {}

class SearchSubCategoryLoaded extends SearchSubCategoryState {
  final List<SearchCategoryModel> cateList;
  SearchSubCategoryLoaded({required this.cateList});

  SearchSubCategoryLoaded copyWith({List<SearchCategoryModel>? cateList}){
    return SearchSubCategoryLoaded(cateList: cateList?? this.cateList);
  }
}

class SearchSubCategoryFailed extends SearchSubCategoryState {
  final String errorText;

  SearchSubCategoryFailed({required this.errorText});
}
