part of 'add_prompts_bloc.dart';

@immutable
abstract class AddPrompts {}

class LoadPrompts extends AddPrompts{}
class ChangeMediaType extends AddPrompts{
  final int whichSide;
  final String? MediaType;

  ChangeMediaType({required this.whichSide,this.MediaType});
}
class PickResource extends AddPrompts{
  final int ?whichSide;
  final String ? mediaUrl;
  PickResource({this.mediaUrl,this.whichSide});
}

class AddResource extends AddPrompts{
  final int ? whichSide;
  final String ? name;
  final int ? mediaUrl;
  final String ? resourceId;
  final String ? content;

  AddResource({this.mediaUrl,this.resourceId,this.name,this.whichSide,this.content});
}
class QuickAddResource extends AddPrompts{
  final int ? whichSide;
  final String ? name;
  final int ? mediaUrl;
  final String ? content;

  QuickAddResource({this.mediaUrl,this.name,this.whichSide,this.content});
}


class AddPromptEvent extends AddPrompts{
  final String ? name;
  final String ? resourceId;
  final String ? categoryId;
  AddPromptEvent({this.resourceId,this.name, this.categoryId});
}

class ResetFileUploadStatus extends AddPrompts{
  ResetFileUploadStatus();
}
class AddPromptEventforQuickPrompt extends AddPrompts{
  final String ? Promptname;

  AddPromptEventforQuickPrompt({this.Promptname});
}

