
import 'package:flutter/cupertino.dart';

import '../model/sub_cate_model.dart';

abstract class SubCategory1Event {}


class SubCategory1LoadEvent extends SubCategory1Event{
  final String? rootId;

  SubCategory1LoadEvent({this.rootId});
}

class SubCategory1LoadingEvent extends SubCategory1Event{}

class DDValueSubCategoryChanged extends SubCategory1Event {
  final String? ddValue;
  final List<SubCategory1Model>? cateList;

  DDValueSubCategoryChanged({this.ddValue,this.cateList});
}

class SubCategory1LoadEmptyEvent extends SubCategory1Event{}




class SubCategory1DeleteEvent extends SubCategory1Event{
  final String rootId;
  final BuildContext context;
  final int deleteIndex;
  final List<SubCategory1Model> catList;
  SubCategory1DeleteEvent({
    required this.rootId,
    required this.context,
    required this.catList, required this.deleteIndex});

  @override
  // TODO: implement props
  List<Object?> get props => [rootId, context, deleteIndex, catList];
}





