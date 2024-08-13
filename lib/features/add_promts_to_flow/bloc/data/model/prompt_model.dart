

class PromptModel {
  String? promptId;
  String? resourceId;
  /*String? createdAt;
  String? updatedAt;*/
  String? title;
  bool? isSelected;



  PromptModel(
      {this.promptId,
      this.resourceId,
        this.isSelected,
      /*this.createdAt,
      this.updatedAt,*/
      this.title});

  PromptModel.fromJson(Map<String, dynamic> json) {
    promptId = json['_id'];
    resourceId = json['rootId'];
    isSelected = json['selected'];
    /*createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];*/
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = this.promptId;
    // data['type'] = this.type;
    data['rootId'] = this.resourceId;
    /*data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['content'] = this.content;*/
    data['selected'] = this.isSelected;
    data['title'] = this.title;
    return data;
  }
}
