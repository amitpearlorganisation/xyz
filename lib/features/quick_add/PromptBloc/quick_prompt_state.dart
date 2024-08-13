part of 'quick_prompt_bloc.dart';

@immutable
abstract class QuickPromptState  {
  List<QuickPromptModel>? list;


}

class QuickPromptInitial extends QuickPromptState {

}
class QuickPromptAddLoadingState extends QuickPromptState{}
class QuickPromptAddLoadedState extends QuickPromptState{
  final List<QuickPromptModel> ? list;
  QuickPromptAddLoadedState({required this.list});

}
class QuickPromptDeletingSuccess extends QuickPromptState{}

