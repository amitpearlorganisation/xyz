part of 'add_prompt_res_cubit.dart';

@immutable
abstract class AddPromptResState extends Equatable{
  List<Object> get props => [];

}

class AddPromptResInitial extends AddPromptResState {}
class AddPromptResLoading extends AddPromptResState{}
class AddPromptResSuccess extends AddPromptResState{
  String promptName;
  String resourceName;
  AddPromptResSuccess({required this.promptName, required this.resourceName});
}
class GetResourcePromptDailog extends AddPromptResState{
  List<AddResourceListModel> res_prompt_list;
  List<AddPromptListModel> def_prompt_list;
  GetResourcePromptDailog({required this.res_prompt_list, required this.def_prompt_list});
  List<Object> get props => [res_prompt_list,def_prompt_list];

}
class AddPromptResError extends AddPromptResState{
  String errorMessage;
  AddPromptResError({required this.errorMessage});
}
class GetPromptFromResourceSuccess extends AddPromptResState{
  List<FlowDataModel> flowModel;
  GetPromptFromResourceSuccess({required this.flowModel});
}
class ResourceDeletedSuccess extends AddPromptResState{
}
class GetFlowSuccess extends AddPromptResState{
  List<FlowModel> flowList;

  GetFlowSuccess(this.flowList);

  GetFlowSuccess copyWith({List<FlowModel>? flowList}){
    return GetFlowSuccess(flowList??this.flowList);
  }
}
class GetFlowDeletedSuccess extends AddPromptResState{
}
class GetPromptUpdate extends AddPromptResState{

}