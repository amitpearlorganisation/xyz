import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../features/resources/maincategory_resources_screen.dart';

class resourceScreenWidget extends StatefulWidget {
  String rootId;
  String categoryName;
  String level;

   resourceScreenWidget({required this.rootId, required this.categoryName, required this.level});

  @override
  State<resourceScreenWidget> createState() => _resourceScreenWidgetState();
}

class _resourceScreenWidgetState extends State<resourceScreenWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("View Resource"),),
        body: MaincategoryResourcesList(rootId: widget.rootId!, title: widget.categoryName! ,mediaType: "",level: widget.level!,));
  }
}
