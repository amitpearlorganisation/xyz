part of 'quick_add_bloc.dart';

@immutable
abstract class QuickImportEvent {}

class LoadQuickTypeEvent extends QuickImportEvent {
  final String? rootId;
  LoadQuickTypeEvent({this.rootId});
}

class ButtonPressedEvent extends QuickImportEvent {
  final String? title;
  final String? quickAddId;
  final String? rootId;
  final String ? mediaType;
  final String ? resourceContent;
  ButtonPressedEvent({this.title,this.quickAddId,this.rootId,this.mediaType, this.resourceContent});
}

class ChangeDropValue extends QuickImportEvent {
   final List<QuickImportModel>? list;
  final String? title;
  ChangeDropValue({this.title,this.list});
}
