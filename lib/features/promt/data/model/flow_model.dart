class AddFlowModel {
  List<PromptFlow>? flow;

  AddFlowModel({this.flow});

  AddFlowModel.fromJson(Map<String, dynamic> json) {
    if (json['data']['record'] != null) {
      flow = <PromptFlow>[];
      json['data']['record'].forEach((v) {
        flow!.add(PromptFlow.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.flow != null) {
        data['flow']= this.flow!.map((v) => v.toJson()).toList();

    }
    return data;
  }
}
class PromptFlow {
  String? id;
  String? module;
  String? name;

  PromptFlow({this.id, this.module});

  PromptFlow.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['name'];
    module = 'prompt';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['module'] = this.module;
   // data['name'] = this.name;
    return data;
  }
}

