part of 'summary2_bloc.dart';

@immutable
abstract class Summary2State {}

class Summary2Initial extends Summary2State {}

class Summary2Loading extends Summary2State {}

class Summary2LoadedState extends Summary2State {
  final String? ddValue;
  final List<MainCategoryModel> sumaryList;
  Summary2LoadedState({required this.sumaryList,this.ddValue});
}

class Summary2Failed extends Summary2State {
  final String errorText;

  Summary2Failed({required this.errorText});
}