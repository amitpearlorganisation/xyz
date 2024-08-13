part of 'promt_bloc.dart';

enum ApiState{Initial,Loading,Success,Error,Added}

@immutable
abstract class PromtState {}

class PromtInitial extends PromtState {}

class PromtLoading extends PromtState {}

class PromtLoaded extends PromtState {
  final ApiState? apiState;
  final List<PromtModel>? promtModel;
  final AddFlowModel? addFlowModel;
  final bool ?showResource;

  PromtLoaded({this.promtModel, this.addFlowModel, this.apiState,this.showResource});

  PromtLoaded copyWith({
    bool ?showResource,
    List<PromtModel>? promtModel,
    AddFlowModel? addFlowModel,
    ApiState? apiState,
  }) {
    return PromtLoaded(
      showResource: showResource??this.showResource,
      promtModel: promtModel ?? this.promtModel,
      addFlowModel: addFlowModel ?? this.addFlowModel,
      apiState: apiState ?? this.apiState,
    );
  }
}

class PromtError extends PromtState {
  final String? error;
  PromtError({this.error});
}

