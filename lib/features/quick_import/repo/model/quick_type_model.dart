import 'package:equatable/equatable.dart';

class QuickImportModel extends Equatable {
  String? sId;
  String? userId;
  String? name;
  List<String>? keywords;
  List<Styles>? styles;
  String? createdAt;
  String? updatedAt;
  int? iV;

  QuickImportModel(
      {this.sId,
        this.userId,
        this.name,
        this.keywords,
        this.styles,
        this.createdAt,
        this.updatedAt,
        this.iV});

  QuickImportModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'];
    name = json['name'];
    keywords = json['keywords'].cast<String>();
    if (json['styles'] != null) {
      styles = <Styles>[];
      json['styles'].forEach((v) {
        styles!.add(Styles.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['userId'] = userId;
    data['name'] = name;
    data['keywords'] = keywords;
    if (styles != null) {
      data['styles'] = styles!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }

  @override
  List<Object?> get props => [sId,userId,name,keywords,styles,createdAt,updatedAt];
}

class Styles {
  String? key;
  String? value;
  String? sId;

  Styles({this.key, this.value, this.sId});

  Styles.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    value = json['value'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['key'] = key;
    data['value'] = value;
    data['_id'] = sId;
    return data;
  }
}
