part of 'promt_bloc.dart';

@immutable
abstract class PromtEvent {}
 class LoadPromtEvent extends PromtEvent {
 final String promtId;
 final Prompt fromType;
 LoadPromtEvent({required this.promtId, required this.fromType});

}

class AddPromptFlow extends PromtEvent {
 final AddFlowModel ?addFlowModel;
 AddPromptFlow({this.addFlowModel});
}

class ViewResourceEvent extends PromtEvent {
 final bool ? showResource;
 ViewResourceEvent({this.showResource});
}


