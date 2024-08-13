part of 'add_promts_to_flow_bloc.dart';

abstract class AddPromtsToFlowState extends Equatable {
  const AddPromtsToFlowState();
}

enum APIStatus{initial, loading, loadSuccess, loadFailed,}

class AddPromtsToFlowInitial extends AddPromtsToFlowState {

  APIStatus mainCategory;
  APIStatus subCategory;
  APIStatus subCategory1;
  APIStatus subCategory2;

  String subCategorySelected;
  String subCategory1Selected;
  String subCategory2Selected;

  AddPromptToFlowModel? mainCategoryData;
  AddPromptToFlowModel? subCategoryData;
  AddPromptToFlowModel? subCategory1Data;
  AddPromptToFlowModel? subCategory2Data;


  AddPromtsToFlowInitial({
    required this.mainCategory,
    required this.subCategory,
    required this.subCategory1,
    required this.subCategory2,
    this.subCategorySelected = '',
    this.subCategory1Selected = '',
    this.subCategory2Selected = '',
    this.subCategoryData,
    this.mainCategoryData,
    this.subCategory1Data,
    this.subCategory2Data});

  AddPromtsToFlowInitial copyWith({
    APIStatus? mainCategory,
    APIStatus? subCategory,
    APIStatus? subCategory1,
    String? subCategorySelected,
    String? subCategory1Selected,
    String? subCategory2Selected,
    AddPromptToFlowModel? mainCategoryData,
    AddPromptToFlowModel? subCategoryData,
    AddPromptToFlowModel? subCategory1Data,
    AddPromptToFlowModel? subCategory2Data,
    APIStatus? subCategory2,}){
    return AddPromtsToFlowInitial(
        mainCategory: mainCategory?? this.mainCategory,
        subCategory: subCategory?? this.subCategory,
        subCategory1: subCategory1 ?? this.subCategory1,
        subCategory2: subCategory2 ?? this.subCategory2,
      subCategorySelected: subCategorySelected?? '',
      subCategory1Selected: subCategory1Selected?? '',
      subCategory2Selected: subCategory2Selected?? '',
      mainCategoryData: mainCategoryData ?? this.mainCategoryData,
      subCategoryData: subCategoryData ?? this.subCategoryData,
      subCategory1Data: subCategory1Data ?? this.subCategory1Data,
      subCategory2Data: subCategory2Data ?? this.subCategory2Data,
    );
  }

  @override
  List<Object> get props => [mainCategory, subCategory, subCategory1, subCategory2,];
}
