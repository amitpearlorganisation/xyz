part of 'get_dailog_bloc.dart';

@immutable
abstract class GetDailogState {
  List<AddDailogModel>? dailogList;

}

class GetDailogInitial extends GetDailogState {}
class GetDailogLoadingState extends GetDailogState{}
class GetDailogSuccessState extends GetDailogState{
  List<AddDailogModel>? dailogList;
  List<AddResourceListModel>? resourceList;
  List<AddPromptListModel>? promptList;
  GetDailogSuccessState({required this.dailogList, this.resourceList, this.promptList});

}
class DailogDeleteSuccessfully extends GetDailogState{
  String dailogname;
  DailogDeleteSuccessfully({required this.dailogname});

}
class GetDailogErrorState extends GetDailogState{
  String? errorMessage;
  GetDailogErrorState({required this.errorMessage});
}

