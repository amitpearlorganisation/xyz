// import 'dart:async';
// import 'dart:ui';
//
// import 'package:bloc/bloc.dart';
// import 'package:flutter/material.dart';
// import 'package:meta/meta.dart';
//
// import '../data/repo/add_cate_repo.dart';
//
// part 'add_category_event.dart';
//
// part 'add_category_state.dart';
//
// class AddCategoryBloc extends Bloc<AddCategoryEvent, InitialAddCatState> {
//   AddCategoryBloc() : super(InitialAddCatState()) {
//     on<CategoryNameChangedEvent>(_onCategoryNameChanged);
//     on<CategoryColorChangedEvent>(_onCategoryColorChanged);
//     on<SubmitCategoryEvent>(_onSubmitCategory);
//   }
//
//   void _onSubmitCategory(
//       SubmitCategoryEvent event, Emitter<InitialAddCatState> emit) async {
//     print(event.categoryTitle);
//     print(event.categoryColor);
//    emit(AddCategoryLoadingState());
//     try {
//       print('inside bloc title');
//       await AddCateRepo.addCategory(
//               cateTitle: event.categoryTitle!, fontColor: event.categoryColor)
//           .then((value) {
//         emit(AddCategorySuccessState());
//       });
//     } catch (e) {
//       print('${e} this is error');
//       emit(AddCategoryunErrorState());
//     }
//   }
//
//   void _onCategoryNameChanged(
//       CategoryNameChangedEvent event, Emitter<InitialAddCatState> emit) async {
//     emit(state.copyWith(cateName: event.categoryTitle));
//     print(state.cateName);
//     print('state.cateName');
//   }
//   void _onCategoryColorChanged(
//       CategoryColorChangedEvent event, Emitter<InitialAddCatState> emit) async {
//     emit(state.copyWith(catebgColor: event.categoryColor));
//     print(state.catebgColor);
//     print('state.catebgColor');
//   }
//
// }
