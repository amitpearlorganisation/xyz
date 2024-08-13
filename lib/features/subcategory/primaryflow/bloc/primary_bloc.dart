import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:self_learning_app/features/create_flow/bloc/create_flow_screen_bloc.dart';

import '../../../create_flow/data/model/flow_model.dart';
import '../data/repo/primaryflowRepo.dart';

part 'primary_event.dart';
part 'primary_state.dart';

class PrimaryBloc extends Bloc<PrimaryEvent, PrimaryState> {
  PrimaryBloc() : super(PrimaryflowLoading()) {
    on<PrimaryEvent>((event, emit) {
      emit(PrimaryflowLoading());
    });
    on<LoadAllPrimaryEvent>((event, emit) async {
      // TODO: implement event handler
      Response res = await AddPromptsToPrimaryFlowRepo.getData(mainCatId: event.rootId);
      if(res.statusCode == 400){
        emit(Primaryflowfailedstate());
      }
      if (res.statusCode == 200 && res.data['data']['record'][0]['type'] == 'primary') {

        final data = res.data;


        List<FlowDataModel> flowData = [];
        for(var item in res.data['data']['record']){

          for (var flow in item['flow']){

            flowData.add(FlowDataModel(
                promptName: flow['promptId']['name'],
                promptId: flow['promptId']['_id'],
                resourceTitle: flow['promptId']['resourceId']?['title']?? '',
                resourceType: flow['promptId']['resourceId']?['type']??'',
                resourceContent: flow['promptId']['resourceId']?['content']??'',
                side1Title: flow['promptId']['side1']['title'],
                side1Type: flow['promptId']['side1']['type'],
                side1Content: flow['promptId']['side1']['content'],
                side2Title: flow['promptId']['side2']['title'],
                side2Type: flow['promptId']['side2']['type'],
                side2Content: flow['promptId']['side2']['content']));

          }

        }
        emit(PrimarySuccessState(flowList: flowData));
      }

    });
    on<DefaultPrimaryEvent>((event, emit) async {
      Response res = await AddPromptsToPrimaryFlowRepo.defalutPrimaryflow(mainCatId: event.rootId);
      if (res.statusCode == 200) {
        final data = res.data;
        // print("res===$res");
        final records = data['data']['record'];
        // print("#########${records}");
        // print("######break");

        List<FlowDataModel> flowDataList = records.map<FlowDataModel>((item) {
          return FlowDataModel(
            resourceTitle: item['name'],
            resourceType: item['resourceId'] == null ? 'text' : 'image',
            resourceContent: '', // You can populate this based on your needs.
            side1Title: item['side1']['title'],
            side1Type: item['side1']['type'],
            side1Content: item['side1']['content'],
            side2Title: item['side2']['title'],
            side2Type: item['side2']['type'],
            side2Content: item['side2']['content'],
            promptName: '', // You can populate this based on your needs.
            promptId: '', // You can populate this based on your needs.
          );
        }).toList();
        print("${flowDataList.length}");
        for (FlowDataModel flowDataModel in flowDataList) {

          print("---------->${flowDataModel.side2Content}");
        }
        emit(PrimarySuccessState(flowList: flowDataList));
      }

    });
  }
}
