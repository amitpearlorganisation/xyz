

part of 'create_flow_screen_bloc.dart';

abstract class CreateFlowEvent extends Equatable{

}

class AddFlow extends CreateFlowEvent {

  final bool showDialog;

  AddFlow({required this.showDialog});
  @override
  // TODO: implement props
  List<Object?> get props => [showDialog];

}

class DeleteFlow extends CreateFlowEvent {

  final String flowId;
  final List<FlowModel> flowList;
  final int deleteIndex;
  final context;
  DeleteFlow({required this.flowId, required this.flowList, required this.deleteIndex, required this.context});
  @override
  // TODO: implement props
  List<Object?> get props => [flowId, flowList, deleteIndex];

}

class CreateAndSaveFlow extends CreateFlowEvent {

  final String title;
  CreateAndSaveFlow({required this.title});
  @override
  // TODO: implement props
  List<Object?> get props => [title];

}


class LoadAllFlowEvent extends CreateFlowEvent {

  final String catID;
   String? keyword;
  LoadAllFlowEvent({required this.catID,  this.keyword});
  @override
  // TODO: implement props
  List<Object?> get props => [catID];

}
class promptSelectedEvent extends CreateFlowEvent{
  final String flowId;
  promptSelectedEvent({required this.flowId});
  List<Object?> get props => [flowId];

}

class FlowSelected extends CreateFlowEvent{
  List<FlowModel> flowList;
  final String flowId;
  final String type;
  final int index;
  final String rootId;


  FlowSelected({required this.flowId, required this.type, required this.flowList,required this.index, required this.rootId});

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();


}