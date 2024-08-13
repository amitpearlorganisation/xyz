
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:self_learning_app/features/add_promts_to_flow/bloc/data/model/add_prompt_to_flow_model.dart';

import 'data/repo/add_prompts_to_flow_repo.dart';

part 'add_promts_to_flow_event.dart';
part 'add_promts_to_flow_state.dart';

class AddPromtsToFlowBloc extends Bloc<AddPromtsToFlowEvent, AddPromtsToFlowInitial> {
  AddPromtsToFlowBloc() : super(
      AddPromtsToFlowInitial(
        mainCategory: APIStatus.initial,
        subCategory: APIStatus.initial,
        subCategory1: APIStatus.initial,
        subCategory2: APIStatus.initial,
      )) {
    on<LoadMainCategoryData>((event, emit) async {
      // TODO: implement event handler
      emit(state.copyWith(mainCategory: APIStatus.loading));
      await AddPromptsToFlowRepo.getData(mainCatId: event.catId).then((value) {
        if(value == null){
          emit(state.copyWith(mainCategory: APIStatus.loadFailed,));
        }else{
          emit(state.copyWith(mainCategory: APIStatus.loadSuccess, mainCategoryData: value));
        }
      });
    });

    on<LoadSubCategoryData>((event, emit) async {
      // TODO: implement event handler
      //EasyLoading.show(dismissOnTap: true);
      emit(state.copyWith(subCategory: APIStatus.loading, subCategorySelected: event.catName));
      await AddPromptsToFlowRepo.getData(mainCatId: event.catId).then((value) {
        if(value == null){
          emit(state.copyWith(subCategory: APIStatus.loadFailed, subCategorySelected: event.catName));
        }else{
          emit(state.copyWith(
              subCategory: APIStatus.loadSuccess,
              subCategoryData: value,
            subCategory1: APIStatus.initial,
            subCategory1Data: AddPromptToFlowModel(promptList: [], categoryList: []),
            subCategory2: APIStatus.initial,
              subCategory2Selected: event.catName,
            subCategory2Data: AddPromptToFlowModel(promptList: [], categoryList: [])
              ));
        }
      });
      //EasyLoading.dismiss();
    });

    on<LoadSubCategory1Data>((event, emit) async {
      // TODO: implement event handler
      //EasyLoading.show(dismissOnTap: true);
      emit(state.copyWith(subCategory1: APIStatus.loading, subCategory1Selected: event.catName));
      await AddPromptsToFlowRepo.getData(mainCatId: event.catId).then((value) {
        if(value == null){
          emit(state.copyWith(subCategory1: APIStatus.loadFailed, subCategory1Selected: event.catName));
        }else{
          emit(state.copyWith(
              subCategory1: APIStatus.loadSuccess,
              subCategory1Data: value,
              subCategory2: APIStatus.initial,
              subCategory1Selected: event.catName,
              subCategory2Data: AddPromptToFlowModel(promptList: [], categoryList: [])
          ));
        }
      });
      //EasyLoading.dismiss();
    });

    on<LoadSubCategory2Data>((event, emit) async {
      // TODO: implement event handler
      //EasyLoading.show(dismissOnTap: true);
      emit(state.copyWith(subCategory2: APIStatus.loading, subCategory2Selected: event.catName));
      await AddPromptsToFlowRepo.getData(mainCatId: event.catId).then((value) {
        if(value == null){
          emit(state.copyWith(subCategory2: APIStatus.loadFailed, subCategory2Selected: event.catName));
        }else{
          emit(state.copyWith(subCategory2: APIStatus.loadSuccess, subCategory2Selected: event.catName, subCategory2Data: value));
        }
      });
      //EasyLoading.dismiss();
    });
  }
}
