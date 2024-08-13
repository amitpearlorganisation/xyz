

class CategoryModel {

  String title = '';
  String categoryId = '';


  CategoryModel({//this.promptId,
        required this.categoryId,
        /*this.createdAt,
      this.updatedAt,*/
        required this.title});

  CategoryModel.fromJson(Map<String, dynamic> json) {
    //promptId = json['_id'];
    categoryId = json['rootId']??'';
    /*createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];*/
    title = json['title']??'';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    //data['_id'] = this.promptId;
    // data['type'] = this.type;
    data['rootId'] = this.categoryId;
    /*data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['content'] = this.content;*/
    data['title'] = this.title;
    return data;
  }
}
