import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:meta/meta.dart';
import 'package:self_learning_app/features/category/data/model/category_model.dart';
import 'package:self_learning_app/features/category/data/repo/category_repo.dart';
import 'package:self_learning_app/utilities/extenstion.dart';
import 'category_state.dart';
part 'category_event.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc() : super(CategoryLoading()) {
    on<CategoryLoadEvent>(_onGetCategoryList);
    on<CategoryImportEvent>(_oncategoryImportEvent);
  // on<SubCategoryLoadEvent>(_onGetSubCategoryList);
    on<CategoryDeleteEvent>((event, state) async {
      EasyLoading.show(dismissOnTap: true);
      Response response = await CategoryRepo.deleteCategory(rootId: event.rootId);
      EasyLoading.dismiss();
      if(response.statusCode == 400) {
        print("sorry to delete category");
        event.context.showSnackBar(SnackBar(content: Text('Something went wrong!')));
      }else{
        event.context.showSnackBar(SnackBar(content: Text('Category deleted Successfully')));
        // event.catList.removeAt(event.deleteIndex);
        // emit(CategoryLoaded(cateList: event.catList));
        emit(CategoryDeleteSuccess());
      }
    });

  }

  void _onGetCategoryList(
      CategoryLoadEvent event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    try {
      await CategoryRepo.getAllCategory().then((value) {
        emit(CategoryLoaded(cateList: value));
      });
    } catch (e) {
      print(e);
      emit(CategoryFailed(errorText: 'Oops Something went wrong'));
    }
  }


  void _oncategoryImportEvent(
      CategoryImportEvent event, Emitter<CategoryState> emit) async {
    emit(CategoryChanged(category: event.dropDownValue!));
  }

  // void _onGetSubCategoryList(
  //     SubCategoryLoadEvent event, Emitter<CategoryState> emit) async {
  //   emit(CategoryLoading());
  //   try {
  //     await CategoryRepo.getAllSubCategory(event.rootId).then((value) {
  //       emit(SubCategoryLoaded(subCateList: value));
  //     });
  //   } catch (e) {
  //     print(e);
  //     emit(CategoryFailed(errorText: 'Oops Something went wrong'));
  //   }
  // }



}
