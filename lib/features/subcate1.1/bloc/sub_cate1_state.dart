import 'package:flutter/cupertino.dart';

import '../model/sub_cate_model.dart';

@immutable
abstract class SubCategory1State {}

class SubCategory1Initial extends SubCategory1State {}

class SubCategory1Loading extends SubCategory1State {}

class SubCategory1Loaded extends SubCategory1State {
  final String? ddValue;
  final bool? value;
  final List<SubCategory1Model> cateList;
  SubCategory1Loaded({required this.cateList,this.ddValue, this.value});
}

class SubCategory1Failed extends SubCategory1State {
  final String errorText;

  SubCategory1Failed({required this.errorText});
}

class SubCategory1Added extends SubCategory1State {}

class SubCategory1Color extends SubCategory1State {
  final Color cateBgColor;
  SubCategory1Color({required this.cateBgColor});
}




