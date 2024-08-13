part of 'create_dailog_bloc.dart';

@immutable
abstract class CreateDailogEvent {}
class AddDailogEvent extends CreateDailogEvent{
  List promtIds;
  List resourceIds;
  String dailogName;
  String color;
  List tags;

  AddDailogEvent({required this.resourceIds, required this.promtIds, required this.dailogName, required this.color, required this.tags});

}
