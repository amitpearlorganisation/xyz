

import 'flow_model.dart';

class PromtModel {
  String? sId;
  String? name;
  ResourceId? resourceId;
  ResourceId? side1;
  ResourceId? side2;
  bool? isActive;
  String? createdAt;
  String? updatedAt;
  int? iV;

  PromtModel(
      {this.sId,
        this.name,
        this.resourceId,
        this.side1,
        this.side2,
        this.isActive,
        this.createdAt,
        this.updatedAt,
        this.iV});

  PromtModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    resourceId = json['resourceId'] != null
        ? new ResourceId.fromJson(json['resourceId'])
        : null;
    side1 =
    json['side1'] != null ? new ResourceId.fromJson(json['side1']) : null;
    side2 =
    json['side2'] != null ? new ResourceId.fromJson(json['side2']) : null;
    isActive = json['isActive'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
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
  }
}

class ResourceId {
  String? sId;
  String? type;
  String? rootId;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? content;
  String? title;

  ResourceId(
      {this.sId,
        this.type,
        this.rootId,
        this.createdAt,
        this.updatedAt,
        this.iV,
        this.content,
        this.title});

  ResourceId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    type = json['type'];
    rootId = json['rootId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    content = json['content'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['type'] = this.type;
    data['rootId'] = this.rootId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['content'] = this.content;
    data['title'] = this.title;
    return data;
  }
}



class PromtAndAddFlowModel {
  List<PromtModel> promtList;
  AddFlowModel addFlowModel;

  PromtAndAddFlowModel({
    required this.promtList,
    required this.addFlowModel,
  });
}