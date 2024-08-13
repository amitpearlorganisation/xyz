part of 'main_bottom_sheet_cubit.dart';

@immutable
abstract class MainBottomSheetState {}

class MainBottomSheetInitial extends MainBottomSheetState {}
class MainBottomSheetLoading extends MainBottomSheetState {}
class MainBottomSheetLoaded extends MainBottomSheetState {
  final List<SubCategoryModel1> cateList;
  MainBottomSheetLoaded({required this.cateList});
}
class DataisEmpty extends MainBottomSheetState{}
