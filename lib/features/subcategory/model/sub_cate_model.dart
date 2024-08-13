class SubCategoryModel {
  String? sId;
  String? userId;
  String? name;
  List<String>? keywords;
  List<Styles>? styles;
  List<String>? summary; // Added summary field
  String? createdAt;
  String? updatedAt;
  int? iV;

  SubCategoryModel({
    this.sId,
    this.userId,
    this.name,
    this.keywords,
    this.styles,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.summary, // Added summary parameter in constructor
  });

  SubCategoryModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'];
    name = json['name'];
    summary = List<String>.from(json['summary'] ?? []); // Parse summary as list of strings
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
    data['summary'] = summary; // Include summary field in JSON
    data['keywords'] = keywords;
    if (styles != null) {
      data['styles'] = styles!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
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
class MainCategoryModel {
  final String id;
  final String userId;
  final String name;
  final List<String> keywords;
  final List<Map<String, dynamic>> styles;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> summary;

  MainCategoryModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.keywords,
    required this.styles,
    required this.createdAt,
    required this.updatedAt,
    required this.summary,
  });

  factory MainCategoryModel.fromJson(Map<String, dynamic> json) {
    return MainCategoryModel(
      id: json['_id'],
      userId: json['userId'],
      name: json['name'],
      keywords: List<String>.from(json['keywords']),
      styles: List<Map<String, dynamic>>.from(json['styles']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      summary: List<String>.from(json['summary']),
    );
  }
}