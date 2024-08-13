part of 'summary3_bloc.dart';

@immutable
abstract class Summary3Event {}
class Summary3LoadedEvent extends Summary3Event{
  final String? rootId;
  Summary3LoadedEvent({this.rootId});
}