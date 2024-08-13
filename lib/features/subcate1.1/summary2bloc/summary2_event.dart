part of 'summary2_bloc.dart';

@immutable
abstract class Summary2Event {}
class Summary2LoadedEvent extends Summary2Event{
  final String? rootId;
  Summary2LoadedEvent({this.rootId});
}
