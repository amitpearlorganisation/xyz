import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'add_resources_screen.dart';

class AddResourceWidget extends StatelessWidget {
  final int whichResources;
  final String rootId;
  final String categoryName;
  const AddResourceWidget({required this.whichResources, required this.rootId, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Resource"),),
      body: AddResourceScreen(rootId: rootId, categoryName: categoryName,whichResources: whichResources),
    );
  }
}
