import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:meta/meta.dart';
import 'package:self_learning_app/features/create_flow/data/model/flow_model.dart';
import 'package:self_learning_app/features/dailog_category/dailog_cate_screen.dart';

import '../../add_Dailog/model/addDailog_model.dart';
import '../../create_flow/data/repo/create_flow_screen_repo.dart';
import '../repo/promptResRepo.dart';

part 'add_prompt_res_state.dart';

class AddPromptResCubit extends Cubit<AddPromptResState> {
  AddPromptResCubit() : super(AddPromptResInitial());

  getResPrompt({required String dailogId}) async {
    emit(AddPromptResLoading());
    try {
      var res = await PromptResRepo.get_Res_Prompt(dailogId: dailogId);

      print("getPromptRes Function is hit");

      if (res != null && res.statusCode == 200) {
        print("check for prompt res ${res.data}");
        List<AddResourceListModel> getListRes_prompt = [];
        List<AddPromptListModel> getPromotList = [];

        var dialogList = res.data['dialogList'];
        if (dialogList != null) {
          List<dynamic> resourcesList = dialogList['resourcesList'] ?? [];
          for (var resource in resourcesList) {
            getListRes_prompt.add(AddResourceListModel(
              resourceId: resource['_id'] ?? '',
              resourceName: resource['title'] ?? '',
              resourceType: resource['type'] ?? '',
              resourceContent: '',
              resPromptList: [], // Empty string for resourceContent
            ));
          }

          List<dynamic> promptList = dialogList['promptList'] ?? [];
          for (var prompt in promptList) {
            getPromotList.add(AddPromptListModel(
              promptId: prompt['_id'] ?? '',
              promptTitle: prompt['name'] ?? '',
              promptSide1Content: prompt['side1']?['content'] ?? '',
              promptSide2Content: prompt['side2']?['content'] ?? '',
              parentPromptId: '1a',
            ));
          }
        }

        emit(GetResourcePromptDailog(
          res_prompt_list: getListRes_prompt,
          def_prompt_list: getPromotList,
        ));
      } else {
        emit(AddPromptResError( errorMessage: 'Failed to load data'));
      }
    } catch (e) {
      print("Error: $e");
      emit(AddPromptResError(errorMessage: "${e.toString()}"));
    }
  }

  addpromptRes({required String promptId, required String promptName, required String resourceId, required String resourceName, required BuildContext context})async{
    print("Cubit function hit");
    var res = await PromptResRepo.AddPromptInResource(promptId: promptId, resourceId: resourceId, dialogId: "di");
    if(res?.statusCode ==200){
      print("Else condition is run");
      Navigator.pop(context);
      emit(AddPromptResSuccess(promptName: promptName, resourceName: resourceName));
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 5, // Adjust the elevation as needed
            backgroundColor: Colors.white, // Background overlay color
            child: Container(
              height: MediaQuery.of(context).size.height*0.3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("$promptName is successfully added in $resourceName", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                  ),
                  SizedBox(height: 10,),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(90)
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 48,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
    else{
      EasyLoading.showToast("Error");
  /*    Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context).pop();
      });*/
    }


  }


getPromptFromResource({required String resourceId})async{
    emit(AddPromptResLoading());
    var res = await PromptResRepo.getPrompResource(resourceId: resourceId);
    List<FlowDataModel> getPromptData = [];
    print("resourceId --$resourceId");
    if(res!.statusCode==200){

      print("resource prompt is ${res.data}");
      List<dynamic> resPrompt = res.data['data']['record'];
      List<FlowDataModel> flowModel=[];
      for(var list in resPrompt){
       flowModel.add(FlowDataModel(
           resourceTitle: list['resourceId']['title'],
           resourceType: list['resourceId']['type'],
           resourceContent: "resourceContent",
           side1Title: list['side1']['title'],
           side1Type: list['side1']['type'],
           side1Content: list['side1']['content'],
           side2Title: list['side2']['title'],
           side2Type: list['side2']['type'],
           side2Content: list['side2']['content'],
           promptName: list['name'], promptId: list["_id"])) ;
      }
      emit(GetPromptFromResourceSuccess(flowModel: flowModel));
    }

}

promptUdateDialog({required String dialogId, required List<String> promptId, required BuildContext context}) async{
  print("prompt ids=====>>>>>>>$promptId");
    Response? res = await PromptResRepo.updatePrompt(listpromtId: promptId, dialogId: dialogId, context: context);
    if(res!.statusCode==200){
      print("########---=--=-==-=-=-=-=>$res.data");
      Navigator.pop(context);
      Navigator.pop(context);

      // Navigator.push(context, MaterialPageRoute(builder: (context)=>DailogCategoryScreen(resourceList: [], promptList: [], dailoId: dialogId)));
      emit(GetPromptUpdate());
    }

}
deleteResource({required String resourceId}) async{
    var res = await PromptResRepo.deleteResource(resourceId: resourceId);
    if(res.statusCode==200){
     emit(ResourceDeletedSuccess());
    }
    else{
      EasyLoading.showToast("Sorry to delete failed");
    }
}

getFlowDialog({required String dailogId})async{
  emit(AddPromptResLoading());
  Response response = await CreateFlowRepo.getAllFlow(catID: dailogId);

  print(response);
  if(response.statusCode == 400){
    emit(AddPromptResError(errorMessage: "get failed flow"));
  }
  else{
    List<FlowModel> flowList = [];
    /*for(var item in response.data['data']['record']){
          flowList.add(FlowModel(title: item['title'], id: item['_id']));
        }*/
    for(var item in response.data['data']['record']){
      List<FlowDataModel> flowData = [];

      for (var flow in item['flow']){
        print("=======>${flow}");

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
      flowList.add(FlowModel(
        title: item['title'],
        id: item['_id'],
        categoryId: item['categoryId'],
        flowList: flowData,
      ));
    }
    emit(GetFlowSuccess(flowList).copyWith(flowList: flowList));
  }
}

getFlowDelete({required String dailogId, required BuildContext context, required String flowId, required List<FlowModel> flowList, required int deleteIndex}) async{
  EasyLoading.show(dismissOnTap: true);
  Response response = await CreateFlowRepo.deleteFlow(flowId: flowId);
  if(response.statusCode == 400){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete Failed!')));
  }else{
    flowList.removeAt(deleteIndex);
    EasyLoading.dismiss();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted Successfully!')));
    emit(GetFlowDeletedSuccess());
  }
}

}
