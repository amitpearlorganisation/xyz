class QuickTypeModel {
  String? message;
  Data? data;

  QuickTypeModel({this.message, this.data});

  QuickTypeModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  Record? record;

  Data({this.record});

  Data.fromJson(Map<String, dynamic> json) {
    record =
    json['record'] != null ? new Record.fromJson(json['record']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.record != null) {
      data['record'] = this.record!.toJson();
    }
    return data;
  }
}

class Record {
  List<Records>? records;
  int? imageCount;
  int? videoCount;
  int? audioCount;
  int? textCount;
  int? totalCount;

  Record(
      {this.records,
        this.imageCount,
        this.videoCount,
        this.audioCount,
        this.textCount,
        this.totalCount});

  Record.fromJson(Map<String, dynamic> json) {
    if (json['records'] != null) {
      records = <Records>[];
      json['records'].forEach((v) {
        records!.add(new Records.fromJson(v));
      });
    }
    imageCount = json['imageCount'];
    videoCount = json['videoCount'];
    audioCount = json['audioCount'];
    textCount = json['textCount'];
    totalCount = json['totalCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.records != null) {
      data['records'] = this.records!.map((v) => v.toJson()).toList();
    }
    data['imageCount'] = this.imageCount;
    data['videoCount'] = this.videoCount;
    data['audioCount'] = this.audioCount;
    data['textCount'] = this.textCount;
    data['totalCount'] = this.totalCount;
    return data;
  }
}

class Records {
  String? sId;
  String? title;
  String? type;
  String? content;
  String? rootId;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Records(
      {this.sId,
        this.title,
        this.type,
        this.content,
        this.rootId,
        this.createdAt,
        this.updatedAt,
        this.iV});

  Records.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    type = json['type'];
    content = json['content'];
    rootId = json['rootId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['title'] = this.title;
    data['type'] = this.type;
    data['content'] = this.content;
    data['rootId'] = this.rootId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
///////// only need resourceID and resourceName seprate to upper model use in Dailog expensionList resource

class QuickResourceModel{
  String? resourceName;
  String? resourceId;

  QuickResourceModel({required this.resourceName, required this.resourceId});


}