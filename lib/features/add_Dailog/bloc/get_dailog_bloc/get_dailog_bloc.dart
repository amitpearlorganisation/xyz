import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:meta/meta.dart';
import 'package:self_learning_app/features/add_Dailog/repo/create_dailog_repo.dart';

import '../../model/addDailog_model.dart';

part 'get_dailog_event.dart';
part 'get_dailog_state.dart';

class GetDailogBloc extends Bloc<GetDailogEvent, GetDailogState> {
  GetDailogBloc() : super(GetDailogInitial()) {
  on<HitGetDailogEvent>(onGetDailog);
  on<DeleteDailogEvent>(onDeleteDailog);
  }
  void onGetDailog(HitGetDailogEvent event,
      Emitter<GetDailogState> emit) async {
    emit(GetDailogLoadingState());

    print("event is trigger");
    var res = await DailogRepo.getDailog();
    print("status code ${res?.statusCode}");
    print("get dailog ${res?.data}");
    if(res?.statusCode == 200){
          print("empty dailog response == ${res!.data}");

      // Create a list to store AddDailogModel objects
      List<AddDailogModel> getlist = [];
      List<AddResourceListModel> getResourceList = [];
      List<AddPromptListModel> getPromptList = [];
      List<PromptListforResourceModel> getResPromptList=[];
      getResPromptList.add(PromptListforResourceModel(promptId: "1", parentPromptId: "1", promptTitle: "promptTitle1", promptSide1Content: "youtube", promptSide2Content: "Movie"));
      getResPromptList.add(PromptListforResourceModel(promptId: "2", parentPromptId: "2", promptTitle: "promptTitle2", promptSide1Content: "flipkart", promptSide2Content: "Shoping"));
      getResPromptList.add(PromptListforResourceModel(promptId: "3", parentPromptId: "3", promptTitle: "promptTitle3", promptSide1Content: "Discovery", promptSide2Content: "Animal"));
      getResPromptList.add(PromptListforResourceModel(promptId: "4", parentPromptId: "4", promptTitle: "promptTitle4", promptSide1Content: "History", promptSide2Content: "Harrapa"));
      getResPromptList.add(PromptListforResourceModel(promptId: "5", parentPromptId: "5", promptTitle: "promptTitle5", promptSide1Content: "Britain", promptSide2Content: "Londan"));
      getResPromptList.add(PromptListforResourceModel(promptId: "6", parentPromptId: "6", promptTitle: "promptTitle6", promptSide1Content: "Usa", promptSide2Content: "Newyork"));





      getResourceList.add(AddResourceListModel(resourceId: "1", resourceName: "amit", resourceType: "Video", resourceContent: "videoUrl",
     resPromptList: getResPromptList));
      getResourceList.add(AddResourceListModel(resourceId: "2", resourceName: "vipin", resourceType: "Audio", resourceContent: "audioUrl",
      resPromptList: getResPromptList
      ));
      getResourceList.add(AddResourceListModel(resourceId: "3", resourceName: "Rakesh", resourceType: "Image", resourceContent: "imageUrl",
      resPromptList: getResPromptList
      ));
      getResourceList.add(AddResourceListModel(resourceId: "4", resourceName: "atul", resourceType: "Text", resourceContent: "noramal",
      resPromptList: getResPromptList
      ));
      getResourceList.add(AddResourceListModel(resourceId: "5", resourceName: "prem", resourceType: "Image", resourceContent: "imageUrl",
          resPromptList: getResPromptList
      ));
      getResourceList.add(AddResourceListModel(resourceId: "6", resourceName: "shubham", resourceType: "Text", resourceContent: "noramal",
          resPromptList: getResPromptList
      ));

      getPromptList.add(AddPromptListModel(promptId: "123", parentPromptId: "1a", promptTitle: "book",
          promptSide1Content: "promptSide1Content", promptSide2Content: "promptSide2Content"));
      getPromptList.add(AddPromptListModel(promptId: "456", parentPromptId: "1b", promptTitle: "youtube",
          promptSide1Content: "promptSide1Content2", promptSide2Content: "promptSide2Content2"));

      // Iterate through the dialogs and populate getlist
          if(res.data['message']=="No Dialogs found!!"){
            emit(GetDailogSuccessState(dailogList: [], resourceList: [], promptList: []));

          }
          else {
            List<dynamic> dialogs = res!.data['dialogs'];

            for (var dialog in dialogs) {
              String dailogId = dialog['_id'];
              String userId = dialog['userId'];
              String dailogName = dialog['name'];
              print("dailogId=$dailogId");

              getlist.add(AddDailogModel(
                dailogName: dailogName,
                dailogId: dailogId,
                userId: userId,
              ));
            }
            emit(GetDailogSuccessState(dailogList: getlist,
                resourceList: getResourceList,
                promptList: getPromptList));
          }
       }


 else{
   print("false condition is run");
   emit(GetDailogErrorState(errorMessage: "error"));
 }



  }


  void onDeleteDailog(DeleteDailogEvent event,
      Emitter<GetDailogState> emit) async{

    var res = await DailogRepo.deleteDailog(dailogId: event.dailogId);
    print("status code of dailog delete${res.statusCode}");
    if(res.statusCode==200){
      state.dailogList?.removeAt(event.index);
      emit(DailogDeleteSuccessfully(dailogname: event.dailogName));

    }
    else{
      EasyLoading.showToast("Error form dailog delete${res.data}");
    }

    /*if(res?.statusCode == 200){
      state.dailogList?.removeAt(event.index);
      emit(DailogDeleteSuccessfully(dailogname: event.dailogName));
    }
    else{
      emit(DailogDeleteSuccessfully(dailogname: event.dailogName));

      EasyLoading.showToast("Sorry this dailog is not delted");

    }*/



  }
}
