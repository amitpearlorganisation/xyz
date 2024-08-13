import 'package:flutter/material.dart';
import 'package:self_learning_app/features/search_category/data/search_cate_model.dart';

import '../../add_category/data/model/add_cate_model.dart';

@immutable
abstract class SearchCategoryState {}

class SearchCategoryInitial extends SearchCategoryState {}

class SearchCategoryLoading extends SearchCategoryState {}

class SearchCategoryLoaded extends SearchCategoryState {
  final List<SearchCategoryModel> cateList;

  SearchCategoryLoaded({required this.cateList});
}

class SearchCategoryFailed extends SearchCategoryState {
  final String errorText;

  SearchCategoryFailed({required this.errorText});
}
