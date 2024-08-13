part of 'create_dailog_bloc.dart';

@immutable
abstract class CreateDailogState {}

class CreateDailogInitial extends CreateDailogState {}
class AddDailogLoadingState extends CreateDailogState{}
class DailogCreateSuccessState extends CreateDailogState{}