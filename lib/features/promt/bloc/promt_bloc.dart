import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:self_learning_app/features/promt/promts_screen.dart';

import '../data/model/addpromtprepo.dart';
import '../data/model/flow_model.dart';
import '../data/model/promt_model.dart';
import '../data/model/promt_model.dart';
import '../data/model/promt_model.dart';
import '../data/model/promt_model.dart';
import '../data/promt_repo.dart';

part 'promt_event.dart';
part 'promt_state.dart';

class PromtBloc extends Bloc<PromtEvent, PromtState> {
  PromtBloc() : super(PromtInitial()) {
    on<LoadPromtEvent>(_onLoadPromtEvent);
    on<AddPromptFlow>(_onAddPromptFlow);
    on<ViewResourceEvent>(_onViewResourceEvent);
  }

  _onLoadPromtEvent(LoadPromtEvent event, Emitter<PromtState>emit)async{
    emit(PromtLoading());
     await PromtRepo.getPromts(promtId: event.promtId, fromType: event.fromType).then((value) {
       emit(PromtLoaded(promtModel: value.promtList, addFlowModel: value.addFlowModel));
     });
  }

  _onAddPromptFlow(AddPromptFlow event, Emitter<PromtState>emit)async{
    emit(PromtLoading());
    await AddPromptNew.addFlow(flow: event.addFlowModel).then((value) {
        emit(PromtLoaded().copyWith(apiState: ApiState.Success));


    });
  }

  _onViewResourceEvent(ViewResourceEvent event, Emitter<PromtState>emit)async{
    emit(PromtLoaded().copyWith(showResource: true));

  }
}
