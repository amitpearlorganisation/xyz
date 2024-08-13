

import 'package:self_learning_app/features/add_promts_to_flow/bloc/data/model/prompt_model.dart';

import 'category_model.dart';

class AddPromptToFlowModel {

  List<PromptModel> promptList;
  List<CategoryModel> categoryList;


  AddPromptToFlowModel({required this.promptList, required this.categoryList});
/*
  AddPromptToFlowModel.fromJson(Map<String, dynamic> json) {
    promptList =  json['prompts'] != null ? PromptModel.fromJson(json['prompts']) : null;
    categoryList = json['categories'] != null ? CategoryModel.fromJson(json['categories']) : null;

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    if (this.resourceId != null) {
      data['resourceId'] = this.resourceId!.toJson();
    }
    if (this.side1 != null) {
      data['side1'] = this.side1!.toJson();
    }
    if (this.side2 != null) {
      data['side2'] = this.side2!.toJson();
    }
    data['isActive'] = this.isActive;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }*/
}
