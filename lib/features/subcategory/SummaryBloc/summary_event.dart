part of 'summary_bloc.dart';

@immutable
abstract class SummaryEvent {}
class SummaryLoadedEvent extends SummaryEvent{
  final String? rootId;
  SummaryLoadedEvent({this.rootId});
}
