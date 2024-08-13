

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:self_learning_app/features/subcate1.1/bloc/sub_cate1_event.dart';
import 'package:self_learning_app/features/subcate1.1/bloc/sub_cate1_state.dart';
import 'package:self_learning_app/utilities/extenstion.dart';

import '../../category/data/repo/category_repo.dart';
import '../repo/subcate1_repo.dart';


class SubCategory1Bloc extends Bloc<SubCategory1Event, SubCategory1State> {
  SubCategory1Bloc() : super(SubCategory1Loading()) {
    on<SubCategory1LoadEvent>(_onGetSubCategoryList);
    on<SubCategory1LoadEmptyEvent>(_onSubCategory1LoadEmptyEvent);
    on<DDValueSubCategoryChanged>(_onDDValueSubCategoryChanged);
    on<SubCategory1DeleteEvent>((event, state) async {
      EasyLoading.show(dismissOnTap: true);
      Response response = await CategoryRepo.deleteCategory(rootId: event.rootId);
      EasyLoading.dismiss();
      if(response.statusCode == 400) {
        event.context.showSnackBar(SnackBar(content: Text('Something went wrong!')));
      }else{
        event.context.showSnackBar(SnackBar(content: Text('Category deleted Successfully')));
        event.catList.removeAt(event.deleteIndex);
        emit(SubCategory1Loaded(cateList: event.catList,value: true));
      }
    });

  }

  void _onGetSubCategoryList(SubCategory1LoadEvent event,
      Emitter<SubCategory1State> emit) async {
    emit(SubCategory1Loading());
    try {
      await SubCategory1Repo.getAllCategory(event.rootId).then((value) =>
          emit(SubCategory1Loaded(cateList: value,value: false)));
    } catch (e) {
      print(e);
      emit(SubCategory1Failed(errorText: 'Oops Something went wrong'));
    }
  }


  void _onSubCategory1LoadEmptyEvent(SubCategory1LoadEmptyEvent event,
      Emitter<SubCategory1State> emit) async {
    emit(SubCategory1Loaded(cateList: const [], value: false));
  }



  void _onDDValueSubCategoryChanged(DDValueSubCategoryChanged event,
      Emitter<SubCategory1State> emit) {
    emit(SubCategory1Loaded(cateList: event.cateList!, ddValue: event.ddValue, value: false));
  }
}