part of 'summary_bloc.dart';

@immutable
abstract class SummaryState {}

class SummaryInitial extends SummaryState {}
class SummaryLoading extends SummaryState {}

class SummaryLoadedState extends SummaryState {
  final String? ddValue;
  final List<MainCategoryModel> sumaryList;
  SummaryLoadedState({required this.sumaryList,this.ddValue});
}

class SummaryFailed extends SummaryState {
  final String errorText;

  SummaryFailed({required this.errorText});
}



