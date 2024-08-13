
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:self_learning_app/features/category/data/repo/category_repo.dart';
import 'package:self_learning_app/features/subcategory/bloc/sub_cate_event.dart';
import 'package:self_learning_app/features/subcategory/bloc/sub_cate_state.dart';
import 'package:self_learning_app/utilities/extenstion.dart';

class SubCategoryBloc extends Bloc<SubCategoryEvent, SubCategoryState> {
  SubCategoryBloc() : super(SubCategoryLoading()) {
    on<SubCategoryLoadEvent>(_onGetSubCategoryList);
   on<SubCateChangeDropValueEvent>(_onSubCateChangeDropValueEvent);
    on<SubCategoryDeleteEvent>((event, state) async {
      EasyLoading.show(dismissOnTap: true);
      Response response = await CategoryRepo.deleteCategory(rootId: event.rootId);
      EasyLoading.dismiss();
      if(response.statusCode == 400) {
        event.context.showSnackBar(SnackBar(content: Text('Something went wrong!')));
      }else{
        event.context.showSnackBar(SnackBar(content: Text('Category deleted Successfully')));
        event.catList.removeAt(event.deleteIndex);
        emit(SubCategoryLoaded(cateList: event.catList));
      }
    });

  }

  void _onGetSubCategoryList(
      SubCategoryLoadEvent event, Emitter<SubCategoryState> emit) async {
    emit(SubCategoryLoading());

      await CategoryRepo.getAllSubCategory(event.rootId).then((value) {

        emit(SubCategoryLoaded(cateList: value,ddValue: value.isNotEmpty?value.first.sId:''));
      });
    }


  void _onSubCateChangeDropValueEvent(
      SubCateChangeDropValueEvent event, Emitter<SubCategoryState> emit) async {
    emit(SubCategoryLoaded(cateList: event.list!,ddValue: event.subCateId));
  }

}


