
import '../../../create_flow/data/model/flow_model.dart';

class PrimaryPromptModel {
  String? promptId;
  String? resourceId;
  /*String? createdAt;
  String? updatedAt;*/
  String? title;
  List<FlowDataModel> flowList;



  PrimaryPromptModel(
      {this.promptId,
        this.resourceId,
        /*this.createdAt,
      this.updatedAt,*/
        this.title,
      required this.flowList
      });



  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = this.promptId;
    // data['type'] = this.type;
    data['rootId'] = this.resourceId;
    /*data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['content'] = this.content;*/
    data['title'] = this.title;
    return data;
  }
}