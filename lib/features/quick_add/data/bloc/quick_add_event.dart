part of 'quick_add_bloc.dart';

@immutable
abstract class QuickAddEvent {}

class LoadQuickTypeEvent extends QuickAddEvent {}


class ButtonPressedEvent extends QuickAddEvent {
  final int contentType;
  final String? title;

  ButtonPressedEvent({this.title,required this.contentType});
}
class QuickDeleteResource extends QuickAddEvent {
  String? id;
  BuildContext context;

  QuickDeleteResource({required this.id, required this.context});
}