import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'promts_screen_event.dart';
part 'promts_screen_state.dart';

class PromtsScreenBloc extends Bloc<PromtsScreenEvent, PromtsScreenState> {
  PromtsScreenBloc() : super(PromtsScreenInitial()) {
    on<PromtsScreenEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
