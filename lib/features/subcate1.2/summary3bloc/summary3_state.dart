part of 'summary3_bloc.dart';

@immutable
abstract class Summary3State {}

class Summary3Initial extends Summary3State {}
class Summary3Loading extends Summary3State {}

class Summary3LoadedState extends Summary3State {
  final String? ddValue;
  final List<MainCategoryModel> sumaryList;
  Summary3LoadedState({required this.sumaryList,this.ddValue});
}

class Summary3Failed extends Summary3State {
  final String errorText;

  Summary3Failed({required this.errorText});
}
