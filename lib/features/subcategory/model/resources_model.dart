class AllResourcesModel {
  String? message;
  Data? data;

  AllResourcesModel({this.message, this.data});

  AllResourcesModel.fromJson(Map<String, dynamic> json) {
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
  Count? count;

  Record({this.records, this.count});

  Record.fromJson(Map<String, dynamic> json) {
    if (json['records'] != null) {
      records = <Records>[];
      json['records'].forEach((v) {
        records!.add(new Records.fromJson(v));
      });
    }
    count = json['count'] != null ? new Count.fromJson(json['count']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.records != null) {
      data['records'] = this.records!.map((v) => v.toJson()).toList();
    }
    if (this.count != null) {
      data['count'] = this.count!.toJson();
    }
    return data;
  }
}

class Records {
  String? sId;
  String? type;
  String? content;
  String? rootId;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? title;

  Records(
      {this.sId,
        this.type,
        this.content,
        this.rootId,
        this.createdAt,
        this.updatedAt,
        this.iV,
        this.title});

  Records.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    type = json['type'];
    content = json['content'];
    rootId = json['rootId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    title = json['title'];

    print('$sId $type $content $rootId $createdAt $updatedAt $iV $title\n Response');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['type'] = this.type;
    data['content'] = this.content;
    data['rootId'] = this.rootId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['title'] = this.title;
    return data;
  }
}

class Count {
  int? imageCount;
  int? videoCount;
  int? audioCount;
  int? textCount;
  int? totalCount;

  Count(
      {this.imageCount,
        this.videoCount,
        this.audioCount,
        this.textCount,
        this.totalCount});

  Count.fromJson(Map<String, dynamic> json) {
    imageCount = json['imageCount'];
    videoCount = json['videoCount'];
    audioCount = json['audioCount'];
    textCount = json['textCount'];
    totalCount = json['totalCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['imageCount'] = this.imageCount;
    data['videoCount'] = this.videoCount;
    data['audioCount'] = this.audioCount;
    data['textCount'] = this.textCount;
    data['totalCount'] = this.totalCount;
    return data;
  }
}
