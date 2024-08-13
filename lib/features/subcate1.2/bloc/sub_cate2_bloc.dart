

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:self_learning_app/features/subcate1.2/bloc/sub_cate2_event.dart';
import 'package:self_learning_app/features/subcate1.2/bloc/sub_cate2_state.dart';
import 'package:self_learning_app/utilities/extenstion.dart';

import '../../category/data/repo/category_repo.dart';
import '../repo/subcate2_repo.dart';


class SubCategory2Bloc extends Bloc<SubCategory2Event, SubCategory2State> {
  SubCategory2Bloc() : super(SubCategory2Loading()) {
    on<SubCategory2LoadEvent>(_onGetSubCategoryList);
    on<SubCategory2DeleteEvent>((event, state) async {
      EasyLoading.show(dismissOnTap: true);
      Response response = await CategoryRepo.deleteCategory(rootId: event.rootId);
      EasyLoading.dismiss();
      if(response.statusCode == 400) {
        event.context.showSnackBar(SnackBar(content: Text('Something went wrong!')));
      }else{
        event.context.showSnackBar(SnackBar(content: Text('Category deleted Successfully')));
        event.catList.removeAt(event.deleteIndex);
        emit(SubCategory2Loaded(cateList: event.catList, value: true));
      }
    });

  }

  void _onGetSubCategoryList(
      SubCategory2LoadEvent event, Emitter<SubCategory2State> emit) async {
    emit(SubCategory2Loading());
    try {
      print(event.rootId);
      print('event.rootId');
      await SubCategory2Repo.getAllCategory(event.rootId).then((value) {
        emit(SubCategory2Loaded(cateList: value, value: false));
      });
    } catch (e) {
      print(e);
      emit(SubCategory2Failed(errorText: 'Oops Something went wrong'));
    }
  }
}
