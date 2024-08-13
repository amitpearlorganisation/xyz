import 'package:flutter/cupertino.dart';
import 'package:self_learning_app/features/subcategory/model/sub_cate_model.dart';

abstract class SubCategoryEvent {}

class SubCategoryLoadEvent extends SubCategoryEvent{
  final String? rootId;
  SubCategoryLoadEvent({this.rootId});
}




class SubCateChangeDropValueEvent extends SubCategoryEvent {
  final List<SubCategoryModel>? list;
  final String? subCateId;
  SubCateChangeDropValueEvent({this.subCateId,this.list});
}
class SubCategoryDeleteEvent extends SubCategoryEvent{
  final String rootId;
  final BuildContext context;
  final int deleteIndex;
  final List<SubCategoryModel> catList;
  SubCategoryDeleteEvent({
    required this.rootId,
    required this.context,
    required this.catList, required this.deleteIndex});

  @override
  // TODO: implement props
  List<Object?> get props => [rootId, context, deleteIndex, catList];
}



