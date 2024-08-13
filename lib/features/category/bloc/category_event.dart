part of 'category_bloc.dart';

@immutable
abstract class CategoryEvent extends Equatable{}

class CategoryImportEvent extends CategoryEvent{
  String? dropDownValue;
  CategoryImportEvent({this.dropDownValue});

  @override
  // TODO: implement props
  List<Object?> get props => [dropDownValue];
}


class CategoryLoadEvent extends CategoryEvent{
  final String? rootId;
  CategoryLoadEvent({this.rootId});

  @override
  // TODO: implement props
  List<Object?> get props => [rootId];
}
class CategoryDeleteEvent extends CategoryEvent{
  final String rootId;
  final BuildContext context;
  final int deleteIndex;
  final List<CategoryModel> catList;
  CategoryDeleteEvent({
    required this.rootId,
    required this.context,
    required this.catList, required this.deleteIndex});

  @override
  // TODO: implement props
  List<Object?> get props => [rootId, context, deleteIndex, catList];
}




