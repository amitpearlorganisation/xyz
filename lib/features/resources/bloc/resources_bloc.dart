import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:self_learning_app/features/resources/data/rep/resources_repo.dart';
import 'package:self_learning_app/features/subcategory/model/resources_model.dart';

part 'resources_event.dart';
part 'resources_state.dart';

class ResourcesBloc extends Bloc<ResourcesEvent, ResourcesState> {
  ResourcesBloc() : super(ResourcesInitial()) {
    on<LoadResourcesEvent>(_onLoadResourcesEvent);
    on<DeleteResourcesEvent>(_onDeleteResourcesEvent);
  }

  _onLoadResourcesEvent(
      LoadResourcesEvent event, Emitter<ResourcesState> emit) async {
    emit(ResourcesLoading());
    try {
      await ResourcesRepo.getResources(
              rootId: event.rootId, mediaType: event.mediaType, resQueary: event.resourcQueary)
          .then((value) {
        emit(ResourcesLoaded(allResourcesModel: value!));
        // print("Fetched Data ===>>> $value");
      });
    } catch (e) {
      emit(ResourcesError());
    }
  }

  _onDeleteResourcesEvent(

      DeleteResourcesEvent event, Emitter<ResourcesState> emit) async {
    emit(ResourcesLoading());

    Response? res = await ResourcesRepo.deleteResource(rootId: event.rootId);
        print("Resource delete successfully");
        print("to check the status code ${res?.statusCode}");
       if(res?.statusCode ==200){
         emit(ResourcesDelete());

       }
       else{
         emit(ResourcesError());
       }
  }
}
