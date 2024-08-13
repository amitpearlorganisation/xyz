import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:self_learning_app/features/add_media/repo/add_media_repo.dart';
import 'package:self_learning_app/features/add_promts/add_promts_screen.dart';
import 'package:self_learning_app/features/add_promts/repo/add_prompts_repo.dart';

part 'add_prompts_event.dart';
part 'add_prompts_state.dart';

class AddPromptsBloc extends Bloc<AddPrompts, AddPromptsInitial> {
  AddPromptsBloc() : super(AddPromptsInitial()) {
    on<ChangeMediaType>(_onChangeMediaType);
    on<PickResource>(_onPickResource);
    on<AddResource>(_onAddResource);
    on<QuickAddResource>(_onAddQuickResource);
    on<AddPromptEvent>(_onAddPromptEvent);
    on<AddPromptEventforQuickPrompt>(_onAddQuickPrompt);
    on<ResetFileUploadStatus>((event, emit) {
      emit(state.copyWith(uploadStatus: UploadStatus.initial));
    },);
  }

  _onChangeMediaType(ChangeMediaType event, Emitter<AddPromptsInitial> emit) {
    print(event.whichSide);
    // print(event.MediaType);
    if (event.whichSide == 0) {
      emit(state.copyWith(
          side1selectedMediaType: event.MediaType, side1ResourceUrl: ''));
    } else {
      emit(state.copyWith(
          side2selectedMediaType: event.MediaType, side1ResourceUrl: ''));
    }
  }

  _onPickResource(PickResource event, Emitter<AddPromptsInitial> emit) {
    if (event.whichSide == 0) {
      emit(state.copyWith(side1ResourceUrl: event.mediaUrl, resource1status: Resource1Status.selected));
    } else {
      emit(state.copyWith(side2ResourceUrl: event.mediaUrl, resource2status: Resource2Status.selected));
    }
  }

  _onAddResource(AddResource event, Emitter<AddPromptsInitial> emit) async {
    // print("====>>>>> ${convertMediaTypeToInt(state.side1selectedMediaType!)}");
    // print("====>>>>> ${state.side1selectedMediaType!}");
    // print("====>>>>> ${convertMediaTypeToInt(event.mediaUrl!)}");
    print("====>>>>> ${event.mediaUrl!} content ${event.content}");
    await AddPromtsRepo.addResourcesForSide(

            resourceId: event.resourceId!??"",
            whichSide: event.whichSide!,
            // mediaType: convertMediaTypeToInt(state.side1selectedMediaType!),
            // mediaType: convertMediaTypeToInt(event.mediaUrl!),
            mediaType: event.mediaUrl!,
            content: event.content)
        .then((value) async {
      final data = await jsonDecode(value.body);
      if (event.whichSide == 0) {
        print('saved side1 _id');
        print(data);
        try {
          print('try');
          emit(state.copyWith(
              side1Id: data['data'][0]['_id'].toString(),
              uploadStatus: UploadStatus.resourceAdded,
            resource1status: Resource1Status.uploaded,
          )
          );
        } catch (e) {

          print('catch  - $e');
          emit(state.copyWith(
              side1Id: data['data']['_id'].toString(),
              uploadStatus: UploadStatus.resourceAdded,
            resource1status: Resource1Status.uploaded,

          ));
        }
      } else {
        print('saved side2 _id');
        print(data);
        try {
          emit(
            state.copyWith(
                side2Id: data['data'][0]['_id'].toString(),
                uploadStatus: UploadStatus.resourceAdded,
              resource2status: Resource2Status.uploaded,

            ),
          );
        } catch (e) {
          emit(
            state.copyWith(
                side2Id: data['data']['_id'].toString(),
                uploadStatus: UploadStatus.resourceAdded,
              resource2status: Resource2Status.uploaded,
            ),
          );
        }
      }
    });
  }
  _onAddQuickResource(QuickAddResource event, Emitter<AddPromptsInitial> emit) async{
    print("====>>>>> ${event.mediaUrl!} content ${event.content}");
    await AddPromtsRepo.quickAddResourcesForSides(
        whichSide: event.whichSide!,
        // mediaType: convertMediaTypeToInt(state.side1selectedMediaType!),
        // mediaType: convertMediaTypeToInt(event.mediaUrl!),
        mediaType: event.mediaUrl!,
        content: event.content)
        .then((value) async {
      final data = await jsonDecode(value.body);
      if (event.whichSide == 0) {
        print('saved side1 _id');
        print(data);
        try {
          print('try');
          emit(state.copyWith(
            side1Id: data['data'][0]['_id'].toString(),
            uploadStatus: UploadStatus.resourceAdded,
            resource1status: Resource1Status.uploaded,
          )
          );
        } catch (e) {

          print('catch  - $e');
          emit(state.copyWith(
            side1Id: data['data']['_id'].toString(),
            uploadStatus: UploadStatus.resourceAdded,
            resource1status: Resource1Status.uploaded,

          ));
        }
      } else {
        print('saved side2 _id');
        print(data);
        try {
          emit(
            state.copyWith(
              side2Id: data['data'][0]['_id'].toString(),
              uploadStatus: UploadStatus.resourceAdded,
              resource2status: Resource2Status.uploaded,

            ),
          );
        } catch (e) {
          emit(
            state.copyWith(
              side2Id: data['data']['_id'].toString(),
              uploadStatus: UploadStatus.resourceAdded,
              resource2status: Resource2Status.uploaded,
            ),
          );
        }
      }
    });
  }

  _onAddPromptEvent(
      AddPromptEvent event, Emitter<AddPromptsInitial> emit) async {
    print(
        "Data To Send: ${event.name} ${event.resourceId!} ${state.side2Id} ${state.side1Id!}");
    await AddPromtsRepo.addSidePrompts(
            name: event.name,
            resourcesId: event.resourceId!,
            categoryId: event.categoryId!,
            side2: state.side2Id,
            side1: state.side1Id)
        .then((value) async {
      emit(AddPromptsInitial(uploadStatus: UploadStatus.uploaded));
    });
  }
  _onAddQuickPrompt( AddPromptEventforQuickPrompt event, Emitter<AddPromptsInitial> emit) async {
    await AddPromtsRepo.quickAddPrompt(name: event.Promptname,
        side1:state.side1Id,
        side2: state.side2Id).then((value) async{
      emit(AddPromptsInitial(uploadStatus: UploadStatus.uploaded));
    });

  }
}


int convertMediaTypeToInt(String mediaType) {
  switch (mediaType.toLowerCase()) {
    case 'Text':
      return 0;
    case 'Image':
      return 1;
    case 'Audio':
      return 2;
    case 'Video':
      return 3;
    default:
      return -1; // Return -1 for an unknown media type.
  }
}
