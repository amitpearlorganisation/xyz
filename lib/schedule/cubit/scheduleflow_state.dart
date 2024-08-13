part of 'scheduleflow_cubit.dart';

@immutable
abstract class ScheduleflowState {}

class ScheduleflowInitial extends ScheduleflowState {}
class ScheduleFlowLoading extends ScheduleflowState{}
class ScheduleFlowLoaded extends ScheduleflowState{
  List<FlowModel> ?flowList;
  ScheduleFlowLoaded({required this.flowList});
}
class ScheduleDateLoaded extends ScheduleflowState{
  List<FlowModel> ?dateflowList;
  ScheduleDateLoaded({required this.dateflowList});
}
class ScheduleFlowError extends ScheduleflowState{}