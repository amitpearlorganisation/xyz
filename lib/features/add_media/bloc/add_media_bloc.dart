import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
import 'package:self_learning_app/features/add_media/repo/add_media_repo.dart';

part 'add_media_event.dart';
part 'add_media_state.dart';

class AddMediaBloc extends Bloc<AddMediaEvent, AddMediaInitial> {
  final StreamController<int> _progressController = StreamController<int>();

  Stream<int> get progressStream => _progressController.stream;

  AddMediaBloc() : super(AddMediaInitial(apiState: ApiState.initial)) {
    on<ImagePickEvent>(_onImagePickEvent);
    on<SubmitButtonEvent>(_onSubmitButtonEvent);
    on<AudioPickEvent>(_onAudioPickEvent);
    on<VideoPickEvent>(_onVideoPickEvent);
    on<TextPickEvent>(_onTextPickEvent);
    on<RemoveMedia>(_onRemoveMedia);
  }
  _onAudioPickEvent(AudioPickEvent event, Emitter<AddMediaInitial> emit) {
    emit(state.copyWith(selectedFilepath: event.audio));
  }

  _onImagePickEvent(ImagePickEvent event, Emitter<AddMediaInitial> emit) {
    emit(state.copyWith(selectedFilepath: event.image));
  }

  _onVideoPickEvent(VideoPickEvent event, Emitter<AddMediaInitial> emit) {
    emit(state.copyWith(
      selectedFilepath: event.video,
    ));
  }

  _onTextPickEvent(TextPickEvent event, Emitter<AddMediaInitial> emit) {
    emit(state.copyWith(name: event.title));
  }

  _onRemoveMedia(RemoveMedia event, Emitter<AddMediaInitial> emit) {
    emit(state.copyWith(selectedFilepath: ''));
  }

  _onSubmitButtonEvent(SubmitButtonEvent event, Emitter<AddMediaInitial> emit)async {
    emit(state.copyWith(apiState: ApiState.submitting));
    try {

   if(event.whichResources==2){
     await  AddMediaRepo.addPrompt(imagePath: state.selectedFilepath,name: event.title??'Untitled',resourcesId: event.rootId!,).then((value) {
         emit(state.copyWith(apiState: ApiState.submitted,wichResources: 2));

     });
   } else if(event.whichResources==0){
     print("filepath ${state.selectedFilepath}");
     await  AddMediaRepo.addQuickAddwithResources(imagePath: state.selectedFilepath,title: event.title??'Untitled',contenttype: event.MediaType).then((value) {
         emit(state.copyWith(apiState: ApiState.submitted,wichResources: 0));
     });
   }else {
     await  AddMediaRepo.addResources(imagePath: state.selectedFilepath, title: event.title, resourceId:  event.rootId??'',mediaType: event.MediaType).then((value) {

       if (value != null) {
         emit(state.copyWith(apiState: ApiState.submitted,wichResources: 1));
       }
     }
       );
   }

    } catch (e) {
      emit(state.copyWith(apiState: ApiState.submitError));
    } finally {
      emit(state.copyWith(apiState: ApiState.initial));
    }
  }
}
