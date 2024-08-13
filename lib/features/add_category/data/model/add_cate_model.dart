class CategoryModel {
  String? name;
  List<String>? keywords;
  List<Styles>? styles;

  CategoryModel({this.name, this.keywords, this.styles,});

  CategoryModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    keywords = json['keywords'].cast<String>();
    if (json['styles'] != null) {
      styles = <Styles>[];
      json['styles'].forEach((v) {
        styles!.add(new Styles.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['keywords'] = this.keywords;
    if (this.styles != null) {
      data['styles'] = this.styles!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Styles {
  String? key;
  String? value;

  Styles({this.key, this.value});

  Styles.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['key'] = this.key;
    data['value'] = this.value;
    return data;
  }
}