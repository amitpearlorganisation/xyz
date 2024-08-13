

/*class FlowModel{
  String title;
  String id;

  FlowModel({required this.title, required this.id});
}*/



class FlowModel{
  String title;
  String id;
  String categoryId;
  String? dateTime;
  List<FlowDataModel> flowList;
  FlowModel({
    required this.title,
    required this.categoryId,
    required this.flowList,
    required this.id,
    this.dateTime
  });

}


class FlowDataModel{
  String resourceTitle;
  String resourceType;
  String resourceContent;
  String side1Title;
  String side1Type;
  String side1Content;
  String side2Title;
  String side2Type;
  String side2Content;
  String promptName;
  String promptId;

  FlowDataModel({
    required this.resourceTitle,
    required this.resourceType,
    required this.resourceContent,
    required this.side1Title,
    required this.side1Type,
    required this.side1Content,
    required this.side2Title,
    required this.side2Type,
    required this.side2Content,
    required this.promptName,
    required this.promptId});
}

