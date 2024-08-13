part of 'quick_add_bloc.dart';

@immutable
abstract class QuickImportState extends Equatable{}

class QuickImportInitial extends QuickImportState {
  @override
  List<Object?> get props => [];
}

class QuickImportLoadingState extends QuickImportState {
  List<Object?> get props => [];
}

class QuickImportLoadedState extends QuickImportState {
  final String? value;
  final List<QuickImportModel>? list;
  QuickImportLoadedState({this.value,this.list});

  QuickImportLoadedState copyWith({
    String? value,
    List<QuickImportModel>? list,
  })=>
      QuickImportLoadedState(
        list: list??this.list,
        value:value??this.value
      );

  @override
  List<Object?> get props => [list,value];
}

class QASubLoadedState extends QuickImportState {
  final String? value;
  final List<QuickImportModel>? list;
  QASubLoadedState({this.value,this.list});

  QuickImportLoadedState copyWith({
    String? value,
    List<QuickImportModel>? list,
  })=>
      QuickImportLoadedState(
          list: list??this.list,
          value:value??this.value
      );
  @override
  List<Object?> get props => [list,value];
}



class QuickImportErrorState extends QuickImportState {
  @override
  List<Object?> get props => [];
}

class QuickImportSuccessfullyState extends QuickImportState {
  @override
  List<Object?> get props => [];
}