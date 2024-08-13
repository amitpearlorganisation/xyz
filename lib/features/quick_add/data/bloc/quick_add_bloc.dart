import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:meta/meta.dart';
import 'package:self_learning_app/features/quick_add/data/repo/model/quick_type_model.dart';
import 'package:self_learning_app/features/quick_add/data/repo/quick_add_repo.dart';
import 'package:self_learning_app/features/resources/bloc/resources_bloc.dart';

import '../repo/model/quick_type_prompt_model.dart';
import '../repo/quickPromptRepo.dart';

part 'quick_add_event.dart';
part 'quick_add_state.dart';

class QuickAddBloc extends Bloc<QuickAddEvent, QuickAddState> {
  QuickAddBloc() : super(QuickAddInitial()) {
    on<ButtonPressedEvent>(_onButtonPressed);
    on<LoadQuickTypeEvent>(_onLoadQuickTypes);
    on<QuickDeleteResource>(_ondeleteQuickTypes);
  }

  void _onButtonPressed(ButtonPressedEvent event, Emitter<QuickAddState> emit) async {
    emit(QuickAddLoadingState());
    try {
      await QuickAddRepo.quickAdd(
          title: event.title!, contentType: event.contentType).then((value) {
        if (value == 201) {
          emit(QuickAddLoadedState());
        } else {
          emit(QuickAddErrorState(message: "error"));
        }
      });
    } catch (e) {
      print('$e this is error');
      emit(QuickAddErrorState(message: e.toString()));
    }
  }

  void _onLoadQuickTypes(LoadQuickTypeEvent event, Emitter<QuickAddState> emit) async {
    emit(QuickAddLoadingState());
    try {
      await QuickAddRepo.getAllQuickTypes().then((value) {
        print(value.data!.record!.records);
        print('valuessss');
        emit(QuickAddLoadedState(list: value));
      });
    } catch (e) {
      print(e);
      emit(QuickAddErrorState(message: e.toString()));
    }
  }

  void _ondeleteQuickTypes(QuickDeleteResource event, Emitter<QuickAddState> emit) async {
    emit(QuickAddLoadingState());
    try {
      var res = await QuickAddRepo.deletequickAdd(id: event.id!, context: event.context);

      if (res == 200) {
        emit(QuickResourceDelete());
      } else {
        emit(QuickAddErrorState(message: 'Failed to delete resource. Status code: $res'));
      }
    } catch (e) {
      print(e);
      emit(QuickAddErrorState(message: e.toString()));
    }
  }
}
