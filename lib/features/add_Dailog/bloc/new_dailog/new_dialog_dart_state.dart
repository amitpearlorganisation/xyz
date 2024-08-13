part of 'new_dialog_dart_cubit.dart';

@immutable
abstract class NewDialogDartState {}

class NewDialogDartInitial extends NewDialogDartState {}
class NewDialogPromptLoading extends NewDialogDartState{}
class NewDialogPromptSuccess extends NewDialogDartState{
  List<QuickPromptModelList> promtModelList;
  NewDialogPromptSuccess({required this.promtModelList});
}
class NewDialogPromptError extends NewDialogDartState{
  String error;
  NewDialogPromptError({required this.error});
}




