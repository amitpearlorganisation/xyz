part of 'resources_bloc.dart';

@immutable
abstract class ResourcesState {}

class ResourcesInitial extends ResourcesState {}
class ResourcesLoading extends ResourcesState {}
class ResourcesLoaded extends ResourcesState {
  final AllResourcesModel allResourcesModel;
  ResourcesLoaded({required this.allResourcesModel});
}
class ResourcesError extends ResourcesState {}

class ResourcesDelete extends ResourcesState {}

