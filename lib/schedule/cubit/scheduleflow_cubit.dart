import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:meta/meta.dart';

import '../../features/create_flow/data/model/flow_model.dart';
import '../scheduleRepo/scheduleRepo.dart';

part 'scheduleflow_state.dart';

class ScheduleflowCubit extends Cubit<ScheduleflowState> {
  ScheduleflowCubit() : super(ScheduleflowInitial());

  getFlow({String? queary})async{
    emit(ScheduleFlowLoading());
    Response? response = await ScheduleRepo.getFlow(queary: queary);


    if(response?.statusCode == 400){
      emit(ScheduleFlowError());
    }
    else{
      List<FlowModel> flowList = [];
      /*for(var item in response.data['data']['record']){
          flowList.add(FlowModel(title: item['title'], id: item['_id']));
        }*/
      for(var item in response?.data['data']['record']){
        List<FlowDataModel> flowData = [];

        for (var flow in item['flow']){

          flowData.add(FlowDataModel(
              promptName: flow['promptId']?['name']??"",
              promptId: flow['promptId']?['_id']??"",
              resourceTitle: flow['promptId']?['resourceId']?['title']?? '',
              resourceType: flow['promptId']?['resourceId']?['type']??'',
              resourceContent: flow['promptId']?['resourceId']?['content']??'',
              side1Title: flow['promptId']?['side1']?['title']??"",
              side1Type: flow['promptId']?['side1']?['type']??"",
              side1Content: flow['promptId']?['side1']?['content']??"",
              side2Title: flow['promptId']?['side2']?['title']??"",
              side2Type: flow['promptId']?['side2']?['type']??"",
              side2Content: flow['promptId']?['side2']?['content']??""

          ));

        }
        flowList.add(FlowModel(
          title: item['title'],
          id: item['_id'],
          categoryId: item['categoryId'],
          flowList: flowData,
        ));
      }
      emit(ScheduleFlowLoaded(flowList: flowList));
    }

  }



  addDateTime({    required DateTime? scheduledDateTime,
    required String flowId,
    required String flowName

  }) async{
    emit(ScheduleFlowLoading());
    Response? response = await ScheduleRepo.addDateTime(scheduledDateTime: scheduledDateTime,flowId:flowId,flowName: flowName );
    if(response?.statusCode == 400){
      emit(ScheduleFlowError());
    }

    else{
      EasyLoading.showSuccess("$flowName Flow is scheduled");
    }

  }


  getScheduledFlow() async {
    emit(ScheduleFlowLoading());
    Response? response = await ScheduleRepo.getFlow();

    if (response?.statusCode == 400) {
      print("status code is 200");
      emit(ScheduleFlowError());
    } else {
      List<FlowModel> flowList = [];

      for (var item in response?.data['data']['record']) {
        print("now we can check Schedule flow ${item["scheduledDateTime"]}");
        // Check if the item has a scheduledDateTime key
        if (item.containsKey('scheduledDateTime')) {
          List<FlowDataModel> flowData = [];

          for (var flow in item['flow']) {
            flowData.add(FlowDataModel(
              promptName: flow['promptId']?['name'] ?? "",
              promptId: flow['promptId']?['_id'] ?? "",
              resourceTitle: flow['promptId']?['resourceId']?['title'] ?? '',
              resourceType: flow['promptId']?['resourceId']?['type'] ?? '',
              resourceContent: flow['promptId']?['resourceId']?['content'] ?? '',
              side1Title: flow['promptId']?['side1']?['title'] ?? "",
              side1Type: flow['promptId']?['side1']?['type'] ?? "",
              side1Content: flow['promptId']?['side1']?['content'] ?? "",
              side2Title: flow['promptId']?['side2']?['title'] ?? "",
              side2Type: flow['promptId']?['side2']?['type'] ?? "",
              side2Content: flow['promptId']?['side2']?['content'] ?? "",
            ));
          }

          flowList.add(FlowModel(
            title: item['title'],
            id: item['_id'],
            categoryId: item['categoryId'],
            flowList: flowData,
            dateTime: item["scheduledDateTime"]
          ));
        }
      }

      emit(ScheduleDateLoaded(dateflowList: flowList));
    }
  }



}
