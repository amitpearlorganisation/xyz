part of 'add_media_bloc.dart';



enum ApiState {initial ,submitting,submitted,submitError,}

@immutable
abstract class AddMediaState {}

class AddMediaInitial extends AddMediaState {
  final ApiState apiState;
  final String? selectedFilepath;
  final String? name;
  final int ?  wichResources;
  AddMediaInitial( { this.name,required this.apiState,this.selectedFilepath='', this.wichResources});

  AddMediaInitial copyWith(
      {String? name, String? selectedFilepath,ApiState? apiState, int ?  wichResources}) {
    return AddMediaInitial(
      apiState: apiState??this.apiState,
        name: name ?? this.name,
        selectedFilepath: selectedFilepath??this.selectedFilepath ,
        wichResources: wichResources??this.wichResources);
  }
}
