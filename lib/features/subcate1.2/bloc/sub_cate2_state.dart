import 'package:flutter/cupertino.dart';

import '../model/sub_cate_model.dart';

@immutable
abstract class SubCategory2State {}

class SubCategory2Initial extends SubCategory2State {}

class SubCategory2Loading extends SubCategory2State {}

class SubCategory2Loaded extends SubCategory2State {
  final List<SubCategory2Model> cateList;
  final bool value;

  SubCategory2Loaded({required this.cateList, required this.value});
}

class SubCategory2Failed extends SubCategory2State {
  final String errorText;

  SubCategory2Failed({required this.errorText});
}

class SubCategory2Added extends SubCategory2State {}

class SubCategory2Color extends SubCategory2State {
  final Color cateBgColor;

  SubCategory2Color({required this.cateBgColor});
}

