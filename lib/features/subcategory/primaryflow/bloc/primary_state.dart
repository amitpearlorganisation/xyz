part of 'primary_bloc.dart';

abstract class PrimaryState  {
  const PrimaryState();
}

class PrimaryInitial extends PrimaryState {}
class PrimaryflowLoading extends PrimaryState{}
class PrimarySuccessState extends PrimaryState{
  List<FlowDataModel> flowList;
  PrimarySuccessState({required this.flowList});
}
class Primaryflowfailedstate extends PrimaryState{}