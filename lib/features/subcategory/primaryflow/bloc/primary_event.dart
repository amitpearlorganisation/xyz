part of 'primary_bloc.dart';

abstract class PrimaryEvent extends Equatable {
}
class LoadAllPrimaryEvent extends PrimaryEvent{
  String rootId;
  LoadAllPrimaryEvent({required this.rootId});
  @override
  // TODO: implement props
  List<Object?> get props => [rootId];


}

class DefaultPrimaryEvent extends PrimaryEvent{
  String rootId;
  DefaultPrimaryEvent({required this.rootId});
  @override
  // TODO: implement props
  List<Object?> get props => [rootId];


}