class SubCategoryModel1 {
  String? sId;
  String? userId;
  String? name;
  List<String>? keywords;
  String? createdAt;
  String? updatedAt;
  int? iV;
  List<SubCategoryModel1> catlist;


  SubCategoryModel1(
      {
        required this.sId,
        required  this.userId,
        required  this.name,
        required  this.keywords,
          this.createdAt,
           this.updatedAt,
           this.iV,
        required this.catlist
      });


}
class SubCategoryModel2 {
  String? sId;
  String? userId;
  String? name;
  List<String>? keywords;
  String? createdAt;
  String? updatedAt;
  int? iV;

  SubCategoryModel2(
      {this.sId,
        this.userId,
        this.name,
        this.keywords,
        this.createdAt,
        this.updatedAt,
        this.iV});

}

