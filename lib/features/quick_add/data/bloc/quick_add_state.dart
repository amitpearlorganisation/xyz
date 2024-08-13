part of 'quick_add_bloc.dart';

@immutable
abstract class QuickAddState {}

class QuickAddInitial extends QuickAddState {}

class QuickAddLoadingState extends QuickAddState{}

class QuickAddLoadedState extends QuickAddState{
  final QuickTypeModel ? list;
  QuickAddLoadedState({this.list});
}

class QuickAddedState extends QuickAddState{}

class QuickAddErrorState extends QuickAddState{
  final String message;
  QuickAddErrorState({required this.message});


}
class QuickResourceDelete extends QuickAddState{}
