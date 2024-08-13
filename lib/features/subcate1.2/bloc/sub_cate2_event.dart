
import 'package:flutter/cupertino.dart';

import '../model/sub_cate_model.dart';

abstract class SubCategory2Event {}


class SubCategory2LoadEvent extends SubCategory2Event{
  final String? rootId;

  SubCategory2LoadEvent({this.rootId});
}

class SubCategory2LoadingEvent extends SubCategory2Event{
  SubCategory2LoadingEvent();
}

class SubCategory2DeleteEvent extends SubCategory2Event{
  final String rootId;
  final BuildContext context;
  final int deleteIndex;
  final List<SubCategory2Model> catList;
  SubCategory2DeleteEvent({
    required this.rootId,
    required this.context,
    required this.catList, required this.deleteIndex});

  @override
  // TODO: implement props
  List<Object?> get props => [rootId, context, deleteIndex, catList];
}







