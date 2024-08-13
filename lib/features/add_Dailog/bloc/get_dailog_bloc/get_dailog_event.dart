part of 'get_dailog_bloc.dart';

@immutable
abstract class GetDailogEvent {}

class HitGetDailogEvent extends GetDailogEvent{}
class DeleteDailogEvent extends GetDailogEvent{
  String dailogName;
  String dailogId;
  int index;

  DeleteDailogEvent({required this.dailogId, required this.index, required this.dailogName});
}
