
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../data/model/flow_model.dart';
import '../data/repo/create_flow_screen_repo.dart';


part 'create_flow_screen_event.dart';
part 'create_flow_screen_state.dart';
class CreateFlowBloc extends Bloc<CreateFlowEvent,CreateFlowState> {
  CreateFlowBloc(): super(FlowLoading()){

    on<DeleteFlow>((event, emit) async {
      EasyLoading.show(dismissOnTap: true);
      Response response = await CreateFlowRepo.deleteFlow(flowId: event.flowId);
      if(response.statusCode == 400){
        ScaffoldMessenger.of(event.context).showSnackBar(SnackBar(content: Text('Delete Failed!')));
      }else{
        event.flowList.removeAt(event.deleteIndex);
        EasyLoading.dismiss();
        ScaffoldMessenger.of(event.context).showSnackBar(SnackBar(content: Text('Deleted Successfully!')));
        emit(flowDeletedSuccess());
        // emit(LoadSuccess(event.flowList));
      }
    });
    on<FlowSelected>((event, emit) async{
      print("1--->${event.flowId}");
      Response? response = await CreateFlowRepo.selectFlow(flowId: event.flowId,flowType: event.type, rootId: event.rootId, flowTitle: event.flowList[event.index].title);
      print("SelectFlow----${response!.data}");
      if(response?.statusCode == 400){
          print("___===++invalid request");
          emit(flowSelectionFailed(errormsg: "sorry to select flow"));
      }
      if(response?.statusCode == 200){
        EasyLoading.showToast(duration: Duration(seconds: 2),"Primary flow selected");
        // emit(LoadSuccess(event.flowList));
        print("flow selected");
        // emit(flowSelected());
      }
    });
    on<LoadAllFlowEvent>((event, emit) async {
      emit(FlowLoading());
      Response response = await CreateFlowRepo.getAllFlow(catID: event.catID,keyword: event.keyword);

      print('123456');
      print(response);
      if(response.statusCode == 400){
        emit(LoadFailed());
      }
      else{
        List<FlowModel> flowList = [];
        /*for(var item in response.data['data']['record']){
          flowList.add(FlowModel(title: item['title'], id: item['_id']));
        }*/
        for(var item in response.data['data']['record']){
          List<FlowDataModel> flowData = [];

          for (var flow in item['flow']){

            flowData.add(FlowDataModel(
                promptName: flow['promptId']?['name'] ?? '', // Null check added here
                promptId: flow['promptId']?['_id'] ?? '',
                resourceTitle: flow['promptId']?['resourceId']?['title'] ?? '',
                resourceType: flow['promptId']?['resourceId']?['type'] ?? '',
                resourceContent: flow['promptId']?['resourceId']?['content'] ?? '',
                side1Title: flow['promptId']?['side1']?['title'] ?? '', // Proper null check added here
                side1Type: flow['promptId']?['side1']?['type'] ?? '', // Proper null check added here
                side1Content: flow['promptId']?['side1']?['content'] ?? '', // Proper null check added here
                side2Title: flow['promptId']?['side2']?['title'] ?? '', // Proper null check added here
                side2Type: flow['promptId']?['side2']?['type'] ?? '', // Proper null check added here
                side2Content: flow['promptId']?['side2']?['content'] ?? '' // Proper null check added here
            ));

          }
          flowList.add(FlowModel(
            title: item['title'],
            id: item['_id'],
            categoryId: item['categoryId'],
            flowList: flowData,
          ));
        }
        emit(LoadSuccess(flowList).copyWith(flowList: flowList));
      }
    });

    on<promptSelectedEvent>((event, emit)async{
      Response response = await CreateFlowRepo.selectedPrompts(flowId: event.flowId);

      final dynamic data = response.data['data']['record'];



    });
  }
}


/// List<FlowModel> flowList = []

