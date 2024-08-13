import 'package:flutter/cupertino.dart';
import 'package:self_learning_app/features/subcategory/model/sub_cate_model.dart';

import '../data/model/category_model.dart';

@immutable
abstract class CategoryState {}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<CategoryModel> cateList;

  CategoryLoaded({required this.cateList});
}

class CategoryFailed extends CategoryState {
  final String errorText;

  CategoryFailed({required this.errorText});
}


class CategoryChanged extends CategoryState {
  final String category;

  CategoryChanged({required this.category});
}

class CategoryAdded extends CategoryState {}

class CategoryColor extends CategoryState {
  final Color cateBgColor;

  CategoryColor({required this.cateBgColor});
}
class CategoryDeleteSuccess extends CategoryState{

}

