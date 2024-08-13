part of 'quick_prompt_bloc.dart';

@immutable
abstract class QuickPromptEvent {}
class QuickAddPromptEvent extends QuickPromptEvent{}
class DeleteQuickPromptEvent extends QuickPromptEvent{
  String? promptName;
  String? promptId;
  int index;
  DeleteQuickPromptEvent({required this.promptId, required this.promptName, required this.index});
}
